-- ORDER BY
-- ORDER BY state DESC
-- ORDER BY state, first_name //order state then order first_name
-- ORDER BY state DESC, first_name DESC
SELECT first_name, last_name
FROM Customers
ORDER BY 1, 2
-- order by first_name then last_name

-- LIMIT 3 //end
-- LIMIT 6, 3 //jump 6 records
-- LIMIT 5 OFFSET 5 // 6:10