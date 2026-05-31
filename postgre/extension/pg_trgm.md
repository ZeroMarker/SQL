# pg_trgm — 模糊文本匹配 🔍

pg_trgm 基于 trigram（三元组）实现强大的模糊字符串匹配，支持 LIKE 加速、相似度排序和正则搜索。

---

## 安装

```sql
CREATE EXTENSION pg_trgm;
```

---

## 核心函数

### 相似度计算

```sql
-- 1. 两个字符串的相似度（0 ~ 1）
SELECT similarity('hello world', 'hello word');   -- 0.833
SELECT similarity('hello', 'hallo');              -- 0.4

-- 2. 显示 trigram 分解
SELECT show_trgm('hello');
-- {" he","ell","hel","llo","lo "}

-- 3. 单词相似度（word_similarity）
-- 一个词是否包含在另一个词中
SELECT word_similarity('hello', 'hello world');   -- 1.0
SELECT word_similarity('world', 'hello world');   -- 1.0
SELECT word_similarity('hlo', 'hello');           -- 0.6

-- 4. 严格单词相似度（strict_word_similarity）
SELECT strict_word_similarity('hello', 'hello world');
```

---

## 索引加速

pg_trgm 提供 GiST 和 GIN 两种索引，用于加速 LIKE 和相似度查询。

```sql
-- 创建示例表
CREATE TABLE articles (
    id    SERIAL PRIMARY KEY,
    title TEXT,
    body  TEXT
);

-- GiST 索引（适合相似度排序）
CREATE INDEX articles_title_gist ON articles USING GIST (title gist_trgm_ops);

-- GIN 索引（适合精确匹配、更快相等查询）
CREATE INDEX articles_title_gin ON articles USING GIN (title gin_trgm_ops);

-- GIN 比 GiST 快 2-3x，但更新更慢、空间更大
```

---

## 查询示例

```sql
-- 1. 模糊搜索（加速 LIKE）
SELECT * FROM articles
WHERE title LIKE '%postgre%';

-- 2. 按相似度排序（模糊匹配）
SELECT id, title,
       similarity(title, 'postgresql tutorial') AS sim
FROM articles
WHERE similarity(title, 'postgresql tutorial') > 0.3
ORDER BY sim DESC
LIMIT 10;

-- 3. 近似匹配（使用 % 操作符）
SELECT * FROM articles
WHERE title % 'postgresql tutorial'
ORDER BY similarity DESC;

-- 4. LIKE + 相似度排序
SELECT id, title,
       similarity(title, 'database design') AS sim
FROM articles
WHERE title ILIKE '%database%'
ORDER BY sim DESC;

-- 5. 自动纠正拼写
SELECT word, similarity(word, 'posgresql') AS sim
FROM (
    VALUES ('postgresql'), ('postgres'), ('mysql'),
           ('oracle'), ('sqlite'), ('mongodb')
) AS dict(word)
WHERE similarity(word, 'posgresql') > 0.3
ORDER BY sim DESC;
```

---

## 操作符速查

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `%` | 相似度超过 threshold | `'hello' % 'hallo'` |
| `<%` | word_similarity | `'hello' <% 'hello world'` |
| `%>>` | strict_word_similarity | `'hello' %> 'hello'` |
| `<=>` | 距离 (1 - similarity) | 排序用 |

---

## 配置

```sql
-- 查看/设置相似度阈值（默认 0.3）
SHOW pg_trgm.similarity_threshold;
SET pg_trgm.similarity_threshold = 0.4;  -- 更严格

-- 限制 trigram 最大长度（默认 0 = 不限制）
SHOW pg_trgm.word_similarity_threshold;
```

---

## 索引性能对比

| 索引类型 | 查询速度 | 写入速度 | 磁盘空间 | 适用场景 |
|---------|---------|---------|---------|----------|
| GIN | ⚡ 最快 | 🐢 慢 | 📦 大 | 大量精确/模糊搜索 |
| GiST | 🐢 较慢 | ⚡ 快 | 📦 小 | 少量写入 + 相似度排序 |

> 经验法则：读多写少用 GIN，写多读少用 GiST。

---

## 🔗 参考

- [pg_trgm 官方文档](https://www.postgresql.org/docs/current/pgtrgm.html)
- [PostgreSQL 模糊搜索最佳实践](https://www.postgresql.org/docs/current/textsearch.html)
