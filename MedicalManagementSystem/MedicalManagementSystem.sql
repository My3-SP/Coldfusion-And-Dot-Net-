CREATE DATABASE MedicalManagementSystem;
GO

USE MedicalManagementSystem;
GO

--ROLES
CREATE TABLE ROLES (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO ROLES (role_name)
VALUES ('Admin'), ('Doctor'), ('Receptionist'), ('Patient');

-- USERS
CREATE TABLE USERS (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL,
    password NVARCHAR(200) NOT NULL,
    role_id INT NOT NULL,
    full_name NVARCHAR(150) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    created_by INT NULL,
    updated_at DATETIME2 NULL,
    updated_by INT NULL,

    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id),
    FOREIGN KEY (updated_by) REFERENCES USERS(user_id)
);

-- DEPARTMENTS
CREATE TABLE DEPARTMENTS (
    dept_id INT IDENTITY(1,1) PRIMARY KEY,
    dept_name NVARCHAR(100) UNIQUE NOT NULL,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- DOCTORS
CREATE TABLE DOCTORS (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    dept_id INT NOT NULL,
    specialization NVARCHAR(100),
    qualification NVARCHAR(150),
    experience_years INT,
    consultation_fee DECIMAL(10,2),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),

    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (dept_id) REFERENCES DEPARTMENTS(dept_id)
);

-- PATIENTS
CREATE TABLE PATIENTS (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    date_of_birth DATE,
    gender NVARCHAR(20),
    blood_group NVARCHAR(5),
    address_line1 NVARCHAR(200),
    address_line2 NVARCHAR(200),
    city NVARCHAR(100),
    state NVARCHAR(100),
    postal_code NVARCHAR(20),
    country NVARCHAR(100),
    emergency_contact_name NVARCHAR(100),
    emergency_contact_phone NVARCHAR(20),
    registration_date DATETIME2 DEFAULT GETDATE(),
    is_active BIT DEFAULT 1,

    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- APPOINTMENT STATUS
CREATE TABLE APPOINTMENT_STATUS (
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    status_name NVARCHAR(30) NOT NULL
);

INSERT INTO APPOINTMENT_STATUS (status_name)
VALUES ('Booked'), ('Cancelled'), ('Completed'), ('In Progress');

-- APPOINTMENTS
CREATE TABLE APPOINTMENTS (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME2 NOT NULL,
    status_id INT NOT NULL,
    remarks NVARCHAR(500),
    created_at DATETIME2 DEFAULT GETDATE(),
    created_by INT NULL,
    updated_at DATETIME2 NULL,
    updated_by INT NULL,

    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id),
    FOREIGN KEY (status_id) REFERENCES APPOINTMENT_STATUS(status_id),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id),
    FOREIGN KEY (updated_by) REFERENCES USERS(user_id)
);

-- PRESCRIPTIONS
CREATE TABLE PRESCRIPTIONS (
    prescription_id INT IDENTITY(1,1) PRIMARY KEY,
    appointment_id INT NOT NULL,
    doctor_id INT,
    diagnosis NVARCHAR(MAX),
    notes NVARCHAR(MAX),
    prescription_date DATE DEFAULT GETDATE(),
    digital_signature VARBINARY(MAX),
    signature_ref NVARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE(),

    FOREIGN KEY (appointment_id) REFERENCES APPOINTMENTS(appointment_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id)
);

-- DRUGS
CREATE TABLE DRUGS (
    drug_id INT IDENTITY(1,1) PRIMARY KEY,
    drug_name NVARCHAR(200) NOT NULL,
    form NVARCHAR(50),
    strength NVARCHAR(50),
    is_active BIT DEFAULT 1
);

-- PRESCRIPTION ITEMS
CREATE TABLE PRESCRIPTION_ITEMS (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    prescription_id INT NOT NULL,
    drug_id INT NOT NULL,
    dosage NVARCHAR(100),
    frequency NVARCHAR(100),
    duration NVARCHAR(50),
    instructions NVARCHAR(255),

    FOREIGN KEY (prescription_id) REFERENCES PRESCRIPTIONS(prescription_id),
    FOREIGN KEY (drug_id) REFERENCES DRUGS(drug_id)
);

-- BILLING
CREATE TABLE BILLS (
    bill_id INT IDENTITY(1,1) PRIMARY KEY,
    appointment_id INT NOT NULL,
    status_id INT NOT NULL,
    invoice_no NVARCHAR(50) UNIQUE,
    total_amount DECIMAL(12,2),
    bill_date DATE DEFAULT GETDATE(),
    created_at DATETIME2 DEFAULT GETDATE(),
    created_by INT NULL,
    updated_at DATETIME2 NULL,
    updated_by INT NULL,

    FOREIGN KEY (appointment_id) REFERENCES APPOINTMENTS(appointment_id),
    FOREIGN KEY (status_id) REFERENCES APPOINTMENT_STATUS(status_id)
);


