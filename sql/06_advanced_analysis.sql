-- =====================================================
-- Music Streaming Analytics - Advanced Analysis
-- =====================================================
-- Level: Advanced SQL (Subqueries, Complex JOINs, Analytics)
-- =====================================================

-- =====================================================
-- Query 1: Correlation Between Audio Features and Popularity
-- Mục đích: Phân tích tương quan giữa audio features và streams
-- =====================================================
WITH popularity_buckets AS (
    SELECT 
        NTILE(5) OVER (ORDER BY streams) AS popularity_bucket,
        danceability_pct,
        energy_pct,
        valence_pct,
        acousticness_pct,
        speechiness_pct,
        bpm,
        streams
    FROM tracks
)
SELECT 
    popularity_bucket,
    CASE popularity_bucket
        WHEN 1 THEN 'Lowest 20%'
        WHEN 2 THEN 'Low (20-40%)'
        WHEN 3 THEN 'Medium (40-60%)'
        WHEN 4 THEN 'High (60-80%)'
        WHEN 5 THEN 'Top 20%'
    END AS bucket_label,
    COUNT(*) AS track_count,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence,
    ROUND(AVG(acousticness_pct), 1) AS avg_acousticness,
    ROUND(AVG(speechiness_pct), 1) AS avg_speechiness,
    ROUND(AVG(bpm), 0) AS avg_bpm
FROM popularity_buckets
GROUP BY popularity_bucket
ORDER BY popularity_bucket DESC;

-- =====================================================
-- Query 2: Cross-Platform Performance Comparison
-- Mục đích: So sánh hiệu suất giữa các platform
-- =====================================================
WITH platform_metrics AS (
    SELECT 
        track_name,
        artist_name,
        streams,
        in_spotify_playlists + in_spotify_charts AS spotify_score,
        in_apple_playlists + in_apple_charts AS apple_score,
        in_deezer_playlists + in_deezer_charts AS deezer_score,
        in_shazam_charts AS shazam_score
    FROM tracks
),
normalized_scores AS (
    SELECT 
        *,
        ROUND(spotify_score * 100.0 / NULLIF(spotify_score + apple_score + deezer_score + shazam_score, 0), 1) AS spotify_pct,
        ROUND(apple_score * 100.0 / NULLIF(spotify_score + apple_score + deezer_score + shazam_score, 0), 1) AS apple_pct,
        ROUND(deezer_score * 100.0 / NULLIF(spotify_score + apple_score + deezer_score + shazam_score, 0), 1) AS deezer_pct
    FROM platform_metrics
)
SELECT 
    'Spotify' AS platform,
    ROUND(AVG(spotify_pct), 1) AS avg_share_pct,
    SUM(spotify_score) AS total_score,
    ROUND(CORR(spotify_score, streams), 3) AS correlation_with_streams
FROM normalized_scores
UNION ALL
SELECT 
    'Apple Music',
    ROUND(AVG(apple_pct), 1),
    SUM(apple_score),
    ROUND(CORR(apple_score, streams), 3)
FROM normalized_scores
UNION ALL
SELECT 
    'Deezer',
    ROUND(AVG(deezer_pct), 1),
    SUM(deezer_score),
    ROUND(CORR(deezer_score, streams), 3)
FROM normalized_scores
UNION ALL
SELECT 
    'Shazam',
    NULL,
    SUM(shazam_score),
    ROUND(CORR(shazam_score, streams), 3)
FROM normalized_scores
ORDER BY total_score DESC;

-- =====================================================
-- Query 3: Seasonal Release Patterns Analysis
-- Mục đích: Phân tích xu hướng phát hành theo mùa
-- =====================================================
WITH seasonal_data AS (
    SELECT 
        released_month,
        CASE 
            WHEN released_month IN (12, 1, 2) THEN 'Winter'
            WHEN released_month IN (3, 4, 5) THEN 'Spring'
            WHEN released_month IN (6, 7, 8) THEN 'Summer'
            WHEN released_month IN (9, 10, 11) THEN 'Fall'
        END AS season,
        streams,
        danceability_pct,
        energy_pct,
        valence_pct
    FROM tracks
    WHERE released_month IS NOT NULL
)
SELECT 
    season,
    COUNT(*) AS track_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS release_share_pct,
    ROUND(SUM(streams) / 1000000000.0, 2) AS total_streams_billions,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence
