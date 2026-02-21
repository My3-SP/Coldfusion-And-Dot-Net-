CREATE DATABASE EmployeeBonusDB;
USE EmployeeBonusDB;
GO

CREATE TABLE employees (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE bonus (
    bonus_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,
    rating INT NOT NULL,
    bonus_percent DECIMAL(10,2),
    bonus_amount DECIMAL(10,2),
    final_salary DECIMAL(10,2),
    calculated_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_EmployeeBonus
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);




INSERT INTO employees (name, department, salary) VALUES
('John Doe', 'Sales', 25000),
('Priya Sharma', 'Marketing', 32000),
('Arjun Rao', 'Finance', 45000),
('Meera Nair', 'Human Resources', 28000),
('Rohan Verma', 'Sales', 38000),
('Ananya Iyer', 'IT', 52000),
('Karthik Reddy', 'Finance', 30000),
('Sneha Kapoor', 'Administration', 27000);

INSERT INTO bonus (employee_id, rating, bonus_percent, bonus_amount, final_salary) VALUES
(1, 5, 20, 5000, 30000),
(2, 4, 15, 4800, 36800),
(3, 3, 10, 4500, 49500),
(4, 2, 5, 1400, 29400),
(5, 1, 0, 0, 38000),
(6, 5, 20, 10400, 62400),
(7, 4, 15, 4500, 34500),
(8, 3, 10, 2700, 29700);


SELECT * FROM employees;
SELECT * FROM bonus;