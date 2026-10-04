--[[
    Blocks Farm V26 | UI Part 2 (Tabs Fill)
    Автор: Xs_KakoNINik | TG: @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local S = _G.BF
if not S or not S._UI then
    warn("[BF26] Run bf26_ui1.lua first!")
    return
end

local CFG = S.CFG
local UI = S._UI

-- Ссылки на табы
local MainTab = UI.tabs.Main
local MovementTab = UI.tabs.Movement
local ESPTab = UI.tabs.ESP
local TargetTab = UI.tabs.Target
local PickupTab = UI.tabs.Pickup
local MiscTab = UI.tabs.Misc

local makeToggle = UI.makeToggle
local makeSlider = UI.makeSlider
local sg = UI.sg

-- Функция makeSelect (создаём тут, чтобы не раздувать ui1)
local function makeSelect(parent, label, options, default, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.45, -10, 1, 0)
    v.Position = UDim2.new(0.55, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = default or "Выбрать"
    v.TextColor3 = Color3.fromRGB(255, 200, 0)
    v.Font = Enum.Font.Gotham
    v.TextSize = 11
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = b

    b.MouseButton1Click:Connect(function()
        local picker = Instance.new("Frame")
        picker.Size = UDim2.new(0, 260, 0, 300)
        picker.Position = UDim2.new(0.5, -130, 0.5, -150)
        picker.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        picker.BorderSizePixel = 0
        picker.Active = true
        picker.Draggable = true
        picker.ZIndex = 100
        picker.Parent = sg
        Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 30)
        t.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        t.Text = label
        t.TextColor3 = Color3.fromRGB(0, 0, 0)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.ZIndex = 101
        t.Parent = picker
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

        local cp = Instance.new("TextButton")
        cp.Size = UDim2.new(0, 24, 0, 24)
        cp.Position = UDim2.new(1, -28, 0, 3)
        cp.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        cp.Text = "X"
        cp.TextColor3 = Color3.fromRGB(255, 255, 255)
        cp.Font = Enum.Font.GothamBold
        cp.TextSize = 12
        cp.ZIndex = 102
        cp.Parent = picker
        Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 4)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -40)
        scroll.Position = UDim2.new(0, 5, 0, 35)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
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
            ob.Size = UDim2.new(1, -5, 0, 28)
            ob.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            ob.Text = opt
            ob.TextColor3 = Color3.fromRGB(220, 220, 220)
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

-- ============================================
-- MAIN TAB
-- ============================================
makeSelect(MainTab, "Enemy Type", S.MobList, CFG.SelectedEnemy, function(o) CFG.SelectedEnemy = o end)
makeSelect(MainTab, "Выбрать добычу", S.LootList, CFG.SelectedLoot, function(o) CFG.SelectedLoot = o end)
makeToggle(MainTab, "Auto Farm", function(v) CFG.FarmEnabled = v end)
makeToggle(MainTab, "Auto Farm ALL", function(v) CFG.AutoFarmAll = v end)
makeToggle(MainTab, "Fly to Mob", function(v) CFG.FlyToMob = v end)
makeSlider(MainTab, "Fly Speed", 1, 20, 5, function(v) CFG.FlyToMobSpeed = v end)
makeSlider(MainTab, "Farm Speed", 40, 150, 100, function(v) CFG.FarmSpeed = v end)
makeToggle(MainTab, "Auto Attack", function(v) CFG.AutoAttack = v end)
makeToggle(MainTab, "Kill Aura", function(v) CFG.KillAura = v end)
makeToggle(MainTab, "No Cooldown", function(v) CFG.NoCooldown = v end)
makeToggle(MainTab, "Hitbox Expander", function(v) CFG.HitboxExpander = v end)
makeSlider(MainTab, "Hitbox Size", 5, 50, 10, function(v) CFG.HitboxSize = v end)
makeToggle(MainTab, "Auto Dodge", function(v) CFG.AutoDodge = v end)

-- ============================================
-- MOVEMENT TAB
-- ============================================
makeToggle(MovementTab, "Enable Speed", function(v) CFG.SpeedEnabled = v end)
makeSlider(MovementTab, "Speed", 40, 450, 40, function(v) CFG.SpeedValue = v end)
makeToggle(MovementTab, "Enable Jump", function(v) CFG.JumpEnabled = v end)
makeToggle(MovementTab, "Infinite Jump", function(v) CFG.InfJump = v end)
makeToggle(MovementTab, "No Stun", function(v) CFG.NoStun = v end)

-- ============================================
-- ESP TAB
-- ============================================
makeToggle(ESPTab, "Mob ESP", function(v) CFG.MobESP = v end)
makeToggle(ESPTab, "Player ESP", function(v) CFG.PlayerESP = v end)
makeToggle(ESPTab, "Runes ESP", function(v) CFG.RunesESP = v end)
makeToggle(ESPTab, "Boss Detect", function(v) CFG.BossDetect = v end)

-- ============================================
-- TARGET TAB
-- ============================================
makeToggle(TargetTab, "Target Tool", function(v) CFG.TargetEnabled = v end)
makeSelect(TargetTab, "Target Mode", {"Bottom","Helicopter"}, CFG.TargetMode, function(o) CFG.TargetMode = o end)
makeSlider(TargetTab, "Heli Speed", 10, 200, 50, function(v) CFG.TargetSpeed = v end)
makeSlider(TargetTab, "Heli Radius", 5, 50, 10, function(v) CFG.HelicopterRadius = v end)

-- Список игроков
local targetListFrame = Instance.new("Frame")
targetListFrame.Size = UDim2.new(1, -10, 0, 150)
targetListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
targetListFrame.Parent = TargetTab
Instance.new("UICorner", targetListFrame).CornerRadius = UDim.new(0, 6)

local targetTitle = Instance.new("TextLabel")
targetTitle.Size = UDim2.new(1, -20, 0, 20)
targetTitle.Position = UDim2.new(0, 10, 0, 4)
targetTitle.BackgroundTransparency = 1
targetTitle.Text = "Выбрать игрока:"
targetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
targetTitle.Font = Enum.Font.GothamBold
targetTitle.TextSize = 11
targetTitle.TextXAlignment = Enum.TextXAlignment.Left
targetTitle.Parent = targetListFrame

local targetList = Instance.new("ScrollingFrame")
targetList.Size = UDim2.new(1, -20, 1, -30)
targetList.Position = UDim2.new(0, 10, 0, 26)
targetList.BackgroundTransparency = 1
targetList.BorderSizePixel = 0
targetList.ScrollBarThickness = 3
targetList.CanvasSize = UDim2.new(0, 0, 0, 0)
targetList.Parent = targetListFrame

local targetLayout = Instance.new("UIListLayout")
targetLayout.Padding = UDim.new(0, 3)
targetLayout.Parent = targetList
targetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    targetList.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 10)
end)

