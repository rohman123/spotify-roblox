--[[
    LocalScript.lua
    Taruh di StarterPlayerScripts
    
    Handles:
    - Search UI (search bar, track list, play buttons)
    - ProximityPrompt on "SpotifyPart" in Workspace
    - Play/Stop 30s preview via Sound object
    - Multiplayer notifications
    
    Required Remote objects in ReplicatedStorage:
    - SpotifyRemote (RemoteEvent)
    - SpotifySearch (RemoteFunction)
    
    Required in Workspace:
    - SpotifyPart (BasePart) — optional, untuk ProximityPrompt
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- REMOTES (harus sama dengan ServerScript)
-- ============================================================
local spotifyRemote = ReplicatedStorage:WaitForChild("SpotifyRemote")
local spotifySearch = ReplicatedStorage:WaitForChild("SpotifySearch")

-- ============================================================
-- CREATE GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpotifyUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.ZIndex = -1
shadow.Parent = mainFrame

-- Header (Spotify green)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Fix bottom corners of header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎵 Spotify Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0.75
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Search bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -24, 0, 38)
searchFrame.Position = UDim2.new(0, 12, 0, 56)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 19)
searchCorner.Parent = searchFrame

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.Position = UDim2.new(0, 8, 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 14
searchIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -45, 1, 0)
searchBox.Position = UDim2.new(0, 35, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search for a song..."
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- Track list (ScrollingFrame)
local trackList = Instance.new("ScrollingFrame")
trackList.Name = "TrackList"
trackList.Size = UDim2.new(1, -24, 0, 310)
trackList.Position = UDim2.new(0, 12, 0, 102)
trackList.BackgroundTransparency = 1
trackList.BorderSizePixel = 0
trackList.ScrollBarThickness = 4
trackList.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
trackList.AutomaticCanvasSize = Enum.AutomaticSize.Y
trackList.CanvasSize = UDim2.new(0, 0, 0, 0)
trackList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = trackList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.Parent = trackList

-- Now Playing bar
local nowPlaying = Instance.new("Frame")
nowPlaying.Name = "NowPlaying"
nowPlaying.Size = UDim2.new(1, 0, 0, 0) -- hidden
nowPlaying.Position = UDim2.new(0, 0, 1, 0)
nowPlaying.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nowPlaying.BorderSizePixel = 0
nowPlaying.ClipsDescendants = true
nowPlaying.Parent = mainFrame

local npCorner = Instance.new("UICorner")
npCorner.CornerRadius = UDim.new(0, 12)
npCorner.Parent = nowPlaying

local npFix = Instance.new("Frame")
npFix.Size = UDim2.new(1, 0, 0, 14)
npFix.Position = UDim2.new(0, 0, 0, 0)
npFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
npFix.BorderSizePixel = 0
npFix.Parent = nowPlaying

local npIcon = Instance.new("TextLabel")
npIcon.Size = UDim2.new(0, 28, 0, 44)
npIcon.Position = UDim2.new(0, 10, 0, 0)
npIcon.BackgroundTransparency = 1
npIcon.Text = "🎶"
npIcon.TextSize = 18
npIcon.Parent = nowPlaying

local npName = Instance.new("TextLabel")
npName.Size = UDim2.new(1, -90, 0, 22)
npName.Position = UDim2.new(0, 40, 0, 4)
npName.BackgroundTransparency = 1
npName.Text = ""
npName.TextColor3 = Color3.fromRGB(30, 215, 96)
npName.TextSize = 13
npName.Font = Enum.Font.GothamBold
npName.TextXAlignment = Enum.TextXAlignment.Left
npName.TextTruncate = Enum.TextTruncate.AtEnd
npName.Parent = nowPlaying

local npArtist = Instance.new("TextLabel")
npArtist.Size = UDim2.new(1, -90, 0, 18)
npArtist.Position = UDim2.new(0, 40, 0, 24)
npArtist.BackgroundTransparency = 1
npArtist.Text = ""
npArtist.TextColor3 = Color3.fromRGB(160, 160, 160)
npArtist.TextSize = 11
npArtist.Font = Enum.Font.Gotham
npArtist.TextXAlignment = Enum.TextXAlignment.Left
npArtist.TextTruncate = Enum.TextTruncate.AtEnd
npArtist.Parent = nowPlaying

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 54, 0, 30)
stopBtn.Position = UDim2.new(1, -64, 0, 7)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
stopBtn.Text = "⏹ Stop"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 11
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.Parent = nowPlaying

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopBtn

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 18)
statusLabel.Position = UDim2.new(0, 12, 1, -22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Walk to the Spotify Part and press E"
statusLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- ============================================================
-- STATE
-- ============================================================
local isVisible = false
local currentSound = nil

-- ============================================================
-- FUNCTIONS
-- ============================================================

local function clearTrackList()
    for _, child in ipairs(trackList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function showNowPlaying(trackName, artist)
    npName.Text = trackName
    npArtist.Text = artist
    nowPlaying.Size = UDim2.new(1, 0, 0, 44)
    nowPlaying.Position = UDim2.new(0, 0, 1, -44)
end

local function hideNowPlaying()
    nowPlaying.Size = UDim2.new(1, 0, 0, 0)
    nowPlaying.Position = UDim2.new(0, 0, 1, 0)
end

local function createTrackCard(track, index)
    local card = Instance.new("Frame")
    card.Name = "Track_" .. (track.id or tostring(index))
    card.Size = UDim2.new(1, -8, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.Parent = trackList

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55, 55, 55) }):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
    end)

    -- Album art
    local albumArt = Instance.new("ImageLabel")
    albumArt.Size = UDim2.new(0, 38, 0, 38)
    albumArt.Position = UDim2.new(0, 7, 0, 7)
    albumArt.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    albumArt.Image = track.imageUrl or ""
    albumArt.Parent = card

    local artCorner = Instance.new("UICorner")
    artCorner.CornerRadius = UDim.new(0, 4)
    artCorner.Parent = albumArt

    -- Track name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 52, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = track.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card

    -- Artist
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Size = UDim2.new(1, -120, 0, 18)
    artistLabel.Position = UDim2.new(0, 52, 0, 26)
    artistLabel.BackgroundTransparency = 1
    artistLabel.Text = track.artist .. " • " .. track.album
    artistLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    artistLabel.TextSize = 11
    artistLabel.Font = Enum.Font.Gotham
    artistLabel.TextXAlignment = Enum.TextXAlignment.Left
    artistLabel.TextTruncate = Enum.TextTruncate.AtEnd
    artistLabel.Parent = card

    -- Play button
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0, 56, 0, 30)
    playBtn.Position = UDim2.new(1, -64, 0, 11)
    playBtn.BackgroundColor3 = track.previewUrl and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(70, 70, 70)
    playBtn.Text = track.previewUrl and "▶ Play" : "N/A"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.TextSize = 11
    playBtn.Font = Enum.Font.GothamBold
    playBtn.BorderSizePixel = 0
    playBtn.Parent = card

    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 8)
    playCorner.Parent = playBtn

    if track.previewUrl then
        playBtn.MouseButton1Click:Connect(function()
            -- Stop current sound
            if currentSound then
                currentSound:Stop()
                currentSound:Destroy()
                currentSound = nil
            end

            -- Play new preview
            currentSound = Instance.new("Sound")
            currentSound.SoundId = track.previewUrl
            currentSound.Volume = 0.7
            currentSound.Parent = SoundService
            currentSound:Play()

            showNowPlaying(track.name, track.artist)
            statusLabel.Text = "▶ Playing: " .. track.name
            statusLabel.TextColor3 = Color3.fromRGB(30, 215, 96)

            -- Notify server (multiplayer)
            spotifyRemote:FireServer("playPreview", {
                trackName = track.name,
                artist = track.artist,
                previewUrl = track.previewUrl
            })

            -- Auto-hide when done
            currentSound.Ended:Connect(function()
                hideNowPlaying()
                statusLabel.Text = ""
                if currentSound then
                    currentSound:Destroy()
                    currentSound = nil
                end
            end)
        end)
    end

    return card
