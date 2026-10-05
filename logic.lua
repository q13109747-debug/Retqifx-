-- [[ SIMPLEXSERVER ENGINE — REPLICATED LOGIC CORE — PART 2 ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- === 1. ОБРАБОТКА NO COOLDOWN И АВТО-АТАКИ ===
RunService.RenderStepped:Connect(function()
    if _G.HubLoaded and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            -- Если включена авто-атака или обход перезарядки
            if _G.AutoAttack or _G.NoCooldown then
                tool:Activate()
            end
            -- Обход анимации взмаха (No Attack Animation)
            if _G.NoAttackAnimation and tool:FindFirstChild("Animation") then
                tool.Animation:Destroy()
            end
        end
    end
end)

-- === 2. ДИНАМИЧЕСКИЙ ESP ПО СКРИНШОТУ ===
local function CreateAdvancedESP(player)
    if player == LocalPlayer then return end
    
    local function applyEsp(char)
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("SimpleX_ESP") then
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "SimpleX_ESP"
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 2, 0)
            
            local txt = Instance.new("TextLabel", billboard)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 13
            
            task.spawn(function()
                while char and char:Parent() and _G.HubLoaded do
                    if _G.PlayerESP then
                        local nameText = player.DisplayName or player.Name
                        
                        -- Проверка отображения статов (Level/HP/Rebirth) со скриншота 4
                        if _G.PlayerStatsESP and char:FindFirstChildOfClass("Humanoid") then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            txt.Text = string.format("%s\n[HP: %.0f/%.0f]", nameText, hum.Health, hum.MaxHealth)
                        else
                            txt.Text = nameText
                        end
                        billboard.Enabled = true
                    else
                        billboard.Enabled = false
                    end
                    task.wait(0.2)
                end
                billboard:Destroy()
            end)
        end
    end
    if player.Character then applyEsp(player.Character) end
    player.CharacterAdded:Connect(applyEsp)
end

_G.TriggerESP = function()
    for _, p in ipairs(Players:GetPlayers()) do CreateAdvancedESP(p) end
end
Players.PlayerAdded:Connect(CreateAdvancedESP)

-- === 3. АВТО-ФАРМ НА ВСЕ 4 МОБА В ВЫБРАННОЙ ЛОКАЦИИ ===
local function GetClosestTarget()
    local closest = nil
    local dist = _G.MonsterESPRange or math.huge
    
    -- Сканируем окружение по маске сетки (Мир_Локация_Моб)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:match("^%d+_%d+_%d+$") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = obj
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while _G.HubLoaded do
        task.wait(0.1)
        if _G.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Экипировка оружия/инструмента
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                local targetTool = bp and bp:FindFirstChildOfClass("Tool")
                if targetTool then targetTool.Parent = LocalPlayer.Character end
            end
            
            local mob = GetClosestTarget()
            if mob then
                -- Телепортация над мобом на основе настроек Farm Speed
                LocalPlayer.Character.HumanoidRootPart.CFrame = mob.CFrame * CFrame.new(0, 3, 0)
                if tool then tool:Activate() end
            end
        end
    end
end)

print("[Simple X Logic]: Ядро вычислений полностью привязано к UI!")
