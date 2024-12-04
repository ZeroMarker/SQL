CREATE OR REPLACE FUNCTION try_parse(
    iv_number IN VARCHAR2)
  RETURN NUMBER IS
BEGIN
RETURN to_number(iv_number);
EXCEPTION
     WHEN others THEN
        RETURN NULL;
END;