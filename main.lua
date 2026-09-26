--[[
    Blocks Farm V25 | Main UI (420 lines)
    Автор: Xs_KakoNINik | TG: @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

_G.BF = _G.BF or {}
local S = _G.BF

-- Форматтер чисел
local function formatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n) end
    if n < 1000 then return tostring(math.floor(n)) end
    local suf = {
        {1e18,"Qi"},{1e15,"Q"},{1e12,"T"},
        {1e9,"B"},{1e6,"M"},{1e3,"K"}
    }
    for _, p in ipairs(suf) do
        if n >= p[1] then
            local sh = n / p[1]
            if sh >= 100 then return string.format("%d%s", math.floor(sh), p[2])
            elseif sh >= 10 then return string.format("%.1f%s", sh, p[2])
            else return string.format("%.2f%s", sh, p[2]) end
        end
    end
    return tostring(math.floor(n))
end
S.formatNumber = formatNumber

-- Мобы
S.Worlds = S.Worlds or {
    ["Мир 3 - Локация 1"] = {
        ["3_1_1"]="Goat",["3_1_2"]="PolarBear",
        ["3_1_3"]="SnowGolem",["3_1_4"]="Starry",
    },
    ["Мир 3 - Локация 2"] = {
        ["3_2_1"]="Fox",["3_2_2"]="SnowLeopard",
        ["3_2_3"]="Tusklin",["3_2_4"]="FrostStalker",
    },
    ["Мир 3 - Локация 3"] = {
        ["3_3_1"]="Frog",["3_3_2"]="Crocodile",
        ["3_3_3"]="SwampSkeleton",["3_3_4"]="Witch",
    },
}

S.SelectedMobs = S.SelectedMobs or {}
for _, loc in pairs(S.Worlds) do
    for id in pairs(loc) do S.SelectedMobs[id] = true end
end

-- Конфиг
S.CFG = S.CFG or {
    SpeedEnabled=false, SpeedValue=40,
    JumpEnabled=false, JumpValue=100,
    InfJump=false,
    AutoAttack=false, AutoAttackRange=30,
    KillAura=false, KillAuraRange=20,
    NoCooldown=false,
    FarmEnabled=false, FarmSpeed=100,
    TPFarm=false, FlyToMob=false, FlyToMobSpeed=5,
    AutoPickup=false,
    PickRunes=true, PickHelmet=true, PickChestplate=true,
    PickLeggings=true, PickBoots=true, PickWeapon=true, PickShield=true,
    MobESP=false, PlayerESP=false, ShowHP=true,
    SpawnPoint=nil, AutoTPOnDeath=false,
    TargetEnabled=false, TargetPlayer=nil,
    TargetMode="Bottom", TargetSpeed=50, HelicopterRadius=10,
}

local CFG = S.CFG

-- UI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

-- Иконка
local icon = Instance.new("Frame")
icon.Size = UDim2.new(0,180,0,50)
icon.Position = UDim2.new(0,20,0,100)
icon.BackgroundColor3 = Color3.fromRGB(25,25,32)
icon.BorderSizePixel = 0
icon.Active = true
icon.Parent = sg
Instance.new("UICorner", icon).CornerRadius = UDim.new(0,10)

local iconTop = Instance.new("Frame")
iconTop.Size = UDim2.new(1,0,0,22)
iconTop.BackgroundColor3 = Color3.fromRGB(255,200,0)
iconTop.BorderSizePixel = 0
iconTop.Parent = icon
Instance.new("UICorner", iconTop).CornerRadius = UDim.new(0,10)

local iconTitle = Instance.new("TextLabel")
iconTitle.Size = UDim2.new(1,0,1,0)
iconTitle.BackgroundTransparency = 1
iconTitle.Text = "🐯 Blocks Farm V25"
iconTitle.TextColor3 = Color3.fromRGB(0,0,0)
iconTitle.Font = Enum.Font.GothamBold
iconTitle.TextSize = 13
iconTitle.Parent = iconTop

local iconSub = Instance.new("TextLabel")
iconSub.Size = UDim2.new(1,0,0,28)
iconSub.Position = UDim2.new(0,0,0,22)
iconSub.BackgroundTransparency = 1
iconSub.Text = "От Xs_KakoNINik\ntg@Xs_KakoINik"
iconSub.TextColor3 = Color3.fromRGB(180,180,180)
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

-- Окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0,440,0,420)
main.Position = UDim2.new(0,200,0,80)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,32)
titleBar.BackgroundColor3 = Color3.fromRGB(255,200,0)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1,-60,1,0)
titleText.Position = UDim2.new(0,10,0,0)
titleText.BackgroundTransparency = 1
titleText.Text = "🐯 Blocks Farm V25"
titleText.TextColor3 = Color3.fromRGB(0,0,0)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 12
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,26,0,26)
close.Position = UDim2.new(1,-30,0,3)
close.BackgroundColor3 = Color3.fromRGB(200,50,50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,120,1,-72)
sidebar.Position = UDim2.new(0,5,0,37)
sidebar.BackgroundColor3 = Color3.fromRGB(28,28,35)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,8)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0,4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1,-135,1,-72)
contentArea.Position = UDim2.new(0,130,0,37)
contentArea.BackgroundColor3 = Color3.fromRGB(28,28,35)
contentArea.BorderSizePixel = 0
contentArea.Parent = main
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0,8)

