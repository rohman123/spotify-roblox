--[[
    SpotifyPlayerPart.lua
    Taruh di ServerScriptService atau sebagai child script di Part ini.
    
    Cara pakai di Roblox Studio:
    1. Buat Part di Workspace
    2. Insert ProximityPrompt ke Part
    3. Insert RemoteEvent ke ReplicatedStorage (nama: "SpotifyRemote")
    4. Insert RemoteFunction ke ReplicatedStorage (nama: "SpotifySearch")
    5. Taruh script ini sebagai child Part ATAU di ServerScriptService
    6. Pastikan ServerScript.lua (server) sudah ada di ServerScriptService
    7. Pastikan LocalScript.lua (client) sudah ada di StarterPlayerScripts
    8. Ganti CLIENT_ID dan CLIENT_SECRET di ServerScript.lua
    9. Play! Dekati Part → tekan E → GUI muncul → search lagu → play preview
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CLIENT_ID = "YOUR_CLIENT_ID_HERE"
local CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"

-- ============================================================
-- REMOTE EVENTS
-- ============================================================
local spotifyRemote = ReplicatedStorage:WaitForChild("SpotifyRemote")
local spotifySearch = ReplicatedStorage:WaitForChild("SpotifySearch")

-- ============================================================
-- SPOTIFY AUTH
-- ============================================================
local accessToken = nil
local tokenExpiry = 0

local function getAccessToken()
    if accessToken and os.time() < tokenExpiry then
        return accessToken
    end
    
    local auth = HttpService:EncodeHttp(CLIENT_ID .. ":" .. CLIENT_SECRET)
    local response = HttpService:RequestAsync({
        Url = "https://accounts.spotify.com/api/token",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Authorization"] = "Basic " .. auth
        },
        Body = "grant_type=client_credentials"
    })
    
    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        accessToken = data.access_token
        tokenExpiry = os.time() + data.expires_in - 60
        return accessToken
    end
    warn("Spotify auth failed: " .. response.StatusCode)
    return nil
end

-- ============================================================
-- SEARCH TRACK
-- ============================================================
local function searchTrack(query)
    local token = getAccessToken()
    if not token then return nil end
    
    local encodedQuery = HttpService:UrlEncode(query)
    local response = HttpService:RequestAsync({
        Url = "https://api.spotify.com/v1/search?q=" .. encodedQuery .. "&type=track&limit=5",
        Method = "GET",
        Headers = {
            ["Authorization"] = "Bearer " .. token
        }
    })
    
    if response.Success then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

-- ============================================================
-- HANDLE CLIENT REQUESTS
-- ============================================================
spotifySearch.OnServerInvoke = function(player, action, data)
    if action == "search" then
        local result = searchTrack(data)
        if result and result.tracks and result.tracks.items then
            local tracks = {}
            for _, track in ipairs(result.tracks.items) do
                table.insert(tracks, {
                    id = track.id,
                    name = track.name,
                    artist = track.artists[1] and track.artists[1].name or "Unknown",
                    album = track.album and track.album.name or "Unknown",
                    previewUrl = track.preview_url, -- 30 second preview (can be nil)
                    imageUrl = track.album and track.album.images[1] and track.album.images[1].url or "",
                    duration = track.duration_ms
                })
            end
            return tracks
        end
        return {}
    end
    return nil
end

-- ============================================================
-- BROADCAST PLAY EVENT TO ALL PLAYERS NEARBY
-- ============================================================
spotifyRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "playPreview" then
        -- Broadcast to all clients so they can hear it
        spotfyRemote:FireAllClients("playPreview", {
            trackName = data.trackName,
            artist = data.artist,
            previewUrl = data.previewUrl,
            playerName = player.Name
        })
    elseif action == "stopPreview" then
        spotifyRemote:FireAllClients("stopPreview", {
            playerName = player.Name
        })
    end
end)

print("[SpotifyPlayer] Server script loaded!")
