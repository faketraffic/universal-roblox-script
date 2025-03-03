if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Chams_Enabled = true
local NameTag_Enabled = false
local TwoD_ESP_Enabled = false
local Aimbot_Enabled = false
local FOV_Enabled = false

local Chams_Color = Color3.fromRGB(255,0,0)
local Box2D_Color = Color3.fromRGB(0,255,0)

local Aimbot_FOV = 100
local Aimbot_Smooth = 0.2
local TargetPart = "Head"
local TargetParts = {"Head","Torso","HumanoidRootPart"}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Aimbot_FOV
FOVCircle.Filled = false
FOVCircle.Visible = false

local Chams_Objects = {}

local GUI = Instance.new("ScreenGui")
GUI.Name = "Universal Script"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Parent = GUI
Main.Size = UDim2.new(0,600,0,450)
Main.Position = UDim2.new(0.25,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(35,35,35)
Main.BorderSizePixel = 0

Main.Active = false
Main.Draggable = false

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0,8)

local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.Size = UDim2.new(1,0,0,30)
TopBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Draggable = false  

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.3,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = " Sleek Cheat Menu "
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)

-- top bar dragging only!!!
do
    local dragging = false
    local dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local Tabs = Instance.new("Frame")
Tabs.Parent = Main
Tabs.Size = UDim2.new(1,0,0,420)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.BackgroundColor3 = Color3.fromRGB(40,40,40)
Tabs.BorderSizePixel = 0

local RageTab = Instance.new("Frame")
local LegitTab = Instance.new("Frame")
local VisualsTab = Instance.new("Frame")
local MiscTab = Instance.new("Frame")

for _,tab in ipairs({RageTab,LegitTab,VisualsTab,MiscTab}) do
    tab.Parent = Tabs
    tab.Size = UDim2.new(1,0,1,0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
end
LegitTab.Visible = true

local function MakeTabButton(txt, pos, ref)
    local btn = Instance.new("TextButton")
    btn.Parent = TopBar
    btn.Size = UDim2.new(0,80,1,0)
    btn.Position = UDim2.new(0,80*pos,0,0)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(function()
        RageTab.Visible = false
        LegitTab.Visible = false
        VisualsTab.Visible = false
        MiscTab.Visible = false
        ref.Visible = true
    end)
end

MakeTabButton("RAGE",0,RageTab)
MakeTabButton("LEGIT",1,LegitTab)
MakeTabButton("VISUAL",2,VisualsTab)
MakeTabButton("MISC",3,MiscTab)

local RageLabel = Instance.new("TextLabel", RageTab)
RageLabel.Size = UDim2.new(1,0,1,0)
RageLabel.BackgroundTransparency = 1
RageLabel.Text = "SOON!"
RageLabel.TextColor3 = Color3.new(1,1,1)
RageLabel.Font = Enum.Font.GothamBold
RageLabel.TextSize = 18

local MiscLabel = Instance.new("TextLabel", MiscTab)
MiscLabel.Size = UDim2.new(1,0,1,0)
MiscLabel.BackgroundTransparency = 1
MiscLabel.Text = "COMing soon"
MiscLabel.TextColor3 = Color3.new(1,1,1)
MiscLabel.Font = Enum.Font.GothamBold
MiscLabel.TextSize = 18

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Parent = LegitTab
AimbotToggle.Size = UDim2.new(0,120,0,30)
AimbotToggle.Position = UDim2.new(0,20,0,20)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
AimbotToggle.TextColor3 = Color3.new(1,1,1)
AimbotToggle.Font = Enum.Font.GothamBold
AimbotToggle.TextSize = 14
AimbotToggle.Text = "Aimbot: OFF"

AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot_Enabled = not Aimbot_Enabled
    AimbotToggle.Text = Aimbot_Enabled and "Aimbot: ON" or "Aimbot: OFF"
    FOVCircle.Visible = (Aimbot_Enabled and FOV_Enabled)
end)

local function MakeSlider(parent, label, minVal, maxVal, defaultVal, pos, callback)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Position = pos
    f.Size = UDim2.new(0,200,0,30)
    f.BackgroundTransparency = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.4,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = label..": "..tostring(defaultVal)
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextColor3 = Color3.new(1,1,1)

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
        l.Text = label..": "..tostring(val)
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
            local width = bar.AbsoluteSize.X
            local pct = math.clamp(relPos/width, 0, 1)
            local newVal = math.floor(minVal + (maxVal - minVal)*pct)
            updateVal(newVal)
        end
    end)
