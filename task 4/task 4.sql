USE inventory_db;


/* =========================================================
   STEP 1: CREATE CUSTOMERS TABLE
   ========================================================= */

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    City VARCHAR(50)
);


/* =========================================================
   STEP 2: INSERT CUSTOMERS
   ========================================================= */

INSERT INTO Customers
    (Customer_Name, Email, Phone, City)
VALUES
    ('Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
    ('Priya S', 'priya@gmail.com', '9876543211', 'Chengalpattu'),
    ('Rahul M', 'rahul@gmail.com', '9876543212', 'Tambaram'),
    ('Divya R', 'divya@gmail.com', '9876543213', 'Chennai'),
    ('Karthik V', 'karthik@gmail.com', '9876543214', 'Kanchipuram');


/* =========================================================
   STEP 3: CREATE ORDERS TABLE
   ========================================================= */

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL,
    Order_Status VARCHAR(30) NOT NULL,

    FOREIGN KEY (Customer_ID)
        REFERENCES Customers(Customer_ID)
);


/* =========================================================
   STEP 4: INSERT ORDERS
   ========================================================= */

INSERT INTO Orders
    (Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
    (31, 1, '2026-08-20', 3750.00, 'Delivered'),
    (32, 2, '2026-08-21', 2100.00, 'Pending'),
    (33, 3, '2026-08-22', 4850.00, 'Shipped'),
    (34, 1, '2026-08-23', 1650.00, 'Delivered'),
    (35, 4, '2026-08-24', 2900.00, 'Processing'),
    (36, 5, '2026-08-25', 5600.00, 'Delivered'),
    (37, 1, '2026-08-26', 3200.00, 'Delivered'),
    (38, 3, '2026-08-27', 4500.00, 'Shipped');


/* =========================================================
   STEP 5: CREATE ORDER_DETAILS TABLE
   ========================================================= */

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID),

    FOREIGN KEY (Product_ID)
        REFERENCES Products(Product_ID)
);


/* =========================================================
   STEP 6: INSERT ORDER DETAILS
   ========================================================= */

INSERT INTO Order_Details
    (Order_ID, Product_ID, Quantity, Price)
VALUES
    (31, 1, 1, 2500.00),
    (31, 2, 2, 625.00),

    (32, 3, 1, 2100.00),

    (33, 1, 1, 2500.00),
    (33, 4, 3, 783.33),

    (34, 2, 1, 650.00),
    (34, 5, 2, 500.00),

    (35, 3, 2, 1450.00),

    (36, 1, 2, 2800.00),

    (37, 2, 2, 1600.00),

    (38, 4, 2, 2250.00);


/* =========================================================
   REPORT 1: CUSTOMER ORDER HISTORY
   ========================================================= */

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status AS Status
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
ORDER BY o.Order_Date;


/* =========================================================
   REPORT 2: PRODUCT-WISE ORDER REPORT
   ========================================================= */

SELECT
    p.Product_Name,
    COUNT(od.Order_ID) AS Times_Ordered,
    SUM(od.Quantity) AS Total_Quantity_Sold
FROM Products p
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name
ORDER BY Total_Quantity_Sold DESC;


/* =========================================================
   REPORT 3: CUSTOMER PURCHASE ANALYSIS
   ========================================================= */
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        COUNT(o.Order_ID) AS Total_Orders,
        SUM(o.Total_Amount) AS Total_Spending,
        ROUND(AVG(o.Total_Amount), 2) AS Average_Order_Value
    FROM Customers c
    JOIN Orders o
        ON c.Customer_ID = o.Customer_ID
    GROUP BY
        c.Customer_ID,
        c.Customer_Name;