CREATE [OR REPLACE] FUNCTION function_name [(
   parameter_1 [IN] [OUT] data_type,
   parameter_2 [IN] [OUT] data_type,
   parameter_N [IN] [OUT] data_type]
    RETURN return_data_type IS
--the declaration statements
BEGIN
   -- the executable statements
   return return_data_type;
EXCEPTION
-- the exception-handling statements
END;
/