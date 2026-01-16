--Create database for library management system:

CREATE DATABASE LibraryDB;
USE LibraryDB;
GO

--create 3 tables in LibraryDB - Books, Members, BorrowedRecords: ADD IDENTITY()
CREATE TABLE Books(
BookID INT IDENTITY(1,1) PRIMARY KEY,
BookName VARCHAR(50) NOT NULL,
Author VARCHAR(25) NOT NULL,
Genre VARCHAR(25) NOT NULL,
AvailableQuantity INT NOT NULL CHECK (AvailableQuantity >= 0),
TotalQuantity INT NOT NULL CHECK (TotalQuantity >= 0));

CREATE TABLE Members(
MemberID INT IDENTITY(101,1) PRIMARY KEY,
Name VARCHAR(50) NOT NULL,
Email VARCHAR(50) NOT NULL UNIQUE,
PhoneNo VARCHAR(10) NOT NULL,
MembershipDate DATETIME NOT NULL DEFAULT GETDATE());

CREATE TABLE BorrowedRecords
(
BorrowID INT IDENTITY(1001,1) PRIMARY KEY,
MemberID INT NOT NULL,
BookID INT NOT NULL,
BorrowDate DATETIME NOT NULL DEFAULT GETDATE(),
ReturnDate DATETIME,
DueDate DATETIME,
FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
FOREIGN KEY (BookID) REFERENCES Books(BookID));

--Insert Data into the tables - Books, Member, BorrowedRecords:
INSERT INTO Books(BookName,Author,Genre,AvailableQuantity,TotalQuantity) 
VALUES
('The Alchemist','Paulo Coelho','Fiction',3,6),
('Wings of Fire','A.P.J. Abdul Kalam','Biography',4,5),
('Atomic Habits','James Clear','Self-Help',7,8),
('Ikigai','Hector Garcia','Fiction',5,6),
('Sapiens','Yuval Noah','History',5,7),
('Guns, Germs, and Steel','Jared Diamond','History',4,5),
('The Power of Now','Eckhart Tolle','Spiritual',3,5),
('The Monk Who Sold His Ferrari','Robin Sharma','Spiritual',5,6),
('Pride and Prejudice','Jane Austen','Fiction',5,6),
('Think Like a monk','Jay Shetty','Self-Help',5,6),
('Norweigian Wood','Haruki Murakami','Fiction',6,6),
('Becoming','Michelle Obama','Biography',4,4);

INSERT INTO Members(Name,Email,PhoneNo,MembershipDate) 
VALUES
('Arav Mehta','arav@gmail.com','9876543210','2025-01-05 09:18:56'),
('Sneha Rao','sneharao@gmail.com','9871234560','2025-01-05 08:19:46'),
('Karthik R','karthik@gmail.com','9876543201','2025-03-15 11:00:15'),
('Pooja A','poojaa@gmail.com','7896543210','2025-02-07 12:45:00'),
('Manasa R','manasar@gmail.com','9884563210','2025-03-10 09:18:56'),
('Meera Joshi','meera@gmail.com','9875566200','2025-01-05 10:45:30'),
('Kavya P','kavyap@gmail.com','9880543210','2025-02-08 11:00:15'),
('Rahul Kumar','rahulk@gmail.com','6789543210','2025-04-25 12:45:00'),
('Suresh V','sureshv@gmail.com','9877553210','2025-04-27  11:00:15'),
('Keerthi H','keerthih@gmail.com','9876345610','2025-05-02 10:45:30'),
('Arya K','aryak@gmail.com','9876345610','2025-06-02 09:18:56'),
('Rohit L','rohitl@gmail.com','9876345610','2025-04-12 12:45:00'),
('Ananya T','ananyat@gmail.com','9876345610','2025-02-23 09:18:56');


