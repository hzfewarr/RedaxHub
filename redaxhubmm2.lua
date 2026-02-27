-- ╔══════════════════════════════════════════════════╗
-- ║         RedaxHub | Murder Mystery 2  v7          ║
-- ╚══════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Workspace    = game:GetService("Workspace")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera

-- =====================
-- DISCORD AUTO-OPEN
-- =====================
task.spawn(function()
    task.wait(0.1)
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://discord.gg/2Rw9GwXaPj")
    end)
end)

-- =====================
-- RAYFIELD BYPASS (aggressive — hides ALL Rayfield UI before & after load)
-- =====================
local rayfieldReady = false
local Rayfield      = nil

local function KillRayfieldGui(gui)
    pcall(function()
        gui.Enabled = false
        for _, d in pairs(gui:GetDescendants()) do
            if d:IsA("Frame") or d:IsA("TextLabel") or d:IsA("ImageLabel") or
               d:IsA("ScrollingFrame") or d:IsA("ScreenGui") then
                pcall(function() d.Visible = false end)
            end
        end
    end)
end

local function HideRayfieldBootScreen()
    task.spawn(function()
        local watched = {}
        local coreGui = game:GetService("CoreGui")
        for i = 1, 200 do   -- 20 seconds max
            task.wait(0.1)
            -- Scan CoreGui
            for _, gui in pairs(coreGui:GetChildren()) do
                if not watched[gui] then
                    local n = gui.Name:lower()
                    if (n:find("rayfield") or n:find("bootstrap") or n:find("loading") or n:find("sirius"))
                        and gui ~= coreGui:FindFirstChild("RedaxLoader")
                        and gui ~= coreGui:FindFirstChild("RedaxHUD") then
                        watched[gui] = true
                        KillRayfieldGui(gui)
                    end
                end
            end
            -- Also scan PlayerGui
            pcall(function()
                for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if not watched[gui] then
                        local n = gui.Name:lower()
                        if n:find("rayfield") or n:find("bootstrap") or n:find("loading") then
                            watched[gui] = true
                            KillRayfieldGui(gui)
                        end
                    end
                end
            end)
            if rayfieldReady and i > 30 then break end
        end
    end)
end

HideRayfieldBootScreen()

task.spawn(function()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if ok and result then
        Rayfield = result
        rayfieldReady = true
        -- Extra: kill any Rayfield GUI that appeared during load
        task.wait(0.1)
        local coreGui = game:GetService("CoreGui")
        for _, gui in pairs(coreGui:GetChildren()) do
            local n = gui.Name:lower()
            if (n:find("rayfield") or n:find("bootstrap") or n:find("sirius"))
               and gui ~= coreGui:FindFirstChild("RedaxLoader")
               and gui ~= coreGui:FindFirstChild("RedaxHUD") then
                KillRayfieldGui(gui)
            end
        end
    else
        warn("RedaxHub: Rayfield failed - " .. tostring(result))
    end
end)

-- =====================
-- RED/BLACK MATRIX LOADER
-- =====================
local vp = Camera.ViewportSize
local CX, CY = vp.X / 2, vp.Y / 2

-- Color palette (red/black/crimson)
local C_BLACK  = Color3.fromRGB(0,   0,   0)
local C_RED    = Color3.fromRGB(200, 0,   0)
local C_BRED   = Color3.fromRGB(255, 30,  30)
local C_DRED   = Color3.fromRGB(100, 0,   0)
local C_WHITE  = Color3.fromRGB(255, 200, 200)

local sg = Instance.new("ScreenGui")
sg.Name           = "RedaxLoader"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.DisplayOrder   = 9999
sg.Parent         = game:GetService("CoreGui")

-- Pure black background
local bg = Instance.new("Frame")
bg.Size             = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = C_BLACK
bg.BorderSizePixel  = 0
bg.ZIndex           = 1
bg.Parent           = sg

-- Matrix rain — red/black style
local matrixChars = {"0","1","R","E","D","A","X","◆","▸","║","╬","∆","Ω","λ",
                     "∑","//",">>","<<","||","##","!!","??","$$","&&","**","%%"}
local rainCols = {
    Color3.fromRGB(180,0,0),
    Color3.fromRGB(220,0,0),
    Color3.fromRGB(140,0,0),
    Color3.fromRGB(255,20,20),
}
local colCount = math.floor(vp.X / 18)

