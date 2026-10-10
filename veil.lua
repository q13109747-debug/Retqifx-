--[[
    VEIL AutoFarm + Stat + Visual Luck
    For Blox Fruits (First Sea ready)
    
    Keybinds:
    F1 - Farm ON/OFF
    F2 - Boss mode
    F3 - TP / Walk
    F4 - Stat allocation ON/OFF
    F5 - Visual Luck ON/OFF
]]

-- ============================================
--              CONFIG
-- ============================================

getgenv().Farm = {
    Enabled = true,
    Mode = "TP",
    AttackSpeed = 0.05,
    UseSkills = true,
    WeaponType = "Auto",
    PreferredFruit = nil,
    TPHeight = 5,
    TPBackDistance = 3,
    TargetMobs = {
        "Bandit", "Monkey", "Gorilla", "Pirate",
        "Brute", "Desert Bandit", "Snow Bandit",
        "Military Soldier", "Military Spy",
        "Magma Ninja", "Lava Pirate",
        "Fishman", "Sea Soldier"
    },
    BossMode = false,
    TargetBosses = {
        "Greybeard", "Mob Leader", "Vice Admiral",
        "Saber Expert", "The Saw", "Diamond",
        "Jeremy", "Fajita", "Frost Bandit"
    },
    BossESP = true,
    BossAlert = true,
    ESPColor = Color3.fromRGB(255, 50, 50),
    EatAfterKill = true,
}

getgenv().StatConfig = {
    Enabled = true,
    SelectedStats = {
        "Blox Fruit",
        "Sword",
        "Defense",
    },
    CheckInterval = 5,
    AutoConfirm = true,
}

getgenv().VisualLuck = {
    Enabled = true,
    RainbowText = true,
}

-- ============================================
--              SERVICES
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

-- ============================================
--              HELPERS
-- ============================================

local function getChar() return LP.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getBackpack() return LP:FindFirstChild("Backpack") end
local function getTool()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Tool")
end
local function dist(pos)
    local hrp = getHRP()
    if not hrp then return math.huge end
    return (hrp.Position - pos).Magnitude
end
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2
        })
    end)
end

-- ============================================
--          WEAPON SWITCHING
-- ============================================

local function equipByName(name)
    local bp = getBackpack()
    if not bp then return false end
    local tool = bp:FindFirstChild(name)
    if tool then
        getHum():EquipTool(tool)
        return true
    end
    return false
end

local function autoEquipWeapon()
    local bp = getBackpack()
    if not bp then return end
    
    if Farm.PreferredFruit and equipByName(Farm.PreferredFruit) then return end
    
    for _, t in pairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("fruit") then
            getHum():EquipTool(t)
            return
        end
    end
    
    for _, t in pairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            getHum():EquipTool(t)
            return
        end
    end
end

-- ============================================
--           ATTACK SPAM
-- ============================================

local attackConn

local function startAttackSpam()
    if attackConn then attackConn:Disconnect() end
    attackConn = RunService.Heartbeat:Connect(function()
        if not Farm.Enabled then return end
        local tool = getTool()
        if tool then tool:Activate() end
    end)
end

local function stopAttackSpam()
    if attackConn then
        attackConn:Disconnect()
        attackConn = nil
    end
end

-- ============================================
--              TP FARM
-- ============================================

local function findTarget()
    local list = Farm.BossMode and Farm.TargetBosses or Farm.TargetMobs
    local closest, closestDist = nil, math.huge
    
    for _, mob in pairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then
                for _, name in pairs(list) do
                    if mob.Name:lower():find(name:lower()) then
                        local d = dist(mob:GetPivot().Position)
                        if d < closestDist then
                            closest = mob
                            closestDist = d
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function teleportTo(mob)
    local hrp = getHRP()
    if not hrp or not mob then return end
    local targetPos = mob:GetPivot().Position
    local behind = (hrp.Position - targetPos).Unit
    local newPos = targetPos - behind * Farm.TPBackDistance + Vector3.new(0, Farm.TPHeight, 0)
    hrp.CFrame = CFrame.new(newPos, targetPos)
    hrp.Velocity = Vector3.zero
