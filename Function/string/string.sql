SELECT UPPER('sky');

SELECT LOWER('Sky');

SELECT LTRIM('  sky');

SELECT RTRIM('  sky ');

SELECT TRIM('  sky  ');

SELECT LEFT('Kindergarten', 4);

SELECT SUBSTRING('Kindergarten', 4, 4);

SELECT LOCATE('q','Kindergarten'); -- get 0

SELECT REPLACE('Kindergarten', 'garten', 'garden');

SELECT CONCAT('first', 'last');

-- https://dev.mysql.com/doc/refman/8.0/en/string-functions.html