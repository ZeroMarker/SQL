# Oracle 🏛️

Oracle Database + PL/SQL 编程学习与实践

---

## 📂 目录结构

```
oracle/
├── PLSQL/               # PL/SQL 编程
│   ├── block.sql        # PL/SQL 块结构（DECLARE/BEGIN/EXCEPTION/END）
│   ├── hello.sql        # Hello World 示例
│   ├── datatype.sql     # 数据类型（%TYPE、%ROWTYPE、RECORD）
│   ├── select.sql       # SELECT INTO 查询
│   ├── square.sql       # 简单计算示例
│   ├── function/        # 函数
│   │   ├── function.sql       # 自定义函数示例
│   │   ├── call.sql           # 函数调用
│   │   └── try_parse.sql      # 解析尝试函数
│   └── procedure/       # 存储过程
│       └── procedure.sql      # 存储过程示例
├── query.sql            # Oracle 常用查询
├── start.sql            # 初始化 SQL
├── install.sh           # Docker 安装脚本
└── README.md
```

---

## 🐳 Docker 启动（Oracle Free）

### 官方镜像

```bash
# 拉取 Oracle Free 镜像
docker pull container-registry.oracle.com/database/free:latest

# 启动容器
docker run -d --name oracle \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=password \
  -v oracle-volume:/opt/oracle/oradata \
  container-registry.oracle.com/database/free:latest

# 进入 SQL*Plus
docker exec -it oracle sqlplus / as sysdba
```

### gvenzl 镜像（更轻量）

```bash
docker pull gvenzl/oracle-free

docker run -d --name oracle \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=password \
  -v oracle-volume:/opt/oracle/oradata \
  gvenzl/oracle-free

docker exec oracle resetPassword password
```

### 连接信息

| 字段 | 值 |
|------|-----|
| 用户名 | SYSTEM |
| 密码 | password |
| 角色 | SYSDBA |
| Service Name (官方) | FREE |
| Service Name (gvenzl) | FREEPDB1 |

---

## 📖 PL/SQL 入门

### 块结构

```sql
DECLARE
    -- 变量声明
    v_name VARCHAR2(50);
BEGIN
    -- 执行逻辑
    SELECT first_name INTO v_name FROM employees WHERE employee_id = 100;
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
EXCEPTION
    -- 异常处理
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee found');
END;
/
```

### 存储过程

```sql
CREATE OR REPLACE PROCEDURE raise_salary(p_emp_id NUMBER, p_amount NUMBER) IS
BEGIN
    UPDATE employees SET salary = salary + p_amount WHERE employee_id = p_emp_id;
    COMMIT;
END;
/
```

### 函数

```sql
CREATE OR REPLACE FUNCTION get_employee_name(p_emp_id NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(100);
BEGIN
    SELECT first_name || ' ' || last_name INTO v_name
    FROM employees WHERE employee_id = p_emp_id;
    RETURN v_name;
END;
/
```

---

## 🔗 参考资源

- [Oracle Tutorial](https://www.oracletutorial.com/)
- [Oracle PL/SQL Full Course](https://www.youtube.com/watch?v=yGU4YfSSjdM)
- [Oracle SQL for Beginners](https://www.youtube.com/watch?v=yukL9vRalVo)
- [Oracle Container Registry](https://container-registry.oracle.com/)
- [Oracle 23c Free with Docker](https://medium.com/oracledevs/oracle-database-23c-free-developer-release-for-java-developers-with-docker-on-windows-b164a7a61a91)

