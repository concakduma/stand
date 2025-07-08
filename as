-- =================================================================
-- Script làm Stand cho người khác
-- Tạo bởi AI theo yêu cầu của bạn
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- Các biến trạng thái
local isEnabled = false -- Script đang bật hay tắt
local targetPlayer = nil -- Người chơi mục tiêu (Stand User)
local currentMode = "behind" -- Chế độ theo sau: 'behind' (đằng sau) hoặc 'ora' (đằng trước)
local isShrunk = false -- Bạn có đang bị thu nhỏ hay không

-- =================================================================
-- TẠO GIAO DIỆN ĐIỀU KHIỂN (GUI)
-- =================================================================

-- Tạo ScreenGui để chứa tất cả
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandControllerGui"
screenGui.ResetOnSpawn = false -- Không reset GUI khi chết
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Tạo khung chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0, 10, 0.5, -150) -- Đặt ở giữa bên trái
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderColor3 = Color3.fromRGB(150, 90, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Tạo tiêu đề
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(150, 90, 255)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Text = "Stand Jojo"
titleLabel.Parent = mainFrame

-- Hộp nhập tên
local nameInput = Instance.new("TextBox")
nameInput.Name = "NameInput"
nameInput.Size = UDim2.new(1, -10, 0, 30)
nameInput.Position = UDim2.new(0, 5, 0, 40)
nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.Font = Enum.Font.SourceSans
nameInput.TextSize = 14
nameInput.Text = ""
nameInput.PlaceholderText = "Nhập tên người chơi..."
nameInput.ClearTextOnFocus = false
nameInput.Parent = mainFrame

-- Khung cuộn để hiện danh sách người chơi
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "PlayerList"
scrollingFrame.Size = UDim2.new(1, -10, 0, 100)
scrollingFrame.Position = UDim2.new(0, 5, 0, 75)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollingFrame.BorderSizePixel = 1
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 90, 255)
scrollingFrame.Visible = false -- Ban đầu ẩn đi
scrollingFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Parent = scrollingFrame

-- Label hiển thị mục tiêu hiện tại
local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Name = "TargetInfo"
targetInfoLabel.Size = UDim2.new(1, -10, 0, 20)
targetInfoLabel.Position = UDim2.new(0, 5, 0, 180)
targetInfoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetInfoLabel.BackgroundTransparency = 1
targetInfoLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
targetInfoLabel.Font = Enum.Font.SourceSansItalic
targetInfoLabel.TextSize = 14
targetInfoLabel.Text = "Mục tiêu: Chưa chọn"
targetInfoLabel.Parent = mainFrame

-- Nút Bật/Tắt
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 85, 0, 30)
toggleButton.Position = UDim2.new(0, 5, 0, 210)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ (OFF)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Text = "OFF"
toggleButton.Parent = mainFrame

-- Nút chế độ ORA ORA
local oraButton = Instance.new("TextButton")
oraButton.Name = "OraButton"
oraButton.Size = UDim2.new(0, 85, 0, 30)
oraButton.Position = UDim2.new(1, -90, 0, 210)
oraButton.BackgroundColor3 = Color3.fromRGB(150, 90, 255)
oraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
oraButton.Font = Enum.Font.SourceSansBold
oraButton.TextSize = 16
oraButton.Text = "ORA ORA"
oraButton.Parent = mainFrame

-- Nút thu nhỏ
local shrinkButton = Instance.new("TextButton")
shrinkButton.Name = "ShrinkButton"
shrinkButton.Size = UDim2.new(1, -10, 0, 30)
shrinkButton.Position = UDim2.new(0, 5, 0, 250)
shrinkButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
shrinkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shrinkButton.Font = Enum.Font.SourceSansBold
shrinkButton.TextSize = 20
shrinkButton.Text = "-"
shrinkButton.Parent = mainFrame


-- =================================================================
-- LOGIC CỦA SCRIPT
-- =================================================================