end

local function tpFarmLoop()
    task.spawn(function()
        while task.wait(0.2) do
            if Farm.Enabled and Farm.Mode == "TP" then
                local mob = findTarget()
                if mob then teleportTo(mob) end
            end
        end
    end)
end

-- ============================================
--          BOSS ESP + ALERT
-- ============================================

local trackedBosses = {}

local function makeBossESP(boss)
    if trackedBosses[boss] then return end
    trackedBosses[boss] = true
    
    local gui = Instance.new("BillboardGui")
    gui.Name = "VEIL_BossESP"
    gui.Size = UDim2.new(0, 250, 0, 70)
    gui.AlwaysOnTop = true
    gui.Adornee = boss
    gui.Parent = boss
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.BackgroundTransparency = 1
    label.Text = "BOSS: " .. boss.Name
    label.TextColor3 = Farm.ESPColor
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    
    local hp = Instance.new("TextLabel")
    hp.Size = UDim2.new(1, 0, 0.4, 0)
    hp.Position = UDim2.new(0, 0, 0.6, 0)
    hp.BackgroundTransparency = 1
    hp.TextColor3 = Color3.fromRGB(255, 255, 255)
    hp.TextStrokeTransparency = 0
    hp.TextScaled = true
    hp.Parent = gui
    
    local hum = boss:FindFirstChildOfClass("Humanoid")
    if hum then
        hp.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        hum.HealthChanged:Connect(function(h)
            hp.Text = math.floor(h) .. " / " .. math.floor(hum.MaxHealth)
            if h <= 0 then gui:Destroy() end
        end)
    end
    
    if Farm.BossAlert then
        notify("BOSS SPAWNED", boss.Name, 5)
    end
end

local function scanBosses()
    if not Farm.BossESP then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            for _, bname in pairs(Farm.TargetBosses) do
                if obj.Name:lower():find(bname:lower()) then
                    makeBossESP(obj)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(scanBosses)

-- ============================================
--           AUTO HEAL
-- ============================================

RunService.Heartbeat:Connect(function()
    if not Farm.Enabled or not Farm.EatAfterKill then return end
    local hum = getHum()
    if not hum then return end
    if hum.Health / hum.MaxHealth < 0.3 then
        local bp = getBackpack()
        if not bp then return end
        for _, item in pairs(bp:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("fruit") or item.Name:lower():find("food")) then
                hum:EquipTool(item)
                item:Activate()
                task.wait(0.5)
                autoEquipWeapon()
                break
            end
        end
    end
end)

-- ============================================
--          AUTO STAT (EVEN)
-- ============================================

local function getStatPoints()
    for _, label in pairs(LP.PlayerGui:GetDescendants()) do
        if label:IsA("TextLabel") then
            local t = label.Text
            if t:lower():find("point") then
                local n = t:match("(%d+)")
                if n then return tonumber(n) end
            end
            if t:match("^%d+$") then return tonumber(t) end
        end
    end
    return 0
end

local function findPlusButton(statName)
    for _, obj in pairs(LP.PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local parent = obj.Parent
            if parent then
                for _, label in pairs(parent:GetDescendants()) do
                    if label:IsA("TextLabel") and label.Text:lower():find(statName:lower()) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function allocateStats()
    if not StatConfig.Enabled then return end
    local points = getStatPoints()
    if points <= 0 then return end
    
    local stats = StatConfig.SelectedStats
    local count = #stats
    if count == 0 then return end
    
    local perStat = math.floor(points / count)
    local remainder = points % count
    
    for i, statName in ipairs(stats) do
        local amount = perStat
        if i <= remainder then amount = amount + 1 end
        local btn = findPlusButton(statName)
        if btn then
            for _ = 1, amount do
                btn:Activate()
                task.wait(0.08)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if StatConfig.AutoConfirm then
            for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") then
                    local t = gui.Text:lower()
                    if t:find("yes") or t:find("confirm") or t:find("ok") then
                        gui:Activate()
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    task.wait(5)
    while task.wait(StatConfig.CheckInterval) do
        pcall(allocateStats)
    end
end)

