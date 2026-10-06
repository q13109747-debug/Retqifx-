local Logic = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

Logic.Config = {
    World = 1,

    AutoFarm = false,
    AutoAttack = false,
    AutoEquip = false,

    AutoRunes = false,

    Mode = "TP",
    Speed = 50,

    GodMode = false,
    SafeZone = false,
    PlayerESP = false,

    Runes = {
        ["Руна Йети"] = false,
        ["Руна Леденого Пастя"] = false,
        ["Руна Иллюзиониста"] = false
    }
}

function Logic:IsAdmin()
    return Player:GetAttribute("AdminMode") == true
end

function Logic:GetCharacter()
    return Player.Character
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
    local result = {}

    local world = Workspace:FindFirstChild("World")
    local areas = world and world:FindFirstChild("Areas")
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")

    if not guardAreas then
        return result
    end

    for _, object in ipairs(guardAreas:GetDescendants()) do
        if object:IsA("Model") then
            local w = object.Name:match("^(%d+)_")

            if tonumber(w) == self.Config.World then
                local humanoid = object:FindFirstChildOfClass("Humanoid")
                local root = object:FindFirstChild("HumanoidRootPart")
                    or object.PrimaryPart

                if humanoid and root and humanoid.Health > 0 then
                    table.insert(result, object)
                end
            end
        end
    end

    return result
end

function Logic:EquipWeapon()
    if not self.Config.AutoEquip then
        return
    end

    local character = self:GetCharacter()
    local humanoid = self:GetHumanoid()

    if not character or not humanoid then
        return
    end

    if character:FindFirstChildOfClass("Tool") then
        return character:FindFirstChildOfClass("Tool")
    end

    local backpack = Player:FindFirstChildOfClass("Backpack")

    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")

        if tool then
            humanoid:EquipTool(tool)
            return tool
        end
    end
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
        return
    end

    local distance = (target.Position - root.Position).Magnitude

    if distance <= 1 then
        return
    end

    local step = math.clamp(self.Config.Speed / 100, 0.05, 1)

    root.CFrame = root.CFrame:Lerp(
        target.CFrame + Vector3.new(0, 3, 0),
        step
    )
end

function Logic:GetRunes()
    local result = {}

    local world = Workspace:FindFirstChild("World")
    local areas = world and world:FindFirstChild("Areas")
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")

    if not guardAreas then
        return result
    end

    local runes = guardAreas:FindFirstChild("Runes", true)

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
        return
    end

    for _, rune in ipairs(self:GetRunes()) do
        if not self.Config.AutoFarm then
            break
        end

        self:MoveTo(rune)
        task.wait(0.15)
    end
end

function Logic:FarmStep()
    if not self.Config.AutoFarm then
        return
    end

    local mobs = self:GetMobs()

    if #mobs == 0 then
        self:CollectRunes()
        return
    end

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
end

function Logic:SetWorld(world)
    world = tonumber(world)

    if world and world >= 1 and world <= 3 then
        self.Config.World = world
    end
end

function Logic:SetMode(mode)
    if mode == "TP" or mode == "Fly" then
        self.Config.Mode = mode
    end
end

function Logic:SetSpeed(speed)
    self.Config.Speed = math.clamp(
        tonumber(speed) or 50,
        20,
        100
    )
end

function Logic:SetGodMode(value)
    if self:IsAdmin() then
        self.Config.GodMode = value
    end
end

function Logic:SetSafeZone(value)
    if self:IsAdmin() then
        self.Config.SafeZone = value
    end
end

function Logic:Start()
    if self.Running then
        return
    end

    self.Running = true

    task.spawn(function()
        while self.Running do
            self:FarmStep()
            task.wait(0.05)
        end
    end)
end

function Logic:Stop()
    self.Running = false
end

function Logic:Init()
    self:Start()
end

return Logic