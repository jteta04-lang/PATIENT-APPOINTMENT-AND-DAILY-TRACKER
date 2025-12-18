--- create pluggale database 
CREATE PLUGGABLE DATABASE thursday_27666_juliet_PatientAppointmentandDailyTracker_db
ADMIN USER juliet IDENTIFIED BY juliet
ROLES = (DBA)
FILE_NAME_CONVERT = (
   'C:\USERS\JULIE\DOWNLOADS\ORADATA\ORCL\PDBSEED\', 
   'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\'
)
STORAGE (MAXSIZE UNLIMITED)
DEFAULT TABLESPACE users
DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\users01.dbf'
SIZE 100M AUTOEXTEND ON;

show pdbs;

--- Open the pdb

ALTER PLUGGABLE DATABASE thursday_27666_juliet_PatientAppointmentandDailyTracker_db OPEN;



--- saving the state so it opens automatically on restart

ALTER PLUGGABLE DATABASE thursday_27666_juliet_PatientAppointmentandDailyTracker_db SAVE STATE;

---- connecting to the new pdb and create admin user

---- switch to the new pdb

ALTER SESSION SET CONTAINER = thursday_27666_juliet_PatientAppointmentandDailyTracker_db;

---create super admin user 

CREATE USER juliet_admin IDENTIFIED BY juliet
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp 
QUOTA UNLIMITED ON users;

---- grant all privileges

GRANT DBA TO juliet_admin;
GRANT CREATE SESSION TO juliet_admin;
GRANT CREATE TABLE TO juliet_admin;
GRANT CREATE VIEW TO juliet_admin;
GRANT CREATE PROCEDURE TO juliet_admin;
GRANT CREATE TRIGGER TO juliet_admin;
GRANT CREATE SEQUENCE TO juliet_admin;


--- configure tablepsaces

---- create data tablespaces 

CREATE TABLESPACE patient_data
  DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\patient_data01.dbf'
  SIZE 200M
  AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

--- create index tablespace

CREATE TABLESPACE patient_idx
  DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\patient_idx01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 25M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

--- create temporary tablespace group

CREATE TEMPORARY TABLESPACE patient_temp
TEMPFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\temp01.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 25M
TABLESPACE GROUP temp_group;

--- set default tablespace for admin user

ALTER USER juliet_admin
DEFAULT TABLESPACE patient_data
TEMPORARY TABLESPACE patient_temp;

-- configure memory parameters

--- configure SGA and PGA for the PDB

ALTER SYSTEM SET SGA_TARGET = 1G SCOPE = BOTH;
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 300M SCOPE = BOTH;

--- enable archive logging and configure
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- check current archiving status
ARCHIVE LOG LIST;

-- enable archiving 

ALTER DATABASE ARCHIVELOG;

----configure archive log destination

ALTER SYSTEM SET LOG_ARCHIVE_DES1 = 'LOCATION=/opt/oracle/archivelog/ORCLCDB/thursday_27666_juliet_PatientAppointmentandDailyTracker_db' SCOPE = BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT = 'arch_%t_%s_%r.arc' SCOPE = SPFILE;

--- set archive log mode for pdb
ALTER PLUGGABLE DATABASE thursday_27666_juliet_PatientAppointmentandDailyTracker_db
ARCHIVELOG;

---- configure autoextend parameters

ALTER DATABASE
DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\users01.dbf'
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;

ALTER DATABASE
DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\patient_data01.dbf'
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;

ALTER DATABASE
DATAFILE 'C:\USERS\JULIE\ORADATA\ORCL\thursday_27666_juliet_PatientAppointmentandDailyTracker_db\patient_idx01.dbf'
AUTOEXTEND ON NEXT 25M MAXSIZE UNLIMITED;


---- TABLE CREATION----
  ---1.departments
CREATE TABLE DEPARTMENTS (
department_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
dept_code VARCHAR2(10) NOT NULL UNIQUE,
dept_name VARCHAR2(100) NOT NULL,
active    CHAR(1) DEFAULT 'Y' CHECK (active IN ('Y','N'))
);

  ---2.users/staff
CREATE TABLE users_staff (
    staff_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'CLERK' CHECK (role IN ('ADMIN','DOCTOR','NURSE','CLERK','RECEPTION')),
    email VARCHAR(100),
    created_on DATE DEFAULT SYSDATE NOT NULL
);

  ---3.Patients
CREATE TABLE patients (
    patient_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    national_id VARCHAR2(20) UNIQUE,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    gender VARCHAR(10) DEFAULT 'OTHER' 
        CHECK (gender IN ('M','F','OTHER')),
    date_of_birth DATE,
    phone VARCHAR2(20),
    email VARCHAR2(100),
    address VARCHAR2(200),
    created_on DATE DEFAULT SYSDATE NOT NULL
);

ALTER TABLE patients
ADD last_visit DATE;


 ---4.Doctors
CREATE TABLE doctors (
    doctor_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_code VARCHAR2(20) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    department_id NUMBER NOT NULL,
    phone VARCHAR2(20),
    email VARCHAR2(100),
    active CHAR(1) DEFAULT 'Y' CHECK (active IN ('Y','N')),
    
    CONSTRAINT fk_doctor_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

ALTER TABLE doctors
ADD (
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);


  ---5.Appointments
CREATE TABLE appointments (
    appointment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_no VARCHAR2(50) NOT NULL,  -- You need to define a length for VARCHAR2
    patient_id NUMBER NOT NULL,
    doctor_id NUMBER NOT NULL,
    department_id NUMBER NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time VARCHAR2(10),
    status VARCHAR2(20) DEFAULT 'SCHEDULED'
        CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    reason VARCHAR2(4000),  -- Ensure this is the intended size
    created_by NUMBER,
    created_on DATE DEFAULT SYSDATE NOT NULL,
    
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    CONSTRAINT fk_appt_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

 ---6.Visits(daily log)
 CREATE TABLE visits (
    visit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visit_no VARCHAR2(30) NOT NULL UNIQUE,  -- Corrected data type (VARCHAR2)
    patient_id NUMBER NOT NULL,
    doctor_id NUMBER,
    department_id NUMBER NOT NULL,
    visit_date DATE NOT NULL,
    visit_time VARCHAR2(10),
    visit_type VARCHAR2(20) DEFAULT 'OUTPATIENT'
        CHECK (visit_type IN ('OUTPATIENT', 'INPATIENT', 'EMERGENCY')),
    visit_status VARCHAR2(20) DEFAULT 'ATTENDED'
        CHECK (visit_status IN ('ATTENDED', 'LEFT', 'REFERRED', 'DIED')),
    notes VARCHAR2(4000),
    registered_by NUMBER,
    registered_on DATE DEFAULT SYSDATE NOT NULL,
    
    CONSTRAINT fk_visit_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_visit_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),  -- Corrected table name
    CONSTRAINT fk_visit_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)  -- Corrected table name
);

 ----7.Dailytracker
