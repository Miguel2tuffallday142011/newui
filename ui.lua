local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local Mouse            = LocalPlayer:GetMouse()

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════
-- ADONIS ANTICHEAT BYPASS
-- ═══════════════════════════════════════════════════════════════
local DEBUG  = false
local Hooked = {}
local Detected, Kill

pcall(function() setthreadidentity(2) end)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc   = rawget(v, "Kill")
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then warn("Adonis flagged: "..tostring(Action)) end
                end
                return true
            end)
            table.insert(Hooked, Detected)
        end
        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then warn("Adonis tried to kill: "..tostring(Info)) end
            end)
            table.insert(Hooked, Kill)
        end
    end
end

pcall(function()
    local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local LevelOrFunc, Info = ...
        if Detected and LevelOrFunc == Detected then
            return coroutine.yield(coroutine.running())
        end
        return Old(...)
    end))
end)

pcall(function() setthreadidentity(7) end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Miguel2tuffallday142011/newui/refs/heads/main/ui.lua"))()

local Window = Library:Window({
    Name = 'cipher<font color="rgb(126, 192, 255)">.win</font>',
})

-- ═══════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════
local LB = {
    Enabled     = false,
    TargetPart  = "Head",
    RefreshRate = 0,
    Sticky      = false,
    TeamCheck   = true,
    Active      = false,
    Target      = nil,
    AutoFire    = false,
    FireCooldown = 0.1,
    ShotDelay    = 0,
}

-- Aim Assist (Aimlock) state
local AA = {
    Enabled      = false,
    Active       = false,
    Target       = nil,
    TargetPart   = "Head",
    Smoothing    = false,
    SmoothValue  = 50,
    Style        = "Linear",
    Direction    = "Center",
    Shake        = false,
    ShakeValue   = 10,
    FOVEnabled   = false,
    FOVRadius    = 100,
    TeamCheck    = true,
    AliveCheck   = true,
    WallCheck    = false,
    FOVCheck     = true,
    Notifications = true,
    Prediction   = 0.13,
}

-- Silent Aim state
local SA = {
    Enabled     = false,
    TargetPart  = "Head",
    HitChance   = 100,
    FOVEnabled  = false,
    FOVRadius   = 100,
    Humanization = false,
    HumanizationAmount = 5,
}

local SL = {
    Enabled   = false,
    MainColor = Color3.fromRGB(100, 150, 255),
    SideColor = Color3.fromRGB(0, 0, 0),
    Thickness = 1,
    Origin    = "Character",
}

local HL = {
    Enabled      = false,
    FillColor    = Color3.fromRGB(100, 150, 255),
    OutlineColor = Color3.fromRGB(0, 0, 0),
}
local _highlight = nil

local BX = {
    Enabled      = false,
    Color        = Color3.fromRGB(100, 150, 255),
    Transparency = 0.5,
}
local _boxPart = nil

-- ESP state
local ESP = {
    Enabled      = false,
    LocalPlayer  = false,
    BoxEnabled   = false,
    BoxMain      = Color3.fromRGB(255, 255, 255),
    BoxOutline   = Color3.fromRGB(0, 0, 0),
    FillEnabled  = false,
    FillColor    = Color3.fromRGB(255, 255, 255),
    FillTransp   = 0.5,
    NameEnabled  = false,
    NameColor    = Color3.fromRGB(255, 255, 255),
    NameOutline  = Color3.fromRGB(0, 0, 0),
    -- Material
    MatEnabled   = false,
    MatType      = "ForceField",
    MatColor     = Color3.fromRGB(100, 150, 255),
    -- Highlight (behind walls)
    HLEnabled    = false,
    HLFill       = Color3.fromRGB(100, 150, 255),
    HLOutline    = Color3.fromRGB(255, 255, 255),
    HLWalls      = true,
    -- Chams
    ChamsEnabled = false,
    ChamsMain    = Color3.fromRGB(255, 50, 50),
    ChamsOutline = Color3.fromRGB(0, 0, 0),
    -- Weapon
    WepEnabled   = false,
    WepMain      = Color3.fromRGB(255, 200, 50),
    WepOutline   = Color3.fromRGB(0, 0, 0),
    -- Health bar
    HBEnabled    = false,
    HBMain       = Color3.fromRGB(50, 255, 100),
    HBOutline    = Color3.fromRGB(0, 0, 0),
    -- Team check
    TeamCheck    = true,
}
local _espHighlights = {}

-- Self ESP state
local SE = {
    HLEnabled    = false,
    HLFill       = Color3.fromRGB(100, 150, 255),
    HLOutline    = Color3.fromRGB(255, 255, 255),
    MatEnabled   = false,
    MatColor     = Color3.fromRGB(100, 150, 255),
    MatType      = "ForceField",
    MatToolEnabled = false,
    MatToolColor = Color3.fromRGB(255, 200, 50),
    MatToolType  = "Neon",
    ChinaEnabled = false,
    ChinaColor   = Color3.fromRGB(200, 200, 255),
    ChinaMat     = "SmoothPlastic",
    ChinaHeight  = 0.3,
    ChinaRadius  = 3,
    ChinaOffsetY = 0.5,
    AuraEnabled  = false,
    AuraColor    = Color3.fromRGB(100, 150, 255),
    AuraParticle = "sparkles",
    TrailEnabled = false,
    TrailColor   = Color3.fromRGB(100, 150, 255),
    TrailLifetime= 0.5,
    JumpAuraEnabled  = false,
    JumpAuraColor    = Color3.fromRGB(100, 150, 255),
    JumpAuraLifetime = 0.5,
}
-- Self ESP instances
local _seHL       = nil
local _seMatParts = {}
local _seChina    = nil
local _seAura     = nil
local _seTrail    = nil

-- Hit Feedback state
local HF = {
    -- Hit Sound
    SoundEnabled  = false,
    SoundType     = "neverlose",
    SoundVolume   = 1.0,
    -- Hit Overlay
    OverlayEnabled = false,
    OverlayColor   = Color3.fromRGB(133, 220, 255),
    OverlayTransp  = 0.8,
    OverlayLifetime= 0.7,
    -- 2D Hit Marker
    HM2DEnabled    = false,
    HM2DColor      = Color3.fromRGB(255, 255, 255),
    HM2DOutline    = Color3.fromRGB(15, 15, 15),
    HM2DThickness  = 2,
    HM2DLifetime   = 0.7,
    -- Hit Chams
    ChamsEnabled   = false,
    ChamsColor     = Color3.fromRGB(142, 242, 255),
    ChamsTransp    = 0.8,
    ChamsType      = "neon",
    ChamsLifetime  = 0.8,
    ChamsAnimation = "new fade",
}

-- Hit sound assets (rbxassetid)
local _hitSounds = {
    neverlose  = "rbxassetid://8679627751",
    skeet      = "rbxassetid://5565851439",
    ["mc bow"] = "rbxassetid://6607339542",
    rust       = "rbxassetid://5043539486",
    bubble     = "rbxassetid://6534947240",
    beep       = "rbxassetid://8177256911",
}
local _seToolParts= {}
local _seChina    = nil
local _seAura     = nil
local _seTrail    = nil -- player -> Highlight instance
local _espEntries = {}

-- Utility state
local UT = {
    FaceTarget  = false,
    Strafe      = false,
    StrafeSpeed = 2,
    StrafeHeight = 0,
    StrafeRange = 8,
}
local _strafeAngle = 0

-- Server Position (dot on stomach) state
local SP = {
    Enabled      = false,
    MainColor    = Color3.fromRGB(100, 150, 255),
    OutlineColor = Color3.fromRGB(0, 0, 0),
    Size         = 12,
}
local _spDot = nil
local _spOutline = nil

-- Hitbox Expander state
local HBE = {
    Enabled         = false,
    SizeX           = 2,
    SizeY           = 2,
    SizeZ           = 2,
    FillColor       = Color3.fromRGB(100, 150, 255),
    OutlineColor    = Color3.fromRGB(255, 255, 255),
    FillTransp      = 0.8,
    OutlineTransp   = 0,
}
local _hbeBoxes = {}

-- World / lighting state
local Lighting = game:GetService("Lighting")

local WLD = {
    -- Color correction
    CC_Enabled    = false,
    CC_Color      = Color3.fromRGB(255, 255, 255),
    CC_Saturation = 0,
    CC_Contrast   = 0,
    CC_Brightness = 0,
    -- Atmosphere
    ATM_Enabled   = false,
    ATM_Color     = Color3.fromRGB(199, 170, 120),
    ATM_Glare     = 0,
    ATM_Haze      = 0,
    ATM_Offset    = 0,
    ATM_Density   = 0.395,
    -- Skybox
    SKY_Enabled   = false,
    SKY_Name      = "default",
    -- Rain
    RAIN_Enabled  = false,
    RAIN_Color    = Color3.fromRGB(180, 200, 255),
    RAIN_Type     = "drizzle",
    RAIN_Rate     = 50,
    RAIN_Lifetime = 3,
    RAIN_Speed    = 0.5,
    -- Ambient sound
    AMB_Enabled   = false,
    AMB_Sound     = "night",
    AMB_Volume    = 0.5,
    -- Bloom
    BLM_Enabled   = false,
    BLM_Threshold = 0.95,
    BLM_Size      = 24,
    BLM_Intensity = 1,
    -- Sun rays
    SUN_Enabled   = false,
    SUN_Intensity = 0.25,
    SUN_Spread    = 1,
    -- Textures
    TEX_Enabled   = false,
    TEX_Pack      = "minecraft",
    -- Fog
    FOG_Enabled   = false,
    FOG_Start     = 0,
    FOG_End       = 100000,
    -- Clock
    CLK_Enabled   = false,
    CLK_Time      = 14,
    -- Brightness
    LBR_Enabled   = false,
    LBR_Value     = 2,
    -- Shadows
    GSH_Enabled   = false,
    -- Lighting tech
    LTM_Mode      = "Voxel",
}

-- World effect instances
local _ccEffect   = nil
local _atmEffect  = nil
local _skyObj     = nil
local _rainParts  = {}
local _rainGui    = nil
local _ambSound   = nil
local _blmEffect  = nil
local _sunEffect  = nil
local _materialVariants = {}

-- Skybox data (from juju)
local _skyboxes = {
    ["default"]          = nil, -- use game default
    ["night"]            = {Bk="48020371",Dn="48020144",Ft="48020234",Lf="48020211",Rt="48020254",Up="48020383"},
    ["space"]            = {Bk="149397692",Dn="149397686",Ft="149397697",Lf="149397684",Rt="149397688",Up="149397702"},
    ["minecraft"]        = {Bk="1876545003",Dn="1876544331",Ft="1876542941",Lf="1876543392",Rt="1876543764",Up="1876544642"},
    ["purple day"]       = {Bk="296908715",Dn="296908724",Ft="296908740",Lf="296908755",Rt="296908764",Up="296908769"},
    ["red night"]        = {Bk="401664839",Dn="401664862",Ft="401664960",Lf="401664881",Rt="401664901",Up="401664936"},
    ["starry night"]     = {Bk="8291078911",Dn="8291077403",Ft="8291081613",Lf="8291074004",Rt="8291080353",Up="8291075054"},
    ["sunset"]           = {Bk="150939022",Dn="150939038",Ft="150939047",Lf="150939056",Rt="150939063",Up="150939082"},
    ["pink day"]         = {Bk="271042516",Dn="271077243",Ft="271042556",Lf="271042310",Rt="271042467",Up="271077958"},
    ["vibe morning"]     = {Bk="1417494030",Dn="1417494146",Ft="1417494253",Lf="1417494402",Rt="1417494499",Up="1417494643"},
    ["vibe night"]       = {Bk="5084575798",Dn="5084575916",Ft="5103949679",Lf="5103948542",Rt="5103948784",Up="5084576400"},
    ["clear day"]        = {Bk="591058823",Dn="591059876",Ft="591058104",Lf="591057861",Rt="591057625",Up="591059642"},
    ["hell sky"]         = {Bk="437430787",Dn="437430804",Ft="437430543",Lf="437430732",Rt="437430747",Up="437430771"},
    ["snowy"]            = {Bk="155657655",Dn="155674246",Ft="155657609",Lf="155657671",Rt="155657619",Up="155674931"},
    ["desert"]           = {Bk="161319957",Dn="161319965",Ft="161319970",Lf="161319983",Rt="161319989",Up="161319996"},
    ["anime"]            = {Bk="7643700666",Dn="7643743687",Ft="7644304186",Lf="7644288724",Rt="7643700819",Up="7643757404"},
    ["purple splash"]    = {Bk="8539982183",Dn="8539981943",Ft="8539981721",Lf="8539981424",Rt="8539980766",Up="8539981085"},
    ["green space"]      = {Bk="159248188",Dn="159248183",Ft="159248187",Lf="159248173",Rt="159248192",Up="159248176"},
    ["walls of autumn"]  = {Bk="7123244709",Dn="7123246497",Ft="7123255895",Lf="7123257992",Rt="7123279103",Up="7123281828"},
    ["crimson"]          = {Bk="15832429892",Dn="15832430998",Ft="15832430210",Lf="15832430671",Rt="15832431198",Up="15832429401"},
    ["earth space"]      = {Bk="15753305495",Dn="15753362674",Ft="15753305823",Lf="15753310707",Rt="15753304774",Up="15753304473"},
    ["blue abyss"]       = {Bk="16269815885",Dn="16269839652",Ft="16269798011",Lf="16269813852",Rt="16269814948",Up="16269829700"},
}

-- Texture packs
local _texturePacks = {
    ["minecraft"] = {
        Slate="http://www.roblox.com/asset/?id=8676746437",
        Grass="http://www.roblox.com/asset/?id=9267183930",
        Sand="http://www.roblox.com/asset/?id=12624140843",
        Wood="http://www.roblox.com/asset/?id=3258599312",
        Brick="http://www.roblox.com/asset/?id=10777285622",
        Concrete="http://www.roblox.com/asset/?id=15622710576",
        Metal="http://www.roblox.com/asset/?id=121650613091353",
        WoodPlanks="http://www.roblox.com/asset/?id=8676581022",
    },
    ["smooth"] = {
        Slate="rbxassetid://2101503",
        Grass="rbxassetid://9867892",
        Sand="rbxassetid://6372755",
        Wood="rbxassetid://5092888",
        Brick="rbxassetid://11311525",
        Concrete="rbxassetid://1693652",
        Metal="rbxassetid://2101503",
        WoodPlanks="rbxassetid://5092888",
    },
}

-- Ambient sound IDs
local _ambientSounds = {
    ["night"]        = "179507208",
    ["storm"]        = "9112853422",
    ["rain"]         = "18862087062",
    ["windy winter"] = "6046340391",
    ["space"]        = "140533822783920",
    ["day ambience"] = "6189453706",
    ["raindrop"]     = "122813811029978",
}-- ── Drawing lines ────────────────────────────────────────────
local _lMain  = Drawing.new("Line")
local _lLeft  = Drawing.new("Line")
local _lRight = Drawing.new("Line")
for _, l in ipairs({_lMain, _lLeft, _lRight}) do
    l.Visible = false; l.Thickness = 1; l.ZIndex = 5
end

-- ── Helpers ───────────────────────────────────────────────────
local function active()
    return LB.Enabled and LB.Active and LB.Target ~= nil and LB.Target.Parent ~= nil
end

local function getDir(o, p)
    return (p - o).Unit * 1000
end

-- ── Notification system ───────────────────────────────────────
local _activeNotifications = {}

local function showNotification(text)
    if not AA.Notifications then return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "AANotif"
    gui.DisplayOrder = 10000
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end
    
    -- Calculate position (stack downwards)
    local yOffset = 0
    for _, notif in ipairs(_activeNotifications) do
        if notif and notif.Parent then
            yOffset = yOffset + 35
        end
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 28)
    frame.Position = UDim2.new(0.5, 0, 0.88 - (yOffset * 0.001), yOffset)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, -4)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Progress line at bottom
    local progressLine = Instance.new("Frame")
    progressLine.Size = UDim2.new(0, 0, 0, 2)
    progressLine.Position = UDim2.new(0, 0, 1, -2)
    progressLine.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    progressLine.BorderSizePixel = 0
    progressLine.Parent = frame
    
    -- Calculate target width
    local textSize = game:GetService("TextService"):GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(math.huge, 28))
    local targetWidth = textSize.X + 20
    
    table.insert(_activeNotifications, frame)
    
    -- Animate in
    frame:TweenSize(UDim2.new(0, targetWidth, 0, 28), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    -- Animate progress line
    task.spawn(function()
        task.wait(0.3)
        progressLine:TweenSize(UDim2.new(1, 0, 0, 2), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2, true)
    end)
    
    -- Fade out and remove
    task.wait(2.3)
    frame:TweenSize(UDim2.new(0, 0, 0, 28), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)
    
    for i, notif in ipairs(_activeNotifications) do
        if notif == frame then
            table.remove(_activeNotifications, i)
            break
        end
    end
    
    gui:Destroy()
end

-- ── Smoothing functions ───────────────────────────────────────
local function smoothLinear(current, target, smoothness)
    return current:Lerp(target, 1 / smoothness)
end

local function smoothQuad(current, target, smoothness)
    local alpha = 1 / smoothness
    alpha = alpha * alpha
    return current:Lerp(target, alpha)
end

local function smoothBack(current, target, smoothness)
    local alpha = 1 / smoothness
    alpha = alpha * (1 + 0.7 * alpha)
    return current:Lerp(target, math.clamp(alpha, 0, 1))
end

local function smoothCubic(current, target, smoothness)
    local alpha = 1 / smoothness
    alpha = alpha * alpha * alpha
    return current:Lerp(target, alpha)
end

local function smoothElastic(current, target, smoothness)
    local alpha = 1 / smoothness
    if alpha < 1 then
        alpha = math.sin(alpha * math.pi * 2) * alpha
    end
    return current:Lerp(target, math.clamp(alpha, 0, 1))
end

-- ── Closest target ────────────────────────────────────────────
local function getClosest()
    -- On mobile use screen centre, on PC use mouse position
    local mp = IsMobile
        and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        or  UserInputService:GetMouseLocation()
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if LB.TeamCheck and p.Team ~= nil and p.Team == LocalPlayer.Team then continue end
        local char = p.Character; if not char then continue end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(LB.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on or sp.Z <= 0 then continue end
        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if d < bd then bd = d; best = part end
    end
    return best
end

-- ── Aim Assist closest target ─────────────────────────────────
local function getClosestAA()
    local mp = IsMobile
        and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        or  UserInputService:GetMouseLocation()
    local best, bd = nil, math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if AA.TeamCheck and p.Team ~= nil and p.Team == LocalPlayer.Team then continue end
        
        local char = p.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if AA.AliveCheck and (not hum or hum.Health <= 0) then continue end
        
        -- Get target part
        local part = nil
        if AA.TargetPart == "Random" then
            local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}
            part = char:FindFirstChild(parts[math.random(1, #parts)])
        else
            part = char:FindFirstChild(AA.TargetPart)
        end
        
        if not part then part = char:FindFirstChild("HumanoidRootPart") end
        if not part then continue end
        
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on or sp.Z <= 0 then continue end
        
        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        
        -- FOV check
        if AA.FOVCheck and AA.FOVEnabled and d > AA.FOVRadius then continue end
        
        -- Wall check
        if AA.WallCheck then
            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude)
            local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char})
            if hit then continue end
        end
        
        if d < bd then bd = d; best = part end
    end
    
    return best
end

-- ── Snapline origin ───────────────────────────────────────────
local function getOriginPos()
    local vp = Camera.ViewportSize
    if SL.Origin == "Device" then
        return IsMobile
            and Vector2.new(vp.X / 2, vp.Y)
            or  UserInputService:GetMouseLocation()
    elseif SL.Origin == "Character" then
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sp, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then return Vector2.new(sp.X, sp.Y) end
        end
        return Vector2.new(vp.X / 2, vp.Y)
    else -- Gun
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("Attachment") then
                    local n = d.Name:lower()
                    if n:find("muzzle") or n:find("barrel") then
                        local sp, on = Camera:WorldToViewportPoint(d.WorldPosition)
                        if on then return Vector2.new(sp.X, sp.Y) end
                    end
                end
            end
        end
        return Vector2.new(vp.X / 2, vp.Y)
    end
end

-- ── Per-frame ─────────────────────────────────────────────────
local _lastRefresh = 0
RunService.RenderStepped:Connect(function()
    local rbRunning = LB.Enabled and LB.Active
    local aaRunning = AA.Enabled and AA.Active
    
    -- Determine which target to use for visuals
    local visualTarget = nil
    if aaRunning and AA.Target and AA.Target.Parent then
        visualTarget = AA.Target
    elseif rbRunning and LB.Target and LB.Target.Parent then
        visualTarget = LB.Target
    end

    -- Clean up visuals when neither is running
    if not rbRunning and not aaRunning then
        if not LB.Sticky then LB.Target = nil end
        _lMain.Visible = false; _lLeft.Visible = false; _lRight.Visible = false
        if _highlight then _highlight:Destroy(); _highlight = nil end
        if _boxPart   then _boxPart:Destroy();   _boxPart   = nil end
        return
    end
    
    -- Refresh ragebot target
    if rbRunning then
        local now = tick()
        if now - _lastRefresh >= LB.RefreshRate then
            _lastRefresh = now
            if LB.Sticky and LB.Target and LB.Target.Parent then
                local hum = LB.Target.Parent:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then LB.Target = nil end
            end
            if not (LB.Sticky and LB.Target) then
                LB.Target = getClosest()
            end
        end
    end

    -- Clean up if no target
    if not visualTarget then
        if _highlight then _highlight:Destroy(); _highlight = nil end
        if _boxPart   then _boxPart:Destroy();   _boxPart   = nil end
        _lMain.Visible = false; _lLeft.Visible = false; _lRight.Visible = false
        return
    end

    local char = visualTarget.Parent

    -- Highlight
    if HL.Enabled then
        if not _highlight or _highlight.Adornee ~= char then
            if _highlight then _highlight:Destroy() end
            _highlight = Instance.new("Highlight")
            _highlight.Adornee            = char
            _highlight.FillTransparency   = 0.5
            _highlight.OutlineTransparency = 0
            _highlight.Parent             = CoreGui
        end
        _highlight.FillColor    = HL.FillColor
        _highlight.OutlineColor = HL.OutlineColor
    else
        if _highlight then _highlight:Destroy(); _highlight = nil end
    end

    -- 3D Box (stable - updates every frame)
    if BX.Enabled then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not _boxPart or not _boxPart.Parent then
                _boxPart              = Instance.new("Part")
                _boxPart.Anchored     = true
                _boxPart.CanCollide   = false
                _boxPart.CastShadow   = false
                _boxPart.Material     = Enum.Material.ForceField
                _boxPart.Size         = Vector3.new(5, 6, 5)
                _boxPart.Parent       = workspace
            end
            -- Update every frame for stability
            _boxPart.CFrame       = hrp.CFrame
            _boxPart.Color        = BX.Color
            _boxPart.Transparency = BX.Transparency
        end
    else
        if _boxPart then _boxPart:Destroy(); _boxPart = nil end
    end

    -- Snaplines
    if SL.Enabled then
        local sp, on = Camera:WorldToViewportPoint(visualTarget.Position)
        if on then
            local tPos = Vector2.new(sp.X, sp.Y)
            local oPos = getOriginPos()
            local dir  = tPos - oPos
            local len  = dir.Magnitude
            if len > 0 then
                local perp   = Vector2.new(-dir.Y / len, dir.X / len)
                local offset = math.max(2, SL.Thickness + 1)
                _lMain.From  = oPos;                  _lMain.To  = tPos
                _lMain.Color = SL.MainColor;          _lMain.Thickness = SL.Thickness; _lMain.Visible = true
                _lLeft.From  = oPos + perp * offset;  _lLeft.To  = tPos + perp * offset
                _lLeft.Color = SL.SideColor;          _lLeft.Thickness = SL.Thickness; _lLeft.Visible = true
                _lRight.From = oPos - perp * offset;  _lRight.To = tPos - perp * offset
                _lRight.Color = SL.SideColor;         _lRight.Thickness = SL.Thickness; _lRight.Visible = true
            else
                _lMain.Visible = false; _lLeft.Visible = false; _lRight.Visible = false
            end
        else
            _lMain.Visible = false; _lLeft.Visible = false; _lRight.Visible = false
        end
    else
        _lMain.Visible = false; _lLeft.Visible = false; _lRight.Visible = false
    end
end)

-- ── Auto Fire ─────────────────────────────────────────────────
local _lastShot = 0
RunService.Heartbeat:Connect(function()
    if not LB.AutoFire or not active() then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local now = tick()
    if now - _lastShot >= LB.FireCooldown then
        task.wait(LB.ShotDelay)
        tool:Activate()
        _lastShot = now
    end
end)

-- ══════════════════════════════════════════════════════════════
-- AIM ASSIST (AIMLOCK) SYSTEM
-- ══════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    if not AA.Enabled or not AA.Active then
        return
    end
    
    -- Get target
    if not AA.Target or not AA.Target.Parent then
        AA.Target = getClosestAA()
    end
    
    if not AA.Target or not AA.Target.Parent then return end
    
    -- Aimlock to target with prediction
    local targetPos = AA.Target.Position
    
    -- Apply prediction
    if AA.Prediction and AA.Prediction > 0 then
        local targetChar = AA.Target.Parent
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            local velocity = targetHRP.AssemblyLinearVelocity or targetHRP.Velocity
            targetPos = targetPos + (velocity * AA.Prediction)
        end
    end
    
    -- Add shake if enabled
    if AA.Shake then
        local shakeAmount = AA.ShakeValue / 100
        targetPos = targetPos + Vector3.new(
            (math.random() - 0.5) * shakeAmount,
            (math.random() - 0.5) * shakeAmount,
            (math.random() - 0.5) * shakeAmount
        )
    end
    
    local camPos = Camera.CFrame.Position
    local targetCFrame = CFrame.new(camPos, targetPos)
    
    -- Apply smoothing
    if AA.Smoothing and AA.SmoothValue > 1 then
        local currentCFrame = Camera.CFrame
        if AA.Style == "Linear" then
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / AA.SmoothValue)
        elseif AA.Style == "Quad" then
            local alpha = 1 / AA.SmoothValue
            alpha = alpha * alpha
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, alpha)
        elseif AA.Style == "Back" then
            local alpha = 1 / AA.SmoothValue
            alpha = alpha * (1 + 0.7 * alpha)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, math.clamp(alpha, 0, 1))
        elseif AA.Style == "Cubic" then
            local alpha = 1 / AA.SmoothValue
            alpha = alpha * alpha * alpha
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, alpha)
        elseif AA.Style == "Elastic" then
            local alpha = 1 / AA.SmoothValue
            if alpha < 1 then
                alpha = math.sin(alpha * math.pi * 2) * alpha
            end
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, math.clamp(alpha, 0, 1))
        end
    else
        Camera.CFrame = targetCFrame
    end
