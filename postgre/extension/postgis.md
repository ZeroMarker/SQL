# PostGIS — 地理空间扩展 🌍

PostGIS 将 PostgreSQL 变成空间数据库，支持 GIS 数据类型、空间索引和空间分析函数。

---

## 安装

```sql
CREATE EXTENSION postgis;      -- 核心
CREATE EXTENSION postgis_topology;  -- 拓扑
CREATE EXTENSION fuzzystrmatch;     -- 模糊匹配（地址）
CREATE EXTENSION postgis_tiger_geocoder; -- 地理编码
```

## 核心数据类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `geometry` | 平面坐标系几何体 | `POINT(116.4 39.9)` |
| `geography` | 球面坐标系（经纬度） | `SRID=4326;POINT(116.4 39.9)` |
| `geography(POINT, 4326)` | 带 SRID 的地理点 | 常用 GPS 坐标 |

## 常用地理对象

```sql
-- 点
SELECT ST_GeomFromText('POINT(116.4 39.9)', 4326);

-- 线
SELECT ST_GeomFromText('LINESTRING(0 0, 1 1, 2 0)', 4326);

-- 面
SELECT ST_GeomFromText('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))', 4326);

-- 多点
SELECT ST_GeomFromText('MULTIPOINT(0 0, 1 1)', 4326);
```

---

## 建表示例

```sql
-- 创建带空间列的表
CREATE TABLE places (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100),
    location GEOGRAPHY(POINT, 4326),  -- GPS 坐标
    boundary GEOGRAPHY(POLYGON, 4326) -- 区域边界
);

-- 创建空间索引（必须用 GiST）
CREATE INDEX idx_places_location ON places USING GIST (location);

-- 写入数据
INSERT INTO places (name, location) VALUES
    ('天安门', ST_GeogFromText('SRID=4326;POINT(116.3975 39.9087)')),
    ('故宫',   ST_GeogFromText('SRID=4326;POINT(116.3972 39.9163)')),
    ('鸟巢',   ST_GeogFromText('SRID=4326;POINT(116.3952 39.9929)'));
```

---

## 空间查询

```sql
-- 1. 计算距离（米）
SELECT name,
       ST_Distance(location, ST_GeogFromText('SRID=4326;POINT(116.4 39.9)')) AS distance_m
FROM places
ORDER BY distance_m;

-- 2. 范围内查找（5 公里内的地点）
SELECT name, ST_AsText(location)
FROM places
WHERE ST_DWithin(location,
    ST_GeogFromText('SRID=4326;POINT(116.4 39.9)'),
    5000  -- 5 公里
);

-- 3. 面积计算
SELECT name,
       ST_Area(boundary) / 1000000 AS area_km2
FROM places;

-- 4. 点是否在面内
SELECT name
FROM places
WHERE ST_Contains(boundary,
    ST_GeomFromText('POINT(116.3975 39.9087)', 4326));

-- 5. 按距离排序（最近 N 个）
SELECT name,
       ST_Distance(location, 'SRID=4326;POINT(116.4 39.9)'::geography) / 1000 AS dist_km
FROM places
ORDER BY location <-> 'SRID=4326;POINT(116.4 39.9)'::geography
LIMIT 3;
```

---

## 常用函数速查

### 构造函数

| 函数 | 说明 |
|------|------|
| `ST_GeomFromText(text, srid)` | WKT 文本构建几何体 |
| `ST_GeogFromText(text)` | 构建地理对象 |
| `ST_MakePoint(lon, lat)` | 构建点 |
| `ST_Buffer(geom, radius)` | 生成缓冲区 |

### 测量函数

| 函数 | 说明 |
|------|------|
| `ST_Distance(a, b)` | 距离 |
| `ST_Area(geom)` | 面积 |
| `ST_Length(geom)` | 长度 |
| `ST_Perimeter(geom)` | 周长 |

### 关系判断

| 函数 | 说明 |
|------|------|
| `ST_Contains(a, b)` | a 包含 b |
| `ST_Intersects(a, b)` | 是否相交 |
| `ST_DWithin(a, b, dist)` | 距离内 |
| `ST_Touches(a, b)` | 是否相邻 |

### 输出函数

| 函数 | 说明 |
|------|------|
| `ST_AsText(geom)` | 转为 WKT 文本 |
| `ST_AsGeoJSON(geom)` | 转为 GeoJSON |
| `ST_AsKML(geom)` | 转为 KML |

---

## 周边工具

| 工具 | 说明 |
|------|------|
| **PostGIS Raster** | 栅格数据（遥感影像） |
| **pgRouting** | 路径规划（最短路径、TSP） |
| **PostGIS Tiger** | 美国地址地理编码 |
| **QGIS** | 桌面 GIS 可视化 |
| **GeoServer** | WMS/WFS 地图服务 |

---

## 🔗 参考

- [PostGIS 官方文档](https://postgis.net/documentation/)
- [PostGIS 在线手册（中文）](https://postgis.gishub.org/)
- [GIS 常用坐标系 SRID 列表](https://epsg.io/)
