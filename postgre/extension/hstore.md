# hstore — 键值对存储 📋

hstore 为 PostgreSQL 添加半结构化键值对数据类型，适合存储可变属性的场景，JSON 普及前的主要方案。

---

## 安装

```sql
CREATE EXTENSION hstore;
```

---

## 基本用法

```sql
-- 创建 hstore 文本
SELECT 'a=>1, b=>2'::hstore;
SELECT '"key with space"=>"value with, comma"'::hstore;

-- 使用 hstore() 函数
SELECT hstore('key1', 'value1');
```

---

## 建表与写入

```sql
-- 建表
CREATE TABLE products (
    id       SERIAL PRIMARY KEY,
    name     TEXT NOT NULL,
    attrs    HSTORE  -- 可变属性（颜色、尺寸、重量...）
);

-- 写入数据
INSERT INTO products (name, attrs) VALUES
    ('T-Shirt', 'color=>red, size=>M, material=>cotton'),
    ('Laptop',  'brand=>Dell, cpu=>i7, ram=>16GB, storage=>512GB'),
    ('Coffee',  'weight=>250g, origin=>Columbia, roast=>medium');

-- 使用 hstore() 函数写入
INSERT INTO products (name, attrs) VALUES
    ('Mouse', hstore('brand', 'Logitech') || hstore('dpi', '1600'));
```

---

## 查询操作

```sql
-- 1. 获取单个键值
SELECT name, attrs -> 'color' AS color FROM products;

-- 2. 键值包含判断
SELECT name FROM products
WHERE attrs ? 'color';  -- 存在 color 键

-- 3. 多键判断
SELECT name FROM products
WHERE attrs ?& ARRAY['color', 'size'];  -- 同时存在

-- 4. 任意键存在
SELECT name FROM products
WHERE attrs ?| ARRAY['cpu', 'roast'];   -- 任一存在

-- 5. 按值过滤
SELECT name FROM products
WHERE attrs -> 'color' = 'red';

-- 6. 获取所有键
SELECT name, akeys(attrs) AS keys FROM products;

-- 7. 获取所有值
SELECT name, avals(attrs) AS values FROM products;

-- 8. 返回成对数组
SELECT name, each(attrs) AS kv FROM products;

-- 9. 统计键数量
SELECT name, count(attrs) AS attr_count FROM products;
```

---

## 更新操作

```sql
-- 添加/更新单个键
UPDATE products
SET attrs = attrs || '"in_stock"=>"true"'
WHERE name = 'T-Shirt';

-- 删除键
UPDATE products
SET attrs = attrs - 'color'
WHERE name = 'T-Shirt';

-- 批量删除键
UPDATE products
SET attrs = attrs - ARRAY['size', 'material']
WHERE name = 'T-Shirt';

-- 替换全部
UPDATE products
SET attrs = '"brand"=>"Apple", "model"=>"MacBook Pro"'
WHERE name = 'Laptop';
```

---

## 索引

```sql
-- GiST 索引（支持 ? / ?& / ?| 操作符）
CREATE INDEX products_attrs_gist ON products USING GIST (attrs);

-- GIN 索引（更快）
CREATE INDEX products_attrs_gin ON products USING GIN (attrs);
```

---

## hstore vs JSONB

| 特性 | hstore | JSONB |
|------|--------|-------|
| 值类型 | 仅字符串 | 任意 JSON 类型 |
| 嵌套 | ❌ | ✅ |
| 数组 | ❌ | ✅ |
| 索引 | GiST / GIN | GIN (更丰富) |
| 操作符 | 较少 | 丰富 |
| 性能 | ⚡ 略快 | 略慢 |
| 适用版本 | PG 8.3+ | PG 9.4+ |

> **建议：** 新项目直接使用 JSONB，hstore 主要用于兼容旧系统或极简键值场景。

---

## 🔗 参考

- [hstore 官方文档](https://www.postgresql.org/docs/current/hstore.html)
- [JSONB 官方文档](https://www.postgresql.org/docs/current/datatype-json.html)
