-- =====================================================
-- Music Streaming Analytics - Database Schema
-- =====================================================
-- Tạo database và table cho dữ liệu Spotify
-- =====================================================

-- Tạo database (chạy riêng nếu cần)
-- CREATE DATABASE music_streaming;

-- Kết nối đến database
-- \c music_streaming

-- Xóa table cũ nếu tồn tại
DROP TABLE IF EXISTS tracks CASCADE;

-- Tạo table chính
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    track_name VARCHAR(500) NOT NULL,
    artist_name VARCHAR(500) NOT NULL,
    artist_count INTEGER DEFAULT 1,
    
    -- Release date
    released_year INTEGER,
    released_month INTEGER,
    released_day INTEGER,
    
    -- Spotify metrics
    in_spotify_playlists INTEGER DEFAULT 0,
    in_spotify_charts INTEGER DEFAULT 0,
    streams BIGINT DEFAULT 0,
    
    -- Audio features
    bpm INTEGER,
    key VARCHAR(10),
    mode VARCHAR(10),
    danceability_pct INTEGER CHECK (danceability_pct >= 0 AND danceability_pct <= 100),
    valence_pct INTEGER CHECK (valence_pct >= 0 AND valence_pct <= 100),
    energy_pct INTEGER CHECK (energy_pct >= 0 AND energy_pct <= 100),
    acousticness_pct INTEGER CHECK (acousticness_pct >= 0 AND acousticness_pct <= 100),
    instrumentalness_pct INTEGER CHECK (instrumentalness_pct >= 0 AND instrumentalness_pct <= 100),
    liveness_pct INTEGER CHECK (liveness_pct >= 0 AND liveness_pct <= 100),
    speechiness_pct INTEGER CHECK (speechiness_pct >= 0 AND speechiness_pct <= 100),
    
    -- Cross-platform metrics
    in_apple_playlists INTEGER DEFAULT 0,
    in_apple_charts INTEGER DEFAULT 0,
    in_deezer_playlists INTEGER DEFAULT 0,
    in_deezer_charts INTEGER DEFAULT 0,
    in_shazam_charts INTEGER DEFAULT 0,
    
    -- Indexes for common queries
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo indexes để tối ưu performance
CREATE INDEX idx_tracks_artist ON tracks(artist_name);
CREATE INDEX idx_tracks_year ON tracks(released_year);
CREATE INDEX idx_tracks_streams ON tracks(streams DESC);
CREATE INDEX idx_tracks_year_month ON tracks(released_year, released_month);

-- Comment cho documentation
COMMENT ON TABLE tracks IS 'Music streaming data with audio features and cross-platform metrics';
COMMENT ON COLUMN tracks.bpm IS 'Beats per minute - tempo of the track';
COMMENT ON COLUMN tracks.danceability_pct IS 'How suitable the track is for dancing (0-100)';
COMMENT ON COLUMN tracks.valence_pct IS 'Musical positiveness/happiness conveyed (0-100)';
COMMENT ON COLUMN tracks.energy_pct IS 'Intensity and activity measure (0-100)';
