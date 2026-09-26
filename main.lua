--[[
    Blocks Farm V26 | Part A - UI
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

_G.BF = _G.BF or {}
local S = _G.BF

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

S.MobList = S.MobList or {
    "3_1_1","3_1_2","3_1_3","3_1_4",
    "3_2_1","3_2_2","3_2_3","3_2_4",
    "3_3_1","3_3_2","3_3_3","3_3_4",
}

S.LootList = S.LootList or {
    "Rune Fragment Yeti","Rune Fragment Frost Maw",
    "Rune Fragment Illusionist","Все руны",
    "Шлем","Нагрудник","Штаны","Ботинки","Оружие","Щит",
}

S.CFG = S.CFG or {
    SpeedEnabled=false, SpeedValue=40,
    JumpEnabled=false, JumpValue=100, InfJump=false,
    AutoAttack=false, AutoAttackRange=30,
    KillAura=false, KillAuraRange=20, NoCooldown=false,
    FarmEnabled=false, FarmSpeed=100, TPFarm=false,
    FlyToMob=false, FlyToMobSpeed=5,
    AutoPickup=false, SelectedLoot="Все руны",
    PickRunes=true, PickHelmet=true, PickChestplate=true,
    PickLeggings=true, PickBoots=true, PickWeapon=true, PickShield=true,
    MobESP=false, PlayerESP=false, ShowHP=true,
    SelectedEnemy="3_1_1",
    SpawnPoint=nil, AutoTPOnDeath=false,
    TargetEnabled=false, TargetPlayer=nil,
    TargetMode="Bottom", TargetSpeed=50, HelicopterRadius=10,
}

local CFG = S.CFG

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

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
iconTitle.Text = "🐯 Blocks Farm V26"
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
titleText.Text = "🐯 Blocks Farm V26"
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

local function makeSelect(parent, label, options, default, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,32)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55,0,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.45,-10,1,0)
    v.Position = UDim2.new(0.55,0,0,0)
    v.BackgroundTransparency = 1
    v.Text = default or "Выбрать"
    v.TextColor3 = Color3.fromRGB(255,200,0)
    v.Font = Enum.Font.Gotham
    v.TextSize = 11
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = b

    b.MouseButton1Click:Connect(function()
        local picker = Instance.new("Frame")
        picker.Size = UDim2.new(0,260,0,300)
        picker.Position = UDim2.new(0.5,-130,0.5,-150)
        picker.BackgroundColor3 = Color3.fromRGB(30,30,38)
        picker.BorderSizePixel = 0
        picker.Active = true
        picker.Draggable = true
        picker.ZIndex = 100
        picker.Parent = sg
        Instance.new("UICorner", picker).CornerRadius = UDim.new(0,8)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1,0,0,30)
        t.BackgroundColor3 = Color3.fromRGB(255,200,0)
        t.Text = label
        t.TextColor3 = Color3.fromRGB(0,0,0)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.ZIndex = 101
        t.Parent = picker
        Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)

        local cp = Instance.new("TextButton")
        cp.Size = UDim2.new(0,24,0,24)
        cp.Position = UDim2.new(1,-28,0,3)
        cp.BackgroundColor3 = Color3.fromRGB(200,50,50)
        cp.Text = "X"
        cp.TextColor3 = Color3.fromRGB(255,255,255)
        cp.Font = Enum.Font.GothamBold
        cp.TextSize = 12
        cp.ZIndex = 102
        cp.Parent = picker
        Instance.new("UICorner", cp).CornerRadius = UDim.new(0,4)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,-10,1,-40)
        scroll.Position = UDim2.new(0,5,0,35)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.ZIndex = 101
        scroll.Parent = picker

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0,4)
        lay.Parent = scroll
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+10)
        end)

        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1,-5,0,28)
            ob.BackgroundColor3 = Color3.fromRGB(45,45,55)
            ob.Text = opt
            ob.TextColor3 = Color3.fromRGB(220,220,220)
            ob.Font = Enum.Font.Gotham
            ob.TextSize = 11
            ob.ZIndex = 102
            ob.Parent = scroll
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0,4)
            ob.MouseButton1Click:Connect(function()
                v.Text = opt
                callback(opt)
                picker:Destroy()
            end)
        end

        cp.MouseButton1Click:Connect(function() picker:Destroy() end)
    end)
end

-- Всё остальное в Части B