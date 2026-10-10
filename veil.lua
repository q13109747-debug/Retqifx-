--[[
    VEIL Blox Fruits — PART 1
    Tabs: Info And Status, Farming, Setting, Fishing, Stats And Esp, Teleport
    by q13109747-debug
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "VEIL | Blox Fruits",
    LoadingTitle = "Загрузка Part 1...",
    LoadingSubtitle = "by q13109747-debug",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VEIL",
        FileName = "BloxConfig1"
    },
    KeySystem = false
})

getgenv().VEIL = getgenv().VEIL or {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ============================================
--              HELPERS
-- ============================================

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getTool()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Tool")
end

local function getBackpack() return LP:FindFirstChild("Backpack") end

local function notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t, Text = x, Duration = d or 3
        })
    end)
end

local function dist(a, b) return (a - b).Magnitude end

-- ============================================
--          MOB DATABASE
-- ============================================

local MobDB = {
    [1]={"Bandit","Monkey"},
    [15]={"Gorilla","Pirate"},
    [30]={"Brute","Desert Bandit"},
    [60]={"Snow Bandit","Snowman"},
    [90]={"Magma Ninja","Lava Pirate"},
    [120]={"Fire Fist","Fishman"},
    [180]={"Fishman Warrior","Sea Soldier"},
    [250]={"Fishman Lord","Swan Pirate"},
    [375]={"Military Soldier","Military Spy"},
    [450]={"Dangerous Prisoner","Prisoner"},
    [525]={"Raider","Mercenary"},
    [650]={"Galley Pirate","Zombie"},
    [750]={"Reborn Skeleton","Living Zombie"},
    [875]={"Demonic Soul","Posessed Mummy"},
    [950]={"Frost Bandit","Snow Trooper"},
    [1050]={"Winter Warrior","Snow Lurker"},
    [1200]={"Ice Admiral","Fajita"},
    [1350]={"Cursed Pirate","Reborn Skeleton"},
    [1500]={"Pirate Lord","Cursed Captain"}
}

local function getMobs(lvl)
    local best = 1
    for k,_ in pairs(MobDB) do
        if lvl >= k and k > best then best = k end
    end
    return MobDB[best] or MobDB[1]
end

-- ============================================
--          ATTACK SPAM
-- ============================================

local attackConn

local function startAttack()
    if attackConn then attackConn:Disconnect() end
    attackConn = RunService.Heartbeat:Connect(function()
        if not VEIL.AutoFarm and not VEIL.KillAura and not VEIL.AutoKillMob then return end
        local t = getTool()
        if t then t:Activate() end
    end)
end

local function stopAttack()
    if attackConn then
        attackConn:Disconnect()
        attackConn = nil
    end
end

-- ============================================
--          AUTO FARM BY LEVEL
-- ============================================

local function findMobByLevel()
    if not LP.Data or not LP.Data.Level then return nil end
    local lvl = LP.Data.Level.Value
    local names = getMobs(lvl)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local best, bestD = nil, math.huge
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h.Health > 0 then
                for _, n in pairs(names) do
                    if m.Name:lower():find(n:lower()) then
                        local d = dist(hrp.Position, m:GetPivot().Position)
                        if d < bestD then best, bestD = m, d end
                    end
                end
            end
        end
    end
    return best
end

local function findMobByName(name)
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h.Health > 0 and m.Name:lower():find(name:lower()) then
                local d = dist(hrp.Position, m:GetPivot().Position)
                if d < bestD then best, bestD = m, d end
            end
        end
    end
    return best
end

task.spawn(function()
    while task.wait(0.15) do
        if VEIL.AutoFarm then
            local mob = findMobByLevel()
            if mob then
                local hrp = getHRP()
                if hrp then
                    local pos = mob:GetPivot().Position
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0), pos)
                end
            end
        end
        if VEIL.AutoKillMob and VEIL.Mob then
            local mob = findMobByName(VEIL.Mob)
            if mob then
                local hrp = getHRP()
                if hrp then
                    local pos = mob:GetPivot().Position
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0), pos)
                end
            end
        end
    end
end)

-- ============================================
--       AUTO FARM (Main Tab)
-- ============================================

local MainTab = Window:CreateTab("Главная", 4483362458)

