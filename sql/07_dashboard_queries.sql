-- =====================================================
-- Music Streaming Analytics - Dashboard Export Queries
-- =====================================================
-- Queries tối ưu cho Looker Studio Dashboard
-- Export kết quả ra CSV để import vào Looker Studio
-- =====================================================

-- =====================================================
-- EXPORT 1: KPI Summary
-- =====================================================
-- \copy (
SELECT 
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT SPLIT_PART(artist_name, ',', 1)) AS total_artists,
    SUM(streams) AS total_streams,
    ROUND(AVG(bpm), 0) AS avg_bpm,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    MIN(released_year) AS earliest_year,
    MAX(released_year) AS latest_year
FROM tracks;
-- ) TO '/path/to/exports/kpi_summary.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 2: Top Artists for Bar Chart
-- =====================================================
-- \copy (
SELECT 
    SPLIT_PART(artist_name, ',', 1) AS artist,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy
FROM tracks
GROUP BY SPLIT_PART(artist_name, ',', 1)
ORDER BY total_streams DESC
LIMIT 20;
-- ) TO '/path/to/exports/top_artists.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 3: Yearly Trends for Line Chart
-- =====================================================
-- \copy (
SELECT 
    released_year,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence,
    ROUND(AVG(bpm), 0) AS avg_bpm
FROM tracks
WHERE released_year >= 2018
GROUP BY released_year
ORDER BY released_year;
-- ) TO '/path/to/exports/yearly_trends.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 4: Mode Distribution for Pie Chart
-- =====================================================
-- \copy (
SELECT 
    mode,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM tracks
WHERE mode IS NOT NULL
GROUP BY mode;
-- ) TO '/path/to/exports/mode_distribution.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 5: Audio Features for Scatter Plot
-- =====================================================
-- \copy (
SELECT 
    track_id,
    track_name,
    SPLIT_PART(artist_name, ',', 1) AS artist,
    released_year,
    streams,
    ROUND(streams / 1000000.0, 2) AS streams_millions,
    danceability_pct,
    energy_pct,
    valence_pct,
    acousticness_pct,
    bpm,
    mode,
    key
FROM tracks
ORDER BY streams DESC;
-- ) TO '/path/to/exports/tracks_features.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 6: Monthly Release Heatmap Data
-- =====================================================
-- \copy (
SELECT 
    released_year,
    released_month,
    TO_CHAR(TO_DATE(released_month::text, 'MM'), 'Mon') AS month_name,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions
FROM tracks
WHERE released_year >= 2018
GROUP BY released_year, released_month
ORDER BY released_year, released_month;
-- ) TO '/path/to/exports/monthly_heatmap.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 7: Artist Performance Tiers
-- =====================================================
-- \copy (
WITH artist_stats AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        COUNT(*) AS track_count,
        SUM(streams) AS total_streams,
        ROUND(AVG(danceability_pct), 1) AS avg_danceability,
        ROUND(AVG(energy_pct), 1) AS avg_energy
    FROM tracks
    GROUP BY SPLIT_PART(artist_name, ',', 1)
),
percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_streams) AS p90,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_streams) AS p75,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_streams) AS p50
    FROM artist_stats
)
SELECT 
    a.artist,
    a.track_count,
    a.total_streams,
    ROUND(a.total_streams / 1000000000.0, 3) AS streams_billions,
    a.avg_danceability,
    a.avg_energy,
    CASE 
        WHEN a.total_streams >= p.p90 THEN 'Superstar'
        WHEN a.total_streams >= p.p75 THEN 'A-List'
        WHEN a.total_streams >= p.p50 THEN 'Rising Star'
        ELSE 'Emerging'
    END AS tier
FROM artist_stats a
CROSS JOIN percentiles p
ORDER BY a.total_streams DESC;
-- ) TO '/path/to/exports/artist_tiers.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 8: Platform Comparison
-- =====================================================
-- \copy (
SELECT 
    track_name,
    SPLIT_PART(artist_name, ',', 1) AS artist,
    streams,
    in_spotify_playlists,
    in_spotify_charts,
    in_apple_playlists,
    in_apple_charts,
    in_deezer_playlists,
    in_deezer_charts,
    in_shazam_charts,
    (in_spotify_playlists + in_spotify_charts) AS spotify_total,
    (in_apple_playlists + in_apple_charts) AS apple_total,
    (in_deezer_playlists + in_deezer_charts) AS deezer_total
FROM tracks
ORDER BY streams DESC;
-- ) TO '/path/to/exports/platform_comparison.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 9: Collaboration Analysis
-- =====================================================
-- \copy (
SELECT 
    track_name,
    artist_name,
    artist_count,
    CASE 
        WHEN artist_count = 1 THEN 'Solo'
        WHEN artist_count = 2 THEN 'Collaboration (2)'
        ELSE 'Multi-Collaboration (3+)'
    END AS collaboration_type,
    streams,
    ROUND(streams / 1000000.0, 2) AS streams_millions,
    danceability_pct,
    energy_pct,
    valence_pct
FROM tracks
ORDER BY streams DESC;
-- ) TO '/path/to/exports/collaboration_analysis.csv' WITH CSV HEADER;

-- =====================================================
-- EXPORT 10: Key Distribution Analysis
-- =====================================================
-- \copy (
SELECT 
    key,
    mode,
    CONCAT(key, ' ', mode) AS key_mode,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy
FROM tracks
WHERE key IS NOT NULL
GROUP BY key, mode
ORDER BY track_count DESC;
-- ) TO '/path/to/exports/key_distribution.csv' WITH CSV HEADER;
