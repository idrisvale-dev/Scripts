-- // language: Lua, file: Centu_PvP_V1.lua, target: Roblox — Blox Fruits
-- // UI: CentuLibrary (github.com/idrisvale-dev)

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/idrisvale-dev/Scripts/refs/heads/master/Library/CentuLibrary.luau",
    true
))()

---------------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------------
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local TweenSvc    = game:GetService("TweenService")
local Lighting    = game:GetService("Lighting")
local RepStorage  = game:GetService("ReplicatedStorage")
local Camera      = workspace.CurrentCamera
local LP          = Players.LocalPlayer
local Mouse       = LP:GetMouse()

---------------------------------------------------------------------------
-- FLAGS / STATE
---------------------------------------------------------------------------
local F = {
    -- aim
    Aimbot       = false, AimbotSmooth = 10, AimbotDist = 500,
    AimbotPart   = "HumanoidRootPart", AimbotMode = "Nearest",
    CamLock      = false, CamLockSmooth = 8,
    FOVCircle    = false, FOVSize = 200,
    -- combat
    HitboxExpand = false, HitboxSize = 12, HitboxTarget = false,
    KillAura     = false, KillRange = 20, KillDelay = 3,
    -- haki
    AutoBuso     = false, BusoKey = "E",
    AutoObs      = false, ObsKey  = "Q",
    AutoV3       = false, V3Key   = "T",
    AntiStun     = false, AntiCombo = false,
    -- visuals
    ESP          = false, ESPBoxes = true, ESPNames = true,
    ESPDist      = true,  ESPHealth = true, ESPMaxDist = 1500,
    NoFog        = false, FullBright = false,
    -- movement
    SpeedHack    = false, SpeedValue = 50,
    JumpPow      = false, JumpValue  = 100,
    InfJump      = false,
    -- misc
    FPSBoost     = false, AntiBlur = false,
}

---------------------------------------------------------------------------
-- UTIL
---------------------------------------------------------------------------
local Conns = {}
local function Track(c) table.insert(Conns, c) return c end

local function GetChar()
    return LP.Character
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function W2V(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis, sp.Z
end

-- Nearest enemy (optional FOV-gated)
local function GetTarget(maxDist, fovGated)
    local best, bestDist = nil, maxDist or math.huge
    local lroot = GetRoot()
    if not lroot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - lroot.Position).Magnitude
                if dist < bestDist then
                    if fovGated and F.FOVCircle then
                        local sp, vis = W2V(root.Position)
                        local cx = Camera.ViewportSize.X * 0.5
                        local cy = Camera.ViewportSize.Y * 0.5
                        if vis and (sp - Vector2.new(cx, cy)).Magnitude <= F.FOVSize then
                            best = p; bestDist = dist
                        end
                    else
                        best = p; bestDist = dist
                    end
                end
            end
        end
    end
    return best
end

-- Haki / ability key-fire (exploit env: keypress/keyrelease if available)
local kp  = typeof(keypress)  == "function" and keypress  or nil
local kr  = typeof(keyrelease) == "function" and keyrelease or nil
local KeyMap = {
    Q=81, E=69, R=82, T=84, F=70, G=71, Z=90, X=88, C=67, V=86,
    Y=89, H=72, J=74, K=75, B=66, N=78, M=77, P=80, O=79, I=73
}

local function PressKey(keyStr)
    local code = KeyMap[string.upper(keyStr)]
    if not code then return end
    if kp and kr then
        kp(code)
        task.delay(0.05, function() kr(code) end)
    else
        -- fallback: fire via UIS simulation event if executor supports it
        pcall(function()
            local vk = Enum.KeyCode[keyStr]
            if vk then
                local ev = Instance.new("InputObject")
                ev.KeyCode = vk
                ev.UserInputType = Enum.UserInputType.Keyboard
                ev.UserInputState = Enum.UserInputState.Begin
                UIS.InputBegan:Fire(ev, false)
                task.delay(0.05, function()
                    ev.UserInputState = Enum.UserInputState.End
                    UIS.InputEnded:Fire(ev, false)
                end)
            end
        end)
    end
end

-- BF Buso/Obs remote (works most versions)
local function FireHakiRemote(hakiType, state)
    pcall(function()
        local rem = RepStorage:FindFirstChild("Remotes")
        if rem then
            local comm = rem:FindFirstChild("CommF_")
            if comm then
                comm:InvokeServer("SetHaki", hakiType, state)
            end
        end
    end)
