local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local LP=P.LocalPlayer
_G.BF=_G.BF or {}
local S=_G.BF
local function fN(n)
if not n or type(n)~="number" then return tostring(n) end
if n<1000 then return tostring(math.floor(n)) end
local s={{1e18,"Qi"},{1e15,"Q"},{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}
for _,p in ipairs(s) do if n>=p[1] then local sh=n/p[1]
if sh>=100 then return string.format("%d%s",math.floor(sh),p[2])
elseif sh>=10 then return string.format("%.1f%s",sh,p[2])
else return string.format("%.2f%s",sh,p[2]) end end end
return tostring(math.floor(n)) end
S.fN=fN
S.Mobs={"3_1_1","3_1_2","3_1_3","3_1_4","3_2_1","3_2_2","3_2_3","3_2_4","3_3_1","3_3_2","3_3_3","3_3_4"}
S.Loot={"Rune Fragment Yeti","Rune Fragment Frost Maw","Rune Fragment Illusionist","Все руны","Шлем","Нагрудник","Штаны","Ботинки","Оружие","Щит"}
S.C=S.C or {
Speed=false,SpeedV=40,Jump=false,JumpV=100,InfJump=false,NoStun=false,
AA=false,AARange=30,KA=false,KARange=20,NoCD=false,
Farm=false,FarmSpeed=100,TP=false,Fly=false,FlySpeed=5,FarmAll=false,
Pick=false,Loot="Все руны",PickRunes=true,PickWeap=true,BringAll=false,BringR=100,
MobESP=false,PlrESP=false,BossDet=false,Enemy="3_1_1",
Spawn=nil,AutoTP=false,
Pot=false,AFK=false,Rejoin=false,
NPCs=false,NPCsAll=false,
}
local C=S.C
local sg=Instance.new("ScreenGui")
sg.ResetOnSpawn=false
pcall(function() sg.Parent=CG end)
if not sg.Parent then sg.Parent=LP:WaitForChild("PlayerGui") end
local ic=Instance.new("Frame")
ic.Size=UDim2.new(0,140,0,38)
ic.Position=UDim2.new(0,15,0,80)
ic.BackgroundColor3=Color3.fromRGB(25,25,32)
ic.BorderSizePixel=0
ic.Active=true
ic.Parent=sg
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8)
local icT=Instance.new("Frame")
icT.Size=UDim2.new(1,0,0,18)
icT.BackgroundColor3=Color3.fromRGB(255,200,0)
icT.BorderSizePixel=0
icT.Parent=ic
Instance.new("UICorner",icT).CornerRadius=UDim.new(0,8)
local icTitle=Instance.new("TextLabel")
icTitle.Size=UDim2.new(1,0,1,0)
icTitle.BackgroundTransparency=1
icTitle.Text="🐯 BF28"
icTitle.TextColor3=Color3.fromRGB(0,0,0)
icTitle.Font=Enum.Font.GothamBold
icTitle.TextSize=11
icTitle.Parent=icT
local icSub=Instance.new("TextLabel")
icSub.Size=UDim2.new(1,0,0,20)
icSub.Position=UDim2.new(0,0,0,18)
icSub.BackgroundTransparency=1
icSub.Text="@Xs_KakoINik"
icSub.TextColor3=Color3.fromRGB(180,180,180)
icSub.Font=Enum.Font.Gotham
icSub.TextSize=8
icSub.Parent=ic
local dg,ds,sp=false,nil,nil
ic.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dg=true;ds=input.Position;sp=ic.Position end end)
ic.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dg=false end end)
U.InputChanged:Connect(function(input)
if dg and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
local d=input.Position-ds
ic.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
local mn=Instance.new("Frame")
mn.Size=UDim2.new(0,380,0,340)
mn.Position=UDim2.new(0,170,0,80)
mn.BackgroundColor3=Color3.fromRGB(20,20,25)
mn.BorderSizePixel=0
mn.Active=true
mn.Draggable=true
mn.Visible=false
mn.Parent=sg
Instance.new("UICorner",mn).CornerRadius=UDim.new(0,8)
local tb=Instance.new("Frame")
tb.Size=UDim2.new(1,0,0,26)
tb.BackgroundColor3=Color3.fromRGB(255,200,0)
tb.BorderSizePixel=0
tb.Parent=mn
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,8)
local tt=Instance.new("TextLabel")
tt.Size=UDim2.new(1,-50,1,0)
tt.Position=UDim2.new(0,8,0,0)
tt.BackgroundTransparency=1
tt.Text="🐯 BF28"
tt.TextColor3=Color3.fromRGB(0,0,0)
tt.Font=Enum.Font.GothamBold
tt.TextSize=11
tt.TextXAlignment=Enum.TextXAlignment.Left
tt.Parent=tb
local cl=Instance.new("TextButton")
cl.Size=UDim2.new(0,20,0,20)
cl.Position=UDim2.new(1,-24,0,3)
cl.BackgroundColor3=Color3.fromRGB(200,50,50)
cl.Text="X"
cl.TextColor3=Color3.fromRGB(255,255,255)
cl.Font=Enum.Font.GothamBold
cl.TextSize=10
cl.Parent=tb
Instance.new("UICorner",cl).CornerRadius=UDim.new(0,4)
local sb=Instance.new("Frame")
sb.Size=UDim2.new(0,100,1,-50)
sb.Position=UDim2.new(0,4,0,30)
sb.BackgroundColor3=Color3.fromRGB(28,28,35)
sb.BorderSizePixel=0
sb.Parent=mn
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
ca.Parent=mn
Instance.new("UICorner",ca).CornerRadius=UDim.new(0,6)
local ft=Instance.new("TextLabel")
ft.Size=UDim2.new(1,-8,0,16)
ft.Position=UDim2.new(0,4,1,-18)
ft.BackgroundTransparency=1
ft.Text="tg:3 @Xs_KakoINik"
ft.TextColor3=Color3.fromRGB(255,200,0)
ft.Font=Enum.Font.GothamBold
ft.TextSize=8
ft.Parent=mn
local pg={}
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
pg[idx]={button=b,content=c}
b.MouseButton1Click:Connect(function()
for i,p in pairs(pg) do
p.button.BackgroundColor3=(i==idx) and Color3.fromRGB(255,200,0) or Color3.fromRGB(38,38,48)
p.button.TextColor3=(i==idx) and Color3.fromRGB(0,0,0) or Color3.fromRGB(200,200,200)
p.content.Visible=(i==idx) end end)
return c end
local T1=mp("Main",1)
local T2=mp("Movement",2)
local T3=mp("ESP",3)
local T4=mp("Pickup",4)
local T5=mp("Settings",5)
pg[1].button.BackgroundColor3=Color3.fromRGB(255,200,0)
pg[1].button.TextColor3=Color3.fromRGB(0,0,0)
pg[1].content.Visible=true
local function mT(parent,name,cb)
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
local function mS(parent,name,mn2,mx,df,cb)
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
bar.Size=UDim2.new((df-mn2)/(mx-mn2),0,1,0)
bar.BackgroundColor3=Color3.fromRGB(255,200,0)
bar.Parent=bb
Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
local dg2=false
local function upd(input)
local rx=math.clamp((input.Position.X-bb.AbsolutePosition.X)/bb.AbsoluteSize.X,0,1)
local v=math.floor(mn2+(mx-mn2)*rx)
bar.Size=UDim2.new(rx,0,1,0)
l.Text=name..": "..v
cb(v) end
bb.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dg2=true;upd(input) end end)
bb.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dg2=false end end)
U.InputChanged:Connect(function(input)
if dg2 and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
upd(input) end end) end
local function mSel(parent,label,opts,df,cb)
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
mSel(T1,"Enemy",S.Mobs,C.Enemy,function(o) C.Enemy=o end)
mSel(T1,"Loot",S.Loot,C.Loot,function(o) C.Loot=o end)
mT(T1,"Auto Farm",function(v) C.Farm=v end)
mT(T1,"Auto Farm ALL",function(v) C.FarmAll=v end)
mT(T1,"Fly to Mob",function(v) C.Fly=v end)
mS(T1,"Fly Speed",1,20,5,function(v) C.FlySpeed=v end)
mS(T1,"Farm Speed",40,150,100,function(v) C.FarmSpeed=v end)
mT(T1,"Auto Attack",function(v) C.AA=v end)
mT(T1,"Kill Aura",function(v) C.KA=v end)
mT(T1,"No Cooldown",function(v) C.NoCD=v end)
mT(T2,"Enable Speed",function(v) C.Speed=v end)
mS(T2,"Speed",40,450,40,function(v) C.SpeedV=v end)
mT(T2,"Enable Jump",function(v) C.Jump=v end)
mT(T2,"Infinite Jump",function(v) C.InfJump=v end)
mT(T2,"No Stun",function(v) C.NoStun=v end)
mT(T3,"Mob ESP",function(v) C.MobESP=v end)
mT(T3,"Player ESP",function(v) C.PlrESP=v end)
mT(T3,"Boss Detect",function(v) C.BossDet=v end)
mT(T4,"Auto Pickup",function(v) C.Pick=v end)
mT(T4,"Pick Runes",function(v) C.PickRunes=v end)
mT(T4,"Pick Weapon",function(v) C.PickWeap=v end)
mT(T4,"Bring All",function(v) C.BringAll=v end)
mS(T4,"Bring Radius",20,500,100,function(v) C.BringR=v end)
mT(T5,"Auto TP on Death",function(v) C.AutoTP=v end)
mT(T5,"Auto Potion",function(v) C.Pot=v end)
mT(T5,"Anti-AFK",function(v) C.AFK=v end)
mT(T5,"Auto Rejoin",function(v) C.Rejoin=v end)
mT(T5,"Bring NPCs",function(v) C.NPCs=v end)
mT(T5,"Bring NPCs ALL",function(v) C.NPCsAll=v end)
local sv=Instance.new("TextButton")
sv.Size=UDim2.new(1,-8,0,24)
sv.BackgroundColor3=Color3.fromRGB(40,40,50)
sv.Text="Save Spawn"
sv.TextColor3=Color3.fromRGB(220,220,220)
sv.Font=Enum.Font.Gotham
sv.TextSize=9
sv.Parent=T5
Instance.new("UICorner",sv).CornerRadius=UDim.new(0,4)
sv.MouseButton1Click:Connect(function()
local ch=LP.Character
if ch and ch:FindFirstChild("HumanoidRootPart") then
C.Spawn=ch.HumanoidRootPart.CFrame
sv.Text="Saved!"
task.wait(1.5)
sv.Text="Save Spawn" end end)
local ts=nil
ic.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
ts=tick() end end)
ic.InputEnded:Connect(function(input)
if (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) and ts then
if tick()-ts<0.3 then mn.Visible=not mn.Visible end
ts=nil end end)
cl.MouseButton1Click:Connect(function() mn.Visible=false end)
print("[BF28] UI loaded")
task.spawn(function()
local ok,err=pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/q13109747-debug/Retqifx-/main/bf28logic.lua",true))() end)
if not ok then warn("[BF28] Logic: "..tostring(err)) end end)