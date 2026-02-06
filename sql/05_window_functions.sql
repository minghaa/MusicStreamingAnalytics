-- =====================================================
-- Music Streaming Analytics - Window Functions
-- =====================================================
-- Level: Intermediate SQL (Window Functions)
-- =====================================================

-- =====================================================
-- Query 1: RANK() - Rank Tracks Within Each Artist
-- Mục đích: Xếp hạng bài hát trong mỗi nghệ sĩ theo streams
-- =====================================================
SELECT 
    SPLIT_PART(artist_name, ',', 1) AS artist,
    track_name,
    streams,
    RANK() OVER (
        PARTITION BY SPLIT_PART(artist_name, ',', 1) 
        ORDER BY streams DESC
    ) AS rank_in_artist,
    DENSE_RANK() OVER (
        ORDER BY streams DESC
    ) AS overall_rank
FROM tracks
WHERE SPLIT_PART(artist_name, ',', 1) IN (
    SELECT SPLIT_PART(artist_name, ',', 1)
    FROM tracks
    GROUP BY SPLIT_PART(artist_name, ',', 1)
    HAVING COUNT(*) >= 10  -- Chỉ lấy artists có ít nhất 10 tracks
)
ORDER BY artist, rank_in_artist;

-- =====================================================
-- Query 2: ROW_NUMBER() - Top 3 Tracks Per Year
-- Mục đích: Lấy top 3 bài hát mỗi năm
-- =====================================================
WITH ranked_tracks AS (
    SELECT 
        track_name,
        artist_name,
        released_year,
        streams,
        ROW_NUMBER() OVER (
            PARTITION BY released_year 
            ORDER BY streams DESC
        ) AS year_rank
    FROM tracks
    WHERE released_year >= 2018
)
SELECT 
    released_year,
    year_rank,
    track_name,
    artist_name,
    ROUND(streams / 1000000.0, 2) AS streams_millions
FROM ranked_tracks
WHERE year_rank <= 3
ORDER BY released_year DESC, year_rank;

-- =====================================================
-- Query 3: LAG()/LEAD() - Compare Track Performance
-- Mục đích: So sánh với track trước/sau trong cùng nghệ sĩ
-- =====================================================
WITH artist_tracks AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        track_name,
        released_year,
        released_month,
        streams,
        LAG(streams) OVER (
            PARTITION BY SPLIT_PART(artist_name, ',', 1) 
            ORDER BY released_year, released_month
        ) AS prev_track_streams,
        LEAD(streams) OVER (
            PARTITION BY SPLIT_PART(artist_name, ',', 1) 
            ORDER BY released_year, released_month
        ) AS next_track_streams
    FROM tracks
)
SELECT 
    artist,
    track_name,
    released_year,
    streams,
    prev_track_streams,
    CASE 
        WHEN prev_track_streams IS NOT NULL AND prev_track_streams > 0
        THEN ROUND((streams - prev_track_streams) * 100.0 / prev_track_streams, 1)
    END AS growth_from_prev_pct,
    next_track_streams,
    CASE 
        WHEN next_track_streams IS NOT NULL
        THEN CASE WHEN streams > next_track_streams THEN 'Declining' ELSE 'Growing' END
    END AS trajectory
FROM artist_tracks
WHERE prev_track_streams IS NOT NULL
ORDER BY artist, released_year, released_month
LIMIT 50;

-- =====================================================
-- Query 4: NTILE() - Divide Tracks into Popularity Quartiles
-- Mục đích: Chia tracks thành 4 nhóm theo popularity
-- =====================================================
WITH track_quartiles AS (
    SELECT 
        track_name,
        artist_name,
        streams,
        danceability_pct,
        energy_pct,
        valence_pct,
        NTILE(4) OVER (ORDER BY streams DESC) AS popularity_quartile
    FROM tracks
)
SELECT 
    popularity_quartile,
    CASE popularity_quartile
        WHEN 1 THEN 'Top 25% (Viral)'
        WHEN 2 THEN 'High (25-50%)'
        WHEN 3 THEN 'Medium (50-75%)'
        WHEN 4 THEN 'Lower (75-100%)'
    END AS quartile_label,
    COUNT(*) AS track_count,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(MIN(streams) / 1000000.0, 2) AS min_streams_millions,
    ROUND(MAX(streams) / 1000000.0, 2) AS max_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence
FROM track_quartiles
GROUP BY popularity_quartile
ORDER BY popularity_quartile;

-- =====================================================
-- Query 5: SUM() OVER() - Running Total of Streams by Month
-- Mục đích: Tính tổng streams tích lũy theo thời gian
-- =====================================================
WITH monthly_streams AS (
    SELECT 
        released_year,
        released_month,
        COUNT(*) AS tracks_released,
        SUM(streams) AS monthly_total
    FROM tracks
    WHERE released_year >= 2020
    GROUP BY released_year, released_month
)
SELECT 
    released_year,
    released_month,
    TO_CHAR(TO_DATE(released_month::text, 'MM'), 'Mon') AS month_abbr,
    tracks_released,
    ROUND(monthly_total / 1000000000.0, 2) AS monthly_streams_billions,
    SUM(monthly_total) OVER (
        PARTITION BY released_year 
        ORDER BY released_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS year_cumulative,
    SUM(monthly_total) OVER (
        ORDER BY released_year, released_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS overall_cumulative,
    ROUND(AVG(monthly_total) OVER (
        ORDER BY released_year, released_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) / 1000000000.0, 2) AS moving_avg_3m_billions
FROM monthly_streams
ORDER BY released_year, released_month;

-- =====================================================
-- Query 6: FIRST_VALUE/LAST_VALUE - Best & Worst per Year
-- Mục đích: Tìm track tốt nhất và kém nhất mỗi năm
-- =====================================================
SELECT DISTINCT
    released_year,
    FIRST_VALUE(track_name) OVER (
        PARTITION BY released_year 
        ORDER BY streams DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS top_track,
    FIRST_VALUE(artist_name) OVER (
        PARTITION BY released_year 
        ORDER BY streams DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS top_artist,
    FIRST_VALUE(streams) OVER (
        PARTITION BY released_year 
        ORDER BY streams DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS top_streams,
    LAST_VALUE(track_name) OVER (
        PARTITION BY released_year 
        ORDER BY streams DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS bottom_track,
    LAST_VALUE(streams) OVER (
        PARTITION BY released_year 
        ORDER BY streams DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS bottom_streams
FROM tracks
WHERE released_year >= 2018
ORDER BY released_year DESC;