INSERT INTO BorrowedRecords(MemberID,BookID,BorrowDate,ReturnDate,DueDate) 
VALUES
(101,1,'2025-03-01 10:45:30','2025-03-12 11:45:30',DATEADD(DAY,15,'2025-03-01 10:45:30')),
(102,3,'2025-03-05 11:00:15',NULL,DATEADD(DAY,15,'2025-03-05 11:00:15')),
(103,2,'2025-03-08 10:45:30','2025-03-18 09:45:30',DATEADD(DAY,15,'2025-03-08 10:45:30')),
(104,5,'2025-03-10 09:18:56',NULL,DATEADD(DAY,15,'2025-03-10 09:18:56')),
(105,6,'2025-03-15 12:45:00','2025-03-25 11:45:00',DATEADD(DAY,15,'2025-03-15 12:45:00')),
(106,4,'2025-03-18 11:00:15',NULL,DATEADD(DAY,15,'2025-03-18 11:00:15')),
(107,8,'2025-03-20 09:18:56','2025-03-30 08:18:56',DATEADD(DAY,15,'2025-03-20 09:18:56')),
(108,9,'2025-03-22 10:45:30',NULL,DATEADD(DAY,15,'2025-03-22 10:45:30')),
(109,10,'2025-03-25 08:13:00',NULL,DATEADD(DAY,15,'2025-03-25 08:13:00')),
(110,7,'2025-03-28 11:00:15','2025-04-05 12:00:15',DATEADD(DAY,15,'2025-03-28 11:00:15')),
(110,5,'2025-04-23 13:00:07','2025-05-01 14:00:07',DATEADD(DAY,15,'2025-04-23 13:00:07')),
(102,7,'2025-03-15 11:00:15',NULL,DATEADD(DAY,15,'2025-03-15 11:00:15')),
(105,1,'2025-04-25 10:45:30','2025-05-02 11:45:30',DATEADD(DAY,15,'2025-04-25 10:45:30')),
(105,1,'2025-03-25 09:18:56','2025-04-02 08:18:56',DATEADD(DAY,15,'2025-03-25 09:18:56'));



--Display all the records of the tables:
SELECT * FROM Books;
SELECT * FROM Members;
SELECT * FROM BorrowedRecords;

--Filter data using WHERE Clause:
--Retrieve all the books where the genre is Fiction:
SELECT * 
FROM Books 
WHERE Genre='Fiction';

--check the availability of the book:
SELECT *
FROM Books
WHERE AvailableQuantity >0;

--Retrieve all the books where Avilable Quantity is greater that 3:
SELECT * 
FROM Books 
WHERE AvailableQuantity > 3;

--Retrieve memebers who joined after 2025-02-01:
SELECT * 
FROM Members 
WHERE CAST(MembershipDate AS DATE) > '2025-02-01';

--Retrieve borrowing records where Return Date is NULL:
SELECT *
FROM BorrowedRecords
WHERE ReturnDate IS NULL;

--Retrieve borrowing records where Return Date is not NULL:
SELECT *
FROM BorrowedRecords
WHERE ReturnDate IS NOT NULL;

--Display Book Title and the Auther where the genre is History:
SELECT BookName,Author
FROM Books
WHERE Genre = 'History';

--Display MemberName and Email for members who joined after 2025-03-01:
SELECT Name,Email
FROM Members
WHERE CAST(MembershipDate AS DATE) > '2025-03-01';

--Display BorrowID and BorrowDate where the BookID is 2:
SELECT BorrowID,BorrowDate
FROM BorrowedRecords
WHERE BookID = 2;

--Display BorrowID and BorrowDate where the BookID is 2 or 7:
SELECT BorrowID,BookID,BorrowDate
FROM BorrowedRecords
WHERE BookID = 2 OR BookID = 7;

--Display BorrowID and BorrowDate where the BookID is 2 and BorrowDate is 2025-03-08:
SELECT BorrowID,BorrowDate
FROM BorrowedRecords
WHERE BookID = 2 AND CAST(BorrowDate AS DATE) = '2025-03-08';

--Display the Borrowing records borrowed between 2025-03-12 and 2025-03-30:
SELECT *
FROM BorrowedRecords
WHERE  CAST(BorrowDate AS DATE) BETWEEN '2025-03-12' AND '2025-03-30';

--Display the book names starting with 'The':
SELECT *
FROM Books
WHERE BookName LIKE 'The%';

--Display the book names not starting with 'The':
SELECT *
FROM Books
WHERE NOT BookName LIKE 'The%';

