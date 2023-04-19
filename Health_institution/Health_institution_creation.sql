-- Create database that monitors workload, capabilities and activities of our city's health institutions. 
--The database needs to represent institutions, their locations, staffing, capacity, capabilities and patients' visits.
--✓ 6+ tables
--✓ 5+ rows in every table, 50+ rows total
--✓ 3NF, Primary and Foreign keys must be defined
--✓ Not null constraints where appropriate and at least 2 check constraints of other type
--✓ Using DEFAULT and GENERATED ALWAYS AS are encouraged


--CREATE DATABASE health_institutions;

CREATE SCHEMA IF NOT EXISTS health_data;

CREATE TABLE IF NOT EXISTS health_data.institution
	(
	institution_id BIGSERIAL PRIMARY KEY, --not null constraint
	institution_name VARCHAR(50) NOT NULL,
	i_location VARCHAR(50) NOT NULL
	);

CREATE 	TABLE IF NOT EXISTS health_data.department
	(
	capability_id BIGSERIAL PRIMARY KEY,
	dep_name VARCHAR(50) NOT NULL,
	institution_id BIGINT NOT NULL REFERENCES health_data.institution -- FOREIGN key
	);

CREATE TABLE IF NOT EXISTS health_data.specialization
	(
	spec_id BIGSERIAL PRIMARY KEY,
	spec_name VARCHAR(50) NOT NULL
	);

CREATE TABLE IF NOT EXISTS health_data.doctor
	(
	doctor_id BIGSERIAL PRIMARY KEY , 
	first_name VARCHAR(50) NOT NULL,
	surname VARCHAR(50) NOT NULL ,
	full_name VARCHAR(100) GENERATED ALWAYS AS (first_name ||' '||surname) STORED NOT NULL, 
	gender VARCHAR(6) CHECK (gender IN ('male','female')), -- other check constraint
	capability_id BIGINT NOT NULL REFERENCES health_data.department,
	spec_id BIGINT NOT NULL REFERENCES health_data.specialization
	);

CREATE TABLE IF NOT EXISTS health_data.patient
	(
	patient_id BIGSERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	surname VARCHAR(50) NOT NULL,
	full_name VARCHAR(100) GENERATED ALWAYS AS (first_name ||' '||surname) STORED NOT NULL
	);

CREATE TABLE IF NOT EXISTS health_data.appointment
	(
	appointment_id BIGSERIAL PRIMARY KEY,
	a_date DATE DEFAULT CURRENT_DATE NOT NULL, --DEFAULT constrain , NEW appointent will be added IN CURRENT day
	patient_id BIGINT NOT NULL REFERENCES health_data.patient,
	doctor_id BIGINT NOT NULL REFERENCES health_data.doctor
	);
	
INSERT INTO health_data.institution (institution_name,i_location)
SELECT institution_name,i_location
FROM
	(
	VALUES
		('University hospital','Pradnicka 80'),
		('Kopernik hospital','Kopernika 15'),
		('Dietl hospital','Focha 33'),
		('Military hospital','Wroclawska 1'),
		('Rydygier hospital','Mistrzejowicka 31')
	)AS institutions (institution_name,i_location)
	-- to avoid duplicates we check if rows exist in table
WHERE NOT EXISTS 
	(
		SELECT 1 FROM health_data.institution 
		WHERE upper(institution_name) IN (upper('University hospital'),upper('Kopernik hospital'),upper('Dietl hospital'),upper('Military hospital'),upper('Rydygier hospital'))
	);
	
