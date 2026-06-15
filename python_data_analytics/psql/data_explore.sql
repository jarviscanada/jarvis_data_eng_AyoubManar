-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
SELECT COUNT(*) FROM retail;


-- number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT customer_id) FROM retail;


-- Invoice date range
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- Number of SKU/products (unique stock_code)
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- Average invoice amount (excluding negative amounts)
SELECT AVG(invoice_total)
FROM (
    SELECT invoice_no, SUM(unit_price * quantity) AS invoice_total
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(unit_price * quantity) > 0
) AS positive_invoices;

-- Total revenue
SELECT SUM(unit_price * quantity) FROM retail;

-- Total revenue by YYYYMM
SELECT
    (EXTRACT(YEAR FROM invoice_date)::INTEGER * 100 + EXTRACT(MONTH FROM invoice_date)::INTEGER) AS yyyymm,
    SUM(unit_price * quantity) AS revenue
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;
