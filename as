--[[
	Tác giả: Gemini
	Mô tả: Script tạo ra một Stand trong JoJo's Bizarre Adventure với giao diện điều khiển
	và các chức năng: triệu hồi, đi theo người dùng, và di chuyển đến trước mặt mục tiêu.
]]

-- Dịch vụ cần thiết
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Người chơi cục bộ và nhân vật
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Biến trạng thái
local isStandOn = false
local isOraActive = false
local targetPlayer = nil
local standModel = nil

-- =================================================================
-- PHẦN 1: TẠO STAND
-- =================================================================
-- Hàm này tạo ra một mô hình Stand đơn giản.
-- Bạn có thể thay thế mô hình này bằng một mô hình Stand chi tiết hơn nếu muốn.
local function createStandModel()
	local stand = Instance.new("Model")
	stand.Name = "MyStand"

	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.BrickColor = BrickColor.new("Electric blue")
	hrp.Material = Enum.Material.Neon
	hrp.CanCollide = false
	hrp.Anchored = true
	hrp.Parent = stand
	stand.PrimaryPart = hrp

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 2, 2)
	head.BrickColor = BrickColor.new("Deep violet")
	head.CanCollide = false
	head.Anchored = true
	head.Parent = stand
	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = hrp
	headWeld.Part1 = head
	headWeld.Parent = hrp

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(4, 4, 2)
	torso.BrickColor = BrickColor.new("Deep violet")
	torso.CanCollide = false
	torso.Anchored = true
	torso.Parent = stand
	local torsoWeld = Instance.new("WeldConstraint")
	torsoWeld.Part0 = hrp
	torsoWeld.Part1 = torso
	torsoWeld.Parent = hrp
	
	-- Di chuyển các bộ phận vào vị trí tương đối
	head.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
	torso.CFrame = hrp.CFrame * CFrame.new(0, 0, 0)

	return stand
end

-- =================================================================
-- PHẦN 2: TẠO GIAO DIỆN NGƯỜI DÙNG (GUI)
-- =================================================================
local function createStandGui()
	-- Tạo các thành phần GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StandGui"
	screenGui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 200, 0, 300)
	mainFrame.Position = UDim2.new(0, 10, 0.5, -150)
	mainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
	mainFrame.BorderSizePixel = 2
	mainFrame.Parent = screenGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = "STAND JOJO"
	titleLabel.TextSize = 20
	titleLabel.Parent = mainFrame

	local nameTextBox = Instance.new("TextBox")
	nameTextBox.Name = "NameTextBox"
	nameTextBox.Size = UDim2.new(1, -20, 0, 40)
	nameTextBox.Position = UDim2.new(0, 10, 0, 40)
	nameTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	nameTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameTextBox.PlaceholderText = "Nhập tên người chơi..."
	nameTextBox.Font = Enum.Font.SourceSans
	nameTextBox.TextSize = 16
	nameTextBox.ClearTextOnFocus = false
	nameTextBox.Parent = mainFrame

	local playerListFrame = Instance.new("ScrollingFrame")
	playerListFrame.Name = "PlayerListFrame"
	playerListFrame.Size = UDim2.new(1, -20, 0, 100)
	playerListFrame.Position = UDim2.new(0, 10, 0, 80)
	playerListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	playerListFrame.BorderSizePixel = 1
	playerListFrame.Visible = false -- Ẩn ban đầu
	playerListFrame.Parent = mainFrame
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = playerListFrame

	local onOffButton = Instance.new("TextButton")
	onOffButton.Name = "OnOffButton"
	onOffButton.Size = UDim2.new(1, -20, 0, 40)
	onOffButton.Position = UDim2.new(0, 10, 0, 190)
	onOffButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	onOffButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	onOffButton.Font = Enum.Font.SourceSansBold
	onOffButton.Text = "STAND: OFF"
	onOffButton.TextSize = 18
	onOffButton.Parent = mainFrame

	local oraButton = Instance.new("TextButton")
	oraButton.Name = "OraButton"
	oraButton.Size = UDim2.new(1, -20, 0, 40)
	oraButton.Position = UDim2.new(0, 10, 0, 240)
	oraButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
	oraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	oraButton.Font = Enum.Font.SourceSansBold
	oraButton.Text = "ORA ORA"
	oraButton.TextSize = 18
	oraButton.Parent = mainFrame

	-- Logic cập nhật danh sách người chơi
	local function updatePlayerList()
		playerListFrame.Visible = true
		for _, child in ipairs(playerListFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				local playerButton = Instance.new("TextButton")
				playerButton.Name = player.Name
				playerButton.Size = UDim2.new(1, 0, 0, 30)
				playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
				playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				playerButton.Font = Enum.Font.SourceSans
				playerButton.Text = player.Name
				playerButton.TextSize = 14
				playerButton.Parent = playerListFrame

				playerButton.MouseButton1Click:Connect(function()
					nameTextBox.Text = player.Name
					targetPlayer = player
					playerListFrame.Visible = false
				end)
			end
		end
	end

	-- Sự kiện cho các nút
	nameTextBox.Focused:Connect(updatePlayerList)
	nameTextBox.FocusLost:Connect(function()
		-- Đợi một chút để cho phép click vào danh sách
		wait(0.2)
		playerListFrame.Visible = false
	end)

	onOffButton.MouseButton1Click:Connect(function()
		isStandOn = not isStandOn
		if isStandOn then
			onOffButton.Text = "STAND: ON"
			onOffButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			standModel.Parent = Workspace
		else
			onOffButton.Text = "STAND: OFF"
			onOffButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			isOraActive = false -- Tắt ORA khi tắt Stand
			oraButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
			standModel.Parent = nil
		end
	end)

	oraButton.MouseButton1Click:Connect(function()
		if isStandOn and targetPlayer and targetPlayer.Character then
			isOraActive = not isOraActive
			if isOraActive then
				oraButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Màu cam khi kích hoạt
			else
				oraButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200) -- Quay lại màu cũ
			end
		else
			-- Có thể thêm thông báo cho người dùng ở đây
			print("Cần bật Stand và chọn mục tiêu hợp lệ!")
		end
	end)

	return screenGui
