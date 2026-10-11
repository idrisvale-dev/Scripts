local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local SESSION = tick()
local function isCurrentSession() return getgenv().CentuVK_Session == SESSION end
getgenv().CentuVK_Session = SESSION

local function Notify(text, isGood)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Centu Void Kill",
            Text = tostring(text or ""),
            Duration = 3,
        })
    end)
    print(string.format("[Centu VK] %s: %s", isGood and "+" or "-", tostring(text)))
end

local Settings = {
    Enabled          = false,
    MinLevel         = 2400,
    MinBounty        = 2400000,
    MaxDist          = 3000,
    FarSpeed         = 160,
    NearSpeed        = 350,
    TeamCheck        = true,
    SafeZoneCheck    = true,
    VoidY            = -5000,
    GrabRange        = 15,
    TweenToRange     = 12,
    ResetDelay       = 0.08,
    Cooldown         = 1.4,
}
getgenv().CentuVK_Settings = Settings

local STATE = {
    Running        = false,
    Target         = nil,
    TweenObj       = nil,
    PartTele       = nil,
    PartTeleConn   = nil,
    NoclipConn     = nil,
    ReachedTarget  = false,
    LastTargetAt   = 0,
    LastKillAt     = 0,
    Kills          = 0,
    Attempts       = 0,
    Resetting      = false,
    PendingResetAt = 0,
}
getgenv().CentuVK_State = STATE

getgenv().CentuVK_Blacklist = getgenv().CentuVK_Blacklist or {}
local Blacklist = getgenv().CentuVK_Blacklist
local function isPlayerBlacklisted(p)
    if not p then return false end
    if Blacklist[p] == true then return true end
    if p.UserId and (Blacklist[p.UserId] or Blacklist[tostring(p.UserId)]) then return true end
    if p.Name and (Blacklist[p.Name] or Blacklist[p.Name:lower()]) then return true end
    return false
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
                    if math.abs(localPos.X) <= size.X/2 + BUFFER
                        and math.abs(localPos.Y) <= size.Y/2 + BUFFER
                        and math.abs(localPos.Z) <= size.Z/2 + BUFFER then
                        return true
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
    if isPlayerBlacklisted(p) then return false, "blacklist" end

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
        if inSafeZone(p) then return false, "safezone" end
        if not hasPvPEnabled(p) then return false, "pvp off" end
    end

    if Settings.TeamCheck and not isEnemy(p) then return false, "team" end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false, "no local" end

    local dist = (hrp.Position - myHrp.Position).Magnitude
    if dist > (maxDist or Settings.MaxDist) then return false, "range" end
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

local function hasDragonTalonEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = string.lower(tool.Name)
    return n:find("dragon talon") or n:find("dragontalon")
        or n:find("dragon_talon") or n == "dragontalon"
end

local function equipDragonTalon()
    if hasDragonTalonEquipped() then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local pool = {}
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then table.insert(pool, t) end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(pool, t) end
        end
    end

    for _, t in ipairs(pool) do
        local n = string.lower(t.Name)
        if n:find("dragon talon") or n:find("dragontalon")
            or n:find("dragon_talon") or n == "dragontalon" then
            pcall(function() hum:EquipTool(t) end)
            task.wait(0.15)
            return hasDragonTalonEquipped()
        end
    end
    return false
end

local function fireDragonTalonZ()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end)
end

local function teleportTargetToVoid(target)
    if not target or not target.Character then return false end
    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHrp then return false end
    pcall(function()
        tHrp.CFrame = CFrame.new(tHrp.Position.X, Settings.VoidY, tHrp.Position.Z)
        tHrp.AssemblyLinearVelocity = Vector3.new(0, -999, 0)
        tHrp.AssemblyAngularVelocity = Vector3.zero
    end)
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.Name = "CentuVoidKill"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0, -999, 0)
        bv.Parent = tHrp
        task.delay(0.6, function()
            if bv and bv.Parent then bv:Destroy() end
        end)
    end)
    return true
end

local function resetSelf()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        pcall(function() hum.Health = 0 end)
    end
end

