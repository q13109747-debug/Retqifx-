--[[
    99 Nights in the Forest | Part 1 - UI
    Автор: moonklice:3
    Вы все лохи:3 от автора moonklice:3
    Писать по скриптам иначе игнор:3 или по рекламе:3
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

_G.N99 = _G.N99 or {}
local S = _G.N99

S.Kids = {"DinoKid", "KoalaKid", "KrakenKid", "SquidKid"}

S.CFG = S.CFG or {
    AutoTreeFarm = false,
    AutoFire = false,
    AutoEat = false,
    AutoStun = false,
    AutoStronghold = false,
    GodMode = false,
    SpeedEnabled = false, SpeedValue = 40,
    InfJump = false,
    KillAura = false,
    DayFarm = false,
    SelectedTask = "",
    SelectedKid = "DinoKid",
    BringStuff = false,
    BringRadius = 100,
}
local CFG = S.CFG

-- Цвета
local BG_DARK = Color3.fromRGB(45, 20, 55)
local BG_PANEL = Color3.fromRGB(55, 25, 70)
local ACCENT = Color3.fromRGB(180, 80, 230)
local TEXT_COLOR = Color3.fromRGB(230, 220, 240)

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

-- Иконка
local icon = Instance.new("Frame")
icon.Size = UDim2.new(0, 220, 0, 55)
icon.Position = UDim2.new(0, 20, 0, 100)
icon.BackgroundColor3 = BG_DARK
icon.BorderSizePixel = 0
icon.Active = true
icon.Parent = sg
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 10)

local iconTop = Instance.new("Frame")
iconTop.Size = UDim2.new(1, 0, 0, 25)
iconTop.BackgroundColor3 = ACCENT
iconTop.BorderSizePixel = 0
iconTop.Parent = icon
Instance.new("UICorner", iconTop).CornerRadius = UDim.new(0, 10)

local iconTitle = Instance.new("TextLabel")
iconTitle.Size = UDim2.new(1, 0, 1, 0)
iconTitle.BackgroundTransparency = 1
iconTitle.Text = "❄️ moonklice:3"
iconTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
iconTitle.Font = Enum.Font.GothamBold
iconTitle.TextSize = 14
iconTitle.Parent = iconTop

local iconSub = Instance.new("TextLabel")
iconSub.Size = UDim2.new(1, 0, 0, 30)
iconSub.Position = UDim2.new(0, 0, 0, 25)
iconSub.BackgroundTransparency = 1
iconSub.Text = "Вы все лохи:3\nПисать по скриптам:3"
iconSub.TextColor3 = Color3.fromRGB(200, 180, 220)
iconSub.Font = Enum.Font.Gotham
iconSub.TextSize = 10
iconSub.Parent = icon

-- Драг иконки
local dragging, dragStart, startPos = false, nil, nil
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = icon.Position
    end
end)
icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        icon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 400)
main.Position = UDim2.new(0.5, -260, 0.5, -200)
main.BackgroundColor3 = BG_DARK
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = BG_DARK
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 40, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Voidware-style | 99 Nights"
titleText.TextColor3 = TEXT_COLOR
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 12
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -44)
sidebar.Position = UDim2.new(0, 5, 0, 37)
sidebar.BackgroundColor3 = BG_PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sidebarScroll = Instance.new("ScrollingFrame")
sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 3
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 3)
sidebarLayout.Parent = sidebarScroll
sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 10)
end)

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -155, 1, -44)
contentArea.Position = UDim2.new(0, 150, 0, 37)
contentArea.BackgroundColor3 = BG_PANEL
contentArea.BorderSizePixel = 0
contentArea.Parent = main
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -10, 0, 20)
footer.Position = UDim2.new(0, 5, 1, -22)
footer.BackgroundTransparency = 1
footer.Text = "Вы все лохи:3 от автора moonklice:3 | Писать по скриптам иначе игнор:3"
footer.TextColor3 = ACCENT
footer.Font = Enum.Font.GothamBold
footer.TextSize = 9
footer.Parent = main

-- Страницы
local pages = {}
local function makePage(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
    b.Text = "  " .. name
    b.TextColor3 = TEXT_COLOR
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = sidebarScroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.CanvasSize = UDim2.new(0, 0, 0, 0)
    c.Visible = false
    c.Parent = contentArea

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 5)
    lay.Parent = c
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        c.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 15)
    end)

    pages[idx] = {button = b, content = c}
    b.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.button.BackgroundColor3 = (i == idx) and ACCENT or Color3.fromRGB(50, 20, 65)
            p.button.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or TEXT_COLOR
            p.content.Visible = (i == idx)
        end
    end)
    return c