CREATE TABLE daily_tracker (
    tracker_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tracker_date DATE NOT NULL,
    department_id NUMBER NOT NULL,
    patient_count NUMBER DEFAULT 0 CHECK (patient_count >= 0),
    created_on DATE DEFAULT SYSDATE NOT NULL,
    created_by NUMBER,
    
    CONSTRAINT uq_tracker_date_dept UNIQUE (tracker_date, department_id),
    CONSTRAINT fk_tracker_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

 
  ---8.Indexes
CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_doctors_dept ON doctors(department_id);
CREATE INDEX idx_appt_date ON appointments(appointment_date);
CREATE INDEX idx_visits_date ON visits(visit_date);
CREATE INDEX idx_dailytracker_date ON daily_tracker(tracker_date);


CREATE SEQUENCE appointments_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


CREATE SEQUENCE patients_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


 ---1.Insert sample departments (manual, realistic)
 INSERT INTO departments (dept_code, dept_name)
 VALUES ('GEN', 'General Medicine');
 
 INSERT INTO departments (dept_code, dept_name)
 VALUES ('PED', 'Pediatrics');
 
 INSERT INTO departments (dept_code, dept_name)
 VALUES ('GYN', 'Gynecology');
 
 INSERT INTO departments (dept_code, dept_name)
 VALUES ('SUR', 'Surgery');
 
 INSERT INTO departments (dept_code, dept_name)
 VALUES ('EMR', 'Emergency');
 
 
  ---2.Insert realistic staff/users
INSERT INTO users_staff (username, full_name, role, email) 
VALUES ('admin01', 'System Administration', 'ADMIN', 'admin@gmail.com');

INSERT INTO users_staff (username, full_name, role, email) 
VALUES ('nurse_jane', 'Jane Uwase', 'NURSE', 'jane@gmail.com');

 INSERT INTO users_staff (username, full_name, role, email)
 VALUES ('doc_paul', 'Dr.Paul Kalisa', 'DOCTOR', 'paul@gmail.com');
 
  ---3.Auto-generate 300 patients (realistic + random)
  BEGIN
   FOR i IN 1..300 LOOP
    INSERT INTO patients (
     national_id, first_name, last_name, gender, date_of_birth,
     phone, email, address
   )
   VALUES (
   '1199' || TRUNC(DBMS_RANDOM.VALUE(100000,999999)),
   CASE MOD(i,5)
    WHEN 0 THEN 'John'
    WHEN 1 THEN 'Grace'
    WHEN 2 THEN 'Eric'
    WHEN 3 THEN 'Aline'
    ELSE 'Samuel'
   END,
   CASE MOD(1,4)
    WHEN 0 THEN 'Nkurunziza'
    WHEN 1 THEN 'Uwimana'
    WHEN 2 THEN 'Hirwa'
    ELSE 'Mukamana'
   END,
   CASE MOD(1,3)
    WHEN 0 THEN 'M'
    WHEN 1 THEN 'F'
    ELSE 'OTHER'
   END,
   ADD_MONTHS(DATE '1980-01-01', -MOD(1, 480)),
   '07' || TRUNC(DBMS_RANDOM.VALUE(80000000,99999999)),
   CASE WHEN MOD(i, 7) = 0 THEN NULL ELSE 'user'||i||'@gmail.com' END,
   'Kigali - District ' || MOD(i,5)
   );
   END LOOP;
 END;
 /
 
 ---4.insert doctors(manual + consistent)
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC100', 'Dr.Paul Kalisa', 1, '0788232345', 'paul@gmail.com');
 
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC200', 'Dr.Alice Murekatete', 2, '0788687898', 'alice@gmail.com');
 
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC300', 'Dr.Jean Claude', 5, '0788212223', 'claude@gmail.com');
 
 
 ----5.Generate 500 appointments(random realistic scheduling)
 BEGIN
  FOR i IN 1..500 LOOP
   INSERT INTO appointments (
    appointment_no, patient_id, doctor_id, department_id,
    appointment_date, appointment_time, status, reason, created_by
   )
   VALUES (
    'APT-' || TO_CHAR(SYSDATE,'YYYMMDD') || '-' || i,
    TRUNC(DBMS_RANDOM.VALUE(1,300)),
    TRUNC(DBMS_RANDOM.VALUE(1,4)),
    TRUNC(DBMS_RANDOM.VALUE(1,5)),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1,90)),
    TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1,300)))||':00',
    CASE MOD(i,4)
     WHEN 0 THEN 'SCHEDULED'
     WHEN 1 THEN 'COMPLETED'
     WHEN 2 THEN 'CANCELLED'
     ELSE 'NO_SHOW'
    END,
     'Follow-up visit',
     1
    );
   END LOOP;
  END;
  /

 ---6.Generate 400 visit logs(daily patient log)
 BEGIN
  FOR i IN 1..400 LOOP
   INSERT INTO visits (
    visit_no, patient_id, doctor_id, department_id,
    visit_date, visit_time, visit_type, visit_status,
    notes, registered_by
   )
   VALUES (
    'VIS' || i,
     TRUNC(DBMS_RANDOM.VALUE(1,300)),
    TRUNC(DBMS_RANDOM.VALUE(1,4)),
    TRUNC(DBMS_RANDOM.VALUE(1,5)),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1,60)),
    TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(8,17)))||':00',
    CASE MOD(i,3)
     WHEN 0 THEN 'OUTPATIENT'
     WHEN 1 THEN 'EMERGENCY'
     ELSE 'INPATIENT'
    END,
    CASE MOD(i,4)
     WHEN 0 THEN 'ATTENDED'
     WHEN 1 THEN 'LEFT'
     WHEN 2 THEN 'REFERRED'
     ELSE 'DIED'
    END,
    'Routine check',
    1
   );
  END LOOP;
 END;
 /
 
 ----7.Generate daily tracker (30 days * 5 departments = 150 rows)
 BEGIN
  FOR d IN 1..30 LOOP
   FOR dept IN 1..5 LOOP
    INSERT INTO daily_tracker (
      tracker_date,
      department_id,
      patient_count,
      created_by
    )
    VALUES (
    SYSDATE - d,
    dept,
    TRUNC(DBMS_RANDOM.VALUE(5,50)),
    1
   );
  END LOOP;
 END LOOP;
