-- MAIN TAB
makeSelect(MainTab, "Enemy Type", S.MobList, CFG.SelectedEnemy, function(o) CFG.SelectedEnemy = o end)
makeSelect(MainTab, "Выбрать добычу", S.LootList, CFG.SelectedLoot, function(o) CFG.SelectedLoot = o end)
makeToggle(MainTab, "Auto Farm", function(v) CFG.FarmEnabled = v end)
makeToggle(MainTab, "Fly to Mob", function(v) CFG.FlyToMob = v end)
makeSlider(MainTab, "Fly Speed", 1, 20, 5, function(v) CFG.FlyToMobSpeed = v end)
makeSlider(MainTab, "Farm Speed", 40, 150, 100, function(v) CFG.FarmSpeed = v end)
makeToggle(MainTab, "Auto Attack", function(v) CFG.AutoAttack = v end)
makeToggle(MainTab, "Kill Aura", function(v) CFG.KillAura = v end)
makeToggle(MainTab, "No Cooldown", function(v) CFG.NoCooldown = v end)

-- MOVEMENT
makeToggle(MovementTab, "Enable Speed", function(v) CFG.SpeedEnabled = v end)
makeSlider(MovementTab, "Speed", 40, 300, 40, function(v) CFG.SpeedValue = v end)
makeToggle(MovementTab, "Enable Jump", function(v) CFG.JumpEnabled = v end)
makeToggle(MovementTab, "Infinite Jump", function(v) CFG.InfJump = v end)

-- ESP
makeToggle(ESPTab, "Mob ESP", function(v) CFG.MobESP = v end)
makeToggle(ESPTab, "Player ESP", function(v) CFG.PlayerESP = v end)

-- TARGET
makeToggle(TargetTab, "Target Tool", function(v) CFG.TargetEnabled = v end)
makeSelect(TargetTab, "Target Mode", {"Bottom","Helicopter"}, CFG.TargetMode, function(o) CFG.TargetMode = o end)
makeSlider(TargetTab, "Heli Speed", 10, 200, 50, function(v) CFG.TargetSpeed = v end)
makeSlider(TargetTab, "Heli Radius", 5, 50, 10, function(v) CFG.HelicopterRadius = v end)

-- PICKUP
makeToggle(PickupTab, "Auto Pickup", function(v) CFG.AutoPickup = v end)
makeToggle(PickupTab, "Pick Runes", function(v) CFG.PickRunes = v end)
makeToggle(PickupTab, "Pick Helmet", function(v) CFG.PickHelmet = v end)
makeToggle(PickupTab, "Pick Chestplate", function(v) CFG.PickChestplate = v end)
makeToggle(PickupTab, "Pick Boots", function(v) CFG.PickBoots = v end)
makeToggle(PickupTab, "Pick Weapon", function(v) CFG.PickWeapon = v end)

-- SETTINGS
makeToggle(MiscTab, "Auto TP on Death", function(v) CFG.AutoTPOnDeath = v end)
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1,-10,0,32)
saveBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
saveBtn.Text = "Сохранить Spawn Point"
saveBtn.TextColor3 = Color3.fromRGB(220,220,220)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 11
saveBtn.Parent = MiscTab
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)
saveBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        CFG.SpawnPoint = char.HumanoidRootPart.CFrame
        saveBtn.Text = "✅ Spawn сохранён!"
        task.wait(1.5)
        saveBtn.Text = "Сохранить Spawn Point"
    end
end)

-- ОТКРЫТИЕ МЕНЮ
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Mob ESP
local MEO = {}
local Blacklist = {
    ["Daily Quests"]=true, ["Artifact Magician"]=true,
    ["Shop"]=true, ["Магазин"]=true, ["Sumka"]=true, ["Сумка"]=true,
}
local function removeME(m)
    if MEO[m] then pcall(function() MEO[m]:Destroy() end) MEO[m] = nil end
