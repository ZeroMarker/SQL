# PostgreSQL 🐘

PostgreSQL 关系型数据库学习与实践

---

## 📂 目录结构

```
postgre/
├── function/                          # 存储函数
│   ├── tb_cis_drAdvice_detail.sql     # 医嘱明细查询函数
│   ├── tb_diagnosis_detail.sql        # 诊断明细查询函数
│   ├── tb_yl_patient_information.sql  # 患者信息查询函数
│   └── tb_yl_zy_medical_record.sql    # 住院病历查询函数
├── funciton.sql                       # 门诊挂号视图函数 (tb_his_mz_reg)
├── post.sql                           # PSQL 基础命令
├── post.sh                            # PSQL 常用元命令速查 (\l, \c, \d)
├── primate.ipynb                      # pgAdmin / 查询 Notebook
├── extension/                         # 扩展生态详解
│   ├── README.md                      #    扩展大全（安装、分类、管理）
│   ├── postgis.md                     #    PostGIS 地理空间
│   ├── pgvector.md                    #    pgvector 向量搜索
│   ├── pg_stat_statements.md          #    查询性能统计
│   ├── pg_trgm.md                     #    模糊文本匹配
│   ├── uuid.md                        #    UUID 生成
│   ├── hstore.md                      #    键值对存储
│   ├── citext.md                      #    大小写不敏感文本
│   └── pg_partman.md                  #    自动分区管理
│   └── vs_专用数据库.md              #    扩展 vs 专用数据库对比
└── README.md
```

---

## 🧩 扩展生态

PostgreSQL 最强特性之一：`CREATE EXTENSION` 即可增加新功能。

```sql
-- 查看已安装的扩展
SELECT * FROM pg_extension;

-- 查看可用扩展
SELECT * FROM pg_available_extensions;
```

详见 [`extension/` 目录](extension/README.md)。

---

## 🐳 Docker 启动

```bash
# 拉取并启动 PostgreSQL
docker run --name postgres -p 5432:5432 \
  -e POSTGRES_PASSWORD=password \
  -d postgres

# 进入 psql
docker exec -it postgres psql -U postgres
```

---

## 🔧 PSQL 常用元命令

| 命令 | 说明 |
|------|------|
| `\l` | 列出所有数据库 |
| `\c dbname` | 切换到指定数据库 |
| `\d` | 列出当前库所有表/视图/序列 |
| `\d tablename` | 查看表结构 |
| `\dt` | 仅列出表 |
| `\df` | 列出函数 |
| `\di` | 列出索引 |
| `\x` | 切换扩展显示模式 |
| `\q` | 退出 psql |

---

## 📖 函数示例

本目录的函数基于 **医疗行业** 场景（his — Hospital Information System）：

| 函数名 | 功能 |
|--------|------|
| `tb_his_mz_reg` | 门诊挂号记录查询（挂号日期、科室、费用类型等） |
| `tb_cis_drAdvice_detail` | 医嘱明细查询（药品、剂量、用法、执行时间等） |
| `tb_diagnosis_detail` | 诊断明细查询 |
| `tb_yl_patient_information` | 患者基本信息查询 |
| `tb_yl_zy_medical_record` | 住院病历记录查询 |

```sql
-- 函数调用示例
SELECT * FROM ho_his.tb_his_mz_reg('2024-01-01', '2024-01-31');
```

> 这些函数均以 `TABLE` 返回类型（返回多列多行的集合），适用于复杂报表和数据导出场景。

---

## 🔗 参考资源

- [PostgreSQL 官方文档](https://www.postgresql.org/docs/)
- [PostgreSQL 教程 (菜鸟教程)](https://www.runoob.com/postgresql/postgresql-tutorial.html)
