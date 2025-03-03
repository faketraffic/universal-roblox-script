if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot_Enabled     = false,
    Aimbot_TeamCheck   = false,  
    FOV_Enabled        = false,
    Aimbot_FOV         = 100,
    Aimbot_Smooth      = 1,      
    TargetPart         = "Head",

    Chams_Enabled      = false,
    Chams_TeamCheck    = false, 
    NameTag_Enabled    = false,
    TwoD_ESP_Enabled   = false,

    Chams_Color        = {R=0,G=255,B=0},
    Box2D_Color        = {R=0,G=255,B=0}
}

local TargetParts = {"Head","Torso","HumanoidRootPart"}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color       = Color3.fromRGB(255,255,255)
FOVCircle.Thickness   = 2
FOVCircle.NumSides    = 100
FOVCircle.Radius      = Config.Aimbot_FOV
FOVCircle.Filled      = false
FOVCircle.Visible     = false

local Chams_Objects   = {}


local function c3(tbl)
    return Color3.fromRGB(tbl.R,tbl.G,tbl.B)
end
local function c3ToTbl(c)
    return {R=math.floor(c.R*255), G=math.floor(c.G*255), B=math.floor(c.B*255)}
end

local function IsTeammate(p)
    return (p.Team == LP.Team)
end


local GUI = Instance.new("ScreenGui")
GUI.Name = "CyrusCheatUI"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Parent = GUI
Main.Size = UDim2.new(0,640,0,500)
Main.Position = UDim2.new(0.25,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(35,35,35)
Main.BorderSizePixel = 0

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,  Color3.fromRGB(30,30,30)),
    ColorSequenceKeypoint.new(1,  Color3.fromRGB(45,45,45))
}
UIGradient.Rotation = 90
UIGradient.Parent = Main

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,10)
UICorner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.Size = UDim2.new(1,0,0,40)
TopBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
TopBar.BorderSizePixel = 0
TopBar.Active = true

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0,10)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.3,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "Cyrus - Premium Cheat"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)

do
    local dragging = false
    local dragStart, startPos
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = Main.Position
        end
    end)
    TopBar.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    TopBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local Tabs = Instance.new("Frame")
Tabs.Parent = Main
Tabs.Size = UDim2.new(1,0,0,460)
Tabs.Position = UDim2.new(0,0,0,40)
Tabs.BackgroundColor3 = Color3.fromRGB(40,40,40)
Tabs.BorderSizePixel = 0

local RageTab    = Instance.new("Frame")
local LegitTab   = Instance.new("Frame")
local VisualsTab = Instance.new("Frame")
local MiscTab    = Instance.new("Frame")

for _,tab in ipairs({RageTab,LegitTab,VisualsTab,MiscTab}) do
    tab.Parent = Tabs
    tab.Size = UDim2.new(1,0,1,0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
end
LegitTab.Visible = true

local function MakeTabButton(txt, xPos, ref)
    local btn = Instance.new("TextButton")
    btn.Parent = TopBar
    btn.Size = UDim2.new(0,90,0,40)
    btn.Position = UDim2.new(0,90*xPos,0,0)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(function()
        RageTab.Visible    = false
        LegitTab.Visible   = false
        VisualsTab.Visible = false
        MiscTab.Visible    = false
        ref.Visible        = true
    end)
    return btn
end

MakeTabButton("RAGE",   0, RageTab)
MakeTabButton("LEGIT",  1, LegitTab)
MakeTabButton("VISUAL", 2, VisualsTab)
MakeTabButton("MISC",   3, MiscTab)

local function NewLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 18
    l.Text = text
    return l
end

local RageLabel = NewLabel(RageTab,"[Cyrus] Rage Tab - Placeholder")
local MiscLabel = NewLabel(MiscTab,"[Cyrus] Misc Tab - Placeholder")

local function NewButton(parent, text, pos)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0,160,0,30)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    return b
end

