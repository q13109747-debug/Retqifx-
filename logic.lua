-- logic.lua
-- ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ADMINS = {
    [123456789] = true, -- ЗАМЕНИ на свой UserId
}

local remote = ReplicatedStorage:FindFirstChild("AdminControl")

if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "AdminControl"
    remote.Parent = ReplicatedStorage
end

local function isAdmin(player)
    return ADMINS[player.UserId] == true
end

local function setGodMode(player, enabled)
    if not isAdmin(player) then
        return
    end

    player:SetAttribute("AdminGodMode", enabled)

    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if enabled then
        humanoid:SetAttribute("AdminGodMode", true)
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid:SetAttribute("AdminGodMode", false)
        humanoid.MaxHealth = 100
        humanoid.Health = math.min(humanoid.Health, 100)
    end
end

local function setSafeZone(player, enabled)
    if not isAdmin(player) then
        return
    end

    player:SetAttribute("AdminSafeZone", enabled)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("AdminMode", isAdmin(player))
    player:SetAttribute("AdminGodMode", false)
    player:SetAttribute("AdminSafeZone", false)

    player.CharacterAdded:Connect(function()
        task.wait(0.5)

        if player:GetAttribute("AdminGodMode") then
            setGodMode(player, true)
        end
    end)
end)

remote.OnServerEvent:Connect(function(player, action, value)
    if not isAdmin(player) then
        return
    end

    if action == "GodMode" then
        setGodMode(player, value == true)

    elseif action == "SafeZone" then
        setSafeZone(player, value == true)
    end
end)