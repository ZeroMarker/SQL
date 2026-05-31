# Neo4j 🔗

Neo4j — 图数据库与 Cypher 查询语言学习与实践

---

## 📂 目录内容

| 文件 | 说明 |
|------|------|
| `cypher/cypher.cyp` | Cypher 基础语法：创建节点/关系、查询、删除、索引 |
| `cypher/dbeaver.cyp` | DBeaver 连接 Neo4j 的配置与查询示例 |
| `cypher/northwind.cyp` | Northwind 示例数据集：供应商-产品-订单图模型 |
| `docker.sh` | Docker 启动脚本 |

---

## 🐳 Docker 启动

```bash
# 拉取镜像
# docker pull neo4j

# 启动容器（带认证）
docker run --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password -d neo4j

# 或使用脚本
sh docker.sh
```

启动后访问 Neo4j Browser: http://localhost:7474

## 🚀 Cypher 快速入门

```cypher
// 创建节点
CREATE (n:Person {name: '刘备', title: '皇帝'})
CREATE (n:Person {name: '关羽', title: '将军'})

// 创建关系
MATCH (a:Person {name: '刘备'}), (b:Person {name: '关羽'})
CREATE (a)-[:结拜 {since: 184}]->(b)

// 查询
MATCH (n)-[r]->(m) RETURN n, r, m

// 查找关系路径
MATCH path = (a:Person {name: '刘备'})-[:结拜*1..3]->(b)
RETURN path
```

## 📖 核心概念

| 概念 | 说明 | SQL 类比 |
|------|------|----------|
| Node (节点) | 实体 | Row |
| Label (标签) | 实体类型 | Table |
| Relationship (关系) | 节点间的连线 | Foreign Key + JOIN |
| Property (属性) | 键值对 | Column |
| Cypher | 声明式图查询语言 | SQL |

---

## 🔗 参考资源

- [Neo4j Aura 云服务](https://console.neo4j.io)
- [Neo4j Browser Demo](https://demo.neo4jlabs.com:7473)
- [手把手教你快速入门知识图谱 - Neo4J教程](https://zhuanlan.zhihu.com/p/88745411)
- [Neo4j入门实战 - 三国英雄关系](https://developer.aliyun.com/article/1143832)
- [Northwind 示例数据集](https://github.com/neo4j-graph-examples/northwind)