for col = 1, colCount do
    task.spawn(function()
        task.wait(math.random() * 4.5)
        while sg and sg.Parent do
            local colH   = math.random(5, 18)
            local speed  = math.random(45, 120) / 1000
            local xPos   = (col-1) * 18
            local chosen = rainCols[math.random(#rainCols)]
            local lbls   = {}
            for row = 1, colH do
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0,16,0,17) lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Code lbl.TextSize = 12 lbl.ZIndex = 3 lbl.Parent = bg
                if row == colH then
                    lbl.TextColor3 = C_WHITE lbl.TextTransparency = 0
                elseif row >= colH-2 then
                    lbl.TextColor3 = C_BRED lbl.TextTransparency = 0.05
                else
                    local fade = (colH - row) / colH
                    lbl.TextColor3 = chosen lbl.TextTransparency = fade * 0.88
                end
                table.insert(lbls, lbl)
            end
            local totalRows = math.floor(vp.Y / 17) + colH + 2
            for step = 1, totalRows do
                if not (sg and sg.Parent) then break end
                for i, lbl in ipairs(lbls) do
                    local row = step - (colH - i)
                    lbl.Text     = matrixChars[math.random(#matrixChars)]
                    lbl.Position = UDim2.new(0, xPos, 0, (row-1)*17)
                    lbl.Visible  = row >= 1 and row <= math.floor(vp.Y/17)+2
                end
                task.wait(speed)
            end
            for _, lbl in ipairs(lbls) do lbl:Destroy() end
            task.wait(math.random() * 1.5)
        end
    end)
end

-- Red scan line
local scanLine = Instance.new("Frame")
scanLine.Size = UDim2.new(1,0,0,2) scanLine.BackgroundColor3 = C_BRED
scanLine.BackgroundTransparency = 0.2 scanLine.BorderSizePixel = 0
scanLine.ZIndex = 4 scanLine.Position = UDim2.new(0,0,0,0) scanLine.Parent = bg

local scanGlow = Instance.new("Frame")
scanGlow.Size = UDim2.new(1,0,0,28) scanGlow.BackgroundColor3 = C_RED
scanGlow.BackgroundTransparency = 0.85 scanGlow.BorderSizePixel = 0
scanGlow.ZIndex = 4 scanGlow.Position = UDim2.new(0,0,0,-13) scanGlow.Parent = bg

task.spawn(function()
    while sg and sg.Parent do
        TweenService:Create(scanLine, TweenInfo.new(3,Enum.EasingStyle.Linear), {Position=UDim2.new(0,0,1,0)}):Play()
        TweenService:Create(scanGlow, TweenInfo.new(3,Enum.EasingStyle.Linear), {Position=UDim2.new(0,0,1,-14)}):Play()
        task.wait(3.1)
        scanLine.Position = UDim2.new(0,0,0,0) scanGlow.Position = UDim2.new(0,0,0,-13)
        task.wait(0.04)
    end
end)

-- ── CENTER PANEL ──
local PW, PH = 500, 320
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,0,0,0) panel.Position = UDim2.new(0.5,0,0.5,0)
panel.BackgroundColor3 = Color3.fromRGB(5,0,0) panel.BackgroundTransparency = 0.03
panel.BorderSizePixel = 0 panel.ZIndex = 10 panel.Parent = bg
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,6)

-- Animated red border
local pStroke = Instance.new("UIStroke")
pStroke.Color = C_RED pStroke.Thickness = 2 pStroke.Parent = panel
task.spawn(function()
    local bc = {C_RED, C_BRED, Color3.fromRGB(180,0,0), Color3.fromRGB(255,50,0)}
    local i = 1
    while pStroke and pStroke.Parent do
        TweenService:Create(pStroke,TweenInfo.new(1,Enum.EasingStyle.Sine),{Color=bc[i%#bc+1]}):Play()
        i=i+1 task.wait(1)
    end
end)

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,28) topBar.BackgroundColor3 = Color3.fromRGB(15,0,0)
topBar.BorderSizePixel = 0 topBar.ZIndex = 11 topBar.Parent = panel
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,6)

local topBarLbl = Instance.new("TextLabel")
topBarLbl.Size = UDim2.new(1,-16,1,0) topBarLbl.Position = UDim2.new(0,8,0,0)
topBarLbl.BackgroundTransparency = 1 topBarLbl.Font = Enum.Font.GothamBold topBarLbl.TextSize = 11
topBarLbl.TextColor3 = C_RED topBarLbl.TextXAlignment = Enum.TextXAlignment.Left
topBarLbl.Text = "◈  REDAXHUB  //  MM2 HACK SUITE  //  v7.0" topBarLbl.ZIndex = 12 topBarLbl.Parent = topBar

-- Blinking status dot
local statusDot = Instance.new("TextLabel")
statusDot.Size = UDim2.new(0,80,1,0) statusDot.Position = UDim2.new(1,-88,0,0)
statusDot.BackgroundTransparency = 1 statusDot.Font = Enum.Font.GothamBold statusDot.TextSize = 10
statusDot.TextColor3 = C_BRED statusDot.TextXAlignment = Enum.TextXAlignment.Right
statusDot.Text = "● LOADING" statusDot.ZIndex = 12 statusDot.Parent = topBar
task.spawn(function()
    local s = {"● LOADING","● LOADING","○ INJECT"}
    local i = 1
    while statusDot and statusDot.Parent do
        statusDot.Text = s[i] statusDot.TextColor3 = i==3 and C_WHITE or C_BRED
        i=i%#s+1 task.wait(0.7)
    end
end)

local hSep = Instance.new("Frame")
hSep.Size = UDim2.new(1,0,0,1) hSep.Position = UDim2.new(0,0,0,28)
hSep.BackgroundColor3 = C_DRED hSep.BorderSizePixel=0 hSep.ZIndex=11 hSep.Parent=panel

-- ── LOGO ──
-- Orbital ring left-side decoration
local ringC = Instance.new("Frame")
ringC.Size = UDim2.new(0,80,0,80) ringC.Position = UDim2.new(0,8,0,34)
ringC.BackgroundTransparency = 1 ringC.ZIndex = 12 ringC.Parent = panel

local outerSegs, innerSegs = {}, {}
for i=1,24 do
    local a = math.rad((i-1)*(360/24))
    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(0,5,0,5)
    seg.Position = UDim2.new(0.5,math.cos(a)*32-2,0.5,math.sin(a)*32-2)
    seg.BackgroundColor3 = i%4==0 and C_BRED or C_RED
    seg.BackgroundTransparency = i%3==0 and 0.1 or 0.5
    seg.BorderSizePixel=0 seg.ZIndex=13 seg.Parent=ringC
    Instance.new("UICorner",seg).CornerRadius=UDim.new(1,0)
    table.insert(outerSegs,{seg=seg,base=(i-1)*(360/24)})
end
for i=1,16 do
    local a = math.rad((i-1)*(360/16))
    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(0,3,0,3)
    seg.Position = UDim2.new(0.5,math.cos(a)*20-1,0.5,math.sin(a)*20-1)
    seg.BackgroundColor3 = C_BRED
    seg.BackgroundTransparency = i%2==0 and 0.15 or 0.65
    seg.BorderSizePixel=0 seg.ZIndex=13 seg.Parent=ringC
    Instance.new("UICorner",seg).CornerRadius=UDim.new(1,0)
    table.insert(innerSegs,{seg=seg,base=(i-1)*(360/16)})
end

local ringAngle = 0
task.spawn(function()
    while sg and sg.Parent do
        ringAngle = ringAngle + 1.8
        for _,d in ipairs(outerSegs) do
            local a = math.rad(d.base + ringAngle)
            d.seg.Position = UDim2.new(0.5,math.cos(a)*32-2,0.5,math.sin(a)*32-2)
        end
        for _,d in ipairs(innerSegs) do
            local a = math.rad(d.base - ringAngle*1.4)
            d.seg.Position = UDim2.new(0.5,math.cos(a)*20-1,0.5,math.sin(a)*20-1)
        end
        task.wait(0.016)
    end
end)

-- Ring center icon
local ringIcon = Instance.new("TextLabel")
ringIcon.Size = UDim2.new(0,44,0,44) ringIcon.Position = UDim2.new(0.5,-22,0.5,-22)
ringIcon.BackgroundTransparency=1 ringIcon.Font=Enum.Font.GothamBlack ringIcon.TextSize=17
ringIcon.TextColor3=C_RED ringIcon.Text="RH" ringIcon.ZIndex=14 ringIcon.Parent=ringC
task.spawn(function()
    while ringIcon and ringIcon.Parent do
        TweenService:Create(ringIcon,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextTransparency=0.5}):Play()
        task.wait(0.8)
        TweenService:Create(ringIcon,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextTransparency=0}):Play()
        task.wait(0.8)
    end
end)

-- Main title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1,-105,0,52) titleLbl.Position = UDim2.new(0,98,0,32)
titleLbl.BackgroundTransparency=1 titleLbl.Font=Enum.Font.GothamBlack titleLbl.TextSize=52
titleLbl.TextColor3=Color3.fromRGB(255,255,255) titleLbl.TextStrokeColor3=C_RED
titleLbl.TextStrokeTransparency=0.15 titleLbl.Text="REDAX" titleLbl.ZIndex=15 titleLbl.Parent=panel

