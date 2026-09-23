--[[
    Blocks Farm V13 | v2
    Fixes: formatNumber ESP, God Mode, Tabs Menu, Location Select
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local Suffixes = {
    {1e33,"Dc"},{1e30,"No"},{1e27,"Oc"},{1e24,"Sp"},{1e21,"Sx"},
    {1e18,"Qa"},{1e15,"T"},{1e12,"B"},{1e9,"M"},{1e6,"K"},
}
local function formatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n) end
    if n < 0 then return "-"..formatNumber(-n) end
    if n < 1000 then return tostring(math.floor(n)) end
    for _,p in ipairs(Suffixes) do
        if n >= p[1] then
            local sh = n/p[1]
            if sh >= 100 then return string.format("%d%s",math.floor(sh),p[2])
            elseif sh >= 10 then return string.format("%.1f%s",sh,p[2])
            else return string.format("%.2f%s",sh,p[2]) end
        end
    end
    return tostring(math.floor(n))
end

local CFG = {
    GodMode = false,
    SpeedEnabled = false, SpeedValue = 100,
    AttackEnabled = false,
    FarmEnabled = false, FarmMode = "Walk", FarmSpeed = 100,
    SelectedLocation = "Location 1", SelectedMob = "All",
    SpawnPoint = nil,
    PlayerESP = false, MobESP = false,
}

local LocationData = {
    ["Location 1"] = {"Goat","Polar Bear","Snow Golem","Stary"},
    ["Location 2"] = {"Fox","Snow Leopard","Tuskin","Frost Stalker"},
    ["Location 3"] = {"Frog","Crocodile","Swamp Skeleton","Witch"},
}

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

local main = Instance.new("Frame")
main.Size = UDim2.new(0,320,0,500)
main.Position = UDim2.new(0,20,0,100)
main.BackgroundColor3 = Color3.fromRGB(25,25,32)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,36)
title.BackgroundColor3 = Color3.fromRGB(35,35,45)
title.Text = "Blocks Farm V13"
title.TextColor3 = Color3.fromRGB(0,255,200)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0,10)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,3)
close.BackgroundColor3 = Color3.fromRGB(200,50,50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,-20,0,32)
tabBar.Position = UDim2.new(0,10,0,44)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabs = {}
local contents = {}

local function makeTab(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25,-3,1,0)
    b.Position = UDim2.new((idx-1)*0.25,0,0,0)
    b.BackgroundColor3 = Color3.fromRGB(45,45,55)
    b.Text = name
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Parent = tabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1,-20,1,-100)
    c.Position = UDim2.new(0,10,0,84)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 4
    c.ScrollBarImageColor3 = Color3.fromRGB(0,200,150)
    c.CanvasSize = UDim2.new(0,0,0,0)
    c.Visible = false
    c.Parent = main

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = c
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        c.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+20)
    end)

    tabs[idx] = b
    contents[idx] = c

    b.MouseButton1Click:Connect(function()
        for i,bb in pairs(tabs) do
            bb.BackgroundColor3 = (i==idx) and Color3.fromRGB(0,150,110) or Color3.fromRGB(45,45,55)
            bb.TextColor3 = (i==idx) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
            contents[i].Visible = (i==idx)
        end
    end)
    return c
end

local CombatTab = makeTab("Combat",1)
local FarmTab = makeTab("Farm",2)
local VisualTab = makeTab("Visual",3)
local MiscTab = makeTab("Misc",4)

tabs[1].BackgroundColor3 = Color3.fromRGB(0,150,110)
tabs[1].TextColor3 = Color3.fromRGB(255,255,255)
contents[1].Visible = true

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
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0,40,0,20)
    bg.Position = UDim2.new(1,-50,0.5,-10)
    bg.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bg.Parent = b
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local k = Instance.new("Frame")
    k.Size = UDim2.new(0,16,0,16)
    k.Position = UDim2.new(0,2,0.5,-8)
    k.BackgroundColor3 = Color3.fromRGB(200,200,200)
    k.Parent = bg
    Instance.new("UICorner", k).CornerRadius = UDim.new(1,0)

    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        if s then
            bg.BackgroundColor3 = Color3.fromRGB(0,200,120)
            k.Position = UDim2.new(1,-18,0.5,-8)
        else
            bg.BackgroundColor3 = Color3.fromRGB(60,60,70)
            k.Position = UDim2.new(0,2,0.5,-8)
        end
        callback(s)
    end)