MainTab:CreateSection("Auto Farm")
MainTab:CreateToggle({
    Name = "Auto Farm (по уровню)",
    CurrentValue = false, Flag = "AF",
    Callback = function(v)
        VEIL.AutoFarm = v
        if v then startAttack() else stopAttack() end
    end
})
MainTab:CreateToggle({
    Name = "Fast Attack", CurrentValue = true, Flag = "FA",
    Callback = function(v) VEIL.FastAttack = v end
})
MainTab:CreateSlider({
    Name = "Attack Speed",
    Range = {0.01, 0.5}, Increment = 0.01, Suffix = "сек",
    CurrentValue = 0.05, Flag = "AS",
    Callback = function(v) VEIL.AttackSpeed = v end
})
MainTab:CreateToggle({
    Name = "Kill Aura", CurrentValue = false, Flag = "KA",
    Callback = function(v) VEIL.KillAura = v end
})

MainTab:CreateSection("Auto")
MainTab:CreateToggle({Name="Auto Haki", CurrentValue=false, Flag="AH",
    Callback=function(v) VEIL.AutoHaki = v end})
MainTab:CreateToggle({Name="Auto Eat", CurrentValue=true, Flag="AE",
    Callback=function(v) VEIL.AutoEat = v end})
MainTab:CreateToggle({Name="Auto Observation", CurrentValue=false, Flag="AO",
    Callback=function(v) VEIL.AutoObs = v end})

-- ============================================
--         TAB INFO AND STATUS
-- ============================================

local InfoTab = Window:CreateTab("Info And Status", 4483362458)

InfoTab:CreateSection("Статусы")
local statusLabels = {}
statusLabels.Mirage = InfoTab:CreateLabel("Mirage Island Status: X")
statusLabels.Kitsune = InfoTab:CreateLabel("Kitsune Island Status: X")
statusLabels.Prehistoric = InfoTab:CreateLabel("Prehistoric Island Status: X")
statusLabels.Frozen = InfoTab:CreateLabel("Frozen Dimension Status: X")
statusLabels.RipIndra = InfoTab:CreateLabel("Rip Indra Status: X")
statusLabels.DoughKing = InfoTab:CreateLabel("Dough King Status: X")
statusLabels.FullMoon = InfoTab:CreateLabel("Full Moon: 0/5")
statusLabels.LegendarySword = InfoTab:CreateLabel("Legendary Sword: Not Found")
statusLabels.Bones = InfoTab:CreateLabel("Bones: nil")
statusLabels.CakePrince = InfoTab:CreateLabel("Cake Prince Killed: 0")

InfoTab:CreateSection("Информация")
InfoTab:CreateLabel("VEIL Scripts = Blox Fruits Community")
InfoTab:CreateLabel("by q13109747-debug")
InfoTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/veil")
            notify("Discord", "Скопировано", 2)
        end
    end
})

-- ============================================
--              FARMING (ПОЛНЫЙ)
-- ============================================

local FarmTab = Window:CreateTab("Farming", 4483362458)

-- SELECT WEAPON
FarmTab:CreateSection("Select Weapon")
FarmTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Melee","Sword","Blox Fruit","Gun"},
    CurrentOption = {"Melee"}, Flag = "Weapon",
    Callback = function(o) VEIL.Weapon = o[1] end
})
FarmTab:CreateDropdown({
    Name = "UI Scale",
    Options = {"Small","Normal","Big"},
    CurrentOption = {"Normal"}, Flag = "UIScale",
    Callback = function(o) VEIL.UIScale = o[1] end
})

-- CHEST
FarmTab:CreateSection("Chest")
FarmTab:CreateToggle({Name="Auto Farm Chest", CurrentValue=false, Flag="AFC",
    Callback=function(v) VEIL.AutoFarmChest = v end})
FarmTab:CreateToggle({Name="Auto Chest Bypass", CurrentValue=false, Flag="ACB",
    Callback=function(v) VEIL.ChestBypass = v end})
FarmTab:CreateToggle({Name="Stop Items", CurrentValue=false, Flag="SI",
    Callback=function(v) VEIL.StopItems = v end})

