# 📊 Hướng Dẫn Chi Tiết Tạo Dashboard Looker Studio

## Bước 1: Upload Data lên Google Sheets

1. Truy cập [Google Sheets](https://sheets.google.com)
2. Tạo spreadsheet mới: **File → New → Spreadsheet**
3. Đặt tên: `Music Streaming Analytics Data`
4. Import file CSV:
   - **File → Import → Upload**
   - Chọn file `full_dataset.csv` từ folder `Downloads/MusicStreamingAnalytics/exports/`
   - Chọn **Replace current sheet**
   - Đặt tên sheet: `main_data`

---

## Bước 2: Kết Nối Looker Studio

1. Truy cập [Looker Studio](https://lookerstudio.google.com)
2. Click **Create → Report**
3. Chọn **Google Sheets** làm data source
4. Chọn spreadsheet `Music Streaming Analytics Data`
5. Chọn sheet `main_data` → **Connect**
6. Click **Add to report**

---

## Bước 3: KPI Scorecards (4 metrics)

### 3.1 Total Streams
1. **Add a chart → Scorecard**
2. Kéo vào góc trên trái dashboard
3. **Metric**: `streams` → Aggregation: **SUM**
4. **Style tab**:
   - Compact numbers: ✅
   - Font size: 48
   - Font color: `#1DB954` (Spotify green)
5. **Add label** phía trên: "Total Streams"

### 3.2 Total Tracks
1. **Add a chart → Scorecard**
2. **Metric**: `track_id` → Aggregation: **COUNT**
3. **Style**: Font size 48, color `#191414`
4. Label: "Total Tracks"

### 3.3 Total Artists
1. **Add a chart → Scorecard**
2. **Metric**: `primary_artist` → Aggregation: **COUNT DISTINCT**
3. **Style**: Font size 48, color `#535353`
4. Label: "Total Artists"

### 3.4 Average BPM
1. **Add a chart → Scorecard**
2. **Metric**: `bpm` → Aggregation: **AVG**
3. **Style**: Font size 48, color `#b3b3b3`
4. Label: "Avg BPM"

---

## Bước 4: Bar Chart - Top 20 Artists

### Setup
1. **Add a chart → Bar chart** (horizontal)
2. Resize: ~400x350 pixels

### Data Configuration
| Field | Setting |
|-------|---------|
| Dimension | `primary_artist` |
| Metric | `streams` (SUM) |
| Sort | `streams` Descending |
| Row limit | 20 |

### Style
1. **Bar tab**:
   - Number of bars: 20
   - Color: `#1DB954`
2. **Axis tab**:
   - Left Y-axis: Show axis title "Artist"
   - X-axis: Show axis title "Total Streams"
3. **Header**: Add title "🎤 Top 20 Artists by Streams"

---

## Bước 5: Line Chart - Yearly Trends

### Setup
1. **Add a chart → Time series** (hoặc Line chart)
2. Resize: ~400x300 pixels

### Data Configuration
| Field | Setting |
|-------|---------|
| Dimension | `released_year` |
| Metric | `streams` (AVG) |
| Sort | `released_year` Ascending |

### Calculated Field (tạo mới)
1. **Add field → Add calculated field**
2. Name: `streams_millions`
3. Formula: `streams / 1000000`
4. Dùng field này thay vì `streams`

### Style
1. **Series tab**:
   - Line color: `#1ED760`
   - Line weight: 3px
   - Show data points: ✅
2. **Axis tab**:
   - X-axis: "Release Year"
   - Y-axis: "Avg Streams (Millions)"
3. **Header**: "📈 Streaming Trends by Year"

---

## Bước 6: Pie Chart - Mode Distribution

### Setup
1. **Add a chart → Pie chart**
2. Resize: ~300x300 pixels

### Data Configuration
| Field | Setting |
|-------|---------|
| Dimension | `mode` |
| Metric | `track_id` (COUNT) |

### Style
1. **Slices tab**:
   - Slice 1 (Major): `#1DB954`
   - Slice 2 (Minor): `#535353`
2. **Legend**: Show at bottom
3. **Labels**: Show percentage
4. **Header**: "🎵 Major vs Minor"

---

## Bước 7: Scatter Plot - Danceability vs Energy

### Setup
1. **Add a chart → Scatter chart**
2. Resize: ~450x350 pixels

### Data Configuration
| Field | Setting |
|-------|---------|
| Dimension | `track_name` |
| Metric X | `danceability_pct` (AVG) |
| Metric Y | `energy_pct` (AVG) |
| Bubble size | `streams` (SUM) - optional |

### Style
1. **Points tab**:
   - Point color: `#1ED760`
   - Point size: 8
   - Opacity: 70%
2. **Axis tab**:
   - X-axis: "Danceability (%)" - Range: 0-100
   - Y-axis: "Energy (%)" - Range: 0-100
3. **Trendline**: ✅ Enable (optional)
4. **Header**: "💃 Danceability vs Energy"

---

## Bước 8: Table - Top Tracks

### Setup
1. **Add a chart → Table**
2. Resize: Full width, ~350 height

### Data Configuration
| Field | Type |
|-------|------|
| `track_name` | Dimension |
| `artist_name` | Dimension |
| `released_year` | Dimension |
| `streams` | Metric (SUM) |
| `danceability_pct` | Metric (AVG) |
| `energy_pct` | Metric (AVG) |
| `valence_pct` | Metric (AVG) |

### Settings
- Sort: `streams` Descending
- Rows per page: 25

### Style
1. **Table header**:
   - Background: `#191414`
   - Font color: White
2. **Table body**:
   - Alternating row colors: ✅
3. **Column formatting**:
   - `streams`: Compact numbers
4. **Header**: "🎧 Top Tracks Details"

---

## Bước 9: Add Filters (Interactive Controls)

### 9.1 Year Filter
1. **Add a control → Drop-down list**
2. Control field: `released_year`
3. Position: Top of dashboard

### 9.2 Artist Filter  
1. **Add a control → Drop-down list**
2. Control field: `primary_artist`
3. Position: Next to year filter

### 9.3 Mode Filter
1. **Add a control → Drop-down list**
2. Control field: `mode`
3. Position: Next to artist filter

---

## Bước 10: Final Styling

### Theme
1. **Theme and layout → Theme → Custom**
2. Background: `#121212` (dark)
3. Font family: "Inter" hoặc "Roboto"

### Header
1. Add **Text** box at top
2. Content: "🎵 Music Streaming Analytics Dashboard"
3. Font: 28px, Bold, White

### Layout Suggestion
```
┌─────────────────────────────────────────────────┐
│  🎵 Music Streaming Analytics Dashboard         │
├───────────┬───────────┬───────────┬─────────────┤
│ Total     │ Total     │ Total     │ Avg         │
│ Streams   │ Tracks    │ Artists   │ BPM         │
├───────────┴───────────┴───────────┴─────────────┤
│ [Year ▼]    [Artist ▼]    [Mode ▼]              │
├─────────────────────────┬───────────────────────┤
│                         │                       │
│   Bar Chart             │   Line Chart          │
│   Top 20 Artists        │   Yearly Trends       │
│                         │                       │
├─────────────────────────┼───────────────────────┤
│                         │                       │
│   Pie Chart             │   Scatter Plot        │
│   Major vs Minor        │   Dance vs Energy     │
│                         │                       │
├─────────────────────────┴───────────────────────┤
│                                                 │
│              Table - Top Tracks                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ✅ Hoàn Thành!

Sau khi làm xong, click **View** để xem dashboard hoàn chỉnh và **Share** để chia sẻ link public cho portfolio.