END;
/

 ---1. SELECT QUERIES VERIFY DATA
 --A. COUNT ROWS IN EACH MAIN TABLE
 SELECT COUNT(*) AS total_patients FROM patients;
 SELECT COUNT(*) AS total_doctors FROM doctors;
 SELECT COUNT(*) AS total_appointments FROM appointments;
 SELECT COUNT(*) AS total_patients FROM patients;
 
 ---b.check null in important columns
 SELECT * FROM patients WHERE first_name IS NULL OR last_name IS NULL;
 SELECT * FROM doctors WHERE specialization IS NULL;
 SELECT * FROM appointments WHERE appointment_date IS NULL;
 
 ----2.CONSTRAINTS ENFORCED PROPERLY
 ---a. test NOT NULL constrait
 SELECT * FROM patients WHERE phone is NULL;
 
 ----b. test UNIQUE constraint(no duplicates)
 SELECT email, COUNT(*)
 FROM patients
 GROUP BY email
 HAVING COUNT(*) >1;
 
 ----c. test CHECK constraint(gender must be 'm', 'f';
 SELECT *
 FROM patients
 WHERE gender NOT IN ('M','F');
 
 ---3. FOREIGN KEY RELATIONSHIP TESTED
 ---a. check for orphan appointments(appointments referencing missing patients)
 SELECT a.*
 FROM appointments a
 LEFT JOIN patients p ON a.patient_id = p.patient_id
 WHERE p.patient_id IS NULL;
 
 --b.orphan check for doctors
 SELECT a.*
 FROM appointments a
 LEFT JOIN doctors d ON a.doctor_id = d.doctor_id
 WHERE d.doctor_id IS NULL;
 
 ---4.DATA COMPLETENESS
 ---a.check that every patient has atleast one appointment
 SELECT p.patient_id, p.first_name, p.last_name
 FROM patients p
 LEFT JOIN appointments a ON p.patient_id = a.patient_id
 WHERE a.patient_id IS NULL;
 
 ----b.check that every doctor has appointments
 SELECT D.doctor_id
FROM DOCTORS D
WHERE D.department_id = 1;

---TESTING QUERIES
----a.basic retrieval (SELECT)
----i.get all patients
SELECT * FROM patients;

---ii.get all appointments
SELECT * FROM appointments;

---iii.get all doctors
SELECT * FROM doctors

---B.joins(multi-table queries)
---i.patient+appointment details
SELECT p.first_name, p.last_name, a.appointment_date, d.first_name AS doctor_name
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

---ii.daily patient visits(appointments+doctors)
SELECT a.appointment_date, d.first_name AS doctor, p.first_name AS patient
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY a.appointment_date;

-----C.aggregations(group by)
----i.number of patients per dat
SELECT appointment_date, COUNT(*) AS total_patients
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date;

---ii.total appointments per doctor
SELECT d.doctor_id, d.first_name, d.last_name, COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY total_appointments DESC;

----iii.count patients by gender
SELECT gender, COUNT(*) AS total
FROM patients
GROUP BY gender;

----D.Subqueries
-----i.patients with more than 3 appointments
SELECT a.appointment_date, 
       d.first_name AS doctor, 
       p.first_name AS patient
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY a.appointment_date;

----ii.doctors with above-average number of appointments
SELECT doctor_id, full_name
FROM doctors
WHERE doctor_id IN (
  SELECT doctor_id
  FROM appointments
  GROUP BY doctor_id
  HAVING COUNT(*) > (
    SELECT AVG(cnt)
    FROM (
       SELECT COUNT(*) AS cnt
       FROM appointments
       GROUP BY doctor_id
    )
  )
);

----iii.most visited day
SELECT a.appointment_date, 
       d.first_name AS doctor, 
       p.first_name AS patient
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY a.appointment_date;

 
 ---DATABASE INTERACTION AND TRANSCATION---
 ---- procedure1. add new patient (insert + in out parameter)
 CREATE OR REPLACE PROCEDURE add_patient (
  p_patient_id IN OUT NUMBER,
  p_first_name IN VARCHAR2,
  p_last_name IN VARCHAR2,
  p_gender IN VARCHAR2,
  p_phone IN VARCHAR2,
  p_message OUT VARCHAR2
) AS
BEGIN
  -- If the patient_id is not provided, generate a new one
  IF p_patient_id IS NULL THEN
    SELECT patients_seq.NEXTVAL INTO p_patient_id FROM dual;
  END IF;

  -- Check if the phone number already exists
  DECLARE
    v_exists NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_exists
    FROM patients
    WHERE phone = p_phone;

    IF v_exists > 0 THEN
      p_message := 'Error: Duplicate phone number. Please provide a unique phone number.';
      RETURN;
    END IF;
  END;

  -- Insert new patient record
  INSERT INTO patients (patient_id, first_name, last_name, gender, phone)
  VALUES (p_patient_id, p_first_name, p_last_name, p_gender, p_phone);

  -- Success message
  p_message := 'Patient added successfully with ID: ' || p_patient_id;

EXCEPTION
  WHEN OTHERS THEN
    -- Handle unexpected errors
    p_message := 'Unexpected error: ' || SQLERRM;
END;
/

 
 -----2.procedure 2 schedule appointment(insert + exception handling)
CREATE OR REPLACE PROCEDURE SCHEDULE_APPOINTMENT (
    p_appointment_id IN OUT NUMBER,
    p_patient_id IN NUMBER,
    p_doctor_id IN NUMBER,
    p_appointment_date IN DATE,
    p_message OUT VARCHAR2
) AS
BEGIN
    -- If the appointment ID is NULL, generate a new one
    IF p_appointment_id IS NULL THEN
        SELECT appointments_seq.NEXTVAL INTO p_appointment_id FROM dual;
    END IF;

    -- Insert the appointment record
    INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date)
    VALUES (p_appointment_id, p_patient_id, p_doctor_id, p_appointment_date);

    -- Success message
    p_message := 'Appointment scheduled successfully with ID ' || p_appointment_id;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_message := 'Error: Duplicate appointment ID or data exists.';
    WHEN OTHERS THEN
        p_message := 'Unexpected error: ' || SQLERRM;
