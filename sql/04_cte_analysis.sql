-- =====================================================
-- Music Streaming Analytics - CTE Analysis Queries
-- =====================================================
-- Level: Intermediate SQL (Common Table Expressions)
-- =====================================================

-- =====================================================
-- Query 1: Top Artists by Total Streams using CTE
-- Mục đích: Tính tổng streams của mỗi nghệ sĩ với ranking
-- =====================================================
WITH artist_streams AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        COUNT(*) AS track_count,
        SUM(streams) AS total_streams,
        AVG(streams) AS avg_streams
    FROM tracks
    GROUP BY SPLIT_PART(artist_name, ',', 1)
)
SELECT 
    artist,
    track_count,
    total_streams,
    ROUND(total_streams / 1000000000.0, 2) AS streams_billions,
    ROUND(avg_streams / 1000000.0, 2) AS avg_streams_millions,
    ROUND(total_streams * 100.0 / SUM(total_streams) OVER(), 2) AS market_share_pct
FROM artist_streams
ORDER BY total_streams DESC
LIMIT 20;

-- =====================================================
-- Query 2: Monthly Release Trends with Running Totals
-- Mục đích: Phân tích xu hướng phát hành theo tháng với tổng tích lũy
-- =====================================================
WITH monthly_releases AS (
    SELECT 
        released_year,
        released_month,
        COUNT(*) AS tracks_released,
        SUM(streams) AS monthly_streams
    FROM tracks
    WHERE released_year >= 2020
    GROUP BY released_year, released_month
)
SELECT 
    released_year,
    released_month,
    TO_CHAR(TO_DATE(released_month::text, 'MM'), 'Month') AS month_name,
    tracks_released,
    monthly_streams,
    SUM(tracks_released) OVER (
        PARTITION BY released_year 
        ORDER BY released_month
    ) AS cumulative_tracks,
    SUM(monthly_streams) OVER (
        PARTITION BY released_year 
        ORDER BY released_month
    ) AS cumulative_streams
FROM monthly_releases
ORDER BY released_year DESC, released_month;

-- =====================================================
-- Query 3: Artist Ranking with Stream Percentages
-- Mục đích: Xếp hạng nghệ sĩ với tỷ lệ phần trăm streams
-- =====================================================
WITH artist_stats AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        SUM(streams) AS total_streams,
        COUNT(*) AS track_count
    FROM tracks
    GROUP BY SPLIT_PART(artist_name, ',', 1)
),
total_market AS (
    SELECT SUM(total_streams) AS market_total
    FROM artist_stats
)
SELECT 
    a.artist,
    a.track_count,
    a.total_streams,
    ROUND(a.total_streams * 100.0 / t.market_total, 3) AS market_share_pct,
    ROUND(SUM(a.total_streams) OVER (ORDER BY a.total_streams DESC) * 100.0 / t.market_total, 2) AS cumulative_share_pct
FROM artist_stats a
CROSS JOIN total_market t
ORDER BY a.total_streams DESC
LIMIT 25;

-- =====================================================
-- Query 4: Multi-level CTE - Artist Performance Tiers
-- Mục đích: Phân loại nghệ sĩ theo tiers dựa trên streams
-- =====================================================
WITH artist_performance AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        SUM(streams) AS total_streams,
        COUNT(*) AS track_count,
        AVG(danceability_pct) AS avg_danceability,
        AVG(energy_pct) AS avg_energy
    FROM tracks
    GROUP BY SPLIT_PART(artist_name, ',', 1)
),
percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_streams) AS p90,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_streams) AS p75,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_streams) AS p50
    FROM artist_performance
),
tiered_artists AS (
    SELECT 
        ap.*,
        CASE 
            WHEN ap.total_streams >= p.p90 THEN 'Superstar'
            WHEN ap.total_streams >= p.p75 THEN 'A-List'
            WHEN ap.total_streams >= p.p50 THEN 'Rising Star'
            ELSE 'Emerging'
        END AS tier
    FROM artist_performance ap
    CROSS JOIN percentiles p
)
SELECT 
    tier,
    COUNT(*) AS artist_count,
    ROUND(AVG(total_streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(track_count), 1) AS avg_tracks,
    ROUND(AVG(avg_danceability), 1) AS avg_danceability,
    ROUND(AVG(avg_energy), 1) AS avg_energy
FROM tiered_artists
GROUP BY tier
ORDER BY avg_streams_millions DESC;

-- =====================================================
-- Query 5: Year-over-Year Growth Analysis with CTE
-- Mục đích: Phân tích tăng trưởng giữa các năm
-- =====================================================
WITH yearly_stats AS (
    SELECT 
        released_year,
        COUNT(*) AS track_count,
        SUM(streams) AS total_streams,
        AVG(danceability_pct) AS avg_danceability
    FROM tracks
    WHERE released_year >= 2018
    GROUP BY released_year
),
yearly_with_prev AS (
    SELECT 
        released_year,
        track_count,
        total_streams,
        avg_danceability,
        LAG(track_count) OVER (ORDER BY released_year) AS prev_track_count,
        LAG(total_streams) OVER (ORDER BY released_year) AS prev_streams
    FROM yearly_stats
)
SELECT 
    released_year,
    track_count,
    ROUND(total_streams / 1000000000.0, 2) AS streams_billions,
    ROUND(avg_danceability, 1) AS avg_danceability,
    CASE 
        WHEN prev_track_count IS NOT NULL 
        THEN ROUND((track_count - prev_track_count) * 100.0 / prev_track_count, 1)
    END AS track_growth_pct,
    CASE 
        WHEN prev_streams IS NOT NULL 
        THEN ROUND((total_streams - prev_streams) * 100.0 / prev_streams, 1)
    END AS stream_growth_pct
FROM yearly_with_prev
ORDER BY released_year;