--Display the book details of genre self-help,fiction,Spritual:
SELECT *
FROM Books
WHERE Genre IN ('Self-Help','Fiction','Spiritual');

--Display the book details of genre NOT IN self-help,fiction,Spritual:
SELECT *
FROM Books
WHERE Genre NOT IN ('Self-Help','Fiction','Spiritual');

--ORDER BY
--Display all books stored by Title in ascending order:
SELECT *
FROM Books
ORDER BY BookName;

--Display all books stored by Title in descending order:
SELECT *
FROM Books
ORDER BY BookName DESC;

--Display the members who recently joined:
SELECT TOP 3 *
FROM Members
ORDER BY MembershipDate DESC;

--Display books sorted by Genre and Title:
SELECT *
FROM Books
ORDER BY Genre,BookName;

--Display books sorted by genre (a-z) and available quantity (high to low):
SELECT *
FROM Books
ORDER BY Genre,AvailableQuantity DESC;

--Diplay members who joined after 2025-02-01, ordered by join date (newest first):
SELECT *
FROM Members 
WHERE CAST(MembershipDate AS DATE) > '2025-02-01'
ORDER BY MembershipDate DESC;

--Display borrowed records where Return date is not null ordered by MemberID:
SELECT *
FROM BorrowedRecords
WHERE ReturnDate IS NOT NULL
ORDER BY MemberID;


--AGGREGATE FUNCTIONS--GROUP BY--HAVING:
--Total number of different books in the library:
SELECT COUNT(BookID) Number_Different_Books
FROM Books;

--Total available quantity of all books:
SELECT SUM(AvailableQuantity) Total_Availabe_Quantity
FROM Books;

--average available quantity of books:
SELECT AVG(AvailableQuantity) AS Average_Availabe_Quantity
FROM Books;

--maximum/minimum available quantity among books:
SELECT MAX(AvailableQuantity) AS Max_Available_Quantity
FROM Books;
SELECT MIN(AvailableQuantity) AS Min_Available_Quantity
FROM Books;

--number of books currently borrowed and not returned:
SELECT COUNT(*) AS TotalBowrrowedBooks
FROM BorrowedRecords
WHERE ReturnDate IS NULL;

--number of memebers who joined after 2025-02-01:
SELECT COUNT(*) AS No_of_Members
FROM Members
WHERE CAST(MembershipDate AS DATE) > '2025-02-01';

--Average total quantity of books in the History gener:
SELECT AVG(TotalQuantity) AS Average_Total_Quantity
FROM Books
WHERE Genre = 'History';

--number of books in each genre:
SELECT Genre,COUNT(*) AS count_book
FROM Books
GROUP BY Genre;

--Earliest borrowed date for each book:
SELECT MIN(BorrowDate) AS Earliest_borrowed_date
FROM BorrowedRecords
GROUP BY BookID;

--number of borrowings for books that are currently not returned grouped by bookID:
SELECT COUNT(*) AS No_of_BorrowedBooks
FROM BorrowedRecords
WHERE ReturnDate IS NULL
GROUP BY BookID;

--number of members joined each month:
SELECT YEAR(MembershipDate) AS Join_Year, MONTH(MembershipDate) AS Join_Month,COUNT(*) AS NumberOfMembers
FROM Members
WHERE CAST(MembershipDate AS DATE) > '2025-02-01'
GROUP BY YEAR(MembershipDate),MONTH(MembershipDate);

--total available quantity per genre only if total>3:
SELECT Genre, SUM(AvailableQuantity) AS TotalAailable
FROM Books
GROUP BY Genre
HAVING SUM(AvailableQuantity) > 3;

--books borrowed more than once:
SELECT  BookID, COUNT(*) AS TimesBorrowed
FROM BorrowedRecords
GROUP BY BookID
HAVING COUNT(*)>1;

--Identify overdue returns:
SELECT *
FROM BorrowedRecords
WHERE ReturnDate IS NULL AND CAST(DueDate AS DATE) < GETDATE();

--JOINS:
--Borrowed books report:INNER JOIN:
SELECT br.BorrowID, m.MemberID,m.Name,br.BookID,br.BorrowDate,br.ReturnDate,br.DueDate
FROM BorrowedRecords br
INNER JOIN Members m
ON br.MemberID = m.MemberID