end)

-- ══════════════════════════════════════════════════════════════
-- UTILITY: FACE TARGET
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Determine target (aim assist or ragebot)
    local target = (AA.Enabled and AA.Active and AA.Target) or (LB.Active and LB.Target)
    if not target or not target.Parent then return end
    
    local targetPos = target.Position
    
    -- Face target
    if UT.FaceTarget then
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
    end
end)

-- ══════════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════════════════════════
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ZHESP"; ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true; ESPGui.DisplayOrder = 1
pcall(function() ESPGui.Parent = CoreGui end)
if not ESPGui.Parent then ESPGui.Parent = LocalPlayer.PlayerGui end

local function makeFrame(parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.new(1, 1, 1)
    f.Visible = false
    f.ZIndex = 5
    f.Parent = parent
    return f
end

local function makeESPEntry()
    local entry = { main = {}, outline = {}, inline = {} }
    
    -- Main box (4 lines)
    for i = 1, 4 do
        entry.main[i] = makeFrame(ESPGui)
    end
    
    -- Outline (4 lines, rendered behind main)
    for i = 1, 4 do
        entry.outline[i] = makeFrame(ESPGui)
        entry.outline[i].ZIndex = 4
    end
    
    -- Inline (4 lines, rendered in front of main)
    for i = 1, 4 do
        entry.inline[i] = makeFrame(ESPGui)
        entry.inline[i].ZIndex = 6
    end

    -- Fill frame
    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BackgroundTransparency = 0.5
    fill.Visible = false
    fill.ZIndex = 3
    fill.Parent = ESPGui
    entry.fill = fill

    -- Nametag
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Code
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.AnchorPoint = Vector2.new(0.5, 1)
    lbl.Size = UDim2.new(0, 100, 0, 14)
    lbl.Visible = false
    lbl.ZIndex = 6
    lbl.Parent = ESPGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Thickness = 1
    stroke.Parent = lbl
    
    entry.nameLabel = lbl
    entry.nameStroke = stroke

    -- Health bar (2 frames: bg outline + fill)
    local hbOutline = makeFrame(ESPGui)
    hbOutline.ZIndex = 7; hbOutline.Size = UDim2.fromOffset(4, 0)
    local hbFill = makeFrame(ESPGui)
    hbFill.ZIndex = 8; hbFill.Size = UDim2.fromOffset(2, 0)
    entry.hbOutline = hbOutline
    entry.hbFill    = hbFill

    -- Weapon label (shows [tool name])
    local wepLbl = Instance.new("TextLabel")
    wepLbl.BackgroundTransparency = 1
    wepLbl.TextSize = 11
    wepLbl.Font = Enum.Font.Code
    wepLbl.TextColor3 = Color3.new(1, 1, 1)
    wepLbl.TextXAlignment = Enum.TextXAlignment.Center
    wepLbl.AnchorPoint = Vector2.new(0.5, 0)
    wepLbl.Size = UDim2.new(0, 120, 0, 13)
    wepLbl.Visible = false; wepLbl.ZIndex = 6; wepLbl.Parent = ESPGui
    local wepStroke = Instance.new("UIStroke")
    wepStroke.Color = Color3.new(0,0,0); wepStroke.Thickness = 1; wepStroke.Parent = wepLbl
    entry.wepLabel  = wepLbl
    entry.wepStroke = wepStroke

    return entry
end

local _BLACK = Color3.fromRGB(0, 0, 0)

local function placeBox(frames, col, transp, x, y, w, h, thickness)
    thickness = thickness or 1
    frames[1].BackgroundColor3 = col; frames[1].BackgroundTransparency = transp
    frames[1].Position = UDim2.fromOffset(x, y); frames[1].Size = UDim2.fromOffset(w, thickness); frames[1].Visible = true
    frames[2].BackgroundColor3 = col; frames[2].BackgroundTransparency = transp
    frames[2].Position = UDim2.fromOffset(x, y+h-thickness); frames[2].Size = UDim2.fromOffset(w, thickness); frames[2].Visible = true
    frames[3].BackgroundColor3 = col; frames[3].BackgroundTransparency = transp
    frames[3].Position = UDim2.fromOffset(x, y); frames[3].Size = UDim2.fromOffset(thickness, h); frames[3].Visible = true
    frames[4].BackgroundColor3 = col; frames[4].BackgroundTransparency = transp
    frames[4].Position = UDim2.fromOffset(x+w-thickness, y); frames[4].Size = UDim2.fromOffset(thickness, h); frames[4].Visible = true
end

local function hideESPEntry(entry)
    for _, f in ipairs(entry.main)    do f.Visible = false end
    for _, f in ipairs(entry.outline) do f.Visible = false end
    for _, f in ipairs(entry.inline)  do f.Visible = false end
    entry.fill.Visible    = false
    entry.nameLabel.Visible = false
    entry.hbOutline.Visible = false
    entry.hbFill.Visible    = false
    entry.wepLabel.Visible  = false
end

-- ── Optimized ESP — runs on Heartbeat throttled, not RenderStepped ───────────
local _espChamParts = {}
local _espChamDirty = {}
local _HIGHLIGHT_DEPTH_ON  = Enum.HighlightDepthMode.AlwaysOnTop
local _HIGHLIGHT_DEPTH_OFF = Enum.HighlightDepthMode.Occluded

-- ESP cache: per-player data updated at ~20fps
local _espCache = {} -- player -> {hrp, hum, health, maxHealth, toolName, visible}

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() _espChamDirty[p] = true end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then _espChamDirty[p] = true end
    p.CharacterAdded:Connect(function() _espChamDirty[p] = true end)
end

-- ── LOGIC LOOP — 20fps, does all expensive work ──────────────────────────────
local _espLogicThrottle = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - _espLogicThrottle < 0.05 then return end -- 20fps
    _espLogicThrottle = now

    if not ESP.Enabled then
        _espCache = {}
        for _, entry in pairs(_espEntries) do hideESPEntry(entry) end
        for _, hl in pairs(_espHighlights) do hl:Destroy() end
        _espHighlights = {}
        for _, parts in pairs(_espChamParts) do
            for _, p in ipairs(parts) do
                if p.obj and p.obj.Parent then
                    p.obj.Material = p.origMat; p.obj.Color = p.origCol
                end
            end
        end
        _espChamParts = {}
        return
    end

    local usedEntries = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer and not ESP.LocalPlayer then continue end

        local char = player.Character
        if not char then _espCache[player] = nil; continue end
        -- Team check
        if ESP.TeamCheck and player.Team and player.Team == LocalPlayer.Team then
            if _espEntries[player] then hideESPEntry(_espEntries[player]) end
            _espCache[player] = nil
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then _espCache[player] = nil; continue end
        local hum = char:FindFirstChildOfClass("Humanoid")

        usedEntries[player] = true
        if not _espEntries[player] then _espEntries[player] = makeESPEntry() end

        -- Update cache
        local toolName = nil
        if ESP.WepEnabled then
            local tool = char:FindFirstChildOfClass("Tool")
            toolName = tool and tool.Name or nil
        end
        _espCache[player] = {
            hrp      = hrp,
            hum      = hum,
            health   = hum and hum.Health or 100,
            maxHealth= hum and hum.MaxHealth or 100,
            toolName = toolName,
            name     = player.Name,
        }

        -- Highlight (instance management only — cheap)
        if ESP.HLEnabled then
            local hl2 = _espHighlights[player]
            if not hl2 or not hl2.Parent then
                hl2 = Instance.new("Highlight")
                hl2.Adornee = char; hl2.Parent = CoreGui
                _espHighlights[player] = hl2
            end
            hl2.FillColor           = ESP.HLFill
            hl2.OutlineColor        = ESP.HLOutline
            hl2.FillTransparency    = 0.5
            hl2.OutlineTransparency = 0
            hl2.DepthMode           = ESP.HLWalls and _HIGHLIGHT_DEPTH_ON or _HIGHLIGHT_DEPTH_OFF
        else
            local hl2 = _espHighlights[player]
            if hl2 then hl2:Destroy(); _espHighlights[player] = nil end
        end

        -- Material / Chams (only rescan on character change)
        if ESP.MatEnabled or ESP.ChamsEnabled then
            if _espChamDirty[player] or not _espChamParts[player] then
                _espChamParts[player] = {}
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(_espChamParts[player], {obj=part, origMat=part.Material, origCol=part.Color})
                    end
                end
                _espChamDirty[player] = false
            end
            local matEnum = Enum.Material[ESP.MatType] or Enum.Material.ForceField
            local matCol  = ESP.MatEnabled and ESP.MatColor or ESP.ChamsMain
            local matType = ESP.MatEnabled and matEnum or Enum.Material.Neon
            for _, p in ipairs(_espChamParts[player]) do
                if p.obj and p.obj.Parent then
                    p.obj.Material = matType; p.obj.Color = matCol
                end
            end
        else
            local parts = _espChamParts[player]
            if parts then
                for _, p in ipairs(parts) do
                    if p.obj and p.obj.Parent then
                        p.obj.Material = p.origMat; p.obj.Color = p.origCol
                    end
                end
                _espChamParts[player] = nil
            end
        end
    end

    -- Cleanup
    for player, entry in pairs(_espEntries) do
        if not usedEntries[player] then
            hideESPEntry(entry)
            _espCache[player] = nil
            local hl2 = _espHighlights[player]
            if hl2 then hl2:Destroy(); _espHighlights[player] = nil end
            local parts = _espChamParts[player]
            if parts then
                for _, p in ipairs(parts) do
                    if p.obj and p.obj.Parent then
                        p.obj.Material = p.origMat; p.obj.Color = p.origCol
                    end
                end
                _espChamParts[player] = nil
            end
        end
    end
end)

