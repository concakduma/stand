-- JoJo Stand Script - Đặt trong StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Biến global
local standModel = nil
local isStandActive = false
local targetPlayerName = ""
local isOraOraActive = false

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandGui"
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Text = "STAND JOJO"
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Input Label
local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(1, -20, 0, 25)
inputLabel.Position = UDim2.new(0, 10, 0, 40)
inputLabel.BackgroundTransparency = 1
inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
inputLabel.Text = "Nhập tên:"
inputLabel.TextScaled = true
inputLabel.Font = Enum.Font.Gotham
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Parent = mainFrame

-- Input TextBox
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 70)
inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Text = ""
inputBox.PlaceholderText = "Nhập tên player..."
inputBox.TextScaled = true
inputBox.Font = Enum.Font.Gotham
inputBox.Parent = mainFrame

-- Stand Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 110)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "OFF"
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

-- Ora Ora Button
local oraButton = Instance.new("TextButton")
oraButton.Size = UDim2.new(1, -20, 0, 35)
oraButton.Position = UDim2.new(0, 10, 0, 155)
oraButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
oraButton.TextColor3 = Color3.fromRGB(0, 0, 0)
oraButton.Text = "ORA ORA"
oraButton.TextScaled = true
oraButton.Font = Enum.Font.GothamBold
oraButton.Parent = mainFrame

-- Function để tìm player theo tên (partial match)
local function findPlayerByPartialName(partialName)
    if partialName == "" then return nil end
    
    partialName = string.lower(partialName)
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if string.find(string.lower(targetPlayer.Name), partialName) then
            return targetPlayer
        end
    end
    return nil
end

-- Function tạo Stand Model
local function createStand()
    local stand = Instance.new("Model")
    stand.Name = "Stand"
    
    -- Tạo torso chính
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Material = Enum.Material.Neon
    torso.BrickColor = BrickColor.new("Bright yellow")
    torso.CanCollide = false
    torso.Anchored = true
    torso.Parent = stand
    
    -- Tạo đầu
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.5, 1.5, 1.5)
    head.Material = Enum.Material.Neon
    head.BrickColor = BrickColor.new("Bright yellow")
    head.CanCollide = false
    head.Anchored = true
    head.Shape = Enum.PartType.Ball
    head.Parent = stand
    
    -- Tạo tay trái
    local leftArm = Instance.new("Part")
    leftArm.Name = "LeftArm"
    leftArm.Size = Vector3.new(1, 2, 1)
    leftArm.Material = Enum.Material.Neon
    leftArm.BrickColor = BrickColor.new("Bright yellow")
    leftArm.CanCollide = false
    leftArm.Anchored = true
    leftArm.Parent = stand
    
    -- Tạo tay phải
    local rightArm = Instance.new("Part")
    rightArm.Name = "RightArm"
    rightArm.Size = Vector3.new(1, 2, 1)
    rightArm.Material = Enum.Material.Neon
    rightArm.BrickColor = BrickColor.new("Bright yellow")
    rightArm.CanCollide = false
    rightArm.Anchored = true
    rightArm.Parent = stand
    
    -- Tạo chân trái
    local leftLeg = Instance.new("Part")
    leftLeg.Name = "LeftLeg"
    leftLeg.Size = Vector3.new(1, 2, 1)
    leftLeg.Material = Enum.Material.Neon
    leftLeg.BrickColor = BrickColor.new("Bright yellow")
    leftLeg.CanCollide = false
    leftLeg.Anchored = true
    leftLeg.Parent = stand
    
    -- Tạo chân phải
    local rightLeg = Instance.new("Part")
    rightLeg.Name = "RightLeg"
    rightLeg.Size = Vector3.new(1, 2, 1)
    rightLeg.Material = Enum.Material.Neon
    rightLeg.BrickColor = BrickColor.new("Bright yellow")
    rightLeg.CanCollide = false
    rightLeg.Anchored = true
    rightLeg.Parent = stand
    
    return stand
end

