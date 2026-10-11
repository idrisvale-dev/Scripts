local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local StarterGui        = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local GuiService        = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local CommF   = Remotes and Remotes:WaitForChild("CommF_", 15)
local CommE   = Remotes and Remotes:WaitForChild("CommE", 15)

local function getSafeParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, PlayerGui)
        return PlayerGui
    end
    return PlayerGui
end
local TargetParent = getSafeParent()

local SESSION = tick()
local function isCurrentSession() return getgenv().CentuAB_Session == SESSION end
getgenv().CentuAB_Session = SESSION

local function Notify(text, isGood)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Centu Auto Bounty",
            Text = tostring(text or ""),
            Duration = 4,
        })
    end)
    print(string.format("[Centu AB] %s: %s", isGood and "+" or "-", tostring(text)))
end

getgenv().CentuAB_Blacklist = getgenv().CentuAB_Blacklist or {}
local Blacklist = getgenv().CentuAB_Blacklist
local function isPlayerBlacklisted(p)
    if not p then return false end
    if Blacklist[p] == true then return true end
    if p.UserId and (Blacklist[p.UserId] or Blacklist[tostring(p.UserId)]) then return true end
    if p.Name and (Blacklist[p.Name] or Blacklist[p.Name:lower()]) then return true end
    return false
end

local Settings = {
    MinLevel        = 2400,
    MinBounty       = 2400000,
    MaxDist         = 3000,
    FarSpeed        = 160,
    NearSpeed       = 350,
    HealThreshold   = 6000,
    HealReturnHP    = 7000,
    HealHeight      = 1500,
    AutoBuso        = true,
    AutoHop         = true,
    HopAfter        = 20,
    TeamCheck       = true,
    SafeZoneCheck   = true,
    MeleeLock       = true,
    AutoV4          = true,
    AutoInstinct    = true,
    AutoPvPOnDeath  = true,

    KillMethod      = "Fast Attack",
    FAWeapon        = "Melee",
    SS_Melee        = true,
    SS_Fruit        = true,
    SS_Sword        = true,
    SS_Gun          = false,
    SS_Z            = true,
    SS_X            = true,
    SS_C            = true,
    SS_V            = true,
    SS_F            = false,

    SpeedPreset     = "Normal",
    HitsPreset      = "Medium",
    FastAttackDelayMin = 0.15,
    FastAttackDelayMax = 0.28,
    HitCountMin        = 2,
    HitCountMax        = 4,
    BurstPauseEvery    = 6,
    BurstPauseMin      = 0.4,
    BurstPauseMax      = 0.9,
}
getgenv().CentuAB_Settings = Settings

local STATE = {
    Running       = false,
    Target        = nil,
    TweenObj      = nil,
    PartTele      = nil,
    PartTeleConn  = nil,
    NoclipConn    = nil,
    LastTargetAt  = 0,
    ReachedTarget = false,
    Healing       = false,
    Killed        = {},
    Earned        = 0,
    StartBounty   = 0,
    StartTime     = 0,
    MeleeLockConn = nil,
    LastMeleeSwap = 0,
    AttackCounter = 0,
    NextPauseAt   = 0,
    LastFastAttack = 0,
    LastSkillPress = 0,
    SSIndex       = 0,
    NoTargetSince = nil,
}
getgenv().CentuAB_State = STATE

local function randRange(a, b)
    if b < a then a, b = b, a end
    return a + math.random() * (b - a)
end

local function randInt(a, b)
    if b < a then a, b = b, a end
    return math.random(a, b)
end

local function isBloxFruitsAlly(player)
    if not player or player == LocalPlayer then return false end
    local ok, isAlly = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local allies = main and main:FindFirstChild("Allies")
        local container = allies and allies:FindFirstChild("Container")
        local list = container and container:FindFirstChild("Allies")
        local scroll = list and list:FindFirstChild("ScrollingFrame")
        if scroll and scroll:FindFirstChild(player.Name, true) then return true end
        local myCrew = LocalPlayer:GetAttribute("Crew")
        local targetCrew = player:GetAttribute("Crew")
        if myCrew and targetCrew and tostring(myCrew):lower() == tostring(targetCrew):lower() and #tostring(myCrew) > 0 then
            return true
        end
        return false
    end)
    return ok and isAlly == true
end

local function isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if isBloxFruitsAlly(player) then return false end
    local myTeam, tTeam = LocalPlayer.Team, player.Team
    if myTeam and tTeam and myTeam.Name == "Marines" and tTeam.Name == "Marines" then
        return false
    end
    return true
end

local function getPlayerLevel(p)
    if not p then return 0 end
    local lvl = 0
    local d = p:FindFirstChild("Data")
    if d and d:FindFirstChild("Level") then lvl = tonumber(d.Level.Value) or 0 end
    if lvl <= 0 then
        local ls = p:FindFirstChild("leaderstats")
        if ls then
            local l = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl")
            if l then lvl = tonumber(l.Value) or 0 end
        end
    end
    return lvl
end

local function getPlayerBounty(p)
    if not p then return 0 end
    local ls = p:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
    return b and tonumber(b.Value) or 0
end

local function inSafeZone(p)
    if not p then return false end
    local ok, inZone = pcall(function()
        local char = p.Character
        if not char then return false end

        if char:FindFirstChildOfClass("ForceField") then return true end

        for _, attr in ipairs({"SafeZone", "InSafeZone", "SafeZoneShield", "Protected", "Invulnerable"}) do
            if char:GetAttribute(attr) == true then return true end
            if p:GetAttribute(attr) == true then return true end
        end

        for _, nm in ipairs({"SafeZoneShield", "SafeZone", "Protected", "Invulnerable", "PvpDisabled"}) do
            local child = char:FindFirstChild(nm) or p:FindFirstChild(nm)
            if child then
                if child:IsA("BoolValue") and child.Value == true then return true end
                if child:IsA("NumberValue") and (tonumber(child.Value) or 0) > 0 then return true end
                if not child:IsA("ValueBase") then return true end
            end
        end

        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not hrp then return false end

        local folders = {}
        local wo = workspace:FindFirstChild("_WorldOrigin")
        if wo then
            local sz = wo:FindFirstChild("SafeZones")
            if sz then table.insert(folders, sz) end
        end
        local wsSz = workspace:FindFirstChild("SafeZones")
        if wsSz then table.insert(folders, wsSz) end
        local map = workspace:FindFirstChild("Map")
        if map then
            local msz = map:FindFirstChild("SafeZones")
            if msz then table.insert(folders, msz) end
        end

        local BUFFER = 30

        for _, folder in ipairs(folders) do
            for _, zone in ipairs(folder:GetDescendants()) do
                if zone:IsA("BasePart") then
                    local size = zone.Size
                    local localPos = zone.CFrame:PointToObjectSpace(hrp.Position)
                    local hx = size.X / 2 + BUFFER
                    local hy = size.Y / 2 + BUFFER
                    local hz = size.Z / 2 + BUFFER
                    if math.abs(localPos.X) <= hx and math.abs(localPos.Y) <= hy and math.abs(localPos.Z) <= hz then
                        return true
                    end

                    local mesh = zone:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.MeshType == Enum.MeshType.Sphere then
                        local radius = math.max(size.X, size.Y, size.Z) / 2 * (mesh.Scale.X or 1) + BUFFER
                        if (zone.Position - hrp.Position).Magnitude <= radius then
                            return true
                        end
                    end
                end
            end
        end

        return false
    end)
    return ok and inZone == true
end

local function hasPvPEnabled(p)
    if not p then return false end
    local ok, on = pcall(function()
        if p:GetAttribute("PvpDisabled") == true then return false end
        if p:GetAttribute("PvpDisabledTime") and tonumber(p:GetAttribute("PvpDisabledTime")) > 0 then return false end

        local char = p.Character
        if not char then return true end

        if char:GetAttribute("PvpDisabled") == true then return false end
        if char:GetAttribute("PvpDisabledTime") and tonumber(char:GetAttribute("PvpDisabledTime")) > 0 then return false end

        for _, nm in ipairs({"PvpDisabled", "PvpCooldown", "ProtectionTimer"}) do
            local child = char:FindFirstChild(nm) or p:FindFirstChild(nm)
            if child then
                if child:IsA("BoolValue") and child.Value == true then return false end
                if child:IsA("NumberValue") and (tonumber(child.Value) or 0) > 0 then return false end
            end
        end

        return true
    end)
    return ok and on == true
