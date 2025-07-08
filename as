-- JoJo Stand System Script
-- Đặt script này vào StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Biến global
local standUser = nil
local standModel = nil
local standActive = false
local oraOraMode = false
local updateConnection = nil
local targetPlayer = nil

-- Tạo GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandGUI"
    screenGui.Parent = playerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "STAND JOJO"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Input Label
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Name = "InputLabel"
    inputLabel.Size = UDim2.new(1, -20, 0, 20)
    inputLabel.Position = UDim2.new(0, 10, 0, 40)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "Nhập tên:"
    inputLabel.TextColor3 = Color3.new(1, 1, 1)
    inputLabel.TextScaled = true
    inputLabel.Font = Enum.Font.SourceSans
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = mainFrame
    
    -- Input TextBox
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.Position = UDim2.new(0, 10, 0, 65)
    inputBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    inputBox.Text = ""
    inputBox.PlaceholderText = "Ví dụ: namhung1 hoặc nam"
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.TextScaled = true
    inputBox.Font = Enum.Font.SourceSans
    inputBox.Parent = mainFrame
    
    -- Stand Toggle Button
    local standToggle = Instance.new("TextButton")
    standToggle.Name = "StandToggle"
    standToggle.Size = UDim2.new(1, -20, 0, 30)
    standToggle.Position = UDim2.new(0, 10, 0, 105)
    standToggle.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    standToggle.BorderSizePixel = 1
    standToggle.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    standToggle.Text = "OFF"
    standToggle.TextColor3 = Color3.new(1, 1, 1)
    standToggle.TextScaled = true
    standToggle.Font = Enum.Font.SourceSansBold
    standToggle.Parent = mainFrame
    
    -- Ora Ora Button
    local oraButton = Instance.new("TextButton")
    oraButton.Name = "OraButton"
    oraButton.Size = UDim2.new(1, -20, 0, 30)
    oraButton.Position = UDim2.new(0, 10, 0, 145)
    oraButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
    oraButton.BorderSizePixel = 1
    oraButton.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    oraButton.Text = "ORA ORA"
    oraButton.TextColor3 = Color3.new(1, 1, 1)
    oraButton.TextScaled = true
    oraButton.Font = Enum.Font.SourceSansBold
    oraButton.Parent = mainFrame
    
    return screenGui, inputBox, standToggle, oraButton
end

-- Tìm người chơi theo tên (hỗ trợ tìm kiếm từng phần)
local function findPlayerByName(name)
    if not name or name == "" then return nil end
    
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) then
            return p
        end
    end
    return nil
end

-- Tạo Stand model
local function createStandModel()
    local stand = Instance.new("Model")
    stand.Name = "Stand"
    stand.Parent = workspace
    
    -- Tạo các parts cho Stand
    local humanoidRootPart = Instance.new("Part")
    humanoidRootPart.Name = "HumanoidRootPart"
    humanoidRootPart.Size = Vector3.new(2, 2, 1)
    humanoidRootPart.Material = Enum.Material.Neon
    humanoidRootPart.BrickColor = BrickColor.new("Bright violet")
    humanoidRootPart.CanCollide = false
    humanoidRootPart.Anchored = true
    humanoidRootPart.Parent = stand
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Material = Enum.Material.Neon
    head.BrickColor = BrickColor.new("Bright violet")
    head.CanCollide = false
    head.Anchored = true
    head.Parent = stand
    
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Material = Enum.Material.Neon
    torso.BrickColor = BrickColor.new("Bright violet")
    torso.CanCollide = false
    torso.Anchored = true
    torso.Parent = stand
    
    -- Tạo tóc dài (nhiều parts)
    for i = 1, 5 do
        local hairPart = Instance.new("Part")
        hairPart.Name = "Hair" .. i
        hairPart.Size = Vector3.new(0.5, 0.5, 0.5)
        hairPart.Material = Enum.Material.Neon
        hairPart.BrickColor = BrickColor.new("Really black")
        hairPart.CanCollide = false
        hairPart.Anchored = true
        hairPart.Parent = stand
    end
    
    -- Tạo Humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = stand
    
    return stand
