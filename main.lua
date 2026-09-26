--[[
    Blocks Farm V18 | Part 1 - MENU
    + 3 мира + Fly точнее + Auto Pickup оптимизирован
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

_G.BF = _G.BF or {}
local S = _G.BF

S.CFG = S.CFG or {
    SpeedEnabled = false, SpeedValue = 100,
    JumpEnabled = false, JumpValue = 100,
    InfJump = false,
    FarmEnabled = false, FarmMode = "Fly", FarmSpeed = 100,
    MobESP = false, PlayerESP = false,
    NoCooldown = false,
    AutoAttack = false, AutoAttackRange = 20,
    KillAura = false, KillAuraRange = 30,
    AutoPickup = false,
    PickRunes = true, PickHelmet = true, PickChestplate = true,
    PickLeggings = true, PickBoots = true, PickWeapon = true, PickShield = true,
}

S.Worlds = {
    ["World 1"] = {
        ["Loc 1"] = {"1_1_1", "1_1_2", "1_1_3", "1_1_4"},
        ["Loc 2"] = {"1_2_1", "1_2_2", "1_2_3", "1_2_4"},
        ["Loc 3"] = {"1_3_1", "1_3_2", "1_3_3", "1_3_4"},
        ["Loc 4"] = {"1_4_1", "1_4_2", "1_4_3", "1_4_4"},
    },
    ["World 2"] = {
        ["Loc 1"] = {"2_1_1", "2_1_2", "2_1_3", "2_1_4"},
        ["Loc 2"] = {"2_2_1", "2_2_2", "2_2_3", "2_2_4"},
        ["Loc 3"] = {"2_3_1", "2_3_2", "2_3_3", "2_3_4"},
        ["Loc 4"] = {"2_4_1", "2_4_2", "2_4_3", "2_4_4"},
    },
    ["World 3"] = {
        ["Loc 1"] = {"3_1_1", "3_1_2", "3_1_3", "3_1_4"},
        ["Loc 2"] = {"3_2_1", "3_2_2", "3_2_3", "3_2_4"},
        ["Loc 3"] = {"3_3_1", "3_3_2", "3_3_3", "3_3_4"},
    },
}

S.SelectedWorld = "World 3"
S.SelectedLocation = "Loc 1"
S.SelectedMobs = {}

local function formatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n) end
    if n < 0 then return "-"..formatNumber(-n) end
    if n < 1000 then return tostring(math.floor(n)) end
    local suf = {{1e18,"Qa"},{1e15,"T"},{1e12,"B"},{1e9,"M"},{1e6,"K"}}
    for _,p in ipairs(suf) do
        if n >= p[1] then
            local sh = n/p[1]
            if sh >= 100 then return string.format("%d%s",math.floor(sh),p[2])
            elseif sh >= 10 then return string.format("%.1f%s",sh,p[2])
            else return string.format("%.2f%s",sh,p[2]) end
        end
    end
    return tostring(math.floor(n))
end
S.formatNumber = formatNumber

-- UI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0,20,0,100)
icon.BackgroundColor3 = Color3.fromRGB(0,200,150)
icon.Text = "BF"
icon.TextColor3 = Color3.fromRGB(255,255,255)
icon.Font = Enum.Font.GothamBold
icon.TextSize = 18
icon.Parent = sg
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

local dragging, dragStart, startPos = false, nil, nil
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = icon.Position
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
main.Size = UDim2.new(0,400,0,340)
main.Position = UDim2.new(0,100,0,100)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(15,15,20)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Blocks Farm V18"
title.TextColor3 = Color3.fromRGB(0,255,200)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,26,0,26)
close.Position = UDim2.new(1,-30,0,2)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(0,255,200)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = titleBar

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,120,1,-30)
sidebar.Position = UDim2.new(0,0,0,30)
sidebar.BackgroundColor3 = Color3.fromRGB(25,25,32)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,10)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0,4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1,-130,1,-40)
contentArea.Position = UDim2.new(0,125,0,35)
contentArea.BackgroundColor3 = Color3.fromRGB(25,25,32)
contentArea.BorderSizePixel = 0
contentArea.Parent = main
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0,8)

local pages = {}

local function makePage(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,34)
    b.BackgroundColor3 = Color3.fromRGB(35,35,45)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
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
    pages[idx] = {button = b, content = c}
    b.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.button.BackgroundColor3 = (i==idx) and Color3.fromRGB(0,150,110) or Color3.fromRGB(35,35,45)
            p.button.TextColor3 = (i==idx) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
            p.content.Visible = (i==idx)
        end
    end)
    return c
end

