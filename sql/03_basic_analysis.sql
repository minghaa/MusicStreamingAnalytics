-- =====================================================
-- Music Streaming Analytics - Basic Analysis Queries
-- =====================================================
-- Level: Basic SQL (SELECT, WHERE, GROUP BY, ORDER BY)
-- =====================================================

-- =====================================================
-- Query 1: Top 10 Most Streamed Tracks
-- Mục đích: Tìm 10 bài hát được stream nhiều nhất
-- =====================================================
SELECT 
    track_name,
    artist_name,
    streams,
    released_year,
    -- Format streams thành đơn vị triệu
    ROUND(streams / 1000000.0, 2) AS streams_millions
FROM tracks
ORDER BY streams DESC
LIMIT 10;

-- =====================================================
-- Query 2: Artists with Most Tracks in Dataset
-- Mục đích: Tìm nghệ sĩ có nhiều bài hát nhất
-- =====================================================
SELECT 
    -- Lấy tên nghệ sĩ chính (trước dấu phẩy nếu có collaboration)
    SPLIT_PART(artist_name, ',', 1) AS primary_artist,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions
FROM tracks
GROUP BY SPLIT_PART(artist_name, ',', 1)
ORDER BY track_count DESC
LIMIT 15;

-- =====================================================
-- Query 3: Tracks Distribution by Release Year
-- Mục đích: Phân tích số lượng tracks theo năm phát hành
-- =====================================================
SELECT 
    released_year,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    MIN(streams) AS min_streams,
    MAX(streams) AS max_streams
FROM tracks
WHERE released_year IS NOT NULL
GROUP BY released_year
ORDER BY released_year DESC;

-- =====================================================
-- Query 4: Average Audio Features by Release Year
-- Mục đích: Phân tích xu hướng audio features theo thời gian
-- =====================================================
SELECT 
    released_year,
    COUNT(*) AS track_count,
    ROUND(AVG(bpm), 0) AS avg_bpm,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence,
    ROUND(AVG(acousticness_pct), 1) AS avg_acousticness
FROM tracks
WHERE released_year >= 2018
GROUP BY released_year
ORDER BY released_year;

-- =====================================================
-- Query 5: Mode Distribution (Major vs Minor)
-- Mục đích: So sánh số lượng và streams giữa Major và Minor
-- =====================================================
SELECT 
    mode,
    COUNT(*) AS track_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    SUM(streams) AS total_streams,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions
FROM tracks
WHERE mode IS NOT NULL
GROUP BY mode
ORDER BY track_count DESC;

-- =====================================================
-- Query 6: Key Distribution Analysis
-- Mục đích: Phân tích phân bố musical keys
-- =====================================================
SELECT 
    key,
    COUNT(*) AS track_count,
    SUM(streams) AS total_streams,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy
FROM tracks
WHERE key IS NOT NULL
GROUP BY key
ORDER BY track_count DESC;
