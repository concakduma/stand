--[[
	Tác giả: Gemini
	Mô tả: Script cho phép người chơi trở thành Stand cho một người chơi khác.
	Người chơi (Stand) sẽ có giao diện để chọn "Stand User" và tự động đi theo họ.
]]

-- Dịch vụ cần thiết
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Người chơi cục bộ (người sẽ làm Stand) và nhân vật
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

-- Biến trạng thái
local isFollowing = false -- Trạng thái đang đi theo Stand User
local standUser = nil -- Người chơi được chọn làm Stand User
local isGuiMinimized = false -- Trạng thái GUI có bị thu nhỏ không

-- =================================================================
-- PHẦN 1: TẠO GIAO DIỆN NGƯỜI DÙNG (GUI)
-- =================================================================
local function createStandControlGui()
	-- Tạo các thành phần GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StandControlGui"
	screenGui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 200, 0, 250) -- Kích thước ban đầu
	mainFrame.Position = UDim2.new(0, 10, 0.5, -125)
	mainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	mainFrame.BorderColor3 = Color3.fromRGB(120, 0, 255)
	mainFrame.BorderSizePixel = 2
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.Size = UDim2.new(1, 0, 0, 30)
	titleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleFrame.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(170, 85, 255)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = "TRỞ THÀNH STAND"
	titleLabel.TextSize = 18
	titleLabel.Parent = titleFrame

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Size = UDim2.new(0, 25, 0, 25)
	minimizeButton.Position = UDim2.new(1, -28, 0.5, -12.5)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.Font = Enum.Font.SourceSansBold
	minimizeButton.Text = "-"
	minimizeButton.TextSize = 20
	minimizeButton.Parent = titleFrame

	local nameTextBox = Instance.new("TextBox")
	nameTextBox.Name = "NameTextBox"
	nameTextBox.Size = UDim2.new(1, -20, 0, 40)
	nameTextBox.Position = UDim2.new(0, 10, 0, 40)
	nameTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	nameTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameTextBox.PlaceholderText = "Chọn Stand User..."
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
	onOffButton.Text = "FOLLOW: OFF"
	onOffButton.TextSize = 18
	onOffButton.Parent = mainFrame

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
					standUser = player
					playerListFrame.Visible = false
				end)
			end
		end
	end
	
	-- Logic thu nhỏ / mở rộng GUI
	minimizeButton.MouseButton1Click:Connect(function()
		isGuiMinimized = not isGuiMinimized
		
		nameTextBox.Visible = not isGuiMinimized
		onOffButton.Visible = not isGuiMinimized
		if playerListFrame.Visible then
			playerListFrame.Visible = not isGuiMinimized
		end
		
		if isGuiMinimized then
			minimizeButton.Text = "+"
			mainFrame:TweenSize(UDim2.new(0, 200, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		else
			minimizeButton.Text = "-"
			mainFrame:TweenSize(UDim2.new(0, 200, 0, 250), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		end
	end)

	-- Sự kiện cho các nút
	nameTextBox.Focused:Connect(updatePlayerList)
	nameTextBox.FocusLost:Connect(function()
		wait(0.2)
		playerListFrame.Visible = false
	end)

	onOffButton.MouseButton1Click:Connect(function()
		if not standUser then
			print("Vui lòng chọn một Stand User trước!")
			return
		end
		
		isFollowing = not isFollowing
		if isFollowing then
			onOffButton.Text = "FOLLOW: ON"
			onOffButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		else
			onOffButton.Text = "FOLLOW: OFF"
			onOffButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
	end)

	return screenGui
end

-- =================================================================
-- PHẦN 2: LOGIC CHÍNH VÀ VÒNG LẶP CẬP NHẬT
-- =================================================================

-- Khởi tạo GUI
local standGui = createStandControlGui()
standGui.Parent = playerGui

-- Vòng lặp cập nhật vị trí của bạn (Stand) mỗi khung hình
RunService.RenderStepped:Connect(function()
	if not isFollowing or not standUser or not standUser.Character or not standUser.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	-- Lấy CFrame của Stand User
	local userRoot = standUser.Character.HumanoidRootPart
	local userCFrame = userRoot.CFrame
	
	-- Tính toán vị trí phía sau và hơi lệch sang phải của Stand User
	local offset = CFrame.new(2, 0, 4) -- Khoảng cách như trong ảnh
	local standTargetCFrame = userCFrame * offset
	
	-- Di chuyển nhân vật của bạn đến vị trí đó
	character:SetPrimaryPartCFrame(standTargetCFrame)
end)

-- Xử lý khi người chơi chết và hồi sinh
localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	-- Tắt chế độ follow khi chết để tránh lỗi
	isFollowing = false
	local onOffButton = standGui:FindFirstChild("MainFrame"):FindFirstChild("OnOffButton")
	if onOffButton then
		onOffButton.Text = "FOLLOW: OFF"
		onOffButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)
