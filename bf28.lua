local P=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local LP=P.LocalPlayer
local C={Speed=false,SpeedV=100,ESP=false,AA=false,AARange=50,AF=false,AFMode="Fly",AFSpeed=10,Hitbox=false,HitboxSize=15}
local sg=Instance.new("ScreenGui")
sg.ResetOnSpawn=false
pcall(function() sg.Parent=game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent=LP:WaitForChild("PlayerGui") end

local icon=Instance.new("Frame")
icon.Size=UDim2.new(0,120,0,32)
icon.Position=UDim2.new(0,15,0,60)
icon.BackgroundColor3=Color3.fromRGB(25,25,32)
icon.Active=true
icon.Parent=sg
Instance.new("UICorner",icon).CornerRadius=UDim.new(0,6)
local it=Instance.new("Frame")
it.Size=UDim2.new(1,0,0,16)
it.BackgroundColor3=Color3.fromRGB(255,200,0)
it.Parent=icon
Instance.new("UICorner",it).CornerRadius=UDim.new(0,6)
local itl=Instance.new("TextLabel")
itl.Size=UDim2.new(1,0,1,0)
itl.BackgroundTransparency=1
itl.Text="🐯 BF"
itl.TextColor3=Color3.fromRGB(0,0,0)
itl.Font=Enum.Font.GothamBold
itl.TextSize=10
itl.Parent=it
local isub=Instance.new("TextLabel")
isub.Size=UDim2.new(1,0,0,16)
isub.Position=UDim2.new(0,0,0,16)
isub.BackgroundTransparency=1
isub.Text="@Xs_KakoINik"
isub.TextColor3=Color3.fromRGB(180,180,180)
isub.Font=Enum.Font.Gotham
isub.TextSize=7
isub.Parent=icon

local f=Instance.new("Frame")
f.Size=UDim2.new(0,220,0,320)
f.Position=UDim2.new(0,150,0,60)
f.BackgroundColor3=Color3.fromRGB(30,30,40)
f.Visible=false
f.Active=true
f.Draggable=true
f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,24)
title.BackgroundColor3=Color3.fromRGB(255,200,0)
title.Text="🐯 BF28"
title.TextColor3=Color3.fromRGB(0,0,0)
title.Font=Enum.Font.GothamBold
title.TextSize=11
title.Parent=f
Instance.new("UICorner",title).CornerRadius=UDim.new(0,8)

local function mkBtn(y,txt,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-20,0,24)
b.Position=UDim2.new(0,10,0,y)
b.BackgroundColor3=Color3.fromRGB(60,60,80)
b.Text=txt
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=10
b.Parent=f
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
local s=false
b.MouseButton1Click:Connect(function()
s=not s
b.BackgroundColor3=s and Color3.fromRGB(0,200,120) or Color3.fromRGB(60,60,80)
cb(s) end) end

mkBtn(30,"SPEED",function(v) C.Speed=v end)
mkBtn(58,"ESP MOBS",function(v) C.ESP=v end)
mkBtn(86,"AUTO ATTACK",function(v) C.AA=v end)
mkBtn(114,"AUTO FARM",function(v) C.AF=v end)
mkBtn(142,"HITBOX EXPAND",function(v) C.Hitbox=v end)

local modeBtn=Instance.new("TextButton")
modeBtn.Size=UDim2.new(1,-20,0,24)
modeBtn.Position=UDim2.new(0,10,0,170)
modeBtn.BackgroundColor3=Color3.fromRGB(100,60,160)
modeBtn.Text="Mode: Fly"
modeBtn.TextColor3=Color3.fromRGB(255,255,255)
modeBtn.Font=Enum.Font.GothamBold
modeBtn.TextSize=10
modeBtn.Parent=f
Instance.new("UICorner",modeBtn).CornerRadius=UDim.new(0,6)
modeBtn.MouseButton1Click:Connect(function()
if C.AFMode=="Fly" then
C.AFMode="TP"
modeBtn.Text="Mode: TP"
else
C.AFMode="Fly"
modeBtn.Text="Mode: Fly" end end)

local spdLabel=Instance.new("TextLabel")
spdLabel.Size=UDim2.new(1,-20,0,16)
spdLabel.Position=UDim2.new(0,10,0,200)
spdLabel.BackgroundTransparency=1
spdLabel.Text="Fly Speed: 10"
spdLabel.TextColor3=Color3.fromRGB(220,220,220)
spdLabel.Font=Enum.Font.Gotham
spdLabel.TextSize=9
spdLabel.TextXAlignment=Enum.TextXAlignment.Left
spdLabel.Parent=f
local spdBar=Instance.new("Frame")
spdBar.Size=UDim2.new(1,-20,0,5)
spdBar.Position=UDim2.new(0,10,0,220)
spdBar.BackgroundColor3=Color3.fromRGB(60,60,70)
spdBar.Parent=f
Instance.new("UICorner",spdBar).CornerRadius=UDim.new(1,0)
local spdFill=Instance.new("Frame")
spdFill.Size=UDim2.new((10-1)/(50-1),0,1,0)
spdFill.BackgroundColor3=Color3.fromRGB(255,200,0)
spdFill.Parent=spdBar
Instance.new("UICorner",spdFill).CornerRadius=UDim.new(1,0)

