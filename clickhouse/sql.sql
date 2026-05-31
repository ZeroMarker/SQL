-- ============================================
-- ClickHouse SQL 查询示例
-- ============================================

-- ---------- 1. 建表 ----------

-- MergeTree 引擎（最常用）
CREATE TABLE IF NOT EXISTS events (
    event_date  Date,
    event_time  DateTime,
    user_id     UInt32,
    event_type  String,    -- page_view, click, purchase, etc.
    page_url    String,
    duration_sec UInt32,
    revenue     Float32
) ENGINE = MergeTree()
  PARTITION BY toYYYYMM(event_date)
  ORDER BY (event_date, event_type, user_id)
  SETTINGS index_granularity = 8192;

-- 分布式表（需先建集群）
-- CREATE TABLE events_dist AS events
-- ENGINE = Distributed('cluster_name', 'mydb', 'events', rand());

-- 物化视图（自动聚合）
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_stats
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (day, event_type)
AS SELECT
    toDate(event_time) AS day,
    event_type,
    uniq(user_id) AS users,
    count() AS events,
    sum(revenue) AS revenue
FROM events
GROUP BY day, event_type;

-- ---------- 2. 写入数据 ----------

INSERT INTO events VALUES
    ('2024-01-01', '2024-01-01 10:00:00', 1001, 'page_view', '/home', 0, 0),
    ('2024-01-01', '2024-01-01 10:05:00', 1001, 'click', '/product/1', 0, 0),
    ('2024-01-01', '2024-01-01 10:10:00', 1002, 'page_view', '/search', 0, 0),
    ('2024-01-01', '2024-01-01 10:15:00', 1001, 'purchase', '/cart', 30, 99.9),
    ('2024-01-01', '2024-01-01 11:00:00', 1003, 'page_view', '/home', 0, 0),
    ('2024-01-01', '2024-01-01 11:30:00', 1002, 'purchase', '/cart', 45, 59.9),
    ('2024-01-02', '2024-01-02 09:00:00', 1001, 'page_view', '/home', 0, 0),
    ('2024-01-02', '2024-01-02 09:30:00', 1003, 'click', '/product/2', 0, 0),
    ('2024-01-02', '2024-01-02 10:00:00', 1004, 'page_view', '/home', 0, 0),
    ('2024-01-02', '2024-01-02 10:45:00', 1003, 'purchase', '/cart', 60, 199.9);

-- 批量写入（从 TSV 文件导入）
-- cat data.tsv | clickhouse-client --query="INSERT INTO events FORMAT TSV"

-- ---------- 3. 基础查询 ----------

-- 查看表结构
DESCRIBE TABLE events;

-- 查看记录数
SELECT count() FROM events;

-- 查看分区信息
SELECT partition, name, rows, bytes_on_disk
FROM system.parts WHERE table = 'events';

-- ---------- 4. 分析查询 ----------

-- 事件类型分布
SELECT event_type, count() AS cnt
FROM events GROUP BY event_type ORDER BY cnt DESC;

-- 每日活跃用户 (DAU)
SELECT event_date, uniq(user_id) AS dau
FROM events GROUP BY event_date ORDER BY event_date;

-- 每小时事件数
SELECT toStartOfHour(event_time) AS hour, count() AS events
FROM events GROUP BY hour ORDER BY hour;

-- 用户转化漏斗
SELECT
    event_type,
    uniq(user_id) AS users
FROM events GROUP BY event_type
ORDER BY users DESC;

-- ---------- 5. 高级聚合 ----------

-- 中位数/分位数
SELECT
    median(duration_sec) AS median_duration,
    quantile(0.90)(duration_sec) AS p90,
    quantile(0.95)(duration_sec) AS p95,
    quantile(0.99)(duration_sec) AS p99
FROM events;

-- 条件统计
SELECT
    countIf(revenue > 0) AS purchase_count,
    sumIf(revenue, revenue > 0) AS total_revenue,
    avgIf(duration_sec, event_type = 'purchase') AS avg_purchase_time
FROM events;

-- 按星期几分布
SELECT
    toDayOfWeek(event_date) AS weekday,
    count() AS events
FROM events
GROUP BY weekday
ORDER BY weekday;

-- 用户留存（次日/7日/30日）
SELECT
    toDate(event_time) AS day,
    uniqIf(user_id, event_date = today()) AS today_users,
    uniqIf(user_id, event_date = yesterday()) AS yesterday_users
FROM events
WHERE event_date >= yesterday()
;

-- ---------- 6. 窗口函数 ----------

-- 累计求和
SELECT
    event_date,
    revenue,
    sum(revenue) OVER (ORDER BY event_date) AS cumulative_revenue
FROM daily_stats
WHERE event_type = 'purchase';

-- 同比环比
SELECT
    day,
    revenue,
    revenue - lagInFrame(revenue) OVER (ORDER BY day) AS diff_from_prev,
    revenue / lagInFrame(revenue) OVER (ORDER BY day) - 1 AS growth_rate
FROM daily_stats
WHERE event_type = 'purchase';

-- ---------- 7. 系统查询 ----------

-- 当前运行的查询
SELECT query_id, query, elapsed, read_rows, memory_usage
FROM system.processes
ORDER BY elapsed DESC;

-- 慢查询
SELECT query, query_duration_ms, read_rows, memory_usage
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY query_duration_ms DESC
LIMIT 10;

-- 表大小排行
SELECT
    database,
    table,
    formatReadableSize(sum(bytes_on_disk)) AS size,
    sum(rows) AS rows
FROM system.parts
WHERE active
GROUP BY database, table
ORDER BY sum(bytes_on_disk) DESC;

-- ---------- 8. TTL 数据生命周期 -----------

ALTER TABLE events
  MODIFY TTL event_date + INTERVAL 90 DAY DELETE;

-- 查看 TTL
SELECT table, ttl_expression FROM system.tables WHERE table = 'events';
