-- ServerScriptService/SpotifyServerScript
-- Server-side Spotify integration

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Spotify API credentials
-- GANTI DENGAN CREDENTIALS KAMU!
local CLIENT_ID = "YOUR_CLIENT_ID_HERE"
local CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"

-- Remote events
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "SpotifyRemote"
remoteEvent.Parent = ReplicatedStorage

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "SpotifyRemoteFunction"
remoteFunction.Parent = ReplicatedStorage

-- Cache for access token
local cachedToken = nil
local tokenExpiry = 0

-- ============================================
-- SPOTIFY AUTH
-- ============================================

local function getAccessToken()
    -- Return cached token if still valid
    if cachedToken and os.time() < tokenExpiry then
        return cachedToken
    end

    -- Request new token using Client Credentials flow
    local url = "https://accounts.spotify.com/api/token"
    local body = HttpService:Encode({
        grant_type = "client_credentials",
        client_id = CLIENT_ID,
        client_secret = CLIENT_SECRET
    })

    local success, response = pcall(function()
        return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationUrlEncoded)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data.access_token then
            cachedToken = data.access_token
            tokenExpiry = os.time() + (data.expires_in or 3600) - 60 -- refresh 1 min before expiry
            print("[Spotify] Token refreshed successfully")
            return cachedToken
        else
            warn("[Spotify] Failed to get token:", response)
            return nil
        end
    else
        warn("[Spotify] Auth request failed:", response)
        return nil
    end
end

-- ============================================
-- SPOTIFY API CALLS
-- ============================================

local function spotifyAPI(endpoint, method, body)
    local token = getAccessToken()
    if not token then
        return nil, "No access token"
    end

    local url = "https://api.spotify.com/v1" .. endpoint
    local headers = {
        ["Authorization"] = "Bearer " .. token,
        ["Content-Type"] = "application/json"
    }

    local success, response = pcall(function()
        if method == "POST" and body then
            return HttpService:PostAsync(url, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
        else
            return HttpService:GetAsync(url, false, headers)
        end
    end)

    if success then
        return HttpService:JSONDecode(response), nil
    else
        return nil, response
    end
end

-- Search for tracks
local function searchTracks(query, limit)
    limit = limit or 5
    local encodedQuery = HttpService:UrlEncode(query)
    local data, err = spotifyAPI("/search?q=" .. encodedQuery .. "&type=track&limit=" .. limit)
    if data and data.tracks then
        return data.tracks.items
    end
    return nil, err
end

-- Get track details
local function getTrack(trackId)
    return spotifyAPI("/tracks/" .. trackId)
end

-- Get track audio features (tempo, energy, etc.)
local function getAudioFeatures(trackId)
    return spotifyAPI("/audio-features/" .. trackId)
end

-- Get recommendations
local function getRecommendations(seedTrackId, limit)
    limit = limit or 5
    local data, err = spotifyAPI("/recommendations?seed_tracks=" .. seedTrackId .. "&limit=" .. limit)
    if data then
        return data.tracks
    end
    return nil, err
end

-- ============================================
-- SOUND MANAGEMENT
-- ============================================

local activeSounds = {}

local function playPreview(previewUrl, player, volume)
    if not previewUrl then
        return false, "No preview URL available"
    end

    -- Stop existing sound for this player
    if activeSounds[player.UserId] then
        activeSounds[player.UserId]:Stop()
        activeSounds[player.UserId] = nil
    end

    -- Create new sound
    local sound = Instance.new("Sound")
    sound.SoundId = previewUrl
    sound.Volume = volume or 0.5
    sound.Looped = false
    sound.Parent = workspace

    -- Play
    sound:Play()
    activeSounds[player.UserId] = sound

    -- Auto cleanup when done
    sound.Ended:Connect(function()
        sound:Destroy()
        if activeSounds[player.UserId] == sound then
            activeSounds[player.UserId] = nil
        end
    end)

    return true
end

local function stopPreview(player)
    if activeSounds[player.UserId] then
        activeSounds[player.UserId]:Stop()
        activeSounds[player.UserId]:Destroy()
        activeSounds[player.UserId] = nil
    end
end

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

-- Client requests search
remoteFunction.OnServerInvoke = function(player, action, ...)
    local args = {...}

    if action == "search" then
        local query = args[1]
        if not query or query == "" then
            return {success = false, error = "No query provided"}
        end

        local tracks, err = searchTracks(query, 5)
        if tracks then
            -- Format results for client
            local results = {}
            for i, track in ipairs(tracks) do
                table.insert(results, {
                    id = track.id,
                    name = track.name,
                    artist = track.artists[1] and track.artists[1].name or "Unknown",
                    album = track.album and track.album.name or "Unknown",
                    previewUrl = track.preview_url, -- 30 second preview
                    duration = track.duration_ms,
                    imageUrl = track.album.images[1] and track.album.images[1].url or "",
                    externalUrl = track.external_urls and track.external_urls.spotify or ""
                })
            end
            return {success = true, tracks = results}
        else
            return {success = false, error = err or "Search failed"}
        end

    elseif action == "playPreview" then
        local previewUrl = args[1]
        local volume = args[2] or 0.5
        local success, err = playPreview(previewUrl, player, volume)
        return {success = success, error = err}

    elseif action == "stopPreview" then
        stopPreview(player)
        return {success = true}

    elseif action == "getTrack" then
        local trackId = args[1]
        local track, err = getTrack(trackId)
        if track then
            return {success = true, track = {
                id = track.id,
                name = track.name,
                artist = track.artists[1] and track.artists[1].name or "Unknown",
                album = track.album and track.album.name or "Unknown",
                previewUrl = track.preview_url,
                duration = track.duration_ms,
                imageUrl = track.album.images[1] and track.album.images[1].url or ""
            }}
        else
            return {success = false, error = err}
        end

    elseif action == "getAudioFeatures" then
        local trackId = args[1]
        local features, err = getAudioFeatures(trackId)
        if features then
            return {success = true, features = {
                tempo = features.tempo,
                energy = features.energy,
                danceability = features.danceability,
                valence = features.valence,
                acousticness = features.acousticness,
                instrumentalness = features.instrumentalness
            }}
        else
            return {success = false, error = err}
        end

    elseif action == "getRecommendations" then
        local trackId = args[1]
        local limit = args[2] or 5
        local tracks, err = getRecommendations(trackId, limit)
        if tracks then
            local results = {}
            for i, track in ipairs(tracks) do
                table.insert(results, {
                    id = track.id,
                    name = track.name,
                    artist = track.artists[1] and track.artists[1].name or "Unknown",
                    previewUrl = track.preview_url,
                    imageUrl = track.album.images[1] and track.album.images[1].url or ""
                })
            end
            return {success = true, tracks = results}
        else
            return {success = false, error = err}
        end

    else
        return {success = false, error = "Unknown action: " .. tostring(action)}
    end
end

-- Client sends simple messages
remoteEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "stopPreview" then
        stopPreview(player)
    end
end)

print("[Spotify Server] Initialized")