end

-- Cập nhật vị trí Stand
local function updateStandPosition()
    if not standModel or not targetPlayer or not targetPlayer.Character then
        return
    end
    
    local targetChar = targetPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot then return end
    
    local standRoot = standModel:FindFirstChild("HumanoidRootPart")
    local standHead = standModel:FindFirstChild("Head")
    local standTorso = standModel:FindFirstChild("Torso")
    
    if not standRoot or not standHead or not standTorso then return end
    
    local targetPosition = targetRoot.Position
    local targetLookVector = targetRoot.CFrame.LookVector
    
    local standPosition
    if oraOraMode then
        -- Đứng trước target như ảnh 2
        standPosition = targetPosition + targetLookVector * 5
    else
        -- Đứng sau target như ảnh 1  
        standPosition = targetPosition - targetLookVector * 5
    end
    
    -- Đặt vị trí cho các parts
    standRoot.Position = standPosition
    standHead.Position = standPosition + Vector3.new(0, 1.5, 0)
    standTorso.Position = standPosition
    
    -- Cập nhật vị trí tóc
    for i = 1, 5 do
        local hairPart = standModel:FindFirstChild("Hair" .. i)
        if hairPart then
            hairPart.Position = standPosition + Vector3.new(
                math.sin(i * 0.5) * 0.5,
                2 + i * 0.3,
                math.cos(i * 0.5) * 0.5
            )
        end
    end
    
    -- Quay Stand nhìn về phía target
    local lookDirection = (targetPosition - standPosition).Unit
    standRoot.CFrame = CFrame.lookAt(standPosition, targetPosition)
    standHead.CFrame = CFrame.lookAt(standHead.Position, targetPosition + Vector3.new(0, 1.5, 0))
    standTorso.CFrame = CFrame.lookAt(standTorso.Position, targetPosition)
end

-- Kích hoạt/tắt Stand
local function toggleStand(inputText, toggleButton)
    if standActive then
        -- Tắt Stand
        standActive = false
        oraOraMode = false
        
        if standModel then
            standModel:Destroy()
            standModel = nil
        end
        
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        targetPlayer = nil
        
    else
        -- Bật Stand
        local foundPlayer = findPlayerByName(inputText)
        if foundPlayer and foundPlayer.Character then
            standActive = true
            targetPlayer = foundPlayer
            
            -- Tạo Stand model
            standModel = createStandModel()
            
            -- Bắt đầu update vị trí
            updateConnection = RunService.Heartbeat:Connect(updateStandPosition)
            
            toggleButton.Text = "ON"
            toggleButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
            
            print("Stand activated for: " .. foundPlayer.Name)
        else
            print("Không tìm thấy người chơi: " .. inputText)
        end
    end
end

-- Kích hoạt Ora Ora mode
local function toggleOraOra(oraButton)
    if not standActive or not targetPlayer then
        print("Cần bật Stand trước!")
        return
    end
    
    oraOraMode = not oraOraMode
    
    if oraOraMode then
        oraButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.8)
        print("ORA ORA MODE ON!")
    else
        oraButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
        print("ORA ORA MODE OFF!")
    end
end

-- Khởi tạo GUI và các sự kiện
local function initializeStandSystem()
    local gui, inputBox, standToggle, oraButton = createGUI()
    
    -- Sự kiện cho Stand Toggle
    standToggle.MouseButton1Click:Connect(function()
        toggleStand(inputBox.Text, standToggle)
    end)
    
    -- Sự kiện cho Ora Ora Button
    oraButton.MouseButton1Click:Connect(function()
        toggleOraOra(oraButton)
    end)
    
    -- Sự kiện Enter trong TextBox
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            toggleStand(inputBox.Text, standToggle)
        end
    end)
    
    print("JoJo Stand System initialized!")
end

-- Chạy system khi script load
initializeStandSystem()

-- Cleanup khi player leave
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        if standModel then
            standModel:Destroy()
        end
        if updateConnection then
            updateConnection:Disconnect()
        end
        standActive = false
        targetPlayer = nil
    end
end)