-- Title glitch
task.spawn(function()
    local pool={"R3DAX","R▓DAX","ЯEDAX","RED▌X","◆EDAX","RËDAX","RΣDAX","REDAX"}
    local cols={C_BRED,Color3.fromRGB(255,120,120),C_RED,Color3.fromRGB(255,0,0)}
    while titleLbl and titleLbl.Parent do
        task.wait(math.random(15,35)*0.1)
        local ot,oc=titleLbl.Text,titleLbl.TextColor3
        for _ = 1,math.random(3,7) do
            titleLbl.Text=pool[math.random(#pool)]
            titleLbl.TextColor3=cols[math.random(#cols)]
            titleLbl.Position=UDim2.new(0,98+math.random(-4,4),0,32)
            task.wait(0.03)
        end
        titleLbl.Text=ot titleLbl.TextColor3=oc titleLbl.Position=UDim2.new(0,98,0,32)
    end
end)

local subLbl = Instance.new("TextLabel")
subLbl.Size=UDim2.new(1,-105,0,18) subLbl.Position=UDim2.new(0,98,0,85)
subLbl.BackgroundTransparency=1 subLbl.Font=Enum.Font.GothamBold subLbl.TextSize=12
subLbl.TextColor3=C_RED subLbl.TextXAlignment=Enum.TextXAlignment.Left
subLbl.Text="H U B  |  MM2  ·  v7.0  ·  discord.gg/2Rw9GwXaPj" subLbl.ZIndex=15 subLbl.Parent=panel

-- Separator
local sep2 = Instance.new("Frame")
sep2.Size=UDim2.new(1,-16,0,1) sep2.Position=UDim2.new(0,8,0,116)
sep2.BackgroundColor3=C_DRED sep2.BorderSizePixel=0 sep2.ZIndex=15 sep2.Parent=panel

-- Step labels
local stepsFrame = Instance.new("Frame")
stepsFrame.Size=UDim2.new(1,-16,0,105) stepsFrame.Position=UDim2.new(0,8,0,122)
stepsFrame.BackgroundTransparency=1 stepsFrame.ZIndex=15 stepsFrame.Parent=panel

local stepLabels = {}
for i = 1, 7 do
    local lbl = Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,14) lbl.Position=UDim2.new(0,0,0,(i-1)*14)
    lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.Code lbl.TextSize=11
    lbl.TextColor3=C_DRED lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Text="" lbl.ZIndex=15 lbl.Parent=stepsFrame
    table.insert(stepLabels,lbl)
end

-- Progress bar
local barBg = Instance.new("Frame")
barBg.Size=UDim2.new(1,-16,0,10) barBg.Position=UDim2.new(0,8,0,236)
barBg.BackgroundColor3=Color3.fromRGB(20,0,0) barBg.BorderSizePixel=0
barBg.ZIndex=15 barBg.Parent=panel
Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
local barBgS=Instance.new("UIStroke") barBgS.Color=C_DRED barBgS.Thickness=1 barBgS.Parent=barBg

local barFill = Instance.new("Frame")
barFill.Size=UDim2.new(0,0,1,0) barFill.BackgroundColor3=C_RED
barFill.BorderSizePixel=0 barFill.ZIndex=16 barFill.Parent=barBg
Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)

local barGlowStrip = Instance.new("Frame")
barGlowStrip.Size=UDim2.new(1,0,0,3) barGlowStrip.BackgroundColor3=C_BRED
barGlowStrip.BackgroundTransparency=0.3 barGlowStrip.BorderSizePixel=0
barGlowStrip.ZIndex=17 barGlowStrip.Parent=barFill
Instance.new("UICorner",barGlowStrip).CornerRadius=UDim.new(1,0)

task.spawn(function()
    local bc={C_RED,C_BRED,Color3.fromRGB(170,0,0),C_RED} local bi=1
    while barFill and barFill.Parent do
        TweenService:Create(barFill,TweenInfo.new(0.85,Enum.EasingStyle.Sine),{BackgroundColor3=bc[bi%#bc+1]}):Play()
        bi=bi+1 task.wait(0.85)
    end
end)

-- Status & percent
local statusLbl = Instance.new("TextLabel")
statusLbl.Size=UDim2.new(1,-80,0,16) statusLbl.Position=UDim2.new(0,8,0,251)
statusLbl.BackgroundTransparency=1 statusLbl.Font=Enum.Font.Code statusLbl.TextSize=11
statusLbl.TextColor3=Color3.fromRGB(200,150,150) statusLbl.TextXAlignment=Enum.TextXAlignment.Left
statusLbl.Text="● Initializing..." statusLbl.ZIndex=15 statusLbl.Parent=panel

local pctLbl = Instance.new("TextLabel")
pctLbl.Size=UDim2.new(0,68,0,16) pctLbl.Position=UDim2.new(1,-74,0,251)
pctLbl.BackgroundTransparency=1 pctLbl.Font=Enum.Font.GothamBold pctLbl.TextSize=11
pctLbl.TextColor3=C_RED pctLbl.TextXAlignment=Enum.TextXAlignment.Right
pctLbl.Text="0%" pctLbl.ZIndex=15 pctLbl.Parent=panel

-- Bottom info
local botLbl = Instance.new("TextLabel")
botLbl.Size=UDim2.new(1,-16,0,16) botLbl.Position=UDim2.new(0,8,0,296)
botLbl.BackgroundTransparency=1 botLbl.Font=Enum.Font.Code botLbl.TextSize=10
botLbl.TextColor3=Color3.fromRGB(55,18,18) botLbl.TextXAlignment=Enum.TextXAlignment.Left
botLbl.Text="discord.gg/2Rw9GwXaPj  ·  RedaxHub v7.0  ·  MM2  ·  Stay Undetected"
botLbl.ZIndex=15 botLbl.Parent=panel

-- Corner decorations
local function MkL(px,py,w,h)
    local f=Instance.new("Frame") f.Size=UDim2.new(0,w,0,h) f.Position=UDim2.new(0,px,0,py)
    f.BackgroundColor3=C_RED f.BorderSizePixel=0 f.ZIndex=16 f.Parent=panel
end
MkL(0,0,20,2) MkL(0,0,2,20) MkL(PW-20,0,20,2) MkL(PW-2,0,2,20)
MkL(0,PH-2,20,2) MkL(0,PH-22,2,22) MkL(PW-20,PH-2,20,2) MkL(PW-2,PH-22,2,22)

-- Panel open animation
TweenService:Create(panel,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Size=UDim2.new(0,PW,0,PH), Position=UDim2.new(0.5,-PW/2,0.5,-PH/2)
}):Play()

-- Burst particles
task.spawn(function()
    task.wait(0.5)
    for i = 1, 28 do
        local a = math.rad((i-1)*(360/28))
        local p = Instance.new("Frame")
        p.Size=UDim2.new(0,5,0,5) p.Position=UDim2.new(0.5,-2,0.5,-2)
        p.BackgroundColor3=i%3==0 and C_WHITE or C_RED
        p.BackgroundTransparency=0 p.BorderSizePixel=0 p.ZIndex=20 p.Parent=bg
        Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
        local dist=math.random(90,240)
        TweenService:Create(p,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Position=UDim2.new(0,CX+math.cos(a)*dist-2,0,CY+math.sin(a)*dist-2),
            BackgroundTransparency=1, Size=UDim2.new(0,2,0,2)
        }):Play()
        task.delay(0.77,function() p:Destroy() end)
    end
end)

-- ── LOAD SEQUENCE ──
local loadSteps = {
    {pct=0.08, txt="● Initializing exploit framework...",    col=C_RED},
    {pct=0.18, txt="● Establishing encrypted channel...",    col=C_BRED},
    {pct=0.30, txt="● Injecting core engine...",             col=C_RED},
    {pct=0.42, txt="● Loading aimbot module...",             col=C_BRED},
    {pct=0.54, txt="● Activating ESP subsystem...",          col=C_RED},
    {pct=0.65, txt="● Hooking player controller...",         col=C_BRED},
    {pct=0.75, txt="● Scanning MM2 network remotes...",      col=C_RED},
    {pct=0.85, txt="● Connecting to RedaxHub servers...",    col=C_BRED},
    {pct=0.94, txt="● Bypassing anti-cheat detection...",    col=C_RED},
    {pct=1.00, txt="◉ ALL SYSTEMS ONLINE — ACCESS GRANTED",  col=C_BRED},
}

task.spawn(function()
    task.wait(0.5)
    local stepDur = 3.4 / #loadSteps
    local lineQ   = {}

    for i, step in ipairs(loadSteps) do
        if i == #loadSteps then
            local w = 0
            while not rayfieldReady and w < 25 do task.wait(0.1) w=w+0.1 end
        end
        table.insert(lineQ, {txt=step.txt, col=step.col})
        if #lineQ > 7 then table.remove(lineQ,1) end
        for j, lbl in ipairs(stepLabels) do
            local e = lineQ[j]
            if e then
                lbl.Text = e.txt
                local a = j/#lineQ
                lbl.TextColor3 = Color3.fromRGB(
                    math.floor(e.col.R*255*a + 40*(1-a)),
                    0,
                    0
                )
            else lbl.Text="" end
        end
        statusLbl.Text = step.txt statusLbl.TextColor3 = step.col
        pctLbl.Text = math.floor(step.pct*100).."%"
        TweenService:Create(barFill,TweenInfo.new(stepDur*0.88,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=UDim2.new(step.pct,0,1,0)
        }):Play()
        task.wait(stepDur)
    end

    local extra = 0
    while not rayfieldReady and extra < 15 do task.wait(0.1) extra=extra+0.1 end
    if not rayfieldReady then
        warn("RedaxHub: Rayfield failed!")
        if sg and sg.Parent then sg:Destroy() end
        return
    end

    pStroke.Color=C_BRED titleLbl.TextColor3=C_BRED statusLbl.TextColor3=C_BRED
    task.wait(0.25)

    for _ = 1, 7 do
        TweenService:Create(panel,TweenInfo.new(0.03),{
            Position=UDim2.new(0.5,-PW/2+math.random(-6,6),0.5,-PH/2+math.random(-4,4))
        }):Play()
        task.wait(0.03)
    end
    panel.Position=UDim2.new(0.5,-PW/2,0.5,-PH/2) task.wait(0.15)

    TweenService:Create(panel,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
        Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)
    }):Play()
    TweenService:Create(bg,TweenInfo.new(0.45,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
    task.wait(0.5)
    if sg and sg.Parent then sg:Destroy() end

    _G.RedaxHubStart()
end)

-- =====================================================
-- MAIN SCRIPT
-- =====================================================
function _G.RedaxHubStart()

local function Notify(t, c, d)
    Rayfield:Notify({Title=t, Content=c, Duration=d or 3})
end

-- =====================
-- VARIABLES
-- =====================
local ActiveHL, ActiveBB = {}, {}
local NoclipConn    = nil
local FlySpeed      = 50
local flyEnabled    = false
local infJumpOn     = false
local ijConn        = nil
local walkSpeedVal  = 16
local jumpPowerVal  = 50
local silentAimOn   = false
local aimbotFOV     = 150
local aimbotPart    = "Head"
local fovCircle     = nil
local shootMurdererOn = false
local shootKey      = Enum.KeyCode.E
local knifeThrowOn  = false
local knifeKey      = Enum.KeyCode.Q
local listeningShoot = false
local listeningKnife = false
local mobileOn      = false
local mobileButtons = {}
local mobileGui     = nil
local mobBtnSize    = 72
local lastSheriffCF = nil
local espOn         = false
local chamsOn       = false
local gunEspOn      = false
local coinOn        = false
local killOn        = false
local autoGunOn     = false
local Window        = nil

-- =====================
-- MAP DETECTION
-- =====================
local function FindActiveMap()
    local m = Workspace:FindFirstChild("Map")
    if m and m:IsA("Model") then return m end
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") then
            local n = v.Name:lower()
            if n=="map" or n=="gamemap" or n=="currentmap" or n=="level" then return v end
        end
    end
    local best, bestC = nil, 0
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v~=LocalPlayer.Character then
            local n = v.Name:lower()
            if not n:find("player") and not n:find("camera") and not n:find("baseplate") then
                local c=0 for _,d in pairs(v:GetDescendants()) do if d:IsA("BasePart") then c=c+1 end end
                if c>bestC and c>30 then bestC=c best=v end
            end
        end
    end
    return best
end

-- =====================
-- HELPERS
-- =====================
local function IsAlive(p)
    if not p or not p.Character then return false end
    if not p.Character:IsDescendantOf(Workspace) then return false end
    if not p.Character:FindFirstChild("HumanoidRootPart") then return false end
    local h = p.Character:FindFirstChild("Humanoid")
    return h and h.Health > 0
end
local function GetRole(p)
    if not p or not p.Character then return "Innocent" end
    local c, bp = p.Character, p:FindFirstChild("Backpack")
    if c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "MURDERER" end
    if c:FindFirstChild("Gun")   or (bp and bp:FindFirstChild("Gun"))   then return "Sheriff" end
    return "Innocent"
end
local function GetRoleColor(r)
    if r=="MURDERER" then return Color3.fromRGB(255,50,50) end
    if r=="Sheriff"  then return Color3.fromRGB(50,100,255) end
    return Color3.fromRGB(50,255,50)
end
local function FindSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and IsAlive(p) and GetRole(p)=="Sheriff" then return p end
    end
end
local function FindMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and IsAlive(p) and GetRole(p)=="MURDERER" then return p end
    end
end
local gunCache, gunCacheTime = nil, 0
local function FindGunDrop()
    local now = tick()
    if gunCache and now-gunCacheTime<0.5 and gunCache.Parent then return gunCache.CFrame, gunCache end
    local function chk(item)
        if item.Name=="GunDrop" or item.Name=="Revolver" or item.Name=="DroppedGun" then
            local p=item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if p then gunCache=p gunCacheTime=tick() return p.CFrame,p end
        end
    end
    for _, item in pairs(Workspace:GetChildren()) do
        local cf,p=chk(item) if cf then return cf,p end
        for _, ch in pairs(item:GetChildren()) do local cf2,p2=chk(ch) if cf2 then return cf2,p2 end end
    end
    gunCache=nil return nil,nil
end
local function ClearESP()
    for _,v in pairs(ActiveHL) do pcall(function() v:Destroy() end) end
    for _,v in pairs(ActiveBB) do pcall(function() v:Destroy() end) end
    ActiveHL,ActiveBB={},{}
end
local function ClearGunESP()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v.Name=="MM2_GunHL" or v.Name=="MM2_GunBB" then pcall(function() v:Destroy() end) end
    end
end
local function ClearChams()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v.Name=="MM2_Chams" then pcall(function() v:Destroy() end) end
    end
end

-- =====================
-- FOV
-- =====================
local function CreateFOV()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible=true fovCircle.Radius=aimbotFOV
    fovCircle.Color=Color3.fromRGB(220,0,0) fovCircle.Thickness=1.5
    fovCircle.Filled=false fovCircle.NumSides=64
    fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Transparency=0.55
end
local function RemoveFOV()
    if fovCircle then fovCircle:Remove() fovCircle=nil end
end
local function GetClosestInFOV()
    local center=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, aimbotFOV
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and IsAlive(p) then
            local part=p.Character:FindFirstChild(aimbotPart) or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp,on=Camera:WorldToScreenPoint(part.Position)
                if on then
                    local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if d<bestDist then bestDist=d best=p end
                end
            end
        end
    end
    return best
end

-- =====================
-- FLY
-- =====================
local function EnableFly()
    local char=LocalPlayer.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    pcall(function()
        if hrp:FindFirstChild("MM2_FlyBV") then hrp.MM2_FlyBV:Destroy() end
        if hrp:FindFirstChild("MM2_FlyBG") then hrp.MM2_FlyBG:Destroy() end
    end)
    local bv=Instance.new("BodyVelocity") bv.Name="MM2_FlyBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.new(0,0,0) bv.Parent=hrp
    local bg3=Instance.new("BodyGyro") bg3.Name="MM2_FlyBG" bg3.MaxTorque=Vector3.new(9e9,9e9,9e9) bg3.P=9e4 bg3.CFrame=hrp.CFrame bg3.Parent=hrp
    task.spawn(function()
        while flyEnabled and hrp and hrp.Parent do
            task.wait()
            local cam=Workspace.CurrentCamera local d=Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
            bv.Velocity=d*FlySpeed bg3.CFrame=cam.CFrame
        end
        pcall(function()
            if hrp:FindFirstChild("MM2_FlyBV") then hrp.MM2_FlyBV:Destroy() end
            if hrp:FindFirstChild("MM2_FlyBG") then hrp.MM2_FlyBG:Destroy() end
        end)
    end)
end
local function DisableFly()
    local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        if hrp:FindFirstChild("MM2_FlyBV") then hrp.MM2_FlyBV:Destroy() end
        if hrp:FindFirstChild("MM2_FlyBG") then hrp.MM2_FlyBG:Destroy() end
    end)
end

-- =====================
-- SHOOT (Camera-Independent)
-- Uses RemoteEvent directly — camera direction irrelevant
-- =====================
local function ShootAtTarget(target)
    if not target or not IsAlive(target) then return false end
    local char = LocalPlayer.Character if not char then return false end
    local part = target.Character:FindFirstChild(aimbotPart) or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return false end
    -- Equip tool first
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then
        local bp=LocalPlayer:FindFirstChild("Backpack")
        if bp then tool=bp:FindFirstChildWhichIsA("Tool") end
    end
    if tool then
        if tool.Parent==LocalPlayer:FindFirstChild("Backpack") then
            local hum=char:FindFirstChild("Humanoid")
            if hum then hum:EquipTool(tool) end
            task.wait(0.05)
        end
        -- Fire directly to target position WITHOUT touching camera
        local targetPos = part.Position
        pcall(function()
            local re=tool:FindFirstChildWhichIsA("RemoteEvent")
            if re then re:FireServer(targetPos) end
        end)
        -- Also try all RemoteEvents inside tool
        pcall(function()
            for _,v in pairs(tool:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    v:FireServer(targetPos)
                end
            end
        end)
        -- Try global shoot remotes in ReplicatedStorage
        pcall(function()
            for _,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local n=v.Name:lower()
                    if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                        v:FireServer(targetPos)
                    end
                end
            end
        end)
        pcall(function() tool:Activate() end)
        return true
    end
    return false
end

-- =====================
-- KNIFE THROW (Camera-Independent)
-- =====================
local function ThrowKnifeAtTarget()
    if GetRole(LocalPlayer)~="MURDERER" then Notify("Knife","You are not Murderer!",2) return end
    local char=LocalPlayer.Character if not char then return end
    local target=FindSheriff() or GetClosestInFOV()
    if not target or not IsAlive(target) then Notify("Knife","No target in range!",2) return end
    local part=target.Character:FindFirstChild("HumanoidRootPart") if not part then return end
    local targetPos = part.Position

    -- Get knife tool
    local knife=char:FindFirstChild("Knife")
    if not knife then
        local bp=LocalPlayer:FindFirstChild("Backpack")
        if bp then knife=bp:FindFirstChild("Knife") end
    end
    if knife then
        if knife.Parent==LocalPlayer:FindFirstChild("Backpack") then
            local hum=char:FindFirstChild("Humanoid")
            if hum then hum:EquipTool(knife) end
            task.wait(0.05)
        end
        -- Fire knife RemoteEvents directly with target position
        pcall(function()
            for _,re in pairs(knife:GetDescendants()) do
                if re:IsA("RemoteEvent") then re:FireServer(targetPos) end
            end
        end)
        -- Try all throw/knife/fling remotes in game
        pcall(function()
            for _,loc in pairs({game:GetService("ReplicatedStorage"),Workspace}) do
                for _,v in pairs(loc:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        local n=v.Name:lower()
                        if n:find("throw") or n:find("knife") or n:find("fling") or n:find("stab") then
                            v:FireServer(targetPos)
                        end
                    end
                end
            end
        end)
        pcall(function() knife:Activate() end)
    end
end

-- =====================
-- KEYBINDS
-- =====================
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if listeningShoot then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            shootKey=inp.KeyCode listeningShoot=false
            Notify("Keybind","Key set: "..tostring(inp.KeyCode):gsub("Enum.KeyCode.",""),3)
        end return
    end
    if listeningKnife then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            knifeKey=inp.KeyCode listeningKnife=false
            Notify("Keybind","Key set: "..tostring(inp.KeyCode):gsub("Enum.KeyCode.",""),3)
        end return
    end
    if shootMurdererOn and inp.KeyCode==shootKey then
        local t=FindMurderer() or GetClosestInFOV()
        if t then ShootAtTarget(t) Notify("Shoot","Shot fired!",1)
        else Notify("Shoot","Murderer not found!",2) end
        return
    end
    if knifeThrowOn and inp.KeyCode==knifeKey then ThrowKnifeAtTarget() return end
end)

-- =====================
-- MOBILE BUTTONS
-- =====================
local function UpdMobColor(name, active)
    for _,b in pairs(mobileButtons) do
        if b.Name=="MobBtn_"..name then
            TweenService:Create(b,TweenInfo.new(0.18),{
                BackgroundColor3=active and Color3.fromRGB(170,0,0) or Color3.fromRGB(12,4,4)
            }):Play()
        end
    end
end
local function CreateMobBtn(name,text,px,py,cb)
    if not mobileGui then return end
    local sz=mobBtnSize
    local btn=Instance.new("TextButton")
    btn.Name="MobBtn_"..name btn.Parent=mobileGui
    btn.BackgroundColor3=Color3.fromRGB(12,4,4) btn.BackgroundTransparency=0.05
    btn.BorderSizePixel=0 btn.Position=UDim2.new(0,px,0,py) btn.Size=UDim2.new(0,sz,0,sz)
    btn.Font=Enum.Font.GothamBold btn.Text=text
    btn.TextColor3=Color3.fromRGB(220,170,170)
    btn.TextSize=math.max(9,math.floor(sz*0.155)) btn.TextWrapped=true btn.ZIndex=50 btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local st=Instance.new("UIStroke") st.Color=Color3.fromRGB(160,0,0) st.Thickness=1.5 st.Transparency=0.3 st.Parent=btn
    local dragging,dragStart,startPos,hasDragged=false,nil,nil,false
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true hasDragged=false dragStart=inp.Position startPos=btn.Position
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.45}):Play()
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement) then
            local delta=inp.Position-dragStart
            if delta.Magnitude>8 then
                hasDragged=true
                btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.05}):Play()
            if not hasDragged then cb() end
            dragging=false
        end
    end)
    table.insert(mobileButtons,btn) return btn
