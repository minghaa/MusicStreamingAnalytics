"""
Music Streaming Analytics - Export to CSV for Looker Studio
Chạy script này để export dữ liệu từ CSV sang các file riêng biệt cho dashboard
"""
import pandas as pd
import os

# Paths
DATA_DIR = '/Users/tominhhaxinhdep/.gemini/antigravity/scratch/MusicStreamingAnalytics/data'
EXPORT_DIR = '/Users/tominhhaxinhdep/.gemini/antigravity/scratch/MusicStreamingAnalytics/exports'

# Load data
df = pd.read_csv(f'{DATA_DIR}/spotify_data.csv')

# Create exports directory if not exists
os.makedirs(EXPORT_DIR, exist_ok=True)

print(f"Loaded {len(df)} tracks from dataset")
print("=" * 50)

# ===== EXPORT 1: Full Dataset for Looker Studio =====
df.to_csv(f'{EXPORT_DIR}/full_dataset.csv', index=False)
print(f"✓ Exported: full_dataset.csv ({len(df)} rows)")

# ===== EXPORT 2: Top Artists Summary =====
df['primary_artist'] = df['artist_name'].str.split(',').str[0]
top_artists = df.groupby('primary_artist').agg({
    'track_id': 'count',
    'streams': ['sum', 'mean'],
    'danceability_pct': 'mean',
    'energy_pct': 'mean'
}).reset_index()
top_artists.columns = ['artist', 'track_count', 'total_streams', 'avg_streams', 'avg_danceability', 'avg_energy']
top_artists = top_artists.sort_values('total_streams', ascending=False).head(50)
top_artists['streams_billions'] = (top_artists['total_streams'] / 1e9).round(3)
top_artists.to_csv(f'{EXPORT_DIR}/top_artists.csv', index=False)
print(f"✓ Exported: top_artists.csv ({len(top_artists)} rows)")

# ===== EXPORT 3: Yearly Trends =====
yearly = df.groupby('released_year').agg({
    'track_id': 'count',
    'streams': ['sum', 'mean'],
    'danceability_pct': 'mean',
    'energy_pct': 'mean',
    'valence_pct': 'mean',
    'bpm': 'mean'
}).reset_index()
yearly.columns = ['year', 'track_count', 'total_streams', 'avg_streams', 
                  'avg_danceability', 'avg_energy', 'avg_valence', 'avg_bpm']
yearly = yearly[yearly['year'] >= 2018].sort_values('year')
yearly.to_csv(f'{EXPORT_DIR}/yearly_trends.csv', index=False)
print(f"✓ Exported: yearly_trends.csv ({len(yearly)} rows)")

# ===== EXPORT 4: Mode Distribution =====
mode_dist = df.groupby('mode').agg({
    'track_id': 'count',
    'streams': 'sum'
}).reset_index()
mode_dist.columns = ['mode', 'track_count', 'total_streams']
mode_dist['percentage'] = (mode_dist['track_count'] / mode_dist['track_count'].sum() * 100).round(1)
mode_dist.to_csv(f'{EXPORT_DIR}/mode_distribution.csv', index=False)
print(f"✓ Exported: mode_distribution.csv ({len(mode_dist)} rows)")

# ===== EXPORT 5: Audio Features (for scatter plot) =====
features = df[['track_id', 'track_name', 'artist_name', 'released_year', 
               'streams', 'danceability_pct', 'energy_pct', 'valence_pct',
               'acousticness_pct', 'bpm', 'mode', 'key']].copy()
features['streams_millions'] = (features['streams'] / 1e6).round(2)
features['primary_artist'] = features['artist_name'].str.split(',').str[0]
features.to_csv(f'{EXPORT_DIR}/audio_features.csv', index=False)
print(f"✓ Exported: audio_features.csv ({len(features)} rows)")

# ===== EXPORT 6: Monthly Heatmap Data =====
monthly = df[df['released_year'] >= 2018].groupby(['released_year', 'released_month']).agg({
    'track_id': 'count',
    'streams': ['sum', 'mean']
}).reset_index()
monthly.columns = ['year', 'month', 'track_count', 'total_streams', 'avg_streams']
month_names = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
               7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'}
