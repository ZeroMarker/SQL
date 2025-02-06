USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS total_sales
FROM invoices
WHERE invoice_date > '2019-09-01'
GROUP BY client_id
ORDER BY total_sales DESC;

USE sql_invoicing;
SELECT
    p.date,
    pm.name AS payment_method,
    SUM(p.amount) AS total_payments
FROM payments p
JOIN payment_methods pm
ON p.payment_method = pm.payment_method_id
GROUP BY p.date, pm.name
ORDER BY p.date;