CREATE TABLE BILL_ITEMS (
    bill_item_id INT IDENTITY(1,1) PRIMARY KEY,
    bill_id INT NOT NULL,
    item_type NVARCHAR(50),
    item_description NVARCHAR(255),
    quantity DECIMAL(10,2),
    unit_price DECIMAL(12,2),
    tax_amount DECIMAL(12,2),
    total_amount DECIMAL(12,2),

    FOREIGN KEY (bill_id) REFERENCES BILLS(bill_id)
);

-- OTP VERIFICATION
CREATE TABLE OTP_VERIFICATION (
    otp_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    otp_hash VARBINARY(200),
    purpose NVARCHAR(50),
    expiry_time DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    consumed_at DATETIME2 NULL,
    is_consumed BIT DEFAULT 0,
    request_ip NVARCHAR(45),
    attempt_count INT DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- PERMISSIONS
CREATE TABLE PERMISSIONS (
    permission_id INT IDENTITY(1,1) PRIMARY KEY,
    permission_name NVARCHAR(100) UNIQUE NOT NULL,
    description NVARCHAR(255)
);

CREATE TABLE ROLE_PERMISSIONS (
    role_id INT,
    permission_id INT,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    FOREIGN KEY (permission_id) REFERENCES PERMISSIONS(permission_id)
);

INSERT INTO PERMISSIONS (permission_name, description) VALUES
('DELETE_PATIENT','Delete patient'),
('MANAGE_USERS','Create and manage system users'),
('ASSIGN_ROLES','Assign roles to users'),
('VIEW_DEPARTMENTS','View department list'),
('ADD_DEPARTMENT','Add new department'),
('EDIT_DEPARTMENT','Edit department'),
('DELETE_DEPARTMENT','Delete department'),
('VIEW_DOCTORS','View doctor details'),
('ADD_DOCTOR','Add doctor'),
('EDIT_DOCTOR','Edit doctor'),
('DELETE_DOCTOR','Delete doctor'),
('VIEW_REPORTS','View system reports'),
('MANAGE_SYSTEM_SETTINGS','Update system settings'),

('VIEW_MY_APPOINTMENTS','Doctor views own appointments'),
('UPDATE_APPOINTMENT_STATUS','Doctor updates appointment status'),
('VIEW_PATIENT_DETAILS','Doctor views patient info'),
('VIEW_PATIENT_HISTORY','Doctor views medical history'),
('CREATE_PRESCRIPTION','Doctor creates prescription'),
('EDIT_PRESCRIPTION','Doctor edits prescription'),
('VIEW_PRESCRIPTION','Doctor views prescriptions'),

('VIEW_PATIENTS','Receptionist views patients'),
('ADD_PATIENT','Receptionist registers patient'),
('EDIT_PATIENT','Receptionist edits patient'),
('CREATE_APPOINTMENT','Receptionist books appointment'),
('RESCHEDULE_APPOINTMENT','Reschedule appointment'),
('CANCEL_APPOINTMENT','Cancel appointment'),
('VIEW_APPOINTMENTS','View all appointments'),
('GENERATE_BILL','Create bill'),
('VIEW_BILLS','View billing info'),

('VIEW_OWN_APPOINTMENTS','Patient views own appointments'),
('VIEW_OWN_PRESCRIPTIONS','Patient views own prescriptions'),
('VIEW_OWN_BILLS','Patient views own bills'),
('UPDATE_PROFILE','Patient updates profile');

INSERT INTO ROLE_PERMISSIONS
SELECT 1, permission_id FROM PERMISSIONS;

INSERT INTO ROLE_PERMISSIONS (role_id, permission_id)
SELECT 2, permission_id FROM PERMISSIONS
WHERE permission_name IN (
'VIEW_MY_APPOINTMENTS',
'UPDATE_APPOINTMENT_STATUS',
'VIEW_PATIENT_DETAILS',
'VIEW_PATIENT_HISTORY',
'CREATE_PRESCRIPTION',
'EDIT_PRESCRIPTION',
'VIEW_PRESCRIPTION',
'VIEW_PATIENT_BILLS',
'DELETE_APPOINTMENT',
'CANCEL_APPOINTMENT'
);

INSERT INTO ROLE_PERMISSIONS (role_id, permission_id)
SELECT 3, permission_id FROM PERMISSIONS
WHERE permission_name IN (
'VIEW_PATIENTS',
'ADD_PATIENT',
'EDIT_PATIENT',
'CREATE_APPOINTMENT',
'RESCHEDULE_APPOINTMENT',
'CANCEL_APPOINTMENT',
'VIEW_APPOINTMENTS'
);

INSERT INTO ROLE_PERMISSIONS (role_id, permission_id)
SELECT 3, permission_id FROM PERMISSIONS
WHERE permission_name IN (
'VIEW_OWN_APPOINTMENTS',
'VIEW_OWN_PRESCRIPTIONS',
'VIEW_OWN_BILLS',
'UPDATE_PROFILE'
);

-- USERS
INSERT INTO USERS (username, password, role_id, full_name, email, phone)
VALUES 
('admin', '$2a$12$hashedpassword',
 (SELECT role_id FROM ROLES WHERE role_name = 'Admin'),
 'System Administrator', 'admin@mms.com', '9999999999'),

('doctor1', '$2a$12$hashedpassword',
 (SELECT role_id FROM ROLES WHERE role_name = 'Doctor'),
 'Dr. Rajesh Kumar', 'doctor1@mms.com', '7777777777'),

('reception1', '$2a$12$hashedpassword',
 (SELECT role_id FROM ROLES WHERE role_name = 'Receptionist'),
 'Front Desk Executive', 'reception1@mms.com', '8888888888'),

('patient1', '$2a$12$hashedpassword',
 (SELECT role_id FROM ROLES WHERE role_name = 'Patient'),
 'Anita Sharma', 'patient1@mms.com', '6666666666');

-- DEPARTMENTS
INSERT INTO DEPARTMENTS (dept_name, description) VALUES
('Cardiology', 'Heart related treatments'),
('Neurology', 'Brain and nervous system'),
('Orthopedics', 'Bone and joints');

-- DOCTORS
INSERT INTO DOCTORS (user_id, dept_id, specialization, qualification, experience_years, consultation_fee)
VALUES (
(SELECT user_id FROM USERS WHERE username = 'doctor1'),
(SELECT dept_id FROM DEPARTMENTS WHERE dept_name = 'Cardiology'),
'Cardiologist',
'MBBS, MD',
10,
800
);

-- PATIENTS
INSERT INTO PATIENTS (
user_id, date_of_birth, gender, blood_group,
address_line1, city, state, postal_code, country,
emergency_contact_name, emergency_contact_phone
)
VALUES (
(SELECT user_id FROM USERS WHERE username = 'patient1'),
'1998-05-10',
'Female',
'O+',
'123 Main Road',
'Bangalore',
'Karnataka',
'560065',
'India',
'Ramesh Sharma',
'9998887777'
);


-- APPOINTMENTS
INSERT INTO APPOINTMENTS (
patient_id, doctor_id, appointment_datetime, status_id, remarks, created_by
)
VALUES (
(SELECT patient_id FROM PATIENTS WHERE user_id = (SELECT user_id FROM USERS WHERE username='patient1')),
(SELECT doctor_id FROM DOCTORS WHERE user_id = (SELECT user_id FROM USERS WHERE username='doctor1')),
DATEADD(DAY, 1, GETDATE()),
(SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Booked'),
'Regular Checkup',
(SELECT user_id FROM USERS WHERE username='admin')
);

-- DRUGS
INSERT INTO DRUGS (drug_name, form, strength) VALUES
('Paracetamol', 'Tablet', '500mg'),
('Aspirin', 'Tablet', '75mg');

-- PRESCRIPTIONS
INSERT INTO PRESCRIPTIONS (appointment_id, doctor_id, diagnosis, notes)
VALUES (
(SELECT TOP 1 appointment_id FROM APPOINTMENTS ORDER BY appointment_id DESC),
(SELECT doctor_id FROM DOCTORS WHERE user_id = (SELECT user_id FROM USERS WHERE username='doctor1')),
'Mild chest pain',
'Take medicines regularly'
);

-- PRESCRIPTION ITEMS
INSERT INTO PRESCRIPTION_ITEMS (
prescription_id, drug_id, dosage, frequency, duration, instructions
)
VALUES
((SELECT TOP 1 prescription_id FROM PRESCRIPTIONS ORDER BY prescription_id DESC),
 (SELECT drug_id FROM DRUGS WHERE drug_name='Paracetamol'),
 '1 Tablet', 'Twice Daily', '5 Days', 'After Food'),

((SELECT TOP 1 prescription_id FROM PRESCRIPTIONS ORDER BY prescription_id DESC),
 (SELECT drug_id FROM DRUGS WHERE drug_name='Aspirin'),
 '1 Tablet', 'Once Daily', '7 Days', 'Morning');

-- BILLS
INSERT INTO BILLS (
appointment_id, status_id, invoice_no, total_amount, created_by
)
VALUES (
(SELECT TOP 1 appointment_id FROM APPOINTMENTS ORDER BY appointment_id DESC),
(SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Completed'),
'INV-1001',
800,
(SELECT user_id FROM USERS WHERE username='admin')
);

-- BILL ITEMS
INSERT INTO BILL_ITEMS (
bill_id, item_type, item_description, quantity, unit_price, tax_amount, total_amount
)
VALUES (
(SELECT TOP 1 bill_id FROM BILLS ORDER BY bill_id DESC),
'Consultation',
'Doctor Consultation Fee',
1,
800,
0,
800
);