-- ── RENDER LOOP — full fps, only does Camera:WorldToViewportPoint + frame moves
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end

    for player, cache in pairs(_espCache) do
        local entry = _espEntries[player]
        if not entry or not cache or not cache.hrp or not cache.hrp.Parent then
            if entry then hideESPEntry(entry) end
            continue
        end

        local hrp = cache.hrp
        local spTop, onTop = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
        local spBot, onBot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        if not onTop or not onBot or spTop.Z <= 0 or spBot.Z <= 0 then
            hideESPEntry(entry); continue
        end

        local cx   = spTop.X
        local minY = spTop.Y
        local maxY = spBot.Y
        local boxH = math.max(1, maxY - minY)
        local boxW = boxH * 0.6
        local minX = cx - boxW * 0.5
        local maxX = cx + boxW * 0.5

        -- Fill
        if ESP.FillEnabled then
            local f = entry.fill
            f.BackgroundColor3       = ESP.FillColor
            f.BackgroundTransparency = ESP.FillTransp
            f.Position = UDim2.fromOffset(minX, minY)
            f.Size     = UDim2.fromOffset(boxW, boxH)
            f.Visible  = true
        else
            entry.fill.Visible = false
        end

        -- Box
        if ESP.BoxEnabled then
            placeBox(entry.outline, ESP.BoxOutline, 0, minX-1, minY-1, boxW+2, boxH+2, 2)
            placeBox(entry.main,    ESP.BoxMain,    0, minX,   minY,   boxW,   boxH,   1)
            placeBox(entry.inline,  _BLACK,         0, minX+1, minY+1, boxW-2, boxH-2, 1)
        else
            for _, f in ipairs(entry.main)    do f.Visible = false end
            for _, f in ipairs(entry.outline) do f.Visible = false end
            for _, f in ipairs(entry.inline)  do f.Visible = false end
        end

        -- Nametag
        if ESP.NameEnabled then
            local lbl = entry.nameLabel
            lbl.Text               = cache.name
            lbl.TextColor3         = ESP.NameColor
            entry.nameStroke.Color = ESP.NameOutline
            lbl.Position           = UDim2.fromOffset(minX + boxW * 0.5, minY - 2)
            lbl.Visible            = true
        else
            entry.nameLabel.Visible = false
        end

        -- Weapon
        if ESP.WepEnabled and cache.toolName then
            local wl = entry.wepLabel
            wl.Text               = "[" .. cache.toolName .. "]"
            wl.TextColor3         = ESP.WepMain
            entry.wepStroke.Color = ESP.WepOutline
            wl.Position           = UDim2.fromOffset(minX + boxW * 0.5, maxY + 2)
            wl.Visible            = true
        else
            entry.wepLabel.Visible = false
        end

        -- Health bar
        if ESP.HBEnabled then
            local pct   = math.clamp(cache.health / math.max(1, cache.maxHealth), 0, 1)
            local fillH = math.max(1, math.floor(boxH * pct))
            local barX  = minX - 5

            entry.hbOutline.BackgroundColor3 = ESP.HBOutline
            entry.hbOutline.Position         = UDim2.fromOffset(barX - 1, minY - 1)
            entry.hbOutline.Size             = UDim2.fromOffset(3, boxH + 2)
            entry.hbOutline.Visible          = true

            entry.hbFill.BackgroundColor3 = ESP.HBMain
            entry.hbFill.Position         = UDim2.fromOffset(barX, minY + (boxH - fillH))
            entry.hbFill.Size             = UDim2.fromOffset(1, fillH)
            entry.hbFill.Visible          = true
        else
            entry.hbOutline.Visible = false
            entry.hbFill.Visible    = false
        end
    end
end)

-- __index hook for Mouse.Hit/Target (PC and mobile compatibility)
local oldIndex = nil 
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and active() then
        local HitPart = LB.Target
        if not HitPart then return oldIndex(self, Index) end
         
        if Index == "Target" or Index == "target" then 
            return HitPart
        elseif Index == "Hit" or Index == "hit" then 
            return CFrame.new(HitPart.Position)
        elseif Index == "X" then
            -- Mobile often checks Mouse.X for shooting position
            local sp = Camera:WorldToViewportPoint(HitPart.Position)
            return sp.X
        elseif Index == "Y" then
            -- Mobile often checks Mouse.Y for shooting position
            local sp = Camera:WorldToViewportPoint(HitPart.Position)
            return sp.Y
        elseif Index == "UnitRay" then
            -- Some games use UnitRay for mobile shooting
            local origin = Camera.CFrame.Position
            local direction = (HitPart.Position - origin).Unit
            return Ray.new(origin, direction)
        end
    end

    return oldIndex(self, Index)
end))

-- ══════════════════════════════════════════════════════════════
-- UNIVERSAL MOBILE SUPPORT — RemoteEvent/RemoteFunction hook
-- ══════════════════════════════════════════════════════════════
-- Hook all RemoteEvent:FireServer and RemoteFunction:InvokeServer calls
local oldFireServer
local oldInvokeServer

-- Function to check and redirect arguments
local function redirectArgs(args)
    if not active() then return args end
    
    local targetPos = LB.Target.Position
    local targetCFrame = CFrame.new(targetPos)
    
    -- Replace any position/CFrame/Part arguments with target
    for i = 1, #args do
        local t = typeof(args[i])
        if t == 'Instance' and args[i]:IsA('BasePart') then
            args[i] = LB.Target
        elseif t == 'CFrame' then
            args[i] = targetCFrame
        elseif t == 'Vector3' then
            args[i] = targetPos
        elseif t == 'table' then
            -- Check if table contains position data
            if args[i].Position and typeof(args[i].Position) == 'Vector3' then
                args[i].Position = targetPos
            end
            if args[i].Hit and typeof(args[i].Hit) == 'CFrame' then
                args[i].Hit = targetCFrame
            end
            if args[i].Target and typeof(args[i].Target) == 'Instance' then
                args[i].Target = LB.Target
            end
        end
    end
    
    return args
end

-- Hook RemoteEvent:FireServer
oldFireServer = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
        local args = {...}
        args = redirectArgs(args)
        return oldFireServer(self, unpack(args))
    end
    
    if method == "InvokeServer" and typeof(self) == "Instance" and self:IsA("RemoteFunction") then
        local args = {...}
        args = redirectArgs(args)
        return oldFireServer(self, unpack(args))
    end
    
    -- Raycast hooks
    if method == "Raycast" and self == workspace and active() then
        local args = {...}
        if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
            local origin = args[1]
            local originalDir = args[2]
            local camPos = Camera.CFrame.Position
            
            -- Only redirect if raycast originates near camera
            if (origin - camPos).Magnitude < 10 then
                local targetPos = LB.Target.Position
                local newDir = (targetPos - origin).Unit * originalDir.Magnitude
                args[2] = newDir
                return oldFireServer(self, table.unpack(args))
            end
        end
    end
    
    -- FindPartOnRay variants
    if self == workspace and active() then
        if method == "FindPartOnRay" or method == "findPartOnRay" then
            local args = {...}
            if typeof(args[1]) == "Ray" then
                local A_Ray = args[1]
                local HitPart = LB.Target
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDir(Origin, HitPart.Position)
                    args[1] = Ray.new(Origin, Direction)
                    return oldFireServer(self, table.unpack(args))
                end
            end
        elseif method == "FindPartOnRayWithIgnoreList" then
            local args = {...}
            if typeof(args[1]) == "Ray" then
                local A_Ray = args[1]
                local HitPart = LB.Target
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDir(Origin, HitPart.Position)
                    args[1] = Ray.new(Origin, Direction)
                    return oldFireServer(self, table.unpack(args))
                end
            end
        elseif method == "FindPartOnRayWithWhitelist" then
            local args = {...}
            if typeof(args[1]) == "Ray" then
                local A_Ray = args[1]
                local HitPart = LB.Target
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDir(Origin, HitPart.Position)
                    args[1] = Ray.new(Origin, Direction)
                    return oldFireServer(self, table.unpack(args))
                end
            end
        end
    end
    
    return oldFireServer(self, ...)
end))

-- ══════════════════════════════════════════════════════════════
-- CONNECTION EXPLOIT STATE
-- ══════════════════════════════════════════════════════════════
local CE = {
    Enabled   = false,
    Attached  = false,
    AutoKnife = false,
    LockKey   = Enum.KeyCode.Q,
    AttachKey = Enum.KeyCode.C,
    Target    = nil,
}

local _ceChar, _ceRoot = nil, nil
local _ceBeam, _ceA0, _ceA1 = nil, nil, nil
local _ceHue = 0

local function _ceSetup(char)
    _ceChar = char
    _ceRoot = char:WaitForChild("Humanoid").RootPart
end
if LocalPlayer.Character then _ceSetup(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(_ceSetup)

local function _ceBeamInit()
    if _ceBeam then return end
    _ceA0 = Instance.new("Attachment", workspace.Terrain)
    _ceA1 = Instance.new("Attachment", workspace.Terrain)
    _ceBeam = Instance.new("Beam", workspace)
    _ceBeam.Attachment0   = _ceA0
    _ceBeam.Attachment1   = _ceA1
    _ceBeam.FaceCamera    = true
    _ceBeam.LightEmission = 1
    _ceBeam.LightInfluence = 0
    _ceBeam.Segments      = 64
    _ceBeam.Texture       = "rbxassetid://1217127707"
    _ceBeam.TextureLength = 15
    _ceBeam.TextureSpeed  = 16
    _ceBeam.TextureMode   = Enum.TextureMode.Wrap
    _ceBeam.Transparency  = NumberSequence.new(0)
    _ceBeam.Width0        = 0.05
    _ceBeam.Width1        = 0.025
end

local function _ceClosest()
    local mp   = UserInputService:GetMouseLocation()
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local sp, on = Camera:WorldToViewportPoint(hrp.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if d < bd then bd = d; best = p end
    end
    return best
end

local function _ceOwn(part)
    if part and part:IsA("BasePart") then
        pcall(function() part:SetNetworkOwner(LocalPlayer) end)
    end
end

local function _ceFindKnife()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("knife") then
            return tool
        end
    end
end

local function _ceEquipKnife(char)
    local hum = char:WaitForChild("Humanoid")
    for i = 1, 100 do
        local knife = _ceFindKnife()
        if knife then hum:EquipTool(knife); return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("knife") then return end
        end
        task.wait(0.1)
    end
end

-- Keybind input for connection exploit
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not CE.Enabled then return end
    if input.KeyCode == CE.LockKey then
        if CE.Target then
            CE.Target   = nil
            CE.Attached = false
        else
            CE.Target = _ceClosest()
        end
    elseif input.KeyCode == CE.AttachKey then
        CE.Attached = not CE.Attached
    end
end)

-- Attach loop
RunService.Heartbeat:Connect(function()
    if not CE.Enabled or not CE.Attached or not _ceChar or not _ceRoot then return end
    local tr = CE.Target and CE.Target.Character and CE.Target.Character:FindFirstChild("HumanoidRootPart")
    if not tr then CE.Attached = false; CE.Target = nil; return end
    _ceOwn(_ceRoot); _ceOwn(tr)
    pcall(function()
        sethiddenproperty(_ceRoot, "PhysicsRepRootPart", tr)
        _ceRoot.CFrame = tr.CFrame
        _ceRoot.AssemblyLinearVelocity  = Vector3.zero
        _ceRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end)

-- Tracer beam
RunService.RenderStepped:Connect(function(dt)
    if not CE.Enabled or not CE.Target then
        if _ceBeam then _ceBeam.Enabled = false end
        return
    end
    _ceBeamInit()
    local tr = CE.Target.Character and CE.Target.Character:FindFirstChild("HumanoidRootPart")
    if tr then
        local m   = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(m.X, m.Y, 0)
        _ceA0.WorldCFrame = CFrame.new(ray.Origin + ray.Direction * 10)
        _ceA1.Parent      = tr
        _ceBeam.Enabled   = true
        _ceHue = (_ceHue + dt * 0.1) % 1
        _ceBeam.Color  = ColorSequence.new(Color3.fromHSV(_ceHue, 1, 1))
        _ceBeam.Width0 = 0.05; _ceBeam.Width1 = 0.025
    else
        _ceBeam.Enabled = false
    end
end)

-- Auto equip knife on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if CE.Enabled and CE.AutoKnife then
        task.wait(0.1)
        _ceEquipKnife(char)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- MOBILE TARGET BUTTON
-- ══════════════════════════════════════════════════════════════
local _tbGui, _tbLbl, _tbLocked = nil, nil, false
local _tbRbGui, _tbRbLbl, _tbRbLocked = nil, nil, false

-- Makes a generic draggable toggle button
local function makeDraggableBtn(guiName, labelText, yPos, onToggle)
    local existingGui = CoreGui:FindFirstChild(guiName)
        or LocalPlayer.PlayerGui:FindFirstChild(guiName)
    if existingGui then existingGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = guiName; gui.DisplayOrder = 9998
    gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    btn.BorderSizePixel = 0
    btn.ZIndex = 10
    btn.Parent = gui
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Text = labelText .. ": OFF"
    btn.AutoButtonColor = false

    local locked = false
    local drag, ref = false, nil
    local ds, fs = Vector2.zero, Vector2.new(10, yPos)

    local function applyState(state)
        locked = state
        if state then
            btn.Text = labelText .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        else
            btn.Text = labelText .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        end
        onToggle(state, btn)
    end

    btn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.Touch or drag then return end
        drag = true; ref = i
        ds = Vector2.new(i.Position.X, i.Position.Y)
        fs = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
        -- Don't toggle yet — wait to see if it's a tap or drag
    end)
    UserInputService.TouchMoved:Connect(function(i)
        if i ~= ref then return end
        btn.Position = UDim2.new(0, fs.X + i.Position.X - ds.X, 0, fs.Y + i.Position.Y - ds.Y)
    end)
    UserInputService.TouchEnded:Connect(function(i)
        if i ~= ref then return end
        local dist = (Vector2.new(i.Position.X, i.Position.Y) - ds).Magnitude
        drag = false; ref = nil
        -- Only toggle if it was a tap (not a drag)
        if dist < 12 then
            applyState(not locked)
        end
    end)

    return gui, btn
end

-- Ragebot button (ragebot only)
local function makeRagebotButton()
    local yBase = math.floor(Camera.ViewportSize.Y * 0.65)
    _tbRbGui, _tbRbLbl = makeDraggableBtn("ZHRagebotBtn", "Ragebot", yBase,
        function(state)
            _tbRbLocked = state
            if state then
                if LB.Enabled then
                    LB.Active = true
                    LB.Target = getClosest()
                end
            else
                LB.Active = false; LB.Target = nil
            end
        end)
end

-- Aimbot button (aim assist only)
local function makeAimbotButton()
    local yBase = math.floor(Camera.ViewportSize.Y * 0.65)
    _tbGui, _tbLbl = makeDraggableBtn("ZHAimbotBtn", "Aimbot", yBase,
        function(state)
            _tbLocked = state
            if state then
                if AA.Enabled then
                    AA.Active = true
                    AA.Target = getClosestAA()
                    if AA.Target and AA.Target.Parent then
                        local player = Players:GetPlayerFromCharacter(AA.Target.Parent)
                        if player then showNotification("Target set to " .. player.Name) end
                    end
                end
            else
                AA.Active = false; AA.Target = nil
                showNotification("Untargeted")
            end
        end)
end

-- Ragebot tool (ragebot only)
local _ttool = nil
local function makeTargetTool()
    if _ttool then _ttool:Destroy() end
    local t = Instance.new("Tool")
    t.Name = "Ragebot"; t.RequiresHandle = false
    t.CanBeDropped = false; t.Parent = LocalPlayer.Backpack
    local locked = false
    t.Activated:Connect(function()
        locked = not locked
        if locked then
            if LB.Enabled then
                LB.Active = true
                LB.Target = getClosest()
            end
        else
            LB.Active = false; LB.Target = nil
        end
    end)
    _ttool = t
end

-- Aimbot tool (aim assist only)
local _aaTool = nil
local function makeAimbotTool()
    if _aaTools then _aaTools:Destroy() end
    local t = Instance.new("Tool")
    t.Name = "Aimbot"; t.RequiresHandle = false
    t.CanBeDropped = false; t.Parent = LocalPlayer.Backpack
    local locked = false
    t.Activated:Connect(function()
        locked = not locked
        if locked then
            if AA.Enabled then
                AA.Active = true
                AA.Target = getClosestAA()
                if AA.Target and AA.Target.Parent then
                    local player = Players:GetPlayerFromCharacter(AA.Target.Parent)
                    if player then showNotification("Target set to " .. player.Name) end
                end
            end
        else
            AA.Active = false; AA.Target = nil
            showNotification("Untargeted")
        end
    end)
    _aaTools = t
end

-- ══════════════════════════════════════════════════════════════
-- UI
-- ══════════════════════════════════════════════════════════════
local RagebotPage  = Window:Page({Name = "ragebot"})
local LegitbotPage = Window:Page({Name = "legitbot"})
local MiscPage     = Window:Page({Name = "misc"})
local VisualsPage  = Window:Page({Name = "visuals"})
local WorldPage    = Window:Page({Name = "world"})
local PlayersPage  = Window:Page({Name = "players"})

do -- Ragebot (left)
    local rb = RagebotPage:Section({Name = "ragebot", Side = 1})

    rb:Toggle({Name = "enable", Flag = "lb_enabled", Default = false,
        Callback = function(v)
            LB.Enabled = v
            if not v then LB.Active = false; LB.Target = nil end
        end})

    rb:Toggle({Name = "auto fire", Flag = "lb_autofire", Default = false,
        Callback = function(v) LB.AutoFire = v end})

    rb:Slider({Name = "fire cooldown", Flag = "lb_firecool",
        Min = 0.05, Max = 1.0, Default = 0.1, Decimals = 0.01, Suffix = "s",
        Callback = function(v) LB.FireCooldown = v end})

    rb:Slider({Name = "shot delay", Flag = "lb_shotdelay",
        Min = 0, Max = 0.5, Default = 0.1, Decimals = 0.01, Suffix = "s",
        Callback = function(v) LB.ShotDelay = v end})

    rb:Toggle({Name = "sticky", Flag = "lb_sticky", Default = false,
        Callback = function(v) LB.Sticky = v end})

    rb:Toggle({Name = "team check", Flag = "lb_team", Default = true,
        Callback = function(v) LB.TeamCheck = v end})

    rb:Dropdown({Name = "hit part", Flag = "lb_part",
        Items = {"Head", "HumanoidRootPart"}, Default = "Head",
        Callback = function(v) LB.TargetPart = v end})

    rb:Slider({Name = "refresh rate", Flag = "lb_refresh",
        Min = 0, Max = 0.5, Default = 0.1, Decimals = 0.01, Suffix = "s",
        Callback = function(v) LB.RefreshRate = v end})

    rb:Label({Name = "keybind"}):Keybind({
        Flag     = "lb_keybind",
        Mode     = "Toggle",
        Default  = Enum.KeyCode.CapsLock,
        Callback = function(toggled)
            LB.Active = toggled
            if not toggled then LB.Target = nil end
        end,
    })

    if IsMobile then
        rb:Button({Name = "load ragebot button", Callback = makeRagebotButton})
        rb:Button({Name = "load ragebot tool",   Callback = makeTargetTool})
    end
end

do -- Snapline (right)
    local sl = RagebotPage:Section({Name = "snapline", Side = 2})

    sl:Toggle({Name = "enable", Flag = "sl_en", Default = false,
        Callback = function(v) SL.Enabled = v end})

    sl:Label({Name = "main color"}):Colorpicker({Flag = "sl_main",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SL.MainColor = v end})

    sl:Label({Name = "side color"}):Colorpicker({Flag = "sl_side",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) SL.SideColor = v end})

    sl:Slider({Name = "thickness", Flag = "sl_thick",
        Min = 1, Max = 6, Default = 1, Decimals = 1,
        Callback = function(v) SL.Thickness = v end})

    sl:Dropdown({Name = "origin", Flag = "sl_origin",
        Items = {"Gun", "Character", "Device"}, Default = "Character",
        Callback = function(v) SL.Origin = v end})
