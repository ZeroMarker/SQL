#!/bin/bash
# InfluxDB 2.x 测试数据写入脚本
# 前提: influxdb 容器已运行

INFLUX_HOST="http://localhost:8086"
INFLUX_ORG="myorg"
INFLUX_BUCKET="mybucket"
INFLUX_TOKEN="mytoken123"

# 写入传感器模拟数据
echo "📡 写入传感器模拟数据..."

for i in $(seq 1 100); do
  # 模拟 3 个位置的温度 + 湿度
  for loc in "机房" "办公室" "仓库"; do
    TEMP=$(echo "20 + $RANDOM % 15" | bc)
    HUM=$(echo "40 + $RANDOM % 40" | bc)

    curl -s -X POST "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=s" \
      -H "Authorization: Token $INFLUX_TOKEN" \
      -d "sensor_temp,location=$loc value=$TEMP $(( $(date +%s) - (100 - i) * 60 ))" \
      -o /dev/null

    curl -s -X POST "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=s" \
      -H "Authorization: Token $INFLUX_TOKEN" \
      -d "sensor_humidity,location=$loc value=$HUM $(( $(date +%s) - (100 - i) * 60 ))" \
      -o /dev/null
  done
done

echo "✅ 已写入 600 条测试数据（3 位置 × 2 指标 × 100 时间点）"
echo ""
echo "📊 Flux 查询验证:"
echo 'from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "sensor_temp")
  |> group(columns: ["location"])
  |> mean()'