FROM seasonal_data
GROUP BY season
ORDER BY 
    CASE season 
        WHEN 'Spring' THEN 1 
        WHEN 'Summer' THEN 2 
        WHEN 'Fall' THEN 3 
        WHEN 'Winter' THEN 4 
    END;

-- =====================================================
-- Query 4: Artist Collaboration Impact Analysis
-- Mục đích: Phân tích tác động của collaboration đến streams
-- =====================================================
WITH collab_analysis AS (
    SELECT 
        artist_count,
        CASE 
            WHEN artist_count = 1 THEN 'Solo'
            WHEN artist_count = 2 THEN 'Duo'
            WHEN artist_count >= 3 THEN 'Multi (3+)'
        END AS collab_type,
        streams,
        in_spotify_playlists,
        danceability_pct,
        energy_pct
    FROM tracks
)
SELECT 
    collab_type,
    COUNT(*) AS track_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS share_pct,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(SUM(streams) / 1000000000.0, 2) AS total_streams_billions,
    ROUND(AVG(in_spotify_playlists), 0) AS avg_playlists,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    -- Compare to overall average
    ROUND(
        (AVG(streams) - (SELECT AVG(streams) FROM tracks)) * 100.0 / 
        (SELECT AVG(streams) FROM tracks), 
    1) AS vs_avg_pct
FROM collab_analysis
GROUP BY collab_type
ORDER BY avg_streams_millions DESC;

-- =====================================================
-- Query 5: Genre/Style Clustering by Audio Features
-- Mục đích: Phân cụm bài hát theo audio features
-- =====================================================
WITH feature_categories AS (
    SELECT 
        track_name,
        artist_name,
        streams,
        -- Categorize danceability
        CASE 
            WHEN danceability_pct >= 70 THEN 'High Dance'
            WHEN danceability_pct >= 40 THEN 'Medium Dance'
            ELSE 'Low Dance'
        END AS dance_category,
        -- Categorize energy
        CASE 
            WHEN energy_pct >= 70 THEN 'High Energy'
            WHEN energy_pct >= 40 THEN 'Medium Energy'
            ELSE 'Low Energy'
        END AS energy_category,
        -- Categorize valence (mood)
        CASE 
            WHEN valence_pct >= 60 THEN 'Happy/Upbeat'
            WHEN valence_pct >= 35 THEN 'Neutral'
            ELSE 'Sad/Dark'
        END AS mood_category,
        danceability_pct,
        energy_pct,
        valence_pct
    FROM tracks
)
SELECT 
    dance_category,
    energy_category,
    mood_category,
    COUNT(*) AS track_count,
    ROUND(AVG(streams) / 1000000.0, 2) AS avg_streams_millions,
    ROUND(AVG(danceability_pct), 1) AS avg_danceability,
    ROUND(AVG(energy_pct), 1) AS avg_energy,
    ROUND(AVG(valence_pct), 1) AS avg_valence
FROM feature_categories
GROUP BY dance_category, energy_category, mood_category
HAVING COUNT(*) >= 10  -- Only show significant clusters
ORDER BY track_count DESC
LIMIT 15;

-- =====================================================
-- Query 6: Year-over-Year Artist Performance Change
-- Mục đích: So sánh hiệu suất nghệ sĩ giữa các năm
-- =====================================================
WITH yearly_artist_stats AS (
    SELECT 
        SPLIT_PART(artist_name, ',', 1) AS artist,
        released_year,
        COUNT(*) AS tracks,
        SUM(streams) AS total_streams
    FROM tracks
    WHERE released_year >= 2020
    GROUP BY SPLIT_PART(artist_name, ',', 1), released_year
),
artist_yoy AS (
    SELECT 
        artist,
        released_year,
        tracks,
        total_streams,
        LAG(total_streams) OVER (PARTITION BY artist ORDER BY released_year) AS prev_year_streams,
        LAG(tracks) OVER (PARTITION BY artist ORDER BY released_year) AS prev_year_tracks
    FROM yearly_artist_stats
)
SELECT 
    artist,
    released_year,
    tracks,
    ROUND(total_streams / 1000000.0, 2) AS streams_millions,
    ROUND(prev_year_streams / 1000000.0, 2) AS prev_year_millions,
    CASE 
        WHEN prev_year_streams IS NOT NULL AND prev_year_streams > 0
        THEN ROUND((total_streams - prev_year_streams) * 100.0 / prev_year_streams, 1)
    END AS yoy_growth_pct
FROM artist_yoy
WHERE prev_year_streams IS NOT NULL
ORDER BY yoy_growth_pct DESC NULLS LAST
LIMIT 20;
