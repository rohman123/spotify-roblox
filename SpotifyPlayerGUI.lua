--[[
    SpotifyPlayerGUI.lua (LocalScript)
    Taruh di StarterPlayerScripts atau sebagai child dari Part.
    
    Creates a search GUI when player interacts with the Spotify Player Part.
    Features:
    - Search bar with real-time Spotify API search
    - Track list with album art
    - Play/Stop preview (30 seconds)
    - Now playing display
    - Smooth animations
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local spotifyRemote = ReplicatedStorage:WaitForChild("SpotifyRemote")
local spotifySearch = ReplicatedStorage:WaitForChild("SpotifySearch")

-- ============================================================
-- CREATE GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpotifyPlayerGui"
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
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
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

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(30, 215, 96) -- Spotify green
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Fix bottom corners of header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 13)
headerFix.Position = UDim2.new(0, 0, 1, -13)
headerFix.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎵 Spotify Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0.8
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

-- Search Bar
local searchFrame = Instance.new("Frame")
searchFrame.Name = "SearchFrame"
searchFrame.Size = UDim2.new(1, -30, 0, 40)
searchFrame.Position = UDim2.new(0, 15, 0, 60)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 20)
searchCorner.Parent = searchFrame

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 35, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 16
searchIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -40, 1, 0)
searchBox.Position = UDim2.new(0, 35, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search for a song..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- Track List (ScrollingFrame)
local trackList = Instance.new("ScrollingFrame")
trackList.Name = "TrackList"
trackList.Size = UDim2.new(1, -30, 0, 320)
trackList.Position = UDim2.new(0, 15, 0, 110)
trackList.BackgroundTransparency = 1
trackList.BorderSizePixel = 0
trackList.ScrollBarThickness = 4
trackList.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
trackList.CanvasSize = UDim2.new(0, 0, 0, 0)
trackList.AutomaticCanvasSize = Enum.AutomaticSize.Y
trackList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = trackList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.Parent = trackList

-- Now Playing Bar
local nowPlaying = Instance.new("Frame")
nowPlaying.Name = "NowPlaying"
nowPlaying.Size = UDim2.new(1, 0, 0, 0) -- Hidden by default
nowPlaying.Position = UDim2.new(0, 0, 1, 0)
nowPlaying.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nowPlaying.BorderSizePixel = 0
nowPlaying.ClipsDescendants = true
nowPlaying.Parent = mainFrame

local nowPlayingCorner = Instance.new("UICorner")
nowPlayingCorner.CornerRadius = UDim.new(0, 12)
nowPlayingCorner.Parent = nowPlaying

local nowPlayingFix = Instance.new("Frame")
nowPlayingFix.Size = UDim2.new(1, 0, 0, 13)
nowPlayingFix.Position = UDim2.new(0, 0, 0, 0)
nowPlayingFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nowPlayingFix.BorderSizePixel = 0
nowPlayingFix.Parent = nowPlaying

local nowPlayingIcon = Instance.new("TextLabel")
nowPlayingIcon.Size = UDim2.new(0, 30, 0, 50)
nowPlayingIcon.Position = UDim2.new(0, 10, 0, 0)
nowPlayingIcon.BackgroundTransparency = 1
nowPlayingIcon.Text = "🎶"
nowPlayingIcon.TextSize = 20
nowPlayingIcon.Parent = nowPlaying

local nowPlayingName = Instance.new("TextLabel")
nowPlayingName.Size = UDim2.new(1, -100, 0, 25)
nowPlayingName.Position = UDim2.new(0, 40, 0, 5)
nowPlayingName.BackgroundTransparency = 1
nowPlayingName.Text = ""
nowPlayingName.TextColor3 = Color3.fromRGB(30, 215, 96)
nowPlayingName.TextSize = 14
nowPlayingName.Font = Enum.Font.GothamBold
nowPlayingName.TextXAlignment = Enum.TextXAlignment.Left
nowPlayingName.TextTruncate = Enum.TextTruncate.AtEnd
nowPlayingName.Parent = nowPlaying

local nowPlayingArtist = Instance.new("TextLabel")
nowPlayingArtist.Size = UDim2.new(1, -100, 0, 20)
nowPlayingArtist.Position = UDim2.new(0, 40, 0, 28)
nowPlayingArtist.BackgroundTransparency = 1
nowPlayingArtist.Text = ""
nowPlayingArtist.TextColor3 = Color3.fromRGB(170, 170, 170)
nowPlayingArtist.TextSize = 12
nowPlayingArtist.Font = Enum.Font.Gotham
nowPlayingArtist.TextXAlignment = Enum.TextXAlignment.Left
nowPlayingArtist.TextTruncate = Enum.TextTruncate.AtEnd
nowPlayingArtist.Parent = nowPlaying

local stopBtn = Instance.new("TextButton")
stopBtn.Name = "StopBtn"
stopBtn.Size = UDim2.new(0, 60, 0, 30)
stopBtn.Position = UDim2.new(1, -70, 0, 10)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
stopBtn.Text = "⏹ Stop"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 12
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Parent = nowPlaying

local stopBtnCorner = Instance.new("UICorner")
stopBtnCorner.CornerRadius = UDim.new(0, 8)
stopBtnCorner.Parent = stopBtn

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -30, 0, 20)
statusLabel.Position = UDim2.new(0, 15, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- ============================================================
-- SOUND
-- ============================================================
local previewSound = nil

-- ============================================================
-- FUNCTIONS
-- ============================================================
local currentTracks = {}

local function clearTrackList()
    for _, child in ipairs(trackList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    currentTracks = {}
end

local function createTrackCard(track, index)
    local card = Instance.new("Frame")
    card.Name = "Track_" .. track.id
    card.Size = UDim2.new(1, -10, 0, 55)
    card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.Parent = trackList
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    
    -- Album art placeholder
    local albumArt = Instance.new("ImageLabel")
    albumArt.Size = UDim2.new(0, 40, 0, 40)
    albumArt.Position = UDim2.new(0, 8, 0, 7)
    albumArt.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    albumArt.Image = track.imageUrl or ""
    albumArt.Parent = card
    
    local albumCorner = Instance.new("UICorner")
    albumCorner.CornerRadius = UDim.new(0, 4)
    albumCorner.Parent = albumArt
    
    -- Track name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 22)
    nameLabel.Position = UDim2.new(0, 55, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = track.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    
    -- Artist name
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Size = UDim2.new(1, -130, 0, 18)
    artistLabel.Position = UDim2.new(0, 55, 0, 28)
    artistLabel.BackgroundTransparency = 1
    artistLabel.Text = track.artist .. " • " .. track.album
    artistLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    artistLabel.TextSize = 11
    artistLabel.Font = Enum.Font.Gotham
    artistLabel.TextXAlignment = Enum.TextXAlignment.Left
    artistLabel.TextTruncate = Enum.TextTruncate.AtEnd
    artistLabel.Parent = card
    
    -- Play button
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0, 60, 0, 30)
    playBtn.Position = UDim2.new(1, -70, 0, 12)
    playBtn.BackgroundColor3 = track.previewUrl and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(80, 80, 80)
    playBtn.Text = track.previewUrl and "▶ Play" or "N/A"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.TextSize = 12
    playBtn.Font = Enum.Font.GothamBold
    playBtn.Parent = card
    
    local playBtnCorner = Instance.new("UICorner")
    playBtnCorner.CornerRadius = UDim.new(0, 8)
    playBtnCorner.Parent = playBtn
    
    if track.previewUrl then
        playBtn.MouseButton1Click:Connect(function()
            -- Stop current sound
            if previewSound then
                previewSound:Stop()
                previewSound:Destroy()
            end
            
            -- Play preview
            previewSound = Instance.new("Sound")
            previewSound.SoundId = track.previewUrl
            previewSound.Volume = 0.8
            previewSound.Parent = SoundService
            previewSound:Play()
            
            -- Update now playing
            nowPlayingName.Text = track.name
            nowPlayingArtist.Text = track.artist
            nowPlaying.Size = UDim2.new(1, 0, 0, 50)
            nowPlaying.Position = UDim2.new(0, 0, 1, -50)
            
            -- Notify server
            spotifyRemote:FireServer("playPreview", {
                trackName = track.name,
                artist = track.artist,
                previewUrl = track.previewUrl
            })
            
            statusLabel.Text = "▶ Now playing: " .. track.name
            
            -- Auto-hide when done
            previewSound.Ended:Connect(function()
                nowPlaying.Size = UDim2.new(1, 0, 0, 0)
                nowPlaying.Position = UDim2.new(0, 0, 1, 0)
                statusLabel.Text = ""
                previewSound:Destroy()
                previewSound = nil
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
    
    local success, result = pcall(function()
        return spotifySearch:InvokeServer("search", query)
    end)
    
    if success and result then
        clearTrackList()
        if #result == 0 then
            statusLabel.Text = "😕 No results found"
        else
            statusLabel.Text = "✅ Found " .. #result .. " tracks"
            for i, track in ipairs(result) do
                createTrackCard(track, i)
            end
        end
    else
        statusLabel.Text = "❌ Search failed. Try again."
    end
end

-- ============================================================
-- EVENT CONNECTIONS
-- ============================================================

-- Search on text changed (with debounce)
local searchDebounce = false
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then return end
    searchDebounce = true
    task.wait(0.5) -- debounce 500ms
    doSearch(searchBox.Text)
    searchDebounce = false
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    -- Animate out
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 400, 0, 0)
    }):Play()
    task.wait(0.3)
    mainFrame.Visible = false
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    
    -- Stop any playing sound
    if previewSound then
        previewSound:Stop()
    end
