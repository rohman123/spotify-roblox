# 🎵 Spotify Player for Roblox Studio

Search and play Spotify 30-second previews directly inside your Roblox game. Walk up to a Part, press E or use ProximityPrompt, search a song, and play the preview.

## Features

- 🔍 **Search** — Real-time Spotify API search with debounce
- ▶️ **Play Preview** — 30-second Spotify previews via Roblox Sound
- 🎨 **GUI** — Clean dark-themed UI with Spotify green accents, smooth animations
- 🚶 **Proximity Trigger** — Walk up to a Part named `SpotifyPart` and press E
- ⌨️ **Keyboard Toggle** — Press E anywhere to toggle the UI
- 🔄 **Multiplayer Sync** — See what other players are playing
- ⏹ **Stop** — Stop playback anytime

## File Structure

```
spotify-roblox/
├── README.md           # This file
├── ServerScript.lua    # Server: auth + API handler → taruh di ServerScriptService
└── LocalScript.lua     # Client: GUI + ProximityPrompt → taruh di StarterPlayerScripts
```

## Setup

### Step 1: Spotify Developer Account (5 menit)

1. Buka [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Login pake akun Spotify (gratis boleh)
3. Klik **Create App**
4. Isi:
   - **App name**: `Roblox Player`
   - **Description**: `Spotify player for Roblox`
   - **Redirect URI**: `http://localhost`
   - Pilih **Web API**
5. Klik **Save**
6. Masuk ke app → klik **Settings** → copy **Client ID** dan **Client Secret**

### Step 2: Enable HTTP Request di Roblox Studio

1. Buka project di Roblox Studio
2. Klik **Home → Game Settings → Security**
3. Centang **Allow HTTP Requests**
4. Klik **Save**

### Step 3: Buat Remote Objects di ReplicatedStorage

1. Di Explorer, klik **ReplicatedStorage**
2. Klik kanan → Insert Object → **RemoteEvent** → rename jadi `SpotifyRemote`
3. Klik kanan → Insert Object → **RemoteFunction** → rename jadi `SpotifySearch`

```
ReplicatedStorage
├── SpotifyRemote (RemoteEvent)
└── SpotifySearch (RemoteFunction)
```

### Step 4: Create the Part (untuk ProximityPrompt)

1. Insert **Part** di **Workspace**
2. Rename jadi `SpotifyPart`
3. Atur ukuran & posisi sesuai selera
4. Opsional: kasih warna glow biar keliatan keren

```
Workspace
└── SpotifyPart (Part)
```

### Step 5: Add Server Script

1. Open file **ServerScript.lua** dari repo ini
2. Ganti `YOUR_CLIENT_ID_HERE` dan `YOUR_CLIENT_SECRET_HERE` dengan credentials dari Step 1
3. Copy seluruh isi file
4. Di Roblox Studio, klik **ServerScriptService**
5. Klik kanan → Insert Object → **Script** → rename jadi `SpotifyHandler`
6. Paste code-nya

### Step 6: Add Client Script

1. Open file **LocalScript.lua** dari repo ini
2. Copy seluruh isi file
3. Di Roblox Studio, klik **StarterPlayer → StarterPlayerScripts**
4. Klik kanan → Insert Object → **LocalScript** → rename jadi `SpotifyGUI`
5. Paste code-nya

### Step 7: Test!

1. Klik **Play** di Roblox Studio
2. Tekan **E** (toggle GUI) ATAU dekati Part `SpotifyPart`
3. Ketik nama lagu di search bar
4. Tekan **Enter** atau tunggu auto-search
5. Klik **▶ Play** di track card
6. Dengar preview 30 detik 🎵

## Final Roblox Structure

```
game
├── ReplicatedStorage
│   ├── SpotifyRemote (RemoteEvent)
│   └── SpotifySearch (RemoteFunction)
├── ServerScriptService
│   └── SpotifyHandler (Script) ← ServerScript.lua
├── StarterPlayer
│   └── StarterPlayerScripts
│       └── SpotifyGUI (LocalScript) ← LocalScript.lua
└── Workspace
    └── SpotifyPart (Part)
```

## Troubleshooting

| Problem | Solusi |
|---|---|
| GUI tidak muncul | Tekan E, atau pastikan part bernama `SpotifyPart` ada di Workspace |
| "Auth failed" | Cek Client ID & Server Script sudah benar |
| "Search failed" | Pastikan Allow HTTP Requests sudah di-enable |
| Suara tidak keluar | Cek SoundService, cek volume game |
| "No preview available" | Tidak semua lagu punya preview — coba lagu lain |

## Limitations

- ❌ Tidak bisa play full song (copyright/DRM) — hanya **30 detik preview**
- ❌ Tidak bisa control Spotify player user
- ✅ Metadata (judul, artis, album cover) berfungsi
- ✅ Multiplayer sync notification

## Credits

Spotify Web API | Roblox Studio
