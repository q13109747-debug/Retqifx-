local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Logic = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/logic.lua",
    true
))()

Logic:Init()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300, 500)
Main.Position = UDim2.new(0.5, -150, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "AUTO FARM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Main

Title.LayoutOrder = 1

local function Button(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(270, 38)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 15
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = Main

    button.MouseButton1Click:Connect(callback)

    return button
end

local worldButton = Button("World: 1", function()
    Logic.Config.World = Logic.Config.World + 1

    if Logic.Config.World > 3 then
        Logic.Config.World = 1
    end

    worldButton.Text = "World: " .. Logic.Config.World
end)

local farmButton = Button("Auto Farm: OFF", function()
    Logic.Config.AutoFarm = not Logic.Config.AutoFarm

    farmButton.Text =
        "Auto Farm: " .. (Logic.Config.AutoFarm and "ON" or "OFF")
end)

local attackButton = Button("Auto Attack: OFF", function()
    Logic.Config.AutoAttack = not Logic.Config.AutoAttack

    attackButton.Text =
        "Auto Attack: " .. (Logic.Config.AutoAttack and "ON" or "OFF")
end)

local modeButton = Button("Mode: TP", function()
    if Logic.Config.Mode == "TP" then
        Logic:SetMode("Fly")
    else
        Logic:SetMode("TP")
    end

    modeButton.Text = "Mode: " .. Logic.Config.Mode
end)

local speedButton = Button("Speed: 50", function()
    local speed = Logic.Config.Speed + 10

    if speed > 100 then
        speed = 20
    end

    Logic:SetSpeed(speed)
    speedButton.Text = "Speed: " .. Logic.Config.Speed
end)

local runeButton = Button("Auto Runes: OFF", function()
    Logic.Config.AutoRunes = not Logic.Config.AutoRunes

    runeButton.Text =
        "Auto Runes: " .. (Logic.Config.AutoRunes and "ON" or "OFF")
end)

local spawnButton = Button("Spawn Point: OFF", function()
    Logic.Config.SpawnPoint = not Logic.Config.SpawnPoint

    spawnButton.Text =
        "Spawn Point: " .. (Logic.Config.SpawnPoint and "ON" or "OFF")
end)

local espButton = Button("Player ESP: OFF", function()
    Logic.Config.PlayerESP = not Logic.Config.PlayerESP

    espButton.Text =
        "Player ESP: " .. (Logic.Config.PlayerESP and "ON" or "OFF")
end)

for _, runeName in ipairs({
    "Руна Йети",
    "Руна Леденого Пастя",
    "Руна Иллюзиониста"
}) do
    local button = Button(runeName .. ": OFF", function()
        Logic.Config.Runes[runeName] =
            not Logic.Config.Runes[runeName]

        button.Text =
            runeName .. ": " ..
            (Logic.Config.Runes[runeName] and "ON" or "OFF")
    end)
end