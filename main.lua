-- [[ SIMPLEXSERVER OFFICIAL REPLICATED UI — BLOX LOOT ]] --
if _G.HubLoaded then 
    _G.HubLoaded = false
    print("[Simple X]: Перезагрузка UI...")
end
_G.HubLoaded = true

-- Настройки по умолчанию
_G.AutoFarm = false
_G.FarmSpeed = 30
_G.AutoAttack = false
_G.AttackSpeed = 0
_G.NoCooldown = false
_G.NoAttackAnimation = false
_G.TargetTool = false
_G.SpawnPointTool = false
_G.LootESP = false
_G.PlayerESP = false
_G.PlayerStatsESP = false
_G.MonsterESP = false
_G.MonsterESPRange = 150
_G.SelectedEnemyTarget = "Chicken"

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SimpleX_BloxLootUI"

-- Главное окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Верхний мини-бар (Заголовок)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1

local Icon = Instance.new("ImageLabel", TopBar)
Icon.Size = UDim2.new(0, 16, 0, 16)
Icon.Position = UDim2.new(0, 12, 0, 7)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://10618644158"
Icon.ImageColor3 = Color3.fromRGB(150, 150, 160)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 35, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SimpleXServer | Blox Loot System"
Title.TextColor3 = Color3.fromRGB(150, 150, 160)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ЛЕВОЕ БОКОВОЕ МЕНЮ (Сайдбар вкладки)
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 130, 1, -35)
SideBar.Position = UDim2.new(0, 5, 0, 30)
SideBar.BackgroundTransparency = 1

local SideLayout = Instance.new("UIListLayout", SideBar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 2)

-- КОНТЕЙНЕР ДЛЯ СТРАНИЦ (Правая часть)
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -145, 1, -40)
PagesContainer.Position = UDim2.new(0, 140, 0, 35)
PagesContainer.BackgroundTransparency = 1

local allPages = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PagesContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 400)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    
    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 6)
    
    allPages[name] = page
    return page
end

-- Вкладки со скриншотов
local mainPage = CreatePage("Main")
local bossPage = CreatePage("Boss Farm")
local farmPage = CreatePage("Auto Farm")
local playerPage = CreatePage("Player")
local espPage = CreatePage("ESP")
local toolsPage = CreatePage("Tools")
local filterPage = CreatePage("Loot Filter")

mainPage.Visible = true -- Стартовая страница

-- Функция переключения вкладок
local function SelectTab(name)
    for pName, pFrame in pairs(allPages) do
        pFrame.Visible = (pName == name)
    end
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    btn.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)
end

CreateTabButton("Main")
CreateTabButton("Boss Farm")
CreateTabButton("Auto Farm")
CreateTabButton("Player")
CreateTabButton("ESP")
CreateTabButton("Tools")
CreateTabButton("Loot Filter")

-- КОНСТРУКТОР ТУМБЛЕРОВ (Toggles)
local function AddToggle(parent, text, globalVar)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    local cr = Instance.new("UICorner", frame) cr.CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 35, 0, 18)
    switch.Position = UDim2.new(1, -45, 0, 7)
    switch.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    local swCr = Instance.new("UICorner", switch) swCr.CornerRadius = UDim.new(0, 9)
    switch.Text = ""
    
    local dot = Instance.new("Frame", switch)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 2, 0, 2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local dotCr = Instance.new("UICorner", dot) dotCr.CornerRadius = UDim.new(0, 7)
    
    switch.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        if _G[globalVar] then
            switch.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            dot.Position = UDim2.new(1, -16, 0, 2)
            if globalVar == "EspEnabled" and _G.TriggerESP then _G.TriggerESP() end
        else
            switch.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            dot.Position = UDim2.new(0, 2, 0, 2)
        end
    end)
end

-- КОНСТРУКТОР СЛАЙДЕРОВ (Sliders)
local function AddSlider(parent, text, min, max, default, globalVar)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    local cr = Instance.new("UICorner", frame) cr.CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0.3, 0, 0, 20)
    valLbl.Position = UDim2.new(0.7, -10, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    valLbl.Font = Enum.Font.Code
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local slideBar = Instance.new("TextButton", frame)
    slideBar.Size = UDim2.new(1, -20, 0, 4)
    slideBar.Position = UDim2.new(0, 10, 0, 25)
    slideBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slideBar.Text = ""
    
    local slideFill = Instance.new("Frame", slideBar)
    slideFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    slideFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    
    slideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local barPos = slideBar.AbsolutePosition.X
            local barWidth = slideBar.AbsoluteSize.X
            local percentage = math.clamp((mousePos - barPos) / barWidth, 0, 1)
            
            slideFill.Size = UDim2.new(percentage, 0, 1, 0)
            local value = math.floor(min + (max - min) * percentage)
            valLbl.Text = tostring(value)
            _G[globalVar] = value
        end
    end)
end

-- НАПОЛНЕНИЕ СТРАНИЦ ПО СКРИНШОТАМ
-- Вкладка: Auto Farm (Скриншот 7)
AddToggle(farmPage, "Auto Farm", "AutoFarm")
AddSlider(farmPage, "Farm Speed", 1, 100, 30, "FarmSpeed")

-- Вкладка: Tools (Скриншот 5)
AddToggle(toolsPage, "Auto Attack", "AutoAttack")
AddSlider(toolsPage, "Attack Speed", 0, 10, 0, "AttackSpeed")
AddToggle(toolsPage, "No Cooldown", "NoCooldown")
AddToggle(toolsPage, "No Attack Animation (FE)", "NoAttackAnimation")

-- Вкладка: Tools Дополнительно (Скриншот 6)
AddToggle(toolsPage, "Target Tool [Risky]", "TargetTool")
AddToggle(toolsPage, "SpawnPoint Tool [Risky]", "SpawnPointTool")

-- Вкладка: ESP (Скриншот 4)
AddToggle(espPage, "Loot ESP", "LootESP")
AddToggle(espPage, "Player ESP", "PlayerESP")
AddToggle(espPage, "Player Stats (Level/HP/Rebirth)", "PlayerStatsESP")
AddToggle(espPage, "Monster ESP", "MonsterESP")
AddSlider(espPage, "Monster ESP Range", 10, 500, 150, "MonsterESPRange")

print("[Simple X UI]: Полная копия интерфейса успешно загружена!")
loadstring(game:HttpGet("https://githubusercontent.com", true))()