end

local function makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,34)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.Text = name
    b.TextColor3 = Color3.fromRGB(220,220,220)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(callback)
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
    l.TextSize = 13
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
    bar.BackgroundColor3 = Color3.fromRGB(0,200,150)
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X)/bb.AbsoluteSize.X,0,1)
        local v = math.floor(min+(max-min)*rx)
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
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0,100,1,0)
    vl.Position = UDim2.new(1,-105,0,0)
    vl.BackgroundTransparency = 1
    vl.Text = default.." v"
    vl.TextColor3 = Color3.fromRGB(0,200,150)
    vl.Font = Enum.Font.Gotham
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f

    local open = false
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(1,0,0,#options*30)
    cont.Position = UDim2.new(0,0,1,4)
    cont.BackgroundColor3 = Color3.fromRGB(30,30,38)
    cont.BorderSizePixel = 0
    cont.Visible = false
    cont.ZIndex = 5
    cont.Parent = f
    Instance.new("UICorner", cont).CornerRadius = UDim.new(0,6)
    local ll = Instance.new("UIListLayout")
    ll.Parent = cont

    for _,opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,30)
        ob.BackgroundColor3 = Color3.fromRGB(30,30,38)
        ob.Text = opt
        ob.TextColor3 = Color3.fromRGB(220,220,220)
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 12
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

makeToggle(CombatTab,"God Mode",function(v) CFG.GodMode=v end)
makeSlider(CombatTab,"Speed",16,300,100,function(v) CFG.SpeedValue=v end)
makeToggle(CombatTab,"Enable Speed",function(v) CFG.SpeedEnabled=v end)
makeToggle(CombatTab,"Fast Attack",function(v) CFG.AttackEnabled=v end)

makeDropdown(FarmTab,"Location",{"Location 1","Location 2","Location 3"},"Location 1",function(v)
    CFG.SelectedLocation = v
    CFG.SelectedMob = "All"
end)
makeDropdown(FarmTab,"Enemy",
    {"All","Goat","Polar Bear","Snow Golem","Stary",
     "Fox","Snow Leopard","Tuskin","Frost Stalker",
     "Frog","Crocodile","Swamp Skeleton","Witch"},
    "All",function(v) CFG.SelectedMob=v end)
makeDropdown(FarmTab,"Farm Mode",{"Walk","TP"},"Walk",function(v) CFG.FarmMode=v end)
makeSlider(FarmTab,"Farm Speed",40,300,100,function(v) CFG.FarmSpeed=v end)
makeToggle(FarmTab,"Auto Farm",function(v) CFG.FarmEnabled=v end)

makeToggle(VisualTab,"Player ESP",function(v) CFG.PlayerESP=v end)
makeToggle(VisualTab,"Mob ESP",function(v) CFG.MobESP=v end)

makeButton(MiscTab,"Save SpawnPoint",function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        CFG.SpawnPoint = char.HumanoidRootPart.CFrame
        print("[SpawnPoint] Saved!")
    end
end)
makeButton(MiscTab,"TP to SpawnPoint",function()
    if CFG.SpawnPoint then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFG.SpawnPoint + Vector3.new(0,3,0)
        end
    end
end)
makeButton(MiscTab,"Clear SpawnPoint",function() CFG.SpawnPoint=nil end)

icon.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
close.MouseButton1Click:Connect(function() main.Visible = false end)

local PEO = {}
local function removePE(plr)
    if PEO[plr] then pcall(function() PEO[plr]:Destroy() end) PEO[plr]=nil end
