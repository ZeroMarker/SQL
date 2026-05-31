# MySQL SELECT 查询子句

MySQL SELECT 查询各子句的练习文件，按学习顺序排列。

---

## 📂 文件列表

| 文件 | 子句 | 核心内容 |
|------|------|----------|
| `where.sql` | WHERE | 条件过滤：比较运算符、LIKE、REGEXP、IN、BETWEEN、IS NULL |
| `sort.sql` | ORDER BY | 排序：ASC/DESC、多列排序、自定义排序 |
| `join.sql` | JOIN | 多表连接：INNER JOIN、LEFT JOIN、RIGHT JOIN、自连接、跨库连接 |
| `group.sql` | GROUP BY | 分组聚合：GROUP BY 单列/多列、ROLLUP |
| `having.sql` | HAVING | 分组后过滤：HAVING vs WHERE 区别 |
| `aggregate.sql` | 聚合函数 | MAX / MIN / AVG / SUM / COUNT、DISTINCT 聚合、GROUP BY + 聚合 |
| `subquery.sql` | 子查询 | 标量子查询、行子查询、FROM 子查询、EXISTS / IN |
| `complete.sql` | 综合 | 多子句组合查询综合练习 |

---

## 📖 SELECT 语法速查

```sql
SELECT [DISTINCT] column, AGG_FUNC(column_or_expression), …
FROM mytable
    JOIN another_table ON mytable.column = another_table.column
WHERE constraint_expression
GROUP BY column
HAVING constraint_expression
ORDER BY column ASC / DESC
LIMIT count OFFSET COUNT;
```

## 🎯 推荐学习顺序

```
where → sort → join → group → having → aggregate → subquery → complete
```

1. **WHERE** — 基础条件过滤
2. **ORDER BY** — 结果排序
3. **JOIN** — 多表关联查询
4. **GROUP BY** — 分组统计
5. **HAVING** — 分组结果过滤
6. **聚合函数** — MAX/MIN/AVG/SUM/COUNT
7. **子查询** — 嵌套查询
8. **综合** — 多子句组合实战

---

> 所有 SQL 基于 Mosh 的 `sql_store` / `sql_invoicing` / `sql_inventory` 示例库，需要先执行 `MySQL/Mosh/SQL Course Materials/create-databases.sql` 导入数据。