end

local InfoTab = makePage("Информация", 1)
local FunTab = makePage("Фан", 2)
local MainTab = makePage("Main", 3)
local AutoTab = makePage("Auto", 4)
local DayFarmTab = makePage("Day Farm", 5)
local StrongholdTab = makePage("Auto Stronghold", 6)
local BringTab = makePage("Bring Stuff", 7)
local TeleportTab = makePage("Телепорт", 8)

pages[3].button.BackgroundColor3 = ACCENT
pages[3].button.TextColor3 = Color3.fromRGB(255, 255, 255)
pages[3].content.Visible = true

S._UI = {sg = sg, main = main, pages = pages}

-- Виджеты
local function makeToggle(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = TEXT_COLOR
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 34, 0, 16)
    bg.Position = UDim2.new(1, -44, 0.5, -8)
    bg.BackgroundColor3 = Color3.fromRGB(70, 40, 85)
    bg.Parent = b
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 12, 0, 12)
    k.Position = UDim2.new(0, 2, 0.5, -6)
    k.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    k.Parent = bg
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        if s then
            bg.BackgroundColor3 = ACCENT
            k.Position = UDim2.new(1, -14, 0.5, -6)
        else
            bg.BackgroundColor3 = Color3.fromRGB(70, 40, 85)
            k.Position = UDim2.new(0, 2, 0.5, -6)
        end
        callback(s)
    end)
end

local function makeSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 48)
    f.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 20)
    l.Position = UDim2.new(0, 10, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = name .. ": " .. default
    l.TextColor3 = TEXT_COLOR
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bb = Instance.new("Frame")
    bb.Size = UDim2.new(1, -20, 0, 6)
    bb.Position = UDim2.new(0, 10, 0, 32)
    bb.BackgroundColor3 = Color3.fromRGB(70, 40, 85)
    bb.Parent = f
    Instance.new("UICorner", bb).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    bar.BackgroundColor3 = ACCENT
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X) / bb.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rx)
        bar.Size = UDim2.new(rx, 0, 1, 0)
        l.Text = name .. ": " .. v
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

local function makeSelect(parent, label, options, default, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = TEXT_COLOR
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.45, -10, 1, 0)
    v.Position = UDim2.new(0.55, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = default
    v.TextColor3 = ACCENT
    v.Font = Enum.Font.Gotham
    v.TextSize = 11
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = b

    b.MouseButton1Click:Connect(function()
        local picker = Instance.new("Frame")
        picker.Size = UDim2.new(0, 220, 0, 240)
        picker.Position = UDim2.new(0.5, -110, 0.5, -120)
        picker.BackgroundColor3 = BG_DARK
        picker.BorderSizePixel = 0
        picker.Active = true
        picker.Draggable = true
        picker.ZIndex = 100
        picker.Parent = sg
        Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 28)
        t.BackgroundColor3 = ACCENT
        t.Text = label
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.ZIndex = 101
        t.Parent = picker
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

        local cp = Instance.new("TextButton")
        cp.Size = UDim2.new(0, 22, 0, 22)
        cp.Position = UDim2.new(1, -26, 0, 3)
        cp.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        cp.Text = "X"
        cp.TextColor3 = Color3.fromRGB(255, 255, 255)
        cp.Font = Enum.Font.GothamBold
        cp.TextSize = 11
        cp.ZIndex = 102
        cp.Parent = picker
        Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 4)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -40)
        scroll.Position = UDim2.new(0, 5, 0, 32)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ZIndex = 101
        scroll.Parent = picker

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 4)
        lay.Parent = scroll
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
        end)

        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, -5, 0, 26)
            ob.BackgroundColor3 = Color3.fromRGB(55, 25, 70)
            ob.Text = opt
            ob.TextColor3 = TEXT_COLOR
            ob.Font = Enum.Font.Gotham
            ob.TextSize = 11
            ob.ZIndex = 102
            ob.Parent = scroll
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
            ob.MouseButton1Click:Connect(function()
                v.Text = opt
                callback(opt)
                picker:Destroy()
            end)
        end

        cp.MouseButton1Click:Connect(function() picker:Destroy() end)
    end)
end

S._UI.makeToggle = makeToggle
S._UI.makeSlider = makeSlider
S._UI.makeSelect = makeSelect
S._UI.tabs = {
    Info = InfoTab, Fun = FunTab, Main = MainTab, Auto = AutoTab,
    DayFarm = DayFarmTab, Stronghold = StrongholdTab,
    Bring = BringTab, Teleport = TeleportTab,
}

