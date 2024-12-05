SELECT USER_ID,username FROM dba_users;

alter session set "_ORACLE_SCRIPT"=true;

create user core identified by core;

grant connect, resource to core;

CREATE TABLE product (
                         product_id NUMBER PRIMARY KEY,
                         product_name VARCHAR2(100) NOT NULL,
                         price NUMBER(10,2) NOT NULL,
                         quantity_in_stock NUMBER
    -- Add more columns as needed
);

