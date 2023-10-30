SELECT NOW();

SELECT CURDATE();

SELECT CURTIME();

SELECT YEAR(NOW());

SELECT DAYNAME(NOW());

SELECT MONTHNAME(NOW());

SELECT EXTRACT(YEAR FROM NOW());

-- https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html

-- example
USE sql_store;
SELECT *
FROM orders
WHERE YEAR(order_date) = YEAR(NOW());

-- format
SELECT DATE_FORMAT(NOW(), '%M %d %Y');

SELECT TIME_FORMAT(NOW(), '%H:%i %p');

-- calculate
SELECT DATE_ADD(NOW(), INTERVAL 1 YEAR);