--[[
    Blocks Farm V27 | Logic Part 3-1
    Автор: Xs_KakoNINik | TG: @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
-- Infinite Jump
-- ============================================
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ============================================
-- Anti-AFK
-- ============================================
task.spawn(function()
    while task.wait(60) do
        if CFG.AntiAFK then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
            end)
        end
    end
end)

-- ============================================
-- Speed / Jump / No Stun
-- ============================================
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
    if CFG.NoStun then
        hum.PlatformStand = false
        hum.Sit = false
    end
end)

-- ============================================
-- Hitbox Expander
-- ============================================
task.spawn(function()
    while task.wait(0.5) do
        if not CFG.HitboxExpander then continue end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                if obj.Name:match("^%d_%d_%d$") and not Players:GetPlayerFromCharacter(obj) then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function()
                                part.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
                                part.Transparency = 0.7
                                part.CanCollide = false
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- Mob ESP
-- ============================================
local MEO = {}
local Blacklist = {["Daily Quests"]=true,["Artifact Magician"]=true,["Shop"]=true,["Магазин"]=true,["Blacksmith"]=true}

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

-- ============================================
-- Player ESP
-- ============================================
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

-- ============================================
-- Runes ESP
-- ============================================
local REO = {}
local function removeRE(obj)
    if REO[obj] then pcall(function() REO[obj]:Destroy() end) REO[obj] = nil end
end

task.spawn(function()
    while task.wait(1) do
        if CFG.RunesESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local n = obj.Name:lower()
                    if n:find("rune") or n:find("руна") or n:find("fragment") then
                        if not REO[obj] then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(180, 80, 230)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            hl.Adornee = obj
                            hl.Parent = obj
                            REO[obj] = hl
                        end
                    end
                end
            end
        else
            for obj,_ in pairs(REO) do removeRE(obj) end
        end
    end
end)

-- ============================================
-- Boss Detect
-- ============================================
local lastBossNotif = 0
task.spawn(function()
    while task.wait(2) do
        if not CFG.BossDetect then continue end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("boss") then
                if tick() - lastBossNotif > 10 then
                    lastBossNotif = tick()
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "🔥 BOSS DETECT",
                            Text = "Появился босс: " .. obj.Name,
                            Duration = 5,
                        })
                    end)
                end
                break
            end
        end
    end
end)

-- ============================================
-- Подгрузка второй половины
-- ============================================
print("[BF27] Logic Part 3-1 loaded")

task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/bf27_logic2.lua", true))()
    end)
    if not ok then warn("[BF27] Logic2 load failed: " .. tostring(err)) end
end)