-- ============================================================
-- ANON Blox Loot v2 — Часть 2/2
-- Combat loops / Auto Farm / Kill Aura / Loot / ESP / UI
-- ============================================================

-- ==== СПАМ-ЦИКЛ (быстрый визуал, честный урон) ====
task.spawn(function()
    while S.running do
        local tool = get_tool()
        if tool and CONFIG.attack_speed > 0 then
            if not tool.Enabled then tool.Enabled = true end
            if CONFIG.no_anim_lock then stop_idle_anims() end

            -- доворот к выбранному игроку (если включено)
            if CONFIG.auto_target_players then
                local plr = find_nearest_selected_player(CONFIG.player_range)
                if plr and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then face_to(hrp.Position) end
                end
            end

            pcall(function() tool:Activate() end)
        end
        task.wait(CONFIG.attack_interval)
    end
end)

-- ==== KILL AURA (только игроки) ====
task.spawn(function()
    while S.running do
        if CONFIG.kill_aura_players then
            local tool = get_tool()
            if tool then
                local players = find_all_players_in_range(CONFIG.ka_range)
                for _, plr in ipairs(players) do
                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        face_to(hrp.Position)
                        pcall(function() tool:Activate() end)
                        task.wait(0.02)
                    end
                end
            end
            task.wait(0.05)
        else
            task.wait(0.3)
        end
    end
end)

-- ==== AUTO FARM (мобы, walk/teleport) ====
-- Идёт к ближайшему мобу → бьёт → подбирает лут → к следующему
task.spawn(function()
    while S.running do
        if CONFIG.auto_farm and S.hrp and S.hum then
            local mob = find_nearest_mob(CONFIG.farm_range)
            if mob then
                local mob_hrp = mob:FindFirstChild("HumanoidRootPart")
                if mob_hrp then
                    local dist = (mob_hrp.Position - S.hrp.Position).Magnitude
                    local tool = get_tool()

                    -- телепорт к мобу, если выбран стиль teleport и моб далеко
                    if CONFIG.farm_style_teleport and dist > 10 then
                        pcall(function()
                            S.hrp.CFrame = CFrame.new(
                                mob_hrp.Position + Vector3.new(0, 3, 0),
                                mob_hrp.Position
                            )
                        end)
                    end

                    -- в радиусе удара — бьём
                    if dist <= 12 and tool then
                        face_to(mob_hrp.Position)
                        if not tool.Enabled then tool.Enabled = true end
                        if CONFIG.no_anim_lock then stop_idle_anims() end
                        pcall(function() tool:Activate() end)
                    end
                end
            end
            task.wait(0.05)
        else
            task.wait(0.3)
        end
    end
end)

-- ==== GOD MODE ====
task.spawn(function()
    while S.running do
        if CONFIG.god_mode and S.hum then
            pcall(function()
                S.hum.MaxHealth = math.huge
                S.hum.Health = math.huge
            end)
        end
        task.wait(0.5)
    end
end)

-- ==== WALKSPEED ====
task.spawn(function()
    while S.running do
        if S.hum then
            pcall(function() S.hum.WalkSpeed = CONFIG.walkspeed end)
        end
        task.wait(0.5)
    end
end)

-- ==== AUTO LOOT (магнит с фильтром) ====
task.spawn(function()
    while S.running do
        if CONFIG.auto_loot and S.hrp then
            local loot = find_nearest_loot()
            if loot then
                pcall(function()
                    if loot:IsA("BasePart") then
                        loot.CFrame = CFrame.new(S.hrp.Position)
                    else
                        loot:PivotTo(CFrame.new(S.hrp.Position))
                    end
                end)
            end
            task.wait(CONFIG.loot_delay)
        else
            task.wait(0.2)
        end
    end
end)

-- ==== PLAYER ESP ====
task.spawn(function()
    while S.running do
        if CONFIG.player_esp then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= S.plr and plr.Character and not S.esp_player[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 90, 90)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = plr.Character
                    S.esp_player[plr] = hl
                end
            end
            for plr, hl in pairs(S.esp_player) do
                if not plr.Character or not plr.Character.Parent then
                    pcall(function() hl:Destroy() end)
                    S.esp_player[plr] = nil
                end
            end
        else
            for plr, hl in pairs(S.esp_player) do
                pcall(function() hl:Destroy() end)
                S.esp_player[plr] = nil
            end
        end
        task.wait(0.5)
    end
end)

