-- inner joins
USE sql_store;
SELECT *, o.customer_id
FROM orders o -- short
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- joins across database
USE sql_store;
SELECT *
FROM order_items oi
JOIN sql_inventory.products p
    ON oi.product_id = p.product_id;

-- self joins
USE sql_hr;

SELECT *
FROM employees e
JOIN employees m
    ON e.reports_to = m.employee_id;

-- joins multiple table
USE sql_store;
SELECT o.order_id,
       o.order_date,
       c.first_name,
       c.last_name,
       os.name AS status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_statuses os
    ON o.status = os.order_status_id;

-- compound join
USE sql_store;
SELECT *
FROM order_items oi
JOIN order_item_notes oin
    ON oi.order_id = oin.order_id
    AND oi.product_id = oin.product_id;

-- Implicit join !!! not recommend
USE sql_store;
SELECT *
FROM customers c, orders o
WHERE o.customer_id = c.customer_id;


-- Outer join
USE sql_store;
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- Outer join multiple table
-- try use left join, avoid use right join
USE sql_store;
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    sh.name AS shipper
FROM customers c
         LEFT JOIN orders o
                   ON c.customer_id = o.customer_id
LEFT JOIN shippers sh
    ON o.shipper_id = sh.shipper_id
ORDER BY c.customer_id;

SELECT
    o.order_id,
    o.order_date,
    c.first_name AS customer,
    sh.name AS shipper,
    os.name AS status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN shippers sh
ON o.shipper_id = sh.shipper_id
LEFT JOIN order_statuses os
ON o.status = os.order_status_id

-- self outer join
USE sql_hr;

SELECT *
FROM employees e
        LEFT JOIN employees m
              ON e.reports_to = m.employee_id;

-- using
USE sql_store;
SELECT
    o.order_id,
    o.order_date,
    c.first_name AS customer,
    sh.name AS shipper
FROM orders o
JOIN customers c
    USING (customer_id)
LEFT JOIN shippers sh
    USING (shipper_id);

USE sql_store;
SELECT *
FROM order_items oi
         JOIN order_item_notes oin
              USING (order_id, product_id)

-- natural join
USE sql_store;
SELECT
    o.order_id,
    c.first_name AS customer
FROM orders o
         NATURAL JOIN customers c;

-- cross join
USE sql_store;
SELECT
    c.first_name AS customer,
    p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name;

USE sql_store;
SELECT
    c.first_name AS customer,
    p.name AS product
FROM customers c, products p
ORDER BY c.first_name;