local function MakeSlider(parent, label, minVal, maxVal, defaultVal, pos, callback)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Position = pos
    f.Size = UDim2.new(0,220,0,40)
    f.BackgroundTransparency = 1

    local lab = Instance.new("TextLabel", f)
    lab.Size = UDim2.new(0.4,0,1,0)
    lab.BackgroundTransparency = 1
    lab.Text = label..": "..tostring(defaultVal)
    lab.Font = Enum.Font.Gotham
    lab.TextSize = 14
    lab.TextColor3 = Color3.new(1,1,1)

    local bar = Instance.new("Frame", f)
    bar.Position = UDim2.new(0.45,0,0.3,0)
    bar.Size = UDim2.new(0.5,0,0.4,0)
    bar.BackgroundColor3 = Color3.fromRGB(80,80,80)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0,10,1,0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)

    local function updateVal(val)
        local pct = (val - minVal)/(maxVal - minVal)
        knob.Position = UDim2.new(pct, -5, 0, 0)
        lab.Text = label..": "..tostring(val)
        callback(val)
    end

    updateVal(defaultVal)

    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    bar.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local relPos = i.Position.X - bar.AbsolutePosition.X
            local w = bar.AbsoluteSize.X
            local pct = math.clamp(relPos/w, 0, 1)
            local newVal = math.floor(minVal + (maxVal - minVal)*pct)
            updateVal(newVal)
        end
    end)
end

local AimbotToggle = NewButton(LegitTab, "Aimbot: OFF", UDim2.new(0,20,0,20))
AimbotToggle.MouseButton1Click:Connect(function()
    Config.Aimbot_Enabled = not Config.Aimbot_Enabled
    AimbotToggle.Text = Config.Aimbot_Enabled and "Aimbot: ON" or "Aimbot: OFF"
    FOVCircle.Visible = (Config.Aimbot_Enabled and Config.FOV_Enabled)
end)

local TeamCheckAim = NewButton(LegitTab,"TeamCheck: OFF",UDim2.new(0,240,0,20))
TeamCheckAim.MouseButton1Click:Connect(function()
    Config.Aimbot_TeamCheck = not Config.Aimbot_TeamCheck
    TeamCheckAim.Text = Config.Aimbot_TeamCheck and "TeamCheck: ON" or "TeamCheck: OFF"
end)

MakeSlider(LegitTab,"FOV",50,300,Config.Aimbot_FOV,UDim2.new(0,20,0,70),function(v)
    Config.Aimbot_FOV = v
    FOVCircle.Radius = Config.Aimbot_FOV
end)

MakeSlider(LegitTab,"Smooth",1,100,math.floor(Config.Aimbot_Smooth*100),UDim2.new(0,20,0,120),function(v)
    Config.Aimbot_Smooth = v/100
end)