-- FARM MOB
FarmTab:CreateSection("Farm Mob")
FarmTab:CreateDropdown({
    Name = "Select Mob",
    Options = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit",
               "Snow Bandit","Magma Ninja","Fishman","Military Soldier",
               "Dangerous Prisoner","Raider","Swan Pirate","Zombie",
               "Reborn Skeleton","Frost Bandit","Ice Admiral","Cursed Pirate"},
    CurrentOption = {"Bandit"}, Flag = "Mob",
    Callback = function(o) VEIL.Mob = o[1] end
})
FarmTab:CreateToggle({Name="Auto Kill Mob", CurrentValue=false, Flag="AKM",
    Callback=function(v)
        VEIL.AutoKillMob = v
        if v then startAttack() else stopAttack() end
    end})

-- ELITE
FarmTab:CreateSection("Farm Elite Hunter")
FarmTab:CreateLabel("Elites Process")
FarmTab:CreateLabel("Elite Spawn Status:")
FarmTab:CreateToggle({Name="Auto Farm Elite", CurrentValue=false, Flag="AFE",
    Callback=function(v) VEIL.AutoFarmElite = v end})
FarmTab:CreateToggle({Name="Auto Farm Elite + Hop", CurrentValue=false, Flag="AFEH",
    Callback=function(v) VEIL.AutoFarmEliteHop = v end})

-- CAKE
FarmTab:CreateSection("Farming Cake")
FarmTab:CreateLabel("Cake Princes")
FarmTab:CreateLabel("Killed: 0")
FarmTab:CreateToggle({Name="Auto Farm Cake Prince", CurrentValue=false, Flag="AFCP",
    Callback=function(v) VEIL.AutoFarmCakePrince = v end})
FarmTab:CreateToggle({Name="Accept Quests", CurrentValue=false, Flag="AQ2",
    Callback=function(v) VEIL.AcceptQuest = v end})
FarmTab:CreateToggle({Name="Auto Summon Cake Prince", CurrentValue=false, Flag="ASCP",
    Callback=function(v) VEIL.SummonCakePrince = v end})
FarmTab:CreateToggle({Name="Auto Dough King [Fully]", CurrentValue=false, Flag="ADKF",
    Callback=function(v) VEIL.DoughKingFull = v end})
FarmTab:CreateToggle({Name="Auto Farm Dough King", CurrentValue=false, Flag="AFDK",
    Callback=function(v) VEIL.AutoFarmDoughKing = v end})
FarmTab:CreateToggle({Name="Auto Farm Dough King + Hop", CurrentValue=false, Flag="AFDKH",
    Callback=function(v) VEIL.AutoFarmDoughKingHop = v end})

-- FARM ALL ISLAND
FarmTab:CreateSection("Farm All Island")
FarmTab:CreateDropdown({
    Name = "Select Island",
    Options = {"Pirates","Marine","Skylands","Desert","Frozen Village",
               "Magma Village","Fishman Island","Kingdom of Rose",
               "Green Zone","Graveyard","Cursed Ship","Ice Castle",
               "Haunted Castle","Hydra Island","Great Tree","Castle on the Sea"},
    CurrentOption = {"Pirates"}, Flag = "FarmIsland",
    Callback = function(o) VEIL.FarmIsland = o[1] end
})
FarmTab:CreateToggle({Name="Auto Farm All Island", CurrentValue=false, Flag="AFAI",
    Callback=function(v) VEIL.AutoFarmAllIsland = v end})

-- RIP INDRA
FarmTab:CreateSection("Farm Rip Indra")
FarmTab:CreateToggle({Name="Auto Attack Rip Indra", CurrentValue=false, Flag="AARI",
    Callback=function(v) VEIL.AttackRipIndra = v end})
FarmTab:CreateToggle({Name="Auto Unlocked Haki", CurrentValue=false, Flag="AUH",
    Callback=function(v) VEIL.UnlockHaki = v end})

-- BONES
FarmTab:CreateSection("Farming Bone")
FarmTab:CreateLabel("Bones")
FarmTab:CreateToggle({Name="Auto Farm Bone", CurrentValue=false, Flag="AFBo",
    Callback=function(v) VEIL.AutoFarmBone = v end})
FarmTab:CreateToggle({Name="Accept Quests", CurrentValue=false, Flag="AQ3",
    Callback=function(v) VEIL.AcceptQuestBone = v end})
FarmTab:CreateToggle({Name="Auto Soul Reaper", CurrentValue=false, Flag="ASR",
    Callback=function(v) VEIL.SoulReaper = v end})
