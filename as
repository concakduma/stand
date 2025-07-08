-- Script đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Biến toàn cục
local targetPlayer = nil
local isFollowing = false
local isInFront = false
local connection = nil
local gui = nil
local isMinimized = false

-- Tạo GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandJoJoGUI"
    screenGui.Parent = playerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 300)
    mainFrame.Position = UDim2.new(0, 10, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.Text = "Stand JoJo"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    minimizeBtn.Position = UDim2.new(1, -25, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = title
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 5)
    minimizeCorner.Parent = minimizeBtn
    
    -- Search Label
    local searchLabel = Instance.new("TextLabel")
    searchLabel.Name = "SearchLabel"
    searchLabel.Size = UDim2.new(1, -20, 0, 20)
    searchLabel.Position = UDim2.new(0, 10, 0, 40)
    searchLabel.BackgroundTransparency = 1
    searchLabel.Text = "Nhập tên:"
    searchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchLabel.TextXAlignment = Enum.TextXAlignment.Left
    searchLabel.Font = Enum.Font.SourceSans
    searchLabel.Parent = mainFrame
    
    -- Search TextBox
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -20, 0, 25)
    searchBox.Position = UDim2.new(0, 10, 0, 65)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Nhập tên player..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 14
    searchBox.Parent = mainFrame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 5)
    searchCorner.Parent = searchBox
    
    -- Players List Frame
    local listFrame = Instance.new("Frame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(1, -20, 0, 120)
    listFrame.Position = UDim2.new(0, 10, 0, 95)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.Parent = mainFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = listFrame
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = listFrame
    
    -- List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollFrame
    
    -- Follow Toggle
    local followToggle = Instance.new("TextButton")
    followToggle.Name = "FollowToggle"
    followToggle.Size = UDim2.new(0, 60, 0, 25)
    followToggle.Position = UDim2.new(0, 10, 0, 225)
    followToggle.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    followToggle.Text = "OFF"
    followToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    followToggle.TextScaled = true
    followToggle.Font = Enum.Font.SourceSansBold
    followToggle.Parent = mainFrame
    
    local followCorner = Instance.new("UICorner")
    followCorner.CornerRadius = UDim.new(0, 5)
    followCorner.Parent = followToggle
    
    -- Ora Ora Button
    local oraButton = Instance.new("TextButton")
    oraButton.Name = "OraButton"
    oraButton.Size = UDim2.new(0, 80, 0, 25)
    oraButton.Position = UDim2.new(0, 80, 0, 225)
    oraButton.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    oraButton.Text = "ORA ORA"
    oraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    oraButton.TextScaled = true
    oraButton.Font = Enum.Font.SourceSansBold
    oraButton.Parent = mainFrame
    
    local oraCorner = Instance.new("UICorner")
    oraCorner.CornerRadius = UDim.new(0, 5)
    oraCorner.Parent = oraButton
    
    return screenGui, mainFrame, searchBox, scrollFrame, followToggle, oraButton, minimizeBtn
end

-- Cập nhật danh sách players
local function updatePlayerList(searchText, scrollFrame)
    -- Xóa các item cũ
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yPos = 0
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerName = otherPlayer.Name
            if searchText == "" or string.lower(playerName):find(string.lower(searchText)) then
                local playerButton = Instance.new("TextButton")
                playerButton.Name = playerName
                playerButton.Size = UDim2.new(1, -10, 0, 25)
                playerButton.Position = UDim2.new(0, 0, 0, yPos)
                playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                playerButton.Text = playerName
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.TextXAlignment = Enum.TextXAlignment.Left
                playerButton.Font = Enum.Font.SourceSans
                playerButton.TextSize = 12
                playerButton.Parent = scrollFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 3)
                btnCorner.Parent = playerButton
                
                -- Click event
                playerButton.MouseButton1Click:Connect(function()
                    targetPlayer = otherPlayer
                    -- Highlight selected
                    for _, btn in pairs(scrollFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        end
                    end
                    playerButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                end)
                
                yPos = yPos + 27
            end
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Tele ra sau player
local function teleportBehind()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local playerRoot = player.Character.HumanoidRootPart
    
    -- Tính vị trí phía sau
    local targetLookDirection = targetRoot.CFrame.LookVector
    local behindPosition = targetRoot.Position - (targetLookDirection * 3)
    
    -- Tele
    playerRoot.CFrame = CFrame.new(behindPosition, targetRoot.Position)
end

-- Tele ra trước player
local function teleportInFront()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local playerRoot = player.Character.HumanoidRootPart
    
    -- Tính vị trí phía trước
    local targetLookDirection = targetRoot.CFrame.LookVector
    local frontPosition = targetRoot.Position + (targetLookDirection * 3)
    
    -- Tele và quay mặt về phía target
    playerRoot.CFrame = CFrame.new(frontPosition, targetRoot.Position)
end

-- Bắt đầu/dừng theo dõi
local function toggleFollow(followToggle)
    if not targetPlayer then
        return
    end
    
    isFollowing = not isFollowing
    
    if isFollowing then
        followToggle.Text = "ON"
        followToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        
        -- Bắt đầu follow
        connection = RunService.Heartbeat:Connect(function()
            if isInFront then
                teleportInFront()
            else
                teleportBehind()
            end
        end)
    else
        followToggle.Text = "OFF"
        followToggle.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        
        -- Dừng follow
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

-- Toggle vị trí (trước/sau)
local function togglePosition(oraButton)
    if not isFollowing then
        return
    end
    
    isInFront = not isInFront
    
    if isInFront then
        oraButton.BackgroundColor3 = Color3.fromRGB(50, 100, 100)
    else
        oraButton.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    end
end

-- Toggle minimize
local function toggleMinimize(mainFrame, minimizeBtn)
    isMinimized = not isMinimized
    
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 35), "Out", "Quad", 0.3, true)
        minimizeBtn.Text = "+"
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 300), "Out", "Quad", 0.3, true)
        minimizeBtn.Text = "-"
    end
end

-- Khởi tạo GUI
local screenGui, mainFrame, searchBox, scrollFrame, followToggle, oraButton, minimizeBtn = createGUI()

-- Cập nhật danh sách ban đầu
updatePlayerList("", scrollFrame)

-- Events
searchBox.Changed:Connect(function()
    updatePlayerList(searchBox.Text, scrollFrame)
end)

followToggle.MouseButton1Click:Connect(function()
    toggleFollow(followToggle)
end)

oraButton.MouseButton1Click:Connect(function()
    togglePosition(oraButton)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    toggleMinimize(mainFrame, minimizeBtn)
end)

-- Cập nhật danh sách khi có player mới
Players.PlayerAdded:Connect(function()
    updatePlayerList(searchBox.Text, scrollFrame)
end)

Players.PlayerRemoving:Connect(function(removedPlayer)
    if targetPlayer == removedPlayer then
        targetPlayer = nil
        isFollowing = false
        followToggle.Text = "OFF"
        followToggle.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
    updatePlayerList(searchBox.Text, scrollFrame)
end)

-- Làm frame có thể kéo được
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