-- Информация
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 0, 200)
infoLabel.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
infoLabel.Text = "📋 99 Nights in the Forest\n\n👤 Автор: moonklice:3\n❄️ Вы все лохи:3\n📝 Писать по скриптам иначе игнор:3\n📢 Или по рекламе:3\n\n🎯 Функции:\n• God Mode\n• Auto Tree Farm\n• Auto Fire\n• Auto Eat\n• Child TP\n• Speed\n• Kill Aura"
infoLabel.TextColor3 = TEXT_COLOR
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = InfoTab
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)

-- Фан
local funLabel = Instance.new("TextLabel")
funLabel.Size = UDim2.new(1, -10, 0, 80)
funLabel.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
funLabel.Text = "🎉 Фан-функции\n\nТут будут приколы (потом добавим)"
funLabel.TextColor3 = TEXT_COLOR
funLabel.Font = Enum.Font.Gotham
funLabel.TextSize = 11
funLabel.TextWrapped = true
funLabel.Parent = FunTab
Instance.new("UICorner", funLabel).CornerRadius = UDim.new(0, 6)

-- Main
makeToggle(MainTab, "God Mode", function(v) CFG.GodMode = v end)
makeToggle(MainTab, "Kill Aura", function(v) CFG.KillAura = v end)
makeToggle(MainTab, "Infinite Jump", function(v) CFG.InfJump = v end)
makeToggle(MainTab, "Enable Speed", function(v) CFG.SpeedEnabled = v end)
makeSlider(MainTab, "Speed", 16, 200, 40, function(v) CFG.SpeedValue = v end)

-- Auto
makeToggle(AutoTab, "Auto Tree Farm", function(v) CFG.AutoTreeFarm = v end)
makeToggle(AutoTab, "Auto Fire (Logs)", function(v) CFG.AutoFire = v end)
makeToggle(AutoTab, "Auto Eat", function(v) CFG.AutoEat = v end)
makeToggle(AutoTab, "Auto Stun (Deer)", function(v) CFG.AutoStun = v end)

-- Day Farm
makeToggle(DayFarmTab, "Day Farm", function(v) CFG.DayFarm = v end)
makeSelect(DayFarmTab, "Выбрать таск", {"Task1","Task2","Task3","Task4"}, "Не выбрано", function(o) CFG.SelectedTask = o end)

-- Stronghold
makeToggle(StrongholdTab, "Auto Stronghold", function(v) CFG.AutoStronghold = v end)

-- Bring
makeToggle(BringTab, "Bring Stuff", function(v) CFG.BringStuff = v end)
makeSlider(BringTab, "Bring Radius", 20, 500, 100, function(v) CFG.BringRadius = v end)

-- Teleport
makeSelect(TeleportTab, "Выбрать ребёнка", S.Kids, "DinoKid", function(o) CFG.SelectedKid = o end)
local tpKidBtn = Instance.new("TextButton")
tpKidBtn.Size = UDim2.new(1, -10, 0, 30)
tpKidBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
tpKidBtn.Text = "ТП к ребёнку"
tpKidBtn.TextColor3 = TEXT_COLOR
tpKidBtn.Font = Enum.Font.GothamBold
tpKidBtn.TextSize = 11
tpKidBtn.Parent = TeleportTab
Instance.new("UICorner", tpKidBtn).CornerRadius = UDim.new(0, 6)

local tpCampBtn = Instance.new("TextButton")
tpCampBtn.Size = UDim2.new(1, -10, 0, 30)
tpCampBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 65)
tpCampBtn.Text = "ТП к Костру"
tpCampBtn.TextColor3 = TEXT_COLOR
tpCampBtn.Font = Enum.Font.GothamBold
tpCampBtn.TextSize = 11
tpCampBtn.Parent = TeleportTab
Instance.new("UICorner", tpCampBtn).CornerRadius = UDim.new(0, 6)

S._UI.tpKidBtn = tpKidBtn
S._UI.tpCampBtn = tpCampBtn

-- Открытие меню
local tapStart = nil
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        tapStart = tick()
    end
end)
icon.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and tapStart then
        if tick() - tapStart < 0.3 then
            main.Visible = not main.Visible
        end
        tapStart = nil
    end
end)
close.MouseButton1Click:Connect(function() main.Visible = false end)

print("[99 Nights] UI loaded | moonklice:3")