end

local function isTargetValid(p, maxDist)
    if not p or p == LocalPlayer or not p.Character then return false, "no char" end
    if isPlayerBlacklisted(p) then return false, "blacklisted" end

    local lvl = getPlayerLevel(p)
    local bounty = getPlayerBounty(p)
    if not (lvl >= Settings.MinLevel or (lvl == 0 and bounty >= Settings.MinBounty)) then
        return false, "low level/bounty"
    end

    local char = p.Character
    if not char:IsDescendantOf(workspace) then return false, "char gone" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp or hrp.Position.Y < -500 then return false, "dead" end

    if Settings.SafeZoneCheck then
        if inSafeZone(p) then return false, "in safezone" end
        if not hasPvPEnabled(p) then return false, "pvp off" end
    end

    if Settings.TeamCheck and not isEnemy(p) then return false, "team/ally" end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false, "no local char" end

    local dist = (hrp.Position - myHrp.Position).Magnitude
    if dist > (maxDist or Settings.MaxDist) then return false, "out of range" end
    return true, dist, char, hrp
end

local function cleanupMovement()
    if STATE.PartTeleConn then
        pcall(function() STATE.PartTeleConn:Disconnect() end)
        STATE.PartTeleConn = nil
    end
    if STATE.TweenObj then
        pcall(function() STATE.TweenObj:Cancel() end)
        STATE.TweenObj = nil
    end
    if STATE.PartTele then
        pcall(function() STATE.PartTele:Destroy() end)
        STATE.PartTele = nil
    end
    if STATE.NoclipConn then
        pcall(function() STATE.NoclipConn:Disconnect() end)
        STATE.NoclipConn = nil
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

local function startNoclip()
    if STATE.NoclipConn then return end
    STATE.NoclipConn = RunService.Stepped:Connect(function()
        if not STATE.Running then return end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)
end

local function TweenTo(targetCF)
    if not STATE.Running then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if typeof(targetCF) ~= "CFrame" then return end

    if targetCF.Position.Y < 18 then
        targetCF = CFrame.new(targetCF.Position.X, 18, targetCF.Position.Z) * targetCF.Rotation
    end

    local distance = (targetCF.Position - hrp.Position).Magnitude
    startNoclip()

    if distance <= 25 then
        if STATE.TweenObj then
            pcall(function() STATE.TweenObj:Cancel() end)
            STATE.TweenObj = nil
        end
        local speed = STATE.ReachedTarget and Settings.NearSpeed or Settings.FarSpeed
        local newCF = hrp.CFrame:Lerp(targetCF, math.min(1, speed * 0.016 / math.max(distance, 0.001)))
        hrp.CFrame = newCF
        if STATE.PartTele and STATE.PartTele.Parent then
            STATE.PartTele.CFrame = newCF
        end
        return
    end

    if not (STATE.PartTele and STATE.PartTele.Parent == char) then
        local stale = char:FindFirstChild("PartTele")
        if stale then stale:Destroy() end
        if STATE.PartTeleConn then STATE.PartTeleConn:Disconnect(); STATE.PartTeleConn = nil end
        local pt = Instance.new("Part")
        pt.Size = Vector3.new(10, 1, 10)
        pt.Name = "PartTele"
        pt.Anchored = true
        pt.Transparency = 1
        pt.CanCollide = false
        pt.CFrame = hrp.CFrame
        pt.Parent = char
        STATE.PartTele = pt
        STATE.PartTeleConn = pt:GetPropertyChangedSignal("CFrame"):Connect(function()
            if STATE.Running and LocalPlayer.Character == char then
                local h = char:FindFirstChild("HumanoidRootPart")
                if h then
                    h.CFrame = pt.CFrame
                    h.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    end

    local pt = STATE.PartTele
    pt.Anchored = true
    pt.CanCollide = false
    if (pt.Position - hrp.Position).Magnitude > 40 then
        pt.CFrame = hrp.CFrame
    end

    if STATE.TweenObj then pcall(function() STATE.TweenObj:Cancel() end) end

    local speed = STATE.ReachedTarget and Settings.NearSpeed or Settings.FarSpeed
    local duration = math.max(distance / speed, 0.05)

    STATE.TweenObj = TweenService:Create(pt, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
    STATE.TweenObj:Play()
end

local WEAPON_TIP = {
    ["Melee"] = "Melee",
    ["Fruit"] = "Blox Fruit",
    ["Sword"] = "Sword",
    ["Gun"]   = "Gun",
}

local function isMeleeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.ToolTip == "Melee" then return true end
    local name = string.lower(tool.Name)
    local kws = {
        "godhuman", "electric claw", "superhuman", "dragon talon", "death step",
        "sharkman karate", "combat", "black leg", "electro", "fishman karate",
        "dragon breath", "sanguine art", "sanguine", "claw"
    }
    for _, kw in ipairs(kws) do
        if string.find(name, kw) then return true end
    end
    return false
end

local function findToolByCategory(cat)
    if not cat then return nil end
    local tip = WEAPON_TIP[cat] or cat
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == tip then return t end
        end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == tip then return t end
        end
    end
    if cat == "Melee" then
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and isMeleeTool(t) then return t end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and isMeleeTool(t) then return t end
            end
        end
    end
    return nil
end

local function equipWeaponCategory(cat)
    if not cat then return false end
    local tip = WEAPON_TIP[cat] or cat
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local cur = char:FindFirstChildOfClass("Tool")
    if cur and cur.ToolTip == tip then return true end

    local tool = findToolByCategory(cat)
    if not tool then return false end
    pcall(function() hum:EquipTool(tool) end)
    return true
end

local function shouldEnforceMelee()
    if not Settings.MeleeLock then return false end
    if Settings.KillMethod == "Fast Attack" then
        return Settings.FAWeapon == "Melee"
    elseif Settings.KillMethod == "Spam Skills" then
        return Settings.SS_Melee == true
    end
    return false
end

local function enforceMeleeLock()
    if not shouldEnforceMelee() or not STATE.Running then return end
    local now = tick()
    if now - STATE.LastMeleeSwap < 0.15 then return end

    local char = LocalPlayer.Character
    if not char then return end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and isMeleeTool(equipped) then return end

    STATE.LastMeleeSwap = now
    local melee = findToolByCategory("Melee")
    if not melee then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:EquipTool(melee) end)
    end
end

local function startMeleeLockWatcher()
    if STATE.MeleeLockConn then return end

    local char = LocalPlayer.Character
    if char then
        local function watchChild(child)
            if child:IsA("Tool") and STATE.Running and shouldEnforceMelee() then
                if not isMeleeTool(child) then
                    task.delay(0.05, enforceMeleeLock)
                end
            end
        end
        for _, c in ipairs(char:GetChildren()) do watchChild(c) end
        char.ChildAdded:Connect(watchChild)
    end

    STATE.MeleeLockConn = RunService.Heartbeat:Connect(function()
        if not STATE.Running then return end
        enforceMeleeLock()
    end)
end

local function stopMeleeLockWatcher()
    if STATE.MeleeLockConn then
        pcall(function() STATE.MeleeLockConn:Disconnect() end)
        STATE.MeleeLockConn = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if STATE.Running then
        stopMeleeLockWatcher()
        startMeleeLockWatcher()
    end
end)

local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RegisterAttack = Net and (Net:FindFirstChild("RE/RegisterAttack") or Net["RE/RegisterAttack"])
local RegisterHit    = Net and (Net:FindFirstChild("RE/RegisterHit") or Net["RE/RegisterHit"])