end
local function ShowMobileButtons()
    if mobileGui then mobileGui:Destroy() end
    mobileGui=Instance.new("ScreenGui")
    mobileGui.Name="RedaxMobile" mobileGui.ResetOnSpawn=false
    mobileGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    mobileGui.IgnoreGuiInset=true mobileGui.DisplayOrder=100
    mobileGui.Parent=game:GetService("CoreGui")
    mobileButtons={}
    local vp2=Camera.ViewportSize local sz=mobBtnSize
    local bx=math.max(10,vp2.X-sz-16) local by=math.max(10,vp2.Y-(sz+8)*5-10) local gap=sz+8
    local ctrl=Instance.new("Frame")
    ctrl.Size=UDim2.new(0,sz,0,28) ctrl.Position=UDim2.new(0,bx,0,vp2.Y-36)
    ctrl.BackgroundColor3=Color3.fromRGB(10,0,0) ctrl.BackgroundTransparency=0.1
    ctrl.BorderSizePixel=0 ctrl.ZIndex=55 ctrl.Parent=mobileGui
    Instance.new("UICorner",ctrl).CornerRadius=UDim.new(0,8)
    local function mkCtrl(lbl,ox,delta)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,math.floor(sz/3)-2,0,22) b.Position=UDim2.new(0,ox,0,3)
        b.BackgroundColor3=Color3.fromRGB(130,0,0) b.BackgroundTransparency=0.2
        b.BorderSizePixel=0 b.Font=Enum.Font.GothamBold b.Text=lbl
        b.TextColor3=Color3.fromRGB(255,180,180) b.TextSize=15 b.ZIndex=56 b.Parent=ctrl
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
        b.MouseButton1Click:Connect(function()
            mobBtnSize=delta==0 and 72 or math.clamp(mobBtnSize+delta,40,120)
            ShowMobileButtons()
        end)
    end
    local t3=math.floor(sz/3)
    mkCtrl("−",2,-8) mkCtrl("▣",t3+2,0) mkCtrl("+",t3*2+2,8)
    CreateMobBtn("Shoot","🔫\nShoot",bx,by,function()
        local t=FindMurderer() or GetClosestInFOV()
        if t then ShootAtTarget(t) Notify("Shoot","Shot fired!",1) UpdMobColor("Shoot",true) task.delay(0.3,function() UpdMobColor("Shoot",false) end)
        else Notify("Shoot","Murderer not found!",2) end
    end)
    CreateMobBtn("Fly","✈️\nFly",bx,by+gap,function()
        flyEnabled=not flyEnabled
        if flyEnabled then EnableFly() Notify("Fly","Fly ON",2) else DisableFly() Notify("Fly","Fly OFF",2) end
        UpdMobColor("Fly",flyEnabled)
    end)
    CreateMobBtn("NC","👻\nNC",bx,by+gap*2,function()
        if not NoclipConn then
            NoclipConn=RunService.Stepped:Connect(function()
                local c=LocalPlayer.Character
                if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
            end)
            Notify("Noclip","Noclip ON",2)
        else
            NoclipConn:Disconnect() NoclipConn=nil
            pcall(function()
                local c=LocalPlayer.Character
                if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
            end)
            Notify("Noclip","Noclip OFF",2)
        end
        UpdMobColor("NC",NoclipConn~=nil)
    end)
    CreateMobBtn("Jump","🦘\nJump",bx,by+gap*3,function()
        infJumpOn=not infJumpOn
        if infJumpOn then
            if ijConn then ijConn:Disconnect() end
            ijConn=UIS.JumpRequest:Connect(function()
                local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            Notify("Jump","Infinite Jump ON",2)
        else
            if ijConn then ijConn:Disconnect() ijConn=nil end
            Notify("Jump","Infinite Jump OFF",2)
        end
        UpdMobColor("Jump",infJumpOn)
    end)
    CreateMobBtn("Gun","🔫\nGun",bx,by+gap*4,function()
        task.spawn(function()
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local saved=hrp.CFrame Notify("Gun","Grabbing...",2)
            local cf,gp=FindGunDrop()
            if not cf then for i=1,16 do task.wait(0.3) cf,gp=FindGunDrop() if cf then break end end end
            if cf then hrp.CFrame=cf task.wait(0.4) hrp.CFrame=saved Notify("Gun","Gun collected!",2)
            else Notify("Gun","Gun not found.",2) end
        end)
    end)
end
local function HideMobileButtons()
    if mobileGui then mobileGui:Destroy() mobileGui=nil end
    mobileButtons={}
end

-- =====================
-- HUD BAR (top-center: avatar + name + FPS + Ping)
-- =====================
local hudGui = Instance.new("ScreenGui")
hudGui.Name="RedaxHUD" hudGui.ResetOnSpawn=false
hudGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
hudGui.IgnoreGuiInset=true hudGui.DisplayOrder=200
hudGui.Parent=game:GetService("CoreGui")

local hudFrame = Instance.new("Frame")
hudFrame.Size=UDim2.new(0,320,0,38) hudFrame.Position=UDim2.new(0.5,-160,0,6)
hudFrame.BackgroundColor3=Color3.fromRGB(8,0,0) hudFrame.BackgroundTransparency=0.15
hudFrame.BorderSizePixel=0 hudFrame.ZIndex=50 hudFrame.Parent=hudGui
Instance.new("UICorner",hudFrame).CornerRadius=UDim.new(0,8)
local hudStroke=Instance.new("UIStroke") hudStroke.Color=Color3.fromRGB(180,0,0) hudStroke.Thickness=1.2 hudStroke.Parent=hudFrame

-- Avatar image
local avatarImg = Instance.new("ImageLabel")
avatarImg.Size=UDim2.new(0,28,0,28) avatarImg.Position=UDim2.new(0,5,0.5,-14)
avatarImg.BackgroundTransparency=1 avatarImg.ZIndex=51 avatarImg.Parent=hudFrame
Instance.new("UICorner",avatarImg).CornerRadius=UDim.new(1,0)
-- Load avatar thumbnail
task.spawn(function()
    pcall(function()
        local uid = LocalPlayer.UserId
        local thumb = game:GetService("Players"):GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        avatarImg.Image = thumb
    end)
end)

-- Name label
local nameLbl = Instance.new("TextLabel")
nameLbl.Size=UDim2.new(0,110,1,0) nameLbl.Position=UDim2.new(0,37,0,0)
nameLbl.BackgroundTransparency=1 nameLbl.Font=Enum.Font.GothamBold nameLbl.TextSize=12
nameLbl.TextColor3=Color3.fromRGB(255,200,200) nameLbl.TextXAlignment=Enum.TextXAlignment.Left
nameLbl.Text="@"..LocalPlayer.Name nameLbl.ZIndex=51 nameLbl.Parent=hudFrame

-- Separator
local hudSep = Instance.new("Frame")
hudSep.Size=UDim2.new(0,1,0,24) hudSep.Position=UDim2.new(0,150,0.5,-12)
hudSep.BackgroundColor3=Color3.fromRGB(100,0,0) hudSep.BorderSizePixel=0 hudSep.ZIndex=51 hudSep.Parent=hudFrame

-- FPS label
local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size=UDim2.new(0,72,1,0) fpsLbl.Position=UDim2.new(0,158,0,0)
fpsLbl.BackgroundTransparency=1 fpsLbl.Font=Enum.Font.Code fpsLbl.TextSize=11
fpsLbl.TextColor3=Color3.fromRGB(100,255,100) fpsLbl.ZIndex=51 fpsLbl.Parent=hudFrame
fpsLbl.Text="FPS: --"

-- Ping label
local pingLbl = Instance.new("TextLabel")
pingLbl.Size=UDim2.new(0,72,1,0) pingLbl.Position=UDim2.new(0,234,0,0)
pingLbl.BackgroundTransparency=1 pingLbl.Font=Enum.Font.Code pingLbl.TextSize=11
pingLbl.TextColor3=Color3.fromRGB(100,200,255) pingLbl.ZIndex=51 pingLbl.Parent=hudFrame
pingLbl.Text="PING: --"

-- FPS counter
local fpsCount,fpsTimer,fpsSamples = 0,0,{}
RunService.RenderStepped:Connect(function(dt)
    fpsCount = fpsCount + 1
    fpsTimer  = fpsTimer  + dt
    if fpsTimer >= 0.5 then
        local fps = math.floor(fpsCount / fpsTimer)
        fpsCount = 0 fpsTimer = 0
        local col
        if fps >= 55 then col = Color3.fromRGB(100,255,100)
        elseif fps >= 30 then col = Color3.fromRGB(255,220,60)
        else col = Color3.fromRGB(255,80,80) end
        fpsLbl.Text = "FPS: "..fps
        fpsLbl.TextColor3 = col
    end
end)

-- Ping updater
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local ms = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            local col
            if ms < 80 then col=Color3.fromRGB(100,200,255)
            elseif ms < 150 then col=Color3.fromRGB(255,220,60)
            else col=Color3.fromRGB(255,80,80) end
            pingLbl.Text = "PING: "..ms
            pingLbl.TextColor3 = col
        end)
    end
