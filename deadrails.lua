--[[
    Dead Rails | Auto Bond Farm (Base)
    Автор: Xs_KakoNINik
    is you noob от автора:3
    telegram:3 @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- Настройки
local Config = {
    AutoBondFarm = false,
    BringRadius = 150,
    TPToBonds = false,
}

-- ===== UI =====
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 190)
main.Position = UDim2.new(0.5, -150, 0.5, -95)
main.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
title.Text = "🚂 Dead Rails | Xs_KakoNINik"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -10, 0, 16)
subtitle.Position = UDim2.new(0, 5, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "is you noob от автора:3"
subtitle.TextColor3 = Color3.fromRGB(200, 180, 220)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.Parent = main

local tg = Instance.new("TextLabel")
tg.Size = UDim2.new(1, -10, 0, 16)
tg.Position = UDim2.new(0, 5, 0, 42)
tg.BackgroundTransparency = 1
tg.Text = "telegram:3 @Xs_KakoINik"
tg.TextColor3 = Color3.fromRGB(180, 130, 230)
tg.Font = Enum.Font.GothamBold
tg.TextSize = 10
tg.Parent = main

local function makeToggle(name, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.BackgroundColor3 = s and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(50, 40, 60)
        callback(s)
    end)
end

makeToggle("Auto Bond Farm", 65, function(v) Config.AutoBondFarm = v end)
makeToggle("TP to Bonds", 100, function(v) Config.TPToBonds = v end)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -10, 0, 20)
footer.Position = UDim2.new(0, 5, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "is you noob от автора:3 | telegram:3 @Xs_KakoINik"
footer.TextColor3 = Color3.fromRGB(180, 130, 230)
footer.Font = Enum.Font.GothamBold
footer.TextSize = 9
footer.Parent = main

-- ===== ЛОГИКА =====
local function findBonds()
    local bonds = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("bond") or n:find("treasury") or n:find("облигац") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos then
                    table.insert(bonds, {obj = obj, pos = pos})
                end
            end
        end
    end
    return bonds
end

task.spawn(function()
    while task.wait(0.5) do
        if not Config.AutoBondFarm then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, bond in ipairs(findBonds()) do
            local dist = (bond.pos - hrp.Position).Magnitude
            if dist < Config.BringRadius then
                pcall(function()
                    if bond.obj:IsA("BasePart") then
                        firetouchinterest(hrp, bond.obj, 0)
                        firetouchinterest(hrp, bond.obj, 1)
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if not Config.TPToBonds then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local bonds = findBonds()
        if #bonds > 0 then
            local closest = bonds[1]
            for _, b in ipairs(bonds) do
                if (b.pos - hrp.Position).Magnitude < (closest.pos - hrp.Position).Magnitude then
                    closest = b
                end
            end
            hrp.CFrame = CFrame.new(closest.pos + Vector3.new(0, 3, 0))
        end
    end
end)

print("[Dead Rails] Loaded | Xs_KakoNINik | is you noob от автора:3")