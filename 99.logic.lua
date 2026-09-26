--[[
    99 Nights | Part 2 - Logic
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local S = _G.N99
if not S or not S.CFG then
    warn("[Part 2] Run Part 1 first!")
    return
end

local CFG = S.CFG
local UI = S._UI

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- God Mode + Speed
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CFG.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
    if CFG.SpeedEnabled then hum.WalkSpeed = CFG.SpeedValue end
end)

-- Auto Tree Farm
task.spawn(function()
    while task.wait(0.4) do
        if not CFG.AutoTreeFarm then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("trunk") or n:find("tree") or n:find("log") then
                    if (obj.Position - hrp.Position).Magnitude < 50 then
                        pcall(function()
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                        end)
                    end
                end
            end
        end
    end
end)

-- Auto Fire (подбор к костру)
task.spawn(function()
    while task.wait(0.4) do
        if not CFG.AutoFire then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("campfire") or n:find("fire") or n:find("log") then
                    if (obj.Position - hrp.Position).Magnitude < 100 then
                        pcall(function()
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                        end)
                    end
                end
            end
        end
    end
end)

-- Auto Eat
task.spawn(function()
    while task.wait(1) do
        if not CFG.AutoEat then continue end
        local char = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        if not char or not bp then continue end
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("food") or n:find("meat") or n:find("fish") then
                    pcall(function() tool.Parent = char end)
                    task.wait(0.1)
                    pcall(function() tool:Activate() end)
                    break
                end
            end
        end
    end
end)

-- Kill Aura
task.spawn(function()
    while task.wait(0.3) do
        if not CFG.KillAura then continue end
        local char = LP.Character
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end
end)

-- Bring Stuff (притянуть всё)
task.spawn(function()
    while task.wait(0.5) do
        if not CFG.BringStuff then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
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
end)

-- ТП к ребёнку
if UI.tpKidBtn then
    UI.tpKidBtn.MouseButton1Click:Connect(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == CFG.SelectedKid then
                local target = obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                    or (obj:IsA("BasePart") and obj)
                if target then
                    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                    return
                end
            end
        end
    end)
end

-- ТП к Костру
if UI.tpCampBtn then
    UI.tpCampBtn.MouseButton1Click:Connect(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("campfire") or n:find("fire") then
                if obj:IsA("BasePart") then
                    hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                    return
                end
            end
        end
    end)
end

print("[99 Nights] Logic loaded | moonklice:3")