# DATA STRUCTURE
This is a Patient Appointment and Daily Tracker system that manages hospital or clinic operations efficiently. It allows staff to schedule and track patient appointments, 
maintain daily activity logs, manage doctor and patient records, and monitor healthcare workflows.
The system helps optimize hospital operations, ensures accurate record-keeping, and improves patient care by keeping all essential information organized and easily accessible.

# PLUGGABLE DATABASE CREATED
![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/main/Picture1.png?raw=true)

PATIENTS

Stores patient profiles including identification details, contact information, address/location, age, gender, medical reference information, and other relevant details needed for registration, appointment scheduling, and healthcare record management.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/c829d3ef8be687a36c6ef48edffb9062330ab6c3/PATIENTS%20TABLE.png)

APPOINTMENTS

Maintains a record of patient appointments, including appointment dates and times, assigned doctors, appointment status, and related notes. This supports efficient scheduling, reduces conflicts, and ensures timely patient care.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/d693dedfeeb97fd3021c32afe233a2e231dba3f2/APPOINTMENTS%20TABLE.png)

DAILY_TRACKER

Tracks daily patient-related activities and records, including visit summaries, treatments administered, vital signs, follow-up notes, and staff observations. This helps monitor patient progress on a day-to-day basis and supports accurate clinical documentation.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/21cb283e8284007a8049a206a5edae7e4cef544e/DAILY_TRACKER%20TABLE.png)

DOCTORS

Stores doctor profiles and professional details, including identification, specialization, contact information, availability schedules, and assigned departments. This supports proper doctor–patient assignment and efficient management of medical staff.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/a0e09cda6236ac2cdbd29be1cb2d0bc944181f71/DOCTORS%20TABLE.png)

HOSPITAL_AUDIT_LOG

Monitors and records system activities and changes across different tables, including user actions such as inserts, updates, and deletions. It stores details like the user performing the action, the affected table, the type of action, the time it occurred, and the related record ID. This supports accountability, auditing, and data integrity within the system.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/2a10d833880f701d6004605da4a708968427d8ea/HOSPITAL_AUDIT_LOG%20TABLE.png)

USERS/STAFFS.

Contains system user information, including user roles (admin, receptionist, doctor, nurse), login credentials, contact details, and access privileges. This supports secure system access, role-based permissions, and accountability for actions performed within the application.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/0a772f7f94822831c0a0da68197b8b707f3a9db0/USER-STAFF%20TABLE.png)

VISITS

Records each patient visit to the healthcare facility, linking patients to doctors and appointments. It tracks visit dates, reasons for the visit, diagnoses, treatments provided, visit outcomes, and any follow-up notes. This table helps maintain a complete history of patient interactions and supports continuity of care.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/1dd8dfdc75447ea3e0dca3cea9093c6ce59dd797/VISITS%20TABLE.png)

# ER DIAGRAM

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/a5c81679f9f57d567374c768f34e4bdf84caf53c/ER%20DIAGRAM.png)

# TEST RESULTS.

Testing appointment scheduling and management functionality

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/362ed43d022b7597d5b49441e81d00423b959fcd/test%20result%201.png)

Testing patient record and profile management

![img alt](the link)

Testing doctor–patient assignment and visit matching logic

![img alt](the link)

Testing daily patient tracking and monitoring features

![img alt](the link)

Testing audit logging and report generation functionality

![img alt](the link)








