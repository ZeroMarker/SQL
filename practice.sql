select table_name, table_rows from information_schema.TABLES
where table_schema='lanqiao' and table_rows > 0;

SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%wild%';