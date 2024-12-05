SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
    n_x number;
    n_y number;
    n_z number;
BEGIN
    n_x := try_parse('574');
    n_y := try_parse('12.21');
    n_z := try_parse('abcd');

    DBMS_OUTPUT.PUT_LINE(n_x);
    DBMS_OUTPUT.PUT_LINE(n_y);
    DBMS_OUTPUT.PUT_LINE(n_z);
END;
/