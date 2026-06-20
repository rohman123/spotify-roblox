# Spotify + Roblox Studio Integration

Integrasi Spotify API ke Roblox Studio untuk search lagu, play 30 detik preview, dan audio features.

## ⚠️ PENTING: Jangan Upload API Keys ke GitHub!

File `ServerScript.lua` ini **TIDAK** menyertakan API Key Spotify kamu. Kamu harus setup sendiri:

### Setup Spotify API Key

1. Buka https://developer.spotify.com/dashboard
2. Login dengan akun Spotify (gratis)
3. Klik **"Create App"**
4. Isi:
   - **App Name**: `Roblox Spotify Player`
   - **App Description**: `Spotify integration for Roblox`
   - **Redirect URI**: `https://localhost`
5. Klik **"Save"**
6. Buka **Settings** → copy **Client ID** dan **Client Secret**

### Masukkan Key ke Script

Buka `ServerScript.lua`, cari baris ini:

```lua
local CLIENT_ID = "YOUR_CLIENT_ID_HERE"
local CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"
```

Ganti dengan key kamu:

```lua
local CLIENT_ID = "abc123def456..."
local CLIENT_SECRET = "xyz789..."
```

## Setup di Roblox Studio

1. Buka game kamu di Roblox Studio
2. **Game Settings** → **Security** → Enable:
   - ✅ Allow HTTP Requests
   - ✅ Enable Studio Access to API Services
3. Copy file ke tempat yang benar:

```
game
├── ServerScriptService
│   └── ServerScript.lua    ← taruh di sini
└── StarterPlayer
    └── StarterPlayerScripts
        └── LocalScript.lua ← taruh di sini
```

4. Play → tekan **E** untuk buka UI Spotify

## Features

- 🔍 Search lagu dari Spotify
- ▶ Play 30 detik preview
- ⏹ Stop playback
- 🎨 UI style Spotify
- 📱 Works on PC & mobile
- 🎵 Audio features (tempo, energy, danceability)

## Limitasi

- Hanya 30 detik preview (aturan Spotify)
- Tidak bisa play full song (copyright)
- Tidak bisa link akun Spotify user

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| "No access token" | Cek Client ID/Secret |
| "Search failed" | Enable HTTP Requests di game settings |
| "No preview" | Beberapa track tidak punya preview |
| UI tidak muncul | Tekan E atau cek StarterPlayerScripts |
