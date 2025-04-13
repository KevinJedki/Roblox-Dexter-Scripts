-- Required services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Tables to store adornments
local trackedHeads = {}

-- Creates both adornments on the head
local function createAdornments(head)
	-- Don't create adornments if they already exist
	if head:FindFirstChild("ESP_Red") or head:FindFirstChild("ESP_Green") then return end

	-- Red box (only visible if behind a wall)
	local redBox = Instance.new("BoxHandleAdornment")
	redBox.Name = "ESP_Red"
	redBox.Size = head.Size
	redBox.Adornee = head
	redBox.AlwaysOnTop = true
	redBox.ZIndex = 5
	redBox.Color3 = Color3.fromRGB(255, 0, 0)
	redBox.Transparency = 0.3
	redBox.Parent = head

	-- Green box (always visible, but respects walls)
	local greenBox = Instance.new("BoxHandleAdornment")
	greenBox.Name = "ESP_Green"
	greenBox.Size = head.Size
	greenBox.Adornee = head
	greenBox.AlwaysOnTop = false
	greenBox.ZIndex = 4
	greenBox.Color3 = Color3.fromRGB(0, 255, 0)
	greenBox.Transparency = 0.3
	greenBox.Parent = head

	-- Save references
	trackedHeads[head] = redBox
end

-- Processes "Male" models with children named "AI_"
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
		end
	end
end

-- Checks if the head is visible and adjusts the red adornment
RunService.RenderStepped:Connect(function()
	for head, redBox in pairs(trackedHeads) do
		if head and head:IsDescendantOf(workspace) and redBox then
			local origin = camera.CFrame.Position
			local direction = (head.Position - origin)
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {localPlayer.Character}
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			local result = workspace:Raycast(origin, direction, rayParams)

			if result and result.Instance ~= head then
				redBox.Transparency = 0.3 -- Show if it's behind something
			else
				redBox.Transparency = 1 -- Hide if it's in sight
			end
		end
	end
end)

-- Process models already in the workspace
for _, model in pairs(workspace:GetChildren()) do
	processModel(model)
end

-- Process newly added models
workspace.ChildAdded:Connect(function(child)
	task.wait(0.1)
	processModel(child)
end)
