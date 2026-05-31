#!/bin/bash
# ClickHouse Docker 启动脚本

echo "🚀 启动 ClickHouse..."

docker run -d --name clickhouse-server \
  -p 8123:8123   `# HTTP 接口 (REST API + Playground)` \
  -p 9000:9000   `# 原生 TCP 客户端接口` \
  -p 9009:9009   `# 集群内部通信` \
  -e CLICKHOUSE_DB=mydb \
  -e CLICKHOUSE_USER=default \
  -e CLICKHOUSE_PASSWORD=password \
  -e CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
  -v clickhouse-data:/var/lib/clickhouse \
  clickhouse/clickhouse-server

if [ $? -eq 0 ]; then
    echo "✅ ClickHouse 已启动！"
    echo ""
    echo "   HTTP Playground: http://localhost:8123/playground"
    echo "   命令行: docker exec -it clickhouse-server clickhouse-client --password password"
    echo "   HTTP API: curl -u default:password 'http://localhost:8123/?query=SELECT%201'"
    echo ""
    echo "💡 快速测试:"
    echo "   curl -u default:password 'http://localhost:8123/?query=SELECT+version()'"
else
    echo "❌ 启动失败，尝试: docker rm clickhouse-server"
fi