if not RegisterAttack then
    RegisterAttack = ReplicatedStorage:FindFirstChild("RE/RegisterAttack", true)
end
if not RegisterHit then
    RegisterHit = ReplicatedStorage:FindFirstChild("RE/RegisterHit", true)
end

local function resolveAttackRemotes()
    if RegisterAttack and RegisterHit then return true end
    local ok = pcall(function()
        local net = ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("Net", 2)
        RegisterAttack = net:FindFirstChild("RE/RegisterAttack") or net["RE/RegisterAttack"]
        RegisterHit    = net:FindFirstChild("RE/RegisterHit") or net["RE/RegisterHit"]
    end)
    return ok and RegisterAttack ~= nil and RegisterHit ~= nil
end

local function generateSessionId()
    local a = tostring(LocalPlayer.UserId):sub(2, 4)
    local b = tostring(math.random(100000, 999999))
    local c = string.format("%x", math.random(0, 0xFFFFFF))
    return a .. b .. c
end

local SESSION_ID = generateSessionId()

local function aimAtTarget()
    local t = STATE.Target
    if not t or not t.Character then return end
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
        or t.Character:FindFirstChild("Head")
        or t.Character.PrimaryPart
    if not myHrp or not tHrp then return end

    pcall(function()
        local lookTarget = Vector3.new(tHrp.Position.X, myHrp.Position.Y, tHrp.Position.Z)
        myHrp.CFrame = CFrame.lookAt(myHrp.Position, lookTarget)
    end)

    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position, tHrp.Position)
        end
    end)
end

local function buildHitList(targetPlayer, myHrp, count)
    local list = {}
    if not myHrp then return list end
    local myPos = myHrp.Position

    local function addModel(model)
        if not model or model == LocalPlayer.Character then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and part then
            if (part.Position - myPos).Magnitude <= 150 then
                table.insert(list, { model, part })
            end
        end
    end

    if targetPlayer and targetPlayer.Character then
        local tChar = targetPlayer.Character
        local tHum = tChar:FindFirstChildOfClass("Humanoid")
        local tPart = tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart")
        if tHum and tHum.Health > 0 and tPart then
            table.insert(list, { tChar, tPart })
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p ~= targetPlayer and p.Character then
            if isEnemy(p) and not inSafeZone(p) then
                addModel(p.Character)
            end
            if #list >= count then break end
        end
    end

    if #list < count then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, m in ipairs(enemies:GetChildren()) do
                addModel(m)
                if #list >= count then break end
            end
        end
    end

    return list
end

local function fireFastAttack(targetPlayer)
    if not resolveAttackRemotes() then return end
    if not RegisterAttack or not RegisterHit then return end

    local char = LocalPlayer.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    if char:GetAttribute("UsingSkill") or char:GetAttribute("isUsingSkill") or char:GetAttribute("Busy") then
        return
    end

    aimAtTarget()

    local desiredCount = randInt(Settings.HitCountMin, Settings.HitCountMax)
    local hitList = buildHitList(targetPlayer, myHrp, desiredCount)
    if #hitList == 0 then return end

    local primaryPart = hitList[1][2]
    if not primaryPart or not primaryPart.Parent then return end

    SESSION_ID = generateSessionId()

    local attackDelay = randRange(0.30, 0.60)
    local attackArgs = { attackDelay, #hitList }

    pcall(function()
        RegisterAttack:FireServer(unpack(attackArgs))
    end)

    pcall(function()
        RegisterHit:FireServer(primaryPart, hitList, nil, SESSION_ID)
    end)
end

local function fastAttackTick(targetPlayer)
    local now = tick()

    if now < STATE.NextPauseAt then return end

    local minDelay = math.max(Settings.FastAttackDelayMin, 0.12)
    local maxDelay = math.max(Settings.FastAttackDelayMax, minDelay + 0.05)
    local chosenDelay = randRange(minDelay, maxDelay)

    if now - STATE.LastFastAttack < chosenDelay then return end
    STATE.LastFastAttack = now

    STATE.AttackCounter = STATE.AttackCounter + 1
    if STATE.AttackCounter >= Settings.BurstPauseEvery then
        STATE.AttackCounter = 0
        STATE.NextPauseAt = now + randRange(Settings.BurstPauseMin, Settings.BurstPauseMax)
    end

    fireFastAttack(targetPlayer)
end

local SKILL_KEYCODE = {
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
    F = Enum.KeyCode.F,
}

local function pressSkillKey(k, hold)
    local kc = SKILL_KEYCODE[k]
    if not kc then return end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        task.wait(hold or 0.08)
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
    end)
end

local function clickM1()
    pcall(function()
        if mouse1click then
            mouse1click()
        elseif VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
            task.wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
        end
    end)
end

local SS_WEAPON_ORDER = { "Melee", "Fruit", "Sword", "Gun" }
local SS_SKILL_ORDER  = { "Z", "X", "C", "V", "F" }

local function getEnabledSSWeapons()
    local list = {}
    for _, w in ipairs(SS_WEAPON_ORDER) do
        local key = "SS_" .. w
        if Settings[key] == true then table.insert(list, w) end
    end
    return list
end

local function getEnabledSSSkills()
    local list = {}
    for _, s in ipairs(SS_SKILL_ORDER) do
        local key = "SS_" .. s
        if Settings[key] == true then table.insert(list, s) end
    end
    return list
end

local function skillOnCooldown(toolName, skillKey)
    local ok, onCd = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local sk = main and main:FindFirstChild("Skills")
        local tf = sk and sk:FindFirstChild(toolName)
        if not tf then return false end
        local kf = tf:FindFirstChild(skillKey)
        if not kf then return false end
        local cd = kf:FindFirstChild("Cooldown")
        if not cd then return false end
        return cd.AbsoluteSize.X > 0
    end)
    return ok and onCd == true
end

local function spamSkillsTick(targetPlayer)
    local now = tick()
    local minDelay = math.max(Settings.FastAttackDelayMin, 0.12)
    if now - STATE.LastSkillPress < minDelay then return end
    STATE.LastSkillPress = now

    local weapons = getEnabledSSWeapons()
    if #weapons == 0 then return end

    aimAtTarget()

    STATE.SSIndex = (STATE.SSIndex % #weapons) + 1
    local cat = weapons[STATE.SSIndex]

    if not equipWeaponCategory(cat) then return end

    aimAtTarget()

    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local skills = getEnabledSSSkills()
    if #skills == 0 then
        aimAtTarget()
        clickM1()
        return
    end

    local fired = false
    for _, s in ipairs(skills) do
        if not skillOnCooldown(tool.Name, s) then
            aimAtTarget()
            pressSkillKey(s, 0.08)
            fired = true
            break
        end
    end

    if not fired then
        aimAtTarget()
        clickM1()
    end
end

local function fireBuso()
    if not Settings.AutoBuso then return end
    local char = LocalPlayer.Character
    if not char then return end
    if char:FindFirstChild("HasBuso") or char:GetAttribute("HasBuso") == true then return end
    if CommF then pcall(function() CommF:InvokeServer("Buso") end) end
end

local v4LastAttempt = 0
local v4Running = false

local function isEnergyFull()
    local char = LocalPlayer.Character
    if not char then return false end
    local energy = char:FindFirstChild("RaceEnergy")
    if not energy then return false end
    return tonumber(energy.Value) and tonumber(energy.Value) >= 1
end

local function canActivateV4()
    local char = LocalPlayer.Character
    if not char then return false end
    local transformed = char:FindFirstChild("RaceTransformed")
    local stun = char:FindFirstChild("Stun")
    local busy = char:FindFirstChild("Busy")
    local notTransformed = not transformed or (transformed.Value ~= true)
    local notStunned = not stun or (tonumber(stun.Value) or 0) <= 0
    local notBusy = not busy or (busy.Value ~= true)
    return notTransformed and notStunned and notBusy
end

local function tryActivateV4()
    if not Settings.AutoV4 then return false end
    local now = tick()
    if now - v4LastAttempt < 2.0 then return false end
    if not isEnergyFull() then return false end
    if not canActivateV4() then return false end

    v4LastAttempt = now

    pcall(function()
        if CommE then CommE:FireServer("ActivateAwakening", true) end
    end)

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
    end)

    pcall(function()
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:FindFirstChild("Backpack")
        local awk = (bp and bp:FindFirstChild("Awakening")) or (char and char:FindFirstChild("Awakening"))
        if awk then
            if awk.Parent == bp and char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(awk) end
            end
            pcall(function() awk:Activate() end)
            local rf = awk:FindFirstChild("RemoteFunction")
            if rf and rf:IsA("RemoteFunction") then pcall(function() rf:InvokeServer(true) end) end
            local re = awk:FindFirstChild("RemoteEvent")
            if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(true) end) end
        end
    end)

    Notify("V4 ACTIVATED!", true)
    return true
