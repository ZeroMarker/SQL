# SQL Notes 🗄️

Structured Query Language — 数据库学习笔记与实践代码

涵盖主流关系型与非关系型数据库，从 SQL 基础到高级特性，以及数据库理论。

---

## 📂 目录结构

```
├── MySQL/          # MySQL 教程、查询练习、LeetCode 题解
├── mongo/          # MongoDB 文档型数据库
├── neo4j/          # Neo4j 图数据库 + Cypher 查询语言
├── redis/          # Redis 键值存储 + 数据类型实操
├── oracle/         # Oracle 数据库 + PL/SQL 编程
├── postgre/        # PostgreSQL 函数与查询
├── sqlite/         # SQLite 轻量级嵌入式数据库
├── influxdb/       # InfluxDB 时序数据库
├── clickhouse/     # ClickHouse 列式分析数据库
├── meta/           # 数据库理论
│   ├── theory/     #    范式理论、关系代数、事务隔离
└── .devcontainer/  # 开发容器配置
```

---

## 🗄️ 数据库覆盖

| 数据库 | 类型 | 目录 | 内容特色 |
|--------|------|------|----------|
| **MySQL** | 关系型 | `MySQL/` | Mosh 教程笔记、查询练习、LeetCode 题解、存储过程 |
| **MongoDB** | 文档型 (NoSQL) | `mongo/` | CRUD、聚合管道、关联查询 |
| **Neo4j** | 图数据库 | `neo4j/` | Cypher 语法、Northwind 示例、三国人物图谱 |
| **Redis** | 键值存储 | `redis/` | 5 种基本类型 + 高级类型命令实操 |
| **Oracle** | 关系型 | `oracle/` | PL/SQL 编程（函数、过程、块、游标） |
| **PostgreSQL** | 关系型 | `postgre/` | 函数定义、医疗数据查询案例 |
| **SQLite** | 嵌入式关系型 | `sqlite/` | 安装与轻量级使用 |
| **InfluxDB** | 时序数据库 | `influxdb/` | Flux 查询、时序数据写入与聚合、下采样 |
| **ClickHouse** | 列式 OLAP | `clickhouse/` | MergeTree 引擎、物化视图、极速聚合 |

---

## 🎯 学习路径建议

1. **SQL 基础** — 从 `MySQL/Query/` 开始，按 `where → sort → join → group → having → aggregate → subquery` 顺序学习
2. **数据库设计** — 学习 `meta/theory/Normalization/` 范式理论
3. **进阶查询** — `MySQL/Query/examples/` 实战案例，`MySQL/leetcode/` SQL 题目
4. **NoSQL 扩展** — `mongo/` → `redis/` → `neo4j/` 逐步拓宽视野
7. **时序数据** — `influxdb/` 学习 Flux 查询与下采样
8. **OLAP 分析** — `clickhouse/` 学习列式存储、MergeTree、亿级聚合
5. **存储过程与编程** — `oracle/PLSQL/` PL/SQL 编程
6. **事务与并发** — `meta/theory/Transaction/` 事务隔离级别

---

## 🔗 参考资源

| 资源 | 链接 |
|------|------|
| DB Engine Ranking | [db-engines.com](https://db-engines.com/en/ranking) |
| 7 Database Paradigms | [YouTube](https://www.youtube.com/watch?v=W2Z7fbCLSTw) |
| 一小时 MySQL 教程 | [Bilibili](https://www.bilibili.com/video/BV1AX4y147tA/) |
| SQL进阶教程 (Mosh) | [Bilibili](https://www.bilibili.com/video/BV1UE41147KC/) |
| Database Design Course | [YouTube](https://www.youtube.com/watch?v=ztHopE5Wnpc) |
| MIT 6.830 Database Systems | [YouTube](https://www.youtube.com/playlist?list=PLfciLKR3SgqOxCy1TIXXyfTqKzX2enDjK) |
| CMU 15-445 Intro to DB | [YouTube](https://www.youtube.com/playlist?list=PLSE8ODhjZXjaKScG3l0nuOiDTTqpfnWFf) |

---

## 🐳 快速开始

项目提供 `.devcontainer` 配置，推荐在 VS Code Dev Container 中打开：

```bash
# 或者在本地用 Docker 启动对应数据库
# MySQL
cd MySQL && docker compose up -d

# MongoDB
cd mongo && sh mongo.sh

# Neo4j
cd neo4j && sh docker.sh

# Oracle
cd oracle && sh install.sh
```

> 各目录下的 `docker.sh` / `install.sh` 脚本可一键启动对应数据库容器。