end

do -- Highlight (right)
    local hl = RagebotPage:Section({Name = "highlight", Side = 2})

    hl:Toggle({Name = "enable", Flag = "hl_en", Default = false,
        Callback = function(v) HL.Enabled = v end})

    hl:Label({Name = "fill color"}):Colorpicker({Flag = "hl_fill",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) HL.FillColor = v end})

    hl:Label({Name = "outline color"}):Colorpicker({Flag = "hl_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) HL.OutlineColor = v end})
end

do -- 3D Box (right)
    local bx = RagebotPage:Section({Name = "3d box", Side = 2})

    bx:Toggle({Name = "enable", Flag = "bx_en", Default = false,
        Callback = function(v)
            BX.Enabled = v
            if not v and _boxPart then
                _boxPart:Destroy(); _boxPart = nil
            end
        end})

    bx:Label({Name = "color"}):Colorpicker({Flag = "bx_color",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) BX.Color = v end})

    -- 0 = fully visible, 0.99 = nearly invisible (1 would delete it visually)
    bx:Slider({Name = "transparency", Flag = "bx_trans",
        Min = 0, Max = 0.99, Default = 0.5, Decimals = 0.01,
        Callback = function(v) BX.Transparency = v end})
end

do -- Utility (right)
    local ut = RagebotPage:Section({Name = "utility", Side = 2})
    
    ut:Toggle({Name = "face target", Flag = "ut_face", Default = false,
        Callback = function(v) UT.FaceTarget = v end})
end

-- ══════════════════════════════════════════════════════════════
-- LEGITBOT PAGE UI
-- ══════════════════════════════════════════════════════════════
do -- Aim Assist (left)
    local aa = LegitbotPage:Section({Name = "aim assist", Side = 1})
    
    aa:Toggle({Name = "enabled", Flag = "aa_enabled", Default = false,
        Callback = function(v)
            AA.Enabled = v
            if not v then AA.Active = false; AA.Target = nil end
        end})
    
    aa:Label({Name = "keybind"}):Keybind({
        Flag = "aa_keybind",
        Mode = "Toggle",
        Default = Enum.KeyCode.E,
        Callback = function(toggled)
            AA.Active = toggled
            if toggled then
                AA.Target = getClosestAA()
                if AA.Target and AA.Target.Parent then
                    local player = Players:GetPlayerFromCharacter(AA.Target.Parent)
                    if player then
                        showNotification("Target set to " .. player.Name)
                    end
                end
            else
                AA.Target = nil
                showNotification("Untargeted")
            end
        end,
    })
    
    aa:Dropdown({Name = "hit part", Flag = "aa_part",
        Items = {"Random", "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"},
        Default = "Head",
        Callback = function(v) AA.TargetPart = v end})
    
    aa:Textbox({Name = "prediction", Flag = "aa_prediction",
        Default = "0.13",
        Placeholder = "0.13",
        Callback = function(v)
            local num = tonumber(v)
            if num then
                AA.Prediction = num
            end
        end})
    
    aa:Toggle({Name = "smoothing", Flag = "aa_smooth", Default = true,
        Callback = function(v) AA.Smoothing = v end})
    
    aa:Slider({Name = "smooth value", Flag = "aa_smooth_val",
        Min = 1, Max = 100, Default = 50, Decimals = 1,
        Callback = function(v) AA.SmoothValue = v end})
    
    aa:Dropdown({Name = "style", Flag = "aa_style",
        Items = {"Linear", "Quad", "Back", "Cubic", "Elastic"},
        Default = "Linear",
        Callback = function(v) AA.Style = v end})
    
    aa:Toggle({Name = "shake", Flag = "aa_shake", Default = false,
        Callback = function(v) AA.Shake = v end})
    
    aa:Slider({Name = "shake value", Flag = "aa_shake_val",
        Min = 0, Max = 100, Default = 10, Decimals = 1,
        Callback = function(v) AA.ShakeValue = v end})
    
    aa:Toggle({Name = "field of view", Flag = "aa_fov", Default = true,
        Callback = function(v) AA.FOVEnabled = v end})
    
    aa:Slider({Name = "fov radius", Flag = "aa_fov_radius",
        Min = 10, Max = 200, Default = 100, Decimals = 1,
        Callback = function(v) AA.FOVRadius = v end})
    
    aa:Dropdown({Name = "checks", Flag = "aa_checks", AllowNull = false, Multi = true,
        Items = {"Team Check", "Alive Check", "Wall Check", "FOV Check"},
        Default = {"Team Check", "Alive Check", "FOV Check"},
        Callback = function(v)
            AA.TeamCheck = table.find(v, "Team Check") ~= nil
            AA.AliveCheck = table.find(v, "Alive Check") ~= nil
            AA.WallCheck = table.find(v, "Wall Check") ~= nil
            AA.FOVCheck = table.find(v, "FOV Check") ~= nil
        end})
    
    if IsMobile then
        aa:Button({Name = "load aimbot button", Callback = makeAimbotButton})
        aa:Button({Name = "load aimbot tool", Callback = makeAimbotTool})
    end
    
    aa:Toggle({Name = "notifications", Flag = "aa_notif", Default = true,
        Callback = function(v) AA.Notifications = v end})
end

do -- Silent Aim (right)
    local sa = LegitbotPage:Section({Name = "silent aim", Side = 2})
    
    sa:Toggle({Name = "enabled", Flag = "sa_enabled", Default = false,
        Callback = function(v) SA.Enabled = v end})
    
    sa:Label({Name = "keybind"}):Keybind({
        Flag = "sa_keybind",
        Mode = "Toggle",
        Default = Enum.KeyCode.R,
        Callback = function(toggled)
            -- Silent aim is always passive when enabled
        end,
    })
    
    sa:Dropdown({Name = "hit part", Flag = "sa_part",
        Items = {"Random", "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"},
        Default = "Head",
        Callback = function(v) SA.TargetPart = v end})
    
    sa:Slider({Name = "hit chance", Flag = "sa_hitchance",
        Min = 0, Max = 100, Default = 100, Decimals = 1, Suffix = "%",
        Callback = function(v) SA.HitChance = v end})
    
    sa:Toggle({Name = "field of view", Flag = "sa_fov", Default = false,
        Callback = function(v) SA.FOVEnabled = v end})
    
    sa:Slider({Name = "fov radius", Flag = "sa_fov_radius",
        Min = 10, Max = 200, Default = 100, Decimals = 1,
        Callback = function(v) SA.FOVRadius = v end})
    
    sa:Toggle({Name = "humanization", Flag = "sa_human", Default = false,
        Callback = function(v) SA.Humanization = v end})
    
    sa:Slider({Name = "humanization amount", Flag = "sa_human_amt",
        Min = 0, Max = 20, Default = 5, Decimals = 1,
        Callback = function(v) SA.HumanizationAmount = v end})
end

-- ESP section in visuals
do
    local esp = VisualsPage:Section({Name = "esp", Side = 1})

    esp:Toggle({Name = "enable", Flag = "esp_enabled", Default = false,
        Callback = function(v) ESP.Enabled = v end})

    esp:Toggle({Name = "team check", Flag = "esp_team", Default = true,
        Callback = function(v) ESP.TeamCheck = v end})

    esp:Toggle({Name = "local player", Flag = "esp_local", Default = false,
        Callback = function(v) ESP.LocalPlayer = v end})

    esp:Toggle({Name = "box", Flag = "esp_box", Default = false,
        Callback = function(v) ESP.BoxEnabled = v end})

    esp:Label({Name = "box main color"}):Colorpicker({Flag = "esp_box_main",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) ESP.BoxMain = v end})

    esp:Label({Name = "box outline"}):Colorpicker({Flag = "esp_box_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) ESP.BoxOutline = v end})

    esp:Toggle({Name = "filled box", Flag = "esp_fill", Default = false,
        Callback = function(v) ESP.FillEnabled = v end})

    esp:Label({Name = "fill color"}):Colorpicker({Flag = "esp_fill_col",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) ESP.FillColor = v end})

    esp:Slider({Name = "fill transparency", Flag = "esp_fill_transp",
        Min = 0.0, Max = 1.0, Default = 0.5, Decimals = 0.01,
        Callback = function(v) ESP.FillTransp = v end})
    
    esp:Toggle({Name = "nametags", Flag = "esp_names", Default = false,
        Callback = function(v) ESP.NameEnabled = v end})

    esp:Label({Name = "name color"}):Colorpicker({Flag = "esp_name_col",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) ESP.NameColor = v end})

    esp:Label({Name = "name outline"}):Colorpicker({Flag = "esp_name_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) ESP.NameOutline = v end})

    -- Material
    esp:Toggle({Name = "material", Flag = "esp_mat", Default = false,
        Callback = function(v) ESP.MatEnabled = v end})
    esp:Label({Name = "mat color"}):Colorpicker({Flag = "esp_mat_col",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) ESP.MatColor = v end})
    esp:Dropdown({Name = "material type", Flag = "esp_mat_type",
        Items = {"ForceField","Neon","SmoothPlastic","Glass","Ice","Metal","Wood","Brick","Concrete","Cobblestone","Sand","Fabric","Slate","Granite","Marble"},
        Default = "ForceField",
        Callback = function(v) ESP.MatType = v end})

    -- Highlight (behind walls)
    esp:Toggle({Name = "highlight", Flag = "esp_hl", Default = false,
        Callback = function(v) ESP.HLEnabled = v end})
    esp:Label({Name = "hl fill"}):Colorpicker({Flag = "esp_hl_fill",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) ESP.HLFill = v end})
    esp:Label({Name = "hl outline"}):Colorpicker({Flag = "esp_hl_outline",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) ESP.HLOutline = v end})
    esp:Toggle({Name = "behind walls", Flag = "esp_hl_walls", Default = true,
        Callback = function(v) ESP.HLWalls = v end})

    -- Chams
    esp:Toggle({Name = "chams", Flag = "esp_chams", Default = false,
        Callback = function(v) ESP.ChamsEnabled = v end})
    esp:Label({Name = "chams main"}):Colorpicker({Flag = "esp_chams_main",
        Default = Color3.fromRGB(255, 50, 50),
        Callback = function(v) ESP.ChamsMain = v end})
    esp:Label({Name = "chams outline"}):Colorpicker({Flag = "esp_chams_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) ESP.ChamsOutline = v end})

    -- Weapon
    esp:Toggle({Name = "weapon", Flag = "esp_wep", Default = false,
        Callback = function(v) ESP.WepEnabled = v end})
    esp:Label({Name = "weapon main"}):Colorpicker({Flag = "esp_wep_main",
        Default = Color3.fromRGB(255, 200, 50),
        Callback = function(v) ESP.WepMain = v end})
    esp:Label({Name = "weapon outline"}):Colorpicker({Flag = "esp_wep_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) ESP.WepOutline = v end})

    -- Health bar
    esp:Toggle({Name = "health bar", Flag = "esp_hb", Default = false,
        Callback = function(v) ESP.HBEnabled = v end})
    esp:Label({Name = "hb main"}):Colorpicker({Flag = "esp_hb_main",
        Default = Color3.fromRGB(50, 255, 100),
        Callback = function(v) ESP.HBMain = v end})
    esp:Label({Name = "hb outline"}):Colorpicker({Flag = "esp_hb_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) ESP.HBOutline = v end})
end

-- ══════════════════════════════════════════════════════════════
-- WORLD PAGE UI
-- ══════════════════════════════════════════════════════════════

-- LEFT SIDE
do -- Color Correction
    local cc = WorldPage:Section({Name = "color correction", Side = 1})
    cc:Toggle({Name = "enabled", Flag = "cc_en", Default = false,
        Callback = function(v)
            WLD.CC_Enabled = v
            if not _ccEffect then
                _ccEffect = Instance.new("ColorCorrectionEffect")
                _ccEffect.Parent = Lighting
            end
            _ccEffect.Enabled = v
        end})
    cc:Label({Name = "tint"}):Colorpicker({Flag = "cc_color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v)
            WLD.CC_Color = v
            if _ccEffect then _ccEffect.TintColor = v end
        end})
    cc:Slider({Name = "saturation", Flag = "cc_sat",
        Min = -1, Max = 1, Default = 0, Decimals = 0.01,
        Callback = function(v)
            WLD.CC_Saturation = v
            if _ccEffect then _ccEffect.Saturation = v end
        end})
    cc:Slider({Name = "contrast", Flag = "cc_con",
        Min = -1, Max = 1, Default = 0, Decimals = 0.01,
        Callback = function(v)
            WLD.CC_Contrast = v
            if _ccEffect then _ccEffect.Contrast = v end
        end})
    cc:Slider({Name = "brightness", Flag = "cc_bri",
        Min = -1, Max = 1, Default = 0, Decimals = 0.01,
        Callback = function(v)
            WLD.CC_Brightness = v
            if _ccEffect then _ccEffect.Brightness = v end
        end})
end

do -- Atmosphere
    local atm = WorldPage:Section({Name = "atmosphere", Side = 1})
    atm:Toggle({Name = "enabled", Flag = "atm_en", Default = false,
        Callback = function(v)
            WLD.ATM_Enabled = v
            if v then
                if not _atmEffect then
                    _atmEffect = Instance.new("Atmosphere")
                    _atmEffect.Parent = Lighting
                end
            else
                if _atmEffect then
                    _atmEffect:Destroy()
                    _atmEffect = nil
                end
            end
        end})
    atm:Label({Name = "color"}):Colorpicker({Flag = "atm_color",
        Default = Color3.fromRGB(199, 170, 120),
        Callback = function(v)
            WLD.ATM_Color = v
            if _atmEffect then _atmEffect.Color = v end
        end})
    atm:Slider({Name = "glare", Flag = "atm_glare",
        Min = 0, Max = 10, Default = 0, Decimals = 0.1,
        Callback = function(v)
            WLD.ATM_Glare = v
            if _atmEffect then _atmEffect.Glare = v end
        end})
    atm:Slider({Name = "haze", Flag = "atm_haze",
        Min = 0, Max = 10, Default = 0, Decimals = 0.1,
        Callback = function(v)
            WLD.ATM_Haze = v
            if _atmEffect then _atmEffect.Haze = v end
        end})
    atm:Slider({Name = "offset", Flag = "atm_offset",
        Min = 0, Max = 1, Default = 0, Decimals = 0.01,
        Callback = function(v)
            WLD.ATM_Offset = v
            if _atmEffect then _atmEffect.Offset = v end
        end})
    atm:Slider({Name = "density", Flag = "atm_density",
        Min = 0, Max = 1, Default = 0.395, Decimals = 0.01,
        Callback = function(v)
            WLD.ATM_Density = v
            if _atmEffect then _atmEffect.Density = v end
        end})
end

do -- Textures
    local tex = WorldPage:Section({Name = "textures", Side = 1})
    tex:Toggle({Name = "enabled", Flag = "tex_en", Default = false,
        Callback = function(v)
            WLD.TEX_Enabled = v
            if v then
                local pack = _texturePacks[WLD.TEX_Pack] or _texturePacks["minecraft"]
                local ms = game:GetService("MaterialService")
                for _, mv in ipairs(_materialVariants) do mv:Destroy() end
                _materialVariants = {}
                for matName, texId in pairs(pack) do
                    local mv = Instance.new("MaterialVariant")
                    mv.BaseMaterial = Enum.Material[matName]
                    mv.ColorMap = texId; mv.NormalMap = texId
                    mv.RoughnessMap = texId; mv.MetalnessMap = texId
                    mv.StudsPerTile = 5; mv.Name = matName
                    mv.Parent = ms
                    table.insert(_materialVariants, mv)
                end
            else
                for _, mv in ipairs(_materialVariants) do mv:Destroy() end
                _materialVariants = {}
            end
        end})
    tex:Dropdown({Name = "pack", Flag = "tex_pack",
        Items = {"minecraft", "smooth"},
        Default = "minecraft",
        Callback = function(v) WLD.TEX_Pack = v end})
end

do -- Lighting
    local lt = WorldPage:Section({Name = "lighting", Side = 1})
    lt:Toggle({Name = "global shadows", Flag = "lt_shadows", Default = false,
        Callback = function(v) Lighting.GlobalShadows = v end})
    lt:Dropdown({Name = "technology", Flag = "lt_tech",
        Items = {"Voxel", "ShadowMap", "Future", "Compatibility"},
        Default = "Voxel",
        Callback = function(v) Lighting.Technology = Enum.Technology[v] end})
    lt:Slider({Name = "brightness", Flag = "lt_bright",
        Min = 0, Max = 10, Default = 2, Decimals = 0.1,
        Callback = function(v) Lighting.Brightness = v end})
    lt:Slider({Name = "clock time", Flag = "lt_clock",
        Min = 0, Max = 24, Default = 14, Decimals = 0.1,
        Callback = function(v) Lighting.ClockTime = v end})
    lt:Slider({Name = "fog start", Flag = "lt_fogstart",
        Min = 0, Max = 5000, Default = 0, Decimals = 1,
        Callback = function(v) Lighting.FogStart = v end})
    lt:Slider({Name = "fog end", Flag = "lt_fogend",
        Min = 100, Max = 100000, Default = 100000, Decimals = 100,
        Callback = function(v) Lighting.FogEnd = v end})
    lt:Label({Name = "fog color"}):Colorpicker({Flag = "lt_fogcol",
        Default = Color3.fromRGB(192, 192, 192),
        Callback = function(v) Lighting.FogColor = v end})
    lt:Label({Name = "ambient"}):Colorpicker({Flag = "lt_ambient",
        Default = Color3.fromRGB(127, 127, 127),
        Callback = function(v) Lighting.Ambient = v end})
    lt:Label({Name = "outdoor ambient"}):Colorpicker({Flag = "lt_outdoorambient",
        Default = Color3.fromRGB(127, 127, 127),
        Callback = function(v) Lighting.OutdoorAmbient = v end})
end

-- RIGHT SIDE
do -- Skybox
    local sky = WorldPage:Section({Name = "skybox", Side = 2})
    sky:Toggle({Name = "enabled", Flag = "sky_en", Default = false,
        Callback = function(v)
            WLD.SKY_Enabled = v
            if _skyObj then _skyObj:Destroy(); _skyObj = nil end
            if not v or WLD.SKY_Name == "default" then return end
            local data = _skyboxes[WLD.SKY_Name]
            if data then
                _skyObj = Instance.new("Sky")
                _skyObj.SkyboxBk="rbxassetid://"..data.Bk; _skyObj.SkyboxDn="rbxassetid://"..data.Dn
                _skyObj.SkyboxFt="rbxassetid://"..data.Ft; _skyObj.SkyboxLf="rbxassetid://"..data.Lf
                _skyObj.SkyboxRt="rbxassetid://"..data.Rt; _skyObj.SkyboxUp="rbxassetid://"..data.Up
                _skyObj.Parent = Lighting
            end
        end})
    sky:Dropdown({Name = "preset", Flag = "sky_preset",
        Items = {"default","night","space","minecraft","purple day","red night","starry night","sunset","pink day","vibe morning","vibe night","clear day","hell sky","snowy","desert","anime","purple splash","green space","walls of autumn","crimson","earth space","blue abyss"},
        Default = "default",
        Callback = function(v)
            WLD.SKY_Name = v
            if not WLD.SKY_Enabled then return end
            if _skyObj then _skyObj:Destroy(); _skyObj = nil end
            if v == "default" then return end
            local data = _skyboxes[v]
            if data then
                _skyObj = Instance.new("Sky")
                _skyObj.SkyboxBk="rbxassetid://"..data.Bk; _skyObj.SkyboxDn="rbxassetid://"..data.Dn
                _skyObj.SkyboxFt="rbxassetid://"..data.Ft; _skyObj.SkyboxLf="rbxassetid://"..data.Lf
                _skyObj.SkyboxRt="rbxassetid://"..data.Rt; _skyObj.SkyboxUp="rbxassetid://"..data.Up
                _skyObj.Parent = Lighting
            end
        end})
end

do -- Rain
    local rain = WorldPage:Section({Name = "rain", Side = 2})
    rain:Toggle({Name = "enabled", Flag = "rain_en", Default = false,
        Callback = function(v)
            WLD.RAIN_Enabled = v
        end})
    rain:Label({Name = "color"}):Colorpicker({Flag = "rain_color",
        Default = Color3.fromRGB(180, 200, 255),
        Callback = function(v) WLD.RAIN_Color = v end})
    rain:Dropdown({Name = "type", Flag = "rain_type",
        Items = {"drizzle", "light rain", "heavy rain"},
        Default = "drizzle",
        Callback = function(v) WLD.RAIN_Type = v end})
    rain:Slider({Name = "rate", Flag = "rain_rate",
        Min = 1, Max = 100, Default = 50, Decimals = 1,
        Callback = function(v) WLD.RAIN_Rate = v end})
    rain:Slider({Name = "lifetime", Flag = "rain_life",
        Min = 0.5, Max = 10, Default = 3, Decimals = 0.1,
        Callback = function(v) WLD.RAIN_Lifetime = v end})
    rain:Slider({Name = "speed", Flag = "rain_speed",
        Min = 0.1, Max = 1, Default = 0.5, Decimals = 0.01,
        Callback = function(v) WLD.RAIN_Speed = v end})
end

do -- Ambience
    local amb = WorldPage:Section({Name = "ambience", Side = 2})
    amb:Toggle({Name = "enabled", Flag = "amb_en", Default = false,
        Callback = function(v)
            WLD.AMB_Enabled = v
            if not v then
                if _ambSound then _ambSound:Stop(); _ambSound:Destroy(); _ambSound = nil end
                return
            end
            if not _ambSound then
                _ambSound = Instance.new("Sound")
                _ambSound.Looped = true
                _ambSound.Parent = workspace
            end
            _ambSound.SoundId = "rbxassetid://" .. (_ambientSounds[WLD.AMB_Sound] or "179507208")
            _ambSound.Volume = WLD.AMB_Volume
            _ambSound:Play()
        end})
    amb:Dropdown({Name = "sound", Flag = "amb_sound",
        Items = {"night","storm","rain","windy winter","space","day ambience","raindrop"},
        Default = "night",
        Callback = function(v)
            WLD.AMB_Sound = v
            if not WLD.AMB_Enabled or not _ambSound then return end
            _ambSound.SoundId = "rbxassetid://" .. (_ambientSounds[v] or "179507208")
            _ambSound:Play()
        end})
    amb:Slider({Name = "volume", Flag = "amb_vol",
        Min = 0, Max = 1, Default = 0.5, Decimals = 0.01,
        Callback = function(v)
            WLD.AMB_Volume = v
            if _ambSound then _ambSound.Volume = v end
        end})
end

do -- Bloom
    local blm = WorldPage:Section({Name = "bloom", Side = 2})
    blm:Toggle({Name = "enabled", Flag = "blm_en", Default = false,
        Callback = function(v)
            WLD.BLM_Enabled = v
            if not _blmEffect then
                _blmEffect = Instance.new("BloomEffect")
                _blmEffect.Parent = Lighting
            end
            _blmEffect.Enabled = v
        end})
    blm:Slider({Name = "threshold", Flag = "blm_thresh",
        Min = 0, Max = 1, Default = 0.95, Decimals = 0.01,
        Callback = function(v)
            WLD.BLM_Threshold = v
            if _blmEffect then _blmEffect.Threshold = v end
        end})
    blm:Slider({Name = "size", Flag = "blm_size",
        Min = 0, Max = 56, Default = 24, Decimals = 1,
        Callback = function(v)
            WLD.BLM_Size = v
            if _blmEffect then _blmEffect.Size = v end
        end})
    blm:Slider({Name = "intensity", Flag = "blm_int",
        Min = 0, Max = 1, Default = 1, Decimals = 0.01,
        Callback = function(v)
            WLD.BLM_Intensity = v
            if _blmEffect then _blmEffect.Intensity = v end
        end})
end

do -- Sun Rays
    local sun = WorldPage:Section({Name = "sun rays", Side = 2})
    sun:Toggle({Name = "enabled", Flag = "sun_en", Default = false,
        Callback = function(v)
            WLD.SUN_Enabled = v
            if not _sunEffect then
                _sunEffect = Instance.new("SunRaysEffect")
                _sunEffect.Parent = Lighting
            end
            _sunEffect.Enabled = v
        end})
    sun:Slider({Name = "intensity", Flag = "sun_int",
        Min = 0, Max = 1, Default = 0.25, Decimals = 0.01,
        Callback = function(v)
            WLD.SUN_Intensity = v
            if _sunEffect then _sunEffect.Intensity = v end
        end})
    sun:Slider({Name = "spread", Flag = "sun_spread",
        Min = 0, Max = 1, Default = 1, Decimals = 0.01,
        Callback = function(v)
            WLD.SUN_Spread = v
            if _sunEffect then _sunEffect.Spread = v end
        end})
end

-- ══════════════════════════════════════════════════════════════
-- IN-GAME RAIN SYSTEM (buildthomas style ParticleEmitter rain)
-- ══════════════════════════════════════════════════════════════
do
    local STRAIGHT_ASSET  = "rbxassetid://1822883048"
    local TOPDOWN_ASSET   = "rbxassetid://1822856633"
    local SPLASH_ASSET    = "rbxassetid://1822856633"
    local SOUND_ASSET     = "rbxassetid://1516791621"
    local MAX_RATE        = 600
    local MAX_SPEED       = 60
    local SPLASH_NUM      = 20
    local EMITTER_DIM     = 40
    local EMITTER_FORWARD = 100
    local EMITTER_UP      = 20
    local SCANHEIGHT      = 1000
    local UPDATE_PERIOD   = 6
    local OCCLUDE_Y       = 500
    local OCCLUDE_XZ_MIN  = -100
    local OCCLUDE_XZ_MAX  = 100
    local OCCLUDE_SCAN_Y  = 550
    local OCCLUDE_MSPD    = 70
    local OCCLUDE_MAXSPD  = 100
    local OCCLUDE_SPREAD  = Vector2.new(10, 10)
    local OCCLUDE_MAXINT  = 2

    -- Build emitter part
    local RainPart = Instance.new("Part")
    RainPart.Transparency = 1; RainPart.Anchored = true
    RainPart.CanCollide = false; RainPart.Size = Vector3.new(0.05,0.05,0.05)
    RainPart.Name = "ZHRainPart"

    local pStraight = Instance.new("ParticleEmitter")
    pStraight.Name = "RainStraight"
    pStraight.LightEmission = 0.05; pStraight.LightInfluence = 0.9
    pStraight.Size = NumberSequence.new(10)
    pStraight.Texture = STRAIGHT_ASSET; pStraight.LockedToPart = true
    pStraight.Enabled = false; pStraight.Lifetime = NumberRange.new(0.8)
    pStraight.Rate = MAX_RATE; pStraight.Speed = NumberRange.new(MAX_SPEED)
    pStraight.EmissionDirection = Enum.NormalId.Bottom
    pStraight.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
    pStraight.Parent = RainPart

    local pTopdown = Instance.new("ParticleEmitter")
    pTopdown.Name = "RainTopDown"
    pTopdown.LightEmission = 0.05; pTopdown.LightInfluence = 0.9
    pTopdown.Size = NumberSequence.new{NumberSequenceKeypoint.new(0,5.33,2.75),NumberSequenceKeypoint.new(1,5.33,2.75)}
    pTopdown.Texture = TOPDOWN_ASSET; pTopdown.LockedToPart = true
    pTopdown.Enabled = false; pTopdown.Rotation = NumberRange.new(0,360)
    pTopdown.Lifetime = NumberRange.new(0.8); pTopdown.Rate = MAX_RATE
    pTopdown.Speed = NumberRange.new(MAX_SPEED)
    pTopdown.EmissionDirection = Enum.NormalId.Bottom
    pTopdown.Parent = RainPart

    -- Splash & occluded rain attachments
    local splashAtts, rainAtts = {}, {}
    for i = 1, SPLASH_NUM do
        local sa = Instance.new("Attachment"); sa.Name = "__RainSplash"
        local spe = Instance.new("ParticleEmitter")
        spe.LightEmission = 0.05; spe.LightInfluence = 0.9
        spe.Size = NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.4,3),NumberSequenceKeypoint.new(1,0)}
        spe.Texture = SPLASH_ASSET; spe.Rotation = NumberRange.new(0,360)
        spe.Lifetime = NumberRange.new(0.1,0.15); spe.Enabled = false
        spe.Rate = 0; spe.Speed = NumberRange.new(0); spe.Name = "RainSplash"
        spe.Parent = sa; splashAtts[i] = sa

        local ra = Instance.new("Attachment"); ra.Name = "__RainOccluded"
        local rs = pStraight:Clone()
        rs.Speed = NumberRange.new(OCCLUDE_MSPD,OCCLUDE_MAXSPD)
        rs.SpreadAngle = OCCLUDE_SPREAD; rs.LockedToPart = false; rs.Enabled = false; rs.Parent = ra
        local rt = pTopdown:Clone()
        rt.Speed = NumberRange.new(OCCLUDE_MSPD,OCCLUDE_MAXSPD)
        rt.SpreadAngle = OCCLUDE_SPREAD; rt.LockedToPart = false; rt.Enabled = false; rt.Parent = ra
        rainAtts[i] = ra
    end

    -- Rain sound
    local rainSound = Instance.new("Sound")
    rainSound.SoundId = SOUND_ASSET; rainSound.Looped = true; rainSound.Volume = 0

    local _rainConns = {}
    local _inside = true
    local _frame = UPDATE_PERIOD
    local _rand = Random.new()
    local _rainActive = false
    local _occIntensity = 0
    local _numSplashes = 0

    local function doRaycast(ray)
        return workspace:FindPartOnRayWithIgnoreList(ray, {RainPart, LocalPlayer.Character})
    end

    local function applyRainSettings()
        local typeRates = {drizzle=0.15, ["light rain"]=0.5, ["heavy rain"]=1.0}
        local intensity = (typeRates[WLD.RAIN_Type] or 0.5) * (WLD.RAIN_Rate / 100)
        intensity = math.clamp(intensity, 0, 1)
        local speed = WLD.RAIN_Speed

        pStraight.Rate = math.floor(MAX_RATE * intensity)
        pTopdown.Rate  = math.floor(MAX_RATE * intensity)
        pStraight.Speed = NumberRange.new(speed * MAX_SPEED)
        pTopdown.Speed  = NumberRange.new(speed * MAX_SPEED)
        _occIntensity = math.ceil(OCCLUDE_MAXINT * intensity)
        _numSplashes  = math.floor(SPLASH_NUM * intensity)

        local col = ColorSequence.new(WLD.RAIN_Color)
        pStraight.Color = col; pTopdown.Color = col
        local lifetime = NumberRange.new(WLD.RAIN_Lifetime * 0.3, WLD.RAIN_Lifetime)
        pStraight.Lifetime = lifetime; pTopdown.Lifetime = lifetime
    end

    local function startRainLoop()
        _rainConns[#_rainConns+1] = RunService.RenderStepped:Connect(function()
            local part = doRaycast(Ray.new(Camera.CFrame.p, -Vector3.new(0,1,0) * SCANHEIGHT))
            if not part then
                local lv = Camera.CFrame.lookVector
                local rd = Vector3.new(0,-1,0)
                local t  = math.abs(lv:Dot(rd))
                local right = lv:Cross(-rd)
                right = right.Magnitude > 0.001 and right.Unit or -rd
                local fwd = rd:Cross(right).Unit
                RainPart.Size = Vector3.new(EMITTER_DIM, EMITTER_DIM,
                    EMITTER_DIM + (1-t)*(EMITTER_FORWARD - EMITTER_DIM))
                RainPart.CFrame = CFrame.new(Camera.CFrame.p.X, Camera.CFrame.p.Y, Camera.CFrame.p.Z,
                    right.X,-rd.X,fwd.X, right.Y,-rd.Y,fwd.Y, right.Z,-rd.Z,fwd.Z)
                    + (1-t)*lv*(RainPart.Size.Z/3) - t*rd*EMITTER_UP
                pStraight.Enabled = true; pTopdown.Enabled = true
                _inside = false
            else
                pStraight.Enabled = false; pTopdown.Enabled = false
                _inside = true
            end
        end)

        _rainConns[#_rainConns+1] = RunService.Stepped:Connect(function()
            _frame = _frame + 1
            if _frame >= UPDATE_PERIOD then
                _frame = 0
                local mapped = Camera.CFrame:Inverse() * (Camera.CFrame.p - Vector3.new(0,1,0))
                local rot = NumberRange.new(math.deg(math.atan2(-mapped.X, mapped.Y)))
                if _inside then
                    for _,v in ipairs(rainAtts) do v.RainStraight.Rotation = rot end
                else
                    pStraight.Rotation = rot
                end
            end
            local tf = Camera.CFrame
            local right = tf.lookVector:Cross(-Vector3.new(0,1,0))
            right = right.Magnitude > 0.001 and right.Unit or -Vector3.new(0,1,0)
            local fwd = Vector3.new(0,-1,0):Cross(right).Unit
            local transform = CFrame.new(tf.p.X,tf.p.Y,tf.p.Z,
                right.X,-0,fwd.X, right.Y,-1,fwd.Y, right.Z,-0,fwd.Z)
            local rayDir = Vector3.new(0,-1,0) * OCCLUDE_SCAN_Y
            for i = 1, _numSplashes do
                local x = _rand:NextNumber(OCCLUDE_XZ_MIN, OCCLUDE_XZ_MAX)
                local z = _rand:NextNumber(OCCLUDE_XZ_MIN, OCCLUDE_XZ_MAX)
                local _, pos, norm = doRaycast(Ray.new(transform * Vector3.new(x, OCCLUDE_Y, z), rayDir))
                if pos then
                    splashAtts[i].Position = pos + (norm or Vector3.new(0,1,0)) * 0.5
                    splashAtts[i].RainSplash:Emit(1)
                end
            end
        end)
    end

    local function stopRainLoop()
        for _, c in ipairs(_rainConns) do c:Disconnect() end
        _rainConns = {}
    end

    local function enableRain()
        if _rainActive then return end
        _rainActive = true
        applyRainSettings()
        RainPart.Parent = Camera
        for i = 1, SPLASH_NUM do
            splashAtts[i].Parent = workspace.Terrain
            rainAtts[i].Parent  = workspace.Terrain
        end
        rainSound.Volume = 0.2 * math.clamp(WLD.RAIN_Rate / 100, 0, 1)
        rainSound.Parent = workspace
        rainSound:Play()
        startRainLoop()
    end

    local function disableRain()
        if not _rainActive then return end
        _rainActive = false
        stopRainLoop()
        pStraight.Enabled = false; pTopdown.Enabled = false
        RainPart.Size = Vector3.new(0.05,0.05,0.05)
        RainPart.Parent = nil
        for i = 1, SPLASH_NUM do
            splashAtts[i].Parent = nil
            rainAtts[i].Parent  = nil
        end
        rainSound:Stop(); rainSound.Parent = nil
    end

    -- Watch for toggle changes
    RunService.Heartbeat:Connect(function()
        if WLD.RAIN_Enabled and not _rainActive then
            enableRain()
        elseif not WLD.RAIN_Enabled and _rainActive then
            disableRain()
        elseif _rainActive then
            -- Live-update color and speed
            local col = ColorSequence.new(WLD.RAIN_Color)
            if pStraight.Color ~= col then applyRainSettings() end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SELF ESP UI (Visuals right side)
-- ══════════════════════════════════════════════════════════════
do
    local se = VisualsPage:Section({Name = "self esp", Side = 2})

    -- Highlight body
    se:Toggle({Name = "highlight body", Flag = "se_hl", Default = false,
        Callback = function(v) SE.HLEnabled = v
            if not v and _seHL then _seHL:Destroy(); _seHL = nil end
        end})
    se:Label({Name = "hl fill"}):Colorpicker({Flag = "se_hl_fill",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SE.HLFill = v; if _seHL then _seHL.FillColor = v end end})
    se:Label({Name = "hl outline"}):Colorpicker({Flag = "se_hl_outline",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) SE.HLOutline = v; if _seHL then _seHL.OutlineColor = v end end})

    -- Material body
    se:Toggle({Name = "material body", Flag = "se_mat", Default = false,
        Callback = function(v)
            SE.MatEnabled = v
            if not v then
                for _, p in ipairs(_seMatParts) do
                    if p.obj and p.obj.Parent then p.obj.Material = p.origMat; p.obj.Color = p.origCol end
                end
                _seMatParts = {}
            end
        end})
    se:Label({Name = "mat color"}):Colorpicker({Flag = "se_mat_col",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SE.MatColor = v end})
    se:Dropdown({Name = "material", Flag = "se_mat_type",
        Items = {"ForceField","Neon","SmoothPlastic","Glass","Ice","Metal","Wood","Brick"},
        Default = "ForceField",
        Callback = function(v) SE.MatType = v end})

    -- Material tools
    se:Toggle({Name = "material tools", Flag = "se_mattool", Default = false,
        Callback = function(v)
            SE.MatToolEnabled = v
            if not v then
                for _, p in ipairs(_seToolParts) do
                    if p.obj and p.obj.Parent then p.obj.Material = p.origMat; p.obj.Color = p.origCol end
                end
                _seToolParts = {}
            end
        end})
    se:Label({Name = "tool color"}):Colorpicker({Flag = "se_mattool_col",
        Default = Color3.fromRGB(255, 200, 50),
        Callback = function(v) SE.MatToolColor = v end})
    se:Dropdown({Name = "tool material", Flag = "se_mattool_type",
        Items = {"ForceField","Neon","SmoothPlastic","Glass","Metal","Wood"},
        Default = "Neon",
        Callback = function(v) SE.MatToolType = v end})

    -- China hat
    se:Toggle({Name = "china hat", Flag = "se_china", Default = false,
        Callback = function(v)
            SE.ChinaEnabled = v
            if not v and _seChina then _seChina:Destroy(); _seChina = nil end
        end})
    se:Label({Name = "hat color"}):Colorpicker({Flag = "se_china_col",
        Default = Color3.fromRGB(200, 200, 255),
        Callback = function(v) SE.ChinaColor = v
            if _seChina then _seChina.Color = v end
        end})
    se:Dropdown({Name = "hat material", Flag = "se_china_mat",
        Items = {"SmoothPlastic","Neon","ForceField","Glass","Metal"},
        Default = "SmoothPlastic",
        Callback = function(v) SE.ChinaMat = v
            if _seChina then _seChina.Material = Enum.Material[v] end
        end})
    se:Slider({Name = "height", Flag = "se_china_h",
        Min = 0.1, Max = 2, Default = 0.3, Decimals = 0.01,
        Callback = function(v) SE.ChinaHeight = v end})
    se:Slider({Name = "radius", Flag = "se_china_r",
        Min = 0.5, Max = 6, Default = 3, Decimals = 0.1,
        Callback = function(v) SE.ChinaRadius = v end})
    se:Slider({Name = "offset y", Flag = "se_china_oy",
        Min = -2, Max = 2, Default = 0.5, Decimals = 0.01,
        Callback = function(v) SE.ChinaOffsetY = v end})

    -- Particle aura
    se:Toggle({Name = "particle aura", Flag = "se_aura", Default = false,
        Callback = function(v)
            SE.AuraEnabled = v
            if not v and _seAura then _seAura:Destroy(); _seAura = nil end
        end})
    se:Label({Name = "aura color"}):Colorpicker({Flag = "se_aura_col",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SE.AuraColor = v
            if _seAura then _seAura.Color = ColorSequence.new(v) end
        end})
    se:Dropdown({Name = "particle type", Flag = "se_aura_type",
        Items = {"sparkles","fire","smoke","magic","stars","hearts","bubbles","confetti"},
        Default = "sparkles",
        Callback = function(v) SE.AuraParticle = v
            if _seAura then _seAura:Destroy(); _seAura = nil end -- rebuild on next tick
        end})

    -- Trail
    se:Toggle({Name = "trail", Flag = "se_trail", Default = false,
        Callback = function(v)
            SE.TrailEnabled = v
            if not v and _seTrail then _seTrail:Destroy(); _seTrail = nil end
        end})
    se:Label({Name = "trail color"}):Colorpicker({Flag = "se_trail_col",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SE.TrailColor = v
            if _seTrail then _seTrail.Color = ColorSequence.new(v) end
        end})
    se:Slider({Name = "lifetime", Flag = "se_trail_life",
        Min = 0.1, Max = 3, Default = 0.5, Decimals = 0.1,
        Callback = function(v) SE.TrailLifetime = v
            if _seTrail then _seTrail.Lifetime = v end
        end})

    -- Jump aura
    se:Toggle({Name = "jump aura", Flag = "se_jumpaura", Default = false,
        Callback = function(v) SE.JumpAuraEnabled = v end})
    se:Label({Name = "aura color"}):Colorpicker({Flag = "se_jumpaura_col",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SE.JumpAuraColor = v end})
    se:Slider({Name = "lifetime", Flag = "se_jumpaura_life",
        Min = 0.1, Max = 2, Default = 0.5, Decimals = 0.1,
        Callback = function(v) SE.JumpAuraLifetime = v end})
end

-- ══════════════════════════════════════════════════════════════
-- HIT FEEDBACK UI (Visuals bottom right)
-- ══════════════════════════════════════════════════════════════
do
    local hf = VisualsPage:Section({Name = "hit feedback", Side = 2})

    -- Hit Sound
    hf:Toggle({Name = "hit sound", Flag = "hf_sound", Default = false,
        Callback = function(v) HF.SoundEnabled = v end})
    hf:Dropdown({Name = "sound type", Flag = "hf_sound_type",
        Items = {"neverlose","skeet","mc bow","rust","bubble","beep"},
        Default = "neverlose",
        Callback = function(v) HF.SoundType = v end})
    hf:Slider({Name = "volume", Flag = "hf_sound_vol",
        Min = 0.1, Max = 5, Default = 1.0, Decimals = 0.1,
        Callback = function(v) HF.SoundVolume = v end})

    -- Hit Overlay
    hf:Toggle({Name = "hit overlay", Flag = "hf_overlay", Default = false,
        Callback = function(v) HF.OverlayEnabled = v end})
    hf:Label({Name = "overlay color"}):Colorpicker({Flag = "hf_overlay_col",
        Default = Color3.fromRGB(133, 220, 255),
        Callback = function(v) HF.OverlayColor = v end})
    hf:Slider({Name = "overlay transparency", Flag = "hf_overlay_trans",
        Min = 0, Max = 1, Default = 0.8, Decimals = 0.01,
        Callback = function(v) HF.OverlayTransp = v end})
    hf:Slider({Name = "overlay lifetime", Flag = "hf_overlay_life",
        Min = 0.1, Max = 2, Default = 0.7, Decimals = 0.1,
        Callback = function(v) HF.OverlayLifetime = v end})

    -- 2D Hit Marker
    hf:Toggle({Name = "2d hit marker", Flag = "hf_hm2d", Default = false,
        Callback = function(v) HF.HM2DEnabled = v end})
    hf:Label({Name = "marker color"}):Colorpicker({Flag = "hf_hm2d_col",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) HF.HM2DColor = v end})
    hf:Label({Name = "marker outline"}):Colorpicker({Flag = "hf_hm2d_out",
        Default = Color3.fromRGB(15, 15, 15),
        Callback = function(v) HF.HM2DOutline = v end})
    hf:Slider({Name = "marker thickness", Flag = "hf_hm2d_thick",
        Min = 1, Max = 5, Default = 2, Decimals = 1,
        Callback = function(v) HF.HM2DThickness = v end})
    hf:Slider({Name = "marker lifetime", Flag = "hf_hm2d_life",
        Min = 0.1, Max = 2, Default = 0.7, Decimals = 0.1,
        Callback = function(v) HF.HM2DLifetime = v end})

    -- Hit Chams
    hf:Toggle({Name = "hit chams", Flag = "hf_chams", Default = false,
        Callback = function(v) HF.ChamsEnabled = v end})
    hf:Label({Name = "chams color"}):Colorpicker({Flag = "hf_chams_col",
        Default = Color3.fromRGB(142, 242, 255),
        Callback = function(v) HF.ChamsColor = v end})
    hf:Slider({Name = "chams transparency", Flag = "hf_chams_trans",
        Min = 0, Max = 1, Default = 0.8, Decimals = 0.01,
        Callback = function(v) HF.ChamsTransp = v end})
    hf:Dropdown({Name = "chams type", Flag = "hf_chams_type",
        Items = {"neon","forcefield","outline"},
        Default = "neon",
        Callback = function(v) HF.ChamsType = v end})
    hf:Dropdown({Name = "chams animation", Flag = "hf_chams_anim",
        Items = {"new fade","fade","none"},
        Default = "new fade",
        Callback = function(v) HF.ChamsAnimation = v end})
    hf:Slider({Name = "chams lifetime", Flag = "hf_chams_life",
        Min = 0.1, Max = 1.5, Default = 0.8, Decimals = 0.1,
        Callback = function(v) HF.ChamsLifetime = v end})
end

-- ══════════════════════════════════════════════════════════════
-- SELF ESP LOGIC
-- ══════════════════════════════════════════════════════════════

-- Particle aura texture map (from juju)
local _auraTextures = {
    -- Simple texture-based (work reliably)
    sparkles  = "rbxasset://textures/particles/sparkles_main.dds",
    fire      = "rbxassetid://10545078665",
    smoke     = "rbxasset://textures/particles/smoke_main.dds",
    magic     = "rbxassetid://1198143982",
    stars     = "rbxassetid://5869684852",
    hearts    = "rbxassetid://6838963660",
    bubbles   = "rbxassetid://5859443854",
    confetti  = "rbxassetid://4919681682",
}

-- Juju model-based auras (these are models, not textures)
local _auraModels = {
    starlight = "rbxassetid://134645216613107",
    lightning = "rbxassetid://88833232287502",
    heavenly  = "rbxassetid://139300897520961",
    ribbon    = "rbxassetid://132069507632161",
    sakura    = "rbxassetid://81755778619404",
    angel     = "rbxassetid://97658130917593",
    wind      = "rbxassetid://80694081850877",
    flow      = "rbxassetid://119913533725648",
    star      = "rbxassetid://73754563740680",
}

-- China hat building function — using correct mesh + weld (from working reference)
local function buildChinaHat(hrp)
    if _seChina then _seChina:Destroy(); _seChina = nil end
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local hat = Instance.new("Part")
    hat.Name = "ZHChinaHat"
    hat.Size = Vector3.new(1, 1, 1)
    hat.Anchored = false; hat.CanCollide = false; hat.CastShadow = false
    hat.Material = Enum.Material[SE.ChinaMat] or Enum.Material.SmoothPlastic
    hat.Color = SE.ChinaColor
    hat.Transparency = 0.1

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId   = "rbxassetid://1033714"  -- correct china hat mesh
    mesh.Scale    = Vector3.new(SE.ChinaRadius, SE.ChinaHeight, SE.ChinaRadius)
    mesh.Parent   = hat

    -- Weld to head exactly like the reference script
    local weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = hat
    weld.C0    = CFrame.new(0, 0.9 + SE.ChinaOffsetY, 0)
    weld.Parent = hat

    hat.Parent = char
    _seChina = hat
end

-- Build simple particle aura
local function buildSimpleAura(hrp)
    if _seAura then pcall(function() _seAura:Destroy() end); _seAura = nil end
    
    local pe = Instance.new("ParticleEmitter")
    pe.Name = "ZHAura"
    pe.Texture = _auraTextures[SE.AuraParticle] or _auraTextures.sparkles
    pe.Color = ColorSequence.new(SE.AuraColor)
    pe.LightEmission = 0.5; pe.LightInfluence = 0.5
    pe.Rate = 25; pe.Speed = NumberRange.new(1, 3)
    pe.Lifetime = NumberRange.new(1, 2)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Size = NumberSequence.new{NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(1,0)}
    pe.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}
    pe.Parent = hrp
    _seAura = pe
end

-- Build aura emitter
local function buildAura(hrp)
    if _seAura then _seAura:Destroy(); _seAura = nil end
    
    -- Try to load model-based aura first
    local modelId = _auraModels[SE.AuraParticle]
    if modelId then
        task.spawn(function()
            local ok, result = pcall(function()
                return game:GetObjects(modelId)[1]
            end)
            if ok and result then
                local cloned = result:Clone()
                for _, child in ipairs(cloned:GetDescendants()) do
                    if child:IsA("ParticleEmitter") then
                        child.Color = ColorSequence.new(SE.AuraColor)
                    end
                    if child:IsA("BasePart") then
                        local matching = hrp.Parent:FindFirstChild(child.Name)
                        if matching then
                            child.Parent = matching
                        end
                    end
                end
                _seAura = cloned
            else
                -- Fallback to simple particle
                buildSimpleAura(hrp)
            end
        end)
    else
        -- Use simple texture-based particle
        buildSimpleAura(hrp)
    end
end

-- Build trail
local function buildTrail(hrp)
    if _seTrail then _seTrail:Destroy(); _seTrail = nil end
    local a0 = Instance.new("Attachment"); a0.Position = Vector3.new(0, 1, 0); a0.Parent = hrp
    local a1 = Instance.new("Attachment"); a1.Position = Vector3.new(0,-1, 0); a1.Parent = hrp
    local t = Instance.new("Trail")
    t.Attachment0 = a0; t.Attachment1 = a1
    t.Color = ColorSequence.new(SE.TrailColor)
    t.Lifetime = SE.TrailLifetime
    t.MinLength = 0; t.FaceCamera = true
    t.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}
    t.Parent = hrp
    _seTrail = t
end

-- Jump aura using StateChanged event (reliable, not polling)
local _jumpAuraActive = false
local _jumpConn = nil

local function setupJumpAura()
    if _jumpConn then _jumpConn:Disconnect(); _jumpConn = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    _jumpConn = hum.StateChanged:Connect(function(_, new)
        if new ~= Enum.HumanoidStateType.Jumping then return end
        if _jumpAuraActive then return end
        _jumpAuraActive = true

        task.spawn(function()
            local groundPos = hrp.Position - Vector3.new(0, 3, 0)
            local startTime = tick()
            local life = SE.JumpAuraLifetime
            local col  = SE.JumpAuraColor

            local ring = Drawing.new("Circle")
            ring.Color     = col
            ring.Filled    = false
            ring.Thickness = 2
            ring.NumSides  = 48
            ring.Visible   = true

            repeat
                local t = (tick() - startTime) / life
                local sp, onScreen = Camera:WorldToViewportPoint(groundPos)
                if onScreen and sp.Z > 0 then
                    ring.Position     = Vector2.new(sp.X, sp.Y)
                    ring.Radius       = t * 150
                    ring.Transparency = t
                    ring.Visible      = true
                else
                    ring.Visible = false
                end
                RunService.RenderStepped:Wait()
            until tick() - startTime >= life

            ring:Remove()
            _jumpAuraActive = false
        end)
    end)
end

-- Set up on character load
setupJumpAura()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupJumpAura()
end)

