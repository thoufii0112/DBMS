-- ============================================
-- WEEK 11: DATABASE AUTOMATION
-- E-COMMERCE DATABASE SYSTEM
-- MySQL Workbench
-- ============================================

CREATE DATABASE IF NOT EXISTS ecommerce_week11;
USE ecommerce_week11;

-- ============================================
-- 1. CREATE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS Customer (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Products (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_Name VARCHAR(100) NOT NULL,
    Price DECIMAL(12,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Total_Amount DECIMAL(12,2) DEFAULT 0,
    Order_Status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
);

CREATE TABLE IF NOT EXISTS Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID)
        REFERENCES Products(Product_ID)
);

CREATE TABLE IF NOT EXISTS Payments (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Payment_Mode VARCHAR(30),
    Payment_Status VARCHAR(30) DEFAULT 'Pending',
    Transaction_Amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
);

-- ============================================
-- 2. INSERT SAMPLE DATA
-- ============================================

INSERT INTO Customer (Customer_Name)
VALUES
('Arun'),
('Priya'),
('Rahul');

INSERT INTO Products (Product_Name, Price, Stock)
VALUES
('Laptop', 50000, 30),
('Mobile', 15000, 5),
('Headphones', 2000, 20);

-- Insert sample orders
INSERT INTO Orders
(Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1, '2026-10-01 10:00:00', 50000, 'Delivered'),
(1, '2026-10-05 11:00:00', 0, 'Pending'),
(2, '2026-10-10 12:00:00', 15000, 'Shipped');

-- Insert sample order details
INSERT INTO Order_Details
(Order_ID, Product_ID, Quantity, Unit_Price)
VALUES
(1, 1, 1, 50000),
(2, 1, 0, 50000),
(3, 2, 1, 15000);

