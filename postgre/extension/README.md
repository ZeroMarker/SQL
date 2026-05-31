# PostgreSQL 扩展生态 🧩

PostgreSQL 最强大的特性之一就是**扩展机制** — 通过 Extension 可以在不修改内核的前提下增加新功能。

---

## 目录

| 文件 | 扩展 | 说明 |
|------|------|------|
| `postgis.md` | PostGIS | 地理空间数据类型与查询 |
| `pgvector.md` | pgvector | 向量相似度搜索（AI 嵌入） |
| `pg_stat_statements.md` | pg_stat_statements | 查询性能统计 |
| `pg_trgm.md` | pg_trgm | 模糊文本匹配 |
| `uuid.md` | uuid-ossp / pgcrypto | UUID 生成 |
| `hstore.md` | hstore | 键值对存储 |
| `citext.md` | citext | 大小写不敏感文本 |
| `pg_partman.md` | pg_partman | 自动分区管理 |

---

## 快速安装

```sql
-- 查看已安装的扩展
SELECT * FROM pg_extension;

-- 查看可用扩展
SELECT * FROM pg_available_extensions;

-- 安装扩展（需要超级用户权限）
CREATE EXTENSION IF NOT EXISTS <extension_name>;

-- 删除扩展
DROP EXTENSION IF EXISTS <extension_name>;
```

---

## 扩展分类

### 1. 数据类型扩展

| 扩展 | 新增数据类型 | 用途 |
|------|-------------|------|
| PostGIS | `geometry`, `geography`, `raster` | 地理空间 |
| pgvector | `vector` | 向量嵌入 |
| hstore | `hstore` | 键值对 |
| citext | `citext` | 大小写不敏感字符串 |
| pgcrypto | `pgp_sym_encrypt` 等 | 加密类型 |
| ip4r | `ip4`, `ip6`, `iprange` | IP 地址范围 |

### 2. 索引扩展

| 扩展 | 索引类型 | 加速场景 |
|------|---------|----------|
| btree_gin | GIN | 复合索引（数组+标量） |
| btree_gist | GiST | 范围类型+标量复合索引 |
| pg_trgm | GiST/GIN | LIKE '%xxx%' 模糊查询 |
| rum | RUM | 全文检索排序优化 |

### 3. 性能分析

| 扩展 | 功能 |
|------|------|
| pg_stat_statements | SQL 执行统计（频率、耗时、I/O） |
| pg_buffercache | 共享缓冲区使用情况 |
| pg_walinspect | WAL 日志分析 |
| auto_explain | 慢查询自动 EXPLAIN |
| pg_hint_plan | 手动控制查询计划 |

### 4. 运维与管理

| 扩展 | 功能 |
|------|------|
| pg_partman | 自动表分区管理 |
| pg_repack | 在线重建表（无锁） |
| pg_rewind | 快速同步旧主库 |
| pg_cron | 数据库内定时任务 |
| file_fdw | 外部文件查询（CSV/JSON） |

---

## 查看扩展信息

```sql
-- 所有已安装扩展及其版本
SELECT e.extname, e.extversion, n.nspname AS schema,
       e.extrelocatable, c.description
FROM pg_extension e
JOIN pg_namespace n ON n.oid = e.extnamespace
LEFT JOIN pg_description c ON c.objoid = e.oid
ORDER BY e.extname;
```

> 大部分扩展可以通过 `CREATE EXTENSION` 在线启用，无需重启数据库。
