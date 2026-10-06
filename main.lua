-- ============================================================
-- ANON Blox Loot v2 — Часть 1/2
-- Auto Attack + Auto Farm + Auto Target (players) + Kill Aura
-- + Auto Loot + Loot Filter (Rune/Material) + ESP + Movement
-- ============================================================

local CONFIG = {
    -- Combat
    attack_speed        = 150,
    attack_interval     = 0.005,
    no_anim_lock        = true,

    -- Auto Target (игроки, только выбранные)
    auto_target_players = false,
    player_range        = 150,
    target_players      = {},     -- {[player]=true}

    -- Kill Aura (игроки, все в радиусе)
    kill_aura_players   = false,
    ka_range            = 40,

    -- Auto Farm (мобы)
    auto_farm           = false,
    farm_world          = 1,
    farm_location       = 1,
    farm_mobs           = {},     -- {["1_1_1"]=true, ...}
    farm_style          = "walk", -- "walk" | "teleport"
    farm_style_teleport = false,  -- переключается тумблером
    farm_range          = 500,

    -- Loot
    auto_loot           = true,
    loot_range          = 80,
    loot_delay          = 0.05,
    pickup_runes        = true,
    pickup_materials    = true,
    pickup_all          = false,

    -- ESP
    player_esp          = false,
    loot_esp            = false,

    -- Movement
    walkspeed           = 25,
    god_mode            = false,
}

-- ==== МОБЫ: схема <мир>_<локация>_<моб> ====
local MOB_SET = {}
for w = 1, 3 do
    for m = 1, 5 do MOB_SET[w .. "_1_" .. m] = true end
    for loc = 2, 4 do
        for m = 1, 4 do MOB_SET[w .. "_" .. loc .. "_" .. m] = true end
    end
end

-- ==== СОСТОЯНИЕ ====
local S = {
    running = true,
    plr = game.Players.LocalPlayer,
    char = nil, hum = nil, hrp = nil,
    esp_player = {}, esp_loot = {},
}

task.spawn(function()
    while S.running do
        S.char = S.plr.Character or S.plr.CharacterAdded:Wait()
        S.hum  = S.char:WaitForChild("Humanoid")
        S.hrp  = S.char:WaitForChild("HumanoidRootPart")
        S.plr.CharacterAdded:Wait()
        task.wait(0.3)
    end
end)

-- ==== УТИЛИТЫ ====
local function get_tool()
    if S.char then return S.char:FindFirstChildOfClass("Tool") end
end

local function stop_idle_anims()
    if not S.hum then return end
    local a = S.hum:FindFirstChildOfClass("Animator")
    if not a then return end
    for _, t in ipairs(a:GetPlayingAnimationTracks()) do
        local n = t.Name
        if n == "MeleeAttack" then
            pcall(function() t:AdjustSpeed(50) end)
        elseif n == "Animation1" or n == "ToolNoneAnim" then
            pcall(function() t:AdjustSpeed(0) end)
            pcall(function() t:Stop(0) end)
        end
    end
end

local function face_to(target_pos)
    if not S.hrp then return end
    local from = S.hrp.Position
    local dir = Vector3.new(target_pos.X - from.X, 0, target_pos.Z - from.Z)
    if dir.Magnitude < 0.01 then return end
    S.hrp.CFrame = CFrame.lookAt(from, from + dir.Unit)
end

-- ==== ПОИСК МОБОВ ====
local function is_mob(o)
    if not o or not o.Parent or not MOB_SET[o.Name] then return false end
    if not o:IsA("Model") then return false end
    local h = o:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    return o:FindFirstChild("HumanoidRootPart") ~= nil
end

local function is_target_mob(o)
    if not is_mob(o) then return false end
    -- если список пустой — бьём всех мобов выбранной локации
    local sel = CONFIG.farm_mobs
    local has_any = false
    for _ in pairs(sel) do has_any = true; break end
    if not has_any then return true end
    return sel[o.Name] == true
end

local function find_nearest_mob(range)
    if not S.hrp then return nil end
    local pos = S.hrp.Position
    local best, bd = nil, range or CONFIG.farm_range
    for _, o in ipairs(workspace:GetDescendants()) do
        if is_target_mob(o) then
            local hrp = o:FindFirstChild("HumanoidRootPart")
            local d = (hrp.Position - pos).Magnitude
            if d < bd then best, bd = o, d end
        end
    end
    return best
end

local function find_all_target_mobs(range)
    if not S.hrp then return {} end
    local pos = S.hrp.Position
    local out = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if is_target_mob(o) then
            local hrp = o:FindFirstChild("HumanoidRootPart")
            if (hrp.Position - pos).Magnitude <= range then
                table.insert(out, o)
            end
        end
    end
    return out
end

-- ==== ПОИСК ИГРОКОВ ====
local function is_enemy_player(plr)
    if plr == S.plr then return false end
    if not plr.Character then return false end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    return plr.Character:FindFirstChild("HumanoidRootPart") ~= nil
end

local function find_nearest_selected_player(range)
    if not S.hrp then return nil end
    local pos = S.hrp.Position
    local best, bd = nil, range or CONFIG.player_range
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if is_enemy_player(plr) and CONFIG.target_players[plr] then
            local hrp = plr.Character.HumanoidRootPart
            local d = (hrp.Position - pos).Magnitude
            if d < bd then best, bd = plr, d end
        end
    end
    return best
end

local function find_all_players_in_range(range)
    if not S.hrp then return {} end
    local pos = S.hrp.Position
    local out = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if is_enemy_player(plr) then
            local hrp = plr.Character.HumanoidRootPart
            if (hrp.Position - pos).Magnitude <= range then
                table.insert(out, plr)
            end
        end
    end
    return out
end

-- ==== ПОИСК ЛУТА ====
local function loot_pass_filter(o)
    if CONFIG.pickup_all then return true end
    local name = o.Name:lower()
    if CONFIG.pickup_runes and name:find("rune") then return true end
    if CONFIG.pickup_materials and name:find("material") then return true end
    -- если оба фильтра выключены — ничего не подбираем
    if not CONFIG.pickup_runes and not CONFIG.pickup_materials then return false end
    return false
end

local function is_loot(o)
    if not o or not o.Parent then return false end
    if not (o:FindFirstChildOfClass("ProximityPrompt") or o:FindFirstChildOfClass("ClickDetector")) then
        return false
    end
    return loot_pass_filter(o)
end

local function find_nearest_loot()
    if not S.hrp then return nil end
    local pos = S.hrp.Position
    local best, bd = nil, CONFIG.loot_range
    for _, o in ipairs(workspace:GetDescendants()) do
        if is_loot(o) then
            local p = o:IsA("BasePart") and o.Position or o:GetPivot().Position
            local d = (p - pos).Magnitude
            if d < bd then best, bd = o, d end
        end
    end
    return best
end

print("[ANON] Часть 1 загружена")

local ok, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/main.lua", true))()
end)
if not ok then warn("ОШИБКА: " .. tostring(err)) end