end

local function doSearch(query)
    if query == "" then
        clearTrackList()
        statusLabel.Text = ""
        return
    end

    statusLabel.Text = "🔍 Searching..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)

    local ok, result = pcall(function()
        return spotifySearch:InvokeServer("search", query)
    end)

    clearTrackList()

    if ok and result and result.success and result.tracks then
        local count = #result.tracks
        if count == 0 then
            statusLabel.Text = "😕 No results found"
            statusLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        else
            statusLabel.Text = "✅ Found " .. count .. " tracks"
            statusLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
            for i, track in ipairs(result.tracks) do
                createTrackCard(track, i)
            end
        end
    else
        local errMsg = (ok and result and result.error) or "Search failed"
        statusLabel.Text = "❌ " .. errMsg
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

local function toggleUI()
    isVisible = not isVisible
    if isVisible then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 400, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 500)
        }):Play()
        task.wait(0.25)
        searchBox:CaptureFocus()
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 400, 0, 0)
        }):Play()
        task.wait(0.2)
        mainFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 400, 0, 500)
        if currentSound then
            currentSound:Stop()
        end
    end
end

-- ============================================================
-- EVENT CONNECTIONS
-- ============================================================

closeBtn.MouseButton1Click:Connect(function()
    isVisible = false
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 400, 0, 0)
    }):Play()
    task.wait(0.2)
    mainFrame.Visible = false
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    if currentSound then currentSound:Stop() end
end)

