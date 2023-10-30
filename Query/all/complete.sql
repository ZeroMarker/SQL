USE sql_invoicing;
SELECT *
FROM invoices
WHERE invoice_total > (
    SELECT MAX(invoice_total)
    FROM invoices
    WHERE client_id = 3
);

USE sql_invoicing;
SELECT *
FROM invoices
WHERE invoice_total > ALL (
    SELECT invoice_total
    FROM invoices
    WHERE client_id = 3
);

-- select client with at least two invoices

USE sql_invoicing;
SELECT *
FROM invoices
WHERE client_id IN (
    SELECT client_id
    FROM invoices
    GROUP BY client_id
    HAVING COUNT(*) >= 2
);

USE sql_invoicing;
SELECT *
FROM invoices
-- = ANY === IN
WHERE client_id = ANY (
    SELECT client_id
    FROM invoices
    GROUP BY client_id
    HAVING COUNT(*) >= 2
);

-- exists
USE sql_invoicing;
SELECT client_id
FROM clients c
WHERE EXISTS(
    SELECT client_id
    FROM invoices i
    WHERE  i.client_id = c.client_id
)