INSERT INTO health_data.department (dep_name, institution_id)
SELECT dep_name, institution_id
FROM
	(
	VALUES
		('Emergency',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('University hospital'))),--avoiding hardcoding - TO ANY hospital we have departments
		('Emergency',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Kopernik hospital'))),
		('Maternity',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Dietl hospital'))),
		('Orthopedics',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Military hospital'))),
		('Dietetics',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Rydygier hospital'))),
		('Pediatric',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('University hospital'))),
		('Cardiology',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Kopernik hospital'))),
		('Urology',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Dietl hospital'))),
		('Neurology',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Military hospital'))),
		('Cardiology',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Military hospital'))),
		('Dermatology',(SELECT institution_id FROM health_data.institution WHERE upper("institution_name") =upper('Rydygier hospital')))
	)AS departments (dep_name, institution_id)
WHERE NOT EXISTS 
	(
		SELECT d.dep_name, i.institution_id  FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id  
		WHERE (upper(d.dep_name) = upper('Emergency') AND i.institution_id = (SELECT institution_id FROM health_data.institution WHERE upper(institution_name) =upper('University hospital')))
		OR (upper(d.dep_name) = upper('Emergency') AND i.institution_id = (SELECT institution_id FROM health_data.institution WHERE upper(institution_name) =upper('Kopernik hospital')))
		OR (upper(d.dep_name) = upper('Maternity') AND i.institution_id = (SELECT institution_id FROM health_data.institution WHERE upper(institution_name) =upper('Dietl hospital')))
		OR (upper(d.dep_name) = upper('Orthopedics') AND i.institution_id = (SELECT institution_id FROM health_data.institution WHERE upper(institution_name) =upper('Military hospital')))
		OR (upper(d.dep_name) = upper('Dietetics') AND i.institution_id =(SELECT institution_id FROM health_data.institution WHERE upper(institution_name) =upper('Rydygier hospital') )));

INSERT INTO health_data.specialization (spec_name)
SELECT spec_name 
FROM
	(
	VALUES
		('Pediatrics'),
		('Dermatology'),
		('Gynecology'),
		('Cardiology'),
		('Neurology'),
		('Urology')
	)AS specializations (spec_name)
WHERE NOT EXISTS 
	(
		SELECT 1 FROM health_data.specialization 
		WHERE upper(spec_name) IN (upper('Pediatrics'),upper('Dermatology'),upper('Gynecology'),upper('Cardiology'),upper('Neurology'),upper('Urology'))
	);

INSERT INTO health_data.doctor (first_name,surname,gender,capability_id,spec_id)
SELECT first_name,surname,gender,capability_id,spec_id
FROM 
	(
	VALUES
	--we choose department and specialization from other tables
		('Sylwia','Adamczak','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Dietl hospital') AND upper("dep_name") = upper('Maternity')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Gynecology'))),
		('Bartosz','Treppa','male',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Dietl hospital') AND upper("dep_name") = upper('Urology')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Urology'))),
		('Ewelina','Baca','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('University hospital') AND upper("dep_name") = upper('Emergency')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Neurology'))),
		('Robert','Bacharz','male',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Kopernik hospital') AND upper("dep_name") = upper('Emergency')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Cardiology'))),
		('Maria','Zybert','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Military hospital') AND upper("dep_name") = upper('Orthopedics')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Dermatology'))),
		('Andrzej','Hendzel','male',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Rydygier hospital') AND upper("dep_name") = upper('Dietetics')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Dermatology'))),
		('Jan','Kowalski','male',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('University hospital') AND upper("dep_name") = upper('Pediatric')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Pediatrics'))),
		('Zofia','Nowak','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Kopernik hospital') AND upper("dep_name") = upper('Cardiology')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Cardiology'))),
		('Ewa','Badura','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Military hospital') AND upper("dep_name") = upper('Neurology')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Neurology'))),
		('Arkadiusz','Waszczuk','male',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Military hospital') AND upper("dep_name") = upper('Cardiology')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Cardiology'))),
		('Kamila','Kuchta','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('Rydygier hospital') AND upper("dep_name") = upper('Dermatology')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Dermatology'))),
		('Agata','Fundakowska','female',
						(SELECT capability_id 
						FROM health_data.institution i INNER JOIN health_data.department d ON i.institution_id =d.institution_id 
						WHERE upper("institution_name") = upper('University hospital') AND upper("dep_name") = upper('Pediatric')),
						(SELECT spec_id FROM health_data.specialization WHERE upper("spec_name") = upper('Pediatrics')))
		) AS doctors (first_name,surname,gender,capability_id,spec_id)
WHERE NOT EXISTS
	(
		SELECT full_name FROM health_data.doctor 
		WHERE upper("full_name") IN (upper('Sylwia Adamczak'),upper('Bartosz Treppa'),upper('Ewelina Baca'),upper('Robert Bacharz'),upper('Maria Zybert'),
			upper('Andrzej Hendzel'),upper('Jan Kowalski'),upper('Zofia Nowak'),upper('Ewa Badura'),upper('Arkadiusz Waszczuk'),upper('Kamila Kuchta'),upper('Agata Fundakowska'))
	);