-- Self ESP Heartbeat loop (~20fps)
local _seThrottle = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - _seThrottle < 0.05 then return end
    _seThrottle = now

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Highlight
    if SE.HLEnabled then
        if not _seHL or not _seHL.Parent then
            _seHL = Instance.new("Highlight")
            _seHL.Adornee = char; _seHL.Parent = CoreGui
        end
        _seHL.FillColor = SE.HLFill; _seHL.OutlineColor = SE.HLOutline
        _seHL.FillTransparency = 0.5; _seHL.OutlineTransparency = 0
    elseif _seHL then
        _seHL:Destroy(); _seHL = nil
    end

    -- Material body (rescan when empty)
    if SE.MatEnabled then
        if #_seMatParts == 0 then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    table.insert(_seMatParts, {obj=p, origMat=p.Material, origCol=p.Color})
                end
            end
        end
        local mat = Enum.Material[SE.MatType] or Enum.Material.ForceField
        for _, p in ipairs(_seMatParts) do
            if p.obj and p.obj.Parent then p.obj.Material = mat; p.obj.Color = SE.MatColor end
        end
    elseif #_seMatParts > 0 then
        for _, p in ipairs(_seMatParts) do
            if p.obj and p.obj.Parent then p.obj.Material = p.origMat; p.obj.Color = p.origCol end
        end
        _seMatParts = {}
    end

    -- Material tools
    if SE.MatToolEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if #_seToolParts == 0 then
                for _, p in ipairs(tool:GetDescendants()) do
                    if p:IsA("BasePart") then
                        table.insert(_seToolParts, {obj=p, origMat=p.Material, origCol=p.Color})
                    end
                end
            end
            local mat = Enum.Material[SE.MatToolType] or Enum.Material.Neon
            for _, p in ipairs(_seToolParts) do
                if p.obj and p.obj.Parent then p.obj.Material = mat; p.obj.Color = SE.MatToolColor end
            end
        else
            _seToolParts = {}
        end
    elseif #_seToolParts > 0 then
        for _, p in ipairs(_seToolParts) do
            if p.obj and p.obj.Parent then p.obj.Material = p.origMat; p.obj.Color = p.origCol end
        end
        _seToolParts = {}
    end

    -- China hat
    if SE.ChinaEnabled then
        if not _seChina or not _seChina.Parent then
            buildChinaHat(hrp)
        else
            -- Keep attached via WeldConstraint, just update color/mat if changed
            _seChina.Color = SE.ChinaColor
            _seChina.Material = Enum.Material[SE.ChinaMat] or Enum.Material.SmoothPlastic
        end
    elseif _seChina then
        _seChina:Destroy(); _seChina = nil
    end

    -- Particle aura
    if SE.AuraEnabled then
        if not _seAura or not _seAura.Parent then buildAura(hrp) end
    elseif _seAura then
        _seAura:Destroy(); _seAura = nil
    end

    -- Trail
    if SE.TrailEnabled then
        if not _seTrail or not _seTrail.Parent then buildTrail(hrp) end
    elseif _seTrail then
        _seTrail:Destroy(); _seTrail = nil
    end
