#!/bin/bash
# ClickHouse 测试数据写入脚本
# 前提: clickhouse-server 容器已运行

HOST="http://localhost:8123"
AUTH="default:password"
TABLE="events"

echo "📊 生成模拟事件数据并写入 ClickHouse..."

# 建表
curl -s -u "$AUTH" -X POST "$HOST/?query=$(cat <<'SQL' | jq -sRr @uri
CREATE TABLE IF NOT EXISTS events (
    event_date  Date,
    event_time  DateTime,
    user_id     UInt32,
    event_type  String,
    page_url    String,
    duration_sec UInt32,
    revenue     Float32
) ENGINE = MergeTree()
  PARTITION BY toYYYYMM(event_date)
  ORDER BY (event_date, event_type, user_id)
SQL
)" -o /dev/null

echo "✅ 表已创建"

# 写入 1000 行随机事件数据
ROWS=1000
echo "🔄 写入 $ROWS 条..."

# 构造批量 INSERT
INSERT_SQL="INSERT INTO events FORMAT TabSeparated"

DATA=""
for i in $(seq 1 $ROWS); do
  DAY_OFFSET=$((RANDOM % 30))
  HOUR=$((RANDOM % 24))
  MINUTE=$((RANDOM % 60))
  SECOND=$((RANDOM % 60))
  USER_ID=$((1000 + RANDOM % 200))
  EVENT_TYPES=("page_view" "click" "purchase" "search" "add_to_cart" "signup")
  ET=${EVENT_TYPES[$((RANDOM % ${#EVENT_TYPES[@]}))]}
  PAGES=("/home" "/search" "/product/1" "/product/2" "/cart" "/checkout" "/profile" "/settings")
  PG=${PAGES[$((RANDOM % ${#PAGES[@]}))]}
  DUR=$((RANDOM % 120))
  REV=0
  if [ "$ET" = "purchase" ]; then
    REV=$(echo "scale=2; 10 + $RANDOM % 200" | bc)
  fi

  DATE=$(date -d "2024-01-01 + $DAY_OFFSET days" +%Y-%m-%d 2>/dev/null || \
         date -j -v+${DAY_OFFSET}d -f "%Y-%m-%d" "2024-01-01" +%Y-%m-%d 2>/dev/null)
  TIME_STR="${DATE} $(printf "%02d:%02d:%02d" $HOUR $MINUTE $SECOND)"

  DATA+="${DATE}\t${TIME_STR}\t${USER_ID}\t${ET}\t${PG}\t${DUR}\t${REV}\n"
done

# 通过 HTTP API 写入
echo -e "$DATA" | curl -s -u "$AUTH" "$HOST/?query=$INSERT_SQL" \
  --data-binary @- -o /dev/null

echo "✅ 写入完成！"
echo ""
echo "📊 验证查询:"
echo ""
echo "   curl -u $AUTH '$HOST/?query=SELECT+event_type,count()+FROM+events+GROUP+BY+event_type+ORDER+BY+count()+DESC+FORMAT+PrettyCompact'"
echo ""
echo "   或通过 Playground 浏览: http://localhost:8123/playground"
