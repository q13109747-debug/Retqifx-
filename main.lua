-- [[ MULTI-FUNCTIONAL MINING HUB — MAIN GUI ]] --
if _G.HubLoaded then 
    _G.HubLoaded = false
    print("[Hub]: Перезапуск интерфейса...")
end
_G.HubLoaded = true

-- Глобальные переменные для связи с logic.lua
_G.AutoFarm = false
_G.KillAura = false
_G.NoCooldown = false
_G.GodMode = false
_G.BossDetect = false
_G.EspEnabled = false

_G.SelectedWorld = "3"
_G.SelectedLocation = "1"
_G.SelectedMob = "1"
_G.ToolName = "Pickaxe"

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "MiningHubGui"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Draggable = true 

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "⛏️ MINING AUTO-FARM HUB ⛏️"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.ScrollBarThickness = 5

local layout = Instance.new("UIListLayout", Scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local function CreateToggle(text, globalVarName)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    
    btn.MouseButton1Click:Connect(function()
        _G[globalVarName] = not _G[globalVarName]
        if _G[globalVarName] then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(55, 75, 55)
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            if globalVarName == "EspEnabled" and _G.TriggerESP then
                _G.TriggerESP() 
            end
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end

CreateToggle("🔥 Auto Farm (ТП + Клик)", "AutoFarm")
CreateToggle("⚡ No Cooldown (Атака без КД)", "NoCooldown")
CreateToggle("⚔️ Kill Aura (Радиус 15 блоков)", "KillAura")
CreateToggle("👁️ ESP (Имя из Таблицы + ХП)", "EspEnabled")
CreateToggle("🛡️ God Mode (Авто-хил)", "GodMode")
CreateToggle("🚨 Boss Detector", "BossDetect")

local SpawnBtn = Instance.new("TextButton", Scroll)
SpawnBtn.Size = UDim2.new(1, 0, 0, 35)
SpawnBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 90)
SpawnBtn.Text = "📍 Установить Точку Спавна здесь"
SpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnBtn.Font = Enum.Font.SourceSans
SpawnBtn.TextSize = 14
SpawnBtn.MouseButton1Click:Connect(function()
    if _G.SetCustomSpawn then _G.SetCustomSpawn() end
end)

local function CreateSelector(labelText, globalVarName)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.35, 0, 0.8, 0)
    box.Position = UDim2.new(0.65, 0, 0.1, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.Text = tostring(_G[globalVarName])
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 14
    
    box.FocusLost:Connect(function()
        _G[globalVarName] = box.Text
    end)
end

CreateSelector("Выбрать Мир (Напр: 3):", "SelectedWorld")
CreateSelector("Выбрать Локацию (1, 2, 3):", "SelectedLocation")
CreateSelector("Выбрать Моба (1, 2, 3, 4):", "SelectedMob")
CreateSelector("Название Кирки/Оружия:", "ToolName")

print("[Main]: Интерфейс готов. Подгружаем логику...")
loadstring(game:HttpGet("https://githubusercontent.com", true))()