-- Insert sample payments
INSERT INTO Payments
(Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES
(1, 'UPI', 'Completed', 50000),
(2, 'Card', 'Pending', 0),
(3, 'UPI', 'Completed', 15000);

-- ============================================
-- 3. CREATE VIEWS
-- ============================================

-- View 1: Customer Order Report

CREATE OR REPLACE VIEW Customer_Order_Report AS
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID;

-- View 2: Product Sales Report

CREATE OR REPLACE VIEW Product_Sales_Report AS
SELECT
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Quantity_Sold,
    COALESCE(SUM(od.Quantity * od.Unit_Price), 0)
        AS Total_Revenue
FROM Products p
LEFT JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
LEFT JOIN Orders o
    ON od.Order_ID = o.Order_ID
    AND o.Order_Status <> 'Cancelled'
GROUP BY
    p.Product_ID,
    p.Product_Name;

-- View 3: Payment Status

CREATE OR REPLACE VIEW Payment_Status_View AS
SELECT
    o.Order_ID,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Orders o
JOIN Payments p
    ON o.Order_ID = p.Order_ID;

-- View 4: Low Stock Products

CREATE OR REPLACE VIEW Low_Stock_Products AS
SELECT
    Product_ID,
    Product_Name,
    Stock,
    'Low Stock' AS Stock_Status
FROM Products
WHERE Stock < 10;

-- ============================================
-- 4. STORED PROCEDURES
-- ============================================

DELIMITER //

-- Procedure 1: Add New Customer Order

CREATE PROCEDURE AddNewCustomerOrder(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT,
    IN p_Payment_Mode VARCHAR(30)
)
BEGIN
    DECLARE v_Price DECIMAL(12,2);
    DECLARE v_Stock INT;
    DECLARE v_Total DECIMAL(12,2);
    DECLARE v_Order_ID INT;
    DECLARE v_Count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be positive';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO v_Count
    FROM Customer
    WHERE Customer_ID = p_Customer_ID;

    IF v_Count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer not found';
    END IF;

    SELECT Price, Stock
    INTO v_Price, v_Stock
    FROM Products
    WHERE Product_ID = p_Product_ID
    FOR UPDATE;

    IF v_Stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found';
    END IF;

    IF v_Stock < p_Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    SET v_Total = v_Price * p_Quantity;

    INSERT INTO Orders
    (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES
    (p_Customer_ID, NOW(), v_Total, 'Pending');

    SET v_Order_ID = LAST_INSERT_ID();

    INSERT INTO Order_Details
    (Order_ID, Product_ID, Quantity, Unit_Price)
    VALUES
    (v_Order_ID, p_Product_ID, p_Quantity, v_Price);

    UPDATE Products
    SET Stock = Stock - p_Quantity
    WHERE Product_ID = p_Product_ID;

    INSERT INTO Payments
    (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
    VALUES
    (v_Order_ID, p_Payment_Mode, 'Pending', v_Total);

    COMMIT;

    SELECT
        v_Order_ID AS Order_ID,
        v_Total AS Total_Amount,
        'Order created successfully' AS Message;
END //

-- Procedure 2: Update Order Status

CREATE PROCEDURE UpdateOrderStatus(
    IN p_Order_ID INT,
    IN p_New_Status VARCHAR(30)
)
BEGIN
    IF p_New_Status NOT IN
       ('Pending', 'Shipped', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order status';
    END IF;

    UPDATE Orders
    SET Order_Status = p_New_Status
    WHERE Order_ID = p_Order_ID;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order not found or unchanged';
    END IF;

    SELECT Order_ID, Order_Status
    FROM Orders
    WHERE Order_ID = p_Order_ID;
END //

-- Procedure 3: Customer Purchase History

CREATE PROCEDURE GetCustomerOrders(
    IN p_Customer_ID INT
)
BEGIN
    SELECT
        Customer_ID,
        Order_ID,
        Order_Date,
        Total_Amount AS Purchase_Amount,
        Order_Status
    FROM Orders
    WHERE Customer_ID = p_Customer_ID
    ORDER BY Order_Date DESC;
END //

-- Procedure 4: Increase Inventory After Supply

CREATE PROCEDURE IncreaseProductStock(
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be positive';
    END IF;

    UPDATE Products
    SET Stock = Stock + p_Quantity
    WHERE Product_ID = p_Product_ID;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found or unchanged';
    END IF;

    SELECT Product_ID, Product_Name, Stock
    FROM Products
    WHERE Product_ID = p_Product_ID;
END //

DELIMITER ;

-- ============================================
-- 5. CREATE FUNCTIONS
-- ============================================

DELIMITER //

-- Function 1: Calculate Total Sales

CREATE FUNCTION CalculateTotalSales(
    p_Start_Date DATE,
    p_End_Date DATE
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_Total DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO v_Total
    FROM Orders
    WHERE Order_Date >= p_Start_Date
      AND Order_Date < DATE_ADD(p_End_Date, INTERVAL 1 DAY)
      AND Order_Status <> 'Cancelled';

    RETURN v_Total;
END //

-- Function 2: Calculate Customer Spending

CREATE FUNCTION CalculateCustomerSpending(
    p_Customer_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_Total DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO v_Total
    FROM Orders
    WHERE Customer_ID = p_Customer_ID
      AND Order_Status <> 'Cancelled';

    RETURN v_Total;
END //

-- Function 3: Calculate Product Revenue

CREATE FUNCTION CalculateProductRevenue(
    p_Product_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_Revenue DECIMAL(12,2);

    SELECT COALESCE(
        SUM(od.Quantity * od.Unit_Price), 0
    )
    INTO v_Revenue
    FROM Order_Details od
    JOIN Orders o
        ON od.Order_ID = o.Order_ID
    WHERE od.Product_ID = p_Product_ID
      AND o.Order_Status <> 'Cancelled';

    RETURN v_Revenue;
END //

DELIMITER ;

-- ============================================
-- 6. TEST VIEWS
-- ============================================

SELECT * FROM Customer_Order_Report;

SELECT * FROM Product_Sales_Report;

SELECT * FROM Payment_Status_View;

SELECT * FROM Low_Stock_Products;

-- ============================================
-- 7. TEST STORED PROCEDURES
-- ============================================

CALL AddNewCustomerOrder(1, 1, 2, 'UPI');

CALL UpdateOrderStatus(1, 'Shipped');

CALL GetCustomerOrders(1);

CALL IncreaseProductStock(2, 10);

-- ============================================
-- 8. TEST FUNCTIONS
-- ============================================

SELECT CalculateTotalSales(
    '2026-10-01', '2026-10-31'
) AS Total_Sales;

SELECT CalculateCustomerSpending(1)
AS Customer_Total_Spending;

SELECT CalculateProductRevenue(1)
AS Product_Revenue;

-- ============================================
-- 9. DAILY SALES REPORT
-- ============================================

SELECT
    DATE(Order_Date) AS Sales_Date,
    COUNT(*) AS Total_Orders,
    SUM(Total_Amount) AS Total_Revenue
FROM Orders
WHERE Order_Status <> 'Cancelled'
GROUP BY DATE(Order_Date)
ORDER BY Sales_Date DESC;

-- ============================================
-- 10. MONTHLY REVENUE REPORT
-- ============================================

-

-- ============================================
-- 11. CUSTOMER PURCHASE REPORT
-- ============================================

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    COALESCE(SUM(
        CASE
            WHEN o.Order_Status <> 'Cancelled'
            THEN o.Total_Amount
            ELSE 0
        END
    ), 0) AS Total_Spending
FROM Customer c
LEFT JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;

-- ============================================
-- END OF WEEK 11 ASSIGNMENT
-- ============================================