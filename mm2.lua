--[[
    Xs_KakoNINik | MM2 Cheat
    Автор: Xs_KakoNINik
    TG: @Xs_KakoINik
    Часть 1: UI
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

_G.MM2 = _G.MM2 or {}
local S = _G.MM2

S.CFG = S.CFG or {
    SpeedEnabled = false, SpeedValue = 100,
    JumpEnabled = false, JumpValue = 100,
    InfJump = false,
    KillAll = false,
    KillSheriff = false,
    SilentAim = false,
    AutoGrabGun = false,
    FlingAll = false,
    FlingSelected = false,
    AntiFling = false,
    FarmCoins = false,
    PlayerESP = false,
    RoleESP = false,
    HitChance = 100,
    FOV = 120,
}

S.SelectedPlayer = nil

-- ============ UI ============
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

-- Стикер-иконка
local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0, 180, 0, 55)
iconFrame.Position = UDim2.new(0, 20, 0, 100)
iconFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
iconFrame.BorderSizePixel = 0
iconFrame.Active = true
iconFrame.Draggable = true
iconFrame.Parent = sg
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 22)
topBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
topBar.BorderSizePixel = 0
topBar.Parent = iconFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐯 Xs_KakoNINik"
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = topBar

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 30)
subLabel.Position = UDim2.new(0, 0, 0, 22)
subLabel.BackgroundTransparency = 1
subLabel.Text = "От Xs_KakoNINik\ntg@Xs_KakoINik"
subLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 10
subLabel.Parent = iconFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(1, 0, 1, 0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text = ""
iconBtn.Parent = iconFrame

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 340)
main.Position = UDim2.new(0, 220, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🐯 Xs_KakoNINik | MM2 Cheat"
titleText.TextColor3 = Color3.fromRGB(0, 0, 0)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -42)
sidebar.Position = UDim2.new(0, 5, 0, 37)
sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -145, 1, -42)
contentArea.Position = UDim2.new(0, 140, 0, 37)
contentArea.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
contentArea.BorderSizePixel = 0
contentArea.Parent = main
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local pages = {}

local function makePage(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 4
    c.CanvasSize = UDim2.new(0, 0, 0, 0)
    c.Visible = false
    c.Parent = contentArea

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.Parent = c
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        c.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
    end)

    pages[idx] = {button = b, content = c}
    b.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.button.BackgroundColor3 = (i == idx) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(38, 38, 48)
            p.button.TextColor3 = (i == idx) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            p.content.Visible = (i == idx)
        end
    end)
    return c
end

local MainTab = makePage("Main", 1)
local KillTab = makePage("Kill", 2)
local FlingTab = makePage("Fling", 3)
local ESPTab = makePage("ESP", 4)
local MiscTab = makePage("Misc", 5)
pages[1].button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
pages[1].button.TextColor3 = Color3.fromRGB(0, 0, 0)
pages[1].content.Visible = true

local function makeToggle(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -46, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bg.Parent = b
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 14, 0, 14)
    k.Position = UDim2.new(0, 2, 0.5, -7)
    k.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    k.Parent = bg
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        if s then
            bg.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
            k.Position = UDim2.new(1, -16, 0.5, -7)
        else
            bg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            k.Position = UDim2.new(0, 2, 0.5, -7)
        end
        callback(s)
    end)
end

local function makeSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 22)
    l.Position = UDim2.new(0, 10, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = name..": "..default
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bb = Instance.new("Frame")
    bb.Size = UDim2.new(1, -20, 0, 6)
    bb.Position = UDim2.new(0, 10, 0, 34)
    bb.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bb.Parent = f
    Instance.new("UICorner", bb).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X) / bb.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rx)
        bar.Size = UDim2.new(rx, 0, 1, 0)
        l.Text = name..": "..v
        callback(v)
    end
    bb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(input)
        end
    end)
    bb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
end

local function makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = name
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
end

-- Main tab
makeToggle(MainTab, "Enable Speed", function(v) S.CFG.SpeedEnabled = v end)
makeSlider(MainTab, "Speed", 20, 500, 100, function(v) S.CFG.SpeedValue = v end)
makeToggle(MainTab, "Enable Jump", function(v) S.CFG.JumpEnabled = v end)
makeSlider(MainTab, "Jump Power", 50, 500, 100, function(v) S.CFG.JumpValue = v end)
makeToggle(MainTab, "Infinite Jump", function(v) S.CFG.InfJump = v end)
makeToggle(MainTab, "Anti-Fling", function(v) S.CFG.AntiFling = v end)

-- Kill tab
makeToggle(KillTab, "Kill All (Murderer)", function(v) S.CFG.KillAll = v end)
makeToggle(KillTab, "Kill Sheriff (Murderer)", function(v) S.CFG.KillSheriff = v end)
makeToggle(KillTab, "Silent Aim (Sheriff)", function(v) S.CFG.SilentAim = v end)
makeToggle(KillTab, "Auto Grab Gun", function(v) S.CFG.AutoGrabGun = v end)
makeSlider(KillTab, "Hit Chance", 0, 100, 100, function(v) S.CFG.HitChance = v end)
makeSlider(KillTab, "FOV", 10, 500, 120, function(v) S.CFG.FOV = v end)

-- Fling tab
makeToggle(FlingTab, "Fling All", function(v) S.CFG.FlingAll = v end)
makeToggle(FlingTab, "Fling Selected", function(v) S.CFG.FlingSelected = v end)

-- ESP tab
makeToggle(ESPTab, "Player ESP", function(v) S.CFG.PlayerESP = v end)
makeToggle(ESPTab, "Role ESP (Murderer/Sheriff)", function(v) S.CFG.RoleESP = v end)

-- Misc tab
makeToggle(MiscTab, "Auto Farm Coins", function(v) S.CFG.FarmCoins = v end)

-- Клик по иконке → открыть меню
iconBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)
close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

print("[Xs_KakoNINik MM2] Menu loaded")

-- Подгрузка логики
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/mm2.logic.lua", true))()
    end)
    if not ok then
        warn("[MM2] Logic load failed: " .. tostring(err))
    end
end)