end
local function createME(m)
    if MEO[m] or Players:GetPlayerFromCharacter(m) or Blacklist[m.Name] then return end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local head = m:FindFirstChild("Head") or m.PrimaryPart
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(2,0,0.7,0)
    bb.StudsOffset = Vector3.new(0,2.5,0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 11
    lbl.TextStrokeTransparency = 0
    lbl.Parent = bb
    local function upd()
        if not lbl.Parent or not hum.Parent then return end
        local hp = formatNumber(math.floor(hum.Health))
        local char = LP.Character
        local dist = 0
        if char and char:FindFirstChild("HumanoidRootPart") then
            dist = math.floor((char.HumanoidRootPart.Position - head.Position).Magnitude)
        end
        lbl.Text = m.Name.."\nHP: "..hp.." | "..dist.."m"
    end
    upd()
    MEO[m] = bb
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then removeME(m) else upd() end
    end)
    task.spawn(function()
        while MEO[m] and CFG.MobESP do upd(); task.wait(0.5) end
    end)
end
task.spawn(function()
    while task.wait(3) do
        if CFG.MobESP then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then createME(obj) end
            end
        else
            for m,_ in pairs(MEO) do removeME(m) end
        end
    end
end)

-- Player ESP
local PEO = {}
local function removePE(plr)
    if PEO[plr] then pcall(function() PEO[plr]:Destroy() end) PEO[plr] = nil end
end
task.spawn(function()
    while task.wait(2) do
        if CFG.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and not PEO[plr] and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local head = plr.Character:FindFirstChild("Head")
                    if hum and head then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0,240,0,80)
                        bb.StudsOffset = Vector3.new(0,3.5,0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = head
                        bb.Parent = head
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0,255,100)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 14
                        lbl.TextStrokeTransparency = 0
                        lbl.Parent = bb
                        local function upd()
                            local lvl, rb = 0, 0
                            local st = plr:FindFirstChild("leaderstats")
                            if st then
                                for _, s in ipairs(st:GetChildren()) do
                                    local n = s.Name:lower()
                                    if n == "level" or n == "lvl" then lvl = s.Value end
                                    if n == "rebirth" or n == "reb" then rb = s.Value end
                                end
                            end
                            lbl.Text = string.format("%s\nHP: %s\nLvl: %s | Rb: %s",
                                plr.Name, formatNumber(math.floor(hum.Health)),
                                formatNumber(lvl), formatNumber(rb))
                        end
                        upd()
                        PEO[plr] = bb
                    end
                end
            end
        else
            for p,_ in pairs(PEO) do removePE(p) end
        end
    end
end)

-- findMob / findEnemy
local function findMob()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            if mob.Name == CFG.SelectedEnemy and not Players:GetPlayerFromCharacter(mob) then
                local h = mob:FindFirstChildOfClass("Humanoid")
                if h.Health > 0 then
                    local mh = mob:FindFirstChild("HumanoidRootPart")
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

local function findEnemy(range)
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
            if obj.Name:match("^%d_%d_%d$") then
                local h = obj:FindFirstChildOfClass("Humanoid")
                if h.Health > 0 then
                    local mh = obj:FindFirstChild("HumanoidRootPart")
                    if mh then
                        local d = (mh.Position - hrp.Position).Magnitude
                        if d < range and d < dist then dist = d; closest = mh end
                    end
                end
            end
        end
    end
    return closest
end

-- pickup
local function matches(name, kws)
    local n = name:lower()
    for _, kw in ipairs(kws) do if n:find(kw) then return true end end
    return false
end
local function isRune(n) return matches(n, {"rune","руна","fragment","фрагмент"}) end
local function isHelmet(n) return matches(n, {"шлем","helmet"}) end
local function isChest(n) return matches(n, {"нагрудник","нагр","chest"}) end
local function isLegs(n) return matches(n, {"штаны","leg"}) end
local function isBoots(n) return matches(n, {"ботин","boot"}) end
local function isWeapon(n) return matches(n, {"меч","sword","посох","staff","оружие","weapon","wand"}) end
local function isShield(n) return matches(n, {"щит","shield"}) end

local function tryPickup(obj, hrp, range)
    local pos = nil
    if obj:IsA("Model") and obj.PrimaryPart then pos = obj.PrimaryPart.Position
    elseif obj:IsA("BasePart") then pos = obj.Position
    elseif obj:IsA("Tool") and obj:FindFirstChild("Handle") then pos = obj.Handle.Position end
    if not pos then return end
    if (pos - hrp.Position).Magnitude > range then return end
    local cd = obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildWhichIsA("ClickDetector", true)
    if cd and fireclickdetector then pcall(function() fireclickdetector(cd) end) return end
    local pp = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if pp and fireproximityprompt then pcall(function() fireproximityprompt(pp) end) end
