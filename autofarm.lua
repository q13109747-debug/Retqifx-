-- AUTO FARM v2 | PART 1/2
-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character, Humanoid, Root

local function loadChar(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end

loadChar(LP.Character or LP.CharacterAdded:Wait())

local World = 1
local AutoFarm = false
local AutoAttack = false
local AutoRunes = false
local ESP = false

local FarmMode = "Fly"
local FarmSpeed = 50
local SpawnPoint = nil

local Runes = {
    ["Руна Йети"] = false,
    ["Руна Леденого Пастя"] = false,
    ["Руна Иллюзиониста"] = false
}

local Areas = workspace
    :WaitForChild("World")
    :WaitForChild("Areas")
    :WaitForChild("GuardAreas")

LP.CharacterAdded:Connect(function(char)
    loadChar(char)

    task.wait(0.5)

    if SpawnPoint and Root then
        Root.CFrame = SpawnPoint
    end

    if AutoFarm then
        task.spawn(function()
            task.wait(0.5)
            if SpawnPoint and Root then
                Root.CFrame = SpawnPoint
            end
        end)
    end
end)

local function getMobs()
    local result = {}

    for _, obj in ipairs(Areas:GetDescendants()) do
        if obj:IsA("Model") then
            local w, area, mob =
                obj.Name:match("^(%d+)_(%d+)_(%d+)$")

            if w and tonumber(w) == World then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                    or obj.PrimaryPart

                if hum and hrp and hum.Health > 0 then
                    table.insert(result, {
                        model = obj,
                        root = hrp,
                        area = tonumber(area),
                        mob = tonumber(mob)
                    })
                end
            end
        end
    end

    table.sort(result, function(a, b)
        if a.area == b.area then
            return a.mob < b.mob
        end
        return a.area < b.area
    end)

    return result
end

local function equipWeapon()
    if not Character or not Humanoid then return nil end

    local tool = Character:FindFirstChildOfClass("Tool")

    if tool then
        return tool
    end

    for _, item in ipairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            Humanoid:EquipTool(item)
            return item
        end
    end
end

local function attack()
    if not AutoAttack then return end

    local tool = equipWeapon()

    if tool then
        tool:Activate()
    end
end

local function moveTo(target)
    if not Root or not target then return end

    if FarmMode == "TP" then
        Root.CFrame = target.CFrame * CFrame.new(0, 0, 4)
        return
    end

    local pos = target.Position + Vector3.new(0, 0, 4)

    while AutoFarm
        and Root
        and target
        and target.Parent do

        local delta = pos - Root.Position
        local distance = delta.Magnitude

        if distance <= 2 then
            break
        end

        local dt = RunService.Heartbeat:Wait()
        local step = math.min(distance, FarmSpeed * dt)

        Root.CFrame = CFrame.new(
            Root.Position + delta.Unit * step,
            pos
        )
    end
end

local function findRune()
    for _, obj in ipairs(Areas:GetDescendants()) do
        if obj.Name == "Runes" then

            for _, rune in ipairs(obj:GetDescendants()) do
                if Runes[rune.Name] then

                    local part

                    if rune:IsA("BasePart") then
                        part = rune
                    elseif rune:IsA("Model") then
                        part = rune.PrimaryPart
                            or rune:FindFirstChildWhichIsA("BasePart")
                    end

                    if part then
                        return part
                    end
                end
            end
        end
    end
end

local function farmLoop()
    while AutoFarm do
        local mobs = getMobs()

        if #mobs > 0 then

            for _, data in ipairs(mobs) do
                if not AutoFarm then break end

                local model = data.model
                local root = data.root
                local hum = model:FindFirstChildOfClass("Humanoid")

                if root and hum and hum.Health > 0 then

                    repeat
                        if not AutoFarm then break end
                        if not root.Parent then break end

                        moveTo(root)
                        attack()

                        task.wait()

                        hum = model:FindFirstChildOfClass("Humanoid")

                    until not hum or hum.Health <= 0
                end
            end

        elseif AutoRunes then

            local rune = findRune()

            if rune then
                moveTo(rune)
                task.wait(0.5)
            else
                task.wait(1)
            end

        else
            task.wait(1)
        end
    end
end

local function setSpawn()
    if Root then
        SpawnPoint = Root.CFrame
    end
end

-- GUI

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoFarmV2"
Gui.ResetOnSpawn = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(250, 430)
Frame.Position = UDim2.new(0, 15, 0.5, -215)
Frame.BackgroundTransparency = 0.15
Frame.Parent = Gui

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Frame

local function button(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.Text = text
    b.TextSize = 14
    b.Parent = Frame
    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    return b
end

local worldButton

worldButton = button("World: 1", function(b)
    World += 1

    if World > 3 then
        World = 1
    end

    b.Text = "World: " .. World
end)

local farmButton

farmButton = button("Auto Farm: OFF", function(b)
    AutoFarm = not AutoFarm
    b.Text = "Auto Farm: " ..
        (AutoFarm and "ON" or "OFF")

    if AutoFarm then
        task.spawn(farmLoop)
    end
end)

local modeButton

modeButton = button("Mode: Fly", function(b)
    if FarmMode == "Fly" then
        FarmMode = "TP"
    else
        FarmMode = "Fly"
    end

    b.Text = "Mode: " .. FarmMode
end)

local speedButton

speedButton = button("Speed: 50", function(b)
    FarmSpeed += 10

    if FarmSpeed > 100 then
        FarmSpeed = 20
    end

    b.Text = "Speed: " .. FarmSpeed
end)

local attackButton

attackButton = button("Auto Attack: OFF", function(b)
    AutoAttack = not AutoAttack
    b.Text = "Auto Attack: " ..
        (AutoAttack and "ON" or "OFF")
end)

local runeButton

runeButton = button("Auto Runes: OFF", function(b)
    AutoRunes = not AutoRunes
    b.Text = "Auto Runes: " ..
        (AutoRunes and "ON" or "OFF")
end)

local spawnButton

spawnButton = button("Spawn Point: SET", function(b)
    setSpawn()
    b.Text = "Spawn Point: SAVED"
end)