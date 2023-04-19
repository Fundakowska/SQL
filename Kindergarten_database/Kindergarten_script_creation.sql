CREATE DATABASE kindergarten;

CREATE SCHEMA kindergarten_data;

CREATE TABLE IF NOT EXISTS kindergarten_data.positions
(
position_id SERIAL PRIMARY KEY ,--serial DATA TYPE TO have auto-incrementation
position_name VARCHAR NOT NULL, -- varchar DATA TYPE TO have possibility TO write
position_description VARCHAR
);

CREATE TABLE IF NOT EXISTS kindergarten_data.teacher
(
	teacher_id SERIAL PRIMARY KEY , --constraint
	first_name VARCHAR NOT NULL,
	surname VARCHAR NOT NULL ,
	position_id INTEGER NOT NULL REFERENCES kindergarten_data.positions,--FOREIGN key
	gender VARCHAR,
	salary DECIMAL--FOR salary IS better TO have decimal than integer 
);

CREATE TABLE IF NOT EXISTS kindergarten_data.skill
(skill_id SERIAL PRIMARY KEY,
skill_name VARCHAR NOT NULL,
skill_description VARCHAR
);

CREATE TABLE IF NOT EXISTS kindergarten_data.teacher_skill
(
teacher_id INTEGER NOT NULL REFERENCES kindergarten_data.teacher,
skill_id INTEGER NOT NULL REFERENCES kindergarten_data.skill,
teacher_skill_id SERIAL PRIMARY KEY 
);


CREATE TABLE IF NOT EXISTS kindergarten_data.grade -- INSTEAD OF CLASS IS grade 
(
grade_id SERIAL PRIMARY KEY,
grade_name VARCHAR
);

