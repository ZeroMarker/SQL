# MongoDB 🍃

MongoDB — 文档型 NoSQL 数据库学习与实践

---

## 📂 目录内容

| 文件 | 说明 |
|------|------|
| `mongo.sql` | MongoDB 聚合管道示例：$match、$lookup、$group 等 |
| `data.sql` | MongoDB 电影数据表结构（MySQL 版，用于对比参考） |
| `mongo.sh` | Docker 启动脚本 |

---

## 🐳 Docker 启动

```bash
# 启动 MongoDB 容器
sh mongo.sh
# 或直接运行
# docker run -d --name mongodb -p 27017:27017 mongo
```

## 🚀 快速入门

```javascript
// 切换/创建数据库
use mydb

// 插入文档
db.users.insertOne({ name: "Alice", age: 25 })
db.users.insertMany([{ name: "Bob", age: 30 }, { name: "Charlie", age: 35 }])

// 查询
db.users.find({ age: { $gte: 30 } })
db.users.find({ name: /A/ })  // 正则匹配

// 聚合管道
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customer", total: { $sum: "$amount" } } },
  { $sort: { total: -1 } }
])
```

## 📖 MongoDB vs SQL 概念对照

| SQL | MongoDB |
|-----|---------|
| Database | Database |
| Table | Collection |
| Row | Document |
| Column | Field |
| Index | Index |
| JOIN | $lookup / 嵌入式文档 |

---

## 🔗 参考资源

- [MongoDB Crash Course](https://www.youtube.com/watch?v=ofme2o29ngU)
- [Learn MongoDB in 1 Hour 🍃 (2023)](https://www.youtube.com/watch?v=c2M-rlkkT5o)
- [【GeekHour】20分钟掌握MongoDB](https://www.bilibili.com/video/BV16u4y1y7Fm/)

