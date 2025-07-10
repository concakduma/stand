--[[
	Script được tạo bởi một AI chuyên nghiệp, đáp ứng yêu cầu của người dùng.
	Chức năng:
	1. Tạo GUI để điều khiển.
	2. Tìm kiếm và chọn người chơi trong server để "làm Stand".
	3. Bật/Tắt chế độ đi theo (teleport liên tục sau lưng).
	4. Nút "Ora Ora" để di chuyển ra phía trước mục tiêu.
	5. Nút thu nhỏ/phóng to GUI.
]]

-- DỊCH VỤ CẦN THIẾT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- NGƯỜI CHƠI LOCAL (chính là bạn, người sẽ làm Stand)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- BIẾN TRẠNG THÁI
local targetPlayer = nil
local targetCharacter = nil
local targetRootPart = nil
local isFollowing = false
local followConnection = nil
local followMode = "Behind" -- Chế độ: "Behind" (sau lưng) hoặc "Front" (trước mặt)
local behindOffset = CFrame.new(0, 0.5, 4.5)  -- Khoảng cách phía sau (giống ảnh 1)
local frontOffset = CFrame.new(0, 0, -4.5) -- Khoảng cách phía trước (giống ảnh 2)

-- TẠO GIAO DIỆN (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandControllerGui"
screenGui.ResetOnSpawn = false -- Không reset GUI khi chết
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 300)
mainFrame.Position = UDim2.new(0.01, 0, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderColor3 = Color3.fromRGB(150, 100, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Draggable = true -- Cho phép kéo thả GUI
mainFrame.Active = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Stand Jojo"
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local inputLabel = Instance.new("TextLabel")
inputLabel.Name = "InputLabel"
inputLabel.Size = UDim2.new(1, -10, 0, 20)
inputLabel.Position = UDim2.new(0, 5, 0, 5)
inputLabel.BackgroundTransparency = 1
inputLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
inputLabel.Text = "Nhập tên (Stand User):"
inputLabel.Font = Enum.Font.SourceSans
inputLabel.TextSize = 14
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Parent = contentFrame

local nameInput = Instance.new("TextBox")
nameInput.Name = "NameInput"
nameInput.Size = UDim2.new(1, -10, 0, 30)
nameInput.Position = UDim2.new(0, 5, 0, 25)
nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
nameInput.BorderColor3 = Color3.fromRGB(120, 120, 120)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.Text = ""
nameInput.PlaceholderText = "Click và gõ tên..."
nameInput.Font = Enum.Font.SourceSans
nameInput.TextSize = 14
nameInput.ClearTextOnFocus = false
nameInput.Parent = contentFrame

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -10, 0, 120)
playerList.Position = UDim2.new(0, 5, 0, 60)
playerList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerList.BorderColor3 = Color3.fromRGB(120, 120, 120)
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
playerList.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playerList

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.5, -10, 0, 35)
toggleButton.Position = UDim2.new(0, 5, 1, -40)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ cho Off
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "OFF"
toggleButton.TextSize = 18
toggleButton.Parent = contentFrame

local oraButton = Instance.new("TextButton")
oraButton.Name = "OraButton"
oraButton.Size = UDim2.new(0.5, -10, 0, 35)
oraButton.Position = UDim2.new(0.5, 5, 1, -40)
oraButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
oraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
oraButton.Font = Enum.Font.SourceSansBold
oraButton.Text = "ORA ORA"
oraButton.TextSize = 18
oraButton.Parent = contentFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Text = "-"
minimizeButton.TextSize = 24
minimizeButton.Parent = mainFrame

-- CHỨC NĂNG
local function updatePlayerList()
	playerList:ClearAllChildren() -- Xóa danh sách cũ
	listLayout.Parent = playerList -- Gắn lại layout
	
	local inputText = nameInput.Text:lower()
	local matchingPlayers = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Name:lower():sub(1, #inputText) == inputText then
			table.insert(matchingPlayers, player)
		end
	end

	for i, player in ipairs(matchingPlayers) do
		local playerButton = Instance.new("TextButton")
		playerButton.Name = player.Name
		playerButton.Size = UDim2.new(1, 0, 0, 25)
		playerButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		playerButton.Font = Enum.Font.SourceSans
		playerButton.Text = player.Name
		playerButton.TextSize = 14
		playerButton.LayoutOrder = i
		playerButton.Parent = playerList

		playerButton.MouseButton1Click:Connect(function()
			nameInput.Text = player.Name
			targetPlayer = player
			print("Đã chọn Stand User:", targetPlayer.Name)
			-- Reset chế độ về sau lưng mỗi khi chọn mục tiêu mới
			followMode = "Behind" 
		end)
	end
end

local function stopFollowing()
	isFollowing = false
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
	toggleButton.Text = "OFF"
	toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

local function startFollowing()
	if not targetPlayer then
		warn("Chưa chọn Stand User!")
		return
	end

	isFollowing = true
	toggleButton.Text = "ON"
	toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Màu xanh cho On

	followConnection = RunService.RenderStepped:Connect(function()
		if not isFollowing then return end

		-- Kiểm tra mục tiêu còn tồn tại không
		if not targetPlayer or not targetPlayer.Parent then
			print("Mục tiêu đã rời khỏi game.")
			stopFollowing()
			return
		end

		targetCharacter = targetPlayer.Character
		if not targetCharacter then
			--print("Mục tiêu đang đợi hồi sinh...")
			return
		end

		targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
		if not targetRootPart or not humanoidRootPart then return end

		local offset
		if followMode == "Behind" then
			offset = behindOffset
		else -- "Front"
			offset = frontOffset
		end

		local targetCFrame = targetRootPart.CFrame * offset
		character:SetPrimaryPartCFrame(targetCFrame)
	end)
end


-- KẾT NỐI SỰ KIỆN
nameInput.Changed:Connect(updatePlayerList)
nameInput.Focused:Connect(updatePlayerList)

toggleButton.MouseButton1Click:Connect(function()
	if isFollowing then
		stopFollowing()
	else
		startFollowing()
	end
end)

oraButton.MouseButton1Click:Connect(function()
	if isFollowing then
		followMode = "Front"
		print("Chế độ ORA ORA: Di chuyển ra phía trước.")
	else
		warn("Cần bật chế độ 'ON' trước khi dùng ORA ORA.")
	end
end)

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	contentFrame.Visible = not isMinimized
	if isMinimized then
		mainFrame.Size = UDim2.new(0, 220, 0, 30) -- Chỉ còn thanh tiêu đề
		minimizeButton.Text = "+"
	else
		mainFrame.Size = UDim2.new(0, 220, 0, 300) -- Kích thước cũ
		minimizeButton.Text = "-"
	end
end)

-- Cập nhật danh sách khi có người chơi vào/ra
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
	if player == targetPlayer then
		print("Stand User đã thoát, tự động tắt.")
		stopFollowing()
		targetPlayer = nil
		nameInput.Text = ""
	end
	updatePlayerList()
end)

-- Khởi tạo danh sách lần đầu
updatePlayerList()
