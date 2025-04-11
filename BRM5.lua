-- Creates a red transparent box around a character's head for ESP visualization
local function createAdornment(head)
	-- If the adornment already exists, do nothing
	if head:FindFirstChild("ESP_Adornment") then return end

	-- Create a new box adornment
	local box = Instance.new("BoxHandleAdornment")
	box.Name = "ESP_Adornment"
	box.Size = head.Size -- Match the size of the head
	box.Adornee = head -- Attach the box to the head
	box.AlwaysOnTop = true -- Make sure it's always visible on top of other objects
	box.ZIndex = 5 -- Render priority (higher = drawn later)
	box.Color3 = Color3.fromRGB(255, 0, 0) -- Red color
	box.Transparency = 0.3 -- Slightly see-through
	box.Parent = head -- Parent it to the head so it moves with it
end

-- Checks if a model should have an adornment and applies it
local function processModel(model)
	-- Check if the instance is a Model and is named "Male"
	if model:IsA("Model") and model.Name == "Male" then
		local hasAIChild = false

		-- Loop through the model's children to find any with a name starting with "AI_"
		for _, child in pairs(model:GetChildren()) do
			if string.sub(child.Name, 1, 3) == "AI_" then
				hasAIChild = true
				break
			end
		end

		-- If it has an AI_ child and a Head part, add the ESP box
		if hasAIChild and model:FindFirstChild("Head") then
			createAdornment(model.Head)
		end
	end
end

-- Process all current models in the workspace when the script runs
for _, model in pairs(workspace:GetChildren()) do
	processModel(model)
end

-- Listen for new models being added to the workspace
workspace.ChildAdded:Connect(function(child)
	-- Wait a moment to ensure all children of the new model are loaded
	task.wait(0.1)
	processModel(child)
end)