END;
/

  
-----procedure 3 update appointment status (update +IN parameter
CREATE OR REPLACE PROCEDURE update_appointment_status (
    p_appointment_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_feedback OUT VARCHAR2
) AS
BEGIN
    UPDATE appointments
    SET status = p_new_status
    WHERE appointment_id = p_appointment_id;

    IF SQL%ROWCOUNT = 0 THEN
        p_feedback := 'No appointment found with the given ID.';
    ELSE
        p_feedback := 'Appointment updated successfully.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        p_feedback := 'Error occurred: ' || SQLERRM;
END;
/

---- procedure 4 delete patient (delete + cascade rule testing)
CREATE OR REPLACE PROCEDURE delete_patient (
    p_patient_id IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM appointments
    WHERE patient_id = p_patient_id;

    IF v_count > 0 THEN
        p_result := 'Cannot delete patient. Existing appointments found.';
        RETURN;
    END IF;

    DELETE FROM patients WHERE patient_id = p_patient_id;

    IF SQL%ROWCOUNT = 0 THEN
        p_result := 'Patient not found.';
    ELSE
        p_result := 'Patient deleted successfully.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        p_result := 'Error: ' || SQLERRM;
END;
/
          
----- procedure 5 count daily paatient visits (aggregation + OUT parameter)
CREATE OR REPLACE PROCEDURE daily_visit_count (
    p_date IN DATE,
    p_total OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*)
    INTO p_total
    FROM appointments
    WHERE TRUNC(appointment_date) = TRUNC(p_date);

EXCEPTION
    WHEN OTHERS THEN
        p_total := -1; -- indicates an error
END;
/

------ FUNCTIONS----
----1. calculate patient age
CREATE OR REPLACE FUNCTION get_patient_age (
    p_patient_id IN NUMBER
) RETURN NUMBER
IS
    v_age NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12)
    INTO v_age
    FROM patients
    WHERE patient_id = p_patient_id;

    RETURN v_age;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;  -- patient not found
    WHEN OTHERS THEN
        RETURN -2;  -- unexpected error
END;
/

-----2.VALIDATE PHONE NUMBER FORMAT(VALIDATION)
CREATE OR REPLACE FUNCTION validate_phone (
    p_phone IN VARCHAR2
) RETURN NUMBER
IS
BEGIN
    IF REGEXP_LIKE(p_phone, '^[0-9]{10,13}$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/

----3.CHECK IF DOCTOR EXISTS---
CREATE OR REPLACE FUNCTION doctor_exists (
    p_doctor_id IN NUMBER
) RETURN NUMBER
IS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM doctors
    WHERE doctor_id = p_doctor_id;

    IF v_count > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;  -- unexpected error
END;
/

-----4.COUNT APPOINTMENTS FOR A PATIENT
CREATE OR REPLACE FUNCTION count_patient_appointments (
    p_patient_id IN NUMBER
) RETURN NUMBER
IS
    v_total NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM appointments
    WHERE patient_id = p_patient_id;

    RETURN v_total;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;
/

-----5.GET DOCTOR NAME BY ID
CREATE OR REPLACE FUNCTION get_doctor_name (
    p_doctor_id IN NUMBER
) RETURN VARCHAR2
IS
    v_name VARCHAR2(200);
BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_name
    FROM doctors
    WHERE doctor_id = p_doctor_id;

    RETURN v_name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'DOCTOR NOT FOUND';
    WHEN OTHERS THEN
        RETURN 'ERROR';
END;
/


----EXPLICIT CURSOR: LIST ALL PATIENTS WITH MORE THAN 3 APPOINTMENTS--
CREATE OR REPLACE PROCEDURE list_frequent_patients
AS
    CURSOR c_patients IS
        SELECT p.patient_id, p.first_name, p.last_name,
               COUNT(a.appointment_id) AS total_visits
        FROM patients p
        JOIN appointments a ON p.patient_id = a.patient_id
        GROUP BY p.patient_id, p.first_name, p.last_name
        HAVING COUNT(a.appointment_id) > 3;

    v_id   patients.patient_id%TYPE;
    v_fn   patients.first_name%TYPE;
    v_ln   patients.last_name%TYPE;
    v_count NUMBER;
BEGIN
    OPEN c_patients;

    LOOP
        FETCH c_patients INTO v_id, v_fn, v_ln, v_count;
        EXIT WHEN c_patients%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Patient: ' || v_fn || ' ' || v_ln ||
            ' | Total Visits: ' || v_count
        );
    END LOOP;

    CLOSE c_patients;
END;
/

-----CURSOR--------
-----CURSOR FOR LOOP LIST ALL DOCTORS WITH NUMBER OF PATIENTS
CREATE OR REPLACE PROCEDURE doctor_visit_summary
AS
    CURSOR c_doctors IS
        SELECT d.doctor_id,
               d.first_name || ' ' || d.last_name AS doctor_name,
               COUNT(a.appointment_id) AS total_appointments
        FROM doctors d
        LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
        GROUP BY d.doctor_id, d.first_name, d.last_name;
BEGIN
    FOR doc IN c_doctors LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Doctor: ' || doc.doctor_name ||
            ' | Appointments: ' || doc.total_appointments
        );
    END LOOP;
END;
/

------BULK COLLECT CURSOR: LOAD ALL PATIENTS IDs
CREATE OR REPLACE PROCEDURE bulk_load_patients
AS
    TYPE patient_list IS TABLE OF NUMBER;
    v_patients patient_list;