--Currently borrowed books detailes:
SELECT br.BorrowDate, b.BookID,b.BookName,br.DueDate
FROM BorrowedRecords br
JOIN Books b
ON br.BookID = b.BookID
WHERE br.ReturnDate IS NULL;

--Number of books borrowed per books:
SELECT b.BookID, b.BookName, COUNT(br.BorrowID) AS NumberOfTimesBorrowed
FROM Books b
LEFT JOIN BorrowedRecords br
ON b.BookID = br.BookID
GROUP BY b.BookID,b.BookName;

--overdue returns:
SELECT m.Name, b.BookName, br.BorrowDate,br.DueDate
FROM BorrowedRecords br
JOIN Members m
ON br.MemberID = m.MemberID
JOIN Books b
ON br.BookID = b.BookID
WHERE br.ReturnDate IS NULL AND CAST(br.DueDate AS DATE)< GETDATE();

--members who never borrowed books:
SELECT m.MemberID, m.Name
FROM Members m
LEFT JOIN BorrowedRecords br
ON m.MemberID = br.MemberID
WHERE br.BorrowID IS NULL;

--total books borrowed by each member:
SELECT  m.Name,COUNT(br.BorrowID) AS TotalBooksBorrowed
FROM Members m
JOIN BorrowedRecords br
ON m.MemberID = br.MemberID
GROUP BY m.Name;

--Display the books borrowed and then the BorrowID:
SELECT b.BookName, br.BorrowID
FROM BorrowedRecords br
RIGHT JOIN Books b
ON br.BookID = b.BookID;

--SUBQUERIES
--Books Borrowed at least once:
SELECT *
FROM Books
WHERE BookID IN (
    SELECT DISTINCT BookID
    FROM BorrowedRecords
);

--Members who borrowed more than 1 book:
SELECT *
FROM Members
WHERE MemberID IN (
    SELECT MemberID
    FROM BorrowedRecords
    GROUP BY MemberID
    HAVING COUNT(*) > 1
);

--EXISTS:
--Members who have borrowed books:
SELECT *
FROM Members m
WHERE EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.MemberID = m.MemberID
);

SELECT *
FROM Members m
WHERE EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.MemberID = m.MemberID
);

--Members who have never borrowed books:
SELECT *
FROM Members m
WHERE NOT EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.MemberID = m.MemberID
);

--Books that are currently borrowed:
SELECT *
FROM Books b
WHERE EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.BookID = b.BookID
      AND br.ReturnDate IS NULL
);

--Books that are currently Not borrowed:
SELECT *
FROM Books b
WHERE NOT EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.BookID = b.BookID
    AND br.ReturnDate IS NULL
);

--Books that were never Borrowed:
SELECT *
FROM Books b
WHERE NOT EXISTS (
    SELECT 1
    FROM BorrowedRecords br
    WHERE br.BookID = b.BookID
    );

--UNION:
SELECT Name 
FROM Members
UNION
SELECT Author 
FROM Books;

--UNION ALL:
SELECT Genre 
FROM Books
WHERE Genre = 'History'
UNION ALL
SELECT Genre 
FROM Books
WHERE Genre = 'Self-Help';

--CASE statement:
--Book Availability Status:
SELECT BookName,AvailableQuantity,
    CASE
        WHEN AvailableQuantity = 0 THEN 'Not Available'
        WHEN AvailableQuantity <= 2 THEN 'Low Stock'
        ELSE 'Available'
    END AS AvailableStock
FROM Books;

--Borrow Status:
SELECT BorrowID,
    CASE 
        WHEN ReturnDate IS NULL THEN 'Not Returned'
        ELSE 'Returned'
    END AS BorrowStatus
FROM BorrowedRecords;



SELECT m.Name, COUNT(*) AS NO_OF_BOOKS
FROM Members m
JOIN BorrowedRecords br
ON m.MemberID = br.MemberID
GROUP BY m.Name
HAVING COUNT(*)>1;


SELECT * FROM Books;
SELECT MAX(TotalQuantity) AS SecondHighest
FROM Books
WHERE TotalQuantity < (SELECT MAX(TotalQuantity)
                       FROM Books);