end

---------------------------------------------------------------------------
-- UI WINDOW
---------------------------------------------------------------------------
local Window = Library:CreateWindow({ Title = "Centu PvP V1", Theme = "Dark" })

---------------------------------------------------------------------------
-- TAB: HOME — Haki & Race
---------------------------------------------------------------------------
local HomeTab = Window:CreateTab({ Name = "Home" })

-- Haki section
local HakiSec = HomeTab:CreateSection("Haki")

HakiSec:AddToggle({
    Text = "Auto Buso Haki", Default = false, Flag = "AutoBuso",
    Callback = function(v) F.AutoBuso = v end
})
HakiSec:AddDropdown({
    Text = "Buso Key", Options = {"E","R","T","F","G","Q","Z","X","C","V"},
    Default = "E", Flag = "BusoKey",
    Callback = function(v) F.BusoKey = v end
})
HakiSec:AddToggle({
    Text = "Auto Observation Haki", Default = false, Flag = "AutoObs",
    Callback = function(v) F.AutoObs = v end
})
HakiSec:AddDropdown({
    Text = "Observation Key", Options = {"Q","E","R","T","F","G","Z","X","C","V"},
    Default = "Q", Flag = "ObsKey",
    Callback = function(v) F.ObsKey = v end
})

-- Race V3 section
local RaceSec = HomeTab:CreateSection("Race V3 / V4")

RaceSec:AddToggle({
    Text = "Auto V3", Default = false, Flag = "AutoV3",
    Callback = function(v) F.AutoV3 = v end
})
RaceSec:AddDropdown({
    Text = "V3 Key", Options = {"T","F","G","R","E","Q","Z","X","C","V"},
    Default = "T", Flag = "V3Key",
    Callback = function(v) F.V3Key = v end
})

-- Defense section
local DefSec = HomeTab:CreateSection("Defense")

DefSec:AddToggle({
    Text = "Anti Stun", Default = false, Flag = "AntiStun",
    Callback = function(v)
        F.AntiStun = v
        local hum = GetHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v)
            end)
        end
    end
})
DefSec:AddToggle({
    Text = "Anti Combo", Default = false, Flag = "AntiCombo",
    Callback = function(v) F.AntiCombo = v end
})

---------------------------------------------------------------------------
-- TAB: AIM
---------------------------------------------------------------------------
local AimTab = Window:CreateTab({ Name = "Aim" })

-- Aimbot section
local AimSec = AimTab:CreateSection("Aimbot")

AimSec:AddToggle({
    Text = "Aimbot", Default = false, Flag = "Aimbot",
    Callback = function(v) F.Aimbot = v end
})
AimSec:AddSlider({
    Text = "Smoothing", Min = 1, Max = 30, Default = 10, Increment = 1,
    Flag = "AimbotSmooth",
    Callback = function(v) F.AimbotSmooth = v end
})
AimSec:AddSlider({
    Text = "Max Distance", Min = 50, Max = 2000, Default = 500, Increment = 25,
    Suffix = " st", Flag = "AimbotDist",
    Callback = function(v) F.AimbotDist = v end
})
AimSec:AddDropdown({
    Text = "Target Part",
    Options = {"HumanoidRootPart", "Head", "UpperTorso"},
    Default = "HumanoidRootPart", Flag = "AimbotPart",
    Callback = function(v) F.AimbotPart = v end
})
AimSec:AddDropdown({
    Text = "Target Mode",
    Options = {"Nearest", "Lowest HP"},
    Default = "Nearest", Flag = "AimbotMode",
    Callback = function(v) F.AimbotMode = v end
})

-- CamLock section
local CamSec = AimTab:CreateSection("CamLock")

CamSec:AddToggle({
    Text = "CamLock", Default = false, Flag = "CamLock",
    Callback = function(v) F.CamLock = v end
})
CamSec:AddSlider({
    Text = "Lock Smoothing", Min = 1, Max = 30, Default = 8, Increment = 1,
    Flag = "CamLockSmooth",
    Callback = function(v) F.CamLockSmooth = v end
})

-- FOV section
local FOVSec = AimTab:CreateSection("FOV Circle")

-- FOV circle drawing object — created here so callbacks can reference it
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness  = 1.5
FOVCircle.Color      = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled     = false
FOVCircle.Visible    = false
FOVCircle.Radius     = 200
FOVCircle.NumSides   = 64

