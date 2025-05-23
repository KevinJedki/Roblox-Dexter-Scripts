-- BRM5 v4 OPTIMIZED by dexter (with local file saving)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Local configuration (executor filesystem)
local configFile = "Dexter_Config.txt"

local function saveConfig(config)
    if writefile then
        writefile(configFile, HttpService:JSONEncode(config))
    end
end

local function loadConfig()
    if isfile and isfile(configFile) and readfile then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(configFile))
        end)
        if success then
            return data
        end
    end
    return {wall = false, silent = false, hitbox = false}
end

local config = loadConfig()
local wallEnabled = config.wall
local silentEnabled = config.silent
local showHitbox = config.hitbox
local guiVisible = true
local isUnloaded = false
local trackedParts = {}
local wallConnections = {}
local originalSizes = {}

local function destroyAllBoxes()
    for part, _ in pairs(trackedParts) do
        if part and part.Parent then
            if part:FindFirstChild("Wall_Box") then part.Wall_Box:Destroy() end
        end
    end
    trackedParts = {}
end

local function resetRootSizes()
    for model, originalSize in pairs(originalSizes) do
        if model and model:FindFirstChild("Root") then
            model.Root.Size = originalSize
            model.Root.Transparency = 1
        end
    end
    originalSizes = {}
end

local function createBoxForPart(part)
    if isUnloaded or not part or part.Parent == nil then return end
    if part:FindFirstChild("Wall_Box") then return end

    task.wait(0.5)

    if not part or not part.Parent or part:FindFirstChild("Wall_Box") then return end

    local boxSize = part.Size + Vector3.new(0.1, 0.1, 0.1)

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Wall_Box"
    box.Size = boxSize
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.3
    box.Parent = part

    trackedParts[part] = true
end

local function createBoxesForAllNPCs()
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == "Male" then
            local head = npc:FindFirstChild("Head")
            if head then createBoxForPart(head) end
        end
    end
end

local function registerExistingNPCs()
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == "Male" then
            local head = npc:FindFirstChild("Head")
            if head then trackedParts[head] = true end
        end
    end
end

-- GUI setup
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "Wall_GUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.Size = UDim2.new(0, 200, 0, 210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = guiVisible
mainFrame.AnchorPoint = Vector2.new(0, 0)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

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

local function createButton(text, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    Instance.new("UICorner", btn)
    return btn
end

local toggleBtn = createButton(wallEnabled and "Wall ON" or "Wall OFF", Color3.fromRGB(40, 40, 40), buttonContainer)
toggleBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    config.wall = wallEnabled
    saveConfig(config)
    toggleBtn.Text = wallEnabled and "Wall ON" or "Wall OFF"
    if wallEnabled then
        createBoxesForAllNPCs()
    else
        destroyAllBoxes()
    end
end)

local silentBtn = createButton(silentEnabled and "Silent ON (RISKY)" or "Silent OFF (RISKY)", Color3.fromRGB(80, 20, 20), buttonContainer)
silentBtn.Font = Enum.Font.GothamBold
silentBtn.MouseButton1Click:Connect(function()
    silentEnabled = not silentEnabled
    config.silent = silentEnabled
    saveConfig(config)
    silentBtn.Text = silentEnabled and "Silent ON (RISKY)" or "Silent OFF (RISKY)"
    if not silentEnabled then resetRootSizes() end
end)

local hitboxBtn = createButton(showHitbox and "Show Hitbox ON" or "Show Hitbox OFF", Color3.fromRGB(40, 80, 40), buttonContainer)
hitboxBtn.MouseButton1Click:Connect(function()
    showHitbox = not showHitbox
    config.hitbox = showHitbox
    saveConfig(config)
    hitboxBtn.Text = showHitbox and "Show Hitbox ON" or "Show Hitbox OFF"
    for model, _ in pairs(originalSizes) do
        if model and model:FindFirstChild("Root") then
            model.Root.Transparency = showHitbox and 0.85 or 1
        end
    end
end)

local unloadBtn = createButton("Unload", Color3.fromRGB(100, 0, 0), buttonContainer)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.MouseButton1Click:Connect(function()
    isUnloaded = true
    destroyAllBoxes()
    resetRootSizes()
    screenGui:Destroy()
    for _, conn in ipairs(wallConnections) do
        pcall(function() conn:Disconnect() end)
    end
end)

registerExistingNPCs()

-- Run functions based on loaded configurations
if wallEnabled then
    createBoxesForAllNPCs()
end

if silentEnabled then
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "Male" and model:FindFirstChild("Root") then
            local root = model.Root
            if not originalSizes[model] then
                originalSizes[model] = root.Size
            end
            root.Size = Vector3.new(10, 10, 10)
            root.Transparency = showHitbox and 0.85 or 1
        end
    end
end

local childConn = workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "Male" then
        task.wait(0.5)
        local head = child:FindFirstChild("Head")
        if head then
            trackedParts[head] = true
            if wallEnabled then
                createBoxForPart(head)
            end
        end
        local root = child:FindFirstChild("Root")
        if root and not silentEnabled then
            root.Size = Vector3.new(1, 1, 1)
        end
    end
end)
table.insert(wallConnections, childConn)

local renderConn = RunService.RenderStepped:Connect(function()
    if isUnloaded then return end

    if wallEnabled then
        for part, _ in pairs(trackedParts) do
            if part and part.Parent and part:FindFirstChild("Wall_Box") then
                local origin = camera.CFrame.Position
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = {localPlayer.Character, part}
                local result = workspace:Raycast(origin, part.Position - origin, rayParams)
                local isVisible = not result or result.Instance:IsDescendantOf(part.Parent)
                part.Wall_Box.Color3 = isVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end

    if silentEnabled then
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "Male" and model:FindFirstChild("Root") then
                local root = model.Root
                if not originalSizes[model] then
                    originalSizes[model] = root.Size
                end
                root.Size = Vector3.new(10, 10, 10)
                root.Transparency = showHitbox and 0.85 or 1
            end
        end
    end
end)
table.insert(wallConnections, renderConn)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or isUnloaded then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)
