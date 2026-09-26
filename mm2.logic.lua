--[[
    Xs_KakoNINik | MM2 Cheat
    Автор: Xs_KakoNINik
    TG: @Xs_KakoINik
    Часть 2: Logic
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

_G.MM2 = _G.MM2 or {}
local S = _G.MM2

if not S.CFG then
    warn("[MM2] CFG не найден! Сначала загрузи mm2.lua")
    return
end

-- ============================================
-- UTILS
-- ============================================
local function getRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    if char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then
        return "Murderer"
    elseif char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function getMyRole() return getRole(LP) end

local function isAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTarget()
    local mpos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, S.CFG.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or not isAlive(plr) then continue end
        local part = plr.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local role = getRole(plr)
        if S.CFG.KillSheriff and role ~= "Sheriff" then continue end
        if S.CFG.KillAll and getMyRole() ~= "Murderer" then continue end

        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(mpos.X, mpos.Y)).Magnitude
        if d < closestDist then
            closest = plr
            closestDist = d
        end
    end
    return closest
end

-- ============================================
-- SILENT AIM
-- ============================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if S.CFG.SilentAim and (method == "Raycast" or method == "FindPartOnRay") then
        if math.random(1, 100) <= S.CFG.HitChance then
            local target = getTarget()
            if target and target.Character then
                local part = target.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    args[2] = (part.Position - args[1]).Unit * (args[2].Magnitude or 1000)
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ============================================
-- AUTO GRAB GUN
-- ============================================
task.spawn(function()
    while task.wait(0.1) do
        if not S.CFG.AutoGrabGun then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "Gun" or obj.Name == "Knife" then
                local handle = obj:FindFirstChild("Handle")
                if handle and (handle.Position - hrp.Position).Magnitude < 15 then
                    pcall(function()
                        firetouchinterest(hrp, handle, 0)
                        firetouchinterest(hrp, handle, 1)
                    end)
                end
            end
        end
    end
end)

-- ============================================
-- AUTO KILL
-- ============================================
task.spawn(function()
    while task.wait(0.15) do
        if not (S.CFG.KillAll or S.CFG.KillSheriff) then continue end
        if getMyRole() ~= "Murderer" then continue end

        local target = getTarget()
        if target and target.Character and LP.Character then
            local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local knife = LP.Character:FindFirstChild("Knife")
                or (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild("Knife"))
            if myHRP and tHRP and knife then
                myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2)
                pcall(function() knife:Activate() end)
            end
        end
    end
end)

-- ============================================
-- FLING (исправлен — тебя не кидает)
-- ============================================
local function safeFling(plr)
    if not plr or plr == LP then return end -- защита от самофлинга
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Проверка NetworkOwnership — флингим только если сервер отдал контроль
    local success, owner = pcall(function() return hrp:GetNetworkOwner() end)
    if success and owner == LP then
        -- Мы владеем — не флингаем (это вызвало бы "космос" для тебя)
        return
    end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 500, 0)  -- умеренная сила, не 9e9
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Parent = hrp
    task.delay(0.4, function()
        if bv then bv:Destroy() end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if S.CFG.FlingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and isAlive(plr) then safeFling(plr) end
            end
        end
        if S.CFG.FlingSelected and S.SelectedPlayer then
            safeFling(S.SelectedPlayer)
        end
    end
end)

-- ============================================
-- ANTI FLING (защита от чужого флинга)
-- ============================================
RunService.Heartbeat:Connect(function()
    if not S.CFG.AntiFling then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") then
            v:Destroy()
        end
    end
end)

-- ============================================
-- AUTO FARM COINS
-- ============================================
task.spawn(function()
    while task.wait(0.2) do
        if not S.CFG.FarmCoins then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money")) then
                if (obj.Position - hrp.Position).Magnitude < 50 then
                    pcall(function()
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                    end)
                end
            end
        end
    end
end)

-- ============================================
-- ESP (уменьшенный текст)
-- ============================================
local espCache = {}

local function removeESP(plr)
    local d = espCache[plr]
    if d then
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
        espCache[plr] = nil
    end
end

local function createESP(plr)
    local char = plr.Character
    if not char or espCache[plr] then return end

    local hl = Instance.new("Highlight")
    hl.Name = "MM2_ESP"
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.Adornee = char
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "MM2_Tag"
    bb.Size = UDim2.new(0, 80, 0, 20)  -- компактный
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextSize = 10  -- маленький фиксированный
    label.Font = Enum.Font.GothamBold
    label.TextScaled = false
    label.Parent = bb

    espCache[plr] = {hl = hl, bb = bb, label = label}
end

RunService.RenderStepped:Connect(function()
    if not S.CFG.PlayerESP and not S.CFG.RoleESP then
        for plr in pairs(espCache) do removeESP(plr) end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or not isAlive(plr) then
            removeESP(plr)
            continue
        end

        local role = getRole(plr)
        local show = S.CFG.PlayerESP
            or (S.CFG.RoleESP and (role == "Murderer" or role == "Sheriff"))

        if not show then
            removeESP(plr)
            continue
        end

        createESP(plr)
        local d = espCache[plr]
        if d and d.label then
            local color = role == "Murderer" and Color3.fromRGB(255, 50, 50)
                       or role == "Sheriff" and Color3.fromRGB(50, 150, 255)
                       or Color3.fromRGB(50, 255, 50)
            d.hl.FillColor = color
            d.hl.OutlineColor = color
            d.label.TextColor3 = color

            local txt = plr.Name
            if S.CFG.RoleESP then txt = txt .. " | " .. role end
            d.label.Text = txt
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)

-- ============================================
-- SPEED / JUMP
-- ============================================
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if S.CFG.SpeedEnabled then hum.WalkSpeed = S.CFG.SpeedValue end
    if S.CFG.JumpEnabled then
        hum.JumpPower = S.CFG.JumpValue
        hum.UseJumpPower = true
    end
end)

UserInputService.JumpRequest:Connect(function()
    if S.CFG.InfJump then
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

print("[Xs_KakoNINik MM2] Logic loaded")