--[[
    Blocks Farm V27 | Logic Part 3-2
    Автор: Xs_KakoNINik | TG: @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local S = _G.BF
if not S or not S.CFG then
    warn("[BF27] Run bf27_ui1.lua first!")
    return
end

local CFG = S.CFG
local formatNumber = S.formatNumber

-- ============================================
-- Bring NPCs (Кузнец, Маг артефактов, Квестовики)
-- ============================================
local NPCS = {
    ["Blacksmith"] = true,
    ["Artifact Magician"] = true,
    ["Daily Quests"] = true,
    ["Boss Rune"] = true,
}

task.spawn(function()
    while task.wait(0.3) do
        if not CFG.BringNPCs then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and NPCS[obj.Name] then
                local target = obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                    or obj:FindFirstChildWhichIsA("BasePart")
                if target then
                    local dist = (target.Position - hrp.Position).Magnitude
                    if CFG.BringNPCsAll or dist < 500 then
                        pcall(function()
                            -- Открепляем, если Anchored
                            for _, p in ipairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") and p.Anchored then
                                    p.Anchored = false
                                end
                            end
                            target.CFrame = hrp.CFrame + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
                        end)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- findMob / findEnemy
-- ============================================
local function findMob()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge

    local names = {}
    if CFG.AutoFarmAll then
        for _, n in ipairs(S.MobList) do names[n] = true end
    else
        names[CFG.SelectedEnemy] = true
    end

    for _, mob in ipairs(Workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            if names[mob.Name] and not Players:GetPlayerFromCharacter(mob) then
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
    for _, obj in ipairs(Workspace:GetDescendants()) do
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

-- ============================================
-- Pickup
-- ============================================
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

-- ============================================
-- Auto Dodge
-- ============================================
local function doDodge(hrp)
    if not CFG.AutoDodge then return end
    local dirs = {
        Vector3.new(0, 0, -10),
        Vector3.new(0, 0, 10),
        Vector3.new(-10, 0, 0),
        Vector3.new(10, 0, 0),
    }
    hrp.CFrame = hrp.CFrame + dirs[math.random(1, #dirs)]
end

-- ============================================
-- Spawn Point
-- ============================================
task.spawn(function()
    while task.wait(1) do
        if CFG.SpawnPoint and CFG.AutoTPOnDeath then
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    task.wait(2)
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.HumanoidRootPart.CFrame = CFG.SpawnPoint
                    end
                end
            end
        end
    end
end)

-- ============================================
-- Auto Rejoin
-- ============================================
task.spawn(function()
    while task.wait(5) do
        if CFG.AutoRejoin then
            if game:GetService("Players").LocalPlayer.Parent == nil then
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
                end)
            end
        end
    end
end)

-- ============================================
-- Main Loop
-- ============================================
local lastAA, lastKA, lastPick, lastFarm, lastTarget, lastBring = 0,0,0,0,0,0
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

    -- No Cooldown
    if CFG.NoCooldown then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") then pcall(function() v.Value = 0 end) end
            end
        end
    end

    -- Auto Attack
    if CFG.AutoAttack and now - lastAA > 0.15 then
        lastAA = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local t = findEnemy(CFG.AutoAttackRange)
            if t then pcall(function() tool:Activate() end) end
        end
    end

    -- Kill Aura
    if CFG.KillAura and now - lastKA > 0.2 then
        lastKA = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, mob in ipairs(Workspace:GetDescendants()) do
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

    -- Fly to Mob
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

    -- Auto Farm
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
                        if d > 100 then hrp.CFrame = mh.CFrame
                        else hrp.CFrame = hrp.CFrame + (mh.Position - hrp.Position).Unit * (CFG.FarmSpeed/10) end
                    end
                end
            end
        end
    end

    -- Auto Pickup
    if CFG.AutoPickup and now - lastPick > 1 then
        lastPick = now
        for _, obj in ipairs(Workspace:GetDescendants()) do
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

    -- Bring All
    if CFG.BringAll and now - lastBring > 0.5 then
        lastBring = now
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local d = (obj.Position - hrp.Position).Magnitude
                if d < CFG.BringRadius and d > 5 then
                    pcall(function()
                        obj.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
                    end)
                end
            end
        end
    end

    -- Target Tool
    if CFG.TargetEnabled and CFG.TargetPlayer and now - lastTarget > 0.03 then
        lastTarget = now
        local tc = CFG.TargetPlayer.Character
        if tc then
            local th = tc:FindFirstChild("HumanoidRootPart")
            if th then
                if CFG.TargetMode == "Bottom" then
                    hrp.CFrame = th.CFrame + Vector3.new(0, -10, 0)
                elseif CFG.TargetMode == "Helicopter" then
                    heliAngle = heliAngle + (CFG.TargetSpeed/100)
                    hrp.CFrame = th.CFrame + Vector3.new(
                        math.cos(heliAngle) * CFG.HelicopterRadius, 0,
                        math.sin(heliAngle) * CFG.HelicopterRadius)
                end
            end
        end
    end
end)

print("[BF27] Logic Part 3-2 loaded | Xs_KakoNINik | is you noob от автора:3")