end

-- main loop
local lastAA, lastKA, lastPick, lastFarm, lastTarget = 0,0,0,0,0
local heliAngle = 0
local flyBV = nil

RunService.Heartbeat:Connect(function()
    local now = tick()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if CFG.SpeedEnabled then hum.WalkSpeed = CFG.SpeedValue end
    if CFG.JumpEnabled then hum.JumpPower = CFG.JumpValue; hum.UseJumpPower = true end

    if CFG.NoCooldown then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") then pcall(function() v.Value = 0 end) end
            end
        end
    end

    if CFG.AutoAttack and now - lastAA > 0.15 then
        lastAA = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local t = findEnemy(CFG.AutoAttackRange)
            if t then pcall(function() tool:Activate() end) end
        end
    end

    if CFG.KillAura and now - lastKA > 0.2 then
        lastKA = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, mob in ipairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") and mob ~= char and mob.Name:match("^%d_%d_%d$") then
                    local h = mob:FindFirstChildOfClass("Humanoid")
                    if h.Health > 0 then
                        local mh = mob:FindFirstChild("HumanoidRootPart")
                        if mh and (mh.Position - hrp.Position).Magnitude < CFG.KillAuraRange then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end
            end
        end
    end

    if CFG.FlyToMob then
        local mob = findMob()
        if mob then
            local mh = mob:FindFirstChild("HumanoidRootPart")
            if mh then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
                    flyBV.Parent = hrp
                end
                local dir = mh.Position - hrp.Position
                flyBV.Velocity = dir.Magnitude < 3 and Vector3.new(0,0,0) or dir.Unit * (CFG.FlyToMobSpeed * 10)
            end
        end
    elseif flyBV then
        flyBV:Destroy(); flyBV = nil
    end

    if CFG.FarmEnabled and not CFG.FlyToMob and now - lastFarm > 0.05 then
        lastFarm = now
        local mob = findMob()
        if mob then
            local mh = mob:FindFirstChild("HumanoidRootPart")
            if mh then
                if CFG.TPFarm then hrp.CFrame = mh.CFrame
                else
                    local d = (mh.Position - hrp.Position).Magnitude
                    if d > 3 then
                        hrp.CFrame = hrp.CFrame + (mh.Position - hrp.Position).Unit * (CFG.FarmSpeed/10)
                    end
                end
            end
        end
    end

    if CFG.AutoPickup and now - lastPick > 1 then
        lastPick = now
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart") then
                local n = obj.Name
                local ok = false
                if CFG.PickRunes and isRune(n) then ok = true
                elseif CFG.PickHelmet and isHelmet(n) then ok = true
                elseif CFG.PickChestplate and isChest(n) then ok = true
                elseif CFG.PickLeggings and isLegs(n) then ok = true
                elseif CFG.PickBoots and isBoots(n) then ok = true
                elseif CFG.PickWeapon and isWeapon(n) then ok = true
                elseif CFG.PickShield and isShield(n) then ok = true
                end
                if ok then tryPickup(obj, hrp, 100) end
            end
        end
    end

    if CFG.TargetEnabled and CFG.TargetPlayer and now - lastTarget > 0.03 then
        lastTarget = now
        local tc = CFG.TargetPlayer.Character
        if tc then
            local th = tc:FindFirstChild("HumanoidRootPart")
            if th then
                if CFG.TargetMode == "Bottom" then
                    hrp.CFrame = th.CFrame + Vector3.new(0,-10,0)
                else
                    heliAngle = heliAngle + (CFG.TargetSpeed/100)
                    hrp.CFrame = th.CFrame + Vector3.new(
                        math.cos(heliAngle) * CFG.HelicopterRadius, 0,
                        math.sin(heliAngle) * CFG.HelicopterRadius)
                end
            end
        end
    end

    if CFG.SpawnPoint and CFG.AutoTPOnDeath and hum.Health <= 0 then
        task.wait(0.5)
        if char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFG.SpawnPoint
        end
    end
end)

print("[Blocks Farm V26] All-in-one loaded")