end)

-- =====================
-- PLAYER LIST (for teleport dropdown)
-- =====================
local function GetPlayerOptions()
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(opts, p.Name)
        end
    end
    if #opts == 0 then opts = {"(no players)"} end
    return opts
end

-- =====================
-- WINDOW
-- =====================
Window = Rayfield:CreateWindow({
    Name                   = "RedaxHub | MM2",
    LoadingTitle           = "RedaxHub",
    LoadingSubtitle        = "Murder Mystery 2  v7",
    Theme                  = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings   = true,
    ConfigurationSaving    = {Enabled=false},
    Discord                = {Enabled=true, Invite="2Rw9GwXaPj", RememberJoins=true},
    KeySystem              = false,
})

-- ── AIMBOT TAB ──
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
AimbotTab:CreateToggle({Name="🔫 Shoot Murderer", CurrentValue=false, Flag="ShootMurderer",
    Callback=function(val)
        shootMurdererOn=val
        Notify("Shoot Murderer", val and "Shoot Murderer ON  [Key: E]" or "Shoot Murderer OFF", 2)
    end})
AimbotTab:CreateButton({Name="Shoot Key (default: E)", Callback=function()
    listeningShoot=true Notify("Keybind","Press any key for Shoot...",3)
end})
AimbotTab:CreateSection("Press key → auto-shoot nearest Murderer (camera independent)")