INSERT INTO health_data.patient (first_name,surname)
SELECT first_name,surname
FROM
	(
	VALUES
		('Aneta','Mazur'),
		('Cecylia','Krawczyk'),
		('Celina','Sikora'),
		('Danuta','Duda'),
		('Felicja','Makowska'),
		('Halina','Kurek'),
		('Jola','Pawlik'),
		('Artur','Maj'),
		('Oskar','Kot'),
		('Stefan','Kruk'),
		('Szymon','Kruk'),
		('Tymon','Skiba'),
		('Wiktor','Pluta'),
		('Witold','Rak'),
		('Zenon','Pawlik')
	)AS patients (first_name,surname)
WHERE NOT EXISTS 
	(
		SELECT full_name FROM health_data.patient 
		WHERE upper("full_name") IN (upper('Aneta Mazur'),upper('Cecylia Krawczyk'),upper('Celina Sikora'),upper('Danuta Duda'),upper('Felicja Makowska'),
			upper('Halina Kurek'),upper('Jola Pawlik'),upper('Artur Maj'),upper('Oskar Kot'),upper('Stefan Kruk'),upper('Szymon Kruk'),upper('Tymon Skiba'),
			upper('Wiktor Pluta'),upper('Zenon Pawlik'),upper('Witold Rak'))
	);


INSERT INTO health_data.appointment (patient_id, a_date, doctor_id)
SELECT patient_id, a_date, doctor_id
FROM(
		VALUES
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2022-01-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2022-04-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2022-06-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2022-09-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2022-11-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2023-01-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2023-03-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Cecylia Krawczyk')),
				'2023-03-02'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Celina Sikora')),
				'2023-03-03'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Felicja Makowska')),
				'2023-03-04'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Danuta Duda')),
				'2023-03-04'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Halina Kurek')),
				'2023-03-05'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Jola Pawlik')),
				'2023-03-05'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Jola Pawlik')),
				'2023-03-15'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Oskar Kot')),
				'2023-02-15'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Artur Maj')),
				'2023-03-01'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Artur Maj')),
				'2023-03-15'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Artur Maj')),
				'2023-03-30'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Oskar Kot')),
				'2023-03-02'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Stefan Kruk')),
				'2023-03-04'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Bartosz Treppa'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Witold Rak')),
				'2023-03-11'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Ewelina Baca'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Zenon Pawlik')),
				'2023-03-14'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Robert Bacharz'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Wiktor Pluta')),
				'2023-03-16'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Maria Zybert'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Tymon Skiba')),
				'2023-03-17'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Andrzej Hendzel'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Szymon Kruk')),
				'2023-03-19'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Jan Kowalski'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Stefan Kruk')),
				'2023-03-21'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Zofia Nowak'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Artur Maj')),
				'2023-03-23'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Ewa Badura'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Halina Kurek')),
				'2023-03-25'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Arkadiusz Waszczuk'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Cecylia Krawczyk')),
				'2023-03-27'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Kamila Kuchta'))),
			((SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper('Aneta Mazur')),
				'2023-03-30'::DATE,
				(SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Agata Fundakowska')))
	)AS appointments(patient_id, a_date, doctor_id)
WHERE NOT EXISTS 
	(
		SELECT p.patient_id , a.a_date , d.doctor_id  
			FROM health_data.appointment a 
			INNER JOIN health_data.doctor d
				ON d.doctor_id = a.doctor_id 
			INNER JOIN health_data.patient p 
				ON a.patient_id = p.patient_id
		WHERE p.patient_id = (SELECT patient_id FROM health_data.patient WHERE upper("full_name") = upper(('Aneta Mazur')) 
			AND a.a_date::DATE = '2022-01-01'::DATE 
			AND d.doctor_id  = (SELECT doctor_id FROM health_data.doctor WHERE upper("full_name")=upper('Sylwia Adamczak'))
	));
--we could add another appointments but in that case it check if anyone of that exist there

-- Write a query to identify doctors with insufficient workload
SELECT d.full_name,count(a.appointment_id) AS appointment_count, EXTRACT(YEAR FROM a.a_date) AS YEAR, EXTRACT (MONTH FROM a.a_date) AS MONTH
	FROM health_data.doctor d 
		INNER JOIN health_data.appointment a 
			ON d.doctor_id =a.doctor_id 
	GROUP BY d.full_name, YEAR , MONTH 
	HAVING count(a.appointment_id) <5;