-- ==== LOOT ESP ====
task.spawn(function()
    while S.running do
        if CONFIG.loot_esp then
            for _, o in ipairs(workspace:GetDescendants()) do
                if is_loot(o) and not S.esp_loot[o] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(60, 255, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = o
                    S.esp_loot[o] = hl
                end
            end
            for o, hl in pairs(S.esp_loot) do
                if not o.Parent then
                    pcall(function() hl:Destroy() end)
                    S.esp_loot[o] = nil
                end
            end
        else
            for o, hl in pairs(S.esp_loot) do
                pcall(function() hl:Destroy() end)
                S.esp_loot[o] = nil
            end
        end
        task.wait(0.8)
    end
end)

-- ============================================================
-- UI
-- ============================================================

local function make_ui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ANON_BloxLoot"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 300, 0, 460)
    win.Position = UDim2.new(0, 20, 0, 60)
    win.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    title.BorderSizePixel = 0
    title.Text = "  ANON • Blox Loot"
    title.TextColor3 = Color3.fromRGB(220, 220, 240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = win
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -44)
    scroll.Position = UDim2.new(0, 8, 0, 38)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 1600)
    scroll.Parent = win
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    local function toggle(text, get, set)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.Parent = btn
        local ind = Instance.new("Frame")
        ind.Size = UDim2.new(0, 40, 0, 18)
        ind.Position = UDim2.new(1, -50, 0.5, -9)
        ind.BackgroundColor3 = get() and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(55, 55, 70)
        ind.BorderSizePixel = 0
        ind.Parent = btn
        Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
        btn.MouseButton1Click:Connect(function()
            set(not get())
            ind.BackgroundColor3 = get() and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(55, 55, 70)
        end)
    end

    local function slider(text, min, max, get, set)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -8, 0, 40)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        f.BorderSizePixel = 0
        f.Parent = scroll
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. " [" .. tostring(get()) .. "]"
        lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.Parent = f
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, 24)
        bar.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        bar.BorderSizePixel = 0
        bar.Parent = f
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((get() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local drag = false
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then drag = true end
        end)
        bar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
        task.spawn(function()
            while f.Parent do
                if drag then
                    local mp = game:GetService("UserInputService"):GetMouseLocation()
                    local rel = math.clamp((mp.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * rel)
                    set(val)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    lbl.Text = text .. " [" .. tostring(val) .. "]"
                end
                task.wait(0.03)
            end
        end)
    end

    local function header(text)
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(1, -8, 0, 24)
        h.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        h.BorderSizePixel = 0
        h.Text = "  " .. text
        h.TextColor3 = Color3.fromRGB(150, 180, 255)
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Font = Enum.Font.GothamBold
        h.TextSize = 12
        h.Parent = scroll
        Instance.new("UICorner", h).CornerRadius = UDim.new(0, 6)
    end

    -- COMBAT
    header("Combat")
    toggle("Auto Attack",          function() return CONFIG.attack_speed > 0 end, function(v) CONFIG.attack_speed = v and 150 or 0 end)
    slider("Attack Speed", 0, 200, function() return CONFIG.attack_speed end, function(v) CONFIG.attack_speed = v end)
    toggle("No Anim (fast swing)", function() return CONFIG.no_anim_lock end, function(v) CONFIG.no_anim_lock = v end)

    -- AUTO FARM
    header("Auto Farm")
    toggle("Auto Farm",            function() return CONFIG.auto_farm end, function(v) CONFIG.auto_farm = v end)
    toggle("Farm Style: Teleport", function() return CONFIG.farm_style_teleport end, function(v) CONFIG.farm_style_teleport = v end)
    slider("Farm Range", 50, 1000, function() return CONFIG.farm_range end, function(v) CONFIG.farm_range = v end)

    -- LOCATION / MOBS
    header("Farm Location")
    slider("World (1-3)", 1, 3, function() return CONFIG.farm_world end, function(v) CONFIG.farm_world = v end)
    slider("Location (1-4)", 1, 4, function() return CONFIG.farm_location end, function(v) CONFIG.farm_location = v end)
    local mobs_label = Instance.new("TextLabel")
    mobs_label.Size = UDim2.new(1, -8, 0, 20)
    mobs_label.BackgroundTransparency = 1
    mobs_label.Text = "  Мобы: нажми чтоб вкл/выкл"
    mobs_label.TextColor3 = Color3.fromRGB(180, 180, 200)
    mobs_label.TextXAlignment = Enum.TextXAlignment.Left
    mobs_label.Font = Enum.Font.Gotham
    mobs_label.TextSize = 11
    mobs_label.Parent = scroll

    local mob_buttons = {}
    local function rebuild_mob_list()
        for _, b in ipairs(mob_buttons) do b:Destroy() end
        mob_buttons = {}
        local w = CONFIG.farm_world
        local loc = CONFIG.farm_location
        local count = (loc == 1) and 5 or 4
        for m = 1, count do
            local mob_name = w .. "_" .. loc .. "_" .. m
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 26)
            btn.BackgroundColor3 = CONFIG.farm_mobs[mob_name] and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(30, 30, 40)
            btn.BorderSizePixel = 0
            btn.Text = "   " .. mob_name
            btn.TextColor3 = Color3.fromRGB(220, 220, 230)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                CONFIG.farm_mobs[mob_name] = not CONFIG.farm_mobs[mob_name]
                btn.BackgroundColor3 = CONFIG.farm_mobs[mob_name] and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(30, 30, 40)
            end)
            table.insert(mob_buttons, btn)
        end
    end
    rebuild_mob_list()
    -- обновляем список при смене локации/мира — каждые 0.5 сек проверяем
    local last_key = ""
    task.spawn(function()
        while win.Parent do
            local key = CONFIG.farm_world .. "_" .. CONFIG.farm_location
            if key ~= last_key then
                last_key = key
                rebuild_mob_list()
            end
            task.wait(0.5)
        end
    end)

    -- KILL AURA / TARGETING
    header("Players (PvP)")
    toggle("Kill Aura Players",    function() return CONFIG.kill_aura_players end, function(v) CONFIG.kill_aura_players = v end)
    slider("KA Range", 5, 200, function() return CONFIG.ka_range end, function(v) CONFIG.ka_range = v end)
    toggle("Auto Target Players",  function() return CONFIG.auto_target_players end, function(v) CONFIG.auto_target_players = v end)
    slider("Player Range", 10, 300, function() return CONFIG.player_range end, function(v) CONFIG.player_range = v end)

    -- PLAYER SELECTOR
    header("Select Players to Target")
    local pl_buttons = {}
    local function rebuild_players()
        for _, b in ipairs(pl_buttons) do b:Destroy() end
        pl_buttons = {}
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= S.plr then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 26)
                btn.BackgroundColor3 = CONFIG.target_players[plr] and Color3.fromRGB(90, 60, 130) or Color3.fromRGB(30, 30, 40)
                btn.BorderSizePixel = 0
                btn.Text = "   " .. plr.Name
                btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = scroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.MouseButton1Click:Connect(function()
                    CONFIG.target_players[plr] = not CONFIG.target_players[plr]
                    btn.BackgroundColor3 = CONFIG.target_players[plr] and Color3.fromRGB(90, 60, 130) or Color3.fromRGB(30, 30, 40)
                end)
                table.insert(pl_buttons, btn)
            end
        end
    end
    rebuild_players()
    game.Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        rebuild_players()
    end)
    game.Players.PlayerRemoving:Connect(function()
        task.wait(0.5)
        rebuild_players()
    end)

    -- LOOT
    header("Loot")
    toggle("Auto Loot",            function() return CONFIG.auto_loot end, function(v) CONFIG.auto_loot = v end)
    slider("Loot Range", 10, 300, function() return CONFIG.loot_range end, function(v) CONFIG.loot_range = v end)
    toggle("Pickup Runes",         function() return CONFIG.pickup_runes end, function(v) CONFIG.pickup_runes = v end)
    toggle("Pickup Materials",     function() return CONFIG.pickup_materials end, function(v) CONFIG.pickup_materials = v end)
    toggle("Pickup ALL",           function() return CONFIG.pickup_all end, function(v) CONFIG.pickup_all = v end)

    -- ESP
    header("ESP")
    toggle("Player ESP",           function() return CONFIG.player_esp end, function(v) CONFIG.player_esp = v end)
    toggle("Loot ESP",             function() return CONFIG.loot_esp end, function(v) CONFIG.loot_esp = v end)

    -- MOVEMENT
    header("Movement")
    toggle("God Mode",             function() return CONFIG.god_mode end, function(v) CONFIG.god_mode = v end)
    slider("WalkSpeed", 16, 120, function() return CONFIG.walkspeed end, function(v) CONFIG.walkspeed = v end)
end

make_ui()
print("[ANON] Часть 2 загружена. UI готов. Погнали.")