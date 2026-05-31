#!/bin/bash
# InfluxDB 2.x Docker 启动脚本

INFLUX_NAME="influxdb"
INFLUX_PORT=8086
INFLUX_ORG="myorg"
INFLUX_BUCKET="mybucket"
INFLUX_USER="admin"
INFLUX_PASS="password"
INFLUX_TOKEN="mytoken123"

echo "🚀 启动 InfluxDB 2.x..."
echo "   Org: $INFLUX_ORG"
echo "   Bucket: $INFLUX_BUCKET"
echo "   UI: http://localhost:$INFLUX_PORT"

docker run -d --name $INFLUX_NAME \
  -p $INFLUX_PORT:8086 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=$INFLUX_USER \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=$INFLUX_PASS \
  -e DOCKER_INFLUXDB_INIT_ORG=$INFLUX_ORG \
  -e DOCKER_INFLUXDB_INIT_BUCKET=$INFLUX_BUCKET \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=$INFLUX_TOKEN \
  -v influxdb-data:/var/lib/influxdb2 \
  influxdb:2

if [ $? -eq 0 ]; then
    echo "✅ InfluxDB 已启动！"
    echo "   Web UI: http://localhost:$INFLUX_PORT"
    echo "   用户名: $INFLUX_USER"
    echo "   密码:   $INFLUX_PASS"
    echo "   Token:  $INFLUX_TOKEN"
else
    echo "❌ 启动失败，尝试: docker rm $INFLUX_NAME"
fi
