local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false,
    Destination = "Void",
    MinLevel = 0,
    MaxDist = 500,
    GrabRange = 20,
    GrabDelay = 0.2,
    ResetDelay = 0.5,
    Cooldown = 1.5,
    TeamCheck = true,
}

local DESTINATIONS = {
    Void = Vector3.new(0, -5000, 0),
    Lava = Vector3.new(5514, 30, -5000),
    Water = Vector3.new(0, -20, 0),
}

local STATE = {
    Running = false,
    Target = nil,
    LastKill = 0,
    Kills = 0,
    Attempts = 0,
    Resetting = false,
    ResetAt = 0,
}

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Dragon Talon Drag",
            Text = tostring(text),
            Duration = 3,
        })
    end)
    print("[DT-Drag] " .. tostring(text))
end

local function getLevel(p)
    local d = p:FindFirstChild("Data")
    if d and d:FindFirstChild("Level") then return tonumber(d.Level.Value) or 0 end
    local ls = p:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Level") then return tonumber(ls.Level.Value) or 0 end
    return 0
end

local function isEnemy(p)
    if not p or p == LocalPlayer then return false end
    if Settings.TeamCheck then
        if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
            return false
        end
    end
    return true
end

local function hasDragonTalon()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local n = tool.Name:lower()
        if n:find("dragon") and n:find("talon") then return true end
    end
    return false
end

local function equipDragonTalon()
    if hasDragonTalon() then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local pool = {}
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then table.insert(pool, t) end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(pool, t) end
        end
    end

    for _, t in ipairs(pool) do
        local n = t.Name:lower()
        if n:find("dragon") and n:find("talon") then
            pcall(function() hum:EquipTool(t) end)
            task.wait(0.15)
            return hasDragonTalon()
        end
    end
    return false
end

local function fireZ()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end)
end

local function killSelf()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        pcall(function() hum.Health = 0 end)
    end
end

local function teleportBothTo(destPos)
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local target = STATE.Target
    if not myHrp or not target or not target.Character then return false end

    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHrp then return false end

    local voidCF = CFrame.new(myHrp.Position.X, destPos.Y, myHrp.Position.Z)

    pcall(function()
        myHrp.CFrame = voidCF
        myHrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
        myHrp.AssemblyAngularVelocity = Vector3.zero
    end)

    pcall(function()
        tHrp.CFrame = CFrame.new(tHrp.Position.X, destPos.Y, tHrp.Position.Z)
        tHrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
        tHrp.AssemblyAngularVelocity = Vector3.zero
    end)

    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0, -999, 0)
        bv.Parent = myHrp
        task.delay(0.5, function() if bv.Parent then bv:Destroy() end end)
    end)

    pcall(function()
        local bv2 = Instance.new("BodyVelocity")
        bv2.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv2.Velocity = Vector3.new(0, -999, 0)
        bv2.Parent = tHrp
        task.delay(0.5, function() if bv2.Parent then bv2:Destroy() end end)
    end)

    return true
end

local function tryKill()
    local target = STATE.Target
    if not target or not target.Character then return false end

    local now = tick()
    if now - STATE.LastKill < Settings.Cooldown then return false end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHum or myHum.Health <= 0 then return false end

    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
    if not tHrp or not tHum or tHum.Health <= 0 then return false end

    local dist = (tHrp.Position - myHrp.Position).Magnitude
    if dist > Settings.GrabRange then return false end

    if not equipDragonTalon() then
        notify("Dragon Talon not found!")
        return false
    end

    STATE.LastKill = now
    STATE.Attempts = STATE.Attempts + 1

    fireZ()

    task.delay(Settings.GrabDelay, function()
        local dest = DESTINATIONS[Settings.Destination] or DESTINATIONS.Void
        pcall(teleportBothTo, dest)
    end)

    task.delay(Settings.ResetDelay, function()
        STATE.Resetting = true
        STATE.ResetAt = tick()
        killSelf()
        STATE.Kills = STATE.Kills + 1
        notify("Dragged " .. target.Name .. " to " .. Settings.Destination)
    end)

    return true
end

local function findTarget()
    local best, bestDist = nil, math.huge
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local lvl = getLevel(p)
                if lvl >= Settings.MinLevel then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < Settings.MaxDist and dist < bestDist then
                        best, bestDist = p, dist
                    end
                end
            end
        end
    end
    return best
end

