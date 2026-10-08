USE INVENTORY_DB;

-- =========================================================
-- WEEK 10: ADVANCED SQL QUERY SYSTEM
-- SUBQUERIES AND NESTED QUERIES
-- =========================================================


-- =========================================================
-- 1. PRODUCTS ABOVE AVERAGE PRICE
-- Single-Row Subquery
-- =========================================================

SELECT
    p.Product_Name,
    c.Category_Name AS Category,
    p.Price
FROM products p
JOIN categories c
    ON p.Category_ID = c.Category_ID
WHERE p.Price > (
    SELECT AVG(Price)
    FROM products
);


-- =========================================================
-- 2. CUSTOMERS WITH HIGH-VALUE ORDERS
-- Multi-Row Subquery
-- Orders greater than Rs.3000
-- =========================================================

SELECT
    Customer_ID,
    Customer_Name,
    Email,
    Phone
FROM customers
WHERE Customer_ID IN (
    SELECT DISTINCT Customer_ID
    FROM orders
    WHERE Total_Amount > 3000
      AND Order_Status != 'Cancelled'
);


-- =========================================================
-- 3. AVERAGE CUSTOMER SPENDING BENCHMARK
-- Nested Subquery / Derived Table
-- =========================================================

SELECT
    ROUND(AVG(Customer_Total_Spend), 2)
    AS Benchmark_Avg_Customer_Spend
FROM (
    SELECT
        Customer_ID,
        SUM(Total_Amount) AS Customer_Total_Spend
    FROM orders
    WHERE Order_Status != 'Cancelled'
    GROUP BY Customer_ID
) AS CustomerSpendSummary;


-- =========================================================
-- 4. EXPENSIVE PRODUCTS IN EACH CATEGORY
-- Products having price higher than their category average
-- =========================================================

SELECT
    p.Product_Name,
    c.Category_Name AS Category,
    p.Price
FROM products p
JOIN categories c
    ON p.Category_ID = c.Category_ID
WHERE p.Price > (
    SELECT AVG(p2.Price)
    FROM products p2
    WHERE p2.Category_ID = p.Category_ID
);


-- =========================================================
-- 5. PRODUCTS ABOVE SELECTED CATEGORY AVERAGE
-- Example: Electronics
-- =========================================================

SELECT
    p.Product_Name,
    c.Category_Name AS Category,
    p.Price
FROM products p
JOIN categories c
    ON p.Category_ID = c.Category_ID
WHERE c.Category_Name = 'Electronics'
  AND p.Price > (
      SELECT AVG(p2.Price)
      FROM products p2
      JOIN categories c2
          ON p2.Category_ID = c2.Category_ID
      WHERE c2.Category_Name = 'Electronics'
  );


-- =========================================================
-- 6. CUSTOMER WHO SPENT THE HIGHEST AMOUNT
-- Nested Subquery
-- =========================================================

SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending
FROM orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
HAVING SUM(Total_Amount) = (
    SELECT MAX(Total_Sales)
    FROM (
        SELECT
            Customer_ID,
            SUM(Total_Amount) AS Total_Sales
        FROM orders
        WHERE Order_Status != 'Cancelled'
        GROUP BY Customer_ID
    ) AS CustomerSales
);


-- =========================================================
-- 7. CUSTOMER WITH MAXIMUM NUMBER OF ORDERS
-- =========================================================

SELECT
    Customer_ID,
    COUNT(Order_ID) AS Total_Orders
FROM orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
HAVING COUNT(Order_ID) = (
    SELECT MAX(Order_Count)
    FROM (
        SELECT
            Customer_ID,
            COUNT(Order_ID) AS Order_Count
        FROM orders
        WHERE Order_Status != 'Cancelled'
        GROUP BY Customer_ID
    ) AS OrderSummary
);


-- =========================================================
-- 8. CUSTOMERS WHOSE SPENDING IS ABOVE AVERAGE
-- =========================================================

SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending
FROM orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
HAVING SUM(Total_Amount) > (
    SELECT AVG(Customer_Total_Spend)
    FROM (
        SELECT
            Customer_ID,
            SUM(Total_Amount) AS Customer_Total_Spend
        FROM orders
        WHERE Order_Status != 'Cancelled'
        GROUP BY Customer_ID
    ) AS CustomerSpend
);


-- =========================================================
-- 9. TOP 5 VALUABLE CUSTOMERS
-- =========================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spending
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC
LIMIT 5;


-- =========================================================
-- 10. BEST-SELLING PRODUCT
-- Maximum quantity sold
-- =========================================================

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Total_Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Total_Revenue
FROM products p
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.Quantity) = (
    SELECT MAX(Total_Quantity)
    FROM (
        SELECT
            od2.Product_ID,
            SUM(od2.Quantity) AS Total_Quantity
        FROM order_details od2
        JOIN orders o2
            ON od2.Order_ID = o2.Order_ID
        WHERE o2.Order_Status != 'Cancelled'
        GROUP BY od2.Product_ID
    ) AS ProductSales
);


-- =========================================================
-- 11. HIGH-VALUE CUSTOMERS
-- Spending greater than average customer spending
-- =========================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spending
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
HAVING SUM(o.Total_Amount) > (
    SELECT AVG(Customer_Total_Spend)
    FROM (
        SELECT
            Customer_ID,
            SUM(Total_Amount) AS Customer_Total_Spend
        FROM orders
        WHERE Order_Status != 'Cancelled'
        GROUP BY Customer_ID
    ) AS AverageCustomerSpend
)
ORDER BY Total_Spending DESC;


