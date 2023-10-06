-- update single row
USE sql_invoicing;
UPDATE invoices
SET payment_total = 10, payment_date = '2019-01-01'
WHERE invoice_id = 1