end)

-- Stop button
stopBtn.MouseButton1Click:Connect(function()
    if previewSound then
        previewSound:Stop()
        previewSound:Destroy()
        previewSound = nil
    end
    nowPlaying.Size = UDim2.new(1, 0, 0, 0)
    nowPlaying.Position = UDim2.new(0, 0, 1, 0)
    statusLabel.Text = ""
    spotifyRemote:FireServer("stopPreview", {})
end)

-- ============================================================
-- PROXIMITY PROMPT TRIGGER
-- ============================================================
-- Find the Spotify Part in workspace
local function findSpotifyPart()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "SpotifyPlayer" then
            return obj
        end
    end
    return nil
end

local spotifyPart = findSpotifyPart()
if not spotifyPart then
    -- Try again after a bit
    task.wait(2)
    spotifyPart = findSpotifyPart()
end

if spotifyPart then
    local prompt = spotifyPart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Open Spotify Player"
        prompt.ObjectText = "🎵 Music Player"
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 12
        prompt.Parent = spotifyPart
    end
    
    prompt.Triggered:Connect(function(triggerPlayer)
        if triggerPlayer == player then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 400, 0, 0)
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 400, 0, 500)
            }):Play()
            searchBox:CaptureFocus()
        end
    end)
    
    print("[SpotifyPlayer] Connected to ProximityPrompt on SpotifyPlayer part")
else
    warn("[SpotifyPlayer] No 'SpotifyPlayer' part found in Workspace!")
    warn("[SpotifyPlayer] Create a Part named 'SpotifyPlayer' with a ProximityPrompt")
end

-- ============================================================
-- HANDLE REMOTE EVENTS (for multiplayer sync)
-- ============================================================
spotifyRemote.OnClientEvent:Connect(function(action, data)
    if action == "playPreview" and data.playerName ~= player.Name then
        statusLabel.Text = "🎵 " .. data.playerName .. " is playing: " .. data.trackName
    elseif action == "stopPreview" then
        -- Optional: show notification
    end
end)

print("[SpotifyPlayer] GUI loaded!")
