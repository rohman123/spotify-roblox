-- StarterPlayerScripts/SpotifyLocalScript
-- Client-side Spotify UI controller

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remoteEvent = ReplicatedStorage:WaitForChild("SpotifyRemote")
local remoteFunction = ReplicatedStorage:WaitForChild("SpotifyRemoteFunction")

-- ============================================
-- UI CREATION
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpotifyUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.ZIndex = -1
shadow.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 215, 96) -- Spotify green
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎵 Spotify Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Search bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -20, 0, 40)
searchFrame.Position = UDim2.new(0, 10, 0, 50)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -50, 1, 0)
searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search songs..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

local searchBtn = Instance.new("TextButton")
searchBtn.Size = UDim2.new(0, 35, 0, 35)
searchBtn.Position = UDim2.new(1, -37, 0, 2)
searchBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
searchBtn.Text = "🔍"
searchBtn.TextSize = 16
searchBtn.BorderSizePixel = 0
searchBtn.Parent = searchFrame

local searchBtnCorner = Instance.new("UICorner")
searchBtnCorner.CornerRadius = UDim.new(0, 6)
searchBtnCorner.Parent = searchBtn

-- Results list
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, -20, 0, 300)
resultsFrame.Position = UDim2.new(0, 10, 0, 100)
resultsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
resultsFrame.BorderSizePixel = 0
resultsFrame.ScrollBarThickness = 4
resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
resultsFrame.Parent = mainFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 8)
resultsCorner.Parent = resultsFrame

local resultsLayout = Instance.new("UIListLayout")
resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultsLayout.Padding = UDim.new(0, 5)
resultsLayout.Parent = resultsFrame

local resultsPadding = Instance.new("UIPadding")
resultsPadding.PaddingAll = UDim.new(0, 5)
resultsPadding.Parent = resultsFrame

-- Now playing bar
local nowPlayingFrame = Instance.new("Frame")
nowPlayingFrame.Size = UDim2.new(1, -20, 0, 60)
nowPlayingFrame.Position = UDim2.new(0, 10, 0, 410)
nowPlayingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
nowPlayingFrame.BorderSizePixel = 0
nowPlayingFrame.Visible = false
nowPlayingFrame.Parent = mainFrame

local nowPlayingCorner = Instance.new("UICorner")
nowPlayingCorner.CornerRadius = UDim.new(0, 8)
nowPlayingCorner.Parent = nowPlayingFrame

local nowPlayingLabel = Instance.new("TextLabel")
nowPlayingLabel.Size = UDim2.new(1, -70, 0, 25)
nowPlayingLabel.Position = UDim2.new(0, 10, 0, 5)
nowPlayingLabel.BackgroundTransparency = 1
nowPlayingLabel.Text = "🎵 Now Playing"
nowPlayingLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
nowPlayingLabel.TextSize = 12
nowPlayingLabel.Font = Enum.Font.GothamBold
nowPlayingLabel.TextXAlignment = Enum.TextXAlignment.Left
nowPlayingLabel.Parent = nowPlayingFrame

local trackNameLabel = Instance.new("TextLabel")
trackNameLabel.Size = UDim2.new(1, -70, 0, 25)
trackNameLabel.Position = UDim2.new(0, 10, 0, 30)
trackNameLabel.BackgroundTransparency = 1
trackNameLabel.Text = ""
trackNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
trackNameLabel.TextSize = 14
trackNameLabel.Font = Enum.Font.Gotham
trackNameLabel.TextXAlignment = Enum.TextXAlignment.Left
trackNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
trackNameLabel.Parent = nowPlayingFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 50, 0, 50)
stopBtn.Position = UDim2.new(1, -55, 0, 5)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
stopBtn.Text = "⏹"
stopBtn.TextSize = 20
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.BorderSizePixel = 0
stopBtn.Parent = nowPlayingFrame

local stopBtnCorner = Instance.new("UICorner")
stopBtnCorner.CornerRadius = UDim.new(0, 8)
stopBtnCorner.Parent = stopBtn

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 475)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Press E near the Spotify block to open"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- ============================================
-- STATE
-- ============================================

local isVisible = false
local currentTracks = {}
local isPlaying = false