-- Function để update vị trí Stand
local function updateStandPosition()
    if not standModel or not standModel.Parent then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local standPosition = rootPart.Position + rootPart.CFrame.RightVector * 3 + Vector3.new(0, 0, -2)
    
    -- Update tất cả parts của stand
    local torso = standModel:FindFirstChild("Torso")
    local head = standModel:FindFirstChild("Head")
    local leftArm = standModel:FindFirstChild("LeftArm")
    local rightArm = standModel:FindFirstChild("RightArm")
    local leftLeg = standModel:FindFirstChild("LeftLeg")
    local rightLeg = standModel:FindFirstChild("RightLeg")
    
    if torso then
        torso.Position = standPosition
        
        -- Floating effect
        local time = tick()
        local floatOffset = math.sin(time * 2) * 0.3
        torso.Position = standPosition + Vector3.new(0, floatOffset, 0)
        
        if head then
            head.Position = torso.Position + Vector3.new(0, 2, 0)
        end
        
        if leftArm then
            leftArm.Position = torso.Position + Vector3.new(-1.5, 0, 0)
        end
        
        if rightArm then
            rightArm.Position = torso.Position + Vector3.new(1.5, 0, 0)
        end
        
        if leftLeg then
            leftLeg.Position = torso.Position + Vector3.new(-0.5, -2, 0)
        end
        
        if rightLeg then
            rightLeg.Position = torso.Position + Vector3.new(0.5, -2, 0)
        end
    end
end

-- Function để spawn Stand
local function spawnStand()
    if standModel then
        standModel:Destroy()
    end
    
    standModel = createStand()
    standModel.Parent = workspace
    
    -- Start update loop
    RunService.Heartbeat:Connect(function()
        if isStandActive and standModel and standModel.Parent then
            updateStandPosition()
        end
    end)
end

-- Function để despawn Stand
local function despawnStand()
    if standModel then
        standModel:Destroy()
        standModel = nil
    end
end

-- Function Ora Ora attack
local function performOraOra()
    if isOraOraActive then return end
    if targetPlayerName == "" then return end
    
    local targetPlayer = findPlayerByPartialName(targetPlayerName)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then return end
    
    isOraOraActive = true
    
    -- Di chuyển stand đến trước mặt target
    if standModel and standModel:FindFirstChild("Torso") then
        local standTorso = standModel.Torso
        local targetPosition = targetRootPart.Position + targetRootPart.CFrame.LookVector * -3
        
        -- Teleport stand đến vị trí
        standTorso.Position = targetPosition
        
        -- Ora Ora animation
        local leftArm = standModel:FindFirstChild("LeftArm")
        local rightArm = standModel:FindFirstChild("RightArm")
        
        if leftArm and rightArm then
            -- Tạo âm thanh Ora Ora (có thể thêm sound effect)
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://131961136" -- Punch sound
            sound.Volume = 0.5
            sound.Parent = standTorso
            
            -- Animation đấm liên hoàn
            for i = 1, 20 do
                wait(0.1)
                
                -- Punch animation
                if i % 2 == 0 then
                    leftArm.Position = standTorso.Position + Vector3.new(-2, 0, -1)
                    rightArm.Position = standTorso.Position + Vector3.new(1.5, 0, 0)
                else
                    rightArm.Position = standTorso.Position + Vector3.new(2, 0, -1)
                    leftArm.Position = standTorso.Position + Vector3.new(-1.5, 0, 0)
                end
                
                sound:Play()
                
                -- Damage effect (có thể thêm damage system)
                local explosion = Instance.new("Explosion")
                explosion.Position = targetRootPart.Position
                explosion.BlastRadius = 5
                explosion.BlastPressure = 0
                explosion.Parent = workspace
            end
            
            sound:Destroy()
        end
    end
    
    wait(1)
    isOraOraActive = false
end

-- Event handlers
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        targetPlayerName = inputBox.Text
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    isStandActive = not isStandActive
    
    if isStandActive then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        spawnStand()
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        despawnStand()
    end
end)

oraButton.MouseButton1Click:Connect(function()
    if isStandActive and not isOraOraActive then
        spawn(function()
            performOraOra()
        end)
    end
end)

-- Cleanup khi player leave
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        despawnStand()
    end
end)
