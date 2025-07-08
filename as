-- Script này đặt trong StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.85, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "STAND JOJO"
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
titleLabel.Font = Enum.Font.Fantasy
titleLabel.Parent = mainFrame

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0.15, 0, 0, 30)
minimizeButton.Position = UDim2.new(0.85, 0, 0, 0)
minimizeButton.Text = "-"
minimizeButton.TextScaled = true
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = mainFrame

-- Container cho content (để dễ ẩn/hiện)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- TextBox nhập tên
local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0.9, 0, 0, 30)
nameInput.Position = UDim2.new(0.05, 0, 0.1, 0)
nameInput.PlaceholderText = "Nhập tên user..."
nameInput.Text = ""
nameInput.TextScaled = true
nameInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
nameInput.TextColor3 = Color3.fromRGB(0, 0, 0)
nameInput.Parent = contentFrame

-- Toggle button (OFF/ON)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.4, 0, 0, 25)
toggleButton.Position = UDim2.new(0.05, 0, 0.5, 0)
toggleButton.Text = "OFF"
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = contentFrame

-- Ora Ora button
local oraButton = Instance.new("TextButton")
oraButton.Size = UDim2.new(0.4, 0, 0, 25)
oraButton.Position = UDim2.new(0.55, 0, 0.5, 0)
oraButton.Text = "ORA ORA"
oraButton.TextScaled = true
oraButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
oraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
oraButton.Parent = contentFrame

-- Variables
local standEnabled = false
local oraMode = false
local targetPlayer = nil
local standConnection = nil
local isMinimized = false

-- Tạo Stand (clone của character nhưng màu tím và không có accessories)
local function createStand()
    local stand = character:Clone()
    stand.Name = "Stand_" .. player.Name
    
    -- Xóa accessories và tools
    for _, child in pairs(stand:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Tool") then
            child:Destroy()
        end
    end
    
    -- Đổi màu da thành tím
    for _, part in pairs(stand:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent:IsA("Model") then
            if part.Name == "Head" or part.Name == "Torso" or part.Name == "Left Arm" or 
               part.Name == "Right Arm" or part.Name == "Left Leg" or part.Name == "Right Leg" or
               part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "LeftUpperArm" or
               part.Name == "RightUpperArm" or part.Name == "LeftLowerArm" or part.Name == "RightLowerArm" or
               part.Name == "LeftUpperLeg" or part.Name == "RightUpperLeg" or part.Name == "LeftLowerLeg" or
               part.Name == "RightLowerLeg" or part.Name == "LeftHand" or part.Name == "RightHand" or
               part.Name == "LeftFoot" or part.Name == "RightFoot" then
                part.Color = Color3.fromRGB(138, 43, 226) -- Màu tím
            end
        end
        -- Làm trong suốt một chút
        if part:IsA("BasePart") then
            part.Transparency = 0.3
        end
    end
    
    -- Xóa humanoid cũ và tạo mới
    local oldHumanoid = stand:FindFirstChild("Humanoid")
    if oldHumanoid then
        oldHumanoid:Destroy()
    end
    
    stand.Parent = workspace
    return stand
end

-- Function tìm player
local function findPlayer(partialName)
    partialName = partialName:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():find(partialName) then
            return plr
        end
    end
    return nil
end

-- Function update vị trí Stand
local function updateStandPosition(stand, target)
    if not stand or not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local standRoot = stand:FindFirstChild("HumanoidRootPart")
    if not standRoot then return end
    
    if oraMode then
        -- Đứng trước mặt
        local frontOffset = targetRoot.CFrame.LookVector * 3
        standRoot.CFrame = targetRoot.CFrame + frontOffset
    else
        -- Đứng sau lưng
        local backOffset = -targetRoot.CFrame.LookVector * 3
        standRoot.CFrame = targetRoot.CFrame + backOffset
    end
end

-- Minimize/Maximize
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Thu nhỏ
        mainFrame:TweenSize(
            UDim2.new(0, 200, 0, 30),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        contentFrame.Visible = false
        minimizeButton.Text = "+"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        -- Phóng to
        mainFrame:TweenSize(
            UDim2.new(0, 200, 0, 150),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        contentFrame.Visible = true
        minimizeButton.Text = "-"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Toggle Stand
toggleButton.MouseButton1Click:Connect(function()
    standEnabled = not standEnabled
    
    if standEnabled then
        local inputName = nameInput.Text
        if inputName == "" then
            toggleButton.Text = "OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            standEnabled = false
            return
        end
        
        targetPlayer = findPlayer(inputName)
        if not targetPlayer then
            toggleButton.Text = "OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            standEnabled = false
            return
        end
        
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Tạo Stand
        local stand = createStand()
        
        -- Update vị trí liên tục
        standConnection = RunService.Heartbeat:Connect(function()
            if standEnabled and stand and stand.Parent then
                updateStandPosition(stand, targetPlayer)
            else
                if standConnection then
                    standConnection:Disconnect()
                end
                if stand and stand.Parent then
                    stand:Destroy()
                end
            end
        end)
        
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
        -- Xóa Stand
        if standConnection then
            standConnection:Disconnect()
        end
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "Stand_" .. player.Name then
                obj:Destroy()
            end
        end
    end
end)

-- Ora Ora mode
oraButton.MouseButton1Click:Connect(function()
    if standEnabled then
        oraMode = not oraMode
        if oraMode then
            oraButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            oraButton.Text = "MUDA MUDA"
        else
            oraButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            oraButton.Text = "ORA ORA"
        end
    end
end)

-- Reset khi character chết
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset Stand
    if standEnabled then
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        standEnabled = false
        
        if standConnection then
            standConnection:Disconnect()
        end
    end
end)
