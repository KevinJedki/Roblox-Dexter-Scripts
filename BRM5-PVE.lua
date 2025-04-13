-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- General state
local ESP_ENABLED = true
local HEAD_EXPAND_ENABLED = true
local UI_VISIBLE = true

-- Tracking tables
local trackedHeads = {}
local originalSizes = {}

-- Fixed size for visual boxes (cube)
local VISUAL_BOX_SIZE = Vector3.new(1.4, 1.5, 1.4)

-- Detect abnormal sizes
local function isWeirdSize(size)
	return size.X > 3 or size.Y > 3 or size.Z > 3
end

-- Create visual adornments
local function createAdornments(head)
	if head:FindFirstChild("ESP_Red") or head:FindFirstChild("ESP_Green") then return end

	local redBox = Instance.new("BoxHandleAdornment")
	redBox.Name = "ESP_Red"
	redBox.Size = VISUAL_BOX_SIZE
	redBox.Adornee = head
	redBox.AlwaysOnTop = true
	redBox.ZIndex = 5
	redBox.Color3 = Color3.fromRGB(255, 0, 0)
	redBox.Transparency = ESP_ENABLED and 0.3 or 1
	redBox.Visible = ESP_ENABLED
	redBox.Parent = head

	local greenBox = Instance.new("BoxHandleAdornment")
	greenBox.Name = "ESP_Green"
	greenBox.Size = VISUAL_BOX_SIZE
	greenBox.Adornee = head
	greenBox.AlwaysOnTop = false
	greenBox.ZIndex = 4
	greenBox.Color3 = Color3.fromRGB(0, 255, 0)
	greenBox.Transparency = ESP_ENABLED and 0.3 or 1
	greenBox.Visible = ESP_ENABLED
	greenBox.Parent = head

	trackedHeads[head] = redBox
end

-- Adjust head and HRP size
local function updateHeadSize(model)
	local head = model:FindFirstChild("Head")
	local hrp = model:FindFirstChild("HumanoidRootPart")

	if head then
		if not originalSizes[head] then
			if isWeirdSize(head.Size) then
				originalSizes[head] = VISUAL_BOX_SIZE
				head.Size = VISUAL_BOX_SIZE
			else
				originalSizes[head] = head.Size
			end
		end
		if HEAD_EXPAND_ENABLED then
			head.Size = Vector3.new(9, 9, 9)
			head.Transparency = 0.85
			head.CanCollide = true
		else
			head.Size = originalSizes[head]
			head.Transparency = 0
			head.CanCollide = false
		end

		local redBox = head:FindFirstChild("ESP_Red")
		if redBox then redBox.Size = VISUAL_BOX_SIZE end
		local greenBox = head:FindFirstChild("ESP_Green")
		if greenBox then greenBox.Size = VISUAL_BOX_SIZE end
	end

	if hrp then
		if not originalSizes[hrp] then
			originalSizes[hrp] = hrp.Size
		end
		if HEAD_EXPAND_ENABLED then
			hrp.Size = Vector3.new(9, 9, 9)
			hrp.Transparency = 0.85
			hrp.CanCollide = false
		else
			hrp.Size = originalSizes[hrp]
			hrp.Transparency = 0
			hrp.CanCollide = true
		end
	end
end

-- Process "Male" model
local function processModel(model)
	if model:IsA("Model") and model.Name == "Male" then
		local hasAIChild = false
		for _, child in pairs(model:GetChildren()) do
			if string.sub(child.Name, 1, 3) == "AI_" then
				hasAIChild = true
				break
			end
		end

		if hasAIChild and model:FindFirstChild("Head") then
			createAdornments(model.Head)
			updateHeadSize(model)
		end
	end
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0, 10, 0, 100)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

-- Button creation function
local function createButton(text, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 0, (#frame:GetChildren() - 1) * 35)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	button.Text = text
	button.MouseButton1Click:Connect(callback)
	return button
end

-- ESP toggle button
local espBtn
espBtn = createButton("ESP: ON", function()
	ESP_ENABLED = not ESP_ENABLED
	espBtn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
	for head, redBox in pairs(trackedHeads) do
		if redBox then
			redBox.Visible = ESP_ENABLED
			redBox.Transparency = ESP_ENABLED and 0.3 or 1
			local greenBox = head:FindFirstChild("ESP_Green")
			if greenBox then
				greenBox.Visible = ESP_ENABLED
				greenBox.Transparency = ESP_ENABLED and 0.3 or 1
			end
		end
	end
end)

-- Big head toggle button
local bigHeadBtn
bigHeadBtn = createButton("Big Head: ON", function()
	HEAD_EXPAND_ENABLED = not HEAD_EXPAND_ENABLED
	bigHeadBtn.Text = "Big Head: " .. (HEAD_EXPAND_ENABLED and "ON" or "OFF")
	for _, model in pairs(workspace:GetChildren()) do
		processModel(model)
	end
end)

-- Full script shutdown
createButton("Close Script", function()
	for head, _ in pairs(trackedHeads) do
		local model = head:FindFirstAncestorOfClass("Model")
		if model then
			if originalSizes[head] then
				head.Size = originalSizes[head]
				head.Transparency = 0
				head.CanCollide = false
			end
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp and originalSizes[hrp] then
				hrp.Size = originalSizes[hrp]
				hrp.Transparency = 0
				hrp.CanCollide = true
			end
		end
		if head:FindFirstChild("ESP_Red") then head.ESP_Red:Destroy() end
		if head:FindFirstChild("ESP_Green") then head.ESP_Green:Destroy() end
	end

	trackedHeads = {}
	originalSizes = {}

	if screenGui then screenGui:Destroy() end
	if script and script.Parent then script:Destroy() end
end)

-- Toggle GUI visibility with Insert key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
		UI_VISIBLE = not UI_VISIBLE
		frame.Visible = UI_VISIBLE
	end
end)

-- Raycast for visibility check
RunService.RenderStepped:Connect(function()
	for head, redBox in pairs(trackedHeads) do
		if head and redBox then
			local origin = Camera.CFrame.Position
			local direction = head.Position - origin
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			local result = workspace:Raycast(origin, direction, rayParams)
			if result and result.Instance ~= head then
				redBox.Transparency = 0.3
			else
				redBox.Transparency = 1
			end
		end
	end
end)

-- Process existing models
for _, model in pairs(workspace:GetChildren()) do
	processModel(model)
end

-- Process newly added models
workspace.ChildAdded:Connect(function(child)
	task.wait(0.5) -- wait half a second to allow the model to stabilize
	processModel(child)
end)
