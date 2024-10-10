use classicmodels;

select * from employees;

#Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

# a.Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;

# b.	Show the unique productline values containing the word cars at the end from the products table.
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%Cars';

#Q2. CASE STATEMENTS for Segmentation

# a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)

SELECT customerNumber, customerName,
       CASE 
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;


#Q3. Group By with Aggregation functions and Having clause, Date and Time functions

# a. Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM OrderDetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;


# b. Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 

SELECT MONTHNAME(paymentDate) AS month, COUNT(*) AS totalPayments
FROM Payments
GROUP BY month
HAVING totalPayments > 20
ORDER BY totalPayments DESC;

#Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

# a.	Create a table named Customers to store customer information. Include the following columns:

CREATE DATABASE Customers_Orders;
USE Customers_Orders;

CREATE TABLE Customers (customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20));
    
    desc customers;
    
    # b.	Create a table named Orders to store information about customer orders. Include the following columns:
    
    CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0)
);

desc orders;

#Q5. JOINS

#a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

SELECT c.country, COUNT(o.orderNumber) AS order_count
FROM Customers c
JOIN Orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;

#Q6. SELF JOIN

#a. Create a table project with below fields.

CREATE TABLE Project (EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT);
    
    desc project;
    
    INSERT INTO Project (FullName, Gender, ManagerID) 
VALUES 
('Pranaya', 'Male', 3),      
('Priyanka', 'Female', 1),     
('Preety', 'Female', NULL),      
('Anurag', 'Male', 1),   
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

select * from project;

SELECT e.FullName AS EmployeeName, m.FullName AS ManagerName
FROM Project e
LEFT JOIN Project m ON e.ManagerID = m.EmployeeID;

#Q7. DDL Commands: Create, Alter, Rename

CREATE TABLE Facility ( Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100));
    
    ALTER TABLE Facility 
MODIFY Facility_ID INT AUTO_INCREMENT,
ADD PRIMARY KEY (Facility_ID);

ALTER TABLE Facility
ADD City VARCHAR(100) NOT NULL AFTER Name;

select * from facility;

desc facility;


#Q8. Views in SQL

#a. Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:

CREATE VIEW product_category_sales AS
SELECT 
    PL.productLine, 
    SUM(OD.quantityOrdered * OD.priceEach) AS total_sales,
    COUNT(DISTINCT O.orderNumber) AS number_of_orders
FROM 
    Products P
JOIN 
    OrderDetails OD ON P.productCode = OD.productCode
JOIN 
    Orders O ON OD.orderNumber = O.orderNumber
JOIN 
    ProductLines PL ON P.productLine = PL.productLine
GROUP BY 
    PL.productLine;
    
    SELECT * FROM product_category_sales;
    
    
    #Q9. Stored Procedures in SQL with parameters
    
    #a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
    
    DELIMITER $$

CREATE PROCEDURE Get_country_payments(
    IN input_year INT,
    IN input_country VARCHAR(100)
)
BEGIN
    SELECT 
        YEAR(P.paymentDate) AS payment_year,
        C.country,
        CONCAT(FORMAT(SUM(P.amount) / 1000, 2), 'K') AS total_amount
    FROM 
        Customers C
    JOIN 
        Payments P ON C.customerNumber = P.customerNumber
    WHERE 
        YEAR(P.paymentDate) = input_year
        AND C.country = input_country
    GROUP BY 
        YEAR(P.paymentDate), C.country;
END$$

DELIMITER ;

CALL Get_country_payments(2023, 'USA');

SELECT * FROM Payments WHERE YEAR(paymentDate) = 2023;

CALL Get_country_payments(2003, 'France');


#Q10. Window functions - Rank, dense_rank, lead and lag

#a) Using customers and orders tables, rank the customers based on their order frequency

SELECT 
    C.customerName,
    COUNT(O.orderNumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(O.orderNumber) DESC) AS rank_order,
    DENSE_RANK() OVER (ORDER BY COUNT(O.orderNumber) DESC) AS order_frequency_rnk
FROM 
    Customers C
JOIN 
    Orders O ON C.customerNumber = O.customerNumber
GROUP BY 
    C.customerName
ORDER BY 
    order_count DESC;
    
    
    #b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
    
    WITH OrdersByYearMonth AS (
    SELECT
        YEAR(orderDate) AS Year,
        MONTHNAME(orderDate) AS Month,
        COUNT(orderNumber) AS Total_Orders,
        MONTH(orderDate) AS MonthNumber -- To ensure correct ordering of months
    FROM 
        Orders
    GROUP BY 
        YEAR(orderDate), MONTHNAME(orderDate), MONTH(orderDate)
)
SELECT 
    Year,
    Month,
    Total_Orders,
    CONCAT(
        FORMAT(
            ((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year, MonthNumber)) / 
            LAG(Total_Orders) OVER (ORDER BY Year, MonthNumber)) * 100, 0), '%') AS `% YoY Change`
FROM 
    OrdersByYearMonth
ORDER BY 
    Year, MonthNumber;
    
    
    #Q11.Subqueries and their applications

#a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

    
    SELECT 
    P.productLine, 
    COUNT(*) AS product_line_count
FROM 
    Products P
WHERE 
    P.buyPrice > (SELECT AVG(buyPrice) FROM Products)  -- Subquery to calculate average buy price
GROUP BY 
    P.productLine order by product_line_count desc;
    
    
    #Q12. ERROR HANDLING in SQL
    
    CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);


desc emp_eh;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_EmpEh`(IN eid INT, IN ename VARCHAR(10), IN email VARCHAR(20))
BEGIN
    -- Handler for "Data too long for column" error (Error 1406)
    DECLARE EXIT HANDLER FOR 1406
    BEGIN
        SELECT 'Error Occurred: Data too long for column' AS Message;
    END;
    
    -- Handler for "Duplicate entry" error (Error 1062)
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT 'Error Occurred: Duplicate entry for primary key' AS Message;
    END;
    
    -- Insert data into the emp_eh table
    INSERT INTO emp_eh (EmpID, EmpName, EmailAddress)
    VALUES (eid, ename, email);
END //

DELIMITER ;

CALL proc_EmpEh(1, 'John', 'john@example.com');
CALL proc_EmpEh(2, 'Jane', 'jane@example.com');

CALL proc_EmpEh(1, 'Mark', 'mark@example.com');





use classicmodels;


#Q13. TRIGGERS

CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);

desc emp_bit;

DELIMITER //

CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    -- Check if Working_hours is negative and make it positive if it is
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END//

DELIMITER ;

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

SELECT * FROM Emp_BIT;




