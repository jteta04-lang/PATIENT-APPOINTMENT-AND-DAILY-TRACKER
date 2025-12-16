---- TABLE CREATION----
  ---1.departments--------
CREATE TABLE DEPARTMENTS (
department_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
dept_code VARCHAR2(10) NOT NULL UNIQUE,
dept_name VARCHAR2(100) NOT NULL,
active    CHAR(1) DEFAULT 'Y' CHECK (active IN ('Y','N'))
);

  ---2.users/staff------
CREATE TABLE users_staff (
    staff_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'CLERK' CHECK (role IN ('ADMIN','DOCTOR','NURSE','CLERK','RECEPTION')),
    email VARCHAR(100),
    created_on DATE DEFAULT SYSDATE NOT NULL
);

  ---3.Patients-------
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


 ---4.Doctors-----------
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


  ---5.Appointments-----------
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

 ---6.Visits(daily log)------------
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

 ----7.Dailytracker------------
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

 
  ---8.Indexes---------------------
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


 ---1.Insert sample departments (manual, realistic)------------
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
 
 
  ---2.Insert realistic staff/users-----------------
INSERT INTO users_staff (username, full_name, role, email) 
VALUES ('admin01', 'System Administration', 'ADMIN', 'admin@gmail.com');

INSERT INTO users_staff (username, full_name, role, email) 
VALUES ('nurse_jane', 'Jane Uwase', 'NURSE', 'jane@gmail.com');

 INSERT INTO users_staff (username, full_name, role, email)
 VALUES ('doc_paul', 'Dr.Paul Kalisa', 'DOCTOR', 'paul@gmail.com');
---4.insert doctors(manual + consistent)
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC100', 'Dr.Paul Kalisa', 1, '0788232345', 'paul@gmail.com');
 
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC200', 'Dr.Alice Murekatete', 2, '0788687898', 'alice@gmail.com');
 
 INSERT INTO doctors (doctor_code, full_name, department_id, phone, email)
 VALUES ('DOC300', 'Dr.Jean Claude', 5, '0788212223', 'claude@gmail.com');

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



