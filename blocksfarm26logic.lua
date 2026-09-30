--[[
    Blocks Farm V26 | Logic
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local S = _G.BF
if not S or not S.CFG then
    warn("[Logic] Run main.lua first!")
    return
end

local CFG = S.CFG
local formatNumber = S.formatNumber

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Speed / Jump
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CFG.SpeedEnabled and hum.WalkSpeed ~= CFG.SpeedValue then
        hum.WalkSpeed = CFG.SpeedValue
    end
    if CFG.JumpEnabled then
        hum.JumpPower = CFG.JumpValue
        hum.UseJumpPower = true
    end
end)

-- Mob ESP
local MEO = {}
local Blacklist = {["Daily Quests"]=true,["Artifact Magician"]=true,["Shop"]=true,["Магазин"]=true}
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
        lbl.Text = m.Name .. "\nHP: " .. formatNumber(math.floor(hum.Health))
    end
    upd()
    MEO[m] = bb
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then removeME(m) else upd() end
    end)
end
task.spawn(function()
    while task.wait(3) do
        if CFG.MobESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
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
    for _, mob in ipairs(Workspace:GetDescendants()) do
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

-- Pickup
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

-- Main loop
local lastAA, lastKA, lastPick, lastFarm = 0,0,0,0
local flyBV = nil

RunService.Heartbeat:Connect(function()
    local now = tick()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

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
end)

print("[Blocks Farm V26] Logic loaded | Xs_KakoNINik")