--[[
    Xs_KakoNINik | MM2 Cheat
    Автор: Xs_KakoNINik
    TG: @Xs_KakoINik
    Всё в одном: UI + Logic
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

_G.MM2 = _G.MM2 or {}
local S = _G.MM2

S.CFG = S.CFG or {
    SpeedEnabled = false, SpeedValue = 100,
    JumpEnabled = false, JumpValue = 100,
    InfJump = false,
    KillAll = false,
    KillSheriff = false,
    SilentAim = false,
    AutoGrabGun = false,
    FlingAll = false,
    FlingSelected = false, FlingTarget = nil,
    AntiFling = false,
    FarmCoins = false,
    PlayerESP = false,
    RoleESP = false,
    HitChance = 100,
    FOV = 120,
}

S.SelectedPlayer = nil

local function formatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n) end
    if n < 1000 then return tostring(math.floor(n)) end
    local suf = {{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}
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

local function getMyRole()
    return getRole(LP)
end

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
-- SILENT AIM (только для Sheriff — метка в UI)
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
-- AUTO GRAB GUN (Sheriff / Murderer — берёт пушку/нож)
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
-- AUTO KILL (Murderer — телепорт + удар ножом)
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
-- FLING
-- ============================================
local function flingPlayer(plr)
    if not plr or not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(9e9, 9e9, 9e9)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    task.delay(0.5, function() if bv then bv:Destroy() end end)
end

task.spawn(function()
    while task.wait(1) do
        if S.CFG.FlingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and isAlive(plr) then flingPlayer(plr) end
            end
        end
        if S.CFG.FlingSelected and S.SelectedPlayer then
            flingPlayer(S.SelectedPlayer)
        end
    end
end)

-- ============================================
-- ANTI FLING
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
-- ESP
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
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
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
-- SPEED / JUMP / INF JUMP
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

-- ============================================
-- UI
-- ============================================
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

-- Стикер-иконка
local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0, 180, 0, 55)
iconFrame.Position = UDim2.new(0, 20, 0, 100)
iconFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
iconFrame.BorderSizePixel = 0
iconFrame.Active = true
iconFrame.Draggable = true
iconFrame.Parent = sg
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 22)
topBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
topBar.BorderSizePixel = 0
topBar.Parent = iconFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐯 Xs_KakoNINik"
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = topBar

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 30)
subLabel.Position = UDim2.new(0, 0, 0, 22)
subLabel.BackgroundTransparency = 1
subLabel.Text = "От Xs_KakoNINik\ntg@Xs_KakoINik"
subLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 10
subLabel.Parent = iconFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(1, 0, 1, 0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text = ""
iconBtn.Parent = iconFrame

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 340)
main.Position = UDim2.new(0, 220, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🐯 Xs_KakoNINik | MM2 Cheat"
titleText.TextColor3 = Color3.fromRGB(0, 0, 0)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -42)
sidebar.Position = UDim2.new(0, 5, 0, 37)
sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -145, 1, -42)
contentArea.Position = UDim2.new(0, 140, 0, 37)
contentArea.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
contentArea.BorderSizePixel = 0
contentArea.Parent = main
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local pages = {}

local function makePage(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 4
    c.CanvasSize = UDim2.new(0, 0, 0, 0)
    c.Visible = false
    c.Parent = contentArea

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.Parent = c
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        c.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
    end)

    pages[idx] = {button = b, content = c}
    b.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.button.BackgroundColor3 = (i == idx) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(38, 38, 48)
            p.button.TextColor3 = (i == idx) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            p.content.Visible = (i == idx)
        end
    end)
    return c
end

local MainTab = makePage("Main", 1)
local KillTab = makePage("Kill", 2)
local FlingTab = makePage("Fling", 3)
local ESPTab = makePage("ESP", 4)
local MiscTab = makePage("Misc", 5)
pages[1].button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
pages[1].button.TextColor3 = Color3.fromRGB(0, 0, 0)
pages[1].content.Visible = true

local function makeToggle(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -46, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bg.Parent = b
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 14, 0, 14)
    k.Position = UDim2.new(0, 2, 0.5, -7)
    k.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    k.Parent = bg
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        if s then
            bg.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
            k.Position = UDim2.new(1, -16, 0.5, -7)
        else
            bg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            k.Position = UDim2.new(0, 2, 0.5, -7)
        end
        callback(s)
    end)
end

local function makeSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 22)
    l.Position = UDim2.new(0, 10, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = name..": "..default
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bb = Instance.new("Frame")
    bb.Size = UDim2.new(1, -20, 0, 6)
    bb.Position = UDim2.new(0, 10, 0, 34)
    bb.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bb.Parent = f
    Instance.new("UICorner", bb).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    bar.Parent = bb
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function upd(input)
        local rx = math.clamp((input.Position.X - bb.AbsolutePosition.X) / bb.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rx)
        bar.Size = UDim2.new(rx, 0, 1, 0)
        l.Text = name..": "..v
        callback(v)
    end
    bb.InputBegan:Connect(function(input)
        if input.UserInputT