end
local function applyPE(plr)
    if plr == LP then return end
    if not CFG.PlayerESP then return end
    if PEO[plr] then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not head or not hum then return end

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,240,0,80)
    bb.StudsOffset = Vector3.new(0,3.5,0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextStrokeTransparency = 0
    lbl.RichText = true
    lbl.Parent = bb

    local function upd()
        if not lbl.Parent or not hum.Parent then return end
        local hp = math.floor(hum.Health)
        local maxHp = math.floor(hum.MaxHealth)
        local lvl, rb = 0, 0
        local stats = plr:FindFirstChild("leaderstats")
        if stats then
            for _, s in ipairs(stats:GetChildren()) do
                local n = s.Name:lower()
                if n == "level" or n == "lvl" then lvl = s.Value end
                if n == "rebirth" or n == "reb" then rb = s.Value end
            end
        end
        local color = "rgb(0,255,100)"
        if hp < maxHp*0.6 then color = "rgb(255,200,0)" end
        if hp < maxHp*0.3 then color = "rgb(255,60,60)" end
        lbl.Text = string.format("%s\n<font color='%s'>HP: %s/%s</font>\nLvl: %s | Rb: %s",
            plr.Name, color, formatNumber(hp), formatNumber(maxHp),
            formatNumber(lvl), formatNumber(rb))
    end
    upd()
    PEO[plr] = bb
    hum:GetPropertyChangedSignal("Health"):Connect(upd)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        removePE(plr)
        if CFG.PlayerESP then applyPE(plr) end
    end)
end
task.spawn(function()
    while task.wait(1) do
        if CFG.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do applyPE(p) end
        else
            for p,_ in pairs(PEO) do removePE(p) end
        end
    end
end)

local MEO = {}
local function removeME(m)
    if MEO[m] then pcall(function() MEO[m]:Destroy() end) MEO[m]=nil end
end
local function createME(m)
    if MEO[m] then return end
    if Players:GetPlayerFromCharacter(m) then return end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local head = m:FindFirstChild("Head") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(4,0,1.6,0)
    bb.StudsOffset = Vector3.new(0,2.5,0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.TextStrokeTransparency = 0
    lbl.RichText = true
    lbl.Parent = bb

    local function upd()
        if not lbl.Parent or not hum.Parent then return end
        local hp = math.floor(hum.Health)
        local maxHp = math.floor(hum.MaxHealth)
        local dist = 0
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            dist = math.floor((char.HumanoidRootPart.Position - head.Position).Magnitude)
        end
        lbl.Text = string.format("%s\n<font color='rgb(255,80,80)'>HP: %s/%s</font> | %dm",
            m.Name, formatNumber(hp), formatNumber(maxHp), dist)
    end
    upd()
    MEO[m] = bb
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then removeME(m) else upd() end
    end)
    task.spawn(function()
        while MEO[m] and CFG.MobESP do upd(); task.wait(0.3) end
    end)
    m.AncestryChanged:Connect(function(_, p)
        if not p then removeME(m) end
    end)
end
task.spawn(function()
    while task.wait(2) do
        if CFG.MobESP then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                    createME(obj)
                end
            end
        else
            for m,_ in pairs(MEO) do removeME(m) end
        end
    end
end)

local function findMob()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local names = {}
    if CFG.SelectedMob == "All" then
        for _, n in ipairs(LocationData[CFG.SelectedLocation] or {}) do
            names[n:lower()] = true
        end
    else
        names[CFG.SelectedMob:lower()] = true
    end
    local closest, dist = nil, math.huge
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            if names[mob.Name:lower()] and not Players:GetPlayerFromCharacter(mob) then
                local h = mob:FindFirstChildOfClass("Humanoid")
                if h.Health > 0 then
                    local mh = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
                    if mh then
                        local d = (mh.Position - hrp.Position).Magnitude
                        if d < dist then dist = d; closest = mob end
                    end
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if CFG.GodMode then
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
    end
    if CFG.SpeedEnabled and hum.WalkSpeed ~= CFG.SpeedValue then
        hum.WalkSpeed = CFG.SpeedValue
    end
    if CFG.AttackEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") then
                    local n = v.Name:lower()
                    if n:find("cool") or n:find("delay") or n:find("cd") then
                        pcall(function() v.Value = 0 end)
                    end
                end
            end
            pcall(function() tool:Activate() end)
        end
    end
    if CFG.FarmEnabled and hrp then
        local mob = findMob()
        if mob then
            local mh = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
            if mh then
                if CFG.FarmMode == "TP" then
                    hrp.CFrame = mh.CFrame + Vector3.new(0,5,0)
            
