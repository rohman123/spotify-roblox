# 🎵 Spotify Player for Roblox Studio

Search and play Spotify 30-second previews directly inside your Roblox game. Walk up to a Part, press E, search a song, and play the preview.

## Features

- 🔍 **Search** — Real-time Spotify API search with debounce
- ▶️ **Play Preview** — 30-second Spotify previews via Roblox Sound
- 🎨 **GUI** — Clean dark-themed UI with Spotify green accents
- 🚶 **Proximity Trigger** — Walk up to a Part and press E
- 🔄 **Multiplayer Sync** — See what other players are playing
- ⏹ **Stop** — Stop playback anytime

## Setup

### 1. Spotify Developer Account

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create an App
3. Copy your **Client ID** and **Client Secret**

### 2. Roblox Studio Setup

1. Open your game in Roblox Studio
2. Go to **Game Settings → Security** → Enable **Allow HTTP Requests**
3. Create the following structure:

```
Workspace/
└── SpotifyPlayer (Part)
    └── ProximityPrompt (auto-created by script)

ServerScriptService/
├── ServerScript.lua (server auth + API handler)
└── SpotifyPlayerPart.lua (optional: Part-based server script)

StarterPlayerScripts/
├── LocalScript.lua (client GUI handler)
└── SpotifyPlayerGUI.lua (full GUI with ProximityPrompt)

ReplicatedStorage/
├── SpotifyRemote (RemoteEvent)
└── SpotifySearch (RemoteFunction)
```

4. Replace `YOUR_CLIENT_ID_HERE` and `YOUR_CLIENT_SECRET_HERE` in `ServerScript.lua`

### 3. Quick Setup (Minimal)

If you just want the basics:

1. Put `ServerScript.lua` in **ServerScriptService**
2. Put `LocalScript.lua` in **StarterPlayerScripts**
3. Create a **Part** in Workspace named `SpotifyPlayer`
4. Add a **ProximityPrompt** to it
5. Create **RemoteEvent** named `SpotifyRemote` in ReplicatedStorage
6. Create **RemoteFunction** named `SpotifySearch` in ReplicatedStorage
7. Play!

## File Structure

```
spotify-roblox/
├── README.md
├── ServerScript.lua          # Server: auth + API (minimal)
├── LocalScript.lua           # Client: GUI (minimal)
├── SpotifyPlayerPart.lua     # Server: Part-based handler
└── SpotifyPlayerGUI.lua      # Client: full GUI with animations
```

## API Reference

### ServerScript.lua
- `getAccessToken()` — Gets/renews Spotify client credentials token
- `searchTrack(query)` — Searches Spotify, returns track data
- Handles `SpotifySearch` RemoteFunction
- Broadcasts play/stop events via `SpotifyRemote`

### LocalScript.lua / SpotifyPlayerGUI.lua
- Creates search GUI on ProximityPrompt trigger
- Debounced search (500ms)
- Track cards with album art, play button
- Now Playing bar with stop button
- Smooth open/close animations

## Limitations

- ❌ Cannot play full songs (copyright/DRM)
- ✅ 30-second previews only
- ❌ Cannot control user's Spotify player
- ✅ Metadata (title, artist, album art) works

## Credits

Spotify Web API | Roblox Studio
