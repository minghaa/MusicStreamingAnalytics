# 🎵 Music Streaming Analytics

> SQL Portfolio Project - Phân tích dữ liệu Music Streaming với PostgreSQL và Looker Studio

[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)](https://www.postgresql.org/)
[![Dashboard](https://img.shields.io/badge/Dashboard-Looker%20Studio-green)](https://lookerstudio.google.com/)
[![Level](https://img.shields.io/badge/Level-Intermediate-yellow)]()

## Project Overview

Dự án này phân tích dữ liệu streaming âm nhạc để tìm hiểu xu hướng nghe nhạc, hiệu suất nghệ sĩ, và mối tương quan giữa các audio features với popularity.

### Dataset
- **953 tracks** với thông tin streaming và audio features
- **50 artists** từ các thể loại khác nhau
- **Cross-platform metrics**: Spotify, Apple Music, Deezer, Shazam
- Dữ liệu từ 2018-2024

### Technologies
- **Database**: PostgreSQL
- **Visualization**: Looker Studio
- **Analysis**: SQL (CTEs, Window Functions, Subqueries)

---

## Project Structure

```
MusicStreamingAnalytics/
├── data/
│   ├── spotify_data.csv        # Main dataset
│   └── generate_data.py        # Data generation script
├── sql/
│   ├── 01_create_tables.sql    # Database schema
│   ├── 02_load_data.sql        # Data import
│   ├── 03_basic_analysis.sql   # Basic queries (6)
│   ├── 04_cte_analysis.sql     # CTE queries (5)
│   ├── 05_window_functions.sql # Window functions (6)
│   ├── 06_advanced_analysis.sql# Advanced queries (6)
│   └── 07_dashboard_queries.sql# Dashboard exports (10)
├── exports/                    # CSV exports for dashboard
├── docs/
│   └── schema_diagram.md       # ERD diagram
├── export_for_dashboard.py     # Export script
└── README.md
```

---

## Quick Start

### 1. Setup PostgreSQL Database

```bash
# Create database
createdb music_streaming

# Create tables
psql -d music_streaming -f sql/01_create_tables.sql

# Load data
psql -d music_streaming -f sql/02_load_data.sql
```

### 2. Run Analysis Queries

```bash
# Basic analysis
psql -d music_streaming -f sql/03_basic_analysis.sql

# CTE analysis
psql -d music_streaming -f sql/04_cte_analysis.sql

# Window functions
psql -d music_streaming -f sql/05_window_functions.sql

# Advanced analysis
psql -d music_streaming -f sql/06_advanced_analysis.sql
```

### 3. Export for Dashboard

```bash
# Using Python
python3 export_for_dashboard.py

# Or using psql \copy commands in 07_dashboard_queries.sql
```

### 4. Create Looker Studio Dashboard

1. Upload CSV files từ `/exports` lên Google Sheets
2. Connect Google Sheets với Looker Studio
3. Tạo các charts theo hướng dẫn bên dưới

---

## SQL Skills Demonstrated

### Basic SQL
- `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `LIMIT` và filtering

### Intermediate SQL (CTEs)
- Common Table Expressions với `WITH`
- Multi-level CTEs
- Recursive calculations
- Running totals và cumulative metrics

### Window Functions
- `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`
- `LAG()`, `LEAD()` cho time-series comparison
- `NTILE()` cho quartile analysis
- `SUM() OVER()`, `AVG() OVER()` cho running calculations
- `FIRST_VALUE()`, `LAST_VALUE()`
- `PARTITION BY` và `ORDER BY` trong window specs

### Advanced SQL
- Complex subqueries
- `CASE WHEN` expressions
- Cross-platform correlation analysis
- `PERCENTILE_CONT()` cho statistical analysis
- String manipulation với `SPLIT_PART()`

---

## Dashboard Components

### KPIs
| Metric | Description |
|--------|-------------|
| Total Streams | Tổng lượt stream |
| Total Tracks | Số bài hát |
| Total Artists | Số nghệ sĩ |
| Average BPM | Tempo trung bình |

### Charts
1. **Bar Chart**: Top 20 Artists by Total Streams
2. **Line Chart**: Yearly Streaming Trends
3. **Pie Chart**: Major vs Minor Mode Distribution
4. **Scatter Plot**: Danceability vs Energy
5. **Heatmap**: Monthly Release Patterns
6. **Table**: Top Tracks with Audio Features

### Filters
- Release Year
- Artist
- Mode (Major/Minor)
- Collaboration Type

---

## Key Insights

1. **Top Artists**: Taylor Swift, The Weeknd, và Bad Bunny dẫn đầu về tổng streams
2. **Audio Trends**: Tracks có danceability cao (>70%) thường có nhiều streams hơn
3. **Collaboration Impact**: Duo collaborations có average streams cao hơn solo tracks 15%
4. **Seasonal Patterns**: Summer releases có performance tốt hơn các mùa khác
5. **Cross-Platform**: Spotify playlists có correlation cao nhất với streams

---

## Links

- **Dashboard**: [📊 View Live Dashboard](https://lookerstudio.google.com/reporting/0f5736d2-e7c6-4b67-9e6c-975d2883db0d)
- **Dataset Source**: Kaggle Spotify Dataset
- **Author**: [Minh Ha To]

---

## 📝 License

This project is for educational and portfolio purposes.
