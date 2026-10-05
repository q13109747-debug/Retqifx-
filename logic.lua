local Logic = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local GuardAreas = Workspace:WaitForChild("World")
    :WaitForChild("Areas")
    :WaitForChild("GuardAreas")

Logic.Config = {
    World = 1,
    AutoFarm = false,
    AutoAttack = false,
    AutoRunes = false,
    SpawnPoint = false,
    PlayerESP = false,

    Mode = "TP",
    Speed = 50,

    Runes = {
        ["Руна Йети"] = false,
        ["Руна Леденого Пастя"] = false,
        ["Руна Иллюзиониста"] = false
    }
}

function Logic:GetCharacter()
    return LocalPlayer.Character
end

function Logic:GetRoot()
    local character = self:GetCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

function Logic:GetHumanoid()
    local character = self:GetCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Logic:GetMobs()
    local mobs = {}

    for _, object in ipairs(GuardAreas:GetDescendants()) do
        if object:IsA("Model") then
            local a, b, c = object.Name:match("^(%d+)_(%d+)_(%d+)$")

            if a and tonumber(a) == self.Config.World then
                local humanoid = object:FindFirstChildOfClass("Humanoid")
                local root = object:FindFirstChild("HumanoidRootPart")
                    or object.PrimaryPart

                if humanoid and root and humanoid.Health > 0 then
                    table.insert(mobs, object)
                end
            end
        end
    end

    return mobs
end

function Logic:EquipWeapon()
    local character = self:GetCharacter()
    local humanoid = self:GetHumanoid()

    if not character or not humanoid then
        return nil
    end

    local tool = character:FindFirstChildOfClass("Tool")

    if tool then
        return tool
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    if backpack then
        tool = backpack:FindFirstChildOfClass("Tool")

        if tool then
            humanoid:EquipTool(tool)
            return tool
        end
    end

    return nil
end

function Logic:Attack()
    if not self.Config.AutoAttack then
        return
    end

    local tool = self:EquipWeapon()

    if tool then
        pcall(function()
            tool:Activate()
        end)
    end
end

function Logic:MoveTo(target)
    local root = self:GetRoot()

    if not root or not target then
        return
    end

    if self.Config.Mode == "TP" then
        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    else
        local distance = (target.Position - root.Position).Magnitude
        local step = math.max(self.Config.Speed, 20) * 0.016

        if distance > 0 then
            root.CFrame = root.CFrame:Lerp(
                target.CFrame + Vector3.new(0, 3, 0),
                math.clamp(step / distance, 0, 1)
            )
        end
    end
end

function Logic:GetSelectedRunes()
    local result = {}

    local runes = GuardAreas:FindFirstChild("Runes", true)

    if not runes then
        return result
    end

    for _, object in ipairs(runes:GetDescendants()) do
        if self.Config.Runes[object.Name] then
            local part

            if object:IsA("BasePart") then
                part = object
            elseif object:IsA("Model") then
                part = object.PrimaryPart
                    or object:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                table.insert(result, part)
            end
        end
    end

    return result
end

function Logic:CollectRunes()
    if not self.Config.AutoRunes then
        return false
    end

    local runes = self:GetSelectedRunes()

    for _, rune in ipairs(runes) do
        self:MoveTo(rune)
        task.wait(0.15)
    end

    return #runes > 0
end

function Logic:FarmStep()
    if not self.Config.AutoFarm then
        return
    end

    local mobs = self:GetMobs()

    if #mobs > 0 then
        for _, mob in ipairs(mobs) do
            if not self.Config.AutoFarm then
                break
            end

            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            local root = mob:FindFirstChild("HumanoidRootPart")
                or mob.PrimaryPart

            if humanoid and root and humanoid.Health > 0 then
                self:MoveTo(root)
                self:Attack()
            end

            task.wait()
        end
    else
        self:CollectRunes()
    end
end

function Logic:SetWorld(world)
    self.Config.World = tonumber(world) or 1
end

function Logic:SetMode(mode)
    if mode == "TP" or mode == "Fly" then
        self.Config.Mode = mode
    end
end

function Logic:SetSpeed(speed)
    self.Config.Speed = math.clamp(tonumber(speed) or 50, 20, 100)
end

function Logic:Start()