-- Declare a variable to hold the input number and its square
DECLARE
    input_number NUMBER := 5;  -- Change this value to any number you like
    result_square NUMBER;
BEGIN
    -- Calculate the square of the input number
    result_square := input_number * input_number;

    -- Display the result
    DBMS_OUTPUT.PUT_LINE('The square of ' || input_number || ' is ' || result_square);
END;
/
