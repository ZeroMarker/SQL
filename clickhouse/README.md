# ClickHouse 🏠

ClickHouse — 开源列式存储 OLAP 数据库，由 Yandex 开发，专为**实时分析查询**设计。

---

## 📂 目录结构

```
clickhouse/
├── README.md          # 本文件
├── clickhouse.sh      # Docker 启动脚本
├── sql.sql            # ClickHouse SQL 查询示例
└── seed_data.sh       # 测试数据写入脚本
```

---

## 🐳 Docker 启动

```bash
# 单机模式
docker run -d --name clickhouse \
  -p 8123:8123   `# HTTP 接口` \
  -p 9000:9000   `# 原生 TCP 接口` \
  -p 9009:9009   `# 集群内部通信` \
  -e CLICKHOUSE_DB=mydb \
  -e CLICKHOUSE_USER=default \
  -e CLICKHOUSE_PASSWORD=password \
  -v clickhouse-data:/var/lib/clickhouse \
  clickhouse/clickhouse-server

# 或使用脚本
sh clickhouse.sh
```

访问 Playground: http://localhost:8123/playground

### 命令行客户端

```bash
# 进入容器
docker exec -it clickhouse clickhouse-client --user default --password password

# 或通过 HTTP API
curl -u default:password 'http://localhost:8123/?query=SELECT%201'
```

---

## 📖 核心概念

| 概念 | 说明 | 与传统 RDBMS 对比 |
|------|------|-------------------|
| **列式存储** | 按列而非行存储数据 | 分析查询只需读取相关列，I/O 大幅降低 |
| **MergeTree** | 核心表引擎，支持分区+排序+主键 | 类似 InnoDB，但为分析优化 |
| **分区 (Partition)** | 按时间等规则拆分数据 | 类似表分区，粒度更细 |
| **物化视图** | 预聚合加速查询 | 类似 Trigger + 汇总表 |
| **向量化执行** | SIMD 批量处理数据 | 逐行解释执行慢 100x+ |
| **分布式表** | 集群透明查询 | 分库分表方案 |

### 适用场景

| ✅ 适合 | ❌ 不适合 |
|---------|-----------|
| 在线分析查询 (OLAP) | 单行事务 (OLTP) |
| 宽表 + 大聚合 | 频繁 UPDATE / DELETE |
| 时序日志分析 | 小数据量 (< 1 亿行) |
| 用户行为分析 | 高并发点查询 |
| 实时报表 Dashboard | JOIN 多的星型模型 |

---

## 🚀 SQL 示例

### 建表（MergeTree 引擎）

```sql
CREATE TABLE events (
    event_date  Date,
    event_time  DateTime,
    user_id     UInt32,
    event_type  String,
    page_url    String,
    duration_sec UInt32,
    revenue     Float32
) ENGINE = MergeTree()
  PARTITION BY toYYYYMM(event_date)
  ORDER BY (event_date, event_type);
```

### 写入数据

```sql
INSERT INTO events VALUES
  (today(), now(), 1001, 'page_view', '/home', 0, 0),
  (today(), now(), 1002, 'purchase', '/cart', 15, 99.9),
  (today(), now(), 1001, 'click', '/product/1', 0, 0);
```

### 分析查询

```sql
-- 1. 按类型统计事件数（极速聚合）
SELECT event_type, count() AS cnt
FROM events
WHERE event_date >= today() - 7
GROUP BY event_type
ORDER BY cnt DESC;

-- 2. 用户留存（日期差）
SELECT
    toStartOfWeek(event_time) AS week,
    uniq(user_id) AS users,
    sum(revenue) AS total_revenue
FROM events
WHERE event_date >= '2024-01-01'
GROUP BY week
ORDER BY week;

-- 3. 漏斗分析
SELECT
    event_type,
    uniq(user_id) AS users
FROM events
WHERE event_date >= today() - 30
GROUP BY event_type
ORDER BY users DESC;
```

---

## 📊 对比：ClickHouse vs 传统数据库

| 场景 | ClickHouse | MySQL / PostgreSQL |
|------|-----------|-------------------|
| 10 亿行 COUNT | **~0.01 秒** | 30 秒 ~ 几分钟 |
| 聚合 GROUP BY | **列式 + 向量化** | 行扫描 + 临时表 |
| 压缩比 | **5~10x** | 2~3x |
| 每秒写入 | **百万行/秒** | 万行/秒 |
| 单行查询 | 慢（按块扫描） | **快（索引定位）** |

---

## 🔧 常用函数

### 聚合函数

```sql
-- 去重计数（比 COUNT DISTINCT 快 100x）
SELECT uniq(user_id) FROM events;

-- 中位数
SELECT median(duration_sec) FROM events;

-- 分位数
SELECT quantile(0.95)(duration_sec) AS p95 FROM events;

-- 任意值（无 GROUP BY 时取第一行）
SELECT any(event_type) FROM events;
```

### 时间函数

```sql
-- 按分钟/小时/天/周/月聚合
SELECT toStartOfMinute(event_time) AS m, count()
FROM events GROUP BY m;

-- 时间差
SELECT dateDiff('day', min(event_time), max(event_time)) AS days FROM events;

-- 按星期几统计
SELECT toDayOfWeek(event_date) AS dow, count() FROM events GROUP BY dow;
```

### 条件与数组

```sql
-- 条件计数
SELECT countIf(revenue > 0) AS purchases FROM events;

-- 数组处理
SELECT groupArray(user_id) AS users FROM events WHERE event_type = 'purchase';

-- 保留最近 N 条
SELECT * FROM events LIMIT 10;
```

---

## 🔗 参考资源

- [ClickHouse 官方文档](https://clickhouse.com/docs/)
- [ClickHouse Playground 在线体验](https://play.clickhouse.com/)
- [ClickHouse SQL 参考](https://clickhouse.com/docs/en/sql-reference/)
- [MergeTree 引擎详解](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/mergetree)
- [Altinity 运维指南](https://docs.altinity.com/)