FarmTab:CreateToggle({Name="Auto Random Bones", CurrentValue=false, Flag="ARB",
    Callback=function(v) VEIL.RandomBones = v end})
FarmTab:CreateToggle({Name="Auto Try Luck Gravestone", CurrentValue=false, Flag="ATLG",
    Callback=function(v) VEIL.TryLuckGrave = v end})
FarmTab:CreateToggle({Name="Auto Pray Gravestone", CurrentValue=false, Flag="APG",
    Callback=function(v) VEIL.PrayGrave = v end})

-- MATERIAL
FarmTab:CreateSection("Farm Material")
FarmTab:CreateDropdown({
    Name = "Choose Material",
    Options = {"Leather + Scrap Metal","Fish Tail","Angel Wings","Magic String",
               "Dragon Scale","Mystic Droplet","Radioactive Material"},
    CurrentOption = {"Leather + Scrap Metal"}, Flag = "Material",
    Callback = function(o) VEIL.Material = o[1] end
})
FarmTab:CreateToggle({Name="Auto Farm Materials", CurrentValue=false, Flag="AFMat",
    Callback=function(v) VEIL.AutoFarmMat = v end})

-- MASTERY
FarmTab:CreateSection("Farming Mastery")
FarmTab:CreateDropdown({
    Name = "Choose Island",
    Options = {"Cake","Pirate Island","Marine Fort","Colosseum",
               "Swan Mansion","Magma Village","Fountain City","Skylands"},
    CurrentOption = {"Cake"}, Flag = "MasteryIsland",
    Callback = function(o) VEIL.MasteryIsland = o[1] end
})
FarmTab:CreateToggle({Name="Auto Mastery Fruits", CurrentValue=false, Flag="AMF",
    Callback=function(v) VEIL.AutoMasteryFruit = v end})
FarmTab:CreateToggle({Name="Auto Mastery Gun", CurrentValue=false, Flag="AMG",
    Callback=function(v) VEIL.AutoMasteryGun = v end})
FarmTab:CreateToggle({Name="Auto Mastery All Sword", CurrentValue=false, Flag="AMS",
    Callback=function(v) VEIL.AutoMasterySword = v end})

-- ДОП
FarmTab:CreateSection("Auto Farm Дополнительно")
FarmTab:CreateToggle({Name="Auto Farm Magnet", CurrentValue=false, Flag="AFMag",
    Callback=function(v) VEIL.FarmMagnet = v end})
FarmTab:CreateToggle({Name="Auto Farm Nearest", CurrentValue=false, Flag="AFN",
    Callback=function(v) VEIL.FarmNearest = v end})
FarmTab:CreateToggle({Name="Auto Factory Raid", CurrentValue=false, Flag="AFR",
    Callback=function(v) VEIL.FactoryRaid = v end})
FarmTab:CreateToggle({Name="Auto Pirate Raid", CurrentValue=false, Flag="APR",
    Callback=function(v) VEIL.PirateRaid = v end})
FarmTab:CreateToggle({Name="Auto Farm Ectoplasm", CurrentValue=false, Flag="AFEcto",
    Callback=function(v) VEIL.FarmEctoplasm = v end})

-- BERRY
FarmTab:CreateSection("Collect Berry")
FarmTab:CreateToggle({Name="Auto Farm Berry", CurrentValue=false, Flag="AFBer",
    Callback=function(v) VEIL.FarmBerry = v end})
FarmTab:CreateToggle({Name="Auto Farm Berry + Hop", CurrentValue=false, Flag="AFBH",
    Callback=function(v) VEIL.FarmBerryHop = v end})

-- ============================================
--              STATS & ESP
-- ============================================

local StatsTab = Window:CreateTab("Stats And Esp", 4483362458)

StatsTab:CreateSection("Esp")
for _, esp in pairs({"Esp Berry","Esp Player","Esp Chest","Esp Fruit","Esp Island",
                     "Esp Flower","Esp Legendary Sword","Esp Haki Color",
                     "Esp Gear","Esp SeaEvent Island","Esp Advanced Dealer"}) do
    StatsTab:CreateToggle({
        Name = esp, CurrentValue = false,
        Flag = "E_" .. esp:gsub("%s",""),
        Callback = function(v) VEIL["E_"..esp] = v end
    })
end

