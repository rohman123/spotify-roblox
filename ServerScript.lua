--[[
    ServerScript.lua
    Taruh di ServerScriptService
    
    Handles:
    - Spotify authentication (client credentials)
    - Search tracks via Spotify Web API
    - Broadcast play/stop events to all clients
    
    Required Remote objects in ReplicatedStorage:
    - SpotifyRemote (RemoteEvent)
    - SpotifySearch (RemoteFunction)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================================
-- CONFIGURATION - GANTI INI DARI SPOTIFY DASHBOARD
-- ============================================================
local CLIENT_ID = "YOUR_CLIENT_ID_HERE"
local CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"

-- ============================================================
-- REMOTES
-- ============================================================
local spotifyRemote = ReplicatedStorage:WaitForChild("SpotifyRemote")
local spotifySearch = ReplicatedStorage:WaitForChild("SpotifySearch")

-- ============================================================
-- AUTH
-- ============================================================
local accessToken = nil
local tokenExpiry = 0

local function getAccessToken()
    if accessToken and os.time() < tokenExpiry then
        return accessToken
    end

    local authStr = HttpService:UrlEncode(CLIENT_ID .. ":" .. CLIENT_SECRET)
    local ok, res = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://accounts.spotify.com/api/token",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded",
                ["Authorization"] = "Basic " .. authStr
            },
            Body = "grant_type=client_credentials"
        })
    end)

    if ok and res.Success then
        local data = HttpService:JSONDecode(res.Body)
        accessToken = data.access_token
        tokenExpiry = os.time() + data.expires_in - 60
        print("[Spotify] Auth success, token expires in", data.expires_in, "seconds")
        return accessToken
    end

    warn("[Spotify] Auth failed:", ok and res.StatusCode or res)
    return nil
end

-- ============================================================
-- SEARCH
-- ============================================================
local function searchTracks(query)
    local token = getAccessToken()
    if not token then
        return { success = false, error = "Auth failed" }
    end

    local url = "https://api.spotify.com/v1/search?q="
        .. HttpService:UrlEncode(query)
        .. "&type=track&limit=5"

    local ok, res = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "GET",
            Headers = { ["Authorization"] = "Bearer " .. token }
        })
    end)

    if ok and res.Success then
        local data = HttpService:JSONDecode(res.Body)
        if data.tracks and data.tracks.items then
            local tracks = {}
            for _, t in ipairs(data.tracks.items) do
                table.insert(tracks, {
                    id = t.id,
                    name = t.name,
                    artist = t.artists[1] and t.artists[1].name or "Unknown",
                    album = t.album and t.album.name or "Unknown",
                    previewUrl = t.preview_url, -- 30s preview (bisa nil)
                    imageUrl = t.album and t.album.images[1] and t.album.images[1].url or "",
                    duration = t.duration_ms or 0
                })
            end
            return { success = true, tracks = tracks }
        end
        return { success = false, error = "No results" }
    end

    warn("[Spotify] Search failed:", ok and res.StatusCode or res)
    return { success = false, error = "Search failed" }
end

-- ============================================================
-- SERVER HANDLERS
-- ============================================================

-- Search handler
spotifySearch.OnServerInvoke = function(player, action, data)
    if action == "search" then
        return searchTracks(data)
    end
    return { success = false, error = "Unknown action" }
end

-- Play/Stop broadcast
spotifyRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "playPreview" then
        -- Broadcast to all clients
        spotifyRemote:FireAllClients("playPreview", {
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

print("[Spotify Server] Ready! Waiting for requests...")
