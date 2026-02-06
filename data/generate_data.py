import csv
import random
from datetime import datetime

# Seed for reproducibility
random.seed(42)

# Sample data for generation
artists = [
    "Taylor Swift", "The Weeknd", "Bad Bunny", "Drake", "Ed Sheeran",
    "Harry Styles", "Dua Lipa", "BTS", "Ariana Grande", "Post Malone",
    "Billie Eilish", "Justin Bieber", "Doja Cat", "Olivia Rodrigo", "SZA",
    "Beyoncé", "Kendrick Lamar", "Travis Scott", "Rihanna", "Bruno Mars",
    "Adele", "Miley Cyrus", "Shakira", "Lady Gaga", "Coldplay",
    "Imagine Dragons", "Maroon 5", "OneRepublic", "The Chainsmokers", "Marshmello",
    "Calvin Harris", "David Guetta", "Tiësto", "Martin Garrix", "Kygo",
    "Daft Punk", "Avicii", "Zedd", "Skrillex", "Diplo",
    "Kanye West", "J. Cole", "Lil Baby", "Future", "21 Savage",
    "Metro Boomin", "Morgan Wallen", "Luke Combs", "Chris Stapleton", "Zach Bryan"
]

track_adjectives = ["Love", "Night", "Dreams", "Heart", "Stars", "Fire", "Rain", "Summer", "Dance", "Forever",
                   "Wild", "Golden", "Midnight", "Sunset", "Electric", "Neon", "Crystal", "Velvet", "Silver", "Ocean"]
track_nouns = ["Story", "Memories", "Vibes", "Feelings", "Moments", "Nights", "Days", "Times", "Ways", "Eyes",
              "Lights", "Shadows", "Clouds", "Waves", "Streets", "Hills", "Rivers", "Skies", "Roads", "Dreams"]

keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
modes = ["Major", "Minor"]

# Generate tracks
tracks = []
track_id = 1

for _ in range(953):  # Generate ~950 tracks similar to real dataset
    artist = random.choice(artists)
    
    # Some tracks have multiple artists
    artist_count = random.choices([1, 2, 3, 4], weights=[70, 20, 7, 3])[0]
    if artist_count > 1:
        collaborators = random.sample([a for a in artists if a != artist], artist_count - 1)
        artist_name = artist + ", " + ", ".join(collaborators)
    else:
        artist_name = artist
    
    # Track name
    track_name = f"{random.choice(track_adjectives)} {random.choice(track_nouns)}"
    if random.random() > 0.7:
        track_name += f" ({random.choice(['Remix', 'feat. DJ', 'Acoustic', 'Live', 'Deluxe'])})"
    
    # Release date (2018-2024)
    year = random.choices(range(2018, 2025), weights=[5, 8, 12, 15, 20, 25, 15])[0]
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    
    # Streaming metrics - exponential distribution for realistic long-tail
    base_streams = random.randint(10000000, 100000000)
    popularity_factor = random.expovariate(1.5) + 0.5
    streams = int(base_streams * popularity_factor)
    
    # Playlist and chart appearances (correlated with streams)
    stream_tier = min(streams / 500000000, 1)
    in_spotify_playlists = int(random.gauss(5000, 2000) * (0.3 + stream_tier))
    in_spotify_charts = random.randint(0, 73) if streams > 100000000 else random.randint(0, 30)
    in_apple_playlists = int(in_spotify_playlists * random.uniform(0.3, 0.6))
    in_apple_charts = random.randint(0, 50) if streams > 100000000 else random.randint(0, 20)
    in_deezer_playlists = int(in_spotify_playlists * random.uniform(0.2, 0.5))
    in_deezer_charts = random.randint(0, 40) if streams > 100000000 else random.randint(0, 15)
    in_shazam_charts = random.randint(0, 50) if streams > 100000000 else random.randint(0, 10)
    
    # Audio features
    bpm = random.randint(60, 200)
    key = random.choice(keys)
    mode = random.choice(modes)
    danceability = random.randint(20, 95)
    valence = random.randint(10, 95)
    energy = random.randint(15, 98)
    acousticness = random.randint(0, 90)
    instrumentalness = random.randint(0, 50)
    liveness = random.randint(5, 40)
    speechiness = random.randint(2, 45)
    
    tracks.append({
        'track_id': track_id,
        'track_name': track_name,
        'artist_name': artist_name,
        'artist_count': artist_count,
        'released_year': year,
        'released_month': month,
        'released_day': day,
        'in_spotify_playlists': max(0, in_spotify_playlists),
        'in_spotify_charts': in_spotify_charts,
        'streams': streams,
        'bpm': bpm,
        'key': key,
        'mode': mode,
        'danceability_pct': danceability,
        'valence_pct': valence,
        'energy_pct': energy,
        'acousticness_pct': acousticness,
        'instrumentalness_pct': instrumentalness,
        'liveness_pct': liveness,
        'speechiness_pct': speechiness,
        'in_apple_playlists': max(0, in_apple_playlists),
        'in_apple_charts': in_apple_charts,
        'in_deezer_playlists': max(0, in_deezer_playlists),
        'in_deezer_charts': in_deezer_charts,
        'in_shazam_charts': in_shazam_charts
    })
    track_id += 1

# Write to CSV
output_path = '/Users/tominhhaxinhdep/.gemini/antigravity/scratch/MusicStreamingAnalytics/data/spotify_data.csv'
with open(output_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=tracks[0].keys())
    writer.writeheader()
    writer.writerows(tracks)

print(f"Generated {len(tracks)} tracks to {output_path}")
print(f"Sample track: {tracks[0]}")