monthly['month_name'] = monthly['month'].map(month_names)
monthly.to_csv(f'{EXPORT_DIR}/monthly_heatmap.csv', index=False)
print(f"✓ Exported: monthly_heatmap.csv ({len(monthly)} rows)")

# ===== EXPORT 7: Artist Tiers =====
artist_stats = df.groupby(df['artist_name'].str.split(',').str[0]).agg({
    'track_id': 'count',
    'streams': 'sum',
    'danceability_pct': 'mean',
    'energy_pct': 'mean'
}).reset_index()
artist_stats.columns = ['artist', 'track_count', 'total_streams', 'avg_danceability', 'avg_energy']

# Calculate percentiles for tiers
p90 = artist_stats['total_streams'].quantile(0.9)
p75 = artist_stats['total_streams'].quantile(0.75)
p50 = artist_stats['total_streams'].quantile(0.5)

def assign_tier(streams):
    if streams >= p90:
        return 'Superstar'
    elif streams >= p75:
        return 'A-List'
    elif streams >= p50:
        return 'Rising Star'
    else:
        return 'Emerging'

artist_stats['tier'] = artist_stats['total_streams'].apply(assign_tier)
artist_stats['streams_billions'] = (artist_stats['total_streams'] / 1e9).round(3)
artist_stats = artist_stats.sort_values('total_streams', ascending=False)
artist_stats.to_csv(f'{EXPORT_DIR}/artist_tiers.csv', index=False)
print(f"✓ Exported: artist_tiers.csv ({len(artist_stats)} rows)")

# ===== EXPORT 8: Collaboration Analysis =====
collab = df[['track_name', 'artist_name', 'artist_count', 'streams', 
             'danceability_pct', 'energy_pct', 'valence_pct']].copy()
collab['collaboration_type'] = collab['artist_count'].apply(
    lambda x: 'Solo' if x == 1 else ('Duo' if x == 2 else 'Multi (3+)'))
collab['streams_millions'] = (collab['streams'] / 1e6).round(2)
collab.to_csv(f'{EXPORT_DIR}/collaboration_analysis.csv', index=False)
print(f"✓ Exported: collaboration_analysis.csv ({len(collab)} rows)")

# ===== EXPORT 9: Platform Comparison =====
platform = df[['track_name', 'artist_name', 'streams',
               'in_spotify_playlists', 'in_spotify_charts',
               'in_apple_playlists', 'in_apple_charts',
               'in_deezer_playlists', 'in_deezer_charts',
               'in_shazam_charts']].copy()
platform['spotify_total'] = platform['in_spotify_playlists'] + platform['in_spotify_charts']
platform['apple_total'] = platform['in_apple_playlists'] + platform['in_apple_charts']
platform['deezer_total'] = platform['in_deezer_playlists'] + platform['in_deezer_charts']
platform.to_csv(f'{EXPORT_DIR}/platform_comparison.csv', index=False)
print(f"✓ Exported: platform_comparison.csv ({len(platform)} rows)")

# ===== EXPORT 10: Key Distribution =====
key_dist = df.groupby(['key', 'mode']).agg({
    'track_id': 'count',
    'streams': ['sum', 'mean'],
    'danceability_pct': 'mean',
    'energy_pct': 'mean'
}).reset_index()
key_dist.columns = ['key', 'mode', 'track_count', 'total_streams', 'avg_streams',
                    'avg_danceability', 'avg_energy']
key_dist['key_mode'] = key_dist['key'] + ' ' + key_dist['mode']
key_dist = key_dist.sort_values('track_count', ascending=False)
key_dist.to_csv(f'{EXPORT_DIR}/key_distribution.csv', index=False)
print(f"✓ Exported: key_distribution.csv ({len(key_dist)} rows)")

print("=" * 50)
print("All exports completed!")
print(f"Files saved to: {EXPORT_DIR}")