local MainTab = makePage("Main",1)
local FarmTab = makePage("Farm",2)
local ESPTab = makePage("ESP",3)
local MiscTab = makePage("Misc",4)
local PickupTab = makePage("Pickup",5)
pages[1].button.BackgroundColor3 = Color3.fromRGB(0,150,110)
pages[1].button.TextColor3 = Color3.fromRGB(255,255,255)
pages[1].content.Visible = true

local function makeToggle(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,34)
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
    l.TextSize = 12
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
    local l = Instance.new("TextButton")
    l.Size = UDim2.new(1,-90,0,22)
    l.Position = UDim2.new(0,10,0,4)
    l.BackgroundTransparency = 1
    l.Text = name..": "..default
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0,70,0,22)
    inputBox.Position = UDim2.new(1,-80,0,4)
    inputBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
    inputBox.TextColor3 = Color3.fromRGB(0,200,150)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = 12
    inputBox.Text = tostring(default)
    inputBox.Visible = false
    inputBox.Parent = f
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,4)
    local bb = Instance.new("Frame")
    bb.Size = UDim2.new(1,-20,0,6)
    bb.Position = UDim2.new(0,10,0,34)
    bb.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bb.Parent = f
    Instance.new("UICorner", bb).CornerRadius = UDim.new(1,0)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((default-min)/(max-min),0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(0,200,150)
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    l.MouseButton1Click:Connect(function()
        inputBox.Visible = true
        inputBox:CaptureFocus()
    end)
    inputBox.FocusLost:Connect(function()
        local v = tonumber(inputBox.Text)
        if v then
            v = math.clamp(v, min, max)
            v = math.floor(v)
            inputBox.Text = tostring(v)
            l.Text = name..": "..v
            bar.Size = UDim2.new((v-min)/(max-min),0,1,0)
            callback(v)
        else
            inputBox.Text = tostring(default)
        end
        inputBox.Visible = false
    end)
    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X)/bb.AbsoluteSize.X,0,1)
        local v = math.floor(min+(max-min)*rx)
        bar.Size = UDim2.new(rx,0,1,0)
        l.Text = name..": "..v
        inputBox.Text = tostring(v)
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

local function makeDropdown(parent, name, options, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,34)
    f.BackgroundColor3 = Color3.fromRGB(40,40,50)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-100,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0,100,1,0)
    vl.Position = UDim2.new(1,-105,0,0)
    vl.BackgroundTransparency = 1
    vl.Text = default.." v"
    vl.TextColor3 = Color3.fromRGB(0,200,150)
    vl.Font = Enum.Font.Gotham
    vl.TextSize = 11
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f
    local open = false
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(1,0,0,#options*28)
    cont.Position = UDim2.new(0,0,1,4)
    cont.BackgroundColor3 = Color3.fromRGB(30,30,38)
    cont.Visible = false
    cont.ZIndex = 5
    cont.Parent = f
    Instance.new("UICorner", cont).CornerRadius = UDim.new(0,6)
    local ll = Instance.new("UIListLayout")
    ll.Parent = cont
    for _,opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,28)
        ob.BackgroundColor3 = Color3.fromRGB(30,30,38)
        ob.Text = opt
        ob.TextColor3 = Color3.fromRGB(220,220,220)
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
        ob.ZIndex = 6
        ob.Parent = cont
        ob.MouseButton1Click:Connect(function()
            vl.Text = opt.." v"
            cont.Visible = false
            open = false
            callback(opt)
        end)
    end
    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            open = not open
            cont.Visible = open
        end
    end)
end