end

local function startV4Watcher()
    if v4Running then return end
    v4Running = true
    task.spawn(function()
        while v4Running and isCurrentSession() do
            task.wait(0.5)
            if STATE.Running and Settings.AutoV4 then
                pcall(tryActivateV4)
            end
        end
    end)
end

local function stopV4Watcher()
    v4Running = false
end

local instinctRunning = false
local instinctLastAttempt = 0

local function isKenActive()
    local char = LocalPlayer.Character
    if not char then return false end
    local ok, has = pcall(function()
        return CollectionService:HasTag(char, "Ken")
    end)
    if ok and has == true then return true end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mcb = pg and pg:FindFirstChild("MobileContextButtons")
    local cbf = mcb and mcb:FindFirstChild("ContextButtonFrame")
    local kBtn = cbf and cbf:FindFirstChild("BoundActionKen")
    if kBtn and kBtn:GetAttribute("Selected") == true then return true end

    local renvG = getrenv and getrenv()._G
    local om = renvG and renvG.OM
    if om and om.active then return true end

    return false
end

local function fireKen()
    if not CommE then return end
    pcall(function() CommE:FireServer("Ken", true) end)

    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mcb = pg and pg:FindFirstChild("MobileContextButtons")
        local cbf = mcb and mcb:FindFirstChild("ContextButtonFrame")
        local kBtn = cbf and cbf:FindFirstChild("BoundActionKen")
        if kBtn and kBtn:GetAttribute("Selected") ~= true then
            kBtn:SetAttribute("Selected", true)
        end
    end)

    pcall(function()
        local renvG = getrenv and getrenv()._G
        local om = renvG and renvG.OM
        if om and not om.active then
            om.radius = 0
            pcall(function() om:setActive(true) end)
        end
    end)
end

local function tryAutoInstinct()
    if not Settings.AutoInstinct then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if char:GetAttribute("Busy") == true then return false end

    local stun = char:FindFirstChild("Stun")
    if stun and (tonumber(stun.Value) or 0) > 0 then return false end

    local now = tick()
    if now - instinctLastAttempt < 1.5 then return false end

    if isKenActive() then return false end

    instinctLastAttempt = now
    fireKen()
    return true
end

local function startInstinctWatcher()
    if instinctRunning then return end
    instinctRunning = true
    task.spawn(function()
        while instinctRunning and isCurrentSession() do
            task.wait(0.5)
            if STATE.Running and Settings.AutoInstinct then
                pcall(tryAutoInstinct)
            end
        end
    end)
end

local function stopInstinctWatcher()
    instinctRunning = false
end

local function enablePvP()
    if not CommF then return false end
    local ok = pcall(function()
        CommF:InvokeServer("EnablePvp")
    end)
    return ok
end

local function isLocalPvPDisabled()
    local ok, dis = pcall(function()
        if LocalPlayer:GetAttribute("PvpDisabled") == true then return true end
        local char = LocalPlayer.Character
        if char and char:GetAttribute("PvpDisabled") == true then return true end
        local main = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not main then return false end
        local bList = main:FindFirstChild("BottomHUDList")
        if bList then
            local flag = bList:FindFirstChild("PvpDisabled") or bList:FindFirstChild("PvPDisabled")
            if flag and flag.Visible == true then return true end
        end
        return false
    end)
    return ok and dis == true
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not STATE.Running then return end
    if not Settings.AutoPvPOnDeath then return end

    task.spawn(function()
        for i = 1, 8 do
            task.wait(0.5)
            if not STATE.Running then return end
            if not isCurrentSession() then return end

            local char = LocalPlayer.Character
            if char and char == newChar then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if enablePvP() then
                        Notify("Auto PvP: Enabled after respawn", true)
                        break
                    end
                end
            end
        end
    end)
end)

local pvpWatchRunning = false
local lastPvPCheck = 0

local function startPvPWatcher()
    if pvpWatchRunning then return end
    pvpWatchRunning = true
    task.spawn(function()
        while pvpWatchRunning and isCurrentSession() do
            task.wait(3)
            if STATE.Running and Settings.AutoPvPOnDeath then
                local now = tick()
                if now - lastPvPCheck > 3 then
                    lastPvPCheck = now
                    if isLocalPvPDisabled() then
                        pcall(enablePvP)
                    end
                end
            end
        end
    end)
end

local function stopPvPWatcher()
    pvpWatchRunning = false
end

local function findBestTarget()
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not STATE.Killed[p] then
            local ok, valid, dist = pcall(isTargetValid, p, Settings.MaxDist)
            if ok and valid and dist < bestDist then
                best, bestDist = p, dist
            end
        end
    end
    return best, bestDist
end

local function setTarget(p)
    if STATE.Target == p then return end
    STATE.Target = p
    STATE.ReachedTarget = false
    if p then
        Notify("Target: " .. p.DisplayName .. " (" .. math.floor(getPlayerBounty(p)/1e6) .. "M)", true)
    end
    if _G.CentuAB_UpdateUI then _G.CentuAB_UpdateUI() end
end

local function skipTarget(killed)
    local old = STATE.Target
    STATE.Target = nil
    STATE.ReachedTarget = false
    if old and killed then
        STATE.Killed[old] = true
        Notify("Killed: " .. old.DisplayName, true)
    end
    if _G.CentuAB_UpdateUI then _G.CentuAB_UpdateUI() end
end
getgenv().CentuAB_SkipTarget = skipTarget

local function handleHealing()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local t = STATE.Target
    if STATE.Healing then
        if hum.Health >= Settings.HealReturnHP or not STATE.Running then
            STATE.Healing = false
            if STATE.TweenObj then pcall(function() STATE.TweenObj:Cancel() end) end
            return
        end
        if t and t.Character then
            local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                TweenTo(tHrp.CFrame * CFrame.new(0, Settings.HealHeight, 0))
            end
        end
    else
        if hum.Health < Settings.HealThreshold then
            STATE.Healing = true
            Notify("Healing in sky...", true)
        end
    end
end

local function checkInCombat()
    local ok, inCombat = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local bList = main and main:FindFirstChild("BottomHUDList")
        local ic = bList and bList:FindFirstChild("InCombat")
        if ic and ic.Visible and ic.Text and string.find(string.lower(ic.Text), "risk") then
            return true
        end
        return false
    end)
    return ok and inCombat
end

local isHopping = false

local function clearTeleportError()
    pcall(function() GuiService:ClearError() end)
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local promptOverlay = coreGui:FindFirstChild("RobloxPromptGui")
            and coreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
        if not promptOverlay then return end
        for _, v in ipairs(promptOverlay:GetChildren()) do
            if v and v.Name == "ErrorPrompt" then
                pcall(function() v:Destroy() end)
            end
        end
    end)
end

local function waitForTeleport(jobId, timeout)
    timeout = timeout or 8
    local done, success = false, false
    local originalJobId = game.JobId

    local conn
    conn = TeleportService.TeleportInitFailed:Connect(function(plr)
        if plr ~= LocalPlayer then return end
        clearTeleportError()
        done = true
    end)

    task.spawn(function()
        pcall(function()
            local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
            if sb then
                sb:InvokeServer("teleport", jobId)
            end
        end)
    end)

    local t0 = tick()
    while not done and (tick() - t0) < timeout do
        task.wait(0.1)
        if game.JobId ~= originalJobId then
            success = true
            done = true
        end
    end

    pcall(function() conn:Disconnect() end)
    clearTeleportError()
    return success
