-- SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
    v_first_name EMPLOYEES.FIRST_NAME%TYPE;
    v_last_name EMPLOYEES.LAST_NAME%TYPE;
    n_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE;
    d_hire_date EMPLOYEES.HIRE_DATE%TYPE;
BEGIN
    SELECT employee_id,
           first_name,
           last_name,
           hire_date
    INTO n_employee_id,
        v_first_name,
        v_last_name,
        d_hire_date
    FROM employees
    WHERE employee_id = 200;

    DBMS_OUTPUT.PUT_LINE(v_first_name);
    DBMS_OUTPUT.PUT_LINE(v_last_name);
    DBMS_OUTPUT.PUT_LINE(d_hire_date);
END;
/