SET SERVEROUTPUT ON SIZE 1000000;
/*  For DataGrip,
    right-click console
    enable serverout
 */
DECLARE
    -- variable declaration
    message  varchar2(20):= 'Hello, World!';

BEGIN
    /*
    *  PL/SQL executable statement(s)
    */
    dbms_output.put_line(message);
END;
/