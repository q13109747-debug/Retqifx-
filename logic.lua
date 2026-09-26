--[[
    Blocks Farm V25 | Part 2 - LOGIC
    + Fly to Mob (полёт прямо к мобу)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local S = _G.BF
if not S or not S.CFG then
    warn("[Part 2] Run PART 1 first!")
    return
end

local CFG = S.CFG
local SelectedMobs = S.SelectedMobs
local formatNumber = S.formatNumber

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ============================================
-- MOB ESP
-- ============================================
local MEO = {}

local Blacklist = {
    ["Daily Quests"] = true,
    ["Artifact Magician"] = true,
    ["Shop"] = true,
    ["Магазин"] = true,
    ["Sumka"] = true,
    ["Сумка"] = true,
}

local function removeME(m)
    if MEO[m] then pcall(function() MEO[m]:Destroy() end) MEO[m] = nil end
end

local function createME(m)
    if MEO[m] then return end
    if Players:GetPlayerFromCharacter(m) then return end
    if Blacklist[m.Name] then return end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local head = m:FindFirstChild("Head") or m.PrimaryPart
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(2, 0, 0.7, 0)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
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
        lbl.Text = m.Name .. "\nHP: " .. hp .. " | " .. dist .. "m"
    end
    upd()
    MEO[m] = bb
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then removeME(m) else upd() end
    end)
    task.spawn(function()
        while MEO[m] and CFG.MobESP do
            upd()
            task.wait(0.5)
        end
    end)
    m.AncestryChanged:Connect(function(_, p)
        if not p then removeME(m) end
    end)
end

task.spawn(function()
    while task.wait(3) do
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

-- ============================================
-- PLAYER ESP
-- ============================================
local PEO = {}
local function removePE(plr)
    if PEO[plr] then pcall(function() PEO[plr]:Destroy() end) PEO[plr] = nil end
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
    bb.Size = UDim2.new(0, 240, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 255, 100)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextStrokeTransparency = 0
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
        lbl.Text = string.format("%s\nHP: %s/%s\nLvl: %s | Rb: %s",
            plr.Name, formatNumber(hp), formatNumber(maxHp),
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
    while task.wait(2) do
        if CFG.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do applyPE(p) end
        else
            for p,_ in pairs(PEO) do removePE(p) end
        end
    end
end)

-- ============================================
-- FIND MOB
-- ============================================
local function findMob()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local names = {}
    for id, _ in pairs(SelectedMobs) do names[id] = true end
    local closest, dist = nil, math.huge
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            if names[mob.Name] and not Players:GetPlayerFromCharacter(mob) then
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

local function findEnemy(range)
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            if obj ~= char and obj.Name:match("^%d_%d_%d$") and obj.Name ~= "Boss Rune" then
                local h = obj:FindFirstChildOfClass("Humanoid")
                if h.Health > 0 then
                    local mh = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
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

-- ============================================
-- AUTO PICKUP
-- ============================================
local function matches(name, keywords)
    local n = name:lower()
    for _, kw in ipairs(keywords) do
        if n:find(kw) then return true end
    end
    return false
end

local function isRune(name) return matches(name, {"rune", "руна", "fragment", "фрагмент"}) end
local function isHelmet(name) return matches(name, {"шлем", "helmet"}) end
local function isChestplate(name) return matches(name, {"нагрудник", "нагр", "chest", "chestplate"}) end
local function isLeggings(name) return matches(name, {"штаны", "leg", "legging"}) end
local function isBoots(name) return matches(name, {"ботин", "boot"}) end
local function isWeapon(name) return matches(name, {"меч", "sword", "посох", "staff", "оружие", "weapon", "wand"}) end
local function isShield(name) return matches(name, {"щит", "shield"}) end

local function tryPickup(obj, hrp, range)
    local pos = nil
    if obj:IsA("Model") and obj.PrimaryPart then pos = obj.PrimaryPart.Position
    elseif obj:IsA("BasePart") then pos = obj.Position
    elseif obj:IsA("Tool") and obj:FindFirstChild("Handle") then pos = obj.Handle.Position end
    if not pos then return false end
    local d = (pos - hrp.Position).Magnitude
    if d > range then return false end
    local cd = obj:FindFirstChildOfClass("ClickDetector")
    if not cd then cd = obj:FindFirstChildWhichIsA("ClickDetector", true) end
    if cd and fireclickdetector then
        pcall(function() fireclickdetector(cd) end)
        return true
    end
    local pp = obj:FindFirstChildOfClass("ProximityPrompt")
    if not pp then pp = obj:FindFirstChildWhichIsA("ProximityPrompt", true) end
    if pp and fireproximityprompt then
        pcall(function() fireproximityprompt(pp) end)
        return true
    end
    return false
end

-- ============================================
-- MAIN LOOP
-- ============================================
local lastAutoAttack = 0
local lastKillAura = 0
local lastPickup = 0
local lastFarm = 0
local lastFly = 0
local lastTarget = 0
local heliAngle = 0
local lastSpawnCheck = 0

RunService.Heartbeat:Connect(function()
    local now = tick()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Speed
    if CFG.SpeedEnabled and hum.WalkSpeed ~= CFG.SpeedValue then
        hum.WalkSpeed = CFG.SpeedValue
    end

    -- Jump
    if CFG.JumpEnabled and hum.JumpPower ~= CFG.JumpValue then
        hum.JumpPower = CFG.JumpValue
        hum.UseJumpPower = true
    end

    -- No Cooldown
    if CFG.NoCooldown then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") then
                    pcall(function() v.Value = 0 end)
                elseif v:IsA("BoolValue") then
                    local n = v.Name:lower()
                    if n:find("cool") or n:find("ready") or n:find("can") then
                        pcall(function() v.Value = true end)
                    end
                end
            end
        end
    end

    -- Auto Attack
    if CFG.AutoAttack and now - lastAutoAttack > 0.15 then
        lastAutoAttack = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local target = findEnemy(CFG.AutoAttackRange)
            if target then pcall(function() tool:Activate() end) end
        end
    end

    -- Kill Aura
    if CFG.KillAura and now - lastKillAura > 0.2 then
        lastKillAura = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, mob in ipairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
                    if mob ~= char and mob.Name:match("^%d_%d_%d$") and mob.Name ~= "Boss Rune" then
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        if h.Health > 0 then
                            local mh = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
                            if mh then
                                local d = (mh.Position - hrp.Position).Magnitude
                                if d < CFG.KillAuraRange then
                                    pcall(function() tool:Activate() end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- ============================================
    -- 🐝 FLY TO MOB (НОВАЯ ФУНКЦИЯ)
    -- ============================================
    if CFG.FlyToMob and now - lastFly > 0.03 then
        lastFly = now
        local mob = findMob()
        if mob then
            local mh = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
            if mh then
                local targetPos = mh.Position + Vector3.new(0, 2, 0)  -- чуть выше моба
                local speed = CFG.FlyToMobSpeed / 10

                -- Плавный полёт через BodyVelocity (не телепорт)
                local bv = hrp:FindFirstChild("FlyToMobVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "FlyToMobVelocity"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp
                end
                local dir = (targetPos - hrp.Position)
                local dist = dir.Magnitude
                if dist < 2 then
                    bv.Velocity = Vector3.new(0, 0, 0)
                else
                    bv.Velocity = dir.Unit * speed * 10
                end
            end
        end
    else
        -- Убираем BodyVelocity если Fly выключен
        local bv = hrp:FindFirstChild("FlyToMobVelocity")
        if bv then bv:Destroy() end
    end

    -- Auto Farm (TP / обычный)
    if CFG.FarmEnabled and not CFG.FlyToMob and now - lastFarm > 0.05 then
        lastFarm = now
        local mob = findMob()
        if mob then
            local mh = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
            if mh then
                if CFG.TPFarm then
                    hrp.CFrame = mh.CFrame
                else
                    local targetPos = mh.Position
                    local distance = (hrp.Position - targetPos).Magnitude
                    if distance > 3 then
                        if distance > 100 then
                            hrp.CFrame = mh.CFrame
                        else
                            local speed = CFG.FarmSpeed / 10
                            local dir = (targetPos - hrp.Position).Unit
                            hrp.CFrame = hrp.CFrame + dir * speed
                        end
                    end
                end
            end
        end
    end

    -- Auto Pickup
    if CFG.AutoPickup and now - lastPickup > 1 then
        lastPickup = now
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart") then
                local n = obj.Name
                local ok = false
                if CFG.PickRunes and isRune(n) then ok = true
                elseif CFG.PickHelmet and isHelmet(n) then ok = true
                elseif CFG.PickChestplate and isChestplate(n) then ok = true
                elseif CFG.PickLeggings and isLeggings(n) then ok = true
                elseif CFG.PickBoots and isBoots(n) then ok = true
                elseif CFG.PickWeapon and isWeapon(n) then ok = true
                elseif CFG.PickShield and isShield(n) then ok = true
                end
                if ok then tryPickup(obj, hrp, 100) end
            end
        end
    end

    -- ============================================
    -- TARGET TOOL (Bottom / Helicopter)
    -- ============================================
    if CFG.TargetEnabled and CFG.TargetPlayer and now - lastTarget > 0.03 then
        lastTarget = now
        local tChar = CFG.TargetPlayer.Character
        if tChar then
            local tHRP = tChar:FindFirstChild("HumanoidRootPart")
            if tHRP then
                if CFG.TargetMode == "Bottom" then
                    hrp.CFrame = tHRP.CFrame + Vector3.new(0, -10, 0)
                elseif CFG.TargetMode == "Helicopter" then
                    heliAngle = heliAngle + (CFG.TargetSpeed / 100)
                    local radius = CFG.HelicopterRadius
                    local x = math.cos(heliAngle) * radius
                    local z = math.sin(heliAngle) * radius
                    hrp.CFrame = tHRP.CFrame + Vector3.new(x, 0, z)
                end
            end
        end
    end

    -- Spawn Point (ТП при смерти)
    if CFG.SpawnPoint and CFG.AutoTPOnDeath and now - lastSpawnCheck > 1 then
        lastSpawnCheck = now
        if hum.Health <= 0 then
            task.wait(0.5)
            char:WaitForChild("HumanoidRootPart", 5)
            if char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFG.SpawnPoint
            end
        end
    end
end)

print("[Part 2 v25] Logic loaded | + Fly to Mob")