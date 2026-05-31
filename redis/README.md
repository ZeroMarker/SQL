# Redis 🔴

Remote Dictionary Server — 内存键值存储（NoSQL）学习与实践

---

## 📂 目录内容

| 文件 | 说明 |
|------|------|
| `redis.sql` | Redis 命令实操：String / Hash / List / Set / Sorted Set / 事务 / 过期 |

---

## 🚀 启动 Redis

```bash
# Docker 启动
docker run --name redis -p 6379:6379 -d redis

# 进入 CLI
docker exec -it redis redis-cli
```

## 📖 数据类型与命令

### 基本类型

| 类型 | 示例 | 说明 |
|------|------|------|
| **String** | `SET key value` / `GET key` | 字符串、数字、二进制安全 |
| **Hash** | `HSET user:1 name "Alice"` / `HGET user:1 name` | 对象/字典结构 |
| **List** | `LPUSH list item` / `RPUSH list item` / `LRANGE list 0 -1` | 双向链表 |
| **Set** | `SADD set member` / `SMEMBERS set` | 无序集合（去重） |
| **Sorted Set** | `ZADD zset 1 one` / `ZRANGE zset 0 -1 WITHSCORES` | 有序集合（排行榜） |

### 高级类型

| 类型 | 说明 |
|------|------|
| **Stream** | 消息队列，支持消费者组 |
| **Geospatial** | 地理位置查询（GEOADD、GEODIST） |
| **HyperLogLog** | 基数估算（PFADD、PFCOUNT） |
| **BitMap** | 位图操作（SETBIT、GETBIT、BITCOUNT） |
| **BitField** | 位字段操作 |

### 通用命令

```bash
# 键操作
KEYS *
KEYS user:*
EXISTS key
TYPE key
DEL key
EXPIRE key 60    # 设置过期时间（秒）
TTL key          # 查看剩余时间

# 事务
MULTI
SET key1 val1
SET key2 val2
EXEC
```

## 🔗 参考资源

- [【GeekHour】一小时Redis教程](https://www.bilibili.com/video/BV1Jj411D7oG/)
- [Redis 官方文档](https://redis.io/docs/)

