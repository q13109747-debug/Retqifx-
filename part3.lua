--[[
    Blocks Farm V25 | Part 3 - Target Tool
    Автор: Xs_KakoNINik | TG: @Xs_KakoINik
--]]

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local S = _G.BF
if not S or not S.CFG then
    warn("[Part 3] Run main.lua first!")
    return
end

local CFG = S.CFG

-- Находим окно и таб Target
local sg = nil
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "ScreenGui" then
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text == "🐯 Blocks Farm V25" then
                sg = gui
                break
            end
        end
    end
end

if not sg then
    warn("[Part 3] ScreenGui not found!")
    return
end

-- Ищем таб Target (по кнопке в сайдбаре)
local targetPage = nil
for _, obj in pairs(sg:GetDescendants()) do
    if obj:IsA("TextButton") and obj.Text == "  Target" then
        -- Ищем связанный ScrollingFrame
        local parent = obj.Parent.Parent
        for _, c in pairs(parent:GetDescendants()) do
            if c:IsA("ScrollingFrame") and c.Visible == false then
                -- Это может быть любой таб — ищем тот, что связан с Target
            end
        end
    end
end

-- Проще: находим contentArea и берём 4-й ScrollingFrame (Target)
local contentArea = nil
for _, obj in pairs(sg:GetDescendants()) do
    if obj:IsA("Frame") and obj.Size == UDim2.new(1,-135,1,-72) then
        contentArea = obj
        break
    end
end

if not contentArea then
    warn("[Part 3] ContentArea not found!")
    return
end

-- 4-й ScrollingFrame = Target tab
local targetTab = nil
local count = 0
for _, obj in pairs(contentArea:GetChildren()) do
    if obj:IsA("ScrollingFrame") then
        count = count + 1
        if count == 4 then
            targetTab = obj
            break
        end
    end
end

if not targetTab then
    warn("[Part 3] TargetTab not found!")
    return
end

-- ============================================
-- КНОПКИ Bottom / Helicopter
-- ============================================
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, -10, 0, 60)
modeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
modeFrame.Parent = targetTab
Instance.new("UICorner", modeFrame).CornerRadius = UDim.new(0, 6)

local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, -20, 0, 20)
modeTitle.Position = UDim2.new(0, 10, 0, 4)
modeTitle.BackgroundTransparency = 1
modeTitle.Text = "Режим: " .. CFG.TargetMode
modeTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
modeTitle.Font = Enum.Font.GothamBold
modeTitle.TextSize = 11
modeTitle.TextXAlignment = Enum.TextXAlignment.Left
modeTitle.Parent = modeFrame

local bottomBtn = Instance.new("TextButton")
bottomBtn.Size = UDim2.new(0.45, 0, 0, 26)
bottomBtn.Position = UDim2.new(0, 10, 0, 28)
bottomBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
bottomBtn.Text = "Bottom"
bottomBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
bottomBtn.Font = Enum.Font.GothamBold
bottomBtn.TextSize = 11
bottomBtn.Parent = modeFrame
Instance.new("UICorner", bottomBtn).CornerRadius = UDim.new(0, 4)

local heliBtn = Instance.new("TextButton")
heliBtn.Size = UDim2.new(0.45, 0, 0, 26)
heliBtn.Position = UDim2.new(0.5, 0, 0, 28)
heliBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
heliBtn.Text = "Helicopter"
heliBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
heliBtn.Font = Enum.Font.GothamBold
heliBtn.TextSize = 11
heliBtn.Parent = modeFrame
Instance.new("UICorner", heliBtn).CornerRadius = UDim.new(0, 4)

bottomBtn.MouseButton1Click:Connect(function()
    CFG.TargetMode = "Bottom"
    modeTitle.Text = "Режим: Bottom"
    bottomBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    bottomBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    heliBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    heliBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
end)

heliBtn.MouseButton1Click:Connect(function()
    CFG.TargetMode = "Helicopter"
    modeTitle.Text = "Режим: Helicopter"
    heliBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    heliBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    bottomBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bottomBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
end)

-- ============================================
-- СПИСОК ИГРОКОВ
-- ============================================
local targetListFrame = Instance.new("Frame")
targetListFrame.Size = UDim2.new(1, -10, 0, 160)
targetListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
targetListFrame.Parent = targetTab
Instance.new("UICorner", targetListFrame).CornerRadius = UDim.new(0, 6)

local targetTitle = Instance.new("TextLabel")
targetTitle.Size = UDim2.new(1, -20, 0, 20)
targetTitle.Position = UDim2.new(0, 10, 0, 4)
targetTitle.BackgroundTransparency = 1
targetTitle.Text = "Выбрать игрока:"
targetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
targetTitle.Font = Enum.Font.GothamBold
targetTitle.TextSize = 11
targetTitle.TextXAlignment = Enum.TextXAlignment.Left
targetTitle.Parent = targetListFrame

local targetList = Instance.new("ScrollingFrame")
targetList.Size = UDim2.new(1, -20, 1, -30)
targetList.Position = UDim2.new(0, 10, 0, 26)
targetList.BackgroundTransparency = 1
targetList.BorderSizePixel = 0
targetList.ScrollBarThickness = 3
targetList.CanvasSize = UDim2.new(0, 0, 0, 0)
targetList.Parent = targetListFrame

local targetLayout = Instance.new("UIListLayout")
targetLayout.Padding = UDim.new(0, 3)
targetLayout.Parent = targetList
targetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    targetList.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 10)
end)

local function refreshTargetList()
    for _, child in ipairs(targetList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            btn.Text = "  " .. plr.Name
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = targetList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            -- Подсветка если выбран
            if CFG.TargetPlayer == plr then
                btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            end

            btn.MouseButton1Click:Connect(function()
                CFG.TargetPlayer = plr
                for _, other in ipairs(targetList:GetChildren()) do
                    if other:IsA("TextButton") then
                        other.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
                        other.TextColor3 = Color3.fromRGB(220, 220, 220)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            end)
        end
    end
end

refreshTargetList()
Players.PlayerAdded:Connect(function() task.wait(1); refreshTargetList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshTargetList() end)

print("[Part 3] Target Tool loaded")