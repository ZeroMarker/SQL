USE sql_store;
INSERT INTO customers (
                       first_name,
                       last_name,
                       birth_date,
                       address,
                       city,
                       state
)
VALUES (
        'John',
        'Smith',
        '1990-09-01',
        'Address',
        'City',
        'CA'
        );

INSERT INTO shippers (name)
VALUES ('shipper1'),
       ('shipper2');

-- insert hierarchical rows
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '1990-09-03', 1);

INSERT INTO order_items
VALUES (LAST_INSERT_ID(), 1, 1, 2.95);

-- copy from table, without pk & auto increment
-- create table as
USE sql_store;
CREATE TABLE orders_archived AS
SELECT *
FROM orders;

USE sql_store;
INSERT INTO orders_archived
SELECT *
FROM orders
WHERE order_date < '2019-01-01';

USE sql_invoicing;
CREATE TABLE invoices_archived AS
SELECT
    i.invoice_id,
    i.invoice_date,
    i.payment_date,
    i.payment_total,
    i.number,
    c.name AS client
FROM invoices i
JOIN clients c
    USING (client_id)
WHERE i.payment_date IS NOT NULL;