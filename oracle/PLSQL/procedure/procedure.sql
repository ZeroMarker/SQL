CREATE OR REPLACE PROCEDURE adjust_salary(
    in_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE,
    in_percent IN NUMBER
) IS
BEGIN
    -- update employee's salary
    UPDATE employees
    SET salary = salary + salary * in_percent / 100
    WHERE employee_id = in_employee_id;
END;