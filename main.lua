local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Logic = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/logic.lua",
    true
))()

if not Logic:IsAdmin() then
    return
end

Logic:Init()

local Gui = Instance.new("ScreenGui")
Gui.Name = "RetqifxMenu"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(320, 600)
Main.Position = UDim2.new(0.5, -160, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(300, 45)
Title.BackgroundTransparency = 1
Title.Text = "RETQIFX ADMIN"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.LayoutOrder = 1
Title.Parent = Main

local function Button(text, callback)
    local button = Instance.new("TextButton")

    button.Size = UDim2.fromOffset(290, 36)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.Parent = Main

    button.MouseButton1Click:Connect(callback)

    return button
end

local worldButton = Button("World: 1", function()
    local world = Logic.Config.World + 1

    if world > 3 then
        world = 1
    end

    Logic:SetWorld(world)
    worldButton.Text = "World: " .. world
end)

local farmButton = Button("Auto Farm: OFF", function()
    Logic.Config.AutoFarm = not Logic.Config.AutoFarm

    farmButton.Text =
        "Auto Farm: " ..
        (Logic.Config.AutoFarm and "ON" or "OFF")
end)

local attackButton = Button("Auto Attack: OFF", function()
    Logic.Config.AutoAttack = not Logic.Config.AutoAttack

    attackButton.Text =
        "Auto Attack: " ..
        (Logic.Config.AutoAttack and "ON" or "OFF")
end)

local equipButton = Button("Auto Equip: OFF", function()
    Logic.Config.AutoEquip = not Logic.Config.AutoEquip

    equipButton.Text =
        "Auto Equip: " ..
        (Logic.Config.AutoEquip and "ON" or "OFF")
end)

local modeButton = Button("Mode: TP", function()
    local mode =
        Logic.Config.Mode == "TP"
        and "Fly"
        or "TP"

    Logic:SetMode(mode)
    modeButton.Text = "Mode: " .. mode
end)

local speedButton = Button("Speed: 50", function()
    local speed = Logic.Config.Speed + 10

    if speed > 100 then
        speed = 20
    end

    Logic:SetSpeed(speed)
    speedButton.Text = "Speed: " .. speed
end)

local runeButton = Button("Auto Runes: OFF", function()
    Logic.Config.AutoRunes = not Logic.Config.AutoRunes

    runeButton.Text =
        "Auto Runes: " ..
        (Logic.Config.AutoRunes and "ON" or "OFF")
end)

local godButton = Button("God Mode: OFF", function()
    local enabled = not Logic.Config.GodMode

    Logic:SetGodMode(enabled)

    godButton.Text =
        "God Mode: " ..
        (enabled and "ON" or "OFF")
end)

local safeButton = Button("Safe Zone: OFF", function()
    local enabled = not Logic.Config.SafeZone

    Logic:SetSafeZone(enabled)

    safeButton.Text =
        "Safe Zone: " ..
        (enabled and "ON" or "OFF")
end)

for _, runeName in ipairs({
    "Руна Йети",
    "Руна Леденого Пастя",
    "Руна Иллюзиониста"
}) do
    Button(runeName .. ": OFF", function(button)
        Logic.Config.Runes[runeName] =
            not Logic.Config.Runes[runeName]
    end)
end