local TBtn = NewButton(LegitTab,"Target: "..Config.TargetPart,UDim2.new(0,20,0,170))
TBtn.MouseButton1Click:Connect(function()
    local idx = table.find(TargetParts,Config.TargetPart) or 1
    idx = (idx % #TargetParts)+1
    Config.TargetPart = TargetParts[idx]
    TBtn.Text = "Target: "..Config.TargetPart
end)

local ChamsToggle = NewButton(VisualsTab,"Chams: ON",UDim2.new(0,20,0,20))
ChamsToggle.MouseButton1Click:Connect(function()
    Config.Chams_Enabled = not Config.Chams_Enabled
    ChamsToggle.Text = Config.Chams_Enabled and "Chams: ON" or "Chams: OFF"
end)

local TeamCheckChams = NewButton(VisualsTab,"TeamCheck: OFF",UDim2.new(0,240,0,20))
TeamCheckChams.MouseButton1Click:Connect(function()
    Config.Chams_TeamCheck = not Config.Chams_TeamCheck
    TeamCheckChams.Text = Config.Chams_TeamCheck and "TeamCheck: ON" or "TeamCheck: OFF"
end)

local FOVToggle = NewButton(VisualsTab,"FOV Circle: OFF",UDim2.new(0,20,0,70))
FOVToggle.MouseButton1Click:Connect(function()
    Config.FOV_Enabled = not Config.FOV_Enabled
    FOVToggle.Text = Config.FOV_Enabled and "FOV Circle: ON" or "FOV Circle: OFF"
    FOVCircle.Visible = (Config.Aimbot_Enabled and Config.FOV_Enabled)
end)

local NameTagToggle = NewButton(VisualsTab,"NameTags: OFF",UDim2.new(0,20,0,120))
NameTagToggle.MouseButton1Click:Connect(function()
    Config.NameTag_Enabled = not Config.NameTag_Enabled
    NameTagToggle.Text = Config.NameTag_Enabled and "NameTags: ON" or "NameTags: OFF"
end)

local TwoDToggle = NewButton(VisualsTab,"2D ESP: OFF",UDim2.new(0,20,0,170))
TwoDToggle.MouseButton1Click:Connect(function()
    Config.TwoD_ESP_Enabled = not Config.TwoD_ESP_Enabled
    TwoDToggle.Text = Config.TwoD_ESP_Enabled and "2D ESP: ON" or "2D ESP: OFF"
end)

local function MakeColorPicker(parent, label, colorRef, pos)
    local cframe = Instance.new("Frame")
    cframe.Parent = parent
    cframe.Position = pos
    cframe.Size = UDim2.new(0,180,0,90)
    cframe.BackgroundTransparency = 1

    local lab = Instance.new("TextLabel", cframe)
    lab.Size = UDim2.new(1,0,0,20)
    lab.BackgroundTransparency = 1
    lab.Text = label
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 14
    lab.TextColor3 = Color3.new(1,1,1)

    local r = colorRef.R
    local g = colorRef.G
    local b = colorRef.B

    local function makeRGBSlider(nametxt, startVal, yPos, setfunc)
        local f = Instance.new("Frame", cframe)
        f.Size = UDim2.new(1,0,0,20)
        f.Position = UDim2.new(0,0,0,yPos)
        f.BackgroundTransparency = 1

        local tl = Instance.new("TextLabel", f)
        tl.Size = UDim2.new(0.2,0,1,0)
        tl.BackgroundTransparency = 1
        tl.Text = nametxt..": "..tostring(startVal)
        tl.Font = Enum.Font.Gotham
        tl.TextSize = 13
        tl.TextColor3 = Color3.new(1,1,1)

        local bar = Instance.new("Frame", f)
        bar.Position = UDim2.new(0.25,0,0.2,0)
        bar.Size = UDim2.new(0.65,0,0.6,0)
        bar.BackgroundColor3 = Color3.fromRGB(100,100,100)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0,8,1,0)
        knob.BackgroundColor3 = Color3.new(1,1,1)

        local function setval(v)
            local pct = v/255
            knob.Position = UDim2.new(pct,-4,0,0)
            tl.Text = nametxt..": "..tostring(v)
            setfunc(v)
        end

        setval(startVal)

        local dragging = false
        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        bar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        bar.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = inp.Position.X - bar.AbsolutePosition.X
                local w = bar.AbsoluteSize.X
                local pct = math.clamp(rel/w,0,1)
                local newV = math.floor(pct*255)
                setval(newV)
            end
        end)
    end

    makeRGBSlider("R", r, 20, function(val)
        r = val
        colorRef.R = val
    end)
    makeRGBSlider("G", g, 40, function(val)
        g = val
        colorRef.G = val
    end)
    makeRGBSlider("B", b, 60, function(val)
        b = val
        colorRef.B = val
    end)
end

MakeColorPicker(VisualsTab,"Chams Color",Config.Chams_Color,UDim2.new(0,420,0,20))
MakeColorPicker(VisualsTab,"2D Box Color",Config.Box2D_Color,UDim2.new(0,420,0,140))


local function SaveConfig()
    local data = HttpService:JSONEncode(Config)
    writefile("CyrusConfig.json", data)
end

local function LoadConfig()
    local ok,err = pcall(function()
        local data = readfile("CyrusConfig.json")
        local dec = HttpService:JSONDecode(data)
        for k,v in pairs(dec) do
            Config[k] = v
        end
    end)
    if not ok then
        warn("[Cyrus] Load config failed:", err)
    end
end

local SaveBtn = NewButton(MiscTab,"Save Config", UDim2.new(0,20,0,20))
SaveBtn.MouseButton1Click:Connect(SaveConfig)

local LoadBtn = NewButton(MiscTab,"Load Config", UDim2.new(0,20,0,70))
LoadBtn.MouseButton1Click:Connect(function()
    LoadConfig()
    AimbotToggle.Text   = Config.Aimbot_Enabled and "Aimbot: ON" or "Aimbot: OFF"
    TeamCheckAim.Text   = Config.Aimbot_TeamCheck and "TeamCheck: ON" or "TeamCheck: OFF"
    FOVBtn.Text         = Config.FOV_Enabled and "FOV Circle: ON" or "FOV Circle: OFF"
    ChamsToggle.Text    = Config.Chams_Enabled and "Chams: ON" or "Chams: OFF"
    TeamCheckChams.Text = Config.Chams_TeamCheck and "TeamCheck: ON" or "TeamCheck: OFF"
    NameTagBtn.Text     = Config.NameTag_Enabled and "NameTags: ON" or "NameTags: OFF"
    TwoDToggle.Text     = Config.TwoD_ESP_Enabled and "2D ESP: ON" or "2D ESP: OFF"
    TBtn.Text           = "Target: "..Config.TargetPart
    FOVCircle.Radius    = Config.Aimbot_FOV
    FOVCircle.Visible   = (Config.Aimbot_Enabled and Config.FOV_Enabled)
end)


