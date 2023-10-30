USE sql_invoicing;
CREATE VIEW sales_by_client AS
    SELECT
        client_id,
        name,
        SUM(invoice_total) AS total_sales
    FROM clients c
    JOIN invoices i USING (client_id)
    GROUP BY client_id, name;

USE sql_invoicing;
SELECT *
FROM sales_by_client
ORDER BY total_sales DESC;

-- drop
USE sql_invoicing;
DROP VIEW sales_by_client;

-- update
USE sql_invoicing;
CREATE OR REPLACE VIEW sales_by_client AS
    SELECT
        client_id,
        name,
        SUM(invoice_total) AS total_sales
    FROM clients c
             JOIN invoices i USING (client_id)
    GROUP BY client_id, name;

-- updatable view
CREATE OR REPLACE VIEW invoice_with_balances AS
    SELECT
        invoice_id,
        number,
        client_id,
        invoice_total,
        invoice_total - payment_total AS balance,
        payment_total,
        invoice_date,
        due_date,
        payment_date
    FROM invoices
    WHERE (invoice_total - payment_total) > 0;

DELETE FROM invoice_with_balances
WHERE invoice_id = 2;