-- ============================================
--          VISUAL LUCK
-- ============================================

local function initVisualLuck()
    if LP.PlayerGui:FindFirstChild("VEIL_LuckGUI") then
        LP.PlayerGui.VEIL_LuckGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "VEIL_LuckGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LP.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 70)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.BackgroundTransparency = 1
    title.Text = "LUCK x100 ACTIVE"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0.5, 0)
    sub.Position = UDim2.new(0, 0, 0.5, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "Rare drop chance boosted"
    sub.TextColor3 = Color3.fromRGB(200, 200, 200)
    sub.Font = Enum.Font.Gotham
    sub.TextScaled = true
    sub.Parent = frame
    
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.005) % 1
            stroke.Color = Color3.fromHSV(hue, 1, 1)
            if VisualLuck.RainbowText then
                title.TextColor3 = Color3.fromHSV((hue + 0.5) % 1, 0.8, 1)
            end
            task.wait(0.03)
        end
    end)
    
    task.spawn(function()
        local lastPopup = 0
        RunService.Heartbeat:Connect(function()
            if tick() - lastPopup < 8 then return end
            if math.random() < 0.0005 then
                lastPopup = tick()
                local popup = Instance.new("TextLabel")
                popup.Size = UDim2.new(0, 400, 0, 50)
                popup.Position = UDim2.new(0.5, -200, 0.3, 0)
                popup.BackgroundTransparency = 1
                popup.Text = "LUCK PROC! x100"
                popup.TextColor3 = Color3.fromRGB(255, 215, 0)
                popup.TextStrokeTransparency = 0
                popup.Font = Enum.Font.GothamBlack
                popup.TextScaled = true
                popup.Parent = gui
                task.spawn(function()
                    for i = 1, 30 do
                        popup.TextTransparency = i / 30
                        popup.TextStrokeTransparency = i / 30
                        popup.Position = popup.Position + UDim2.new(0, 0, -0.002, 0)
                        task.wait(0.03)
                    end
                    popup:Destroy()
                end)
            end
        end)
    end)
end

if VisualLuck.Enabled then initVisualLuck() end

-- ============================================
--              KEYBINDS
-- ============================================

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        Farm.Enabled = not Farm.Enabled
        if Farm.Enabled then
            startAttackSpam()
            autoEquipWeapon()
        else
            stopAttackSpam()
        end
        notify("Farm", Farm.Enabled and "ON" or "OFF", 2)
    end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        Farm.BossMode = not Farm.BossMode
        notify("Farm", Farm.BossMode and "Boss mode" or "Mob mode", 2)
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        Farm.Mode = Farm.Mode == "TP" and "Walk" or "TP"
        notify("Farm", "Mode: " .. Farm.Mode, 2)
    end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        StatConfig.Enabled = not StatConfig.Enabled
        notify("Stats", StatConfig.Enabled and "ON" or "OFF", 2)
    end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        VisualLuck.Enabled = not VisualLuck.Enabled
        local g = LP.PlayerGui:FindFirstChild("VEIL_LuckGUI")
        if VisualLuck.Enabled and not g then
            initVisualLuck()
        elseif g then
            g:Destroy()
        end
    end
end)

-- ============================================
--              START
-- ============================================

task.wait(3)
autoEquipWeapon()
startAttackSpam()
tpFarmLoop()

notify("VEIL Loaded", "F1 farm | F2 boss | F3 TP | F4 stat | F5 luck", 5)

print("[VEIL] All modules loaded.")