-- Search on Enter
searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and searchBox.Text ~= "" then
        doSearch(searchBox.Text)
    end
end)

-- Search debounce on text change
local searchDebounce = false
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then return end
    searchDebounce = true
    task.wait(0.6)
    if searchBox.Text ~= "" then
        doSearch(searchBox.Text)
    else
        clearTrackList()
        statusLabel.Text = ""
    end
    searchDebounce = false
end)

-- Stop button
stopBtn.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
    hideNowPlaying()
    statusLabel.Text = "⏹ Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    spotifyRemote:FireServer("stopPreview", {})
end)

-- Keyboard toggle (E key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleUI()
    end
end)

-- ============================================================
-- PROXIMITY PROMPT
-- ============================================================
local function setupProximity()
    local part = workspace:FindFirstChild("SpotifyPart")
    if not part then
        -- Try again after a moment
        task.wait(2)
        part = workspace:FindFirstChild("SpotifyPart")
    end

    if part then
        local prompt = part:FindFirstChildOfClass("ProximityPrompt")
        if not prompt then
            prompt = Instance.new("ProximityPrompt")
            prompt.ActionText = "Open Spotify Player"
            prompt.ObjectText = "🎵 Music Player"
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 12
            prompt.Parent = part
        end

        prompt.Triggered:Connect(function(triggerPlayer)
            if triggerPlayer == player then
                toggleUI()
            end
        end)

        print("[Spotify] ProximityPrompt connected to SpotifyPart")
    else
        warn("[Spotify] No 'SpotifyPart' found in Workspace — ProximityPrompt disabled")
        warn("[Spotify] Create a Part named 'SpotifyPart' to use proximity trigger")
    end
end

task.spawn(setupProximity)

-- ============================================================
-- MULTIPLAYER EVENTS
-- ============================================================
spotifyRemote.OnClientEvent:Connect(function(action, data)
    if action == "playPreview" and data.playerName ~= player.Name then
        statusLabel.Text = "🎧 " .. data.playerName .. " is playing: " .. data.trackName
        statusLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
    elseif action == "stopPreview" then
        -- Optional: clear notification after a delay
        task.delay(3, function()
            if statusLabel.Text:find("is playing") then
                statusLabel.Text = ""
            end
        end)
    end
end)

print("[Spotify Client] Loaded! Press E or use ProximityPrompt to open")