end)

-- ══════════════════════════════════════════════════════════════
-- PLAYERS PAGE
-- ══════════════════════════════════════════════════════════════
do
    local _playerPriority = {}
    local _selectedPlayer = nil
    local _playerRows     = {}

    local leftCol  = PlayersPage.ColumnsData[1].Instance
    local rightCol = PlayersPage.ColumnsData[2].Instance
    rightCol.Visible = false
    leftCol.Size = UDim2.new(2, 0, 1, 0)

    for _, c in ipairs(leftCol:GetChildren()) do
        if c:IsA("UIListLayout") or c:IsA("UIPadding") then c:Destroy() end
    end

    local BG_DARK   = Color3.fromRGB(21, 21, 21)
    local BG_MID    = Color3.fromRGB(26, 26, 26)
    local BG_LIGHT  = Color3.fromRGB(32, 32, 32)
    local BG_HOVER  = Color3.fromRGB(38, 38, 52)
    local TEXT_MAIN = Color3.fromRGB(200, 200, 200)
    local TEXT_DIM  = Color3.fromRGB(135, 135, 135)
    local ACCENT    = Color3.fromRGB(126, 192, 255)
    local OUTLINE   = Color3.fromRGB(35, 35, 35)
    local DETAIL_H  = 88

    local _prioColors = {
        LocalPlayer = ACCENT,
        Neutral     = TEXT_DIM,
        Enemy       = Color3.fromRGB(255, 80, 80),
        Friend      = Color3.fromRGB(80, 200, 120),
    }

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 1, -4)
    container.Position = UDim2.new(0, 2, 0, 2)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = leftCol

    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 26)
    topBar.BackgroundColor3 = BG_MID
    topBar.BorderSizePixel = 0
    topBar.Parent = container
    Instance.new("UIStroke", topBar).Color = OUTLINE

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -66, 1, -4)
    searchBox.Position = UDim2.new(0, 2, 0, 2)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search Here"
    searchBox.PlaceholderColor3 = TEXT_DIM
    searchBox.TextColor3 = TEXT_MAIN
    searchBox.TextSize = 12; searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Text = ""; searchBox.ClearTextOnFocus = false
    searchBox.BorderSizePixel = 0
    searchBox.Active = IsMobile; searchBox.Selectable = IsMobile
    searchBox.Parent = topBar
    local spad = Instance.new("UIPadding"); spad.PaddingLeft = UDim.new(0,6); spad.Parent = searchBox

    if IsMobile then
        searchBox.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then
                searchBox.Active = true; searchBox.Selectable = true
                task.defer(function() searchBox:CaptureFocus() end)
            end
        end)
    end

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 62, 1, -4)
    refreshBtn.Position = UDim2.new(1, -64, 0, 2)
    refreshBtn.BackgroundColor3 = BG_LIGHT; refreshBtn.BorderSizePixel = 0
    refreshBtn.Text = "Refresh"; refreshBtn.TextColor3 = TEXT_MAIN
    refreshBtn.TextSize = 11; refreshBtn.Font = Enum.Font.Gotham
    refreshBtn.AutoButtonColor = false; refreshBtn.Parent = topBar
    Instance.new("UIStroke", refreshBtn).Color = OUTLINE

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.Position = UDim2.new(0, 0, 0, 28)
    header.BackgroundColor3 = BG_DARK; header.BorderSizePixel = 0
    header.Parent = container
    Instance.new("UIStroke", header).Color = OUTLINE

    local function hdr(text, xs, ws, align)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(ws,0,1,0); l.Position = UDim2.new(xs,0,0,0)
        l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = TEXT_MAIN
        l.TextSize = 11; l.Font = Enum.Font.GothamBold
        l.TextXAlignment = align or Enum.TextXAlignment.Center
        l.Parent = header; return l
    end
    local hName = hdr("Name", 0, 0.40, Enum.TextXAlignment.Left)
    local hnPad = Instance.new("UIPadding"); hnPad.PaddingLeft = UDim.new(0,6); hnPad.Parent = hName
    hdr("UserId",   0.40, 0.35, Enum.TextXAlignment.Center)
    hdr("Priority", 0.75, 0.25, Enum.TextXAlignment.Center)

    -- List
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 1, -(50 + DETAIL_H + 4))
    listFrame.Position = UDim2.new(0, 0, 0, 50)
    listFrame.BackgroundColor3 = BG_DARK; listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 3
    listFrame.ScrollBarImageColor3 = ACCENT
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.Parent = container
    Instance.new("UIStroke", listFrame).Color = OUTLINE
    Instance.new("UIListLayout", listFrame).SortOrder = Enum.SortOrder.LayoutOrder

    local listLayout = Instance.new("UIListLayout")
    -- Detail panel
    local detailPanel = Instance.new("Frame")
    detailPanel.Size = UDim2.new(1, 0, 0, DETAIL_H)
    detailPanel.Position = UDim2.new(0, 0, 1, -DETAIL_H)
    detailPanel.BackgroundColor3 = BG_MID; detailPanel.BorderSizePixel = 0
    detailPanel.Parent = container
    Instance.new("UIStroke", detailPanel).Color = OUTLINE

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 66, 0, 66)
    avatarImg.Position = UDim2.new(0, 10, 0.5, -33)
    avatarImg.BackgroundColor3 = BG_LIGHT; avatarImg.BorderSizePixel = 0
    avatarImg.Image = ""; avatarImg.Parent = detailPanel
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0,4)

    local function infoLbl(y, txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0,200,0,16); l.Position = UDim2.new(0,84,0,y)
        l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = TEXT_MAIN
        l.TextSize = 12; l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = detailPanel
        return l
    end
    local nameLbl = infoLbl(8,  "Name: ???")
    local dispLbl = infoLbl(26, "DisplayName: ???")
    local idLbl   = infoLbl(44, "UserId: ???")

    local prioTitle = Instance.new("TextLabel")
    prioTitle.Size = UDim2.new(0,82,0,14); prioTitle.Position = UDim2.new(1,-94,0,6)
    prioTitle.BackgroundTransparency = 1; prioTitle.Text = "Priority"
    prioTitle.TextColor3 = TEXT_MAIN; prioTitle.TextSize = 11
    prioTitle.Font = Enum.Font.GothamBold
    prioTitle.TextXAlignment = Enum.TextXAlignment.Center; prioTitle.Parent = detailPanel

    local prioBtn = Instance.new("TextButton")
    prioBtn.Size = UDim2.new(0,82,0,22); prioBtn.Position = UDim2.new(1,-94,0,22)
    prioBtn.BackgroundColor3 = BG_LIGHT; prioBtn.BorderSizePixel = 0
    prioBtn.Text = "-"; prioBtn.TextColor3 = TEXT_DIM
    prioBtn.TextSize = 11; prioBtn.Font = Enum.Font.Gotham
    prioBtn.AutoButtonColor = false; prioBtn.Parent = detailPanel
    Instance.new("UIStroke", prioBtn).Color = OUTLINE

    local prioDropdown = Instance.new("Frame")
    prioDropdown.Size = UDim2.new(0,82,0,66); prioDropdown.Position = UDim2.new(1,-94,0,46)
    prioDropdown.BackgroundColor3 = BG_MID; prioDropdown.BorderSizePixel = 0
    prioDropdown.Visible = false; prioDropdown.ZIndex = 30; prioDropdown.Parent = detailPanel
    Instance.new("UIStroke", prioDropdown).Color = OUTLINE
    Instance.new("UIListLayout", prioDropdown).SortOrder = Enum.SortOrder.LayoutOrder

    for _, opt in ipairs({"Neutral","Enemy","Friend"}) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,22); ob.BackgroundColor3 = BG_LIGHT
        ob.BorderSizePixel = 0; ob.Text = opt; ob.TextColor3 = _prioColors[opt]
        ob.TextSize = 11; ob.Font = Enum.Font.Gotham
        ob.AutoButtonColor = false; ob.ZIndex = 31; ob.Parent = prioDropdown
        ob.MouseButton1Click:Connect(function()
            if not _selectedPlayer then return end
            _playerPriority[_selectedPlayer.UserId] = opt
            prioBtn.Text = opt; prioBtn.TextColor3 = _prioColors[opt]
            prioDropdown.Visible = false
            local row = _playerRows[_selectedPlayer.UserId]
            if row then
                local pl = row:FindFirstChild("PrioLabel")
                if pl then pl.Text = opt; pl.TextColor3 = _prioColors[opt] end
            end
        end)
    end

    prioBtn.MouseButton1Click:Connect(function()
        if _selectedPlayer and _selectedPlayer ~= LocalPlayer then
            prioDropdown.Visible = not prioDropdown.Visible
        end
    end)

    local function updateDetail(player)
        _selectedPlayer = player
        prioDropdown.Visible = false
        if not player then
            nameLbl.Text="Name: ???"; dispLbl.Text="DisplayName: ???"; idLbl.Text="UserId: ???"
            avatarImg.Image=""; prioBtn.Text="-"; prioBtn.TextColor3=TEXT_DIM; return
        end
        nameLbl.Text = "Name: "..player.Name
        dispLbl.Text = "DisplayName: "..player.DisplayName
        idLbl.Text   = "UserId: "..tostring(player.UserId)
        local prio = player == LocalPlayer and "LocalPlayer" or (_playerPriority[player.UserId] or "Neutral")
        prioBtn.Text = prio; prioBtn.TextColor3 = _prioColors[prio] or TEXT_DIM
        task.spawn(function()
            local ok, url = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok then avatarImg.Image = url end
        end)
    end

    local function makeRow(player)
        local isLocal = player == LocalPlayer
        local prio = isLocal and "LocalPlayer" or (_playerPriority[player.UserId] or "Neutral")

        local row = Instance.new("TextButton")
        row.Name = tostring(player.UserId)
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = BG_DARK; row.BorderSizePixel = 0
        row.Text = ""; row.AutoButtonColor = false; row.Parent = listFrame
        Instance.new("UIStroke", row).Color = OUTLINE

        local function col(text, xs, ws, align, color)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(ws,0,1,0); l.Position = UDim2.new(xs,0,0,0)
            l.BackgroundTransparency = 1; l.Text = text
            l.TextColor3 = color or TEXT_MAIN; l.TextSize = 11; l.Font = Enum.Font.Gotham
            l.TextXAlignment = align; l.Parent = row; return l
        end
        local nameCol = col(player.Name, 0, 0.40, Enum.TextXAlignment.Left)
        local ncp = Instance.new("UIPadding"); ncp.PaddingLeft = UDim.new(0,6); ncp.Parent = nameCol
        col(tostring(player.UserId), 0.40, 0.35, Enum.TextXAlignment.Center, TEXT_DIM)
        local prioCol = col(prio, 0.75, 0.25, Enum.TextXAlignment.Center, _prioColors[prio] or TEXT_DIM)
        prioCol.Name = "PrioLabel"

        row.MouseButton1Click:Connect(function()
            for _, r in pairs(_playerRows) do r.BackgroundColor3 = BG_DARK end
            row.BackgroundColor3 = BG_HOVER
            updateDetail(player)
        end)
        _playerRows[player.UserId] = row
    end

    local function filterRows(q)
        q = q:lower()
        for uid, row in pairs(_playerRows) do
            local p = Players:GetPlayerByUserId(uid)
            row.Visible = p and (q=="" or p.Name:lower():find(q,1,true) ~= nil)
        end
    end

    local function rebuildList()
        for _,r in pairs(_playerRows) do r:Destroy() end
        _playerRows = {}; updateDetail(nil)
        makeRow(LocalPlayer)
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then makeRow(p) end
        end
        filterRows(searchBox.Text)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function() filterRows(searchBox.Text) end)
    refreshBtn.MouseButton1Click:Connect(rebuildList)

    -- Auto-update on player join/leave
    Players.PlayerAdded:Connect(function(p)
        if not _playerRows[p.UserId] then makeRow(p) end
    end)
    Players.PlayerRemoving:Connect(function(p)
        local row = _playerRows[p.UserId]
        if row then row:Destroy(); _playerRows[p.UserId] = nil end
        if _selectedPlayer == p then updateDetail(nil) end
    end)

    -- Initial build (delayed so page is ready)
    task.spawn(function()
        task.wait(0.5)
        rebuildList()
    end)