local function refreshTargetList()
    for _, child in ipairs(targetList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            btn.Text = "  " .. plr.Name
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = targetList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                CFG.TargetPlayer = plr
                for _, other in ipairs(targetList:GetChildren()) do
                    if other:IsA("TextButton") then
                        other.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
                        other.TextColor3 = Color3.fromRGB(220, 220, 220)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            end)
        end
    end
end
refreshTargetList()
Players.PlayerAdded:Connect(function() task.wait(1); refreshTargetList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshTargetList() end)

-- ============================================
-- PICKUP TAB
-- ============================================
makeToggle(PickupTab, "Auto Pickup", function(v) CFG.AutoPickup = v end)
makeToggle(PickupTab, "Pick Runes", function(v) CFG.PickRunes = v end)
makeToggle(PickupTab, "Pick Helmet", function(v) CFG.PickHelmet = v end)
makeToggle(PickupTab, "Pick Chestplate", function(v) CFG.PickChestplate = v end)
makeToggle(PickupTab, "Pick Boots", function(v) CFG.PickBoots = v end)
makeToggle(PickupTab, "Pick Weapon", function(v) CFG.PickWeapon = v end)
makeToggle(PickupTab, "Bring All", function(v) CFG.BringAll = v end)
makeSlider(PickupTab, "Bring Radius", 20, 500, 100, function(v) CFG.BringRadius = v end)

-- ============================================
-- SETTINGS TAB
-- ============================================
makeToggle(MiscTab, "Auto TP on Death", function(v) CFG.AutoTPOnDeath = v end)
makeToggle(MiscTab, "Auto Upgrade", function(v) CFG.AutoUpgrade = v end)
makeToggle(MiscTab, "Auto Sell", function(v) CFG.AutoSell = v end)
makeToggle(MiscTab, "Auto Potion", function(v) CFG.AutoPotion = v end)
makeToggle(MiscTab, "Anti-AFK", function(v) CFG.AntiAFK = v end)
makeToggle(MiscTab, "Auto Rejoin", function(v) CFG.AutoRejoin = v end)

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -10, 0, 32)
saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
saveBtn.Text = "Сохранить Spawn Point"
saveBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 11
saveBtn.Parent = MiscTab
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
saveBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        CFG.SpawnPoint = char.HumanoidRootPart.CFrame
        saveBtn.Text = "✅ Spawn сохранён!"
        task.wait(1.5)
        saveBtn.Text = "Сохранить Spawn Point"
    end
end)

print("[BF26] UI Part 2 loaded")

-- Подгрузка логики
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/bf26_logic.lua", true))()
    end)
    if not ok then warn("[BF26] Logic load failed: " .. tostring(err)) end
end)