local footer = Instance.new("Frame")
footer.Size = UDim2.new(1,-10,0,28)
footer.Position = UDim2.new(0,5,1,-32)
footer.BackgroundColor3 = Color3.fromRGB(28,28,35)
footer.BorderSizePixel = 0
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0,8)

local footerText = Instance.new("TextLabel")
footerText.Size = UDim2.new(1,0,1,0)
footerText.BackgroundTransparency = 1
footerText.Text = "Автор: @Xs_KakoNINik  |  TG: @Xs_KakoINik"
footerText.TextColor3 = Color3.fromRGB(255,200,0)
footerText.Font = Enum.Font.GothamBold
footerText.TextSize = 10
footerText.Parent = footer

local pages = {}
local function makePage(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,30)
    b.BackgroundColor3 = Color3.fromRGB(38,38,48)
    b.Text = "  "..name
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1,0,1,0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 4
    c.CanvasSize = UDim2.new(0,0,0,0)
    c.Visible = false
    c.Parent = contentArea
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6)
    lay.Parent = c
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        c.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+20)
    end)
    pages[idx] = {button=b, content=c}
    b.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.button.BackgroundColor3 = (i==idx) and Color3.fromRGB(255,200,0) or Color3.fromRGB(38,38,48)
            p.button.TextColor3 = (i==idx) and Color3.fromRGB(0,0,0) or Color3.fromRGB(200,200,200)
            p.content.Visible = (i==idx)
        end
    end)
    return c
end

local MainTab = makePage("Main",1)
local MovementTab = makePage("Movement",2)
local ESPTab = makePage("ESP",3)
local TargetTab = makePage("Target",4)
local PickupTab = makePage("Pickup",5)
local MiscTab = makePage("Settings",6)
pages[1].button.BackgroundColor3 = Color3.fromRGB(255,200,0)
pages[1].button.TextColor3 = Color3.fromRGB(0,0,0)
pages[1].content.Visible = true

local function makeToggle(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,32)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-60,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0,36,0,18)
    bg.Position = UDim2.new(1,-46,0.5,-9)
    bg.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bg.Parent = b
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    local k = Instance.new("Frame")
    k.Size = UDim2.new(0,14,0,14)
    k.Position = UDim2.new(0,2,0.5,-7)
    k.BackgroundColor3 = Color3.fromRGB(200,200,200)
    k.Parent = bg
    Instance.new("UICorner", k).CornerRadius = UDim.new(1,0)
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        if s then
            bg.BackgroundColor3 = Color3.fromRGB(0,200,120)
            k.Position = UDim2.new(1,-16,0.5,-7)
        else
            bg.BackgroundColor3 = Color3.fromRGB(60,60,70)
            k.Position = UDim2.new(0,2,0.5,-7)
        end
        callback(s)
    end)
end

