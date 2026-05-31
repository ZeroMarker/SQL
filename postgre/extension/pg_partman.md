# pg_partman — 自动分区管理 📂

pg_partman 自动管理 PostgreSQL 的表分区（Partitioning），按时间或数字范围自动创建/维护分区子表。

---

## 安装

```sql
-- 需要先确保表分区功能已启用
CREATE EXTENSION pg_partman;
```

> 注意：需要先安装 pg_partman 到操作系统中（apt install postgresql-16-partman / 或编译安装）。

---

## 核心概念

| 概念 | 说明 |
|------|------|
| **父表** | 逻辑表，不存数据 |
| **子表** | 实际存储数据的分区 |
| **模板表** | 定义分区的默认结构（索引、默认值等） |
| **前置分区** | 提前创建的将来分区数量 |
| **保留策略** | 自动删除过期分区 |

---

## 配置前置

```sql
-- pg_partman 需要自己的 schema
CREATE SCHEMA partman;

-- 设置维护角色
CREATE ROLE partman_user WITH LOGIN;
GRANT ALL ON SCHEMA partman TO partman_user;
GRANT ALL ON ALL TABLES IN SCHEMA partman TO partman_user;

-- 授予分区管理权限给维护用户
GRANT CREATE ON SCHEMA public TO partman_user;
```

---

## 创建分区表

### 1. 时间分区（推荐）

```sql
-- 创建父表
CREATE TABLE events (
    id         SERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    user_id    INT,
    event_type TEXT,
    payload    JSONB
) PARTITION BY RANGE (event_time);

-- 使用 pg_partman 自动创建分区
SELECT partman.create_parent(
    p_parent_table   := 'public.events',
    p_control        := 'event_time',      -- 分区列
    p_type           := 'native',          -- 原生分区
    p_interval       := '1 day',           -- 每天一个分区
    p_premake        := 7,                 -- 提前创建 7 天
    p_start_partition := '2024-01-01'      -- 起始日期
);

-- 查看生成的分区
SELECT child_schema || '.' || child_table AS partition_name
FROM partman.part_config_sub
WHERE parent_table = 'public.events';
```

### 2. 按 ID 分区

```sql
CREATE TABLE orders (
    id         BIGSERIAL,
    user_id    INT,
    amount     NUMERIC(10,2),
    created_at TIMESTAMPTZ
) PARTITION BY RANGE (id);

SELECT partman.create_parent(
    p_parent_table := 'public.orders',
    p_control      := 'id',
    p_type         := 'native',
    p_interval     := '1000000',     -- 每 100 万一个分区
    p_premake      := 3
);
```

---

## 维护

### 自动维护（推荐）

```sql
-- 在 pg_cron 中设置每小时的维护任务
SELECT cron.schedule('partman-maintenance', '0 * * * *',
    $$SELECT partman.run_maintenance()$$
);
```

### 手动维护

```sql
-- 手动创建新分区
SELECT partman.create_partition_time(
    p_parent_table := 'public.events',
    p_creation     := now() + interval '7 days'
);

-- 手动或使用 cron 定时调用
SELECT partman.run_maintenance();
```

---

## 保留与清理

```sql
-- 查看当前配置
SELECT parent_table, control, partition_interval, premake, retention
FROM partman.part_config;

-- 设置保留策略（保留 90 天）
UPDATE partman.part_config
SET retention = '90 days',
    retention_keep_table = false   -- 删除过期分区
WHERE parent_table = 'public.events';

-- 手动清理过期分区
SELECT partman.cleanup_time(
    p_parent_table := 'public.events',
    p_retention    := '90 days'
);

-- 取消自动删除（仅取消子表与父表的关联）
UPDATE partman.part_config
SET retention_keep_table = true;
```

---

## 自动创建索引

```sql
-- 在模板表上建索引，所有新分区自动继承
ALTER TABLE events_template ADD PRIMARY KEY (id, event_time);
CREATE INDEX idx_events_type ON events_template (event_type);
CREATE INDEX idx_events_user ON events_template (user_id);

-- 已有分区执行索引
-- pg_partman 会自动将父表的索引应用到新分区
```

---

## 监控分区状态

```sql
-- 查看分区大小
SELECT
    parent_table,
    child_schema || '.' || child_table AS partition_name,
    pg_size_pretty(pg_total_relation_size(child_schema || '.' || child_table)) AS size
FROM partman.part_config_sub
WHERE parent_table = 'public.events'
ORDER BY child_table;

-- 查看分区数据分布
SELECT
    tableoid::regclass AS partition,
    count(*) AS rows,
    min(event_time) AS since,
    max(event_time) AS until
FROM events
GROUP BY tableoid
ORDER BY partition;

-- 检查是否有分区缺失
SELECT * FROM partman.check_default(
    p_parent_table := 'public.events'
);
```

---

## 常用配置选项

```sql
-- 创建时指定
SELECT partman.create_parent(
    p_parent_table    := 'public.events',
    p_control         := 'event_time',
    p_type            := 'native',
    p_interval        := '1 day',
    p_premake         := 7,
    p_start_partition := '2024-01-01',
    p_template_table  := 'events_template',  -- 模板表
    p_jobmon          := true                -- 启用任务监控
);
```

### 配置字段说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `p_interval` | 分区间隔 | `'1 day'`, `'1 week'`, `'1 month'` |
| `p_premake` | 提前创建的分区数 | `7` |
| `p_retention` | 保留时长 | `'90 days'` |
| `p_start_partition` | 起始分区 | `'2024-01-01'` |
| `p_template_table` | 模板表 | `'events_template'` |

---

## ⚠️ 注意事项

1. **分区列必须 NOT NULL**
2. **主键必须包含分区列**
3. **外键不能跨分区**
4. **一次性创建太多分区可能影响性能**
5. **早期数据导入建议使用 `attach_partition`**

---

## 🔗 参考

- [pg_partman GitHub](https://github.com/pgpartman/pg_partman)
- [pg_partman 官方文档](https://github.com/pgpartman/pg_partman/blob/master/doc/pg_partman.md)
- [PostgreSQL 分区官方文档](https://www.postgresql.org/docs/current/ddl-partitioning.html)
