--create a company database:
CREATE DATABASE CompanyDB;
USE CompanyDB;
GO

--create tables: Department, Employees, Project 
CREATE TABLE Departments
(
    DeptID INT IDENTITY(1,1) PRIMARY KEY ,
    DeptName VARCHAR(50) NOT NULL,
    Location VARCHAR(50) NOT NULL,
    ManagerName VARCHAR(50) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Employees
(
    EmpID INT IDENTITY(1,1) PRIMARY KEY ,
    EmpName VARCHAR(50) NOT NULL,
    Email VARCHAR(60) UNIQUE,
    Salary DECIMAL(10,2) DEFAULT 0.00,
    JoinDate DATETIME DEFAULT GETDATE(),
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

CREATE TABLE Projects
(
    ProjectID INT IDENTITY(1,1) PRIMARY KEY ,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATETIME DEFAULT GETDATE(),
    EndDate DATETIME,
    Budget DECIMAL(12,2) DEFAULT 0.00,
    EmpID INT,
    FOREIGN KEY (EmpID) REFERENCES Employees(EmpID)
);

--Insert records into each table.
INSERT INTO Departments (DeptName, Location, ManagerName, CreatedDate)
VALUES
('IT', 'Bangalore', 'Ramesh Kumar', '2023-01-01 10:00:00'),
('HR', 'Mumbai', 'Sneha Patil', '2023-01-02 11:00:00'),
('Finance', 'Delhi', 'Ankit Verma', '2023-01-03 09:30:00'),
('Marketing', 'Hyderabad', 'Pooja Sharma', '2023-01-04 10:45:00');

INSERT INTO Employees (EmpName, Email, Salary, JoinDate, DeptID)
VALUES
('Amit Sharma', 'amit@gmail.com', 50000.00, '2023-01-10 09:00:00', 1),
('Riya Patel', 'riya@gmail.com', 45000.00, '2023-02-15 09:30:00', 2),
('John Mathew', 'john@gmail.com', 60000.00, '2022-12-05 10:00:00', 1),
('Neha Singh', 'neha@gmail.com', 42000.00, '2023-03-20 11:00:00', 4),
('Karan Verma', 'karan@gmail.com', 55000.00, '2023-01-25 09:45:00', 3),
('Priya Nair', 'priya@gmail.com', 48000.00, '2023-04-05 10:15:00', 2),
('Arjun Rao', 'arjun@gmail.com', 53000.00, '2022-11-18 09:20:00', 1),
('Snehal Joshi', 'snehal@gmail.com', 46000.00, '2023-02-28 10:40:00', 4),
('Rohit Gupta', 'rohit@gmail.com', 65000.00, '2022-10-10 09:10:00', 3),
('Divya Iyer', 'divya@gmail.com', 44000.00, '2023-03-12 11:30:00', 2);

INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget, EmpID)
VALUES
('Employee Management System', '2023-01-15 10:00:00', '2023-06-15 18:00:00', 300000.00, 1),
('HR Recruitment Portal', '2023-02-20 09:30:00', '2023-07-20 17:30:00', 250000.00, 2),
('Finance Analytics Dashboard', '2023-01-05 09:00:00', '2023-05-30 18:00:00', 280000.00, 5),
('Digital Marketing Tool', '2023-03-01 10:15:00', '2023-08-01 17:45:00', 220000.00, 4),
('IT Support Automation', '2023-04-01 09:45:00', '2023-09-01 18:30:00', 270000.00, 3);

--Display tables:
SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Projects;

--Update a specific record based on a condition (e.g., increase salary for employees in IT).
--Increase Salary for IT Department Employees
UPDATE Employees
SET Salary = Salary + 5000
WHERE DeptID = 1;

--Change Manager Name for Marketing Department:
UPDATE Departments
SET ManagerName = 'Rahul Mehta'
WHERE DeptName = 'Marketing';

--Increase Project Budget for Long Duration Project
UPDATE Projects
SET Budget = Budget + 50000
WHERE DATEDIFF(MONTH, StartDate, EndDate) > 4;

--Delete a record based on a specific condition.
--Delete projects with low budget (less than 2,30,000).
SELECT * FROM Projects
WHERE Budget < 230000;

DELETE FROM Projects
WHERE Budget < 230000;

--Implement a transaction (COMMIT, ROLLBACK) for safe modifications.
--Increase salary of Finance department employees but rollback if mistake happens.

BEGIN TRANSACTION;
BEGIN TRY
    UPDATE Employees
    SET Salary = Salary + 10000
    WHERE DeptID = 3;
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH

-- Check the result
SELECT EmpName, Salary 
FROM Employees 
WHERE DeptID = 3;


--Transaction without ROLLBACK.
BEGIN TRANSACTION;

UPDATE Employees
SET Salary = Salary + 8000
WHERE DeptID = 2;

COMMIT;

--Create a stored procedure.
--Increase salary of employees department-wise - parameterized stored procedure:
CREATE PROCEDURE IncreaseSalaryByDepartment
    @DeptID INT,
    @IncrementAmount DECIMAL(10,2)
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + @IncrementAmount
    WHERE DeptID = @DeptID;
END;


EXEC IncreaseSalaryByDepartment 1, 4000;

SELECT EmpName, Salary 
FROM Employees
WHERE DeptID = 1;

--Create a view.
--Display employee details with department and project information in one virtual table. 
CREATE VIEW EmployeeProjectDetails
AS
SELECT
    e.EmpID,e.EmpName,d.DeptName,e.Salary,p.ProjectName,p.Budget
FROM Employees e
JOIN Departments d ON e.DeptID = d.DeptID
LEFT JOIN Projects p ON e.EmpID = p.EmpID;

SELECT * FROM EmployeeProjectDetails;

--Triggers
--create auditing table:
CREATE TABLE AuditLog
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ActionType VARCHAR(50),
    EmpID INT,
    EmpName VARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);

