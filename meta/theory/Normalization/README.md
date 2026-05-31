# 数据库范式理论 (Database Normalization)

数据库范式是一组关系数据库设计的规范，用于减少数据冗余和避免更新异常。

[参考文章: Essentials SQL — Normalization](https://www.essentialsql.com/database-normalization/)

---

## 范式级别概览

| 范式 | 核心要求 | 解决的问题 |
|------|----------|------------|
| **1NF** | 属性原子性，不可再分 | 非原子值、重复组 |
| **2NF** | 消除部分函数依赖 | 部分依赖导致的数据冗余 |
| **3NF** | 消除传递函数依赖 | 传递依赖导致的更新异常 |
| **BCNF** | 每个决定因素都是候选键 | 3NF 未覆盖的特殊情况 |
| **4NF** | 消除多值依赖 | 多值依赖导致的数据冗余 |
| **5NF** | 消除连接依赖 | 连接依赖导致的冗余 |

---

## 1NF — 第一范式

**要求：** 表中的每个属性都是**原子值**（不可再分）。

| ❌ 违反 1NF（电话列包含多个值） | ✅ 符合 1NF |
|:--|:--|
| 客户 \| 电话 | 客户 \| 电话 |
| Alice \| 138xxx, 139xxx | Alice \| 138xxx |
| | Alice \| 139xxx |

```sql
-- ❌ 违反：一个字段存多个电话
CREATE TABLE customer (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    phones VARCHAR(100)  -- "138xxxx,139xxxx"
);

-- ✅ 符合：每个电话一行
CREATE TABLE customer_phone (
    customer_id INT,
    phone VARCHAR(20),
    PRIMARY KEY (customer_id, phone)
);
```

---

## 2NF — 第二范式

**前提：** 满足 1NF。
**要求：** 每个非主键列**完全依赖于**主键（消除部分依赖）。

适用于**联合主键**的表。

| ❌ 违反 2NF | 说明 |
|:--|:--|
| 订单明细表 (order_id, product_id, product_name, qty) | `product_name` 只依赖于 `product_id`，而不是 (order_id, product_id) |

```sql
-- ❌ 违反：product_name 只部分依赖于主键的一部分 (product_id)
CREATE TABLE order_detail (
    order_id INT,
    product_id INT,
    product_name VARCHAR(100),  -- 只依赖于 product_id
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- ✅ 符合：拆成两张表
CREATE TABLE product (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE order_detail (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);
```

---

## 3NF — 第三范式

**前提：** 满足 2NF。
**要求：** 没有**传递函数依赖**（非主键列不能依赖于另一个非主键列）。

即：X → Y → Z 是不允许的。

```sql
-- ❌ 违反：城市 → 省份，省份不依赖于学号
-- 学号 → 城市 → 省份（传递依赖）
CREATE TABLE student (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    province VARCHAR(50)  -- 只依赖于 city，而非 id
);

-- ✅ 符合：拆成字典表
CREATE TABLE city (
    name VARCHAR(50) PRIMARY KEY,
    province VARCHAR(50)
);
CREATE TABLE student (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    FOREIGN KEY (city) REFERENCES city(name)
);
```

---

## BCNF — 博伊斯-科德范式

**前提：** 满足 3NF。
**要求：** 对于每个函数依赖 X → Y，X 必须是**候选键**（超键）。

比 3NF 更严格，解决 3NF 未能处理的特殊情况。

---

## 4NF — 第四范式

**前提：** 满足 BCNF。
**要求：** 消除**多值依赖**（一个属性决定多个独立属性值）。

---

## 5NF — 第五范式（投影连接范式）

**前提：** 满足 4NF。
**要求：** 每个连接依赖都被候选键隐含。

---

## 实际建议

| 场景 | 建议范式 |
|------|----------|
| 大多数 OLTP 系统 | 3NF |
| 数据仓库 / OLAP | 星型模型（适度反范式） |
| 需要严格完整性 | BCNF |
| 高性能读场景 | 2NF + 适当冗余 |

> **经验法则：** 一般业务系统达到 3NF 即可满足大部分需求。过度范式化会导致查询性能下降。

---

## 延伸阅读

- 关系代数: [《Relation Algebra》](../Relation%20Algebra/relation.md)
- 事务隔离: [《Transaction》](../Transaction/transaction.md)
- [数据库设计课程 - Database Design Course](https://www.youtube.com/watch?v=ztHopE5Wnpc)
- [Learn Database Normalization - 1NF, 2NF, 3NF, 4NF, 5NF](https://www.youtube.com/watch?v=GFQaEYEc8_8)

