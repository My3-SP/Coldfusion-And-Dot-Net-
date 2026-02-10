CREATE DATABASE OrderDB;
USE OrderDB
GO

CREATE TABLE Customer(
CustomerID INT IDENTITY PRIMARY KEY,
CustomerName Varchar(50) NOT NULL,
Email VARCHAR(50) NOT NULL UNIQUE,
PhoneNo VARCHAR(15) NOT NULL);



CREATE TABLE Product(
ProductID INT IDENTITY PRIMARY KEY,
ProductName VARCHAR(50) NOT NULL,
Price DECIMAL(10,2) NOT NULL);

INSERT INTO Customer (CustomerName, Email, PhoneNo)
VALUES
('Sneha R', 'snehar@gmail.com', '9871111111'),
('James H', 'james@gmail.com', '9872222222'),
('Sneha K', 'snehak@gmail.com', '9873333333'),
('Arav M', 'aravm@gmail.com', '9881111111'),
('Arav R', 'aravr@gmail.com', '9882222222'),
('Karthik R', 'karthikr@gmail.com', '9891111111'),
('Charlie S', 'charlie@gmail.com', '9892222222'),
('Meera P', 'meerap@gmail.com', '9901111111'),
('Ava N', 'Ava@gmail.com', '9902222222');


INSERT INTO Product (ProductName, Price)
VALUES
('Laptop (Dell)', 55000.00),
('Laptop (HP)', 58000.00),
('Laptop (Lenovo)', 52000.00),
('Headphones (Boat)', 2500.00),
('Headphones (Sony)', 7500.00),
('Headphones (JBL)', 4500.00),
('Keyboard (Logitech)', 3000.00),
('Keyboard (HP)', 2200.00),
('Mouse (Dell)', 1200.00),
('Mouse (Logitech)', 1800.00);

SELECT * FROM Customer;
SELECT * FROM Product;

--STORED PROCEDURES FOR <cfstoredproc> - Customer Table
-- insert operation
CREATE PROCEDURE sp_InsertCustomer
(
    @CustomerName VARCHAR(100),
    @Email        VARCHAR(100),
    @PhoneNo      VARCHAR(15)
)
AS
BEGIN
    INSERT INTO Customer (CustomerName, Email, PhoneNo)
    VALUES (@CustomerName, @Email, @PhoneNo);
END;

-- Update(edit) operation
CREATE PROCEDURE sp_UpdateCustomer
(
    @CustomerID   INT,
    @CustomerName VARCHAR(100),
    @Email        VARCHAR(100),
    @PhoneNo      VARCHAR(15)
)
AS
BEGIN
    UPDATE Customer
    SET
        CustomerName = @CustomerName,
        Email        = @Email,
        PhoneNo      = @PhoneNo
    WHERE
        CustomerID = @CustomerID;
END;

--load data for editing
CREATE PROCEDURE sp_GetCustomerById
(
    @CustomerID INT
)
AS
BEGIN
    SELECT CustomerID, CustomerName, Email, PhoneNo
    FROM Customer
    WHERE CustomerID = @CustomerID;
END;

--Delete operation
CREATE PROCEDURE sp_DeleteCustomer
(
    @CustomerID INT
)
AS
BEGIN
    DELETE FROM Customer
    WHERE customerID=@CustomerID
END;
DROP PROCEDURE sp_DeleteCustomer

--display table
CREATE PROCEDURE sp_SelectCustomer
AS
BEGIN
    SELECT CustomerID, CustomerName, Email, PhoneNo
    FROM Customer;
END;

--search box operation
CREATE PROCEDURE sp_SearchCustomer
(
    @SearchTerm VARCHAR(100)
)
AS
BEGIN
    SELECT CustomerID, CustomerName, Email, PhoneNo
    FROM Customer
    WHERE CustomerName LIKE '%' + @SearchTerm + '%'
       OR Email LIKE '%' + @SearchTerm + '%';
END;

-- check for adding new member already present
CREATE PROCEDURE sp_CheckCustomerExists
    @CustomerName VARCHAR(100),
    @Email VARCHAR(100),
    @PhoneNo VARCHAR(15)
AS
BEGIN
    SELECT CustomerID 
    FROM Customer
    WHERE CustomerName = @CustomerName
      AND Email = @Email
      AND PhoneNo = @PhoneNo
END


-------------------------------------------------------
--STORED PROCEDURES FOR <cfstoredproc> - Customer Table
-- insert operation
CREATE PROCEDURE sp_InsertProduct
(
    @ProductName VARCHAR(100),
    @Price DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO Product (ProductName, Price)
    VALUES (@ProductName, @Price);
END;

--Update (edit) operation
CREATE PROCEDURE sp_UpdateProduct
(
    @ProductID INT,
    @ProductName VARCHAR(100),
    @Price DECIMAL(10,2)
)
AS
BEGIN
    UPDATE Product
    SET ProductName = @ProductName,
        Price       = @Price
    WHERE ProductID = @ProductID;
END;
--load data for edit operation
CREATE PROCEDURE sp_GetProductById
(
    @ProductID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ProductID,
        ProductName,
        Price
    FROM Product
    WHERE ProductID = @ProductID;
END;

--Delete Operation
CREATE PROCEDURE sp_DeleteProduct
(
    @ProductID INT
)
AS
BEGIN
   DELETE FROM Product
    WHERE ProductID = @ProductID;
END;

--Display operation
CREATE PROCEDURE sp_SelectProduct
AS
BEGIN
    SELECT ProductID, ProductName, Price
    FROM Product
    ORDER BY ProductID;
END;

--search box operation
CREATE PROCEDURE sp_SearchProduct
(
    @ProductName VARCHAR(100)
)
AS
BEGIN
    SELECT ProductID, ProductName, Price
    FROM Product
    WHERE ProductName LIKE '%' + @ProductName + '%'
    ORDER BY ProductID;
END;

-- check for adding new member already present
CREATE PROCEDURE sp_CheckProductExists
    @ProductName VARCHAR(100),
    @Price DECIMAL(10,2)
AS
BEGIN
    SELECT ProductID
    FROM Product
    WHERE ProductName = @ProductName
      AND Price = @Price
      
END

