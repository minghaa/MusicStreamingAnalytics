-- =====================================================
-- Music Streaming Analytics - Load Data
-- =====================================================
-- Import dữ liệu từ CSV vào PostgreSQL
-- =====================================================

-- Cách 1: Sử dụng COPY command (chạy từ psql với quyền superuser)
-- Thay đổi đường dẫn phù hợp với hệ thống của bạn

COPY tracks(
    track_id,
    track_name,
    artist_name,
    artist_count,
    released_year,
    released_month,
    released_day,
    in_spotify_playlists,
    in_spotify_charts,
    streams,
    bpm,
    key,
    mode,
    danceability_pct,
    valence_pct,
    energy_pct,
    acousticness_pct,
    instrumentalness_pct,
    liveness_pct,
    speechiness_pct,
    in_apple_playlists,
    in_apple_charts,
    in_deezer_playlists,
    in_deezer_charts,
    in_shazam_charts
)
FROM '/Users/tominhhaxinhdep/.gemini/antigravity/scratch/MusicStreamingAnalytics/data/spotify_data.csv'
DELIMITER ','
CSV HEADER;

-- Cách 2: Nếu không có quyền superuser, sử dụng \copy trong psql
-- \copy tracks(...) FROM 'spotify_data.csv' DELIMITER ',' CSV HEADER;

-- Verify data loaded
SELECT 
    'Total tracks loaded' as metric,
    COUNT(*) as value
FROM tracks
UNION ALL
SELECT 
    'Total streams (billions)' as metric,
    ROUND(SUM(streams) / 1000000000.0, 2) as value
FROM tracks
UNION ALL
SELECT 
    'Unique artists' as metric,
    COUNT(DISTINCT artist_name) as value
FROM tracks;