CREATE TABLE IF NOT EXISTS kindergarten_data.diet
(
type_of_diet VARCHAR NOT NULL,
diet_id SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS kindergarten_data.child_name
(
child_id SERIAL PRIMARY KEY,
first_name VARCHAR NOT NULL,
surname VARCHAR NOT NULL,
diet_id INTEGER NOT NULL REFERENCES kindergarten_data.diet,
grade_id INTEGER NOT NULL REFERENCES kindergarten_data.grade,
date_of_birth DATE NOT NULL,
fee DECIMAL NOT NULL
);

CREATE TABLE IF NOT EXISTS kindergarten_data.type_activity
(
type_activity_id SERIAL PRIMARY KEY,
type_of_activity VARCHAR
);

CREATE TABLE IF NOT EXISTS kindergarten_data.activities
(
type_activity_id INTEGER NOT NULL REFERENCES kindergarten_data.type_activity,
activity_id SERIAL PRIMARY KEY,
detailed_info VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS kindergarten_data.child_activity
(
child_id INTEGER NOT NULL REFERENCES kindergarten_data.child_name,
activity_id INTEGER NOT NULL REFERENCES kindergarten_data.activities,
child_activity_id SERIAL PRIMARY KEY 
);

CREATE TABLE IF NOT EXISTS kindergarten_data.activity_teacher
(
activity_id INTEGER NOT NULL REFERENCES kindergarten_data.activities,
teacher_id INTEGER NOT NULL REFERENCES kindergarten_data.teacher,
activity_teacher_id SERIAL PRIMARY KEY
);

--Create at least 5 check constraints, not considering unique and not null, on your tables 
--(in total 5, not for each table).


	ALTER TABLE kindergarten_data.teacher 
	ADD CHECK (gender IN ('male','female')); --ONLY two possible gender TO avoid misspelling
	
	ALTER TABLE kindergarten_data.child_name 
	ADD CHECK (fee < 5000);--that IS the highest possible fee
	
	ALTER TABLE kindergarten_data.teacher 
	ADD COLUMN create_date DATE NOT NULL ;
	
	ALTER TABLE kindergarten_data.grade 
	ADD CHECK (grade_id IN (1,2,3,4,5));--ONLY five classes
	
	ALTER TABLE kindergarten_data.positions 
	ADD CHECK (position_description IN ('Junior','Senior'));
	
	ALTER TABLE kindergarten_data.teacher 
	ALTER create_date SET DEFAULT CURRENT_DATE;


--Fill your tables with sample data 
--(create it yourself, 20+ rows total in all tables, make sure each table has at least 2 rows).

INSERT INTO kindergarten_data.diet(type_of_diet)
VALUES ('gluten-free'),
	( 'meat-free');

INSERT INTO kindergarten_data.grade (grade_name)
VALUES ('three-year-olds'),
	('four-year-olds'),
	('five-year-olds'),
	('six-year-olds');

INSERT INTO kindergarten_data.child_name (first_name, surname,diet_id,grade_id,date_of_birth,fee)
VALUES ('Szymon','Kowal',1,4,'2017-01-02',1000),
	('Anna','Nowak',2,1,'2020-07-03',850);
	
INSERT INTO kindergarten_data.skill (skill_name,skill_description)
VALUES ('english','possibility to teach in english'),
	('science','possibility to teach science');

INSERT INTO kindergarten_data.positions (position_name,position_description)
VALUES ('English Teacher','Junior'),
	('Teacher','Senior');
	
INSERT INTO kindergarten_data.teacher (first_name,surname,position_id,gender,salary)
VALUES ('Agata','Smith',1,'female',4000),
	('Britney','Spears',2,'female',6000);

INSERT INTO kindergarten_data.teacher_skill (teacher_id,skill_id)
SELECT t.teacher_id ,s.skill_id 
FROM kindergarten_data.teacher t 
	INNER JOIN kindergarten_data.teacher_skill ts
		ON t.teacher_id =ts.teacher_id 
	INNER JOIN kindergarten_data.skill s 
		ON s.skill_id =ts.skill_id 
	WHERE (t.first_name ='Agata' AND t.surname = 'Smith' AND s.skill_name ='english')
		OR (t.first_name = 'Britney' AND t.surname = 'Spears' AND s.skill_name ='science');

INSERT INTO kindergarten_data.type_activity (type_of_activity)
VALUES ('language'),
	('sport');
	

INSERT INTO kindergarten_data.activities (type_activity_id,detailed_info)
SELECT type_activity_id , 'english classes'
FROM kindergarten_data.type_activity 
	WHERE type_of_activity ='language';

INSERT INTO kindergarten_data.activities (type_activity_id,detailed_info)
SELECT type_activity_id , 'polish classes'
FROM kindergarten_data.type_activity 
	WHERE type_of_activity ='language';


INSERT INTO kindergarten_data.activity_teacher (activity_id,teacher_id)
SELECT a.activity_id ,t.teacher_id
FROM kindergarten_data.activities a
	INNER JOIN kindergarten_data.activity_teacher at2
		ON a.activity_id =at2.activity_id 
	INNER JOIN kindergarten_data.teacher t
		ON t.teacher_id =at2.teacher_id 
	WHERE (a.detailed_info = 'english classes' AND t.first_name ='Agata' AND t.surname = 'Smith')
		OR (a.detailed_info ='polish classes' AND t.first_name = 'Britney' AND t.surname = 'Spears');

INSERT INTO kindergarten_data.child_activity (child_id,activity_id)
SELECT cn.child_id,a.activity_id
FROM kindergarten_data.child_name cn
	INNER JOIN kindergarten_data.child_activity ca 
		ON cn.child_id =ca.child_id 
	INNER JOIN kindergarten_data.activities a
		ON a.activity_id =ca.activity_id 
	WHERE (cn.first_name='Szymon' AND cn.surname='Kowal' AND a.detailed_info='english classes')
		OR (cn.first_name='Szymon' AND cn.surname='Kowal' AND a.detailed_info='polish classes');

--Alter all tables and add 'record_ts' field to each table. 
--Make it not null and set its default value to current_date.


	ALTER TABLE kindergarten_data.diet 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.activities 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.activity_teacher 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.child_activity 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.child_name 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.grade 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.positions 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.skill 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.teacher 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.teacher_skill 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
	
	ALTER TABLE kindergarten_data.type_activity 
	ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;


-- Check that the value has been set for existing rows.
SELECT *
FROM kindergarten_data.child_name cn ;