AimbotTab:CreateToggle({Name="🔪 Knife Throw (Murderer only)", CurrentValue=false, Flag="KnifeThrow",
    Callback=function(val)
        knifeThrowOn=val
        Notify("Knife Throw", val and "Knife Throw ON  [Key: Q]" or "Knife Throw OFF", 2)
    end})
AimbotTab:CreateButton({Name="Knife Key (default: Q)", Callback=function()
    listeningKnife=true Notify("Keybind","Press any key for Knife...",3)
end})
AimbotTab:CreateSection("Press key → throw knife at Sheriff (camera independent)")

AimbotTab:CreateToggle({Name="Silent Aim (Sheriff Gun)", CurrentValue=false, Flag="SilentAim",
    Callback=function(val)
        silentAimOn=val
        Notify("Silent Aim", val and "Silent Aim ON" or "Silent Aim OFF", 2)
        if val then
            RunService.RenderStepped:Connect(function()
                if not silentAimOn then return end
                if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
                if GetRole(LocalPlayer)~="Sheriff" then return end
                local t=GetClosestInFOV()
                if not t or not IsAlive(t) then return end
                local part=t.Character:FindFirstChild(aimbotPart) or t.Character:FindFirstChild("HumanoidRootPart")
                if part then Camera.CFrame=CFrame.new(Camera.CFrame.Position,part.Position) end
            end)
        end
    end})
AimbotTab:CreateSlider({Name="FOV Size",Range={20,500},Increment=10,Suffix=" px",CurrentValue=150,Flag="AFOV",
    Callback=function(v) aimbotFOV=v if fovCircle then fovCircle.Radius=v end end})
AimbotTab:CreateDropdown({Name="Target Part",Options={"Head","HumanoidRootPart","Torso","UpperTorso"},
    CurrentOption={"Head"},Flag="AimPart",Callback=function(opt) aimbotPart=opt[1] or "Head" end})
AimbotTab:CreateToggle({Name="Show FOV Circle",CurrentValue=false,Flag="ShowFOV",
    Callback=function(val) if val then CreateFOV() else RemoveFOV() end end})
AimbotTab:CreateSection("ℹ️ Silent Aim: Hold LMB as Sheriff")

