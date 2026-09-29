-- =========================================
-- INNER JOIN
-- =========================================

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Total_Amount
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


SELECT
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status,
    p.Payment_Mode,
    p.Payment_Status
FROM Orders o
INNER JOIN Payment p
ON o.Order_ID = p.Order_ID;


SELECT
    c.Customer_Name,
    o.Order_ID,
    pr.Product_Name,
    od.Quantity
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od
ON o.Order_ID = od.Order_ID
INNER JOIN Products pr
ON od.Product_ID = pr.Product_ID;


-- =========================================
-- LEFT JOIN
-- =========================================

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Total_Amount
FROM Customers c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Email
FROM Customers c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;


SELECT
    pr.Product_ID,
    pr.Product_Name,
    pr.Price,
    od.Order_ID,
    od.Quantity
FROM Products pr
LEFT JOIN Order_Details od
ON pr.Product_ID = od.Product_ID;


-- =========================================
-- RIGHT JOIN
-- =========================================

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Total_Amount
FROM Customers c
RIGHT JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


SELECT
    o.Order_ID,
    o.Total_Amount,
    c.Customer_Name
FROM Customers c
RIGHT JOIN Orders o
ON c.Customer_ID = o.Customer_ID
WHERE c.Customer_ID IS NULL;


SELECT
    p.payment_date,
    o.order_id,
    p.payment_status,
    o.order_status,
    p.transaction_amount
FROM Orders o
RIGHT JOIN Payment p
ON o.order_id = p.order_id;


-- =========================================
-- COMPLETE ORDER REPORT
-- =========================================

SELECT
    c.Customer_Name,
    pr.Product_Name,
    od.Quantity,
    o.Order_Date,
    o.Total_Amount,
    p.Payment_Status
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od
ON o.Order_ID = od.Order_ID
INNER JOIN Products pr
ON od.Product_ID = pr.Product_ID
INNER JOIN Payment p
ON o.Order_ID = p.Order_ID;


-- =========================================
-- CUSTOMER PURCHASE HISTORY
-- =========================================

-- 1. Products purchased by customers

SELECT
    c.Customer_Name,
    pr.Product_Name,
    od.Quantity,
    o.Order_Date
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od
ON o.Order_ID = od.Order_ID
INNER JOIN Products pr
ON od.Product_ID = pr.Product_ID;


-- 2. Total amount spent by each customer

SELECT
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 3. Number of orders placed by each customer

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 4. Latest purchase details of customers

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Date = (
    SELECT MAX(o2.Order_Date)
    FROM Orders o2
    WHERE o2.Customer_ID = c.Customer_ID
);


-- =========================================
-- BUSINESS REPORTS
-- =========================================

-- Report 1: Customer Order Report

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Order_Status
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


-- Report 2: Sales Report

SELECT
    pr.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * pr.Price) AS Total_Revenue
FROM Products pr
INNER JOIN Order_Details od
ON pr.Product_ID = od.Product_ID
GROUP BY pr.Product_ID, pr.Product_Name;


-- Report 3: Payment Analysis Report

SELECT
    p.Payment_Mode,
    COUNT(p.Payment_ID) AS Number_of_Transactions,
    SUM(
        CASE
            WHEN p.Payment_Status = 'SUCCESSFUL'
            THEN 1
            ELSE 0
        END
    ) AS Successful_Payments
FROM Payment p
GROUP BY p.Payment_Mode;


-- =========================================
-- CUSTOMER PURCHASE ANALYSIS
-- =========================================

-- 1. Top purchasing customers

SELECT
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spent DESC;


-- 2. Customers with maximum orders

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Orders DESC;


-- 3. Customers with highest spending

SELECT
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spending
FROM Customers c
INNER JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;