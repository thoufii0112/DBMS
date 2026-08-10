-- =================================================================
-- Product and Category Management System Script
-- Database Engine: MySQL
-- =================================================================
DROP DATABASE IF EXISTS inventory_db;
CREATE DATABASE inventory_db;
USE inventory_db;
-- -----------------------------------------------------------------
-- Table: categories
-- -----------------------------------------------------------------
CREATE TABLE categories (
category_id INT AUTO_INCREMENT PRIMARY KEY,

category_name VARCHAR(100) NOT NULL UNIQUE,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- -----------------------------------------------------------------
-- Table: products
-- -----------------------------------------------------------------
CREATE TABLE products (
product_id INT AUTO_INCREMENT PRIMARY KEY,
product_name VARCHAR(150) NOT NULL,
category_id INT NOT NULL,
price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_products_categories
FOREIGN KEY (category_id)
REFERENCES categories(category_id)
ON DELETE CASCADE
ON UPDATE CASCADE
);
-- -----------------------------------------------------------------
-- Sample Data Insertion
-- -----------------------------------------------------------------
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Gadgets, devices, and electronic accessories'),
('Home Appliances', 'Appliances for home, kitchen, and living rooms'),
('Books & Stationery', 'Books, notebooks, and office supplies');
INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('Wireless Bluetooth Headphones', 1, 59.99, 120),
('4K Ultra HD Smart TV', 1, 499.00, 30),
('Gaming Laptop 16GB RAM', 1, 1199.50, 15),
('Microwave Oven 20L', 2, 85.00, 45),
('Ergonomic Office Chair', 2, 150.00, 20),
('SQL Database Design Guide', 3, 29.99, 200),
('Ballpoint Pens (Pack of 10)', 3, 4.50, 500);
-- -----------------------------------------------------------------
-- CRUD Operations Demo
-- -----------------------------------------------------------------
-- Update price & stock
UPDATE products SET price = 54.99, stock_quantity = 130 WHERE product_id = 1;
-- Delete a specific product
DELETE FROM products WHERE product_id = 7;
-- -----------------------------------------------------------------
-- Category-Wise Reports
-- -----------------------------------------------------------------

-- 1. Full Inventory Report
SELECT
p.product_id,
p.product_name,
c.category_name,
p.price,
p.stock_quantity,
(p.price * p.stock_quantity) AS stock_value
FROM products p
JOIN categories c ON p.category_id = c.category_id;
-- 2. Category Summary Report
SELECT
c.category_name,
COUNT(p.product_id) AS total_products,
ROUND(AVG(p.price), 2) AS avg_price,
SUM(p.stock_quantity) AS total_stock,
COALESCE(SUM(p.price * p.stock_quantity), 0.00) AS category_value
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;