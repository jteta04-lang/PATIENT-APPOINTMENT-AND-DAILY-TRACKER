# DATA STRUCTURE
This is a Patient Appointment and Daily Tracker system that manages hospital or clinic operations efficiently. It allows staff to schedule and track patient appointments, 
maintain daily activity logs, manage doctor and patient records, and monitor healthcare workflows.
The system helps optimize hospital operations, ensures accurate record-keeping, and improves patient care by keeping all essential information organized and easily accessible.

# PLUGGABLE DATABASE CREATED
![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/9f068b7a4a90f114490c5352fb26edc226595208/My%20screenshots/PDB%20CREATION.png)

PATIENTS

Stores patient profiles including identification details, contact information, address/location, age, gender, medical reference information, and other relevant details needed for registration, appointment scheduling, and healthcare record management.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/aea646cf635e2fe7fc885da86ef8fcdd94e1acc1/My%20screenshots/PATIENTS%20TABLE.png)

APPOINTMENTS

Maintains a record of patient appointments, including appointment dates and times, assigned doctors, appointment status, and related notes. This supports efficient scheduling, reduces conflicts, and ensures timely patient care.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/7cb420476a85d6781bd23bf4ed67bd24460bf005/My%20screenshots/APPOINTMENTS%20TABLE.png)

DAILY_TRACKER

Tracks daily patient-related activities and records, including visit summaries, treatments administered, vital signs, follow-up notes, and staff observations. This helps monitor patient progress on a day-to-day basis and supports accurate clinical documentation.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/f8ad46e5c97d2c498fb6b1033c4ce7c52de17c84/My%20screenshots/DAILY_TRACKER%20TABLE.png)

DOCTORS

Stores doctor profiles and professional details, including identification, specialization, contact information, availability schedules, and assigned departments. This supports proper doctor–patient assignment and efficient management of medical staff.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/f4cd26f0a68bbf0c1defd093c1b6946e674e3766/My%20screenshots/DOCTORS%20TABLE.png)

HOSPITAL_AUDIT_LOG

Monitors and records system activities and changes across different tables, including user actions such as inserts, updates, and deletions. It stores details like the user performing the action, the affected table, the type of action, the time it occurred, and the related record ID. This supports accountability, auditing, and data integrity within the system.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/542f4170020913a4cb2a2239a5e0918d7477dae1/My%20screenshots/HOSPITAL_AUDIT_LOG%20TABLE.png)

USERS/STAFFS.

Contains system user information, including user roles (admin, receptionist, doctor, nurse), login credentials, contact details, and access privileges. This supports secure system access, role-based permissions, and accountability for actions performed within the application.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/d5351b71c1e4d632695167dbd3db05a18dc3fdd8/My%20screenshots/USER-STAFF%20TABLE.png)

VISITS

Records each patient visit to the healthcare facility, linking patients to doctors and appointments. It tracks visit dates, reasons for the visit, diagnoses, treatments provided, visit outcomes, and any follow-up notes. This table helps maintain a complete history of patient interactions and supports continuity of care.

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/56364d5a30dd816ae6bbde9e87acb65ef5cf9773/My%20screenshots/VISITS%20TABLE.png)

# ER DIAGRAM

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/8b21414f8326167669e5e503ad349ff702344652/My%20screenshots/ER%20DIAGRAM.png)

# TEST RESULTS.

Testing appointment scheduling and management functionality

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/9032911a5730e58e949f1e8bd0e5b3aad8191a13/My%20screenshots/test%20result%201.png)

Testing patient record and profile management

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/6ad98a7a11f7a149353ffb5cf94ff854bee3cbc3/My%20screenshots/test%20result%202.png)

Testing doctor–patient assignment and visit matching logic

![img alt](https://github.com/jteta04-lang/PATIENT-APPOINTMENT-AND-DAILY-TRACKER/blob/7f542aa5c65f1cc6e01efcf1b1b5e2b87942a95c/My%20screenshots/test%20result%203.png)

Testing daily patient tracking and monitoring features

![img alt]()

Testing audit logging and report generation functionality

![img alt]()