FOVSec:AddToggle({
    Text = "Show FOV Circle", Default = false, Flag = "FOVCircle",
    Callback = function(v) F.FOVCircle = v; FOVCircle.Visible = v end
})
FOVSec:AddSlider({
    Text = "FOV Radius", Min = 50, Max = 600, Default = 200, Increment = 10,
    Suffix = "px", Flag = "FOVSize",
    Callback = function(v) F.FOVSize = v; FOVCircle.Radius = v end
})

---------------------------------------------------------------------------
-- TAB: COMBAT
---------------------------------------------------------------------------
local CombatTab = Window:CreateTab({ Name = "Combat" })

-- Hitbox section
local HitSec = CombatTab:CreateSection("Hitbox")

HitSec:AddToggle({
    Text = "Hitbox Expander", Default = false, Flag = "HitboxExpand",
    Callback = function(v)
        F.HitboxExpand = v
        if not v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then r.Size = Vector3.new(2, 2, 1) end
                end
            end
        end
    end
})
HitSec:AddSlider({
    Text = "Hitbox Size", Min = 2, Max = 80, Default = 12, Increment = 1,
    Suffix = " st", Flag = "HitboxSize",
    Callback = function(v) F.HitboxSize = v end
})
HitSec:AddToggle({
    Text = "Expand Target Only", Default = false, Flag = "HitboxTarget",
    Callback = function(v) F.HitboxTarget = v end
})

-- Kill Aura section
local KillSec = CombatTab:CreateSection("Kill Aura")

KillSec:AddToggle({
    Text = "Kill Aura", Default = false, Flag = "KillAura",
    Callback = function(v) F.KillAura = v end
})
KillSec:AddSlider({
    Text = "Aura Range", Min = 5, Max = 100, Default = 20, Increment = 1,
    Suffix = " st", Flag = "KillRange",
    Callback = function(v) F.KillRange = v end
})
KillSec:AddSlider({
    Text = "Attack Delay (frames)", Min = 1, Max = 20, Default = 3, Increment = 1,
    Flag = "KillDelay",
    Callback = function(v) F.KillDelay = v end
})

---------------------------------------------------------------------------
-- TAB: VISUALS
---------------------------------------------------------------------------
local VisualsTab = Window:CreateTab({ Name = "Visuals" })

-- ESP section
local ESPSec = VisualsTab:CreateSection("Player ESP")

ESPSec:AddToggle({
    Text = "Enable ESP", Default = false, Flag = "ESP",
    Callback = function(v) F.ESP = v end
})
ESPSec:AddToggle({
    Text = "Boxes", Default = true, Flag = "ESPBoxes",
    Callback = function(v) F.ESPBoxes = v end
})
ESPSec:AddToggle({
    Text = "Names", Default = true, Flag = "ESPNames",
    Callback = function(v) F.ESPNames = v end
})
ESPSec:AddToggle({
    Text = "Distance", Default = true, Flag = "ESPDist",
    Callback = function(v) F.ESPDist = v end
})
ESPSec:AddToggle({
    Text = "Health Bar", Default = true, Flag = "ESPHealth",
    Callback = function(v) F.ESPHealth = v end
})
ESPSec:AddSlider({
    Text = "ESP Max Distance", Min = 100, Max = 3000, Default = 1500, Increment = 50,
    Suffix = " st", Flag = "ESPMaxDist",
    Callback = function(v) F.ESPMaxDist = v end
})

-- Environment section
local EnvSec = VisualsTab:CreateSection("Environment")

EnvSec:AddToggle({
    Text = "No Fog", Default = false, Flag = "NoFog",
    Callback = function(v)
        F.NoFog = v
        Lighting.FogEnd   = v and 1e9 or 1000
        Lighting.FogStart = v and 1e9 or 0
    end
})
EnvSec:AddToggle({
    Text = "Full Bright", Default = false, Flag = "FullBright",
    Callback = function(v)
        F.FullBright = v
        if v then
            Lighting.Brightness = 10
            Lighting.ClockTime  = 12
        else
            Lighting.Brightness = 2
            Lighting.ClockTime  = 15
        end
    end
})

---------------------------------------------------------------------------
-- TAB: MOVEMENT
---------------------------------------------------------------------------
local MoveTab = Window:CreateTab({ Name = "Movement" })

