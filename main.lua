-- main.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("AdminControl")

if player:GetAttribute("AdminMode") ~= true then
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminAutoFarm"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 500)
frame.Position = UDim2.new(0.5, -150, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "ADMIN AUTO FARM"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = frame

local function makeButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(270, 38)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 15
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.Parent = frame

    button.MouseButton1Click:Connect(callback)

    return button
end

local god = false
local safe = false

local godButton = makeButton("God Mode: OFF", function()
    god = not god

    remote:FireServer("GodMode", god)

    godButton.Text = "God Mode: " .. (god and "ON" or "OFF")
end)

local safeButton = makeButton("Safe Zone: OFF", function()
    safe = not safe

    remote:FireServer("SafeZone", safe)

    safeButton.Text = "Safe Zone: " .. (safe and "ON" or "OFF")
end)

makeButton("Admin Mode: ON", function()
    -- Информация, кнопка намеренно ничего не меняет.
end)