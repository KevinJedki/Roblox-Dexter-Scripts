-- Variables
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local pvpButton = Instance.new("TextButton")
local pveButton = Instance.new("TextButton")

-- Create the GUI
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "ModeSelectionGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = screenGui
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)  -- Top-left corner
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(50, 50, 50)

-- Shadow for a more professional look
local shadow = Instance.new("Frame")
shadow.Parent = frame
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, 5, 0, 5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.ZIndex = frame.ZIndex - 1

-- Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

-- PVP Button
pvpButton.Parent = frame
pvpButton.Size = UDim2.new(0, 250, 0, 50)
pvpButton.Position = UDim2.new(0.5, -125, 0.3, -25)
pvpButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
pvpButton.Text = "PVP"
pvpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
pvpButton.Font = Enum.Font.GothamBold
pvpButton.TextSize = 20

local pvpCorner = Instance.new("UICorner")
pvpCorner.CornerRadius = UDim.new(0, 12)
pvpCorner.Parent = pvpButton

-- PVE Button
pveButton.Parent = frame
pveButton.Size = UDim2.new(0, 250, 0, 50)
pveButton.Position = UDim2.new(0.5, -125, 0.7, -25)
pveButton.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
pveButton.Text = "PVE"
pveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
pveButton.Font = Enum.Font.GothamBold
pveButton.TextSize = 20

local pveCorner = Instance.new("UICorner")
pveCorner.CornerRadius = UDim.new(0, 12)
pveCorner.Parent = pveButton

-- Ensure the character is ready
local function getSafeCharacter()
    local character = player.Character
    if not character or not character.Parent then
        character = player.CharacterAdded:Wait()
    end
    return character
end

-- Function to load the script from GitHub
local function loadScript(url)
    local success, response = pcall(function()
        return game:GetService("HttpService"):GetAsync(url)
    end)

    if success then
        local scriptInstance = Instance.new("LocalScript") -- Important: LocalScript
        scriptInstance.Source = response
        scriptInstance.Parent = getSafeCharacter() or player:WaitForChild("PlayerScripts")
    else
        warn("Failed to load the script.")
    end
end

-- Function to handle mode selection
local function onPvpSelected()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HiIxX0Dexter0XxIiH/Roblox-Dexter-Scripts/refs/heads/main/BRM5-PVP.lua"))() -- Change the URL if necessary
    screenGui:Destroy()
end

local function onPveSelected()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HiIxX0Dexter0XxIiH/Roblox-Dexter-Scripts/refs/heads/main/BRM5-PVE.lua"))() -- Change the URL if necessary
    screenGui:Destroy()
end

-- Connect buttons to functions
pvpButton.MouseButton1Click:Connect(onPvpSelected)
pveButton.MouseButton1Click:Connect(onPveSelected)