-- ============================================
-- FUNCTIONS
-- ============================================

local function clearResults()
    for _, child in ipairs(resultsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    currentTracks = {}
end

local function createTrackItem(track, index)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, -10, 0, 50)
    item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    item.BorderSizePixel = 0
    item.LayoutOrder = index
    item.Parent = resultsFrame

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = item

    -- Album image placeholder
    local imageFrame = Instance.new("ImageLabel")
    imageFrame.Size = UDim2.new(0, 40, 0, 40)
    imageFrame.Position = UDim2.new(0, 5, 0, 5)
    imageFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    imageFrame.Image = track.imageUrl
    imageFrame.Parent = item

    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 4)
    imageCorner.Parent = imageFrame

    -- Track name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -110, 0, 25)
    nameLabel.Position = UDim2.new(0, 50, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = track.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = item

    -- Artist name
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Size = UDim2.new(1, -110, 0, 20)
    artistLabel.Position = UDim2.new(0, 50, 0, 28)
    artistLabel.BackgroundTransparency = 1
    artistLabel.Text = track.artist
    artistLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    artistLabel.TextSize = 11
    artistLabel.Font = Enum.Font.Gotham
    artistLabel.TextXAlignment = Enum.TextXAlignment.Left
    artistLabel.TextTruncate = Enum.TextTruncate.AtEnd
    artistLabel.Parent = item

    -- Play button
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0, 45, 0, 40)
    playBtn.Position = UDim2.new(1, -50, 0, 5)
    playBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
    playBtn.Text = "▶"
    playBtn.TextSize = 18
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.BorderSizePixel = 0
    playBtn.Parent = item

    local playBtnCorner = Instance.new("UICorner")
    playBtnCorner.CornerRadius = UDim.new(0, 6)
    playBtnCorner.Parent = playBtn

    -- Play button click
    playBtn.MouseButton1Click:Connect(function()
        if track.previewUrl then
            local result = remoteFunction:InvokeServer("playPreview", track.previewUrl, 0.5)
            if result and result.success then
                nowPlayingFrame.Visible = true
                trackNameLabel.Text = track.name .. " - " .. track.artist
                isPlaying = true
                statusLabel.Text = "▶ Playing: " .. track.name
                statusLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
            else
                statusLabel.Text = "❌ Failed to play preview"
                statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        else
            statusLabel.Text = "⚠ No preview available for this track"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end
    end)

    return item
end

local function searchTracks(query)
    statusLabel.Text = "🔍 Searching..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)

    local result = remoteFunction:InvokeServer("search", query)

    clearResults()

    if result and result.success and result.tracks then
        for i, track in ipairs(result.tracks) do
            currentTracks[track.id] = track
            createTrackItem(track, i)
        end
        statusLabel.Text = "✅ Found " .. #result.tracks .. " tracks"
        statusLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
    else
        statusLabel.Text = "❌ " .. (result and result.error or "Search failed")
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

-- ============================================
-- EVENT CONNECTIONS
-- ============================================

closeBtn.MouseButton1Click:Connect(function()
    isVisible = false
    mainFrame.Visible = false
end)

searchBtn.MouseButton1Click:Connect(function()
    local query = searchBox.Text
    if query ~= "" then
        searchTracks(query)
    end
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and searchBox.Text ~= "" then
        searchTracks(searchBox.Text)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    remoteEvent:FireServer("stopPreview")
    nowPlayingFrame.Visible = false
    isPlaying = false
    statusLabel.Text = "⏹ Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- Toggle UI with key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        isVisible = not isVisible
        mainFrame.Visible = isVisible
    end
end)

-- ============================================
-- PROXIMITY PROMPT (optional - if Part exists)
-- ============================================

local function setupProximityPrompt()
    local part = workspace:FindFirstChild("SpotifyPart")
    if part then
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Open Spotify"
        prompt.ObjectText = "🎵 Spotify Player"
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 10
        prompt.Parent = part

        prompt.Triggered:Connect(function()
            isVisible = not isVisible
            mainFrame.Visible = isVisible
        end)
    end
end

setupProximityPrompt()

print("[Spotify Client] Initialized - Press E to open")
