-- =====================================================
-- WEEK 9: SALES AND CUSTOMER ANALYTICS SYSTEM
-- MYSQL WORKBENCH
-- =====================================================

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Price DECIMAL(10,2),
    Category_ID INT,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID)
);

CREATE TABLE IF NOT EXISTS Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE IF NOT EXISTS Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT,
    Product_ID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

INSERT IGNORE INTO Customer VALUES
(1, 'Arun', 'arun@gmail.com'),
(2, 'Bala', 'bala@gmail.com'),
(3, 'Charan', 'charan@gmail.com'),
(4, 'Deepa', 'deepa@gmail.com'),
(5, 'Elango', 'elango@gmail.com');

INSERT IGNORE INTO Category VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books');

INSERT IGNORE INTO Product VALUES
(1, 'Laptop', 50000.00, 1),
(2, 'Mobile Phone', 25000.00, 1),
(3, 'Headphones', 2000.00, 1),
(4, 'T-Shirt', 800.00, 2),
(5, 'Jeans', 1500.00, 2),
(6, 'SQL Book', 600.00, 3),
(7, 'Java Book', 700.00, 3);

INSERT IGNORE INTO Orders VALUES
(101, 1, '2026-01-10', 50000.00),
(102, 2, '2026-01-15', 25000.00),
(103, 1, '2026-02-05', 2800.00),
(104, 3, '2026-02-10', 1500.00),
(105, 4, '2026-02-15', 50600.00),
(106, 2, '2026-03-01', 27000.00),
(107, 5, '2026-03-05', 1300.00),
(108, 3, '2026-03-10', 2000.00);

INSERT IGNORE INTO Order_Details VALUES
(1, 101, 1, 1, 50000.00),
(2, 102, 2, 1, 25000.00),
(3, 103, 3, 1, 2000.00),
(4, 103, 4, 1, 800.00),
(5, 104, 5, 1, 1500.00),
(6, 105, 1, 1, 50000.00),
(7, 105, 6, 1, 600.00),
(8, 106, 2, 1, 25000.00),
(9, 106, 3, 1, 2000.00),
(10, 107, 4, 1, 800.00),
(11, 107, 6, 1, 500.00),
(12, 108, 3, 1, 2000.00);

-- =====================================================
-- 3. AGGREGATE FUNCTIONS
-- =====================================================

-- Total number of orders
SELECT COUNT(*) AS Total_Orders
FROM Orders;

-- Total revenue
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Orders;

-- Average order value
SELECT AVG(Total_Amount) AS Average_Order_Value
FROM Orders;

-- Highest order amount
SELECT MAX(Total_Amount) AS Highest_Order
FROM Orders;

-- Lowest order amount
SELECT MIN(Total_Amount) AS Lowest_Order
FROM Orders;

-- =====================================================
-- 4. CUSTOMER PURCHASE ANALYSIS
-- =====================================================

-- Orders placed by each customer
SELECT
    Customer_ID,
    COUNT(Order_ID) AS Number_Of_Orders
FROM Orders
GROUP BY Customer_ID;

-- Total amount spent by each customer
SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending
FROM Orders
GROUP BY Customer_ID
ORDER BY Total_Spending DESC;

-- Average spending by customer
SELECT
    Customer_ID,
    AVG(Total_Amount) AS Average_Spending
FROM Orders
GROUP BY Customer_ID;

-- Customer with maximum purchase
SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending
FROM Orders
GROUP BY Customer_ID
ORDER BY Total_Spending DESC
LIMIT 1;

-- =====================================================
-- 5. TOP 5 CUSTOMERS
-- =====================================================

SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending
FROM Orders
GROUP BY Customer_ID
ORDER BY Total_Spending DESC
LIMIT 5;

-- =====================================================
-- 6. BEST-SELLING PRODUCTS
-- =====================================================

-- Products with maximum sales quantity
SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sold
FROM Order_Details
GROUP BY Product_ID
ORDER BY Total_Sold DESC;

-- Products generating highest revenue
SELECT
    Product_ID,
    SUM(Price * Quantity) AS Revenue
FROM Order_Details
GROUP BY Product_ID
ORDER BY Revenue DESC;

-- Top 5 products
SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sold
FROM Order_Details
GROUP BY Product_ID
ORDER BY Total_Sold DESC
LIMIT 5;

-- Least-selling products
SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sold
FROM Order_Details
GROUP BY Product_ID
ORDER BY Total_Sold ASC;

-- =====================================================
-- 7. CATEGORY-WISE SALES
-- =====================================================

-- Total sales by category
SELECT
    c.Category_Name,
    SUM(od.Price * od.Quantity) AS Total_Sales
FROM Category c
JOIN Product p
    ON c.Category_ID = p.Category_ID
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Total_Sales DESC;

-- Total products sold by category
SELECT
    c.Category_Name,
    SUM(od.Quantity) AS Products_Sold
FROM Category c
JOIN Product p
    ON c.Category_ID = p.Category_ID
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name;

-- Highest revenue category
SELECT
    c.Category_Name,
    SUM(od.Price * od.Quantity) AS Revenue
FROM Category c
JOIN Product p
    ON c.Category_ID = p.Category_ID
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Revenue DESC
LIMIT 1;

-- =====================================================
-- 8. SALES PERFORMANCE REPORT
-- =====================================================

SELECT
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Total_Sales,
    AVG(Total_Amount) AS Average_Order_Value,
    MAX(Total_Amount) AS Highest_Order_Value
FROM Orders;

-- =====================================================
-- 9. CUSTOMER ANALYTICS REPORT
-- =====================================================

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_Of_Orders,
    SUM(o.Total_Amount) AS Total_Spending,
    AVG(o.Total_Amount) AS Average_Spending
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

-- =====================================================
-- 10. PRODUCT PERFORMANCE REPORT
-- =====================================================

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Price * od.Quantity) AS Revenue_Generated
FROM Product p
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Revenue_Generated DESC;

-- =====================================================
-- 11. CATEGORY ANALYSIS REPORT
-- =====================================================

SELECT
    c.Category_Name,
    SUM(od.Quantity) AS Total_Products_Sold,
    SUM(od.Price * od.Quantity) AS Total_Revenue
FROM Category c
JOIN Product p
    ON c.Category_ID = p.Category_ID
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Total_Revenue DESC;