# InfluxDB ⏱️

InfluxDB — 开源时序数据库（Time Series Database），专为监控、指标、IoT 传感器数据设计。

---

## 📂 目录结构

```
influxdb/
├── README.md          # 本文件
├── flux.flux          # Flux 查询语言示例
└── influx.sh          # Docker 启动脚本
```

---

## 🐳 Docker 启动

```bash
# InfluxDB 2.x（推荐）
docker run --name influxdb -p 8086:8086 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=password \
  -e DOCKER_INFLUXDB_INIT_ORG=myorg \
  -e DOCKER_INFLUXDB_INIT_BUCKET=mybucket \
  -d influxdb:2

# 或使用脚本
sh influx.sh
```

访问 Web UI: http://localhost:8086

### InfluxDB 1.x（兼容模式）

```bash
docker run --name influxdb-v1 -p 8083:8083 -p 8086:8086 \
  -e INFLUXDB_ADMIN_ENABLED=true \
  -d influxdb:1
```

---

## 📖 核心概念

| 概念 | 说明 | 类比传统数据库 |
|------|------|----------------|
| **Bucket** | 数据存储桶，类似数据库 | Database |
| **Measurement** | 测量指标类型，类似表 | Table |
| **Point** | 单条数据记录 | Row |
| **Tag** | 标签（索引字段，可分组） | Indexed Column |
| **Field** | 字段值（实际指标数据） | Value Column |
| **Timestamp** | 时间戳（精度纳秒） | Primary Key (time) |

### 数据结构示例

```
# 数据写入行协议 (Line Protocol)
sensor_temp,location=机房,device=sensor01 value=25.6 1700000000000000000
│          │                         │     │         │
│          ├─ Tag(s)                 │     │         └─ Timestamp (纳秒)
│                                   │     │
Measurement                        Field └─ Field Value
                                    Key
```

---

## 🚀 InfluxDB 2.x + Flux 查询

### 写入数据

```bash
# 通过 HTTP API 写入
curl -X POST http://localhost:8086/api/v2/write?org=myorg&bucket=mybucket \
  -H "Authorization: Token <your-token>" \
  -d 'weather,temperature=25.6,humidity=60,location=beijing 100i 1700000000'
```

### Flux 查询

```flux
// 查询最近 1 小时的数据
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> filter(fn: (r) => r.location == "机房")
  |> yield(name: "机房温度")

// 聚合：每分钟平均值
from(bucket: "mybucket")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> aggregateWindow(every: 1m, fn: mean)
  |> yield(name: "mean_temp")

// 按 location 分组统计
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> group(columns: ["location"])
  |> mean()
  |> yield(name: "avg_by_location")
```

### InfluxQL（1.x 兼容语法）

```sql
-- 查看所有的 measurement
SHOW MEASUREMENTS

-- 查询数据
SELECT * FROM "sensor_temp" WHERE time > now() - 1h

-- 聚合查询
SELECT MEAN("value") FROM "sensor_temp"
  WHERE "location" = '机房'
  AND time > now() - 24h
  GROUP BY time(10m)
```

---

## 📊 InfluxDB vs 传统数据库

| 场景 | InfluxDB 优势 | 传统 RDBMS 劣势 |
|------|---------------|-----------------|
| 大量时间范围查询 | 按时间索引优化，毫秒级 | 需要手动分表，性能差 |
| 实时写入高吞吐 | 批量写入 + 压缩 | 行存储写入瓶颈 |
| 数据保留与下采样 | 内置 retention + downsampling | 需要手动清理 |
| 聚合窗口查询 | 原生窗口函数 | 复杂 GROUP BY |
| IoT / 传感器 | 行协议写入效率极高 | JSON 解析开销大 |

---

## 🛠️ 常见应用场景

- **基础设施监控** — CPU / 内存 / 磁盘 / 网络指标
- **IoT 传感器** — 温度、湿度、震动、GPS 轨迹
- **应用性能监控 (APM)** — 请求延迟、错误率、吞吐量
- **金融时序** — 股价、交易量、汇率
- **实时分析** — 流量统计、用户行为漏斗

---

## 🔗 参考资源

- [InfluxDB 官方文档](https://docs.influxdata.com/influxdb/)
- [Flux 查询语言文档](https://docs.influxdata.com/flux/)
- [【简析时序数据库InfluxDB】](https://www.cnblogs.com/buttercup/p/15204096.html)
- [InfluxDB 2.x 入门教程](https://www.influxdata.com/blog/getting-started-with-influxdb/)