end

-- =================================================================
-- PHẦN 3: LOGIC CHÍNH VÀ VÒNG LẶP CẬP NHẬT
-- =================================================================

-- Khởi tạo Stand và GUI
standModel = createStandModel()
local standGui = createStandGui()
standGui.Parent = playerGui

-- Vòng lặp cập nhật vị trí của Stand mỗi khung hình
RunService.RenderStepped:Connect(function()
	-- Đảm bảo nhân vật và stand tồn tại
	if not character or not character:FindFirstChild("HumanoidRootPart") or not standModel or not standModel.PrimaryPart then
		return
	end
	
	local playerRoot = character.HumanoidRootPart

	if isStandOn then
		if isOraActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			-- Chế độ ORA ORA: Stand đứng trước mặt mục tiêu
			local targetRoot = targetPlayer.Character.HumanoidRootPart
			local targetCFrame = targetRoot.CFrame
			
			-- Tính toán vị trí trước mặt mục tiêu
			local offset = CFrame.new(0, 0, -5) -- Khoảng cách 5 stud trước mặt
			local standTargetCFrame = targetCFrame * offset
			
			standModel.PrimaryPart.CFrame = standTargetCFrame
			
		else
			-- Chế độ bình thường: Stand đi theo sau người chơi
			local playerCFrame = playerRoot.CFrame
			
			-- Tính toán vị trí phía sau và hơi lệch sang phải của người chơi
			local offset = CFrame.new(2, 0, 4) -- Khoảng cách như trong ảnh
			local standTargetCFrame = playerCFrame * offset
			
			standModel.PrimaryPart.CFrame = standTargetCFrame
		end
	end
end)

-- Xử lý khi người chơi chết
localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
	-- Tắt stand khi chết để tránh lỗi
	isStandOn = false
	isOraActive = false
	standModel.Parent = nil
	local onOffButton = standGui:FindFirstChild("MainFrame"):FindFirstChild("OnOffButton")
	if onOffButton then
		onOffButton.Text = "STAND: OFF"
		onOffButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)