local function tryVoidKill(target)
    if not target or not target.Character then return false end
    local now = tick()
    if now - STATE.LastKillAt < Settings.Cooldown then return false end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHum or myHum.Health <= 0 then return false end

    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
    if not tHrp or not tHum or tHum.Health <= 0 then return false end

    local dist = (tHrp.Position - myHrp.Position).Magnitude
    if dist > Settings.GrabRange then return false end

    if not equipDragonTalon() then return false end

    STATE.LastKillAt = now
    STATE.Attempts = STATE.Attempts + 1

    fireDragonTalonZ()

    task.delay(0.05, function()
        pcall(teleportTargetToVoid, target)
    end)

    task.delay(Settings.ResetDelay, function()
        STATE.Resetting = true
        STATE.PendingResetAt = tick()
        resetSelf()
        STATE.Kills = STATE.Kills + 1
        Notify("Void kill: " .. target.Name, true)
    end)

    return true
end

local function findBestTarget()
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
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
    if _G.CentuVK_UpdateUI then _G.CentuVK_UpdateUI() end
end

local function skipTarget()
    STATE.Target = nil
    STATE.ReachedTarget = false
    if _G.CentuVK_UpdateUI then _G.CentuVK_UpdateUI() end
end

local function mainLoop()
    if not STATE.Running then return end
    local char = LocalPlayer.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHum or myHum.Health <= 0 then return end

    if STATE.Resetting then
        if tick() - STATE.PendingResetAt > 2.5 then
            STATE.Resetting = false
        end
        return
    end

    local t = STATE.Target
    if t then
        local ok, valid = pcall(isTargetValid, t, Settings.MaxDist + 500)
        if not ok or not valid then
            skipTarget()
            t = nil
        end
    end

    if not t then
        if tick() - STATE.LastTargetAt > 0.4 then
            STATE.LastTargetAt = tick()
            t = findBestTarget()
            if t then setTarget(t) end
        end
        return
    end

    if not t.Character then skipTarget(); return end
    local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
    local tHum = t.Character:FindFirstChildOfClass("Humanoid")
    if not tHrp or not tHum or tHum.Health <= 0 then
        skipTarget()
        return
    end

    if Settings.SafeZoneCheck then
        if inSafeZone(t) then
            Notify("Target in SafeZone — skip", false)
            skipTarget()
            return
        end
        if not hasPvPEnabled(t) then
            Notify("Target PvP OFF — skip", false)
            skipTarget()
            return
        end
    end

    local dist = (tHrp.Position - myHrp.Position).Magnitude
    if dist <= 300 then STATE.ReachedTarget = true end

    local targetY = math.max(tHrp.Position.Y, 18)
    local gotoCF

    if dist < Settings.TweenToRange then
        gotoCF = tHrp.CFrame * CFrame.new(0, 3, 2)
    elseif dist < 60 then
        gotoCF = tHrp.CFrame * CFrame.new(0, 6, 5)
    else
        gotoCF = CFrame.new(tHrp.Position.X, math.max(targetY + 30, 65), tHrp.Position.Z)
    end

    TweenTo(gotoCF)

    if dist <= Settings.GrabRange then
        tryVoidKill(t)
    end
end

local function startVK()
    if STATE.Running then return end
    STATE.Running = true
    STATE.Resetting = false
    STATE.Target = nil
    STATE.Kills = 0
    STATE.Attempts = 0
    STATE.LastKillAt = 0
    Notify("Void Kill STARTED", true)
    if _G.CentuVK_UpdateUI then _G.CentuVK_UpdateUI() end
end
getgenv().CentuVK_Start = startVK

local function stopVK()
    STATE.Running = false
    STATE.Target = nil
    STATE.Resetting = false
    cleanupMovement()
    Notify("Void Kill STOPPED", false)
    if _G.CentuVK_UpdateUI then _G.CentuVK_UpdateUI() end
end
getgenv().CentuVK_Stop = stopVK

local function toggleVK()
    if STATE.Running then stopVK() else startVK() end
end
getgenv().CentuVK_Toggle = toggleVK

RunService.Heartbeat:Connect(function()
    if not STATE.Running then return end
    if not isCurrentSession() then stopVK(); return end
    pcall(mainLoop)
end)

local function getSafeParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return PlayerGui
end