-- Hàm cập nhật danh sách người chơi
local function updatePlayerList()
	scrollingFrame:ClearAllChildren() -- Xóa danh sách cũ
	
	local searchText = nameInput.Text:lower()
	local canvasHeight = 0
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Name:lower():match("^" .. searchText) then
			local playerButton = Instance.new("TextButton")
			playerButton.Name = player.Name
			playerButton.Size = UDim2.new(1, -10, 0, 25)
			playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			playerButton.Font = Enum.Font.SourceSans
			playerButton.TextSize = 14
			playerButton.Text = player.Name
			playerButton.Parent = scrollingFrame
			
			canvasHeight = canvasHeight + 30 -- 25 height + 5 padding
			
			-- Sự kiện khi click chọn một người chơi
			playerButton.MouseButton1Click:Connect(function()
				targetPlayer = player
				targetInfoLabel.Text = "Mục tiêu: " .. player.Name
				nameInput.Text = ""
				scrollingFrame.Visible = false
			end)
		end
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
end

-- Sự kiện khi click vào ô nhập tên
nameInput.Focused:Connect(function()
	scrollingFrame.Visible = true
	updatePlayerList()
end)

-- Sự kiện khi gõ chữ vào ô nhập tên
nameInput.TextChanged:Connect(updatePlayerList)

-- Sự kiện khi click ra ngoài ô nhập tên
nameInput.FocusLost:Connect(function(enterPressed)
	if not enterPressed then
		-- Dùng task.wait để chờ một chút, nếu không sự kiện click vào button player sẽ không kịp chạy
		task.wait(0.2) 
		scrollingFrame.Visible = false
	end
end)


-- Sự kiện click nút Bật/Tắt
toggleButton.MouseButton1Click:Connect(function()
	isEnabled = not isEnabled -- Đảo ngược trạng thái
	if isEnabled then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Màu xanh (ON)
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ (OFF)
	end
end)

-- Sự kiện click nút ORA ORA
oraButton.MouseButton1Click:Connect(function()
	if currentMode == "behind" then
		currentMode = "ora"
		oraButton.Text = "BEHIND"
	else
		currentMode = "behind"
		oraButton.Text = "ORA ORA"
	end
end)

-- Hàm thu nhỏ/phóng to nhân vật
local function setCharacterScale(scale)
	local character = localPlayer.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.BodyDepthScale.Value = scale
		humanoid.BodyHeightScale.Value = scale
		humanoid.BodyWidthScale.Value = scale
		humanoid.HeadScale.Value = scale
	end
end

-- Sự kiện click nút Thu nhỏ
shrinkButton.MouseButton1Click:Connect(function()
	isShrunk = not isShrunk
	if isShrunk then
		setCharacterScale(0.5) -- Thu nhỏ lại một nửa
		shrinkButton.Text = "+"
	else
		setCharacterScale(1) -- Trở về kích thước bình thường
		shrinkButton.Text = "-"
	end
end)


-- Vòng lặp chính để di chuyển theo mục tiêu
RunService.Heartbeat:Connect(function()
	-- Chỉ chạy khi script được bật, có mục tiêu, và mục tiêu còn trong server
	if not isEnabled or not targetPlayer or not targetPlayer.Parent then
		-- Nếu mục tiêu thoát game, reset lại
		if targetPlayer and not targetPlayer.Parent then
			targetPlayer = nil
			targetInfoLabel.Text = "Mục tiêu: Đã thoát"
			isEnabled = false
			toggleButton.Text = "OFF"
			toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
		return
	end
	
	local myCharacter = localPlayer.Character
	local targetCharacter = targetPlayer.Character
	
	-- Kiểm tra xem cả 2 nhân vật có tồn tại và có HumanoidRootPart không
	if not myCharacter or not targetCharacter then return end
	
	local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	
	if not myRoot or not targetRoot then return end
	
	-- Tính toán vị trí mới
	local offset
	if currentMode == "behind" then
		-- Vị trí: Lùi ra sau 4 studs, lệch sang trái 2.5 studs (nhìn từ phía mục tiêu)
		offset = CFrame.new(-2.5, 0, 4) 
	else -- Chế độ 'ora'
		-- Vị trí: Đứng ngay trước mặt, cách 4 studs
		offset = CFrame.new(0, 0, -4)
	end
	
	-- Lấy CFrame của mục tiêu và áp dụng offset để có CFrame mới
	local newCFrame = targetRoot.CFrame * offset
	
	-- Di chuyển nhân vật của bạn đến vị trí mới
	-- CFrame bao gồm cả vị trí (Position) và hướng nhìn (Rotation)
	myRoot.CFrame = newCFrame
end)