local function SetupChams(p)
    if p==LP then return end
    if Chams_Objects[p] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor        = c3(Config.Chams_Color)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor     = Color3.fromRGB(255,255,255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = CoreGui

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0,100,0,30)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,0,1,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 14
    nameLbl.Text = p.Name
    nameLbl.Parent = billboard
    billboard.Parent = CoreGui

    local box2D = Drawing.new("Square")
    box2D.Color     = c3(Config.Box2D_Color)
    box2D.Thickness = 2
    box2D.Filled    = false
    box2D.Visible   = false

    Chams_Objects[p] = {
        Highlight = highlight,
        Billboard = billboard,
        Box2D     = box2D
    }

    RunService.RenderStepped:Connect(function()
        if not Chams_Objects[p] then return end
        local data = Chams_Objects[p]
        local h    = data.Highlight
        local b    = data.Billboard
        local box  = data.Box2D

        h.FillColor = c3(Config.Chams_Color)
        box.Color   = c3(Config.Box2D_Color)

        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            if Config.Chams_TeamCheck and (p.Team==LP.Team) then
                h.Enabled  = false
                b.Enabled  = false
                box.Visible= false
                return
            end
            h.Adornee = p.Character
            h.Enabled = Config.Chams_Enabled

            local head = p.Character.Head
            b.Adornee = head
            b.Enabled = Config.NameTag_Enabled

            local hrp = p.Character.HumanoidRootPart
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

            if Config.TwoD_ESP_Enabled then
                local height = footPos.Y - headPos.Y
                if height < 0 then
                    local tmp = headPos
                    headPos = footPos
                    footPos = tmp
                    height = footPos.Y - headPos.Y
                end
                local width = height / 2
                local x = headPos.X - width/2
                local y = headPos.Y
                if width>0 and height>0 and headPos.Z>0 and footPos.Z>0 then
                    box.Size     = Vector2.new(width, height)
                    box.Position = Vector2.new(x, y)
                    box.Visible  = true
                else
                    box.Visible  = false
                end
            else
                box.Visible = false
            end
        else
            h.Enabled  = false
            b.Enabled  = false
            box.Visible= false
        end
    end)
end

for _,pl in ipairs(Players:GetPlayers()) do
    if pl~=LP then
        pl.CharacterAdded:Connect(function() SetupChams(pl) end)
        SetupChams(pl)
    end
end

Players.PlayerAdded:Connect(function(newP)
    if newP~=LP then
        newP.CharacterAdded:Connect(function() SetupChams(newP) end)
        SetupChams(newP)
    end
end)


local function IsTeammateCheck(p)
    return Config.Aimbot_TeamCheck and (p.Team==LP.Team)
end

local function GetClosest()
    local chosen, dist = nil, Config.Aimbot_FOV
    for _,pp in ipairs(Players:GetPlayers()) do
        if pp~=LP and pp.Character and pp.Character:FindFirstChild(Config.TargetPart) then
            if IsTeammateCheck(pp) then continue end
            local part = pp.Character[Config.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z>0 then
                local mpos = UserInputService:GetMouseLocation()
                local diff = (Vector2.new(pos.X,pos.Y)-mpos).magnitude
                if diff<dist then
                    dist = diff
                    chosen = pp
                end
            end
        end
    end
    return chosen
end

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Position = UserInputService:GetMouseLocation()
    if Config.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local tgt = GetClosest()
        if tgt and tgt.Character and tgt.Character:FindFirstChild(Config.TargetPart) then
            local part = tgt.Character[Config.TargetPart]
            local goalCF = CFrame.new(Camera.CFrame.Position, part.Position)

-- fixed aimbto!!!
            local linearFactor = (101 - math.floor(Config.Aimbot_Smooth*100)) / 100
            local step = math.clamp(linearFactor * dt * 10, 0,1)
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, step)
        end
    end
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    elseif inp.KeyCode == Enum.KeyCode.Delete then
        GUI:Destroy()
        FOVCircle:Remove()
        for ply,data in pairs(Chams_Objects) do
            data.Highlight:Destroy()
            data.Billboard:Destroy()
            data.Box2D:Remove()
        end
        table.clear(Chams_Objects)
    end
end)