local function mainLoop()
    if not STATE.Running then return end

    local char = LocalPlayer.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHum or myHum.Health <= 0 then return end

    if STATE.Resetting then
        if tick() - STATE.ResetAt > 2 then
            STATE.Resetting = false
        end
        return
    end

    if not STATE.Target or not STATE.Target.Character then
        STATE.Target = findTarget()
    end

    local t = STATE.Target
    if not t or not t.Character then return end

    local tHrp = t.Character:FindFirstChild("HumanoidRootPart")
    local tHum = t.Character:FindFirstChildOfClass("Humanoid")
    if not tHrp or not tHum or tHum.Health <= 0 then
        STATE.Target = nil
        return
    end

    local dist = (tHrp.Position - myHrp.Position).Magnitude

    if dist > Settings.GrabRange then
        local speed = dist > 100 and 200 or 100
        local dir = (tHrp.Position - myHrp.Position).Unit
        local newPos = myHrp.Position + dir * math.min(speed * 0.03, dist - 5)
        pcall(function()
            myHrp.CFrame = CFrame.new(newPos, tHrp.Position)
        end)
    else
        tryKill()
    end
end

RunService.Heartbeat:Connect(function()
    pcall(mainLoop)
end)

local function getSafeParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local sg = Instance.new("ScreenGui")
sg.Name = "DTDrag_GUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = getSafeParent()

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 20, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(14, 12, 18)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stk = Instance.new("UIStroke", frame)
stk.Color = Color3.fromRGB(200, 80, 100)
stk.Thickness = 1.4

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "DRAGON TALON DRAG"
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(255, 160, 180)
title.TextXAlignment = Enum.TextXAlignment.Left

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.BackgroundColor3 = Color3.fromRGB(26, 22, 36)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.TextColor3 = Color3.fromRGB(240, 240, 255)
toggle.Text = "▶ START"
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local destLabel = Instance.new("TextLabel", frame)
destLabel.Size = UDim2.new(1, -20, 0, 14)
destLabel.Position = UDim2.new(0, 10, 0, 90)
destLabel.BackgroundTransparency = 1
destLabel.Font = Enum.Font.GothamBold
destLabel.TextSize = 9.5
destLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
destLabel.TextXAlignment = Enum.TextXAlignment.Left
destLabel.Text = "DESTINATION"

local destBtns = {}
local destinations = {"Void", "Lava", "Water"}
for i, name in ipairs(destinations) do
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.33, -8, 0, 30)
    b.Position = UDim2.new(0, 10 + (i - 1) * 80, 0, 106)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Text = name
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    destBtns[name] = b

    b.MouseButton1Click:Connect(function()
        Settings.Destination = name
        for n, btn in pairs(destBtns) do
            if n == name then
                btn.BackgroundColor3 = Color3.fromRGB(70, 24, 40)
                btn.TextColor3 = Color3.fromRGB(255, 200, 210)
            else
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
                btn.TextColor3 = Color3.fromRGB(200, 200, 220)
            end
        end
    end)
end
destBtns.Void.BackgroundColor3 = Color3.fromRGB(70, 24, 40)
destBtns.Void.TextColor3 = Color3.fromRGB(255, 200, 210)

local stats = Instance.new("TextLabel", frame)
stats.Size = UDim2.new(1, -20, 0, 40)
stats.Position = UDim2.new(0, 10, 0, 150)
stats.BackgroundTransparency = 1
stats.Font = Enum.Font.Gotham
stats.TextSize = 11
stats.TextColor3 = Color3.fromRGB(180, 180, 200)
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Text = "Kills: 0 | Attempts: 0\nTarget: none"

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -20, 0, 30)
info.Position = UDim2.new(0, 10, 0, 200)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextColor3 = Color3.fromRGB(120, 120, 140)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Text = "RightShift to toggle"

toggle.MouseButton1Click:Connect(function()
    STATE.Running = not STATE.Running
    if STATE.Running then
        STATE.Target = nil
        STATE.Kills = 0
        STATE.Attempts = 0
        toggle.Text = "■ STOP"
        toggle.BackgroundColor3 = Color3.fromRGB(60, 22, 34)
    else
        toggle.Text = "▶ START"
        toggle.BackgroundColor3 = Color3.fromRGB(26, 22, 36)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggle.MouseButton1Click:Fire()
    end
end)

task.spawn(function()
    while sg.Parent do
        task.wait(0.3)
        pcall(function()
            local t = STATE.Target
            local name = t and (t.DisplayName or t.Name) or "none"
            stats.Text = string.format("Kills: %d | Attempts: %d\nTarget: %s | Dest: %s",
                STATE.Kills, STATE.Attempts, name, Settings.Destination)
        end)
    end
end)

notify("Loaded. RightShift to toggle.")
