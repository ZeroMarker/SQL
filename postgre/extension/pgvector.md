# pgvector — 向量相似度搜索 🔢

pgvector 为 PostgreSQL 添加向量数据类型和相似度搜索，支持 **AI 嵌入向量**的存储与检索（LLM、图片、音频等）。

---

## 安装

```sql
CREATE EXTENSION vector;

-- 查看版本
SELECT extversion FROM pg_extension WHERE extname = 'vector';
```

> 注意：pgvector 需要编译安装（非纯 SQL 扩展），详见下方 Docker 部署方式。

### Docker 快速使用

```bash
# 带 pgvector 的镜像
docker pull pgvector/pgvector:pg16
docker run --name pgvector -p 5432:5432 \
  -e POSTGRES_PASSWORD=password \
  -d pgvector/pgvector:pg16
```

---

## 核心数据类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `vector(n)` | n 维浮点向量 | `[0.1, 0.2, 0.3, ...]` |
| `halfvec(n)` | 半精度浮点 | 内存减半 |
| `bit(n)` | 二进制向量 | `[1,0,1,1]` |
| `sparsevec(n)` | 稀疏向量 | 大量零值的向量 |

---

## 建表与索引

```sql
-- 建表（存储文本嵌入）
CREATE TABLE documents (
    id      SERIAL PRIMARY KEY,
    title   TEXT,
    content TEXT,
    embedding VECTOR(1536)  -- OpenAI embedding 维度
);

-- 创建索引（加速近似最近邻搜索）
-- IVFFlat：速度更快，适合大型数据集
CREATE INDEX idx_doc_embedding ON documents
  USING IVFFLAT (embedding vector_cosine_ops)
  WITH (lists = 100);  -- 列表数 √N

-- HNSW：精度更高，适合高维向量
CREATE INDEX idx_doc_hnsw ON documents
  USING HNSW (embedding vector_cosine_ops);
```

### 索引操作符

| Operator Class | 距离函数 | 适用场景 |
|---------------|----------|----------|
| `vector_l2_ops` | L2 距离（欧氏） | 图像/音频嵌入 |
| `vector_ip_ops` | 内积（点积） | 归一化向量 |
| `vector_cosine_ops` | 余弦距离 | 文本嵌入（最常用） |

---

## 写入数据

```sql
-- 插入带向量的文档
INSERT INTO documents (title, content, embedding) VALUES
    ('PostgreSQL 教程', 'PostgreSQL 是一个强大的开源数据库...',
     '[0.012, 0.045, -0.032, ...]'::vector),
    ('机器学习入门', '机器学习是人工智能的核心领域...',
     '[0.098, -0.012, 0.076, ...]'::vector),
    ('数据库设计范式', '数据库范式是关系数据库设计的基础...',
     '[0.034, 0.089, -0.021, ...]'::vector);

-- 批量插入（使用 COPY 或 INSERT ... VALUES）
```

---

## 向量搜索

```sql
-- 1. 余弦相似度（最常用）
SELECT id, title,
       1 - (embedding <=> '[0.05, 0.03, -0.01, ...]'::vector) AS similarity
FROM documents
ORDER BY embedding <=> '[0.05, 0.03, -0.01, ...]'::vector
LIMIT 10;

-- 2. L2 距离（越小越相似）
SELECT id, title,
       embedding <-> '[0.05, 0.03, -0.01, ...]'::vector AS distance
FROM documents
ORDER BY distance
LIMIT 10;

-- 3. 内积（越大越相似，需归一化向量）
SELECT id, title,
       embedding <#> '[0.05, 0.03, -0.01, ...]'::vector AS dot_product
FROM documents
ORDER BY dot_product DESC
LIMIT 10;

-- 4. 带阈值过滤
SELECT id, title, content
FROM documents
WHERE embedding <=> '[0.05, 0.03, -0.01, ...]'::vector < 0.5  -- 相似度 > 0.5
ORDER BY embedding <=> '[0.05, 0.03, -0.01, ...]'::vector
LIMIT 10;
```

### 距离操作符速查

| 操作符 | 说明 | 越小表示 |
|--------|------|----------|
| `<->` | L2 距离 | 越相似 |
| `<#>` | 负内积（-dot） | 越相似（负值越大越不相似） |
| `<=>` | 余弦距离 (1 - cos) | 越相似 |

---

## 高级用法

### 混合搜索（向量 + 关键词）

```sql
-- 结合全文检索
SELECT id, title,
       1 - (embedding <=> '[0.05, ...]'::vector) AS vector_score,
       ts_rank(to_tsvector('english', content), plainto_tsquery('数据库')) AS text_score,
       0.7 * (1 - (embedding <=> '[0.05, ...]'::vector)) +
       0.3 * ts_rank(to_tsvector('english', content), plainto_tsquery('数据库')) AS combined_score
FROM documents
WHERE to_tsvector('english', content) @@ plainto_tsquery('数据库')
   OR embedding <=> '[0.05, ...]'::vector < 0.6
ORDER BY combined_score DESC
LIMIT 10;
```

### 按类别过滤

```sql
-- 先过滤类别，再向量搜索
SELECT id, title, category
FROM documents
WHERE category = 'tech'  -- 传统索引过滤
ORDER BY embedding <=> '[0.05, ...]'::vector
LIMIT 10;
```

---

## 性能建议

| 场景 | 推荐索引 | 参数建议 |
|------|---------|----------|
| < 100K 行 | IVFFlat | lists = √N (e.g. 100K → 316) |
| 100K ~ 1M 行 | IVFFlat | lists = √N, probes ≥ 10 |
| > 1M 行 | HNSW | ef_construction = 200, ef_search = 500 |
| 高精度要求 | HNSW | ef_construction = 400, ef_search = 800 |

```sql
-- 调整搜索精度（IVFFlat）
SET ivfflat.probes = 10;  -- 默认 1，越大越精确但越慢

-- HNSW 搜索精度
SET hnsw.ef_search = 200;  -- 越大越精确
```

---

## 与 AI 框架集成

```python
# LangChain + pgvector
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import PGVector

CONNECTION_STRING = "postgresql://user:pass@localhost:5432/vectordb"

vector_store = PGVector.from_documents(
    documents=docs,
    embedding=OpenAIEmbeddings(),
    connection_string=CONNECTION_STRING,
)
```

---

## 🔗 参考

- [pgvector GitHub](https://github.com/pgvector/pgvector)
- [pgvector 文档](https://github.com/pgvector/pgvector#usage)
- [pgvector-python](https://github.com/pgvector/pgvector-python)
- [pgvector-node](https://github.com/pgvector/pgvector-node)