StatsTab:CreateSection("Stats Upgrade")
StatsTab:CreateSlider({
    Name = "Stats Value",
    Range = {1, 100}, Increment = 1, Suffix = "очков",
    CurrentValue = 10, Flag = "StatsVal",
    Callback = function(v) VEIL.StatsValue = v end
})
for _, stat in pairs({"Auto Melee","Auto Swords","Auto Gun","Auto Blox Fruit","Auto Defense"}) do
    StatsTab:CreateToggle({
        Name = stat, CurrentValue = false,
        Flag = "S_" .. stat:gsub("%s",""),
        Callback = function(v) VEIL["S_"..stat] = v end
    })
end

-- ============================================
--              TELEPORT
-- ============================================

local TPTab = Window:CreateTab("Teleport", 4483362458)

TPTab:CreateSection("Travel - Island")
local islands = {"Starter Island","Marine Ford","Middle Town","Jungle","Pirate Village",
                 "Desert","Frozen Village","Marine Base","Skylands","Prison","Colosseum",
                 "Magma Village","Underwater City","Fishman Island","Kingdom of Rose",
                 "Green Zone","Graveyard","Snow Mountain","Hot and Cold","Cursed Ship",
                 "Ice Castle","Forgotten Island","Haunted Castle","Hydra Island",
                 "Great Tree","Castle on the Sea","Sea of Treats","Port Town"}
TPTab:CreateDropdown({
    Name = "Select Travelling",
    Options = islands, CurrentOption = {"Skylands"}, Flag = "Travel",
    Callback = function(o) VEIL.TravelIsland = o[1] end
})
TPTab:CreateToggle({Name="Auto Travel", CurrentValue=false, Flag="AT",
    Callback=function(v) VEIL.AutoTravel = v end})

TPTab:CreateSection("Travel - Worlds")
TPTab:CreateButton({Name="Travel East Blue (World 1)",
    Callback=function() notify("TP","East Blue",2) end})
TPTab:CreateButton({Name="Travel Dressrosa (World 2)",
    Callback=function() notify("TP","Dressrosa",2) end})
TPTab:CreateButton({Name="Travel Zou (World 3)",
    Callback=function() notify("TP","Zou",2) end})

TPTab:CreateSection("Travel - NPCs")
TPTab:CreateDropdown({
    Name = "Select NPCs",
    Options = {"Indra","Cousin","Bartilo","Swan","Hydra","Uzoth","Legendary Sword Dealer"},
    CurrentOption = {"Indra"}, Flag = "NPC",
    Callback = function(o) VEIL.NPC = o[1] end
})
TPTab:CreateToggle({Name="Auto Tween to NPC", CurrentValue=false, Flag="ATN",
    Callback=function(v) VEIL.AutoTweenNPC = v end})

TPTab:CreateSection("Travel - Portal")
TPTab:CreateDropdown({
    Name = "Select Portal",
    Options = {"Sky","Fountain","Pirate","Swan"},
    CurrentOption = {"Sky"}, Flag = "Portal",
    Callback = function(o) VEIL.Portal = o[1] end
})
TPTab:CreateButton({Name="requestEntrance",
    Callback=function() notify("TP","Portal request",2) end})

-- ============================================
--              SETTING
-- ============================================

local SetTab = Window:CreateTab("Setting", 4483362458)

SetTab:CreateSection("Settings / Configure")
SetTab:CreateSlider({
    Name = "Tween Speed",
    Range = {50, 500}, Increment = 5, Suffix = "studs/s",
    CurrentValue = 175, Flag = "TweenSpd",
    Callback = function(v) VEIL.TweenSpeed = v end
})
SetTab:CreateToggle({Name="Fast Attack", CurrentValue=false, Flag="FAS",
    Callback=function(v) VEIL.FastAttack = v end})
SetTab:CreateToggle({Name="Bring Mobs", CurrentValue=false, Flag="BM",
    Callback=function(v) VEIL.BringMobs = v end})
SetTab:CreateToggle({Name="Auto Hop Server with time", CurrentValue=false, Flag="AHS",
    Callback=function(v) VEIL.AutoHop = v end})
SetTab:CreateSlider({
    Name = "Hop Delay (Minutes)",
    Range = {1, 120}, Increment = 1, Suffix = "мин",
    CurrentValue = 30, Flag = "HopDelay",
    Callback = function(v) VEIL.HopDelay = v end
})

-- ============================================
--              FISHING
-- ================