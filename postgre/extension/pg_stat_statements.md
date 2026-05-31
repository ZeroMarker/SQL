# pg_stat_statements — 查询性能统计 📊

PostgreSQL 内置的性能分析扩展，记录 SQL 执行的统计信息，帮助定位慢查询。

---

## 安装

```sql
-- 1. 修改 postgresql.conf
-- shared_preload_libraries = 'pg_stat_statements'
-- track_activity_query_size = 2048

-- 2. 重启数据库后创建扩展
CREATE EXTENSION pg_stat_statements;
```

---

## 核心视图

```sql
-- 查看当前统计
SELECT * FROM pg_stat_statements;
```

### 关键字段

| 字段 | 说明 |
|------|------|
| `queryid` | 查询指纹哈希 |
| `query` | 规范化后的 SQL 文本 |
| `calls` | 执行次数 |
| `total_exec_time` | 总耗时 (ms) |
| `mean_exec_time` | 平均耗时 (ms) |
| `min_exec_time` | 最短耗时 |
| `max_exec_time` | 最长耗时 |
| `rows` | 返回总行数 |
| `shared_blks_hit` | 缓存命中块数 |
| `shared_blks_read` | 磁盘读取块数 |
| `blk_read_time` | 磁盘 I/O 耗时 |
| `local_blks_written` | 临时文件写入 |

---

## 常用分析查询

```sql
-- 1. 最慢的查询（按总耗时）
SELECT queryid,
       left(query, 80) AS query_preview,
       calls,
       round(total_exec_time::numeric, 2) AS total_ms,
       round(mean_exec_time::numeric, 2) AS avg_ms,
       round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS pct
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat%'
ORDER BY total_exec_time DESC
LIMIT 10;

-- 2. 最频繁执行的查询
SELECT queryid,
       left(query, 80) AS query_preview,
       calls,
       round(mean_exec_time::numeric, 2) AS avg_ms,
       round(calls::numeric / extract(epoch FROM now() - min(now()) OVER ()) * 3600, 2) AS calls_per_hour
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- 3. I/O 最密集的查询
SELECT queryid,
       left(query, 80) AS query_preview,
       calls,
       shared_blks_read,
       round(shared_blks_read::numeric / NULLIF(calls, 0), 2) AS blks_per_call,
       round(blk_read_time::numeric, 2) AS io_time_ms
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 10;

-- 4. 缓存命中率低的查询
SELECT queryid,
       left(query, 80) AS query_preview,
       calls,
       round(100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0), 2) AS cache_hit_pct
FROM pg_stat_statements
WHERE shared_blks_read > 100
ORDER BY cache_hit_pct ASC
LIMIT 10;

-- 5. 返回数据量最多的查询
SELECT queryid, left(query, 80) AS query_preview,
       calls, rows,
       round(rows::numeric / NULLIF(calls, 0), 2) AS rows_per_call
FROM pg_stat_statements
ORDER BY rows DESC
LIMIT 10;

-- 6. 临时文件写入（排序溢出）
SELECT queryid, left(query, 80) AS query_preview,
       calls,
       local_blks_written,
       temp_blks_written,
       round(temp_blks_written::numeric / NULLIF(calls, 0), 2) AS temp_per_call
FROM pg_stat_statements
WHERE temp_blks_written > 0
ORDER BY temp_blks_written DESC
LIMIT 10;
```

---

## 管理与维护

```sql
-- 重置统计
SELECT pg_stat_statements_reset();

-- 重置特定查询
SELECT pg_stat_statements_reset(queryid);

-- 查看 pg_stat_statements 配置
SELECT name, setting, unit FROM pg_settings
WHERE name LIKE '%pg_stat_statements%';

-- 只跟踪特定用户
-- pg_stat_statements.track = 'top'    -- 只跟踪顶层 SQL（默认）
-- pg_stat_statements.track = 'all'    -- 跟踪所有 SQL
-- pg_stat_statements.track_utility = false  -- 不跟踪工具命令
```

---

## 调优实战流程

```
1. 查慢查询 SQL     ← pg_stat_statements ORDER BY total_exec_time DESC
       ↓
2. EXPLAIN ANALYZE  ← 查看查询计划
       ↓
3. 检查索引缺失     ← seq_scan 多的表
       ↓
4. 优化 SQL / 加索引
       ↓
5. 验证效果         ← pg_stat_statements_reset() 后对比
```

---

## 🔗 参考

- [pg_stat_statements 官方文档](https://www.postgresql.org/docs/current/pgstatstatements.html)
- [PostgreSQL 性能调优指南](https://wiki.postgresql.org/wiki/Performance_Optimization)