end

local function collectCandidates()
    local candidates = {}
    local seen = {}
    local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not sb then return candidates end

    for page = 1, 100 do
        if not isCurrentSession() then break end
        local ok, data = pcall(function() return sb:InvokeServer(page) end)
        if ok and type(data) == "table" then
            for jobId, info in pairs(data) do
                if jobId ~= game.JobId and type(info) == "table" and not seen[jobId] then
                    local cnt = tonumber(info.Count) or 0
                    if cnt > 0 and cnt < 12 then
                        seen[jobId] = true
                        table.insert(candidates, jobId)
                    end
                end
            end
        else
            break
        end
    end

    for i = #candidates, 2, -1 do
        local j = math.random(i)
        candidates[i], candidates[j] = candidates[j], candidates[i]
    end

    return candidates
end

local function serverHop()
    if isHopping then
        Notify("Hop already in progress", false)
        return
    end
    if checkInCombat() then
        Notify("Cannot hop: In Combat", false)
        return
    end

    isHopping = true
    Notify("Hopping server...", true)
    clearTeleportError()

    task.spawn(function()
        pcall(function()
            if LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 50000, 0) end
            end
        end)
        task.wait(1.2)

        local candidates = collectCandidates()
        if #candidates == 0 then
            Notify("No candidates, random teleport", false)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            task.wait(3)
            isHopping = false
            return
        end

        Notify(string.format("Trying %d candidates...", #candidates), true)

        for i, jobId in ipairs(candidates) do
            if not isCurrentSession() then break end
            clearTeleportError()
            Notify(string.format("Try %d/%d [%s]", i, #candidates, tostring(jobId):sub(1, 8)), true)

            if waitForTeleport(jobId, 8) then
                isHopping = false
                return
            end

            task.wait(0.6)
        end

        Notify("All candidates failed, random teleport", false)
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        task.wait(3)
        isHopping = false
    end)
end
getgenv().CentuAB_HopServer = serverHop

local function mainLoop()
    if not STATE.Running then return end
    local char = LocalPlayer.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHum or myHum.Health <= 0 then
        return
    end

    if Settings.AutoBuso then fireBuso() end

    local t = STATE.Target
    if t then
        local ok, valid = pcall(isTargetValid, t, Settings.MaxDist + 500)
        if not ok or not valid then
            skipTarget(false)
            t = nil
        end
    end

    if not t then
        if tick() - STATE.LastTargetAt > 0.4 then
            STATE.LastTargetAt = tick()
            t = findBestTarget()
            if t then
                setTarget(t)
            else
                if Settings.AutoHop and tick() - (STATE.NoTargetSince or 0) > Settings.HopAfter then
                    STATE.NoTargetSince = tick()
                    serverHop()
                elseif not STATE.NoTargetSince then
                    STATE.NoTargetSince = tick()
                end
            end
        end
    else
        STATE.NoTargetSince = nil
    end

    handleHealing()
    if STATE.Healing then return end

    if t and t.Character then
        local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
        local tHum = t.Character:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHum or tHum.Health <= 0 then
            skipTarget(true)
            return
        end

        if Settings.SafeZoneCheck then
            if inSafeZone(t) then
                Notify("Target in SafeZone — skipping", false)
                skipTarget(false)
                return
            end
            if not hasPvPEnabled(t) then
                Notify("Target PvP OFF — skipping", false)
                skipTarget(false)
                return
            end
        end

        local dist = (tHrp.Position - myHrp.Position).Magnitude
        if dist <= 300 then STATE.ReachedTarget = true end

        local targetY = math.max(tHrp.Position.Y, 18)
        local gotoCF
        if dist < 40 then
            gotoCF = tHrp.CFrame * CFrame.new(0, 7.5, -6)
        elseif dist < 120 then
            gotoCF = tHrp.CFrame * CFrame.new(0, 14, -12)
        else
            gotoCF = CFrame.new(tHrp.Position.X, math.max(targetY + 45, 95), tHrp.Position.Z)
        end
        TweenTo(gotoCF)

        if dist < 40 then
            enforceMeleeLock()

            if Settings.KillMethod == "Fast Attack" then
                equipWeaponCategory(Settings.FAWeapon)
                fastAttackTick(t)
            elseif Settings.KillMethod == "Spam Skills" then
                spamSkillsTick(t)
            end
        end

        if not t.Character or tHum.Health <= 0 then
            skipTarget(true)
        end
    end

    local myB = getPlayerBounty(LocalPlayer)
    if myB > 0 then
        STATE.Earned = myB - STATE.StartBounty
    end
end

local function stopAutoBounty()
    STATE.Running = false
    STATE.Killed = {}
    STATE.Healing = false
    STATE.Target = nil
    STATE.AttackCounter = 0
    STATE.NextPauseAt = 0
    STATE.LastFastAttack = 0
    STATE.LastSkillPress = 0
    STATE.SSIndex = 0
    cleanupMovement()
    stopMeleeLockWatcher()
    stopV4Watcher()
    stopInstinctWatcher()
    stopPvPWatcher()
    Notify("Auto Bounty STOPPED", false)
    if _G.CentuAB_UpdateUI then _G.CentuAB_UpdateUI() end
end
getgenv().CentuAB_Stop = stopAutoBounty

local function startAutoBounty()
    if STATE.Running then return end
    STATE.Running = true
    STATE.Killed = {}
    STATE.Healing = false
    STATE.Target = nil
    STATE.ReachedTarget = false
    STATE.NoTargetSince = nil
    STATE.LastTargetAt = 0
    STATE.AttackCounter = 0
    STATE.NextPauseAt = 0
    STATE.LastFastAttack = 0
    STATE.LastSkillPress = 0
    STATE.SSIndex = 0
    STATE.StartBounty = getPlayerBounty(LocalPlayer)
    STATE.StartTime = tick()
    startMeleeLockWatcher()
    startV4Watcher()
    startInstinctWatcher()
    startPvPWatcher()
    Notify("Auto Bounty STARTED", true)
    if _G.CentuAB_UpdateUI then _G.CentuAB_UpdateUI() end
end
getgenv().CentuAB_Start = startAutoBounty

local function toggleAutoBounty()
    if STATE.Running then stopAutoBounty() else startAutoBounty() end
end
getgenv().CentuAB_Toggle = toggleAutoBounty

RunService.Heartbeat:Connect(function()
    if not STATE.Running then return end
    if not isCurrentSession() then stopAutoBounty(); return end
    pcall(mainLoop)
end)

local SPEED_PRESETS = {
    Fast   = { min = 0.12, max = 0.22, label = "Fast (risky)" },
    Normal = { min = 0.15, max = 0.28, label = "Normal" },
    Safe   = { min = 0.22, max = 0.38, label = "Safe" },
    Human  = { min = 0.30, max = 0.55, label = "Human-like" },
}
local HIT_PRESETS = {
    Tiny   = { min = 1, max = 2, label = "1-2 hits" },
    Small  = { min = 2, max = 3, label = "2-3 hits" },
    Medium = { min = 2, max = 4, label = "2-4 hits" },
    Large  = { min = 3, max = 5, label = "3-5 hits" },
    XLarge = { min = 4, max = 6, label = "4-6 hits" },
}
local SPEED_ORDER = { "Fast", "Normal", "Safe", "Human" }
local HIT_ORDER   = { "Tiny", "Small", "Medium", "Large", "XLarge" }

local function applySpeedPreset(name)
    local p = SPEED_PRESETS[name]
    if not p then return end
    Settings.SpeedPreset = name
    Settings.FastAttackDelayMin = p.min
    Settings.FastAttackDelayMax = p.max
end

local function applyHitPreset(name)
    local p = HIT_PRESETS[name]
    if not p then return end
    Settings.HitsPreset = name
    Settings.HitCountMin = p.min
    Settings.HitCountMax = p.max
end

local function buildGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CentuAB_GUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 10000
    local ok = pcall(function() sg.Parent = TargetParent end)
    if not ok or not sg.Parent then sg.Parent = PlayerGui end

    local frame = Instance.new("Frame", sg)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 540)
    frame.Position = UDim2.new(0, 20, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local frameStk = Instance.new("UIStroke", frame)
    frameStk.Color = Color3.fromRGB(120, 90, 200)
    frameStk.Thickness = 1.4

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -100, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "CENTU AUTO BOUNTY"
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(220, 190, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local minimizeBtn = Instance.new("TextButton", frame)
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.Position = UDim2.new(1, -58, 0, 8)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 15
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -30, 0, 8)
    close.BackgroundColor3 = Color3.fromRGB(40, 22, 28)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 150, 150)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 11
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)
    close.MouseButton1Click:Connect(function()
        stopAutoBounty()
        sg:Destroy()
    end)

    local restoreBtn = Instance.new("TextButton", sg)
    restoreBtn.Name = "RestoreBtn"
    restoreBtn.Size = UDim2.new(0, 56, 0, 56)
    restoreBtn.Position = UDim2.new(0, 20, 0, 60)
    restoreBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
    restoreBtn.BackgroundTransparency = 0.05
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.Text = ""
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Color3.fromRGB(220, 190, 255)
    restoreBtn.Visible = false
    restoreBtn.Active = true
    restoreBtn.Draggable = true
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 8)
    local rStk = Instance.new("UIStroke", restoreBtn)
    rStk.Color = Color3.fromRGB(120, 90, 200)
    rStk.Thickness = 1.4

    local restoreIcon = Instance.new("ImageLabel", restoreBtn)
    restoreIcon.Name = "RestoreIcon"
    restoreIcon.Size = UDim2.new(0, 40, 0, 40)
    restoreIcon.Position = UDim2.new(0.5, -20, 0.5, -20)
    restoreIcon.BackgroundTransparency = 1
    restoreIcon.Image = "rbxassetid://123438604306607"
    restoreIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    restoreIcon.ScaleType = Enum.ScaleType.Fit

    local function setMinimized(state)
        frame.Visible = not state
        restoreBtn.Visible = state
        if state then
            restoreBtn.Position = frame.Position
        end
    end
    minimizeBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
    restoreBtn.MouseButton1Click:Connect(function() setMinimized(false) end)

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(1, -20, 0, 42)
    toggleBtn.Position = UDim2.new(0, 10, 0, 40)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(26, 22, 36)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
    local tbStk = Instance.new("UIStroke", toggleBtn)
    tbStk.Color = Color3.fromRGB(80, 60, 130)
    tbStk.Thickness = 1.2

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -20, 0, 16)
    status.Position = UDim2.new(0, 10, 0, 86)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 10.5
    status.TextColor3 = Color3.fromRGB(180, 180, 200)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Text = "Status: idle"

    local earned = Instance.new("TextLabel", frame)
    earned.Size = UDim2.new(1, -20, 0, 16)
    earned.Position = UDim2.new(0, 10, 0, 104)
    earned.BackgroundTransparency = 1
    earned.Font = Enum.Font.GothamMedium
    earned.TextSize = 10.5
    earned.TextColor3 = Color3.fromRGB(180, 220, 180)
    earned.TextXAlignment = Enum.TextXAlignment.Left
    earned.Text = "Earned: 0"

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Name = "ContentScroll"
    scroll.Size = UDim2.new(1, -14, 0, 330)
    scroll.Position = UDim2.new(0, 7, 0, 124)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 70, 120)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local statusCard = Instance.new("Frame", frame)
    statusCard.Size = UDim2.new(1, -20, 0, 56)
    statusCard.Position = UDim2.new(0, 10, 1, -68)
    statusCard.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    statusCard.BorderSizePixel = 0
    Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 6)
    local scStk = Instance.new("UIStroke", statusCard)
    scStk.Color = Color3.fromRGB(40, 40, 52)
    scStk.Thickness = 1

    local cardLbl = Instance.new("TextLabel", statusCard)
    cardLbl.Size = UDim2.new(1, -12, 1, 0)
    cardLbl.Position = UDim2.new(0, 6, 0, 0)
    cardLbl.BackgroundTransparency = 1
    cardLbl.Font = Enum.Font.Code
    cardLbl.TextSize = 9.5
    cardLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    cardLbl.TextXAlignment = Enum.TextXAlignment.Left
    cardLbl.TextYAlignment = Enum.TextYAlignment.Center
    cardLbl.Text = "ready"

    local function makeSection(order, height)
        local s = Instance.new("Frame", scroll)
        s.Size = UDim2.new(1, -6, 0, height)
        s.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        s.BorderSizePixel = 0
        s.LayoutOrder = order
        Instance.new("UICorner", s).CornerRadius = UDim.new(0, 7)
        local stk = Instance.new("UIStroke", s)
        stk.Color = Color3.fromRGB(38, 38, 52)
        stk.Thickness = 1
        return s
    end

    local function makeHeader(parent, text, y)
        local h = Instance.new("TextLabel", parent)
        h.Size = UDim2.new(1, -16, 0, 14)
        h.Position = UDim2.new(0, 8, 0, y or 6)
        h.BackgroundTransparency = 1
        h.Font = Enum.Font.GothamBold
        h.TextSize = 10
        h.TextColor3 = Color3.fromRGB(180, 160, 220)
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Text = text
        return h
    end

    local function makeCycleBtn(parent, y, initial, onNext)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -16, 0, 28)
        b.Position = UDim2.new(0, 8, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = Color3.fromRGB(230, 220, 255)
        b.Text = initial
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local stk = Instance.new("UIStroke", b)
        stk.Color = Color3.fromRGB(60, 55, 90)
        stk.Thickness = 1
        b.MouseButton1Click:Connect(function() onNext(b) end)
        return b
    end

    local KILL_METHODS = { "Fast Attack", "Spam Skills" }

    local secKill = makeSection(1, 84)
    makeHeader(secKill, "KILL METHOD", 6)
    local killBtn = makeCycleBtn(secKill, 24, "Kill: " .. Settings.KillMethod, function(b)
        local cur = Settings.KillMethod
        local idx = 1
        for i, v in ipairs(KILL_METHODS) do if v == cur then idx = i; break end end
        idx = (idx % #KILL_METHODS) + 1
        Settings.KillMethod = KILL_METHODS[idx]
        b.Text = "Kill: " .. Settings.KillMethod
        _G.CentuAB_RefreshMode()
    end)
    local killHint = Instance.new("TextLabel", secKill)
    killHint.Size = UDim2.new(1, -16, 0, 26)
    killHint.Position = UDim2.new(0, 8, 0, 54)
    killHint.BackgroundTransparency = 1
    killHint.Font = Enum.Font.Gotham
    killHint.TextSize = 9
    killHint.TextWrapped = true
    killHint.TextColor3 = Color3.fromRGB(150, 150, 175)
    killHint.TextXAlignment = Enum.TextXAlignment.Left
    killHint.TextYAlignment = Enum.TextYAlignment.Top
    killHint.Text = "Fast Attack = remote burst (may fail / suspicious). Spam Skills = real skills (safer, slower)."

    local secFA = makeSection(2, 116)
    makeHeader(secFA, "FAST ATTACK WEAPON", 6)

    local FA_WEAPONS = { "Melee", "Fruit", "Sword" }
    local faBtn = makeCycleBtn(secFA, 24, "Weapon: " .. Settings.FAWeapon, function(b)
        local cur = Settings.FAWeapon
        local idx = 1
        for i, v in ipairs(FA_WEAPONS) do if v == cur then idx = i; break end end
        idx = (idx % #FA_WEAPONS) + 1
        Settings.FAWeapon = FA_WEAPONS[idx]
        b.Text = "Weapon: " .. Settings.FAWeapon
    end)

    local faNote1 = Instance.new("TextLabel", secFA)
    faNote1.Size = UDim2.new(1, -16, 0, 22)
    faNote1.Position = UDim2.new(0, 8, 0, 56)
    faNote1.BackgroundTransparency = 1
    faNote1.Font = Enum.Font.Gotham
    faNote1.TextSize = 9
    faNote1.TextWrapped = true
    faNote1.TextColor3 = Color3.fromRGB(255, 200, 120)
    faNote1.TextXAlignment = Enum.TextXAlignment.Left
    faNote1.TextYAlignment = Enum.TextYAlignment.Top
    faNote1.Text = "Fruit: only works for fruits that have M1."

    local faNote2 = Instance.new("TextLabel", secFA)
    faNote2.Size = UDim2.new(1, -16, 0, 34)
    faNote2.Position = UDim2.new(0, 8, 0, 78)
    faNote2.BackgroundTransparency = 1
    faNote2.Font = Enum.Font.Gotham
    faNote2.TextSize = 9
    faNote2.TextWrapped = true
    faNote2.TextColor3 = Color3.fromRGB(255, 160, 160)
    faNote2.TextXAlignment = Enum.TextXAlignment.Left
    faNote2.TextYAlignment = Enum.TextYAlignment.Top
    faNote2.Text = "Warning: Sometimes you get Bounty, sometimes you don't."

    local secSS = makeSection(3, 196)
    makeHeader(secSS, "SPAM SKILLS — WEAPONS", 6)

    local ssWeaponLabels = {
        { key = "SS_Melee", label = "Melee" },
        { key = "SS_Fruit", label = "Fruit" },
        { key = "SS_Sword", label = "Sword" },
        { key = "SS_Gun",   label = "Gun"   },
    }
    local weaponY = 24
    for i, w in ipairs(ssWeaponLabels) do
        local b = Instance.new("TextButton", secSS)
        local w_per = (1 - 16 - 9) / 4
        b.Size = UDim2.new(w_per, 0, 0, 26)
        b.Position = UDim2.new(0, 8 + (i-1) * (w_per + 3), 0, weaponY)
        b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9.5
        b.TextColor3 = Color3.fromRGB(200, 200, 220)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local stk = Instance.new("UIStroke", b)
        stk.Color = Color3.fromRGB(45, 45, 60)
        stk.Thickness = 1
        local function refresh()
            local on = Settings[w.key] == true
            b.Text = w.label .. ": " .. (on and "ON" or "OFF")
            b.BackgroundColor3 = on and Color3.fromRGB(30, 50, 40) or Color3.fromRGB(22, 22, 32)
            b.TextColor3 = on and Color3.fromRGB(180, 240, 200) or Color3.fromRGB(200, 200, 220)
            stk.Color = on and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(45, 45, 60)
        end
        b.MouseButton1Click:Connect(function()
            Settings[w.key] = not Settings[w.key]
            refresh()
        end)
        refresh()
    end

    local ssWeaponHint = Instance.new("TextLabel", secSS)
    ssWeaponHint.Size = UDim2.new(1, -16, 0, 20)
    ssWeaponHint.Position = UDim2.new(0, 8, 0, 54)
    ssWeaponHint.BackgroundTransparency = 1
    ssWeaponHint.Font = Enum.Font.Gotham
    ssWeaponHint.TextSize = 9
    ssWeaponHint.TextWrapped = true
    ssWeaponHint.TextColor3 = Color3.fromRGB(150, 150, 175)
    ssWeaponHint.TextXAlignment = Enum.TextXAlignment.Left
    ssWeaponHint.TextYAlignment = Enum.TextYAlignment.Top
    ssWeaponHint.Text = "Cycles through enabled weapons during fight. Gun OFF = won't use Gun."

    makeHeader(secSS, "SKILLS TO USE", 82)

    local ssSkillLabels = {
        { key = "SS_Z", label = "Z" },
        { key = "SS_X", label = "X" },
        { key = "SS_C", label = "C" },
        { key = "SS_V", label = "V" },
        { key = "SS_F", label = "F" },
    }
    local skillY = 100
    for i, s in ipairs(ssSkillLabels) do
        local b = Instance.new("TextButton", secSS)
        local s_per = (1 - 16 - 12) / 5
        b.Size = UDim2.new(s_per, 0, 0, 26)
        b.Position = UDim2.new(0, 8 + (i-1) * (s_per + 3), 0, skillY)
        b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = Color3.fromRGB(200, 200, 220)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local stk = Instance.new("UIStroke", b)
        stk.Color = Color3.fromRGB(45, 45, 60)
        stk.Thickness = 1
        local function refresh()
            local on = Settings[s.key] == true
            b.Text = s.label .. (on and " ✓" or " ✗")
            b.BackgroundColor3 = on and Color3.fromRGB(30, 50, 40) or Color3.fromRGB(22, 22, 32)
            b.TextColor3 = on and Color3.fromRGB(180, 240, 200) or Color3.fromRGB(200, 200, 220)
            stk.Color = on and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(45, 45, 60)
        end
        b.MouseButton1Click:Connect(function()
            Settings[s.key] = not Settings[s.key]
            refresh()
        end)
        refresh()
    end

    local ssSkillHintLbl = Instance.new("TextLabel", secSS)
    ssSkillHintLbl.Size = UDim2.new(1, -16, 0, 20)
    ssSkillHintLbl.Position = UDim2.new(0, 8, 0, 132)
    ssSkillHintLbl.BackgroundTransparency = 1
    ssSkillHintLbl.Font = Enum.Font.Gotham
    ssSkillHintLbl.TextSize = 9
    ssSkillHintLbl.TextWrapped = true
    ssSkillHintLbl.TextColor3 = Color3.fromRGB(150, 150, 175)
    ssSkillHintLbl.TextXAlignment = Enum.TextXAlignment.Left
    ssSkillHintLbl.TextYAlignment = Enum.TextYAlignment.Top
    ssSkillHintLbl.Text = "Only selected skills will be pressed. If all on cooldown, falls back to M1."

    local ssNote = Instance.new("TextLabel", secSS)
    ssNote.Size = UDim2.new(1, -16, 0, 34)
    ssNote.Position = UDim2.new(0, 8, 0, 156)
    ssNote.BackgroundTransparency = 1
    ssNote.Font = Enum.Font.Gotham
    ssNote.TextSize = 9
    ssNote.TextWrapped = true
    ssNote.TextColor3 = Color3.fromRGB(140, 210, 255)
    ssNote.TextXAlignment = Enum.TextXAlignment.Left
    ssNote.TextYAlignment = Enum.TextYAlignment.Top
    ssNote.Text = "Spam Skills = legit skill presses (Z/X/C/V/F) — safer but slower than Fast Attack."

    local secSpeed = makeSection(4, 108)
    makeHeader(secSpeed, "SPEED (ATTACK RATE)", 6)
    local speedBtn = makeCycleBtn(secSpeed, 24, "Speed: " .. SPEED_PRESETS[Settings.SpeedPreset].label, function(b)
        local cur = Settings.SpeedPreset
        local idx = 1
        for i, v in ipairs(SPEED_ORDER) do if v == cur then idx = i; break end end
        idx = (idx % #SPEED_ORDER) + 1
        applySpeedPreset(SPEED_ORDER[idx])
        b.Text = "Speed: " .. SPEED_PRESETS[SPEED_ORDER[idx]].label
    end)

    local hitBtn = makeCycleBtn(secSpeed, 58, "Hits: " .. HIT_PRESETS[Settings.HitsPreset].label, function(b)
        local cur = Settings.HitsPreset
        local idx = 1
        for i, v in ipairs(HIT_ORDER) do if v == cur then idx = i; break end end
        idx = (idx % #HIT_ORDER) + 1
        applyHitPreset(HIT_ORDER[idx])
        b.Text = "Hits: " .. HIT_PRESETS[HIT_ORDER[idx]].label
    end)

    local secToggles = makeSection(5, 138)
    makeHeader(secToggles, "TOGGLES", 6)

    local function makeToggleBtn(parent, x, y, w, label, getFn, setFn)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(w, 0, 0, 26)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.fromRGB(200, 200, 220)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local stk = Instance.new("UIStroke", b)
        stk.Color = Color3.fromRGB(45, 45, 60)
        stk.Thickness = 1
        local function refresh()
            local on = getFn()
            b.Text = label .. ": " .. (on and "ON" or "OFF")
            b.BackgroundColor3 = on and Color3.fromRGB(28, 40, 60) or Color3.fromRGB(22, 22, 32)
            b.TextColor3 = on and Color3.fromRGB(180, 220, 255) or Color3.fromRGB(200, 200, 220)
            stk.Color = on and Color3.fromRGB(60, 110, 180) or Color3.fromRGB(45, 45, 60)
        end
        b.MouseButton1Click:Connect(function()
            setFn(not getFn())
            refresh()
        end)
        refresh()
        return b
    end

    makeToggleBtn(secToggles, 8, 24, 0.31, "Hop", function() return Settings.AutoHop end, function(v) Settings.AutoHop = v end)
    makeToggleBtn(secToggles, 8 + 90, 24, 0.31, "Buso", function() return Settings.AutoBuso end, function(v) Settings.AutoBuso = v end)
    makeToggleBtn(secToggles, 8 + 180, 24, 0.31, "MeleeLock", function() return Settings.MeleeLock end, function(v) Settings.MeleeLock = v end)
    makeToggleBtn(secToggles, 8, 58, 0.31, "Auto V4", function() return Settings.AutoV4 end, function(v) Settings.AutoV4 = v end)
    makeToggleBtn(secToggles, 8 + 90, 58, 0.31, "Instinct", function() return Settings.AutoInstinct end, function(v) Settings.AutoInstinct = v end)
    makeToggleBtn(secToggles, 8 + 180, 58, 0.31, "Auto PvP", function() return Settings.AutoPvPOnDeath end, function(v) Settings.AutoPvPOnDeath = v end)

    local instinctHint = Instance.new("TextLabel", secToggles)
    instinctHint.Size = UDim2.new(1, -16, 0, 26)
    instinctHint.Position = UDim2.new(0, 8, 0, 92)
    instinctHint.BackgroundTransparency = 1
    instinctHint.Font = Enum.Font.Gotham
    instinctHint.TextSize = 9
    instinctHint.TextWrapped = true
    instinctHint.TextColor3 = Color3.fromRGB(150, 150, 175)
    instinctHint.TextXAlignment = Enum.TextXAlignment.Left
    instinctHint.TextYAlignment = Enum.TextYAlignment.Top
    instinctHint.Text = "Instinct = auto Ken/Observation. Auto PvP = re-enable PvP after death."

    local secLvl = makeSection(6, 60)
    makeHeader(secLvl, "MIN LEVEL (target filter)", 6)
    local lvlBox = Instance.new("TextBox", secLvl)
    lvlBox.Size = UDim2.new(1, -16, 0, 26)
    lvlBox.Position = UDim2.new(0, 8, 0, 24)
    lvlBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    lvlBox.Font = Enum.Font.Gotham
    lvlBox.TextSize = 11
    lvlBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    lvlBox.Text = tostring(Settings.MinLevel)
    lvlBox.ClearTextOnFocus = false
    Instance.new("UICorner", lvlBox).CornerRadius = UDim.new(0, 5)
    lvlBox.FocusLost:Connect(function()
        local n = tonumber(lvlBox.Text)
        if n then Settings.MinLevel = n end
        lvlBox.Text = tostring(Settings.MinLevel)
    end)

    local secManual = makeSection(7, 62)
    makeHeader(secManual, "MANUAL", 6)
    local skipBtn = Instance.new("TextButton", secManual)
    skipBtn.Size = UDim2.new(0.48, -4, 0, 26)
    skipBtn.Position = UDim2.new(0, 8, 0, 24)
    skipBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    skipBtn.Font = Enum.Font.GothamBold
    skipBtn.TextSize = 10
    skipBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    skipBtn.Text = "Skip Target"
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 5)
    skipBtn.MouseButton1Click:Connect(function()
        if STATE.Target then skipTarget(false) end
    end)

    local manHop = Instance.new("TextButton", secManual)
    manHop.Size = UDim2.new(0.48, -4, 0, 26)
    manHop.Position = UDim2.new(0.52, 0, 0, 24)
    manHop.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    manHop.Font = Enum.Font.GothamBold
    manHop.TextSize = 10
    manHop.TextColor3 = Color3.fromRGB(200, 200, 220)
    manHop.Text = "Hop Server"
    Instance.new("UICorner", manHop).CornerRadius = UDim.new(0, 5)
    manHop.MouseButton1Click:Connect(function() serverHop() end)

    local function refreshModeVisibility()
        secFA.Visible = (Settings.KillMethod == "Fast Attack")
        secSS.Visible = (Settings.KillMethod == "Spam Skills")
    end
    _G.CentuAB_RefreshMode = refreshModeVisibility
    refreshModeVisibility()

    _G.CentuAB_UpdateUI = function()
        toggleBtn.Text = STATE.Running and "■ STOP" or "▶ START"
        toggleBtn.BackgroundColor3 = STATE.Running and Color3.fromRGB(50, 20, 30) or Color3.fromRGB(26, 22, 36)
        tbStk.Color = STATE.Running and Color3.fromRGB(150, 50, 70) or Color3.fromRGB(80, 60, 130)
        if restoreBtn.Visible then
            restoreBtn.BackgroundColor3 = STATE.Running and Color3.fromRGB(50, 20, 30) or Color3.fromRGB(20, 18, 30)
            rStk.Color = STATE.Running and Color3.fromRGB(150, 50, 70) or Color3.fromRGB(120, 90, 200)
        end
    end
    _G.CentuAB_UpdateUI()

    toggleBtn.MouseButton1Click:Connect(function()
        toggleAutoBounty()
    end)

    task.spawn(function()
        while sg.Parent and isCurrentSession() do
            task.wait(0.4)
            pcall(function()
                local t = STATE.Target
                if t and t.Character then
                    local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = (tHrp and myHrp) and math.floor((tHrp.Position - myHrp.Position).Magnitude) or 0
                    status.Text = string.format("Target: %s [%dm]", t.DisplayName or t.Name, dist)
                    status.TextColor3 = Color3.fromRGB(255, 140, 140)
                else
                    status.Text = STATE.Running and "Scanning..." or "Status: idle"
                    status.TextColor3 = Color3.fromRGB(180, 180, 200)
                end
                earned.Text = string.format("Earned: %.2fM", (STATE.Earned or 0) / 1e6)

                local v4State = "off"
                if Settings.AutoV4 then
                    local char = LocalPlayer.Character
                    local energy = char and char:FindFirstChild("RaceEnergy")
                    if energy then
                        local v = tonumber(energy.Value) or 0
                        v4State = v >= 1 and "READY" or string.format("%d%%", math.floor(v * 100))
                    else
                        v4State = "no race"
                    end
                end

                local modeStr
                if Settings.KillMethod == "Fast Attack" then
                    modeStr = "FA " .. Settings.FAWeapon
                else
                    local wEn = getEnabledSSWeapons()
                    modeStr = "SS " .. table.concat(wEn, "/")
                end

                cardLbl.Text = string.format(
                    "%s | Lvl>%d | V4:%s\nSpeed:%s Hits:%d-%d | HP<%d",
                    modeStr,
                    Settings.MinLevel,
                    v4State,
                    SPEED_PRESETS[Settings.SpeedPreset].label,
                    Settings.HitCountMin, Settings.HitCountMax,
                    Settings.HealThreshold
                )
            end)
        end
    end)

    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return sg
end

local gui = buildGUI()

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleAutoBounty()
    end
end)

Notify("Centu AB loaded. RightShift to toggle.", true)
print("[Centu AB] loaded. Session: " .. tostring(SESSION))