local hbLabel=Instance.new("TextLabel")
hbLabel.Size=UDim2.new(1,-20,0,16)
hbLabel.Position=UDim2.new(0,10,0,232)
hbLabel.BackgroundTransparency=1
hbLabel.Text="Hitbox Size: 15"
hbLabel.TextColor3=Color3.fromRGB(220,220,220)
hbLabel.Font=Enum.Font.Gotham
hbLabel.TextSize=9
hbLabel.TextXAlignment=Enum.TextXAlignment.Left
hbLabel.Parent=f
local hbBar=Instance.new("Frame")
hbBar.Size=UDim2.new(1,-20,0,5)
hbBar.Position=UDim2.new(0,10,0,252)
hbBar.BackgroundColor3=Color3.fromRGB(60,60,70)
hbBar.Parent=f
Instance.new("UICorner",hbBar).CornerRadius=UDim.new(1,0)
local hbFill=Instance.new("Frame")
hbFill.Size=UDim2.new((15-5)/(50-5),0,1,0)
hbFill.BackgroundColor3=Color3.fromRGB(255,200,0)
hbFill.Parent=hbBar
Instance.new("UICorner",hbFill).CornerRadius=UDim.new(1,0)

local btnClose=Instance.new("TextButton")
btnClose.Size=UDim2.new(1,-20,0,24)
btnClose.Position=UDim2.new(0,10,0,270)
btnClose.BackgroundColor3=Color3.fromRGB(200,50,50)
btnClose.Text="ЗАКРЫТЬ"
btnClose.TextColor3=Color3.fromRGB(255,255,255)
btnClose.Font=Enum.Font.GothamBold
btnClose.TextSize=10
btnClose.Parent=f
Instance.new("UICorner",btnClose).CornerRadius=UDim.new(0,6)
btnClose.MouseButton1Click:Connect(function()
f.Visible=false
icon.Visible=true end)

local dragging,ds,sp=false,nil,nil
icon.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true;ds=input.Position;sp=icon.Position end end)
icon.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false end end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
local d=input.Position-ds
icon.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)

local ts=nil
icon.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
ts=tick() end end)
icon.InputEnded:Connect(function(input)
if (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) and ts then
if tick()-ts<0.3 then
f.Visible=not f.Visible
icon.Visible=false end
ts=nil end end)

local dragSpd,dragHb=false,false
local function updSpd(input)
local rx=math.clamp((input.Position.X-spdBar.AbsolutePosition.X)/spdBar.AbsoluteSize.X,0,1)
local v=math.floor(1+(50-1)*rx)
spdFill.Size=UDim2.new(rx,0,1,0)
spdLabel.Text="Fly Speed: "..v
C.AFSpeed=v end
local function updHb(input)
local rx=math.clamp((input.Position.X-hbBar.AbsolutePosition.X)/hbBar.AbsoluteSize.X,0,1)
local v=math.floor(5+(50-5)*rx)
hbFill.Size=UDim2.new(rx,0,1,0)
hbLabel.Text="Hitbox Size: "..v
C.HitboxSize=v end
spdBar.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragSpd=true;updSpd(input) end end)
spdBar.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragSpd=false end end)
hbBar.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragHb=true;updHb(input) end end)
hbBar.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragHb=false end end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
if dragSpd and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then updSpd(input) end
if dragHb and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then updHb(input) end end)

task.spawn(function()
while task.wait(0.5) do
if C.Hitbox then
for _,m in ipairs(WS:GetDescendants()) do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
if m.Name:match("^%d_%d_%d$") and not P:GetPlayerFromCharacter(m) then
for _,p in ipairs(m:GetDescendants()) do
if p:IsA("BasePart") then
pcall(function()
p.Size=Vector3.new(C.HitboxSize,C.HitboxSize,C.HitboxSize)
p.Transparency=0.7
p.CanCollide=false end) end end end end end end end end end)

RS.Heartbeat:Connect(function()
local ch=LP.Character
if not ch then return end
local h=ch:FindFirstChildOfClass("Humanoid")
if not h then return end
local hrp=ch:FindFirstChild("HumanoidRootPart")
if not hrp then return end
if C.Speed and h.WalkSpeed~=C.SpeedV then h.WalkSpeed=C.SpeedV end
local tool=ch:FindFirstChildOfClass("Tool")
if not tool then return end
local closest,d=nil,math.huge
for _,m in ipairs(WS:GetDescendants()) do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m~=ch then
if m.Name:match("^%d_%d_%d$") then
local hh=m:FindFirstChildOfClass("Humanoid")
if hh.Health>0 then
local mh=m:FindFirstChild("HumanoidRootPart")
if mh then local dd=(mh.Position-hrp.Position).Magnitude
if dd<d then d=dd;closest=mh end end end end end end
if closest and d<C.AARange then
if C.AF then
if C.AFMode=="TP" then
hrp.CFrame=closest.CFrame*CFrame.new(0,0,3)
else
if d>3 then
hrp.CFrame=hrp.CFrame+(closest.Position-hrp.Position).Unit*C.AFSpeed end end end
if C.AA then
for _=1,3 do pcall(function() tool:Activate() end) end end end end)

local cache={}
RS.RenderStepped:Connect(function()
if not C.ESP then
for m,_ in pairs(cache) do pcall(function() cache[m]:Destroy() end) cache[m]=nil end
return end
for _,m in ipairs(WS:GetDescendants()) do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
if not P:GetPlayerFromCharacter(m) and m.Name:match("^%d_%d_%d$") then
if not cache[m] then
local hd=m:FindFirstChild("Head") or m.PrimaryPart
if hd then
local bb=Instance.new("BillboardGui")
bb.Size=UDim2.new(0,100,0,30)
bb.StudsOffset=Vector3.new(0,3,0)
bb.AlwaysOnTop=true
bb.Adornee=hd
bb.Parent=hd
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,0,1,0)
l.BackgroundTransparency=1
l.TextColor3=Color3.fromRGB(255,100,100)
l.TextStrokeTransparency=0
l.Font=Enum.Font.GothamBold
l.TextSize=12
l.Text=m.Name
l.Parent=bb
cache[m]=bb end end end end end end)

print("=== BF28 LOADED ===")