end

Window:InitWindow()

-- Misc page — server position dot
do
    local sp = MiscPage:Section({Name = "server position", Side = 1})

    sp:Toggle({Name = "enabled", Flag = "sp_enabled", Default = false,
        Callback = function(v)
            SP.Enabled = v
            if not v then
                if _spDot     then _spDot:Remove();     _spDot     = nil end
                if _spOutline then _spOutline:Remove(); _spOutline = nil end
            end
        end})

    sp:Label({Name = "main color"}):Colorpicker({Flag = "sp_main",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) SP.MainColor = v end})

    sp:Label({Name = "outline color"}):Colorpicker({Flag = "sp_outline",
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(v) SP.OutlineColor = v end})

    sp:Slider({Name = "size", Flag = "sp_size",
        Min = 4, Max = 40, Default = 12, Decimals = 1,
        Callback = function(v) SP.Size = v end})
end

-- Hitbox Expander UI
do
    local hbe = MiscPage:Section({Name = "hitbox expander", Side = 1})

    hbe:Toggle({Name = "enabled", Flag = "hbe_enabled", Default = false,
        Callback = function(v)
            HBE.Enabled = v
            if not v then
                for _, box in pairs(_hbeBoxes) do
                    if box then box:Destroy() end
                end
                _hbeBoxes = {}
            end
        end})

    hbe:Label({Name = "fill color"}):Colorpicker({Flag = "hbe_fill",
        Default = Color3.fromRGB(100, 150, 255),
        Callback = function(v) HBE.FillColor = v end})

    hbe:Label({Name = "outline color"}):Colorpicker({Flag = "hbe_outline",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) HBE.OutlineColor = v end})

    hbe:Slider({Name = "fill transparency", Flag = "hbe_fill_trans",
        Min = 0, Max = 1, Default = 0.8, Decimals = 0.01,
        Callback = function(v) HBE.FillTransp = v end})

    hbe:Slider({Name = "outline transparency", Flag = "hbe_outline_trans",
        Min = 0, Max = 1, Default = 0, Decimals = 0.01,
        Callback = function(v) HBE.OutlineTransp = v end})

    hbe:Slider({Name = "size x", Flag = "hbe_x",
        Min = 1, Max = 20, Default = 2, Decimals = 0.1,
        Callback = function(v) HBE.SizeX = v end})

    hbe:Slider({Name = "size y", Flag = "hbe_y",
        Min = 1, Max = 20, Default = 2, Decimals = 0.1,
        Callback = function(v) HBE.SizeY = v end})

    hbe:Slider({Name = "size z", Flag = "hbe_z",
        Min = 1, Max = 20, Default = 2, Decimals = 0.1,
        Callback = function(v) HBE.SizeZ = v end})
