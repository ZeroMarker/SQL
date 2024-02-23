-- subquery in select clause
USE sql_invoicing;
SELECT
    client_id,
    name,
    (
    SELECT SUM(invoice_total)
    FROM invoices i
    WHERE i.client_id = c.client_id
    ) AS total_sales,
    (
        SELECT AVG(invoice_total)
        FROM invoices
    ) AS average,
    (
        SELECT total_sales - average
    ) AS difference
FROM clients c;

-- from clause
SELECT *
FROM (
    SELECT
        client_id,
        name,
        (
            SELECT SUM(invoice_total)
            FROM invoices i
            WHERE i.client_id = c.client_id
        ) AS total_sales,
        (
            SELECT AVG(invoice_total)
            FROM invoices
        ) AS average,
        (
            SELECT total_sales - average
        ) AS difference
    FROM clients c
) as sales_summary -- use view alternative
WHERE total_sales IS NOT NULL;