local SpeedSec = MoveTab:CreateSection("Speed")

SpeedSec:AddToggle({
    Text = "Speed Hack", Default = false, Flag = "SpeedHack",
    Callback = function(v)
        F.SpeedHack = v
        local hum = GetHum()
        if hum then hum.WalkSpeed = v and F.SpeedValue or 16 end
    end
})
SpeedSec:AddSlider({
    Text = "Walk Speed", Min = 16, Max = 350, Default = 50, Increment = 1,
    Suffix = " sp", Flag = "SpeedValue",
    Callback = function(v)
        F.SpeedValue = v
        if F.SpeedHack then
            local hum = GetHum()
            if hum then hum.WalkSpeed = v end
        end
    end
})

local JumpSec = MoveTab:CreateSection("Jump")

JumpSec:AddToggle({
    Text = "Infinite Jump", Default = false, Flag = "InfJump",
    Callback = function(v) F.InfJump = v end
})
JumpSec:AddToggle({
    Text = "Custom Jump Power", Default = false, Flag = "JumpPow",
    Callback = function(v)
        F.JumpPow = v
        local hum = GetHum()
        if hum then hum.JumpPower = v and F.JumpValue or 50 end
    end
})
JumpSec:AddSlider({
    Text = "Jump Power", Min = 50, Max = 600, Default = 100, Increment = 5,
    Suffix = " jp", Flag = "JumpValue",
    Callback = function(v)
        F.JumpValue = v
        if F.JumpPow then
            local hum = GetHum()
            if hum then hum.JumpPower = v end
        end
    end
})

---------------------------------------------------------------------------
-- TAB: MISC
---------------------------------------------------------------------------
local MiscTab = Window:CreateTab({ Name = "Misc" })

local PerfSec = MiscTab:CreateSection("Performance")

PerfSec:AddToggle({
    Text = "FPS Boost", Default = false, Flag = "FPSBoost",
    Callback = function(v)
        F.FPSBoost = v
        if v then
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Fire")
                or d:IsA("Smoke") or d:IsA("Sparkles") then
                    d.Enabled = false
                end
            end
        end
    end
})
PerfSec:AddToggle({
    Text = "Anti Blur", Default = false, Flag = "AntiBlur",
    Callback = function(v)
        F.AntiBlur = v
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = not v
            end
        end
    end
})

local ConfigSec = MiscTab:CreateSection("Config")

ConfigSec:AddButton({
    Text = "Save Config", Variant = "Primary",
    Callback = function()
        Library:SaveConfig(nil, "CentuPvP_V1")
        Library:Notify({
            Title = "Centu PvP V1", Content = "Config saved.",
            Type = "Success", Duration = 3
        })
    end
})
ConfigSec:AddButton({
    Text = "Load Config",
    Callback = function()
        Library:LoadConfig(nil, "CentuPvP_V1")
        Library:Notify({
            Title = "Centu PvP V1", Content = "Config loaded.",
            Type = "Info", Duration = 3
        })
    end
})
ConfigSec:AddButton({
    Text = "Reset Config", Variant = "Danger",
    Callback = function()
        Library:DeleteConfig(nil, "CentuPvP_V1")
        Library:Notify({
            Title = "Centu PvP V1", Content = "Config reset.",
            Type = "Warning", Duration = 3
        })
    end
})

---------------------------------------------------------------------------
-- ESP DRAWING POOL
---------------------------------------------------------------------------
local ESPPool = {}

local function GetESP(player)
    if not ESPPool[player] then
        local e = {}
        e.Box   = Drawing.new("Square")
        e.Box.Thickness = 1.5
        e.Box.Filled    = false
        e.Box.Visible   = false

        e.Name  = Drawing.new("Text")
        e.Name.Size   = 14
        e.Name.Font   = 2
        e.Name.Center = true
        e.Name.Outline = true
        e.Name.OutlineColor = Color3.new(0,0,0)
        e.Name.Visible = false

        e.Dist  = Drawing.new("Text")
        e.Dist.Size   = 12
        e.Dist.Font   = 2
        e.Dist.Center = true
        e.Dist.Outline = true
        e.Dist.OutlineColor = Color3.new(0,0,0)
        e.Dist.Color  = Color3.fromRGB(200,200,200)
        e.Dist.Visible = false

        e.HpBg  = Drawing.new("Square")
        e.HpBg.Filled  = true
        e.HpBg.Color   = Color3.new(0,0,0)
        e.HpBg.Transparency = 0.5
        e.HpBg.Visible = false

        e.HpFill = Drawing.new("Square")
        e.HpFill.Filled  = true
        e.HpFill.Visible = false

        ESPPool[player] = e
    end
    return ESPPool[player]