local function makeSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,50)
    f.BackgroundColor3 = Color3.fromRGB(40,40,50)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-20,0,22)
    l.Position = UDim2.new(0,10,0,4)
    l.BackgroundTransparency = 1
    l.Text = name..": "..default
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local bb = Instance.new("Frame")
    bb.Size = UDim2.new(1,-20,0,6)
    bb.Position = UDim2.new(0,10,0,34)
    bb.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bb.Parent = f
    Instance.new("UICorner", bb).CornerRadius = UDim.new(1,0)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((default-min)/(max-min),0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(255,200,0)
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X) / bb.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rx)
        bar.Size = UDim2.new(rx,0,1,0)
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

-- MAIN TAB
makeToggle(MainTab, "Auto Attack", function(v) CFG.AutoAttack = v end)
makeSlider(MainTab, "Attack Range", 10, 100, 30, function(v) CFG.AutoAttackRange = v end)
makeToggle(MainTab, "Kill Aura", function(v) CFG.KillAura = v end)
makeSlider(MainTab, "Kill Aura Range", 10, 100, 20, function(v) CFG.KillAuraRange = v end)
makeToggle(MainTab, "No Cooldown", function(v) CFG.NoCooldown = v end)
makeToggle(MainTab, "Auto Farm", function(v) CFG.FarmEnabled = v end)
makeToggle(MainTab, "TP Auto Farm", function(v) CFG.TPFarm = v end)
makeToggle(MainTab, "Fly to Mob", function(v) CFG.FlyToMob = v end)
makeSlider(MainTab, "Fly Speed", 1, 20, 5, function(v) CFG.FlyToMobSpeed = v end)
makeSlider(MainTab, "Farm Speed", 40, 150, 100, function(v) CFG.FarmSpeed = v end)

-- MOVEMENT TAB
makeToggle(MovementTab, "Enable Speed", function(v) CFG.SpeedEnabled = v end)
makeSlider(MovementTab, "Speed (40-50 safe)", 40, 300, 40, function(v) CFG.SpeedValue = v end)
makeToggle(MovementTab, "Enable Jump", function(v) CFG.JumpEnabled = v end)
makeSlider(MovementTab, "Jump Power", 50, 500, 100, function(v) CFG.JumpValue = v end)
makeToggle(MovementTab, "Infinite Jump", function(v) CFG.InfJump = v end)

-- ESP TAB
makeToggle(ESPTab, "Mob ESP", function(v) CFG.MobESP = v end)
makeToggle(ESPTab, "Player ESP", function(v) CFG.PlayerESP = v end)
makeToggle(ESPTab, "Show HP", function(v) CFG.ShowHP = v end)

-- Список мобов
local mobListFrame = Instance.new("Frame")
mobListFrame.Size = UDim2.new(1,-10,0,280)
mobListFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
mobListFrame.Parent = ESPTab
Instance.new("UICorner", mobListFrame).CornerRadius = UDim.new(0,6)
local mobTitle = Instance.new("TextLabel")
mobTitle.Size = UDim2.new(1,-20,0,20)
mobTitle.Position = UDim2.new(0,10,0,4)
mobTitle.BackgroundTransparency = 1
mobTitle.Text = "Мобы для фарма:"
mobTitle.TextColor3 = Color3.fromRGB(255,200,0)
mobTitle.Font = Enum.Font.GothamBold
mobTitle.TextSize = 11
mobTitle.TextXAlignment = Enum.TextXAlignment.Left
mobTitle.Parent = mobListFrame
local mobList = Instance.new("ScrollingFrame")
mobList.Size = UDim2.new(1,-20,1,-30)
mobList.Position = UDim2.new(0,10,0,26)
mobList.BackgroundTransparency = 1
mobList.BorderSizePixel = 0
mobList.ScrollBarThickness = 3
mobList.CanvasSize = UDim2.new(0,0,0,0)
mobList.Parent = mobListFrame
local mobLayout = Instance.new("UIListLayout")
mobLayout.Padding = UDim.new(0,3)
mobLayout.Parent = mobList
mobLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mobList.CanvasSize = UDim2.new(0,0,0,mobLayout.AbsoluteContentSize.Y+10)
end)