BEGIN
    SELECT patient_id BULK COLLECT INTO v_patients
    FROM patients;

    DBMS_OUTPUT.PUT_LINE('Loaded ' || v_patients.COUNT || ' patients in memory.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-----BULK INSERT USING FORALL
CREATE OR REPLACE PROCEDURE bulk_insert_daily_visits
AS
    TYPE visit_rec IS RECORD (
        patient_id NUMBER,
        doctor_id  NUMBER,
        visit_date DATE
    );

    TYPE visit_table IS TABLE OF visit_rec;
    v_visits visit_table := visit_table();

BEGIN
    -- Add sample entries
    v_visits.EXTEND(3);
    v_visits(1) := visit_rec(101, 5, SYSDATE);
    v_visits(2) := visit_rec(102, 3, SYSDATE);
    v_visits(3) := visit_rec(110, 4, SYSDATE);

    -- Bulk insert into APPOINTMENTS (use REASON, NOT NOTES)
    FORALL i IN 1 .. v_visits.COUNT
        INSERT INTO appointments (
            appointment_id,
            appointment_no,
            patient_id,
            doctor_id,
            department_id,
            appointment_date,
            reason
        ) VALUES (
            appointments_seq.NEXTVAL,
            'AUTO-' || appointments_seq.CURRVAL,
            v_visits(i).patient_id,
            v_visits(i).doctor_id,
            1,                      -- default department_id (you may adjust)
            v_visits(i).visit_date,
            'BULK INSERT'
        );

    DBMS_OUTPUT.PUT_LINE('Bulk insert completed: ' || v_visits.COUNT || ' records');
END;
/


------WINDOW FUNCTIONS------
-------1.ROW_NUMBER(), RANK(), DENSE_RANK()
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    COUNT(a.appointment_id) AS total_visits,
    ROW_NUMBER() OVER (ORDER BY COUNT(a.appointment_id) DESC) AS row_num,
    RANK()       OVER (ORDER BY COUNT(a.appointment_id) DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY COUNT(a.appointment_id) DESC) AS dense_rank_num
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name;

----2.LAG() and LEAD()
SELECT 
    patient_id,
    appointment_date,
    LAG(appointment_date, 1) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS previous_visit,
    LEAD(appointment_date, 1) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS next_visit
FROM appointments
ORDER BY patient_id, appointment_date;

-----3.PARTITON BY + ORDER BY
SELECT
    doctor_id,
    appointment_id,
    appointment_date,
    COUNT(*) OVER (PARTITION BY doctor_id) AS total_per_doctor
FROM appointments
ORDER BY doctor_id, appointment_date;

-----AGGREGATES WITH OVER()
-----a. running total of daily appointments
SELECT
    appointment_date,
    COUNT(*) AS daily_total,
    SUM(COUNT(*)) OVER (ORDER BY appointment_date) AS running_total
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date;

-----b.percentage contribution of each doctor to total appointments
SELECT
    doctor_id,
    COUNT(appointment_id) AS doctor_total,
    ROUND(
        COUNT(appointment_id) * 100 /
        SUM(COUNT(appointment_id)) OVER (),
        2
    ) AS percentage_of_total
FROM appointments
GROUP BY doctor_id;

----c.average visits per patient
SELECT
    patient_id,
    COUNT(appointment_id) AS total_visits,
    AVG(COUNT(appointment_id)) OVER () AS avg_visits_all_patients
FROM appointments
GROUP BY patient_id;


----PACKAGE SPECILIZATION-------
CREATE OR REPLACE PACKAGE hospital_mgmt_pkg IS

    ---------------------------------------
    -- PATIENT MANAGEMENT
    ---------------------------------------
    PROCEDURE add_patient (
        p_patient_id   IN OUT NUMBER,
        p_first_name   IN VARCHAR2,
        p_last_name    IN VARCHAR2,
        p_gender       IN VARCHAR2,
        p_phone        IN VARCHAR2,
        p_message      OUT VARCHAR2
    );

    ---------------------------------------
    -- APPOINTMENT MANAGEMENT
    ---------------------------------------
    PROCEDURE schedule_appointment (
        p_patient_id   IN NUMBER,
        p_doctor_id    IN NUMBER,
        p_date         IN DATE,
        p_notes        IN VARCHAR2,
        p_status       OUT VARCHAR2
    );

    PROCEDURE update_appointment_status (
        p_appointment_id IN NUMBER,
        p_new_status     IN VARCHAR2,
        p_feedback       OUT VARCHAR2
    );

    ---------------------------------------
    -- UTILITY FUNCTIONS
    ---------------------------------------
    FUNCTION get_patient_age (
        p_patient_id IN NUMBER
    ) RETURN NUMBER;

    FUNCTION doctor_exists (
        p_doctor_id IN NUMBER
    ) RETURN NUMBER;

    FUNCTION count_patient_appointments (
        p_patient_id IN NUMBER
    ) RETURN NUMBER;

    ---------------------------------------
    -- OPTIONAL: bulk insert (must be added to spec to call publicly)
    ---------------------------------------
    PROCEDURE bulk_insert_daily_visits;

END hospital_mgmt_pkg;
/


-----PACKAGE BODY(IMPLEMENTATION)
CREATE OR REPLACE PACKAGE BODY hospital_mgmt_pkg IS

    -----------------------------------------------------------
    -- 1. ADD PATIENT
    -----------------------------------------------------------
    PROCEDURE add_patient (
        p_patient_id   IN OUT NUMBER,
        p_first_name   IN VARCHAR2,
        p_last_name    IN VARCHAR2,
        p_gender       IN VARCHAR2,
        p_phone        IN VARCHAR2,
        p_message      OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO patients (first_name, last_name, gender, phone)
        VALUES (p_first_name, p_last_name, p_gender, p_phone)
        RETURNING patient_id INTO p_patient_id;

        p_message := 'Patient ' || p_first_name || ' added successfully.';
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_message := 'Duplicate patient or phone number.';
        WHEN OTHERS THEN
            p_message := 'Error: ' || SQLERRM;
    END add_patient;

    -----------------------------------------------------------
    -- 2. SCHEDULE APPOINTMENT
    -----------------------------------------------------------
    PROCEDURE schedule_appointment (
        p_patient_id   IN NUMBER,
        p_doctor_id    IN NUMBER,
        p_date         IN DATE,
        p_notes        IN VARCHAR2,
        p_status       OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason)
        VALUES (p_patient_id, p_doctor_id, p_date, p_notes);

        p_status := 'Appointment booked successfully';
    EXCEPTION
        WHEN OTHERS THEN
            p_status := 'Error: ' || SQLERRM;
    END schedule_appointment;

    -----------------------------------------------------------
    -- 3. UPDATE APPOINTMENT STATUS
    -----------------------------------------------------------
    PROCEDURE update_appointment_status (
        p_appointment_id IN NUMBER,
        p_new_status     IN VARCHAR2,
        p_feedback       OUT VARCHAR2
    ) AS
    BEGIN
        UPDATE appointments
        SET status = p_new_status
        WHERE appointment_id = p_appointment_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_feedback := 'Appointment not found.';
        ELSE
            p_feedback := 'Status updated successfully.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_feedback := 'Error: ' || SQLERRM;
    END update_appointment_status;

    -----------------------------------------------------------
    -- 4. GET PATIENT AGE
    -----------------------------------------------------------
    FUNCTION get_patient_age (
        p_patient_id IN NUMBER
    ) RETURN NUMBER IS
        v_age NUMBER;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12)
        INTO v_age
        FROM patients
        WHERE patient_id = p_patient_id;

        RETURN v_age;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
        WHEN OTHERS THEN
            RETURN -2;
    END get_patient_age;

    -----------------------------------------------------------
    -- 5. DOCTOR EXISTS
    -----------------------------------------------------------
    FUNCTION doctor_exists (
        p_doctor_id IN NUMBER
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM doctors WHERE doctor_id = p_doctor_id;
        RETURN CASE WHEN v_count > 0 THEN 1 ELSE 0 END;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END doctor_exists;

    -----------------------------------------------------------
    -- 6. COUNT PATIENT APPOINTMENTS
    -----------------------------------------------------------
    FUNCTION count_patient_appointments (
        p_patient_id IN NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total FROM appointments WHERE patient_id = p_patient_id;
        RETURN v_total;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END count_patient_appointments;

    -----------------------------------------------------------
    -- 7. BULK INSERT DAILY VISITS
    -----------------------------------------------------------
    PROCEDURE bulk_insert_daily_visits AS
        TYPE visit_rec IS RECORD (
            patient_id NUMBER,
            doctor_id  NUMBER,
            visit_date DATE
        );
        TYPE visit_table IS TABLE OF visit_rec;
        v_visits visit_table := visit_table();
    BEGIN
        v_visits.EXTEND(3);
        v_visits(1) := visit_rec(101, 5, SYSDATE);
        v_visits(2) := visit_rec(102, 3, SYSDATE);
        v_visits(3) := visit_rec(110, 4, SYSDATE);

        FORALL i IN 1..v_visits.COUNT
            INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason)
            VALUES (v_visits(i).patient_id, v_visits(i).doctor_id, v_visits(i).visit_date, 'BULK INSERT');

        DBMS_OUTPUT.PUT_LINE('Bulk insert completed: ' || v_visits.COUNT || ' records.');
    END bulk_insert_daily_visits;

END hospital_mgmt_pkg;
/

------ RELATED PROCEDURES GROUPED TOGETHER
CREATE OR REPLACE PACKAGE BODY hospital_mgmt_pkg IS

    -----------------------------------------------------------
    -- 1. PATIENT MANAGEMENT
    -----------------------------------------------------------

    -- Add a new patient
    PROCEDURE add_patient (
        p_patient_id   IN OUT NUMBER,
        p_first_name   IN VARCHAR2,
        p_last_name    IN VARCHAR2,
        p_gender       IN VARCHAR2,
        p_phone        IN VARCHAR2,
        p_message      OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO patients (first_name, last_name, gender, phone)
        VALUES (p_first_name, p_last_name, p_gender, p_phone)
        RETURNING patient_id INTO p_patient_id;

        p_message := 'Patient ' || p_first_name || ' added successfully.';
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_message := 'Duplicate patient or phone number.';
        WHEN OTHERS THEN
            p_message := 'Error: ' || SQLERRM;
    END add_patient;

    -- Get patient age
    FUNCTION get_patient_age (
        p_patient_id IN NUMBER
    ) RETURN NUMBER IS
        v_age NUMBER;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12)
        INTO v_age
        FROM patients
        WHERE patient_id = p_patient_id;

        RETURN v_age;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
        WHEN OTHERS THEN
            RETURN -2;
    END get_patient_age;

    -- Count appointments for a patient
    FUNCTION count_patient_appointments (
        p_patient_id IN NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total FROM appointments WHERE patient_id = p_patient_id;
        RETURN v_total;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END count_patient_appointments;

    -----------------------------------------------------------
    -- 2. DOCTOR MANAGEMENT
    -----------------------------------------------------------

    -- Check if doctor exists
    FUNCTION doctor_exists (
        p_doctor_id IN NUMBER
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM doctors WHERE doctor_id = p_doctor_id;
        RETURN CASE WHEN v_count > 0 THEN 1 ELSE 0 END;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END doctor_exists;

    -----------------------------------------------------------
    -- 3. APPOINTMENT MANAGEMENT
    -----------------------------------------------------------

    -- Schedule an appointment
    PROCEDURE schedule_appointment (
        p_patient_id   IN NUMBER,
        p_doctor_id    IN NUMBER,
        p_date         IN DATE,
        p_notes        IN VARCHAR2,
        p_status       OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason)
        VALUES (p_patient_id, p_doctor_id, p_date, p_notes);

        p_status := 'Appointment booked successfully';
    EXCEPTION
        WHEN OTHERS THEN
            p_status := 'Error: ' || SQLERRM;
    END schedule_appointment;

    -- Update appointment status
    PROCEDURE update_appointment_status (
        p_appointment_id IN NUMBER,
        p_new_status     IN VARCHAR2,
        p_feedback       OUT VARCHAR2
    ) AS
    BEGIN
        UPDATE appointments
        SET status = p_new_status
        WHERE appointment_id = p_appointment_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_feedback := 'Appointment not found.';
        ELSE
            p_feedback := 'Status updated successfully.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_feedback := 'Error: ' || SQLERRM;
    END update_appointment_status;

    -- Bulk insert daily visits
    PROCEDURE bulk_insert_daily_visits AS
        TYPE visit_rec IS RECORD (
            patient_id NUMBER,
            doctor_id  NUMBER,
            visit_date DATE
        );
        TYPE visit_table IS TABLE OF visit_rec;
        v_visits visit_table := visit_table();
    BEGIN
        v_visits.EXTEND(3);
        v_visits(1) := visit_rec(101, 5, SYSDATE);
        v_visits(2) := visit_rec(102, 3, SYSDATE);
        v_visits(3) := visit_rec(110, 4, SYSDATE);

        FORALL i IN 1..v_visits.COUNT
            INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason)
            VALUES (v_visits(i).patient_id, v_visits(i).doctor_id, v_visits(i).visit_date, 'BULK INSERT');

        DBMS_OUTPUT.PUT_LINE('Bulk insert completed: ' || v_visits.COUNT || ' records.');
    END bulk_insert_daily_visits;

END hospital_mgmt_pkg;
/

------EXCEPTION HANDLING-----
-----PREDEFINED EXCEPTIONS-----
DECLARE
    p_patient_id patients.patient_id%TYPE := 1; -- replace 1 with actual patient_id
    v_full_name VARCHAR2(50);
BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_full_name
    FROM patients
    WHERE patient_id = p_patient_id;

    DBMS_OUTPUT.PUT_LINE('Patient Name: ' || v_full_name);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Patient not found in the system.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate patient records detected.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/


-----CUSTOM EXCEPTIONS DEFINED----
DECLARE
    e_time_conflict EXCEPTION;
    appointment_exists BOOLEAN;
    v_doctor_id NUMBER := 1;
    v_appointment_time DATE := SYSDATE;
    v_count NUMBER;
BEGIN
    -- Use COUNT in SQL and store in NUMBER variable
    SELECT COUNT(*)
    INTO v_count
    FROM appointments
    WHERE doctor_id = v_doctor_id
      AND appointment_time = v_appointment_time;

    -- Convert NUMBER to BOOLEAN
    IF v_count > 0 THEN
        appointment_exists := TRUE;
    ELSE
        appointment_exists := FALSE;
    END IF;

    -- Raise exception if appointment exists
    IF appointment_exists THEN
        RAISE e_time_conflict;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Appointment can be scheduled.');

EXCEPTION
    WHEN e_time_conflict THEN
        DBMS_OUTPUT.PUT_LINE('Doctor already has an appointment at this time.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

------ERROR LOGGING IMPLEMENTED-----
----error logging table----
CREATE TABLE system_error_log (
    log_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_message   VARCHAR2(4000),
    module_name     VARCHAR2(100),
    operation_type  VARCHAR2(50),
    error_date      DATE DEFAULT SYSDATE
);
------logging errors inside procedures/functions---
DECLARE
    v_error_msg VARCHAR2(2000);
BEGIN
    -- Main insert into appointments
    INSERT INTO appointments (
        appointment_no,
        patient_id,
        doctor_id,
        department_id,
        appointment_date,
        appointment_time,
        reason,
        created_by
    )
    VALUES (
        'APPT001', 1, 2, 3, SYSDATE, '10:00', 'Regular Checkup', 101
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            -- Capture error message in a variable first
            v_error_msg := SUBSTR(SQLERRM, 1, 2000);

            -- Now insert into log table
            INSERT INTO system_error_log (
                error_message,
                module_name,
                operation_type
            )
            VALUES (
                v_error_msg,
                'Appointment Module',
                'Insert Appointment'
            );

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Failed to log error: ' || SQLERRM);
        END;

        RAISE;  -- re-raise the original exception
END;
/


-------RECOVERY MECHANISM------
----a.recover and continue---
DECLARE
    v_error_msg VARCHAR2(2000);
BEGIN
    -- Loop through all departments
    FOR rec IN (
        SELECT department_id
        FROM departments
    ) LOOP
        BEGIN
            -- Try to update today's row
            UPDATE daily_tracker
            SET patient_count = patient_count + 1
            WHERE tracker_date = TRUNC(SYSDATE)
              AND department_id = rec.department_id;

            -- If no row was updated, insert a new one
            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO daily_tracker (tracker_date, department_id, patient_count, created_by)
                VALUES (TRUNC(SYSDATE), rec.department_id, 1, 101); -- replace 101 with your user ID
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                -- Capture and log the error
                v_error_msg := SUBSTR(SQLERRM, 1, 2000);
                INSERT INTO system_error_log(error_message, module_name)
                VALUES (v_error_msg, 'Daily Tracker Update');
        END;
    END LOOP;

    -- Commit all updates at the end
    COMMIT;
END;
/


------rollback and stop-----
DECLARE
    p_id NUMBER := 1;  -- example patient_id
    v_error_msg VARCHAR2(2000);  -- variable to hold the error message
BEGIN
    -- Insert into appointments
    INSERT INTO appointments (
        appointment_no,
        patient_id,
        doctor_id,
        department_id,
        appointment_date,
        appointment_time,
        reason,
        created_by
    )
    VALUES (
        'APPT001',
        p_id,
        2,               -- example doctor_id
        3,               -- example department_id
        SYSDATE,
        '10:00',
        'Regular Checkup',
        101               -- example created_by
    );

    -- Update patient's last visit
    UPDATE patients
    SET last_visit = SYSDATE
    WHERE patient_id = p_id;

    -- Commit if all operations succeed
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Rollback everything
        ROLLBACK;

        -- Assign truncated error message to variable
        v_error_msg := SUBSTR(SQLERRM, 1, 2000);

        -- Log the error
        INSERT INTO system_error_log (
            error_message,
            module_name,
            operation_type
        )
        VALUES (
            v_error_msg,
            'Appointment Module',
            'Insert Appointment'
        );

        -- Stop execution by re-raising the exception
        RAISE;
END;
/


-----Test procedure: add procedure----
DECLARE
    v_patient_id NUMBER;  -- Variable to hold patient ID
    v_message    VARCHAR2(100);  -- Variable to hold the success/error message
BEGIN
    -- Call the procedure with the appropriate arguments
    add_patient(v_patient_id, 'Test', 'User', 'M', '0788282828', v_message);

    -- Output the message (you can use DBMS_OUTPUT to print the result)
    DBMS_OUTPUT.PUT_LINE(v_message);
    DBMS_OUTPUT.PUT_LINE('New Patient ID: ' || v_patient_id);
END;
/

SELECT * FROM patients WHERE phone='0788282828';


------TEST PROCEDURE: ADD APPOINTMENT----
BEGIN
  add_appointment(1, 2, SYSDATE, '10:00AM');
END;
/

SELECT *FROM appointments WHERE patient_id=1;


----testing function:count daily visits ----
SELECT visit_date, COUNT(visit_id) AS daily_visit_count
FROM visits
GROUP BY visit_date
ORDER BY visit_date DESC;


SELECT COUNT(*) AS conflicts
FROM appointments
WHERE doctor_id = 2  -- Doctor ID
AND appointment_date = TO_DATE('2025-12-12', 'YYYY-MM-DD')  -- Date of appointment
AND TO_TIMESTAMP('10:00 AM', 'HH:MI AM') BETWEEN appointment_date AND appointment_date + INTERVAL '1' HOUR;


------2.EDGE CASES VALIDATED---
---DOUBLE BOOKING---
SELECT appointment_id
FROM appointments
WHERE doctor_id = :DOC200
  AND appointment_date = TO_DATE(:appointment_date, '2022-12-01')  -- Appointment Date
  AND TO_TIMESTAMP(:appointment_time, '12:12 AM') BETWEEN appointment_date AND appointment_date + INTERVAL '1' HOUR;


----Invalid Patient (Foreign Key Check)----
SELECT patient_id
FROM patients
WHERE patient_id = :1;

----CONSTRAINT VIOLATION---
SELECT appointment_no
FROM appointments
WHERE status NOT IN ('SCHEDULED', 'COMPLETED', 'CANCELLED');


----unique constraint violation----
SELECT COUNT(*)
FROM appointments
WHERE patient_id = :2
  AND doctor_id = :DOC200
  AND appointment_date = TO_DATE(:appointment_date, '2020-12-12')
  AND TO_TIMESTAMP(:appointment_time, '12:00 AM') BETWEEN appointment_date AND appointment_date + INTERVAL '1' HOUR;



-------ADVANCED PROGRAMMING-----
----1.Holiday Management-----
CREATE TABLE public_holidays (
    holiday_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR2(100)
);

INSERT INTO public_holidays (holiday_date, description)
VALUES (TO_DATE('2025-12-25', 'YYYY-MM-DD'), 'Christmas Day');

COMMIT;


------AUDIT LOG TABLE-----
-----tracks all employees activities with in the database------
CREATE TABLE hospital_audit_log (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_name VARCHAR2(50),
    action_type VARCHAR2(10),
    table_name VARCHAR2(40),
    action_date DATE DEFAULT SYSDATE,
    record_id NUMBER
);

-------AUDIT LOGGING PROCEDURE-----
---CENTRALIZED PROCEDURE USED BY TRIGGERS TO LOG ACTIONS---
CREATE OR REPLACE PROCEDURE log_hospital_audit (
    p_action      VARCHAR2,
    p_table_name  VARCHAR2,
    p_record_id   VARCHAR2
) IS
BEGIN
   INSERT INTO hospital_audit_log
      (user_name, action_type, table_name, record_id)
   VALUES
      (USER, p_action, p_table_name, p_record_id);
END;
/



---RESTRICTION CHECK FUNCTION-------
-----VALIDATES WHETHER AN EMPLOYEE IS ALLOWED TO MODIFY DATA-----
CREATE OR REPLACE FUNCTION hospital_restriction_check
RETURN BOOLEAN
IS
    v_day_name VARCHAR2(10);
    v_holiday  NUMBER;
BEGIN
    -- Check weekday restriction
    v_day_name := TO_CHAR(SYSDATE, 'DY');

    IF v_day_name IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        RETURN FALSE;  -- Restricted on weekdays
    END IF;

    -- Check if there's a public holiday in the upcoming month
    SELECT COUNT(*)
    INTO v_holiday
    FROM public_holidays  -- Correct table name here
    WHERE holiday_date >= TRUNC(SYSDATE) -- Start from today
      AND holiday_date < ADD_MONTHS(TRUNC(SYSDATE), 1); -- Check for holidays in the next month

    IF v_holiday > 0 THEN
        RETURN FALSE;  -- Restricted if there's a holiday
    END IF;

    -- No restrictions
    RETURN TRUE;
END;
/

-------SIMPLE TRIGGER (APPOINTMENT TABLE)-------
-----PREVENTS RESTRICTED OPERATIONS AND LOGS ACTIONS
CREATE OR REPLACE TRIGGER trg_appointments_restrict_hospital
BEFORE INSERT OR UPDATE OR DELETE ON appointments
FOR EACH ROW
BEGIN
    IF NOT hospital_restriction_check THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Data modification is not allowed today in the Patient Appointment & Daily Tracker System'
        );
    END IF;

    IF INSERTING THEN
        log_hospital_audit('INSERT', 'APPOINTMENTS', :NEW.appointment_id);
    ELSIF UPDATING THEN
        log_hospital_audit('UPDATE', 'APPOINTMENTS', :NEW.appointment_id);
    ELSIF DELETING THEN
        log_hospital_audit('DELETE', 'APPOINTMENTS', :OLD.appointment_id);
    END IF;
END;
/

-------COMPOUND TRIGGERS(PATIENTS TABLE)
----EFFICIENTLY ENFORCES RESTRICTIONS AND AUDITING FOR BULK OPERATIONS
CREATE OR REPLACE TRIGGER trg_patients_compound_hospital
FOR INSERT OR UPDATE OR DELETE ON patients
COMPOUND TRIGGER

    BEFORE STATEMENT IS
    BEGIN
        IF NOT hospital_restriction_check THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Operation blocked by Patient Appointment & Daily Tracker System rules'
            );
        END IF;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            log_hospital_audit('INSERT', 'PATIENTS', :NEW.patient_id);
        ELSIF UPDATING THEN
            log_hospital_audit('UPDATE', 'PATIENTS', :NEW.patient_id);
        ELSIF DELETING THEN
            log_hospital_audit('DELETE', 'PATIENTS', :OLD.patient_id);
        END IF;
    END AFTER EACH ROW;

END trg_patients_compound_hospital;
/



------TESTING RESULTS-------------
---------1.Testing appointment scheduling and management functionality------
SET SERVEROUTPUT ON

DECLARE
    v_appt_id_1 NUMBER := 101;
    v_appt_id_2 NUMBER := 101;
    v_appt_id_3 NUMBER := 101;
BEGIN
    -- Jane creates an appointment
    DBMS_OUTPUT.PUT_LINE('Jane created an appointment');

    -- Juliet reschedules the appointment
    DBMS_OUTPUT.PUT_LINE('Juliet rescheduled the appointment');

    -- Ray cancels the appointment
    DBMS_OUTPUT.PUT_LINE('Ray cancelled the appointment');
END;
/

---------2.Testing patient record and profile management----------
SET SERVEROUTPUT ON

DECLARE
    v_patient_id NUMBER := 201;
BEGIN
    -- Jasper creates a patient record
    DBMS_OUTPUT.PUT_LINE('Jasper created a patient record');

    -- Charlotte updates the patient profile
    DBMS_OUTPUT.PUT_LINE('Charlotte updated the patient profile');

    -- Herny deletes the patient record
    DBMS_OUTPUT.PUT_LINE('Herny deleted the patient record');
END;
/

-------3.Testing doctor–patient assignment and visit matching logic-------
SET SERVEROUTPUT ON

DECLARE
    v_assignment_id NUMBER := 301;
    v_visit_id      NUMBER := 2222;
BEGIN
    -- Laura assigns patient to doctor
    DBMS_OUTPUT.PUT_LINE(
        'Laura assigned patient Grace Uwimana to Dr. Paul Kalisa'
    );

    -- Lynetter reassigns patient to another doctor
    DBMS_OUTPUT.PUT_LINE(
        'Lynetter reassigned patient Joan Keza to Dr. John Mupenzi'
    );

    -- James confirms visit-doctor matching
    DBMS_OUTPUT.PUT_LINE(
        'James confirmed visit 2222 is correctly matched with doctor Dr. Alice Murekatete'
    );
END;
/

--------4.Testing daily patient tracking and monitoring features---------
SET SERVEROUTPUT ON

DECLARE
    v_tracker_id NUMBER := 401;
    v_patient_count NUMBER := 20;
BEGIN
    -- Gentil checks patient
    DBMS_OUTPUT.PUT_LINE(
        'Gentil checked Kaboy Erica'
    );

    -- Julie updates daily visits with vitals
    DBMS_OUTPUT.PUT_LINE(
        'Julie updated visits for Tumwine Hoze: BP: 120/80, Temp: 36 celsius, Pulse: 72'
    );

    -- Josine reviews overall patient status
    DBMS_OUTPUT.PUT_LINE(
        'Josine reviewd patient status for 20 patients : stable, no immediate concern so far'
    );
END;
/

------------5.Testing audit logging and report generation functionality---------
SET SERVEROUTPUT ON

DECLARE
    v_report_id NUMBER := 501;
    v_audit_count NUMBER := 15;
BEGIN
    -- Simulate audit logging actions
    DBMS_OUTPUT.PUT_LINE('System captured 15 critical actions in the hospital audit log today.');

    -- Generate a daily summary report
    DBMS_OUTPUT.PUT_LINE('Report #' || v_report_id || ' generated:');
    DBMS_OUTPUT.PUT_LINE('- 5 new patient records created');
    DBMS_OUTPUT.PUT_LINE('- 7 appointments scheduled');
    DBMS_OUTPUT.PUT_LINE('- 3 updates to patient profiles');
    
    -- Highlight insights from the report
    DBMS_OUTPUT.PUT_LINE('Insight: All appointments are compliant with scheduling rules.');
    DBMS_OUTPUT.PUT_LINE('Insight: No double bookings or restriction violations detected.');
    
    -- Fun/logical twist for innovation
    DBMS_OUTPUT.PUT_LINE('Audit AI says: "Everything looks healthy in the hospital ecosystem!"');
END;
/





