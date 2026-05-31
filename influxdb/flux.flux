// ============================================
// InfluxDB Flux 查询语言示例
// ============================================
// 前提: InfluxDB 2.x 已启动，有 bucket "mybucket"

// ---------- 1. 基础查询 ----------

// 查询最近 1 小时所有数据
from(bucket: "mybucket")
  |> range(start: -1h)

// 指定 measurement 和字段
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> filter(fn: (r) => r._field == "value")

// ---------- 2. 多条件过滤 ----------

from(bucket: "mybucket")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "sensor_temp" and
    r.location == "机房"
  )

// ---------- 3. 聚合查询 ----------

// 按 10 分钟窗口求平均值
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> aggregateWindow(every: 10m, fn: mean)

// 按 location 分组后求最大值
from(bucket: "mybucket")
  |> range(start: -6h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> group(columns: ["location"])
  |> max()

// ---------- 4. 数学运算 ----------

// 华氏度转摄氏度
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp_f")
  |> map(fn: (r) => ({ r with _value: (r._value - 32.0) * 5.0 / 9.0 }))
  |> yield(name: "celsius")

// ---------- 5. 滑动窗口 ----------

// 1 小时滑动平均值
from(bucket: "mybucket")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "cpu_usage")
  |> window(every: 1m)
  |> mean()
  |> duplicate(column: "_stop", as: "_time")
  |> window(every: inf)

// ---------- 6. 向下采样 (Downsampling) ----------

// 将原始数据按 5 分钟窗口压缩后写入新 bucket
from(bucket: "mybucket")
  |> range(start: -7d)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> aggregateWindow(every: 5m, fn: mean)
  |> to(bucket: "mybucket_downsampled", org: "myorg")

// ---------- 7. 多表连接 ----------

// 关联温度与湿度数据
cpu = from(bucket: "mybucket")
  |> range(start: -30m)
  |> filter(fn: (r) => r._measurement == "cpu_usage")

mem = from(bucket: "mybucket")
  |> range(start: -30m)
  |> filter(fn: (r) => r._measurement == "memory_usage")

join(tables: {cpu: cpu, mem: mem}, on: ["_time", "host"])
  |> map(fn: (r) => ({
    _time: r._time,
    host: r.host,
    cpu: r._value_cpu,
    memory: r._value_mem
  }))

// ---------- 8. 预测 (Pivot) ----------

// 将 tag 展开为列
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> pivot(rowKey: ["_time"], columnKey: ["location"], valueColumn: "_value")

// ---------- 9. 条件逻辑 ----------

from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> map(fn: (r) => ({
    r with
    alert: if r._value > 30.0 then "高温告警" else "正常"
  }))
