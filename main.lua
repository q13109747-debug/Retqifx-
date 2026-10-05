-- [[ SIMPLE X INTERFACE — PART 1 ]] --
if _G.HubLoaded then 
    _G.HubLoaded = false
    print("[Simple X]: Перезагрузка UI...")
end
_G.HubLoaded = true

-- Дефолтные настройки для связи с logic.lua
_G.AutoFarm = false
_G.KillAura = false
_G.NoCooldown = false
_G.GodMode = false
_G.BossDetect = false
_G.EspEnabled = false

_G.SelectedWorld = "3"
_G.SelectedLocation = "1"
_G.SelectedMob = "1"
_G.SelectedRune = "None"
_G.ToolName = "Pickaxe"

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SimpleX_OfficialUI"

-- Окно Simple X
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 330, 0, 450)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.Active = true
MainFrame.Draggable = true 

-- Неоновый кант
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(0, 255, 140) 
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 5)

-- Шапка (TopBar)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 5)

-- Иконка Simple X
local Icon = Instance.new("ImageLabel", TopBar)
Icon.Size = UDim2.new(0, 20, 0, 20)
Icon.Position = UDim2.new(0, 10, 0, 7)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://10618644158" 
Icon.ImageColor3 = Color3.fromRGB(0, 255, 140)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 35, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Simple X | Mining System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Зона прокрутки
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -16, 1, -45)
Scroll.Position = UDim2.new(0, 8, 0, 42)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 560)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)

local layout = Instance.new("UIListLayout", Scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Разделители категорий
local function CreateCategory(name)
    local header = Instance.new("TextLabel", Scroll)
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = "—— " .. string.upper(name) .. " ——"
    header.TextColor3 = Color3.fromRGB(100, 100, 110)
    header.Font = Enum.Font.Code
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Center
end

-- Переключатели (Toggles)
local function CreateToggle(text, globalVarName)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.BorderSizePixel = 0
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)

    local indicator = Instance.new("TextLabel", btn)
    indicator.Size = UDim2.new(0, 50, 1, 0)
    indicator.Position = UDim2.new(1, -60, 0, 0)
    indicator.BackgroundTransparency = 1
    indicator.Text = "OFF"
    indicator.TextColor3 = Color3.fromRGB(230, 70, 70)
    indicator.Font = Enum.Font.Code
    indicator.TextSize = 13
    indicator.TextXAlignment = Enum.TextXAlignment.Right

    btn.MouseButton1Click:Connect(function()
        _G[globalVarName] = not _G[globalVarName]
        if _G[globalVarName] then
            indicator.Text = "ON"
            indicator.TextColor3 = Color3.fromRGB(0, 255, 140)
            btn.BackgroundColor3 = Color3.fromRGB(24, 28, 26)
            if globalVarName == "EspEnabled" and _G.TriggerESP then _G.TriggerESP() end
        else
            indicator.Text = "OFF"
            indicator.TextColor3 = Color3.fromRGB(230, 70, 70)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
end

-- Поля ввода (Selectors)
local function CreateSelector(labelText, globalVarName)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.35, 0, 0.8, 0)
    box.Position = UDim2.new(0.65, 0, 0.1, 0)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    box.BorderSizePixel = 0
    box.Text = tostring(_G[globalVarName])
    box.TextColor3 = Color3.fromRGB(0, 255, 140)
    box.Font = Enum.Font.Code
    box.TextSize = 13
    
    local boxCorner = Instance.new("UICorner", box)
    boxCorner.CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function()
        _G[globalVarName] = box.Text
    end)
end

-- Сборка меню
CreateCategory("Main Farming")
CreateToggle("Auto Farm (Target)", "AutoFarm")
CreateToggle("Kill Aura (Brings)", "KillAura")
CreateToggle("No Cooldown (Fast Attack)", "NoCooldown")

CreateCategory("Target Settings")
CreateSelector("World:", "SelectedWorld")
CreateSelector("Location:", "SelectedLocation")
CreateSelector("Mob ID (1-4):", "SelectedMob")
CreateSelector("Rune Element:", "SelectedRune")
CreateSelector("Weapon Name:", "ToolName")

CreateCategory("Visuals & Utilities")
CreateToggle("Player ESP (Table Name)", "EspEnabled")
CreateToggle("God Mode (Self Heal)", "GodMode")
CreateToggle("Boss Detector", "BossDetect")

-- Кнопка SpawnPoint
local SpawnBtn = Instance.new("TextButton", Scroll)
SpawnBtn.Size = UDim2.new(1, 0, 0, 30)
SpawnBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 35)
SpawnBtn.BorderSizePixel = 0
SpawnBtn.Text = "  📍 Set Custom Spawn Point"
SpawnBtn.TextColor3 = Color3.fromRGB(180, 140, 255)
SpawnBtn.Font = Enum.Font.SourceSans
SpawnBtn.TextSize = 14
SpawnBtn.TextXAlignment = Enum.TextXAlignment.Left
local spCorner = Instance.new("UICorner", SpawnBtn)
spCorner.CornerRadius = UDim.new(0, 4)
SpawnBtn.MouseButton1Click:Connect(function()
    if _G.SetCustomSpawn then _G.SetCustomSpawn() end
end)

print("[Simple X UI]: Интерфейс загружен. Подгружаем твою логику...")

-- Ссылка на логику в твоем репозитории
loadstring(game:HttpGet("https://githubusercontent.com", true))()