-- ── ESP TAB ──
local ESPTab = Window:CreateTab("👁 ESP", 4483362458)
ESPTab:CreateToggle({Name="Player ESP",CurrentValue=false,Flag="ESP",Callback=function(val)
    espOn=val if not val then ClearESP() return end
    task.spawn(function()
        while espOn do
            ClearESP()
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and IsAlive(p) then
                    local role=GetRole(p) local col=GetRoleColor(role)
                    local hrp=p.Character.HumanoidRootPart
                    local bb=Instance.new("BillboardGui") bb.Name="MM2_BB" bb.Parent=hrp bb.AlwaysOnTop=true
                    bb.Size=UDim2.new(0,130,0,45) bb.StudsOffset=Vector3.new(0,3.5,0)
                    local lbl=Instance.new("TextLabel") lbl.Parent=bb lbl.BackgroundTransparency=1 lbl.Size=UDim2.new(1,0,1,0)
                    lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextStrokeTransparency=0
                    lbl.Text=p.Name.."\n["..role.."]" lbl.TextColor3=col
                    table.insert(ActiveBB,bb)
                    local hl=Instance.new("Highlight") hl.Name="MM2_HL" hl.Parent=p.Character
                    hl.FillColor=col hl.OutlineColor=col hl.FillTransparency=0.6 hl.OutlineTransparency=0
                    table.insert(ActiveHL,hl)
                end
            end
            task.wait(2)
        end
    end)
end})
ESPTab:CreateToggle({Name="Role Chams (Murderer=Red, Sheriff=Blue)",CurrentValue=false,Flag="Chams",Callback=function(val)
    chamsOn=val if not val then ClearChams() return end
    task.spawn(function()
        while chamsOn do
            ClearChams()
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and IsAlive(p) then
                    local role=GetRole(p) local col=GetRoleColor(role)
                    if role~="Innocent" then
                        local hl=Instance.new("Highlight") hl.Name="MM2_Chams" hl.Parent=p.Character
                        hl.FillColor=col hl.OutlineColor=col hl.FillTransparency=0.25 hl.OutlineTransparency=0
                        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    end
                end
            end
            task.wait(2)
        end
    end)
end})
ESPTab:CreateToggle({Name="Gun Drop ESP",CurrentValue=false,Flag="GunESP",Callback=function(val)
    gunEspOn=val if not val then ClearGunESP() return end
    task.spawn(function()
        while gunEspOn do
            ClearGunESP()
            local cf,gp=FindGunDrop()
            if gp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if not gp:FindFirstChild("MM2_GunBB") then
                    local dist=math.floor((LocalPlayer.Character.HumanoidRootPart.Position-gp.Position).Magnitude)
                    local bb=Instance.new("BillboardGui") bb.Name="MM2_GunBB" bb.Parent=gp
                    bb.AlwaysOnTop=true bb.Size=UDim2.new(0,180,0,45) bb.StudsOffset=Vector3.new(0,2,0)
                    local lbl=Instance.new("TextLabel") lbl.Parent=bb lbl.BackgroundTransparency=1
                    lbl.Size=UDim2.new(1,0,1,0) lbl.Font=Enum.Font.GothamBold lbl.TextSize=14
                    lbl.TextStrokeTransparency=0 lbl.TextColor3=Color3.fromRGB(255,215,0)
                    lbl.Text="🔫 GUN | "..dist.." studs"
                    local hl=Instance.new("Highlight") hl.Name="MM2_GunHL" hl.Parent=gp
                    hl.FillColor=Color3.fromRGB(255,215,0) hl.OutlineColor=Color3.fromRGB(255,215,0)
                    hl.FillTransparency=0.3 hl.OutlineTransparency=0
                end
            end
            task.wait(1.5)
        end
    end)
end})

-- ── PLAYER TAB ──
local PlayerTab = Window:CreateTab("🏃 Player", 4483362458)
PlayerTab:CreateSlider({Name="Walk Speed",Range={16,250},Increment=1,Suffix="",CurrentValue=16,Flag="WS",
    Callback=function(v) walkSpeedVal=v end})
PlayerTab:CreateSlider({Name="Jump Power",Range={50,300},Increment=1,Suffix="",CurrentValue=50,Flag="JP",
    Callback=function(v) jumpPowerVal=v end})
task.spawn(function()
    while true do task.wait(1) pcall(function()
        local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed=walkSpeedVal h.JumpPower=jumpPowerVal end
    end) end
end)
PlayerTab:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="IJ",Callback=function(val)
    infJumpOn=val
    if val then
        if ijConn then ijConn:Disconnect() end
        ijConn=UIS.JumpRequest:Connect(function()
            local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else if ijConn then ijConn:Disconnect() ijConn=nil end end
end})
PlayerTab:CreateToggle({Name="Fly (WASD + Space/Shift)",CurrentValue=false,Flag="Fly",Callback=function(val)
    flyEnabled=val if val then EnableFly() else DisableFly() end
end})
PlayerTab:CreateSlider({Name="Fly Speed",Range={10,300},Increment=5,Suffix="",CurrentValue=50,Flag="FS",
    Callback=function(v) FlySpeed=v end})
PlayerTab:CreateToggle({Name="Noclip",CurrentValue=false,Flag="NC",Callback=function(val)
    if val then
        NoclipConn=RunService.Stepped:Connect(function()
            local c=LocalPlayer.Character
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect() NoclipConn=nil end
        pcall(function()
            local c=LocalPlayer.Character
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
        end)
    end
end})

-- ── ROLE TAB ──
local RoleTab = Window:CreateTab("🎭 Role", 4483362458)
RoleTab:CreateSection("RemoteEvent Role (Round Start)")
RoleTab:CreateButton({Name="🔪 Try Become Murderer",Callback=function()
    task.spawn(function() pcall(function()
        for _,loc in pairs({game:GetService("ReplicatedStorage"),Workspace}) do
            for _,v in pairs(loc:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    for _,kw in pairs({"role","assign","murder","setteam","team","character"}) do
                        if v.Name:lower():find(kw) then
                            pcall(function() v:FireServer("Murderer") v:FireServer(1) v:FireServer(LocalPlayer,"Murderer") end)
                        end
                    end
                end
            end
        end
        Notify("Role","Role remote fired!",4)
    end) end)
end})
RoleTab:CreateButton({Name="🔫 Try Become Sheriff",Callback=function()
    task.spawn(function() pcall(function()
        for _,loc in pairs({game:GetService("ReplicatedStorage"),Workspace}) do
            for _,v in pairs(loc:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    for _,kw in pairs({"role","assign","sheriff","setteam","team","character"}) do
                        if v.Name:lower():find(kw) then
                            pcall(function() v:FireServer("Sheriff") v:FireServer(2) v:FireServer(LocalPlayer,"Sheriff") end)
                        end
                    end
                end
            end
        end
        Notify("Role","Role remote fired!",4)
    end) end)
end})
RoleTab:CreateButton({Name="🔍 Scan MM2 Remotes (F9)",Callback=function()
    print("\n=== MM2 REMOTES ===")
    for _,loc in pairs({game:GetService("ReplicatedStorage"),Workspace,game:GetService("ReplicatedFirst")}) do
        for _,v in pairs(loc:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v.ClassName.." | "..v:GetFullName()) end
        end
    end
    print("===================\n")
    Notify("Debug","Remotes printed to F9.",3)
end})

-- ── TELEPORT TAB ──
local TeleportTab = Window:CreateTab("⚡ Teleport", 4483362458)
TeleportTab:CreateButton({Name="Teleport to Murderer",Callback=function()
    local m=FindMurderer()
    if m then LocalPlayer.Character.HumanoidRootPart.CFrame=m.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3) Notify("TP","→ "..m.Name,3)
    else Notify("Error","Murderer not found!",3) end
end})
TeleportTab:CreateButton({Name="Teleport to Sheriff",Callback=function()
    local s=FindSheriff()
    if s then LocalPlayer.Character.HumanoidRootPart.CFrame=s.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3) Notify("TP","→ "..s.Name,3)
    else Notify("Error","Sheriff not found!",3) end
end})

-- Player-Select TP (with refresh)
TeleportTab:CreateSection("Teleport to Selected Player")

local tpPlayerList = GetPlayerOptions()
local tpSelectedPlayer = tpPlayerList[1]

local tpDropdown -- forward ref
tpDropdown = TeleportTab:CreateDropdown({
    Name       = "Select Player",
    Options    = tpPlayerList,
    CurrentOption = {tpPlayerList[1]},
    Flag       = "TPPlayer",
    Callback   = function(opt)
        tpSelectedPlayer = opt[1] or tpPlayerList[1]
    end,
})

TeleportTab:CreateButton({Name="⚡ Teleport to Selected Player",Callback=function()
    local char=LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then Notify("Error","Character not found!",3) return end
    local target=Players:FindFirstChild(tpSelectedPlayer)
    if not target or not IsAlive(target) then Notify("Error","Player not found or not alive!",3) return end
    char.HumanoidRootPart.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)
    Notify("TP","→ "..tpSelectedPlayer,3)
end})

