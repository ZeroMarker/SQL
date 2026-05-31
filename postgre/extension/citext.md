# citext — 大小写不敏感文本 🔤

citext（Case-Insensitive Text）提供一种大小写不敏感的文本类型，比较时自动忽略大小写差异。

---

## 安装

```sql
CREATE EXTENSION citext;
```

---

## 基本用法

```sql
-- 建表
CREATE TABLE users (
    id       SERIAL PRIMARY KEY,
    username CITEXT UNIQUE,  -- 不区分大小写
    email    CITEXT UNIQUE,
    bio      TEXT
);

-- 写入
INSERT INTO users (username, email) VALUES
    ('Alice', 'Alice@Example.com'),
    ('BOB',   'BOB@TEST.ORG');

-- 查询自动忽略大小写
SELECT * FROM users WHERE username = 'alice';   -- 匹配 Alice
SELECT * FROM users WHERE username = 'bob';     -- 匹配 BOB
SELECT * FROM users WHERE email = 'alice@example.com';  -- 匹配

-- 唯一约束也忽略大小写
INSERT INTO users (username, email) VALUES ('alice', 'xxx'); -- ❌ 冲突
```

---

## 性能对比

```sql
-- 方案 A: citext（内置支持）
CREATE TABLE t1 (name CITEXT);
SELECT * FROM t1 WHERE name = 'Hello';  -- 自动忽略大小写

-- 方案 B: lower() 函数（传统做法）
CREATE TABLE t2 (name TEXT);
CREATE INDEX idx_t2_lower ON t2 (lower(name));
SELECT * FROM t2 WHERE lower(name) = 'hello';  -- 需手动 lower

-- 方案 C: ILIKE
SELECT * FROM t2 WHERE name ILIKE 'hello';  -- 无法使用普通索引
```

### 对比

| 方案 | 写法简洁 | 索引可用 | 性能 |
|------|---------|---------|------|
| citext | ✅ `=` | ✅ 普通 B-tree | ⚡ 最快（无函数调用） |
| lower() | ❌ 需包 lower | ✅ 函数索引 | ⚡ 好 |
| ILIKE | ✅ | ❌（需 pg_trgm） | 🐢 慢 |

---

## 注意事项

```sql
-- 1. 不能直接用作主键（上层应用可能用大小写生成 URL）
-- ❌ 不推荐
CREATE TABLE t (id CITEXT PRIMARY KEY);

-- 2. 排序规则也是大小写不敏感
SELECT username FROM users ORDER BY username;  -- a, B, C → Alice, BOB, ...

-- 3. 前缀匹配
SELECT * FROM users WHERE username LIKE 'ali%';  -- 匹配 Alice

-- 4. 模式匹配仍区分大小写（SIMILAR TO、POSIX 正则）
SELECT * FROM users WHERE username ~ '^ali';  -- ❌ 不匹配 Alice（正则区分大小写）

-- 5. citext 与 text 混合比较
SELECT username::text = 'Alice' FROM users;  -- ❌ 区分大小写（需转型）
```

---

## 应用场景

| 场景 | 推荐 |
|------|------|
| 用户名登录 | ✅ citext |
| Email 地址 | ✅ citext |
| 标签/分类 | ✅ citext |
| URL Slug | ❌ 保持原始大小写 |
| 密码哈希 | ❌ 二进制比较 |

---

## 🔗 参考

- [citext 官方文档](https://www.postgresql.org/docs/current/citext.html)
