-- sql_hr
-- Find all employees earn more than average
USE sql_hr;
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- Find all products that have never  been ordered
USE sql_store;
SELECT *
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
    )