local function makeCheckbox(parent, name, id)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,28)
    b.BackgroundColor3 = Color3.fromRGB(35,35,45)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0,18,0,18)
    box.Position = UDim2.new(0,6,0.5,-9)
    box.BackgroundColor3 = Color3.fromRGB(0,200,120)
    box.Parent = b
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1,0,1,0)
    check.BackgroundTransparency = 1
    check.Text = "v"
    check.TextColor3 = Color3.fromRGB(255,255,255)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 13
    check.Parent = box
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-40,1,0)
    l.Position = UDim2.new(0,30,0,0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b
    local state = true
    S.SelectedMobs[id] = true
    b.MouseButton1Click:Connect(function()
        state = not state
        if state then
            box.BackgroundColor3 = Color3.fromRGB(0,200,120)
            check.Text = "v"
            S.SelectedMobs[id] = true
        else
            box.BackgroundColor3 = Color3.fromRGB(60,60,70)
            check.Text = ""
            S.SelectedMobs[id] = nil
        end
    end)
end

-- Content
makeToggle(MainTab, "Enable Speed", function(v) S.CFG.SpeedEnabled = v end)
makeSlider(MainTab, "Speed", 16, 500, 100, function(v) S.CFG.SpeedValue = v end)
makeToggle(MainTab, "Enable Jump", function(v) S.CFG.JumpEnabled = v end)
makeSlider(MainTab, "Jump Power", 50, 500, 100, function(v) S.CFG.JumpValue = v end)
makeToggle(MainTab, "Infinite Jump", function(v) S.CFG.InfJump = v end)
makeToggle(MainTab, "No Cooldown", function(v) S.CFG.NoCooldown = v end)

makeToggle(FarmTab, "Auto Farm", function(v) S.CFG.FarmEnabled = v end)
makeDropdown(FarmTab, "Farm Mode", {"Fly", "TP"}, "Fly", function(v) S.CFG.FarmMode = v end)
makeSlider(FarmTab, "Farm Speed", 30, 500, 100, function(v) S.CFG.FarmSpeed = v end)

makeDropdown(FarmTab, "World", {"World 1", "World 2", "World 3"}, "World 3", function(v)
    S.SelectedWorld = v
    -- Обновить локации
    local locs = {}
    for loc, _ in pairs(S.Worlds[v]) do table.insert(locs, loc) end
    table.sort(locs)
    -- Очистить старые чекбоксы
    for _, child in ipairs(FarmTab:GetChildren()) do
        if child:IsA("TextButton") and child:FindFirstChild("TextLabel") then
            local isCb = false
            for _, c in ipairs(child:GetChildren()) do
                if c:IsA("TextLabel") and c.Text:find("%(") then isCb = true end
            end
            if isCb then child:Destroy() end
        end
    end
    for k in pairs(S.SelectedMobs) do S.SelectedMobs[k] = nil end
    for _, mob in ipairs(S.Worlds[v]["Loc 1"] or {}) do
        makeCheckbox(FarmTab, mob, mob)
    end
    S.SelectedLocation = "Loc 1"
end)

makeDropdown(FarmTab, "Location", {"Loc 1", "Loc 2", "Loc 3", "Loc 4"}, "Loc 1", function(v)
    S.SelectedLocation = v
    for _, child in ipairs(FarmTab:GetChildren()) do
        if child:IsA("TextButton") and child:FindFirstChild("TextLabel") then
            local isCb = false
            for _, c in ipairs(child:GetChildren()) do
                if c:IsA("TextLabel") and c.Text:find("%(") then isCb = true end
            end
            if isCb then child:Destroy() end
        end
    end
    for k in pairs(S.SelectedMobs) do S.SelectedMobs[k] = nil end
    for _, mob in ipairs(S.Worlds[S.SelectedWorld][v] or {}) do
        makeCheckbox(FarmTab, mob, mob)
    end
end)

for _, mob in ipairs(S.Worlds["World 3"]["Loc 1"]) do
    makeCheckbox(FarmTab, mob, mob)
end

makeToggle(ESPTab, "Mob ESP", function(v) S.CFG.MobESP = v end)
makeToggle(ESPTab, "Player ESP (HP/Lvl/Rb)", function(v) S.CFG.PlayerESP = v end)

makeToggle(MiscTab, "Auto Attack (mobs+players)", function(v) S.CFG.AutoAttack = v end)
makeSlider(MiscTab, "Auto Attack Range", 5, 50, 20, function(v) S.CFG.AutoAttackRange = v end)
makeToggle(MiscTab, "Kill Aura", function(v) S.CFG.KillAura = v end)
makeSlider(MiscTab, "Kill Aura Range", 5, 100, 30, function(v) S.CFG.KillAuraRange = v end)

makeToggle(PickupTab, "Auto Pickup", function(v) S.CFG.AutoPickup = v end)
makeToggle(PickupTab, "Pick Runes", function(v) S.CFG.PickRunes = v end)
makeToggle(PickupTab, "Pick Helmet", function(v) S.CFG.PickHelmet = v end)
makeToggle(PickupTab, "Pick Chestplate", function(v) S.CFG.PickChestplate = v end)
makeToggle(PickupTab, "Pick Leggings", function(v) S.CFG.PickLeggings = v end)
makeToggle(PickupTab, "Pick Boots", function(v) S.CFG.PickBoots = v end)
makeToggle(PickupTab, "Pick Weapon", function(v) S.CFG.PickWeapon = v end)
makeToggle(PickupTab, "Pick Shield", function(v) S.CFG.PickShield = v end)

icon.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
close.MouseButton1Click:Connect(function() main.Visible = false end)

print("[Part 1 v18] Menu loaded")
loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/logic.lua", true))()