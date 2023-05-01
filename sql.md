## SQL

Structured Query Language

## Relative Database

### Database Normal Form

- 1NF
Every elements of the table is atomic, meanwhile is undivided.

- 2NF
Other key is only depended the primary key.

- 3NF
There not exists function dependency of the X -> Y -> Z.

- BCNF

- 4NF

- 5Nf


## Keyword

- where
- not
- between and
- in()
- like%_
- distinct
- order by ASC/DESC
- limit
- offset
- join on
- inner
- left
- right
- full
- is
- and
- or
- as
- count
- min
- max
- avg
- sum
- group by
- having
- insert into
- values
- update
- set
- delete from
- create table
- alter table
- add
- (subqueries)
- union
- union all
- intersect
- except


## SQL DML && DDL

DML

    SELECT - 从数据库表中获取数据
    UPDATE - 更新数据库表中的数据
    DELETE - 从数据库表中删除数据
    INSERT INTO - 向数据库表中插入数据
    SQL 的数据定义语言 (DDL) 部分使我们有能力创建或删除表格。我们也可以定义索引（键），规定表之间的链接，以及施加表间的约束。

DDL

    CREATE DATABASE
    ALTER DATABASE
    CREATE TABLE
    ALTER TABLE
    DROP TABLE
    CREATE INDEX
    DROP INDEX
#### primary key
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    PRIMARY KEY (Id_P)
    )
## Query
    SELECT DISTINCT column, AGG_FUNC(column_or_expression), …
    FROM mytable
        JOIN another_table
          ON mytable.column = another_table.column
        WHERE constraint_expression
        GROUP BY column
        HAVING constraint_expression
        ORDER BY column ASC/DESC
        LIMIT count OFFSET COUNT;
        use world;
        select * 
        -- select Name
        -- select distinct Name
        from city
        where CountryCode = 'NLD' OR CountryCode = 'AFG'
        order by Population
        limit 30;
---
    create database myDatabase
    use myDatabase;
    create table movies(
        ID int(40) NOT NULL unique,
        Code varchar(15),
        actress varchar(63),
        Title varchar(255),
        Tags varchar(255),
        Length int(7),
        magnet varchar(255),
        primary key(ID)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;
---
    use myDatabase;
    create table actress(
        ID INT UNSIGNED AUTO_INCREMENT,
        Name varchar(255),
        Brithday date,
        Height varchar(255),
        Cup varchar(255),
        Place varchar(255),
        primary key(ID)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;
---
    use myDatabase;
    insert into movies (ID, Date ,Title, rTitle, Cateory, Series, Link)
        values
        (1,'2018-06-06','金秘书为何那样','김비서가 왜 그럴까','喜剧 / 爱情',60,'https://movie.douban.com/subject/30181455/')
---
    select * 
    from customers
    where state = 'VA' OR state = 'FL' OR state = 'GA'
    -- WHERE state IN ('VA', 'FL', 'GA')
    -- WHERE state NOT IN

    SELECT * 
    FROM customers
    WHERE points BETWEEN 3000 AND 1000

    SELECT * 
    FROM customers
    WHERE LIKE 'b%' --- '%b%' 
    -- % any number character

    WHERE LIKE '_y'
    -- _ single character

    -- NOT LIKE

    WHERE last_name REGEXP 'field' | '^field' | 'field$' | 'field|mac|rose' | '[gim]e' | '[a-h]e'
    REGEXP
    -- ^ begining
    -- $ end
    -- | or
    -- [abcd] single character
    -- [a-h] range

    -- ORDER BY
    -- ORDER BY state DESC
    -- ORDER BY state, first_name //order state then order first_name
    -- ORDER BY state DESC, first_name DESC

    -- LIMIT 3 //end
    -- LIMIT 6, 3 //jump 6 records
    -- LIMIT 5 OFFSET 5 // 6:10

    -- inner joins
    SELECT *
    FROM orders o --short
    INNER JOIN customers
        ON orders.customer_id = customers.customer_id
    
    -- joins across database
    SELECT*
    FROM order_items oi
    JOIN sql_inventory.porduct p
        ON oi.product_id = p.product_id

    -- self joins
    USE sql_hr;

    SELECT *
    FROM employees e
    JOIN employees m
        ON e.reports_id = m.employee_id

    -- joins multiple table
    SELECT *
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
    JOIN order_statuses os
    ON o.status = os.order_status_id

## Transaction

ACID

- Atomicity
- Consistency
- Isolation
- Durability

begin;      // start a transaction

commit;     // commit transaction

rollback;   // undo

SET AUTOCOMMIT=0    // prevent auto commit

### Isolation

Isolation Level

- Read Uncommitted
- Read Committed
- Repeatable Read // default value
- Serializable

SELECT @@TRANSACTION_ISOLATION

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

## Index