end

-- Hitbox Expander logic
do
    local function resetHitboxes()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.CanCollide = false
                        local selectionBox = hrp:FindFirstChild('HitboxOutline')
                        if selectionBox then selectionBox:Destroy() end
                    end)
                end
            end
        end
        _hbeBoxes = {}
    end

    RunService.Heartbeat:Connect(function()
        if not HBE.Enabled then
            if next(_hbeBoxes) then
                resetHitboxes()
            end
            return
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.Size = Vector3.new(HBE.SizeX, HBE.SizeY, HBE.SizeZ)
                        hrp.Transparency = HBE.FillTransp
                        hrp.Color = HBE.FillColor
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false

                        -- Selection box for outline
                        local selectionBox = hrp:FindFirstChild('HitboxOutline')
                        if not selectionBox then
                            selectionBox = Instance.new('SelectionBox')
                            selectionBox.Name = 'HitboxOutline'
                            selectionBox.Adornee = hrp
                            selectionBox.LineThickness = 0.05
                            selectionBox.Parent = hrp
                            _hbeBoxes[player.UserId] = selectionBox
                        end
                        selectionBox.Color3 = HBE.OutlineColor
                        selectionBox.SurfaceTransparency = 1
                        selectionBox.SurfaceColor3 = HBE.FillColor
                        selectionBox.LineThickness = HBE.OutlineTransp == 1 and 0 or 0.05
                    end)
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if _hbeBoxes[player.UserId] then
            pcall(function()
                _hbeBoxes[player.UserId]:Destroy()
            end)
            _hbeBoxes[player.UserId] = nil
        end
    end)
end

-- Server position render loop
do
    -- Create dot drawings once
    _spOutline = Drawing.new("Circle")
    _spOutline.Visible = false; _spOutline.Filled = true; _spOutline.NumSides = 32; _spOutline.ZIndex = 3

    _spDot = Drawing.new("Circle")
    _spDot.Visible = false; _spDot.Filled = true; _spDot.NumSides = 32; _spDot.ZIndex = 4

    RunService.RenderStepped:Connect(function()
        if not SP.Enabled then
            _spDot.Visible     = false
            _spOutline.Visible = false
            return
        end

        local char = LocalPlayer.Character
        if not char then
            _spDot.Visible = false; _spOutline.Visible = false; return
        end

        -- Try UpperTorso (R15) then Torso (R6) then HRP as fallback
        local torso = char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("HumanoidRootPart")

        if not torso then
            _spDot.Visible = false; _spOutline.Visible = false; return
        end

        local sp2d, onScreen = Camera:WorldToViewportPoint(torso.Position)
        if not onScreen or sp2d.Z <= 0 then
            _spDot.Visible = false; _spOutline.Visible = false; return
        end

        local pos = Vector2.new(sp2d.X, sp2d.Y)
        local r   = SP.Size

        _spOutline.Position = pos
        _spOutline.Radius   = r + 2
        _spOutline.Color    = SP.OutlineColor
        _spOutline.Visible  = true

        _spDot.Position = pos
        _spDot.Radius   = r
        _spDot.Color    = SP.MainColor
        _spDot.Visible  = true
    end)
end

-- Misc page — connection exploit
do
    local ce = MiscPage:Section({Name = "connection exploit", Side = 1})

    ce:Toggle({Name = "enable", Flag = "ce_en", Default = false,
        Callback = function(v)
            CE.Enabled = v
            if not v then
                CE.Attached = false
                CE.Target   = nil
                if _ceBeam then _ceBeam.Enabled = false end
            end
        end})

    ce:Toggle({Name = "auto equip knife", Flag = "ce_knife", Default = false,
        Callback = function(v)
            CE.AutoKnife = v
            if v and LocalPlayer.Character then
                task.spawn(_ceEquipKnife, LocalPlayer.Character)
            end
        end})

    ce:Label({Name = "lock on"}):Keybind({
        Flag    = "ce_lockkey",
        Mode    = "Toggle",
        Default = Enum.KeyCode.Q,
        Callback = function(toggled)
            if not CE.Enabled then return end
            if toggled then
                CE.Target = _ceClosest()
            else
                CE.Target   = nil
                CE.Attached = false
            end
        end,
    })

    ce:Label({Name = "attach"}):Keybind({
        Flag    = "ce_attachkey",
        Mode    = "Toggle",
        Default = Enum.KeyCode.C,
        Callback = function(toggled)
            if not CE.Enabled then return end
            CE.Attached = toggled
        end,
    })
end

-- ══════════════════════════════════════════════════════════════
-- HIT FEEDBACK LOGIC
-- ══════════════════════════════════════════════════════════════
local _hitSoundObj = nil
local _hitOverlayFrame = nil
local _playerHealthTrack = {}

-- Initialize hit sound
if not _hitSoundObj then
    _hitSoundObj = Instance.new("Sound")
    _hitSoundObj.Parent = game:GetService("SoundService")
end

-- Helper: check if player is current target
local function isCurrentTarget(player)
    if not player then return false end
    
    -- Check ragebot target (LB.Target is a body part)
    if LB and LB.Target and LB.Target.Parent then
        local targetPlayer = Players:GetPlayerFromCharacter(LB.Target.Parent)
        if targetPlayer == player then return true end
    end
    
    -- Check aim assist target (AA.Target is a body part)
    if AA and AA.Target and AA.Target.Parent then
        local targetPlayer = Players:GetPlayerFromCharacter(AA.Target.Parent)
        if targetPlayer == player then return true end
    end
    
    -- Check silent aim target (SA.Target might be player or body part)
    if SA and SA.Target then
        if SA.Target == player then return true end
        if SA.Target.Parent then
            local targetPlayer = Players:GetPlayerFromCharacter(SA.Target.Parent)
            if targetPlayer == player then return true end
        end
    end
    
    return false
end

-- Track player health to detect hits
local function trackPlayerHealth(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    _playerHealthTrack[player.UserId] = _playerHealthTrack[player.UserId] or {}
    _playerHealthTrack[player.UserId].health = hum.Health
    _playerHealthTrack[player.UserId].player = player
    
    hum.HealthChanged:Connect(function(newHealth)
        local track = _playerHealthTrack[player.UserId]
        if not track then return end
        local oldHealth = track.health or newHealth
        
        -- Hit detected (health decreased) AND player is current target
        if newHealth < oldHealth and newHealth > 0 and isCurrentTarget(player) then
            -- Hit Sound
            if HF.SoundEnabled and _hitSoundObj then
                local soundId = _hitSounds[HF.SoundType] or _hitSounds.neverlose
                _hitSoundObj.SoundId = soundId
                _hitSoundObj.Volume = HF.SoundVolume
                _hitSoundObj:Play()
            end
            
            -- Hit Overlay
            if HF.OverlayEnabled then
                task.spawn(function()
                    if not _hitOverlayFrame then
                        local sg = Instance.new("ScreenGui")
                        sg.Name = "HitOverlay"
                        sg.ResetOnSpawn = false
                        sg.DisplayOrder = 999
                        sg.IgnoreGuiInset = true
                        local ok = pcall(function()
                            sg.Parent = game:GetService("CoreGui")
                        end)
                        if not ok then
                            sg.Parent = LocalPlayer.PlayerGui
                        end
                        
                        _hitOverlayFrame = Instance.new("Frame")
                        _hitOverlayFrame.Size = UDim2.new(1,0,1,0)
                        _hitOverlayFrame.Position = UDim2.new(0,0,0,0)
                        _hitOverlayFrame.BackgroundColor3 = HF.OverlayColor
                        _hitOverlayFrame.BackgroundTransparency = 1
                        _hitOverlayFrame.BorderSizePixel = 0
                        _hitOverlayFrame.ZIndex = 999
                        _hitOverlayFrame.Parent = sg
                    end
                    
                    _hitOverlayFrame.BackgroundColor3 = HF.OverlayColor
                    _hitOverlayFrame.BackgroundTransparency = HF.OverlayTransp
                    _hitOverlayFrame.Visible = true
                    
                    local startTime = tick()
                    while tick() - startTime < HF.OverlayLifetime do
                        local progress = (tick() - startTime) / HF.OverlayLifetime
                        _hitOverlayFrame.BackgroundTransparency = HF.OverlayTransp + (1 - HF.OverlayTransp) * progress
                        task.wait()
                    end
                    _hitOverlayFrame.BackgroundTransparency = 1
                    _hitOverlayFrame.Visible = false
                end)
            end
            
            -- 2D Hit Marker
            if HF.HM2DEnabled then
                task.spawn(function()
                    local lines = {}
                    local outlines = {}
                    
                    for i = 1, 4 do
                        lines[i] = Drawing.new("Line")
                        lines[i].Thickness = HF.HM2DThickness
                        lines[i].Color = HF.HM2DColor
                        lines[i].Transparency = 1
                        lines[i].ZIndex = 100
                        lines[i].Visible = true
                        
                        outlines[i] = Drawing.new("Line")
                        outlines[i].Thickness = HF.HM2DThickness + 2
                        outlines[i].Color = HF.HM2DOutline
                        outlines[i].Transparency = 1
                        outlines[i].ZIndex = 99
                        outlines[i].Visible = true
                    end
                    
                    local startTime = tick()
                    local conn; conn = RunService.RenderStepped:Connect(function()
                        local elapsed = tick() - startTime
                        if elapsed > HF.HM2DLifetime + 0.2 then
                            conn:Disconnect()
                            for i = 1, 4 do
                                lines[i]:Remove()
                                outlines[i]:Remove()
                            end
                            return
                        end
                        
                        local center = Camera.ViewportSize / 2
                        local transparency = elapsed > HF.HM2DLifetime and (1 - (elapsed - HF.HM2DLifetime) / 0.2) or 1
                        
                        for i = 1, 4 do
                            lines[i].Transparency = transparency
                            outlines[i].Transparency = transparency
                        end
                        
                        lines[1].From = Vector2.new(center.X - 10, center.Y - 10)
                        lines[1].To = Vector2.new(center.X - 5, center.Y - 5)
                        outlines[1].From = lines[1].From
                        outlines[1].To = lines[1].To
                        
                        lines[2].From = Vector2.new(center.X + 10, center.Y - 10)
                        lines[2].To = Vector2.new(center.X + 5, center.Y - 5)
                        outlines[2].From = lines[2].From
                        outlines[2].To = lines[2].To
                        
                        lines[3].From = Vector2.new(center.X - 10, center.Y + 10)
                        lines[3].To = Vector2.new(center.X - 5, center.Y + 5)
                        outlines[3].From = lines[3].From
                        outlines[3].To = lines[3].To
                        
                        lines[4].From = Vector2.new(center.X + 10, center.Y + 10)
                        lines[4].To = Vector2.new(center.X + 5, center.Y + 5)
                        outlines[4].From = lines[4].From
                        outlines[4].To = lines[4].To
                    end)
                end)
            end
            
            -- Hit Chams
            if HF.ChamsEnabled then
                task.spawn(function()
                    local char = player.Character
                    if not char then return end
                    
                    local clonedModel = Instance.new("Model")
                    clonedModel.Name = "HitCham"
                    
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            local clone = part:Clone()
                            clone:ClearAllChildren()
                            clone.Anchored = true
                            clone.CanCollide = false
                            clone.CastShadow = false
                            
                            if HF.ChamsType == "neon" or HF.ChamsType == "forcefield" then
                                clone.Material = HF.ChamsType == "neon" and Enum.Material.Neon or Enum.Material.ForceField
                                clone.Color = HF.ChamsColor
                                clone.Transparency = HF.ChamsTransp
                                if clone:IsA("MeshPart") then
                                    clone.TextureID = ""
                                end
                            elseif HF.ChamsType == "outline" then
                                clone.Transparency = 1
                                local selectionBox = Instance.new("SelectionBox")
                                selectionBox.LineThickness = 0.01
                                selectionBox.Color3 = HF.ChamsColor
                                selectionBox.Transparency = HF.ChamsTransp
                                selectionBox.Adornee = clone
                                selectionBox.Parent = clone
                            end
                            
                            clone.Parent = clonedModel
                        end
                    end
                    
                    clonedModel.Parent = workspace
                    
                    -- Animate based on type
                    local startTime = tick()
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        local elapsed = tick() - startTime
                        if elapsed > HF.ChamsLifetime then
                            conn:Disconnect()
                            clonedModel:Destroy()
                            return
                        end
                        
                        if HF.ChamsAnimation == "new fade" or HF.ChamsAnimation == "fade" then
                            local fadeStart = HF.ChamsAnimation == "new fade" and 0.15 or 0.25
                            if elapsed > HF.ChamsLifetime - fadeStart then
                                local fadeProgress = (elapsed - (HF.ChamsLifetime - fadeStart)) / fadeStart
                                local newTransp = HF.ChamsTransp + (1 - HF.ChamsTransp) * fadeProgress
                                
                                for _, part in ipairs(clonedModel:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.Transparency = newTransp
                                        local sb = part:FindFirstChildOfClass("SelectionBox")
                                        if sb then sb.Transparency = newTransp end
                                    end
                                end
                            end
                        end
                    end)
                end)
            end
        end
        
        track.health = newHealth
    end)
end

-- Hook into player added/character added
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        trackPlayerHealth(player)
    end)
    if player.Character then
        task.wait(0.5)
        trackPlayerHealth(player)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        trackPlayerHealth(player)
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        trackPlayerHealth(player)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- MOBILE: UI toggle button
-- ══════════════════════════════════════════════════════════════
if IsMobile then
    task.spawn(function()
        task.wait(0.3)
        local gui = Instance.new("ScreenGui")
        gui.Name = "ZHToggle"; gui.DisplayOrder = 9999
        gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
        local ok = pcall(function() gui.Parent = CoreGui end)
        if not ok then gui.Parent = LocalPlayer.PlayerGui end

        local btn = Instance.new("Frame")
        btn.Size             = UDim2.new(0, 52, 0, 52)
        btn.Position         = UDim2.new(0, 8, 0, 80)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.BackgroundTransparency = 0.35
        btn.BorderSizePixel  = 0; btn.ZIndex = 20; btn.Parent = gui
        local cor = Instance.new("UICorner")
        cor.CornerRadius = UDim.new(0, 12); cor.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size               = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = "C"
        lbl.TextColor3         = Color3.fromRGB(200, 200, 255)
        lbl.TextSize           = 28; lbl.Font = Enum.Font.GothamBold
        lbl.ZIndex             = 21; lbl.Parent = btn

        local open = true
        local drag, ref = false, nil
        local ds, fs = Vector2.zero, Vector2.new(8, 80)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.Touch or drag then return end
            drag = true; ref = i
            ds = Vector2.new(i.Position.X, i.Position.Y)
            fs = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
        end)
        UserInputService.TouchMoved:Connect(function(i)
            if i ~= ref then return end
            btn.Position = UDim2.new(0, fs.X + i.Position.X - ds.X, 0, fs.Y + i.Position.Y - ds.Y)
        end)
        UserInputService.TouchEnded:Connect(function(i)
            if i ~= ref then return end
            local dist = (Vector2.new(i.Position.X, i.Position.Y) - ds).Magnitude
            drag = false; ref = nil
            if dist < 10 then
                open = not open
                Window:SetOpen(open)
                btn.BackgroundColor3 = open and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 30)
                btn.BackgroundTransparency = 0.35
            end
        end)
    end)
end



