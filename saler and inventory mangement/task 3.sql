-- =========================================
-- SELLER AND INVENTORY MANAGEMENT SYSTEM
-- ERROR-FREE COMPLETE SCRIPT
-- =========================================

-- Select the database
USE inventory_db;

-- =========================================
-- STEP 1: REMOVE OLD TABLES
-- =========================================

DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS sellers;


-- =========================================
-- STEP 2: CREATE SELLERS TABLE
-- =========================================

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY AUTO_INCREMENT,
    store_name VARCHAR(120) NOT NULL UNIQUE,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================
-- STEP 3: CREATE INVENTORY TABLE
-- =========================================

CREATE TABLE inventory (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(150) NOT NULL,
    seller_id INT,
    sku VARCHAR(50) UNIQUE,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 10,
    last_restocked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_sellers
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================
-- STEP 4: INSERT SELLERS
-- =========================================

INSERT INTO sellers
(store_name, contact_email, phone_number, city)
VALUES
('ABC Store', 'abc@gmail.com', '9876543210', 'Chennai'),
('Fresh Mart', 'fresh@gmail.com', '9000000002', 'Chennai'),
('Tech World', 'tech@gmail.com', '9876543212', 'Bangalore'),
('Daily Needs', '9000000004', '9876543213', 'Coimbatore'),
('Smart Shop', 'smart@gmail.com', '9876543214', 'Madurai');


-- =========================================
-- STEP 5: INSERT INVENTORY
-- =========================================

INSERT INTO inventory
(item_name, seller_id, sku, unit_price, stock_quantity, reorder_level)
VALUES
('Laptop', 1, 'SKU001', 52000.00, 10, 10),
('Mouse', 2, 'SKU002', 500.00, 30, 10),
('Keyboard', 3, 'SKU003', 1200.00, 20, 10),
('Headphones', 4, 'SKU004', 1500.00, 20, 10),
('Monitor', 5, 'SKU005', 12000.00, 8, 15);


-- =========================================
-- REPORT 1
-- COMPREHENSIVE AVAILABILITY & STOCK CLASSIFICATION
-- =========================================

SELECT
    s.store_name,
    i.item_id,
    i.item_name,
    i.sku,
    i.unit_price,
    i.stock_quantity,
    i.reorder_level,

    CASE
        WHEN i.stock_quantity = 0
            THEN 'Unavailable (Out of Stock)'

        WHEN i.stock_quantity <= i.reorder_level
            THEN 'Available (Low Stock Alert)'

        ELSE 'Available (Optimal Stock)'
    END AS inventory_status

FROM inventory AS i

INNER JOIN sellers AS s
    ON i.seller_id = s.seller_id

ORDER BY
    s.store_name,
    i.stock_quantity ASC;


-- =========================================
-- REPORT 2
-- UNAVAILABLE PRODUCT BREAKDOWN
-- =========================================

SELECT
    s.seller_id,
    s.store_name,
    s.contact_email,
    i.sku,
    i.item_name,
    i.unit_price,
    i.last_restocked

FROM inventory AS i

INNER JOIN sellers AS s
    ON i.seller_id = s.seller_id

WHERE i.stock_quantity = 0

ORDER BY
    s.store_name,
    i.item_name;


-- =========================================
-- REPORT 3
-- SELLER PORTFOLIO VALUATION & AVAILABILITY
-- =========================================

SELECT
    s.seller_id,
    s.store_name,
    s.city,

    COUNT(i.item_id) AS total_skus_managed,

    SUM(
        CASE
            WHEN i.stock_quantity > 0 THEN 1
            ELSE 0
        END
    ) AS available_skus,

    SUM(
        CASE
            WHEN i.stock_quantity = 0 THEN 1
            ELSE 0
        END
    ) AS unavailable_skus,

    COALESCE(
        SUM(i.stock_quantity),
        0
    ) AS total_units_in_stock,

    COALESCE(
        ROUND(
            SUM(i.unit_price * i.stock_quantity),
            2
        ),
        0.00
    ) AS total_inventory_valuation

FROM sellers AS s

LEFT JOIN inventory AS i
    ON s.seller_id = i.seller_id

GROUP BY
    s.seller_id,
    s.store_name,
    s.city

ORDER BY
    total_inventory_valuation DESC;


-- =========================================
-- OPTIONAL: VIEW ALL DATA
-- =========================================

SELECT * FROM sellers;

SELECT * FROM inventory;
-- =========================================
-- REPORT 3
-- Seller Portfolio Valuation & Availability
-- =========================================

SELECT
    s.seller_id,
    s.store_name,
    s.city,

    COUNT(i.item_id) AS total_skus_managed,

    SUM(
        CASE
            WHEN i.stock_quantity > 0 THEN 1
            ELSE 0
        END
    ) AS available_skus,

    SUM(
        CASE
            WHEN i.stock_quantity = 0 THEN 1
            ELSE 0
        END
    ) AS unavailable_skus,

    COALESCE(
        SUM(i.stock_quantity),
        0
    ) AS total_units_in_stock,

    COALESCE(
        ROUND(
            SUM(i.unit_price * i.stock_quantity),
            2
        ),
        0.00
    ) AS total_inventory_valuation

FROM sellers AS s

LEFT JOIN inventory AS i
    ON s.seller_id = i.seller_id

GROUP BY
    s.seller_id,
    s.store_name,
    s.city

ORDER BY
    total_inventory_valuation DESC;