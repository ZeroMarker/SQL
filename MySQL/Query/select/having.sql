USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices
FROM invoices
-- WHERE invoice_date > '2019-09-01'
GROUP BY client_id
HAVING total_sales > 500
-- Must exist in select
ORDER BY total_sales DESC;

-- rollup
USE sql_invoicing;
SELECT
    c.state,
    c.city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients c USING (client_id)
GROUP BY state, city WITH ROLLUP;

USE sql_invoicing;
SELECT
    pm.name AS payment_method,
    SUM(p.amount) AS total
FROM payments p
JOIN payment_methods pm
ON p.payment_method = pm.payment_method_id
GROUP BY pm.name WITH ROLLUP;
