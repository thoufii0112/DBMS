create table payment(
Payment_ID int auto_increment,
Order_ID int NOT NULL,
Payment_Date timestamp default current_timestamp,
Payment_Mode varchar(100),
Payment_Status varchar(100),
Transaction_Amount decimal(10,2),


constraint pk_key primary key (Payment_ID),
constraint chk_amt CHECK(Transaction_Amount > 0),
constraint fk_key foreign key (Order_ID) references orders(Order_ID)
);

select * FROM Orders;

INSERT INTO payment(Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES 
(31, "Cash on delivery" , "Pending" , 7500),

(32, "UPI" , "Successfull" , 6500),

(33, "Credit card" , "Pending" , 500),

(34, "UPI" , "Failed" , 600),

(35, "Credit card" , "Failed" , 650),

(36, "Cash on delivery" , "Pending" , 500),

(37, "UPI" , "Successfull" , 6500),

(38, "Credit card" , "Failed" , 6000); 

select * FROM Payment;

-- Display all successful payment.

select * FROM payment where Payment_Status = "Successfull";

-- Find the Failed payment.

select * FROM payment where Payment_Status = "Failed";


-- Count total Successfull and Failed payment.

select
count(*) as Number_of_Transcation, Payment_Mode
from payment group by Payment_Mode;

select
count(*) as Number_of_Transcation, Payment_Status
from payment group by Payment_Status;

select * from payment where Payment_Status = "Failed";

-- UPdate failed payment after retry.

update payment set Payment_Status = "Successfull" where Payment_ID = 20;

-- Identify the pending transaction.

select * from payment where Payment_Status = "Pending";

-- REPORT 1: PAYMENT MODE ANALYSIS

-- Number of UPI transactions
SELECT COUNT(*) AS UPI_Transactions
FROM Payment
WHERE Payment_Mode = 'UPI';


-- Number of Card payments
SELECT COUNT(*) AS Card_Payments
FROM Payment
WHERE Payment_Mode = 'Credit card';


-- Most preferred payment method
SELECT Payment_Mode, COUNT(*) AS Number_of_Transactions
FROM Payment
GROUP BY Payment_Mode
ORDER BY Number_of_Transactions DESC
LIMIT 1;

-- REPORT 2: REVENUE ANALYSIS

-- Total revenue generated
SELECT SUM(Transaction_Amount) AS Total_Revenue
FROM Payment
WHERE Payment_Status = 'Successfull';


-- Revenue by payment method
SELECT
    Payment_Mode,
    SUM(Transaction_Amount) AS Revenue
FROM Payment
WHERE Payment_Status = 'Successfull'
GROUP BY Payment_Mode;


-- Average transaction amount
SELECT
    AVG(Transaction_Amount) AS Average_Transaction_Amount
FROM Payment
WHERE Payment_Status = 'Successfull';

-- REPORT 3: CUSTOMER PAYMENT HISTORY

SELECT
    c.Customer_Name,
    o.Order_ID,
    p.Payment_Mode,
    p.Transaction_Amount AS Amount,
    p.Payment_Status
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Payment p
    ON o.Order_ID = p.Order_ID
ORDER BY o.Order_ID;