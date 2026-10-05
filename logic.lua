-- [[ SIMPLE X LOGIC CORE — PART 2 ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local DistanceToMob = 3

local function GetLeaderboardName(player)
    if player and player:IsA("Player") then
        return player.DisplayName or player.Name
    end
    return "Unknown"
end

-- === 1. ESP СИСТЕМА ===
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function applyEsp(char)
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("EspUI") then
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "EspUI"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 2, 0)
            
            local txt = Instance.new("TextLabel", billboard)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(0, 255, 140) 
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 14
            
            task.spawn(function()
                while char and char:Parent() and _G.EspEnabled and _G.HubLoaded do
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local tableName = GetLeaderboardName(player)
                        txt.Text = string.format("%s\n[HP: %.0f/%.0f]", tableName, hum.Health, hum.MaxHealth)
                    end
                    task.wait(0.1)
                end
                billboard:Destroy()
            end)
        end
    end
    
    if player.Character then applyEsp(player.Character) end
    player.CharacterAdded:Connect(applyEsp)
end

_G.TriggerESP = function()
    for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)

-- === 2. ФАРМ И КИЛЛ-АУРА ===
local function GetTargetMob()
    local targetName = string.format("%s_%s_%s", _G.SelectedWorld, _G.SelectedLocation, _G.SelectedMob)
    local closest = nil
    local dist = math.huge
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == targetName then
            if _G.SelectedRune ~= "None" and not obj.Name:lower():find(_G.SelectedRune:lower()) then
                continue
            end
            
            local part = obj:IsA("Part") and obj or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = part
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while _G.HubLoaded do
        task.wait(0.1)
        if not _G.AutoFarm or not LocalPlayer.Character then continue end
        
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChild(_G.ToolName) or LocalPlayer.Character:FindFirstChild(_G.ToolName)
        if tool and tool.Parent ~= LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
        end
        
        local target = GetTargetMob()
        if target and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, DistanceToMob, 0)
            if tool then tool:Activate() end
        end
    end
end)

task.spawn(function()
    while _G.HubLoaded do
        task.wait(0.05)
        if not _G.KillAura or not LocalPlayer.Character then continue end
        
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:match("^%d+_%d+_%d+$") and obj:IsA("BasePart") then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                if d <= 15 and tool then
                    tool:Activate()
                end
            end
        end
    end
end)

-- === 3. NO COOLDOWN ===
RunService.RenderStepped:Connect(function()
    if _G.NoCooldown and _G.HubLoaded and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- === 4. УТИЛИТЫ ===
task.spawn(function()
    while _G.HubLoaded do
        task.wait(2)
        if _G.BossDetect then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("boss") then
                    print("[⚠️ SIMPLE X DETECT]: Босс -> " .. obj.Name)
                end
            end
        end
    end
end)

task.spawn(function()
    while _G.HubLoaded do
        task.wait(1)
        if _G.GodMode and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

local CustomSpawnPoint = nil
_G.SetCustomSpawn = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        CustomSpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame
        print("[Simple X]: Точка спавна сохранена.")
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if CustomSpawnPoint and _G.HubLoaded then
        task.wait(0.5)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then hrp.CFrame = CustomSpawnPoint end
    end
end)

print("[Simple X Engine]: Логика ядра запущена!")