-- =========================================================
-- 12. CATEGORY PERFORMANCE ANALYSIS
-- Revenue generated by each category
-- =========================================================

SELECT
    c.Category_ID,
    c.Category_Name,
    SUM(od.Quantity * od.Price) AS Category_Revenue,
    SUM(od.Quantity) AS Products_Sold,
    AVG(p.Price) AS Average_Product_Price
FROM categories c
JOIN products p
    ON c.Category_ID = p.Category_ID
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Category_Revenue DESC;


-- =========================================================
-- 13. HIGHEST REVENUE-GENERATING CATEGORY
-- =========================================================

SELECT
    c.Category_Name,
    SUM(od.Quantity * od.Price) AS Total_Revenue
FROM categories c
JOIN products p
    ON c.Category_ID = p.Category_ID
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Category_ID, c.Category_Name
HAVING SUM(od.Quantity * od.Price) = (
    SELECT MAX(Category_Revenue)
    FROM (
        SELECT
            p2.Category_ID,
            SUM(od2.Quantity * od2.Price) AS Category_Revenue
        FROM products p2
        JOIN order_details od2
            ON p2.Product_ID = od2.Product_ID
        JOIN orders o2
            ON od2.Order_ID = o2.Order_ID
        WHERE o2.Order_Status != 'Cancelled'
        GROUP BY p2.Category_ID
    ) AS CategorySales
);


-- =========================================================
-- 14. CUSTOMER PURCHASE HISTORY
-- =========================================================

SELECT
    c.Customer_Name,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    SUM(o.Total_Amount) AS Total_Purchase_Amount
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Purchase_Amount DESC;


-- =========================================================
-- REPORT 1: PREMIUM PRODUCT REPORT
-- Products above average price
-- =========================================================

SELECT
    p.Product_Name,
    c.Category_Name AS Category,
    p.Price,
    p.Stock_Quantity AS Stock_Availability
FROM products p
JOIN categories c
    ON p.Category_ID = c.Category_ID
WHERE p.Price > (
    SELECT AVG(Price)
    FROM products
)
ORDER BY p.Price DESC;


-- =========================================================
-- REPORT 2: CUSTOMER VALUE REPORT
-- =========================================================

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Total_Amount) AS Total_Spending,
    CASE
        WHEN SUM(o.Total_Amount) >= 100000 THEN 'Premium'
        WHEN SUM(o.Total_Amount) >= 50000 THEN 'High Value'
        ELSE 'Regular'
    END AS Customer_Category
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;


-- =========================================================
-- REPORT 3: SALES PERFORMANCE REPORT
-- =========================================================

SELECT
    p.Product_Name,
    c.Category_Name AS Category,
    SUM(od.Quantity) AS Total_Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Product_Revenue,
    (
        SELECT SUM(od2.Quantity * od2.Price)
        FROM order_details od2
        JOIN products p2
            ON od2.Product_ID = p2.Product_ID
        JOIN orders o2
            ON od2.Order_ID = o2.Order_ID
        WHERE p2.Category_ID = p.Category_ID
          AND o2.Order_Status != 'Cancelled'
    ) AS Category_Revenue
FROM products p
JOIN categories c
    ON p.Category_ID = c.Category_ID
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY
    p.Product_ID,
    p.Product_Name,
    c.Category_ID,
    c.Category_Name
ORDER BY Product_Revenue DESC;

-- =========================================================
-- REPORT 4: BUSINESS DECISION REPORT
-- =========================================================

SELECT
    'High-Performing Product' AS Decision_Type,
    p.Product_Name AS Item,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Amount
FROM products p
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.Quantity) > (
    SELECT AVG(Product_Quantity)
    FROM (
        SELECT
            od2.Product_ID,
            SUM(od2.Quantity) AS Product_Quantity
        FROM order_details od2
        JOIN orders o2
            ON od2.Order_ID = o2.Order_ID
        WHERE o2.Order_Status != 'Cancelled'
        GROUP BY od2.Product_ID
    ) AS ProductAverage
)

UNION ALL

SELECT
    'Low-Performing Product' AS Decision_Type,
    p.Product_Name AS Item,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Amount
FROM products p
JOIN order_details od
    ON p.Product_ID = od.Product_ID
JOIN orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.Quantity) < (
    SELECT AVG(Product_Quantity)
    FROM (
        SELECT
            od2.Product_ID,
            SUM(od2.Quantity) AS Product_Quantity
        FROM order_details od2
        JOIN orders o2
            ON od2.Order_ID = o2.Order_ID
        WHERE o2.Order_Status != 'Cancelled'
        GROUP BY od2.Product_ID
    ) AS ProductAverage
)

UNION ALL

SELECT
    'High-Value Customer' AS Decision_Type,
    c.Customer_Name AS Item,
    COUNT(o.Order_ID) AS Quantity_Sold,
    SUM(o.Total_Amount) AS Amount
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
HAVING SUM(o.Total_Amount) > (
    SELECT AVG(Customer_Total_Spend)
    FROM (
        SELECT
            Customer_ID,
            SUM(Total_Amount) AS Customer_Total_Spend
        FROM orders
        WHERE Order_Status != 'Cancelled'
        GROUP BY Customer_ID
    ) AS CustomerAverage
)

ORDER BY Amount DESC;