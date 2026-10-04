local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer
_G.BF=_G.BF or {}
local S=_G.BF
local function fN(n)
if not n or type(n)~="number" then return tostring(n) end
if n<1000 then return tostring(math.floor(n)) end
local suf={{1e18,"Qi"},{1e15,"Q"},{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}
for _,p in ipairs(suf) do if n>=p[1] then local sh=n/p[1]
if sh>=100 then return string.format("%d%s",math.floor(sh),p[2])
elseif sh>=10 then return string.format("%.1f%s",sh,p[2])
else return string.format("%.2f%s",sh,p[2]) end end end
return tostring(math.floor(n)) end
S.formatNumber=fN
S.MobList=S.MobList or {"3_1_1","3_1_2","3_1_3","3_1_4","3_2_1","3_2_2","3_2_3","3_2_4","3_3_1","3_3_2","3_3_3","3_3_4"}
S.LootList=S.LootList or {"Rune Fragment Yeti","Rune Fragment Frost Maw","Rune Fragment Illusionist","Все руны","Шлем","Нагрудник","Штаны","Ботинки","Оружие","Щит"}
S.CFG=S.CFG or {
SpeedEnabled=false,SpeedValue=40,JumpEnabled=false,JumpValue=100,InfJump=false,NoStun=false,
AutoAttack=false,AutoAttackRange=30,KillAura=false,KillAuraRange=20,NoCooldown=false,
FarmEnabled=false,FarmSpeed=100,TPFarm=false,FlyToMob=false,FlyToMobSpeed=5,AutoFarmAll=false,
AutoPickup=false,SelectedLoot="Все руны",PickRunes=true,PickWeapon=true,BringAll=false,BringRadius=100,
MobESP=false,PlayerESP=false,BossDetect=false,SelectedEnemy="3_1_1",
SpawnPoint=nil,AutoTPOnDeath=false,TargetEnabled=false,TargetPlayer=nil,
TargetMode="Bottom",TargetSpeed=50,HelicopterRadius=10,
AutoPotion=false,AntiAFK=false,AutoRejoin=false,BringNPCs=false,BringNPCsAll=false,
}
local C=S.CFG
local sg=Instance.new("ScreenGui")
sg.ResetOnSpawn=false
pcall(function() sg.Parent=CoreGui end)
if not sg.Parent then sg.Parent=LP:WaitForChild("PlayerGui") end
local icon=Instance.new("Frame")
icon.Size=UDim2.new(0,140,0,38)
icon.Position=UDim2.new(0,15,0,80)
icon.BackgroundColor3=Color3.fromRGB(25,25,32)
icon.BorderSizePixel=0
icon.Active=true
icon.Parent=sg
Instance.new("UICorner",icon).CornerRadius=UDim.new(0,8)
local iconTop=Instance.new("Frame")
iconTop.Size=UDim2.new(1,0,0,18)
iconTop.BackgroundColor3=Color3.fromRGB(255,200,0)
iconTop.BorderSizePixel=0
iconTop.Parent=icon
Instance.new("UICorner",iconTop).CornerRadius=UDim.new(0,8)
local iconTitle=Instance.new("TextLabel")
iconTitle.Size=UDim2.new(1,0,1,0)
iconTitle.BackgroundTransparency=1
iconTitle.Text="🐯 BF27"
iconTitle.TextColor3=Color3.fromRGB(0,0,0)
iconTitle.Font=Enum.Font.GothamBold
iconTitle.TextSize=11
iconTitle.Parent=iconTop
local iconSub=Instance.new("TextLabel")
iconSub.Size=UDim2.new(1,0,0,20)
iconSub.Position=UDim2.new(0,0,0,18)
iconSub.BackgroundTransparency=1
iconSub.Text="@Xs_KakoINik"
iconSub.TextColor3=Color3.fromRGB(180,180,180)
iconSub.Font=Enum.Font.Gotham
iconSub.TextSize=8
iconSub.Parent=icon
local dragging,dragStart,startPos=false,nil,nil
icon.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true;dragStart=input.Position;startPos=icon.Position end end)
icon.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false end end)
UIS.InputChanged:Connect(function(input)
if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
local d=input.Position-dragStart
icon.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
local main=Instance.new("Frame")
main.Size=UDim2.new(0,380,0,340)
main.Position=UDim2.new(0,170,0,80)
main.BackgroundColor3=Color3.fromRGB(20,20,25)
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
main.Visible=false
main.Parent=sg
Instance.new("UICorner",main).CornerRadius=UDim.new(0,8)
local tb=Instance.new("Frame")
tb.Size=UDim2.new(1,0,0,26)
tb.BackgroundColor3=Color3.fromRGB(255,200,0)
tb.BorderSizePixel=0
tb.Parent=main
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,8)
local tt=Instance.new("TextLabel")
tt.Size=UDim2.new(1,-50,1,0)
tt.Position=UDim2.new(0,8,0,0)
tt.BackgroundTransparency=1
tt.Text="🐯 BF27"
tt.TextColor3=Color3.fromRGB(0,0,0)
tt.Font=Enum.Font.GothamBold
tt.TextSize=11
tt.TextXAlignment=Enum.TextXAlignment.Left
tt.Parent=tb
local close=Instance.new("TextButton")
close.Size=UDim2.new(0,20,0,20)
close.Position=UDim2.new(1,-24,0,3)
close.BackgroundColor3=Color3.fromRGB(200,50,50)
close.Text="X"
close.TextColor3=Color3.fromRGB(255,255,255)
close.Font=Enum.Font.GothamBold
close.TextSize=10
close.Parent=tb
Instance.new("UICorner",close).CornerRadius=UDim.new(0,4)
local sb=Instance.new("Frame")
sb.Size=UDim2.new(0,100,1,-50)
sb.Position=UDim2.new(0,4,0,30)
sb.BackgroundColor3=Color3.fromRGB(28,28,35)
sb.BorderSizePixel=0
sb.Parent=main
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,6)
local sbS=Instance.new("ScrollingFrame")
sbS.Size=UDim2.new(1,0,1,0)
sbS.BackgroundTransparency=1
sbS.BorderSizePixel=0
sbS.ScrollBarThickness=2
sbS.CanvasSize=UDim2.new(0,0,0,0)
sbS.Parent=sb
local sbL=Instance.new("UIListLayout")
sbL.Padding=UDim.new(0,3)
sbL.SortOrder=Enum.SortOrder.LayoutOrder
sbL.Parent=sbS
sbL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
sbS.CanvasSize=UDim2.new(0,0,0,sbL.AbsoluteContentSize.Y+8) end)
local ca=Instance.new("Frame")
ca.Size=UDim2.new(1,-114,1,-50)
ca.Position=UDim2.new(0,110,0,30)
ca.BackgroundColor3=Color3.fromRGB(28,28,35)
ca.BorderSizePixel=0
ca.Parent=main
Instance.new("UICorner",ca).CornerRadius=UDim.new(0,6)
local ft=Instance.new("TextLabel")
ft.Size=UDim2.new(1,-8,0,16)
ft.Position=UDim2.new(0,4,1,-18)
ft.BackgroundTransparency=1
ft.Text="tg:3 @Xs_KakoINik"
ft.TextColor3=Color3.fromRGB(255,200,0)
ft.Font=Enum.Font.GothamBold
ft.TextSize=8
ft.Parent=main
local pages={}
local function mp(name,idx)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-8,0,24)
b.BackgroundColor3=Color3.fromRGB(38,38,48)
b.Text="  "..name
b.TextColor3=Color3.fromRGB(200,200,200)
b.Font=Enum.Font.Gotham
b.TextSize=9
b.TextXAlignment=Enum.TextXAlignment.Left
b.Parent=sbS
Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
local c=Instance.new("ScrollingFrame")
c.Size=UDim2.new(1,0,1,0)
c.BackgroundTransparency=1
c.BorderSizePixel=0
c.ScrollBarThickness=3
c.CanvasSize=UDim2.new(0,0,0,0)
c.Visible=false
c.Parent=ca
local l=Instance.new("UIListLayout")
l.Padding=UDim.new(0,4)
l.Parent=c
l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
c.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10) end)
pages[idx]={button=b,content=c}
b.MouseButton1Click:Connect(function()
for i,p in pairs(pages) do
p.button.BackgroundColor3=(i==idx) and Color3.fromRGB(255,200,0) or Color3.fromRGB(38,38,48)
p.button.TextColor3=(i==idx) and Color3.fromRGB(0,0,0) or Color3.fromRGB(200,200,200)
p.content.Visible=(i==idx) end end)
return c end
local MainTab=mp("Main",1)
local MoveTab=mp("Movement",2)
local ESPTab=mp("ESP",3)
local PickTab=mp("Pickup",4)
local MiscTab=mp("Settings",5)
pages[1].button.BackgroundColor3=Color3.fromRGB(255,200,0)
pages[1].button.TextColor3=Color3.fromRGB(0,0,0)
pages[1].content.Visible=true
local function mt(parent,name,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-8,0,24)
b.BackgroundColor3=Color3.fromRGB(40,40,50)
b.Text=""
b.AutoButtonColor=false
b.Parent=parent
Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,-50,1,0)
l.Position=UDim2.new(0,8,0,0)
l.BackgroundTransparency=1
l.Text=name
l.TextColor3=Color3.fromRGB(220,220,220)
l.Font=Enum.Font.Gotham
l.TextSize=9
l.TextXAlignment=Enum.TextXAlignment.Left
l.Parent=b
local bg=Instance.new("Frame")
bg.Size=UDim2.new(0,28,0,14)
bg.Position=UDim2.new(1,-36,0.5,-7)
bg.BackgroundColor3=Color3.fromRGB(60,60,70)
bg.Parent=b
Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
local k=Instance.new("Frame")
k.Size=UDim2.new(0,10,0,10)
k.Position=UDim2.new(0,2,0.5,-5)
k.BackgroundColor3=Color3.fromRGB(200,200,200)
k.Parent=bg
Instance.new("UICorner",k).CornerRadius=UDim.new(1,0)
local s=false
b.MouseButton1Click:Connect(function()
s=not s
if s then bg.BackgroundColor3=Color3.fromRGB(0,200,120)
k.Position=UDim2.new(1,-12,0.5,-5)
else bg.BackgroundColor3=Color3.fromRGB(60,60,70)
k.Position=UDim2.new(0,2,0.5,-5) end
cb(s) end) end
local function ms(parent,name,mn,mx,df,cb)
local f=Instance.new("Frame")
f.Size=UDim2.new(1,-8,0,40)
f.BackgroundColor3=Color3.fromRGB(40,40,50)
f.Parent=parent
Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,-16,0,16)
l.Position=UDim2.new(0,8,0,3)
l.BackgroundTransparency=1
l.Text=name..": "..df
l.TextColor3=Color3.fromRGB(220,220,220)
l.Font=Enum.Font.Gotham
l.TextSize=9
l.TextXAlignment=Enum.TextXAlignment.Left
l.Parent=f
local bb=Instance.new("Frame")
bb.Size=UDim2.new(1,-16,0,5)
bb.Position=UDim2.new(0,8,0,26)
bb.BackgroundColor3=Color3.fromRGB(60,60,70)
bb.Parent=f
Instance.new("UICorner",bb).CornerRadius=UDim.new(1,0)
local bar=Instance.new("Frame")
bar.Size=UDim2.new((df-mn)/(mx-mn),0,1,0)
bar.BackgroundColor3=Color3.fromRGB(255,200,0)
bar.Parent=bb
Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
local drag=false
local function upd(input)
local rx=math.clamp((input.Position.X-bb.AbsolutePosition.X)/bb.AbsoluteSize.X,0,1)
local v=math.floor(mn+(mx-mn)*rx)
bar.Size=UDim2.new(rx,0,1,0)
l.Text=name..": "..v
cb(v) end
bb.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
drag=true;upd(input) end end)
bb.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
drag=false end end)
UIS.InputChanged:Connect(function(input)
if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
upd(input) end end) end
local function msel(parent,label,opts,df,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-8,0,24)
b.BackgroundColor3=Color3.fromRGB(40,40,50)
b.Text=""
b.AutoButtonColor=false
b.Parent=parent
Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
local l=Instance.new("TextLabel")
l.Size=UDim2.new(0.55,0,1,0)
l.Position=UDim2.new(0,8,0,0)
l.BackgroundTransparency=1
l.Text=label
l.TextColor3=Color3.fromRGB(220,220,220)
l.Font=Enum.Font.Gotham
l.TextSize=9
l.TextXAlignment=Enum.TextXAlignment.Left
l.Parent=b
local v=Instance.new("TextLabel")
v.Size=UDim2.new(0.45,-8,1,0)
v.Position=UDim2.new(0.55,0,0,0)
v.BackgroundTransparency=1
v.Text=df or "?"
v.TextColor3=Color3.fromRGB(255,200,0)
v.Font=Enum.Font.Gotham
v.TextSize=9
v.TextXAlignment=Enum.TextXAlignment.Right
v.Parent=b
b.MouseButton1Click:Connect(function()
local p=Instance.new("Frame")
p.Size=UDim2.new(0,220,0,260)
p.Position=UDim2.new(0.5,-110,0.5,-130)
p.BackgroundColor3=Color3.fromRGB(30,30,38)
p.BorderSizePixel=0
p.Active=true
p.Draggable=true
p.ZIndex=100
p.Parent=sg
Instance.new("UICorner",p).CornerRadius=UDim.new(0,6)
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,26)
t.BackgroundColor3=Color3.fromRGB(255,200,0)
t.Text=label
t.TextColor3=Color3.fromRGB(0,0,0)
t.Font=Enum.Font.GothamBold
t.TextSize=10
t.ZIndex=101
t.Parent=p
Instance.new("UICorner",t).CornerRadius=UDim.new(0,6)
local cp=Instance.new("TextButton")
cp.Size=UDim2.new(0,20,0,20)
cp.Position=UDim2.new(1,-24,0,3)
cp.BackgroundColor3=Color3.fromRGB(200,50,50)
cp.Text="X"
cp.TextColor3=Color3.fromRGB(255,255,255)
cp.Font=Enum.Font.GothamBold
cp.TextSize=10
cp.ZIndex=102
cp.Parent=p
Instance.new("UICorner",cp).CornerRadius=UDim.new(0,4)
local sc=Instance.new("ScrollingFrame")
sc.Size=UDim2.new(1,-8,1,-34)
sc.Position=UDim2.new(0,4,0,30)
sc.BackgroundTransparency=1
sc.BorderSizePixel=0
sc.ScrollBarThickness=3
sc.CanvasSize=UDim2.new(0,0,0,0)
sc.ZIndex=101
sc.Parent=p
local ly=Instance.new("UIListLayout")
ly.Padding=UDim.new(0,3)
ly.Parent=sc
ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
sc.CanvasSize=UDim2.new(0,0,0,ly.AbsoluteContentSize.Y+8) end)
for _,o in ipairs(opts) do
local ob=Instance.new("TextButton")
ob.Size=UDim2.new(1,-4,0,24)
ob.BackgroundColor3=Color3.fromRGB(45,45,55)
ob.Text=o
ob.TextColor3=Color3.fromRGB(220,220,220)
ob.Font=Enum.Font.Gotham
ob.TextSize=9
ob.ZIndex=102
ob.Parent=sc
Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
ob.MouseButton1Click:Connect(function()
v.Text=o
cb(o)
p:Destroy() end) end
cp.MouseButton1Click:Connect(function() p:Destroy() end) end) end
msel(MainTab,"Enemy",S.MobList,C.SelectedEnemy,function(o) C.SelectedEnemy=o end)
msel(MainTab,"Loot",S.LootList,C.SelectedLoot,function(o) C.SelectedLoot=o end)
mt(MainTab,"Auto Farm",function(v) C.FarmEnabled=v end)
mt(MainTab,"Auto Farm ALL",function(v) C.AutoFarmAll=v end)
mt(MainTab,"Fly to Mob",function(v) C.FlyToMob=v end)
ms(MainTab,"Fly Speed",1,20,5,function(v) C.FlyToMobSpeed=v end)
ms(MainTab,"Farm Speed",40,150,100,function(v) C.FarmSpeed=v end)
mt(MainTab,"Auto Attack",function(v) C.AutoAttack=v end)
mt(MainTab,"Kill Aura",function(v) C.KillAura=v end)
mt(MainTab,"No Cooldown",function(v) C.NoCooldown=v end)
mt(MoveTab,"Enable Speed",function(v) C.SpeedEnabled=v end)
ms(MoveTab,"Speed",40,450,40,function(v) C.SpeedValue=v end)
mt(MoveTab,"Enable Jump",function(v) C.JumpEnabled=v end)
mt(MoveTab,"Infinite Jump",function(v) C.InfJump=v end)
mt(MoveTab,"No Stun",function(v) C.NoStun=v end)
mt(ESPTab,"Mob ESP",function(v) C.MobESP=v end)
mt(ESPTab,"Player ESP",function(v) C.PlayerESP=v end)
mt(ESPTab,"Boss Detect",function(v) C.BossDetect=v end)
mt(PickTab,"Auto Pickup",function(v) C.AutoPickup=v end)
mt(PickTab,"Pick Runes",function(v) C.PickRunes=v end)
mt(PickTab,"Pick Weapon",function(v) C.PickWeapon=v end)
mt(PickTab,"Bring All",function(v) C.BringAll=v end)
ms(PickTab,"Bring Radius",20,500,100,function(v) C.BringRadius=v end)
mt(MiscTab,"Auto TP on Death",function(v) C.AutoTPOnDeath=v end)
mt(MiscTab,"Auto Potion",function(v) C.AutoPotion=v end)
mt(MiscTab,"Anti-AFK",function(v) C.AntiAFK=v end)
mt(MiscTab,"Auto Rejoin",function(v) C.AutoRejoin=v end)
mt(MiscTab,"Bring NPCs",function(v) C.BringNPCs=v end)
mt(MiscTab,"Bring NPCs ALL",function(v) C.BringNPCsAll=v end)
local sv=Instance.new("TextButton")
sv.Size=UDim2.new(1,-8,0,24)
sv.BackgroundColor3=Color3.fromRGB(40,40,50)
sv.Text="Save Spawn"
sv.TextColor3=Color3.fromRGB(220,220,220)
sv.Font=Enum.Font.Gotham
sv.TextSize=9
sv.Parent=MiscTab
Instance.new("UICorner",sv).CornerRadius=UDim.new(0,4)
sv.MouseButton1Click:Connect(function()
local ch=LP.Character
if ch and ch:FindFirstChild("HumanoidRootPart") then
C.SpawnPoint=ch.HumanoidRootPart.CFrame
sv.Text="Saved!"
task.wait(1.5)
sv.Text="Save Spawn" end end)
local ts=nil
icon.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
ts=tick() end end)
icon.InputEnded:Connect(function(input)
if (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) and ts then
if tick()-ts<0.3 then main.Visible=not main.Visible end
ts=nil end end)
close.MouseButton1Click:Connect(function() main.Visible=false end)
print("[BF27] UI loaded")
task.spawn(function()
local ok,err=pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/bf27logic.lua",true))() end)
if not ok then warn("[BF27] Logic: "..tostring(err)) end end)