TeleportTab:CreateButton({Name="🔄 Refresh Player List",Callback=function()
    tpPlayerList = GetPlayerOptions()
    tpSelectedPlayer = tpPlayerList[1]
    pcall(function()
        tpDropdown:Refresh(tpPlayerList, true)
    end)
    Notify("TP","Player list refreshed! ("..#tpPlayerList.." players)",3)
end})

-- ── FARM TAB ──
local FarmTab = Window:CreateTab("💰 Farm", 4483362458)
FarmTab:CreateToggle({Name="Coin Farm",CurrentValue=false,Flag="CF",Callback=function(val)
    coinOn=val Notify("Farm",val and "Coin Farm ON" or "Coin Farm OFF",2)
    if not val then return end
    task.spawn(function()
        while coinOn do task.wait(0.15) pcall(function()
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _,v in pairs(Workspace:GetChildren()) do
                if not coinOn then break end
                if v.Name=="Coin" then local p=v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart") if p then hrp.CFrame=p.CFrame task.wait(0.1) end end
                for _,c in pairs(v:GetChildren()) do
                    if not coinOn then break end
                    if c.Name=="Coin" then local p=c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart") if p then hrp.CFrame=p.CFrame task.wait(0.1) end end
                end
            end
        end) end
    end)
end})
FarmTab:CreateToggle({Name="Kill All (Murderer Only)",CurrentValue=false,Flag="KA",Callback=function(val)
    killOn=val Notify("Farm",val and "Kill All ON" or "Kill All OFF",2)
    if not val then return end
    task.spawn(function()
        while killOn do task.wait(0.5) pcall(function()
            local char=LocalPlayer.Character if not char then return end
            if GetRole(LocalPlayer)~="MURDERER" then killOn=false Notify("Kill All","You are not Murderer!",2) return end
            local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
            local myY=hrp.Position.Y
            for _,p in pairs(Players:GetPlayers()) do
                if not killOn then break end
                if p~=LocalPlayer and IsAlive(p) then
                    local phrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if phrp and math.abs(phrp.Position.Y-myY)<100 then hrp.CFrame=phrp.CFrame task.wait(0.4) end
                end
            end
        end) end
    end)
end})
FarmTab:CreateSection("Auto Gun Features")
task.spawn(function()
    while true do task.wait(0.5) pcall(function()
        local s=FindSheriff()
        if s and IsAlive(s) then lastSheriffCF=s.Character.HumanoidRootPart.CFrame end
    end) end
end)
FarmTab:CreateToggle({Name="Auto Collect Gun (Sheriff Dies)",CurrentValue=false,Flag="AG",Callback=function(val)
    autoGunOn=val
    if not val then return end
    task.spawn(function()
        local wasAlive=FindSheriff()~=nil
        while autoGunOn do task.wait(0.5) pcall(function()
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if GetRole(LocalPlayer)=="Sheriff" then autoGunOn=false Notify("Auto Gun","You are already Sheriff!",3) return end
            local sheriff=FindSheriff()
            if sheriff then wasAlive=true
            elseif wasAlive then
                wasAlive=false Notify("Auto Gun","Sheriff died! Finding gun...",3)
                local found=false
                for i=1,33 do
                    task.wait(0.3) if not autoGunOn then break end
                    local cf,gp=FindGunDrop()
                    if cf then
                        hrp.CFrame=cf found=true task.wait(0.4)
                        Notify("Auto Gun","Gun collected! Returning...",2)
                        if lastSheriffCF then hrp.CFrame=lastSheriffCF Notify("Auto Gun","Returned!",3) end
                        break
                    end
                end
                if not found then Notify("Auto Gun","Gun not found.",3) end
            end
        end) end
    end)
end})
FarmTab:CreateButton({Name="⚡ Grab Gun Now",Callback=function()
    task.spawn(function()
        local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then Notify("Error","Character not found!",3) return end
        local saved=hrp.CFrame Notify("Grab Gun","Grabbing...",2)
        local cf,gp=FindGunDrop()
        if not cf then for i=1,16 do task.wait(0.3) cf,gp=FindGunDrop() if cf then break end end end
        if cf then hrp.CFrame=cf task.wait(0.4) Notify("Grab Gun","Collected!",2) task.wait(0.2) hrp.CFrame=saved Notify("Grab Gun","Returned!",2)
        else Notify("Grab Gun","Gun not found.",3) end
    end)
end})
FarmTab:CreateSection("Sheriff Kill & Gun Grab")
FarmTab:CreateButton({Name="⚡ Kill Sheriff → Grab Gun → Return",Callback=function()
    task.spawn(function()
        local char=LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then Notify("Error","Character not found!",3) return end
        local sheriff=FindSheriff()
        if not sheriff or not IsAlive(sheriff) then Notify("Error","Sheriff not found!",3) return end
        local myHRP=char:FindFirstChild("HumanoidRootPart")
        local sHRP=sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart")
        if not sHRP then return end
        local savedCF=sHRP.CFrame
        Notify("Kill Sheriff","Sending Sheriff to void...",2)
        for i=1,8 do
            task.wait(0.05)
            pcall(function() sHRP.CFrame=CFrame.new(savedCF.X,-200-(i*100),savedCF.Z) end)
            if not IsAlive(sheriff) then break end
        end
        local dead=false
        for i=1,20 do
            task.wait(0.3) if not IsAlive(sheriff) then dead=true break end
            if i%3==0 then pcall(function() if sHRP and sHRP.Parent then sHRP.CFrame=CFrame.new(savedCF.X,-500,savedCF.Z) end end) end
        end
        if not dead then Notify("Kill Sheriff","Failed. Anti-cheat may be blocking.",4) return end
        Notify("Kill Sheriff","Sheriff dead! Finding gun...",2)
        local gunFound=false
        for i=1,25 do
            task.wait(0.3)
            local cf,gp=FindGunDrop()
            if cf then myHRP.CFrame=cf gunFound=true task.wait(0.3) Notify("Kill Sheriff","Gun collected!",2) break end
        end
        if not gunFound then Notify("Kill Sheriff","Gun not found.",3) end
        task.wait(0.2) myHRP.CFrame=savedCF Notify("Kill Sheriff","Returned!",3)
    end)
end})

-- ── SETTINGS TAB ──
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- UI Theme changer
SettingsTab:CreateSection("🎨 UI Theme")
SettingsTab:CreateDropdown({
    Name          = "Rayfield Theme",
    Options       = {"Default","Dark Red","Amethyst","Ocean","Aqua"},
    CurrentOption = {"Default"},
    Flag          = "UITheme",
    Callback      = function(opt)
        local o = opt[1] or "Default"
        local themeMap = {
            ["Default"]  = "Default",
            ["Dark Red"]  = "DarkRed",
            ["Amethyst"] = "Amethyst",
            ["Ocean"]    = "Ocean",
            ["Aqua"]     = "Aqua",
        }
        pcall(function()
            Rayfield:SetTheme(themeMap[o] or "Default")
        end)
        Notify("Theme","Theme set: "..o,3)
    end,
})

SettingsTab:CreateSection("📱 Mobile Buttons")
SettingsTab:CreateToggle({Name="Mobile Support",CurrentValue=false,Flag="Mobile",Callback=function(val)
    mobileOn=val
    if val then ShowMobileButtons() Notify("Mobile","Mobile buttons shown!",3)
    else HideMobileButtons() Notify("Mobile","Mobile buttons hidden!",3) end
end})
SettingsTab:CreateSlider({Name="Mobile Button Size",Range={40,120},Increment=4,Suffix=" px",CurrentValue=72,Flag="MobSize",
    Callback=function(v) mobBtnSize=v if mobileOn then ShowMobileButtons() end end})

-- ── DEBUG TAB ──
local DebugTab = Window:CreateTab("🔍 Debug", 4483362458)
DebugTab:CreateSection("Debug Tools")
DebugTab:CreateButton({Name="Toggle Role Chams",Callback=function()
    local found=false
    for _,v in pairs(Workspace:GetDescendants()) do if v.Name=="MM2_Chams" then found=true break end end
    if found then ClearChams() Notify("Debug","Chams cleared.",3)
    else
        ClearChams() local any=false
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and IsAlive(p) then
                local role=GetRole(p) local col=GetRoleColor(role)
                if role~="Innocent" then
                    any=true
                    local hl=Instance.new("Highlight") hl.Name="MM2_Chams" hl.Parent=p.Character
                    hl.FillColor=col hl.OutlineColor=col hl.FillTransparency=0.2 hl.OutlineTransparency=0
                    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
        Notify("Debug",any and "Murderer=RED | Sheriff=BLUE" or "No roles found.",4)
    end
end})
DebugTab:CreateButton({Name="Print Roles (F9)",Callback=function()
    print("\n=== REDAXHUB ROLES ===")
    for _,p in pairs(Players:GetPlayers()) do
        print(p.Name.." --> "..GetRole(p)..(IsAlive(p) and " [ALIVE]" or " [DEAD/LOBBY]"))
    end
    print("======================\n")
    Notify("Debug","Roles printed to F9.",3)
end})

Notify("RedaxHub v7 Loaded!","MM2 Hub | All Features Ready",5)
print("✅ RedaxHub MM2 v7 loaded!")

end -- RedaxHubStart
