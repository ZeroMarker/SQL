USE sql_store;
SELECT
    order_id,
    order_date,
    IF(
        YEAR(order_date) = YEAR(DATE_SUB(NOW(), INTERVAL 4 YEAR)),
        'Active',
        'Archived'
    ) AS category
FROM orders;

USE sql_store;
SELECT
    product_id,
    name,
    COUNT(*) AS order_times,
    IF(
        COUNT(*) > 1,
        'Many times',
        'Once'
    ) AS frequency
FROM products
JOIN order_items USING (product_id)
GROUP BY product_id, name;