local function buildGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CentuVK_GUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 10002
    local okP = pcall(function() sg.Parent = getSafeParent() end)
    if not okP or not sg.Parent then sg.Parent = PlayerGui end

    local frame = Instance.new("Frame", sg)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 260, 0, 360)
    frame.Position = UDim2.new(0, 340, 0, 200)
    frame.BackgroundColor3 = Color3.fromRGB(14, 12, 18)
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local fStk = Instance.new("UIStroke", frame)
    fStk.Color = Color3.fromRGB(200, 80, 100)
    fStk.Thickness = 1.4

    do
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
    end

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -40, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "CENTU VOID KILL"
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 160, 180)
    title.TextXAlignment = Enum.TextXAlignment.Left

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
        stopVK()
        sg:Destroy()
    end)

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(1, -20, 0, 42)
    toggleBtn.Position = UDim2.new(0, 10, 0, 40)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(26, 22, 36)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 13
    toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
    local tbStk = Instance.new("UIStroke", toggleBtn)
    tbStk.Color = Color3.fromRGB(80, 60, 130)
    tbStk.Thickness = 1.2

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -20, 0, 16)
    status.Position = UDim2.new(0, 10, 0, 88)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 10.5
    status.TextColor3 = Color3.fromRGB(180, 180, 200)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Text = "Status: idle"

    local stats = Instance.new("TextLabel", frame)
    stats.Size = UDim2.new(1, -20, 0, 16)
    stats.Position = UDim2.new(0, 10, 0, 106)
    stats.BackgroundTransparency = 1
    stats.Font = Enum.Font.GothamMedium
    stats.TextSize = 10.5
    stats.TextColor3 = Color3.fromRGB(180, 220, 180)
    stats.TextXAlignment = Enum.TextXAlignment.Left
    stats.Text = "kills: 0 | attempts: 0"

    local function makeToggle(label, getFn, setFn, y)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(0.5, -13, 0, 26)
        b.Position = UDim2.new(0, 10, 0, y)
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
            b.BackgroundColor3 = on and Color3.fromRGB(50, 26, 40) or Color3.fromRGB(22, 22, 32)
            b.TextColor3 = on and Color3.fromRGB(255, 180, 200) or Color3.fromRGB(200, 200, 220)
            stk.Color = on and Color3.fromRGB(160, 70, 90) or Color3.fromRGB(45, 45, 60)
        end
        b.MouseButton1Click:Connect(function()
            setFn(not getFn())
            refresh()
        end)
        refresh()
        return b
    end

    makeToggle("TeamChk", function() return Settings.TeamCheck end, function(v) Settings.TeamCheck = v end, 132)
    local safeB = makeToggle("SafeZone", function() return Settings.SafeZoneCheck end, function(v) Settings.SafeZoneCheck = v end, 132)
    safeB.Position = UDim2.new(0.5, 3, 0, 132)

    local lvlLbl = Instance.new("TextLabel", frame)
    lvlLbl.Size = UDim2.new(0, 100, 0, 14)
    lvlLbl.Position = UDim2.new(0, 10, 0, 168)
    lvlLbl.BackgroundTransparency = 1
    lvlLbl.Font = Enum.Font.GothamBold
    lvlLbl.TextSize = 9.5
    lvlLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    lvlLbl.TextXAlignment = Enum.TextXAlignment.Left
    lvlLbl.Text = "MIN LEVEL"

    local lvlBox = Instance.new("TextBox", frame)
    lvlBox.Size = UDim2.new(1, -20, 0, 26)
    lvlBox.Position = UDim2.new(0, 10, 0, 184)
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

    local voidLbl = Instance.new("TextLabel", frame)
    voidLbl.Size = UDim2.new(0, 100, 0, 14)
    voidLbl.Position = UDim2.new(0, 10, 0, 218)
    voidLbl.BackgroundTransparency = 1
    voidLbl.Font = Enum.Font.GothamBold
    voidLbl.TextSize = 9.5
    voidLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    voidLbl.TextXAlignment = Enum.TextXAlignment.Left
    voidLbl.Text = "VOID Y"

    local voidBox = Instance.new("TextBox", frame)
    voidBox.Size = UDim2.new(0.5, -13, 0, 26)
    voidBox.Position = UDim2.new(0, 10, 0, 234)
    voidBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    voidBox.Font = Enum.Font.Gotham
    voidBox.TextSize = 11
    voidBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    voidBox.Text = tostring(Settings.VoidY)
    voidBox.ClearTextOnFocus = false
    Instance.new("UICorner", voidBox).CornerRadius = UDim.new(0, 5)
    voidBox.FocusLost:Connect(function()
        local n = tonumber(voidBox.Text)
        if n then Settings.VoidY = n end
        voidBox.Text = tostring(Settings.VoidY)
    end)

    local cdLbl = Instance.new("TextLabel", frame)
    cdLbl.Size = UDim2.new(0, 100, 0, 14)
    cdLbl.Position = UDim2.new(0.5, 3, 0, 218)
    cdLbl.BackgroundTransparency = 1
    cdLbl.Font = Enum.Font.GothamBold
    cdLbl.TextSize = 9.5
    cdLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    cdLbl.TextXAlignment = Enum.TextXAlignment.Left
    cdLbl.Text = "COOLDOWN"

    local cdBox = Instance.new("TextBox", frame)
    cdBox.Size = UDim2.new(0.5, -13, 0, 26)
    cdBox.Position = UDim2.new(0.5, 3, 0, 234)
    cdBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    cdBox.Font = Enum.Font.Gotham
    cdBox.TextSize = 11
    cdBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    cdBox.Text = tostring(Settings.Cooldown)
    cdBox.ClearTextOnFocus = false
    Instance.new("UICorner", cdBox).CornerRadius = UDim.new(0, 5)
    cdBox.FocusLost:Connect(function()
        local n = tonumber(cdBox.Text)
        if n then Settings.Cooldown = n end
        cdBox.Text = tostring(Settings.Cooldown)
    end)

    local manualBtn = Instance.new("TextButton", frame)
    manualBtn.Size = UDim2.new(1, -20, 0, 32)
    manualBtn.Position = UDim2.new(0, 10, 0, 270)
    manualBtn.BackgroundColor3 = Color3.fromRGB(70, 24, 40)
    manualBtn.Font = Enum.Font.GothamBold
    manualBtn.TextSize = 11.5
    manualBtn.TextColor3 = Color3.fromRGB(255, 210, 220)
    manualBtn.Text = "FIRE MANUAL"
    Instance.new("UICorner", manualBtn).CornerRadius = UDim.new(0, 6)
    manualBtn.MouseButton1Click:Connect(function()
        if STATE.Target then tryVoidKill(STATE.Target) end
    end)

    local skipBtn = Instance.new("TextButton", frame)
    skipBtn.Size = UDim2.new(0.5, -13, 0, 26)
    skipBtn.Position = UDim2.new(0, 10, 0, 310)
    skipBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    skipBtn.Font = Enum.Font.GothamBold
    skipBtn.TextSize = 10.5
    skipBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    skipBtn.Text = "Skip Target"
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 6)
    skipBtn.MouseButton1Click:Connect(function() skipTarget() end)

    local clearBtn = Instance.new("TextButton", frame)
    clearBtn.Size = UDim2.new(0.5, -13, 0, 26)
    clearBtn.Position = UDim2.new(0.5, 3, 0, 310)
    clearBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 10.5
    clearBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    clearBtn.Text = "Clear BL"
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    clearBtn.MouseButton1Click:Connect(function()
        _G.CentuVK_Blacklist = {}
        Blacklist = _G.CentuVK_Blacklist
        Notify("Blacklist cleared", true)
    end)

    _G.CentuVK_UpdateUI = function()
        toggleBtn.Text = STATE.Running and "■ STOP" or "▶ START"
        toggleBtn.BackgroundColor3 = STATE.Running and Color3.fromRGB(60, 22, 34) or Color3.fromRGB(26, 22, 36)
        tbStk.Color = STATE.Running and Color3.fromRGB(200, 80, 100) or Color3.fromRGB(80, 60, 130)
    end
    _G.CentuVK_UpdateUI()

    toggleBtn.MouseButton1Click:Connect(toggleVK)

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
                    status.TextColor3 = Color3.fromRGB(255, 140, 160)
                else
                    status.Text = STATE.Running and "Scanning..." or "Status: idle"
                    status.TextColor3 = Color3.fromRGB(180, 180, 200)
                end
                stats.Text = string.format("kills: %d | attempts: %d", STATE.Kills or 0, STATE.Attempts or 0)
            end)
        end
    end)

    return sg
end

local gui = buildGUI()

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleVK()
    end
end)

Notify("Centu Void Kill loaded. RightShift to toggle.", true)
print("[Centu Void Kill] loaded. Session: " .. tostring(SESSION))