end

local function HideESP(e)
    e.Box.Visible    = false
    e.Name.Visible   = false
    e.Dist.Visible   = false
    e.HpBg.Visible   = false
    e.HpFill.Visible = false
end

local function CleanESP(p)
    if ESPPool[p] then
        for _, d in pairs(ESPPool[p]) do pcall(function() d:Remove() end) end
        ESPPool[p] = nil
    end
end

Track(Players.PlayerRemoving:Connect(CleanESP))

-- Get screen bounding box from character
local function CharBounds(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return nil end
    local sp, vis = W2V(root.Position)
    if not vis then return nil end
    local top = W2V(root.Position + Vector3.new(0, 3.5, 0))
    local bot = W2V(root.Position + Vector3.new(0, -3.5, 0))
    local h = math.abs(top.Y - bot.Y)
    local w = h * 0.5
    return {
        X = sp.X - w * 0.5, Y = top.Y,
        W = w, H = h,
        Cx = sp.X,
        HP = hum.Health / math.max(1, hum.MaxHealth)
    }
end

---------------------------------------------------------------------------
-- RENDER LOOP
---------------------------------------------------------------------------
local hakiTimer  = 0
local v3Timer    = 0
local killFrame  = 0

Track(RunService.RenderStepped:Connect(function()
    local lroot = GetRoot()
    local lhum  = GetHum()
    local now   = tick()

    -- FOV circle
    if F.FOVCircle then
        FOVCircle.Position = Vector2.new(
            Camera.ViewportSize.X * 0.5,
            Camera.ViewportSize.Y * 0.5
        )
    end

    -- Find target (FOV-gated when circle is on)
    local target = nil
    if lroot and (F.Aimbot or F.CamLock or F.KillAura) then
        if F.AimbotMode == "Lowest HP" then
            local bestHP = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local r   = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if r and hum and hum.Health > 0 then
                        local d = (r.Position - lroot.Position).Magnitude
                        if d < F.AimbotDist and hum.Health < bestHP then
                            local sp, vis = W2V(r.Position)
                            local ok = not F.FOVCircle or (
                                vis and
                                (sp - Vector2.new(Camera.ViewportSize.X*.5, Camera.ViewportSize.Y*.5)).Magnitude <= F.FOVSize
                            )
                            if ok then target = p; bestHP = hum.Health end
                        end
                    end
                end
            end
        else
            target = GetTarget(F.AimbotDist, true)
        end
    end

    -- Aimbot
    if F.Aimbot and target and target.Character then
        local part = target.Character:FindFirstChild(F.AimbotPart) or
                     target.Character:FindFirstChild("HumanoidRootPart")
        if part then
            local s = math.max(1, F.AimbotSmooth)
            local dir = (part.Position - Camera.CFrame.Position).Unit
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir),
                1 / s
            )
        end
    end

    -- CamLock
    if F.CamLock and not F.Aimbot then
        local ct = GetTarget(F.AimbotDist, false)
        if ct and ct.Character then
            local r = ct.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local s = math.max(1, F.CamLockSmooth)
                local dir = (r.Position - Camera.CFrame.Position).Unit
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir),
                    1 / s
                )
            end
        end
    end

    -- Kill Aura
    if F.KillAura and lroot and lhum and lhum.Health > 0 then
        killFrame += 1
        if killFrame >= F.KillDelay then
            killFrame = 0
            local char = LP.Character
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local r   = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if r and hum and hum.Health > 0 then
                        if (r.Position - lroot.Position).Magnitude <= F.KillRange then
                            local tool = char and char:FindFirstChildOfClass("Tool")
                            if tool then
                                local rem = tool:FindFirstChildOfClass("RemoteEvent")
                                   or tool:FindFirstChildOfClass("RemoteFunction")
                                if rem then
                                    pcall(function() rem:FireServer(r) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Auto Buso / Obs Haki (remote first, key fallback)
    if now - hakiTimer >= 0.6 then
        if F.AutoBuso and lhum and lhum.Health > 0 then
            if not FireHakiRemote("Buso", true) then
                PressKey(F.BusoKey)
            end
            hakiTimer = now
        elseif F.AutoObs and lhum and lhum.Health > 0 then
            PressKey(F.ObsKey)
            hakiTimer = now
        end
    end

    -- Auto V3
    if F.AutoV3 and lhum and lhum.Health > 0 and now - v3Timer >= 1 then
        PressKey(F.V3Key)
        v3Timer = now
    end

    -- Anti Stun persistence (re-apply on each frame — guards against re-enable)
    if F.AntiStun and lhum then
        pcall(function()
            lhum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            lhum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end)
    end

    -- Anti Combo: cancel GettingUp state
    if F.AntiCombo and lhum then
        pcall(function()
            lhum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        end)
    end

    -- Hitbox Expander
    if F.HitboxExpand then
        local sz = F.HitboxSize
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                if not F.HitboxTarget or p == target then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then r.Size = Vector3.new(sz, sz, sz) end
                end
            end
        end
    end

    -- Infinite Jump
    if F.InfJump and lhum and UIS:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function() lhum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end

    -- Speed / Jump persistence
    if F.SpeedHack and lhum then lhum.WalkSpeed = F.SpeedValue end
    if F.JumpPow   and lhum then lhum.JumpPower  = F.JumpValue  end

    -- ESP render
    local lrootPos = lroot and lroot.Position
    for _, p in ipairs(Players:GetPlayers()) do
        local e = GetESP(p)
        if p == LP or not p.Character then HideESP(e); continue end
        local hum  = p.Character:FindFirstChildOfClass("Humanoid")
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not F.ESP or not hum or not root or hum.Health <= 0 then
            HideESP(e); continue
        end
        local dist = lrootPos and (root.Position - lrootPos).Magnitude or math.huge
        if dist > F.ESPMaxDist then HideESP(e); continue end

        local b = CharBounds(p.Character)
        if not b then HideESP(e); continue end

        local col = Color3.fromRGB(255, 100, 100)
        if p.Team and LP.Team and p.Team == LP.Team then
            col = Color3.fromRGB(100, 255, 100)
        end

        if F.ESPBoxes then
            e.Box.Visible  = true
            e.Box.Color    = col
            e.Box.Position = Vector2.new(b.X, b.Y)
            e.Box.Size     = Vector2.new(b.W, b.H)
        else
            e.Box.Visible = false
        end

        if F.ESPNames then
            e.Name.Visible   = true
            e.Name.Color     = col
            e.Name.Text      = p.Name
            e.Name.Position  = Vector2.new(b.Cx, b.Y - 16)
        else
            e.Name.Visible = false
        end

        if F.ESPDist then
            e.Dist.Visible  = true
            e.Dist.Text     = string.format("[%d]", math.floor(dist))
            e.Dist.Position = Vector2.new(b.Cx, b.Y + b.H + 3)
        else
            e.Dist.Visible = false
        end

        if F.ESPHealth then
            local bx = b.X - 6
            local hp = b.HP
            e.HpBg.Visible   = true
            e.HpBg.Position  = Vector2.new(bx, b.Y)
            e.HpBg.Size      = Vector2.new(4, b.H)
            e.HpFill.Visible = true
            e.HpFill.Color   = Color3.fromRGB(
                math.floor((1 - hp) * 255),
                math.floor(hp * 255),
                30
            )
            e.HpFill.Position = Vector2.new(bx, b.Y + b.H * (1 - hp))
            e.HpFill.Size     = Vector2.new(4, b.H * hp)
        else
            e.HpBg.Visible   = false
            e.HpFill.Visible = false
        end
    end
end))

---------------------------------------------------------------------------
-- CHARACTER RESPAWN — restore stats
---------------------------------------------------------------------------
local function OnCharAdded(c)
    task.wait(1)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        if F.SpeedHack then hum.WalkSpeed = F.SpeedValue end
        if F.JumpPow   then hum.JumpPower  = F.JumpValue  end
        if F.AntiStun  then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
        end
    end
end
Track(LP.CharacterAdded:Connect(OnCharAdded))
if LP.Character then OnCharAdded(LP.Character) end

---------------------------------------------------------------------------
-- LOAD NOTIFICATION
---------------------------------------------------------------------------
Library:Notify({
    Title   = "Centu PvP V1",
    Content = "Loaded. Configure via the menu.",
    Type    = "Success",
    Duration = 4
})