--Create an AFTER INSERT trigger to log new employee entries into an AuditLog table.
CREATE TRIGGER trg_AfterEmployeeInsert 
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (ActionType, EmpID, EmpName)
    SELECT 'INSERT',EmpID,EmpName
    FROM inserted;
END;

INSERT INTO Employees (EmpName, Email, Salary, JoinDate, DeptID)
VALUES ('Manoj Kumar', 'manoj@gmail.com', 47000, '2023-05-10 10:00:00', 1);

SELECT * FROM AuditLog;
SELECT * FROM Employees;


--Implement an INSTEAD OF DELETE trigger to prevent accidental deletion of records.
CREATE TRIGGER trg_BlockEmployeeDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Delete operation is not allowed on Employees table!';
END;

DELETE FROM Employees WHERE EmpID = 1;

SELECT * FROM Employees WHERE EmpID = 1;


--Cursors
--Write a cursor that loops through employee salaries and applies a bonus based on a certain condition - salary < 50000
DECLARE @EmpID INT;
DECLARE @Salary DECIMAL(10,2);

DECLARE SalaryCursor CURSOR FOR
SELECT EmpID, Salary 
FROM Employees;

OPEN SalaryCursor;

FETCH NEXT FROM SalaryCursor INTO @EmpID, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Salary < 50000
    BEGIN
        UPDATE Employees
        SET Salary = Salary + 3000
        WHERE EmpID = @EmpID;
    END;

    FETCH NEXT FROM SalaryCursor INTO @EmpID, @Salary;
END;

CLOSE SalaryCursor;
DEALLOCATE SalaryCursor;


SELECT EmpID, EmpName, Salary
FROM Employees
WHERE Salary < 50000;

--Optimize performance by using set-based queries instead of cursors.
UPDATE Employees
SET Salary = Salary + 3000
WHERE Salary < 50000;
    
UPDATE E
SET E.Salary += 15000
FROM Employees E
JOIN Projects P
ON E.EmpID = P.EmpID
WHERE P.ProjectName = 'Employee Management System';