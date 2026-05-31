# UUID 扩展 — 全局唯一标识符 🔑

PostgreSQL 提供多种 UUID 生成方案，适用于分布式系统、主键生成和加密场景。

---

## 安装

```sql
-- 二选一即可
CREATE EXTENSION "uuid-ossp";   -- uuid-ossp（传统）
CREATE EXTENSION pgcrypto;      -- pgcrypto（推荐，无需额外依赖）
```

---

## 生成 UUID

### pgcrypto（推荐，无外部依赖）

```sql
-- 随机 UUID v4（最常用）
SELECT gen_random_uuid();
-- 结果: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11

-- 批量生成
SELECT gen_random_uuid() FROM generate_series(1, 10);
```

### uuid-ossp（需编译依赖）

```sql
-- UUID v1 — 基于时间戳 + MAC 地址
SELECT uuid_generate_v1();
-- 结果: c7f3a0e0-3f1a-11ee-be56-0242ac120002

-- UUID v1mc — 基于时间戳 + 随机 MAC
SELECT uuid_generate_v1mc();

-- UUID v3 — 基于 MD5 哈希 + 命名空间
SELECT uuid_generate_v3(uuid_ns_url(), 'https://example.com');

-- UUID v4 — 随机 UUID
SELECT uuid_generate_v4();

-- UUID v5 — 基于 SHA-1 哈希 + 命名空间
SELECT uuid_generate_v5(uuid_ns_url(), 'https://example.com');
```

---

## 主键设计

### 方案一：UUID 做主键（推荐分布式）

```sql
CREATE TABLE users (
    id      UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name    TEXT NOT NULL,
    email   TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 插入自动生成 UUID
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');

-- 查看
SELECT * FROM users;
```

### 方案二：UUID 作为业务标识 + 自增主键

```sql
CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,           -- 内部自增
    public_id   UUID DEFAULT gen_random_uuid() UNIQUE,  -- 对外暴露
    user_id     UUID NOT NULL,
    amount      NUMERIC(10, 2),
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- 对外暴露 public_id，内部用 id 做 JOIN
CREATE INDEX idx_orders_public_id ON orders (public_id);
```

---

## UUID vs 自增 ID

| 特性 | SERIAL (自增) | UUID |
|------|-------------|------|
| 大小 | 4/8 字节 | 16 字节 |
| 全球唯一 | ❌ | ✅ |
| 可预测 | ✅（可遍历） | ❌（安全） |
| 合并数据 | 冲突风险 | ✅ 无冲突 |
| 索引性能 | ⚡ 更快（顺序插入） | 🐢 略慢（随机插入） |
| 分布式友好 | ❌ | ✅ |

> UUID 的主键索引碎片化问题可以通过 `uuid-ossp` 的 v1 版本（时间有序）缓解，或使用 **ULID / Snowflake** 方案。

---

## 相关扩展

```sql
-- 生成简短唯一 ID（类似 ULID）
-- 需要安装 pg_idkit 扩展
-- SELECT idkit_generate();

-- 使用 HASH 函数生成确定性 UUID
SELECT md5('hello')::uuid;  -- 基于内容哈希
```

---

## 🔗 参考

- [pgcrypto 官方文档](https://www.postgresql.org/docs/current/pgcrypto.html)
- [uuid-ossp 官方文档](https://www.postgresql.org/docs/current/uuid-ossp.html)
- [ULID: Universally Unique Lexicographically Sortable Identifier](https://github.com/ulid/spec)