for locName, loc in pairs(S.Worlds) do
    local locTitle = Instance.new("TextLabel")
    locTitle.Size = UDim2.new(1,-5,0,20)
    locTitle.BackgroundTransparency = 1
    locTitle.Text = "  "..locName
    locTitle.TextColor3 = Color3.fromRGB(100,200,255)
    locTitle.Font = Enum.Font.GothamBold
    locTitle.TextSize = 10
    locTitle.TextXAlignment = Enum.TextXAlignment.Left
    locTitle.Parent = mobList
    for id, name in pairs(loc) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1,-5,0,24)
        row.BackgroundColor3 = Color3.fromRGB(55,55,65)
        row.Text = ""
        row.AutoButtonColor = false
        row.Parent = mobList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,4)
        local rowLbl = Instance.new("TextLabel")
        rowLbl.Size = UDim2.new(1,-50,1,0)
        rowLbl.Position = UDim2.new(0,8,0,0)
        rowLbl.BackgroundTransparency = 1
        rowLbl.Text = id.." ("..name..")"
        rowLbl.TextColor3 = Color3.fromRGB(220,220,220)
        rowLbl.Font = Enum.Font.Gotham
        rowLbl.TextSize = 10
        rowLbl.TextXAlignment = Enum.TextXAlignment.Left
        rowLbl.Parent = row
        local tg = Instance.new("Frame")
        tg.Size = UDim2.new(0,28,0,14)
        tg.Position = UDim2.new(1,-36,0.5,-7)
        tg.BackgroundColor3 = Color3.fromRGB(0,200,120)
        tg.Parent = row
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1,0)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0,10,0,10)
        dot.Position = UDim2.new(1,-12,0.5,-5)
        dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
        dot.Parent = tg
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        row.MouseButton1Click:Connect(function()
            S.SelectedMobs[id] = not S.SelectedMobs[id]
            if S.SelectedMobs[id] then
                tg.BackgroundColor3 = Color3.fromRGB(0,200,120)
                dot.Position = UDim2.new(1,-12,0.5,-5)
            else
                tg.BackgroundColor3 = Color3.fromRGB(60,60,70)
                dot.Position = UDim2.new(0,2,0.5,-5)
            end
        end)
    end
end

-- TARGET TAB
makeToggle(TargetTab, "Target Tool", function(v) CFG.TargetEnabled = v end)
makeSlider(TargetTab, "Heli Speed", 10, 200, 50, function(v) CFG.TargetSpeed = v end)
makeSlider(TargetTab, "Heli Radius", 5, 50, 10, function(v) CFG.HelicopterRadius = v end)

-- PICKUP TAB
makeToggle(PickupTab, "Auto Pickup", function(v) CFG.AutoPickup = v end)
makeToggle(PickupTab, "Pick Runes", function(v) CFG.PickRunes = v end)
makeToggle(PickupTab, "Pick Helmet", function(v) CFG.PickHelmet = v end)
makeToggle(PickupTab, "Pick Chestplate", function(v) CFG.PickChestplate = v end)
makeToggle(PickupTab, "Pick Leggings", function(v) CFG.PickLeggings = v end)
makeToggle(PickupTab, "Pick Boots", function(v) CFG.PickBoots = v end)
makeToggle(PickupTab, "Pick Weapon", function(v) CFG.PickWeapon = v end)
makeToggle(PickupTab, "Pick Shield", function(v) CFG.PickShield = v end)

-- SETTINGS TAB
makeToggle(MiscTab, "Auto TP on Death", function(v) CFG.AutoTPOnDeath = v end)
local saveSpawnBtn = Instance.new("TextButton")
saveSpawnBtn.Size = UDim2.new(1,-10,0,32)
saveSpawnBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
saveSpawnBtn.Text = "Сохранить Spawn Point"
saveSpawnBtn.TextColor3 = Color3.fromRGB(220,220,220)
saveSpawnBtn.Font = Enum.Font.Gotham
saveSpawnBtn.TextSize = 11
saveSpawnBtn.Parent = MiscTab
Instance.new("UICorner", saveSpawnBtn).CornerRadius = UDim.new(0,6)
saveSpawnBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        CFG.SpawnPoint = char.HumanoidRootPart.CFrame
        saveSpawnBtn.Text = "✅ Spawn сохранён!"
        task.wait(1.5)
        saveSpawnBtn.Text = "Сохранить Spawn Point"
    end
end)

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

print("[Blocks Farm V25] UI loaded")

-- Подгрузка логики
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/part2.lua", true))()
    end)
    if not ok then warn("[Part 2] Load failed: " .. tostring(err)) end
end)