-- Script này đặt trong StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Biến global
local targetPlayer = nil
local isFollowing = false
local isOraMode = false
local followConnection = nil
local isMinimized = false

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandJojoGui"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.Parent = screenGui

-- Tạo corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "STAND JOJO"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = titleLabel

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 5)
minimizeCorner.Parent = minimizeButton

-- Input Label
local inputLabel = Instance.new("TextLabel")
inputLabel.Name = "InputLabel"
inputLabel.Size = UDim2.new(1, -20, 0, 30)
inputLabel.Position = UDim2.new(0, 10, 0, 50)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Nhập tên:"
inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
inputLabel.TextScaled = true
inputLabel.Font = Enum.Font.SourceSans
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Parent = mainFrame

-- Input TextBox
local inputTextBox = Instance.new("TextBox")
inputTextBox.Name = "InputTextBox"
inputTextBox.Size = UDim2.new(1, -20, 0, 30)
inputTextBox.Position = UDim2.new(0, 10, 0, 80)
inputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputTextBox.BorderSizePixel = 1
inputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
inputTextBox.Text = ""
inputTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
inputTextBox.TextScaled = true
inputTextBox.Font = Enum.Font.SourceSans
inputTextBox.PlaceholderText = "Nhập tên player..."
inputTextBox.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = inputTextBox

-- Player List ScrollingFrame
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerListFrame"
playerListFrame.Size = UDim2.new(1, -20, 0, 200)
playerListFrame.Position = UDim2.new(0, 10, 0, 120)
playerListFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
playerListFrame.BorderSizePixel = 1
playerListFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
playerListFrame.ScrollBarThickness = 8
playerListFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 5)
listCorner.Parent = playerListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = playerListFrame

-- Toggle Button (OFF/ON)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.5, -5, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 330)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggleButton

-- Ora Button
local oraButton = Instance.new("TextButton")
oraButton.Name = "OraButton"
oraButton.Size = UDim2.new(0.5, -5, 0, 35)
oraButton.Position = UDim2.new(0.5, 5, 0, 330)
oraButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
oraButton.BorderSizePixel = 0
oraButton.Text = "ORA ORA"
oraButton.TextColor3 = Color3.fromRGB(0, 0, 0)
oraButton.TextScaled = true
oraButton.Font = Enum.Font.SourceSansBold
oraButton.Parent = mainFrame

local oraCorner = Instance.new("UICorner")
oraCorner.CornerRadius = UDim.new(0, 5)
oraCorner.Parent = oraButton

-- Functions
local function updatePlayerList(searchText)
    -- Xóa tất cả các item cũ
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    searchText = searchText:lower()
    local yPos = 0
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and (searchText == "" or otherPlayer.Name:lower():find(searchText)) then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Size = UDim2.new(1, -10, 0, 30)
            playerButton.Position = UDim2.new(0, 5, 0, yPos)
            playerButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            playerButton.BorderSizePixel = 1
            playerButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            playerButton.Text = otherPlayer.Name
            playerButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            playerButton.TextScaled = true
            playerButton.Font = Enum.Font.SourceSans
            playerButton.Parent = playerListFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 3)
            buttonCorner.Parent = playerButton
            
            playerButton.MouseButton1Click:Connect(function()
                inputTextBox.Text = otherPlayer.Name
                targetPlayer = otherPlayer
                
                -- Highlight selected player
                for _, btn in ipairs(playerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                    end
                end
                playerButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            end)
            
            yPos = yPos + 32
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isFollowing = false
    isOraMode = false
end

local function startFollowing()
    if not targetPlayer or not targetPlayer.Character then
        return
    end
    
    stopFollowing()
    isFollowing = true
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            stopFollowing()
            toggleButton.Text = "OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        local offset
        
        if isOraMode then
            -- Đứng trước target (như ảnh 2)
            offset = targetCFrame.LookVector * 5
        else
            -- Đứng sau target (như ảnh 1)
            offset = targetCFrame.LookVector * -5
        end
        
        local newPosition = targetCFrame.Position + offset
        player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(newPosition, targetPlayer.Character.HumanoidRootPart.Position)
    end)
end

local function toggleMinimize()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Biến mất hoàn toàn, chỉ còn nút -
        mainFrame.Size = UDim2.new(0, 30, 0, 30)
        mainFrame.BackgroundTransparency = 1
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextTransparency = 1
        
        -- Ẩn tất cả trừ nút -
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child ~= minimizeButton then
                child.Visible = false
            end
        end
        
        -- Đặt lại vị trí nút -
        minimizeButton.Position = UDim2.new(0, 0, 0, 0)
        minimizeButton.Size = UDim2.new(0, 30, 0, 30)
        minimizeButton.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
        minimizeButton.Text = "+"
    else
        -- Hiện lại toàn bộ GUI
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
        mainFrame.BackgroundTransparency = 0
        titleLabel.BackgroundTransparency = 0
        titleLabel.TextTransparency = 0
        
        -- Hiện tất cả các element
        for _, child in ipairs(mainFrame:GetChildren()) do
            child.Visible = true
        end
        
        -- Đặt lại vị trí nút -
        minimizeButton.Position = UDim2.new(1, -35, 0, 5)
        minimizeButton.Size = UDim2.new(0, 30, 0, 30)
        minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        minimizeButton.Text = "-"
    end
end

-- Event Connections
inputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayerList(inputTextBox.Text)
    
    -- Tự động chọn player nếu tên khớp chính xác
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Name:lower() == inputTextBox.Text:lower() then
            targetPlayer = otherPlayer
            break
        end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    if not targetPlayer then
        return
    end
    
    if isFollowing then
        stopFollowing()
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    else
        startFollowing()
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

oraButton.MouseButton1Click:Connect(function()
    if not isFollowing or not targetPlayer then
        return
    end
    
    isOraMode = not isOraMode
    
    if isOraMode then
        oraButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        oraButton.Text = "ORA MODE"
    else
        oraButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        oraButton.Text = "ORA ORA"
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleMinimize()
end)

-- Khởi tạo danh sách player
updatePlayerList("")

-- Cập nhật danh sách khi có player mới join/leave
Players.PlayerAdded:Connect(function()
    updatePlayerList(inputTextBox.Text)
end)

Players.PlayerRemoving:Connect(function(removedPlayer)
    if targetPlayer == removedPlayer then
        stopFollowing()
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        targetPlayer = nil
        inputTextBox.Text = ""
    end
    updatePlayerList(inputTextBox.Text)
end)
