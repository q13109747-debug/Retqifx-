local P=game:GetService("Players")
local RS=game:GetService("RunService")
local U=game:GetService("UserInputService")
local WS=game:GetService("Workspace")
local LP=P.LocalPlayer
local S=_G.BF
if not S or not S.C then warn("[V28] Run main first!") return end
local C=S.C
local fN=S.fN
U.JumpRequest:Connect(function()
if not C.InfJump then return end
local ch=LP.Character
local h=ch and ch:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
task.spawn(function()
while task.wait(60) do
if C.AFK then
pcall(function()
game:GetService("VirtualUser"):CaptureController()
game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0)) end) end end end)
RS.Heartbeat:Connect(function()
local ch=LP.Character
if not ch then return end
local h=ch:FindFirstChildOfClass("Humanoid")
if not h then return end
if C.Speed and h.WalkSpeed~=C.SpeedV then h.WalkSpeed=C.SpeedV end
if C.Jump then h.JumpPower=C.JumpV;h.UseJumpPower=true end
if C.NoStun then h.PlatformStand=false;h.Sit=false end end)
local ME={}
local BL={["Daily Quests"]=true,["Artifact Magician"]=true,["Shop"]=true,["Магазин"]=true,["Blacksmith"]=true}
local function rME(m) if ME[m] then pcall(function() ME[m]:Destroy() end) ME[m]=nil end end
local function cME(m)
if ME[m] or P:GetPlayerFromCharacter(m) or BL[m.Name] then return end
local h=m:FindFirstChildOfClass("Humanoid")
if not h or h.Health<=0 then return end
local hd=m:FindFirstChild("Head") or m.PrimaryPart
if not hd then return end
local bb=Instance.new("BillboardGui")
bb.Size=UDim2.new(2,0,0.7,0)
bb.StudsOffset=Vector3.new(0,2.5,0)
bb.AlwaysOnTop=true
bb.Adornee=hd
bb.Parent=hd
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,0,1,0)
l.BackgroundTransparency=1
l.TextColor3=Color3.fromRGB(255,255,255)
l.Font=Enum.Font.SourceSansBold
l.TextSize=11
l.TextStrokeTransparency=0
l.Parent=bb
local function up()
if not l.Parent or not h.Parent then return end
l.Text=m.Name.."\nHP: "..fN(math.floor(h.Health)) end
up()
ME[m]=bb
h:GetPropertyChangedSignal("Health"):Connect(function()
if h.Health<=0 then rME(m) else up() end end) end
task.spawn(function()
while task.wait(3) do
if C.MobESP then
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then cME(o) end end
else for m,_ in pairs(ME) do rME(m) end end end end)
local PE={}
local function rPE(p) if PE[p] then pcall(function() PE[p]:Destroy() end) PE[p]=nil end end
task.spawn(function()
while task.wait(2) do
if C.PlrESP then
for _,p in ipairs(P:GetPlayers()) do
if p~=LP and not PE[p] and p.Character then
local h=p.Character:FindFirstChildOfClass("Humanoid")
local hd=p.Character:FindFirstChild("Head")
if h and hd then
local bb=Instance.new("BillboardGui")
bb.Size=UDim2.new(0,240,0,80)
bb.StudsOffset=Vector3.new(0,3.5,0)
bb.AlwaysOnTop=true
bb.Adornee=hd
bb.Parent=hd
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,0,1,0)
l.BackgroundTransparency=1
l.TextColor3=Color3.fromRGB(0,255,100)
l.Font=Enum.Font.GothamBold
l.TextSize=14
l.TextStrokeTransparency=0
l.Parent=bb
local function up()
local lv,rb=0,0
local st=p:FindFirstChild("leaderstats")
if st then for _,s in ipairs(st:GetChildren()) do
local n=s.Name:lower()
if n=="level" or n=="lvl" then lv=s.Value end
if n=="rebirth" or n=="reb" then rb=s.Value end end end
l.Text=string.format("%s\nHP: %s\nLvl: %s | Rb: %s",p.Name,fN(math.floor(h.Health)),fN(lv),fN(rb)) end
up()
PE[p]=bb end end end
else for p,_ in pairs(PE) do rPE(p) end end end end)
local lBN=0
task.spawn(function()
while task.wait(2) do
if not C.BossDet then continue end
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("Model") and o.Name:lower():find("boss") then
if tick()-lBN>10 then
lBN=tick()
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification",{
Title="🔥 BOSS",
Text=o.Name,
Duration=5}) end) end
break end end end end)
local NPC={["Blacksmith"]=true,["Artifact Magician"]=true,["Daily Quests"]=true,["Boss Rune"]=true}
task.spawn(function()
while task.wait(0.3) do
if not C.NPCs then continue end
local ch=LP.Character
if not ch then continue end
local hrp=ch:FindFirstChild("HumanoidRootPart")
if not hrp then continue end
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("Model") and NPC[o.Name] then
local t=o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Head") or o:FindFirstChildWhichIsA("BasePart")
if t then
local d=(t.Position-hrp.Position).Magnitude
if C.NPCsAll or d<500 then
pcall(function()
for _,pp in ipairs(o:GetDescendants()) do
if pp:IsA("BasePart") and pp.Anchored then pp.Anchored=false end end
t.CFrame=hrp.CFrame+Vector3.new(math.random(-8,8),0,math.random(-8,8)) end) end end end end end end end)
local function fM()
local ch=LP.Character
if not ch then return nil end
local hrp=ch:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
local cl,d=nil,math.huge
local nm={}
if C.FarmAll then for _,n in ipairs(S.Mobs) do nm[n]=true end
else nm[C.Enemy]=true end
for _,m in ipairs(WS:GetDescendants()) do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
if nm[m.Name] and not P:GetPlayerFromCharacter(m) then
local h=m:FindFirstChildOfClass("Humanoid")
if h.Health>0 then
local mh=m:FindFirstChild("HumanoidRootPart")
if mh then local dd=(mh.Position-hrp.Position).Magnitude
if dd<d then d=dd;cl=m end end end end end end
return cl end
local function fE(r)
local ch=LP.Character
if not ch then return nil end
local hrp=ch:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
local cl,d=nil,math.huge
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and o~=ch then
if o.Name:match("^%d_%d_%d$") then
local h=o:FindFirstChildOfClass("Humanoid")
if h.Health>0 then
local mh=o:FindFirstChild("HumanoidRootPart")
if mh then local dd=(mh.Position-hrp.Position).Magnitude
if dd<r and dd<d then d=dd;cl=mh end end end end end end
return cl end
local function mch(n,k) local s=n:lower()
for _,kw in ipairs(k) do if s:find(kw) then return true end end return false end
local function iR(n) return mch(n,{"rune","руна","fragment","фрагмент"}) end
local function iW(n) return mch(n,{"меч","sword","посох","staff","оружие","weapon","wand"}) end
local function tp(o,hrp,r)
local p=nil
if o:IsA("Model") and o.PrimaryPart then p=o.PrimaryPart.Position
elseif o:IsA("BasePart") then p=o.Position
elseif o:IsA("Tool") and o:FindFirstChild("Handle") then p=o.Handle.Position end
if not p then return end
if (p-hrp.Position).Magnitude>r then return end
local cd=o:FindFirstChildOfClass("ClickDetector") or o:FindFirstChildWhichIsA("ClickDetector",true)
if cd and fireclickdetector then pcall(function() fireclickdetector(cd) end) return end
local pp=o:FindFirstChildOfClass("ProximityPrompt") or o:FindFirstChildWhichIsA("ProximityPrompt",true)
if pp and fireproximityprompt then pcall(function() fireproximityprompt(pp) end) end end
task.spawn(function()
while task.wait(1) do
if C.Spawn and C.AutoTP then
local ch=LP.Character
if ch then
local h=ch:FindFirstChildOfClass("Humanoid")
if h and h.Health<=0 then
task.wait(2)
if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
LP.Character.HumanoidRootPart.CFrame=C.Spawn end end end end end end)
task.spawn(function()
while task.wait(5) do
if C.Rejoin then
if game:GetService("Players").LocalPlayer.Parent==nil then
pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end) end end end end)
local lAA,lKA,lP,lF,lB=0,0,0,0,0
local fBV=nil
RS.Heartbeat:Connect(function()
local n=tick()
local ch=LP.Character
if not ch then return end
local h=ch:FindFirstChildOfClass("Humanoid")
if not h then return end
local hrp=ch:FindFirstChild("HumanoidRootPart")
if not hrp then return end
if C.NoCD then
local t=ch:FindFirstChildOfClass("Tool")
if t then for _,v in ipairs(t:GetDescendants()) do
if v:IsA("NumberValue") then pcall(function() v.Value=0 end) end end end end
if C.AA and n-lAA>0.15 then
lAA=n
local t=ch:FindFirstChildOfClass("Tool")
if t then local tg=fE(C.AARange)
if tg then pcall(function() t:Activate() end) end end end
if C.KA and n-lKA>0.2 then
lKA=n
local t=ch:FindFirstChildOfClass("Tool")
if t then
for _,m in ipairs(WS:GetDescendants()) do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m~=ch and m.Name:match("^%d_%d_%d$") then
local hh=m:FindFirstChildOfClass("Humanoid")
if hh.Health>0 then
local mh=m:FindFirstChild("HumanoidRootPart")
if mh and (mh.Position-hrp.Position).Magnitude<C.KARange then
pcall(function() t:Activate() end) end end end end end end end
if C.Fly then
local m=fM()
if m then
local mh=m:FindFirstChild("HumanoidRootPart")
if mh then
if not fBV then
fBV=Instance.new("BodyVelocity")
fBV.MaxForce=Vector3.new(1e5,1e5,1e5)
fBV.Parent=hrp end
local dir=mh.Position-hrp.Position
fBV.Velocity=dir.Magnitude<3 and Vector3.new(0,0,0) or dir.Unit*(C.FlySpeed*10) end end
elseif fBV then fBV:Destroy();fBV=nil end
if C.Farm and not C.Fly and n-lF>0.05 then
lF=n
local m=fM()
if m then
local mh=m:FindFirstChild("HumanoidRootPart")
if mh then
if C.TP then hrp.CFrame=mh.CFrame
else
local d=(mh.Position-hrp.Position).Magnitude
if d>3 then
if d>100 then hrp.CFrame=mh.CFrame
else hrp.CFrame=hrp.CFrame+(mh.Position-hrp.Position).Unit*(C.FarmSpeed/10) end end end end end end
if C.Pick and n-lP>1 then
lP=n
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("Model") or o:IsA("Tool") or o:IsA("BasePart") then
local nn=o.Name
local ok=false
if C.PickRunes and iR(nn) then ok=true
elseif C.PickWeap and iW(nn) then ok=true end
if ok then tp(o,hrp,100) end end end end
if C.BringAll and n-lB>0.5 then
lB=n
for _,o in ipairs(WS:GetDescendants()) do
if o:IsA("BasePart") then
local d=(o.Position-hrp.Position).Magnitude
if d<C.BringR and d>5 then
pcall(function() o.CFrame=hrp.CFrame+Vector3.new(0,2,0) end) end end end end end)
print("[Blox Loot V28] Logic loaded")