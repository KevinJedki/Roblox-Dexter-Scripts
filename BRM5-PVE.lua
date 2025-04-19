local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local trackedParts = {}
local wallEnabled = false
local wallConnections = {}
local guiVisible = true
local isUnloaded = false

-- Color for Head
local colorMap = {
    Head = Color3.fromRGB(0, 255, 0) -- Green
}

-- Destroy all ESP boxes
local function destroyAllBoxes()
    for part, _ in pairs(trackedParts) do
        if part and part.Parent then
            if part:FindFirstChild("Wall_Red") then part.Wall_Red:Destroy() end
            if part:FindFirstChild("Wall_Green") then part.Wall_Green:Destroy() end
        end
    end
    trackedParts = {}
end

-- Create boxes for a specific body part
local function createBoxForPart(part)
    if isUnloaded or not part or part.Parent == nil then return end
    if part:FindFirstChild("Wall_Red") then return end

    local boxSize = part.Size + Vector3.new(0.1, 0.1, 0.1)

    local redBox = Instance.new("BoxHandleAdornment")
    redBox.Name = "Wall_Red"
    redBox.Size = boxSize
    redBox.Adornee = part
    redBox.AlwaysOnTop = true
    redBox.ZIndex = 5
    redBox.Color3 = Color3.fromRGB(255, 0, 0)
    redBox.Transparency = 1
    redBox.Parent = part

    local greenBox = Instance.new("BoxHandleAdornment")
    greenBox.Name = "Wall_Green"
    greenBox.Size = boxSize
    greenBox.Adornee = part
    greenBox.AlwaysOnTop = false
    greenBox.ZIndex = 4
    greenBox.Color3 = colorMap[part.Name] or Color3.fromRGB(0, 255, 0)
    greenBox.Transparency = 0.3
    greenBox.Parent = part

    trackedParts[part] = true
end

-- Create ESP for all NPC heads
local function createBoxesForAllNPCs()
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == "Male" then
            for _, child in ipairs(npc:GetChildren()) do
                if child.Name:sub(1, 3) == "AI_" then
                    local head = npc:FindFirstChild("Head")
                    if head then createBoxForPart(head) end
                    break
                end
            end
        end
    end
end

-- Register existing NPCs (only heads)
local function registerExistingNPCs()
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == "Male" then
            for _, child in ipairs(npc:GetChildren()) do
                if child.Name:sub(1, 3) == "AI_" then
                    local head = npc:FindFirstChild("Head")
                    if head then trackedParts[head] = true end
                    break
                end
            end
        end
    end
end

-- GUI
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "Wall_GUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = guiVisible
mainFrame.AnchorPoint = Vector2.new(0, 0)

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "BRM5 v4 by dexter"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BorderSizePixel = 0
Instance.new("UICorner", title)

local buttonContainer = Instance.new("Frame", mainFrame)
buttonContainer.Position = UDim2.new(0, 0, 0, 40)
buttonContainer.Size = UDim2.new(1, 0, 1, -40)
buttonContainer.BackgroundTransparency = 1

local uiList = Instance.new("UIListLayout", buttonContainer)
uiList.Padding = UDim.new(0, 8)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

local toggleBtn = Instance.new("TextButton", buttonContainer)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.Text = "Wall OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextScaled = true
Instance.new("UICorner", toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    toggleBtn.Text = wallEnabled and "Wall ON" or "Wall OFF"
    if wallEnabled then
        createBoxesForAllNPCs()
    else
        destroyAllBoxes()
    end
end)

local unloadBtn = Instance.new("TextButton", buttonContainer)
unloadBtn.Size = UDim2.new(1, -20, 0, 30)
unloadBtn.Text = "Unload"
unloadBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
unloadBtn.TextColor3 = Color3.new(1, 1, 1)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextScaled = true
Instance.new("UICorner", unloadBtn)

unloadBtn.MouseButton1Click:Connect(function()
    isUnloaded = true
    destroyAllBoxes()
    screenGui:Destroy()
    for _, conn in ipairs(wallConnections) do
        pcall(function() conn:Disconnect() end)
    end
end)

buttonContainer.Parent = mainFrame

-- Initialize tracking
registerExistingNPCs()

-- Detect new NPCs
local childConn = workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "Male" then
        task.wait(0.5)
        for _, c in ipairs(child:GetChildren()) do
            if c.Name:sub(1, 3) == "AI_" then
                local head = child:FindFirstChild("Head")
                if head then 
                    trackedParts[head] = true
                    if wallEnabled then
                        createBoxForPart(head)
                    end
                end
                break
            end
        end
    end
end)
table.insert(wallConnections, childConn)

-- Visibility check
local renderConn = RunService.RenderStepped:Connect(function()
    if not wallEnabled or isUnloaded then return end

    for part, _ in pairs(trackedParts) do
        if part and part.Parent and part:FindFirstChild("Wall_Red") and part:FindFirstChild("Wall_Green") then
            local origin = camera.CFrame.Position
            local direction = (part.Position - origin).Unit * 1000

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {localPlayer.Character, part}

            local result = workspace:Raycast(origin, part.Position - origin, rayParams)
            local isVisible = not result or result.Instance:IsDescendantOf(part.Parent)

            part.Wall_Green.Transparency = isVisible and 0.3 or 1
            part.Wall_Red.Transparency = isVisible and 1 or 0.3
        end
    end
end)
table.insert(wallConnections, renderConn)

-- Insert key toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or isUnloaded then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)
