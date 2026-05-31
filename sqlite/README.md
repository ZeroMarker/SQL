# SQLite 📦

SQLite — 轻量级嵌入式关系型数据库引擎

---

## 📂 目录内容

| 文件 | 说明 |
|------|------|
| `install.sh` | SQLite 安装脚本 |

---

## 🚀 安装

### macOS

```bash
# 自带 SQLite，或通过 Homebrew 更新
brew install sqlite
```

### Linux

```bash
# Ubuntu / Debian
sudo apt install sqlite3

# CentOS / RHEL
sudo yum install sqlite
```

### Windows

从 [SQLite 官网](https://www.sqlite.org/download.html) 下载 `sqlite-tools-win32-x64-*.zip`，解压后添加到 PATH。

---

## 基本使用

```bash
# 创建/打开数据库文件
sqlite3 mydb.db

# 导入 SQL 文件
sqlite3 mydb.db < schema.sql

# 导出数据库
sqlite3 mydb.db .dump > backup.sql
```

### SQLite 特有命令（点命令）

| 命令 | 说明 |
|------|------|
| `.databases` | 列出数据库 |
| `.tables` | 列出所有表 |
| `.schema tablename` | 查看表结构 |
| `.headers on` | 显示列名 |
| `.mode column` | 列对齐显示 |
| `.import file.csv table` | 导入 CSV |
| `.output file.txt` | 输出重定向 |
| `.quit` | 退出 |

```sql
-- SQLite 特色
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- 自增主键
    name TEXT NOT NULL,
    age INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
);

INSERT INTO users (name, age) VALUES ('Alice', 25);
SELECT * FROM users;
```

---

## 📖 特点

| 特性 | 说明 |
|------|------|
| 零配置 | 无需安装/配置服务 |
| 单文件 | 整个数据库就是一个文件 |
| 无服务器 | 应用程序直接读写文件 |
| 事务完整 | 支持 ACID 事务 |
| 数据量 | 适合 GB 级以下场景 |
| 公共领域 | 完全免费，无许可限制 |

---

## 🔗 参考资源

- [SQLite 官网](https://www.sqlite.org/)
- [SQLite 官方文档](https://www.sqlite.org/docs.html)
- [SQLite Tutorial](https://www.sqlitetutorial.net/)