end

MakeSlider(LegitTab,"FOV",50,300,Aimbot_FOV,UDim2.new(0,20,0,60),function(v)
    Aimbot_FOV = v
    FOVCircle.Radius = Aimbot_FOV
end)

MakeSlider(LegitTab,"Smooth",1,100,math.floor(Aimbot_Smooth*100),UDim2.new(0,20,0,100),function(v)
    Aimbot_Smooth = v/100
end)

local TargetBtn = Instance.new("TextButton")
TargetBtn.Parent = LegitTab
TargetBtn.Size = UDim2.new(0,120,0,30)
TargetBtn.Position = UDim2.new(0,20,0,140)
TargetBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
TargetBtn.TextColor3 = Color3.new(1,1,1)
TargetBtn.Font = Enum.Font.GothamBold
TargetBtn.TextSize = 14
TargetBtn.Text = "Target: "..TargetPart

TargetBtn.MouseButton1Click:Connect(function()
    local idx = table.find(TargetParts,TargetPart) or 1
    idx = (idx % #TargetParts) + 1
    TargetPart = TargetParts[idx]
    TargetBtn.Text = "Target: "..TargetPart
end)

local ChamsToggle = Instance.new("TextButton")
ChamsToggle.Parent = VisualsTab
ChamsToggle.Size = UDim2.new(0,120,0,30)
ChamsToggle.Position = UDim2.new(0,20,0,20)
ChamsToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
ChamsToggle.TextColor3 = Color3.new(1,1,1)
ChamsToggle.Font = Enum.Font.GothamBold
ChamsToggle.TextSize = 14
ChamsToggle.Text = "Chams: ON"

ChamsToggle.MouseButton1Click:Connect(function()
    Chams_Enabled = not Chams_Enabled
    ChamsToggle.Text = Chams_Enabled and "Chams: ON" or "Chams: OFF"
end)

local FOVToggle = Instance.new("TextButton")
FOVToggle.Parent = VisualsTab
FOVToggle.Size = UDim2.new(0,140,0,30)
FOVToggle.Position = UDim2.new(0,20,0,60)
FOVToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
FOVToggle.TextColor3 = Color3.new(1,1,1)
FOVToggle.Font = Enum.Font.GothamBold
FOVToggle.TextSize = 14
FOVToggle.Text = "FOV Circle: OFF"

FOVToggle.MouseButton1Click:Connect(function()
    FOV_Enabled = not FOV_Enabled
    FOVToggle.Text = FOV_Enabled and "FOV Circle: ON" or "FOV Circle: OFF"
    FOVCircle.Visible = (Aimbot_Enabled and FOV_Enabled)
end)

local NameTagToggle = Instance.new("TextButton")
NameTagToggle.Parent = VisualsTab
NameTagToggle.Size = UDim2.new(0,140,0,30)
NameTagToggle.Position = UDim2.new(0,20,0,100)
NameTagToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
NameTagToggle.TextColor3 = Color3.new(1,1,1)
NameTagToggle.Font = Enum.Font.GothamBold
NameTagToggle.TextSize = 14
NameTagToggle.Text = "NameTags: OFF"

NameTagToggle.MouseButton1Click:Connect(function()
    NameTag_Enabled = not NameTag_Enabled
    NameTagToggle.Text = NameTag_Enabled and "NameTags: ON" or "NameTags: OFF"
end)

local TwoDToggle = Instance.new("TextButton")
TwoDToggle.Parent = VisualsTab
TwoDToggle.Size = UDim2.new(0,140,0,30)
TwoDToggle.Position = UDim2.new(0,20,0,140)
TwoDToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
TwoDToggle.TextColor3 = Color3.new(1,1,1)
TwoDToggle.Font = Enum.Font.GothamBold
TwoDToggle.TextSize = 14
TwoDToggle.Text = "2D ESP: OFF"

TwoDToggle.MouseButton1Click:Connect(function()
    TwoD_ESP_Enabled = not TwoD_ESP_Enabled
    TwoDToggle.Text = TwoD_ESP_Enabled and "2D ESP: ON" or "2D ESP: OFF"
end)
-- api
local function MakeColorPicker(parent, label, defaultColor, pos, callback)
    local cframe = Instance.new("Frame")
    cframe.Parent = parent
    cframe.Position = pos
    cframe.Size = UDim2.new(0,180,0,90)
    cframe.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", cframe)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)

    local defaultR = math.floor(defaultColor.R * 255)
    local defaultG = math.floor(defaultColor.G * 255)
    local defaultB = math.floor(defaultColor.B * 255)
    local r, g, b = defaultR, defaultG, defaultB

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

    makeRGBSlider("R", defaultR, 20, function(val)
        r = val
        callback(Color3.fromRGB(r,g,b))
    end)
    makeRGBSlider("G", defaultG, 40, function(val)
        g = val
        callback(Color3.fromRGB(r,g,b))
    end)
    makeRGBSlider("B", defaultB, 60, function(val)
        b = val
        callback(Color3.fromRGB(r,g,b))
    end)
end

MakeColorPicker(VisualsTab,"Chams Color",Chams_Color,UDim2.new(0,200,0,20),function(c)
    Chams_Color = c
end)

MakeColorPicker(VisualsTab,"2D Box Color",Box2D_Color,UDim2.new(0,200,0,120),function(c)
    Box2D_Color = c
end)

local function SetupChams(p)
    if p == LP then return end
    if Chams_Objects[p] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Chams_Color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
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
    box2D.Color = Box2D_Color
    box2D.Thickness = 2
    box2D.Filled = false
    box2D.Visible = false

    Chams_Objects[p] = {
        Highlight = highlight,
        Billboard = billboard,
        Box2D = box2D
    }

    RunService.RenderStepped:Connect(function()
        if not Chams_Objects[p] then return end
        local data = Chams_Objects[p]
        local h = data.Highlight
        local b = data.Billboard
        local box = data.Box2D

        -- updating colors?
        h.FillColor = Chams_Color
        box.Color = Box2D_Color

        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            h.Adornee = p.Character
            h.Enabled = Chams_Enabled

            local head = p.Character.Head
            b.Adornee = head
            b.Enabled = NameTag_Enabled

            local hrp = p.Character.HumanoidRootPart
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

            if TwoD_ESP_Enabled then
                local height = footPos.Y - headPos.Y
                if height < 0 then
                    local tmp = headPos
                    headPos = footPos
                    footPos = tmp
                    height = footPos.Y - headPos.Y
                end
                local width = height / 2
                local x = headPos.X - width / 2
                local y = headPos.Y

                if width > 0 and height > 0 then
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(x, y)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            h.Enabled = false
            b.Enabled = false
            box.Visible = false
        end
    end)
end

for _,pl in ipairs(Players:GetPlayers()) do
    pl.CharacterAdded:Connect(function()
        SetupChams(pl)
    end)
    SetupChams(pl)
end

Players.PlayerAdded:Connect(function(newP)
    newP.CharacterAdded:Connect(function()
        SetupChams(newP)
    end)
end)

local function GetClosest()
    local chosen, dist = nil, Aimbot_FOV
    for _,pp in ipairs(Players:GetPlayers()) do
        if pp~=LP and pp.Character and pp.Character:FindFirstChild(TargetPart) then
            local part = pp.Character[TargetPart]
            local pos,onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mpos = UserInputService:GetMouseLocation()
                local diff = (Vector2.new(pos.X,pos.Y)-mpos).magnitude
                if diff < dist then
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
    if Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local tgt = GetClosest()
        if tgt and tgt.Character and tgt.Character:FindFirstChild(TargetPart) then
            local part = tgt.Character[TargetPart]
            local desiredCF = CFrame.new(Camera.CFrame.Position, part.Position)
            local step = math.clamp(Aimbot_Smooth * dt * 4, 0, 1)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCF, step)
        end
    end
end)

UserInputService.InputBegan:Connect(function(i,g)
    if i.KeyCode == Enum.KeyCode.Insert and not g then
        Main.Visible = not Main.Visible
    elseif i.KeyCode == Enum.KeyCode.Delete and not g then
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
