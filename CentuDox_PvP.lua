-- CentuDox PvP
-- language: Luau, target: Blox Fruits, executor: Delta
-- UI: Custom Library by IDRIS

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY LOAD
-- ═══════════════════════════════════════════════════════════════

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/IDRIS-vx23/ByteCore/main/Library/Library.lua"
))()

-- ═══════════════════════════════════════════════════════════════
--  PvP CORE
-- ═══════════════════════════════════════════════════════════════

local PvP = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

PvP.Settings = {
    SilentAim        = false,
    AutoCombo        = false,
    ComboDelay       = 0.08,
    AutoSkill        = false,
    AutoSkillDelay   = 0.12,
    AutoBlock        = false,
    FastAttack       = false,
    FastAttackDelay  = 0.02,
    KillAura         = false,
    KillAuraRange    = 25,
    AntiKnockback    = false,
    HitboxExpander   = false,
    HitboxSize       = 10,
    SpeedBoost       = false,
    SpeedValue       = 40,
    NoClip           = false,
    InfStamina       = false,
    TeleportToTarget = false,
    TeleportBehind   = true,
    TeleportKey      = Enum.KeyCode.Q,
    TeamCheck        = true,
    NullCheck        = true,
}

PvP.Target = nil

local _conns     = {}
local _origSizes = {}
local _threads   = {}
local _origSpeed = 16

local function getChar()
    local c = LP.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function isEnemy(p)
    if p == LP then return false end
    if PvP.Settings.NullCheck then
        local c = p.Character
        if not c then return false end
        if not c:FindFirstChild("HumanoidRootPart") then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
    end
    if PvP.Settings.TeamCheck and LP.Team and p.Team == LP.Team then return false end
    return true
end

local function getNearestEnemy(range)
    local _, hrp = getChar()
    if not hrp then return nil, math.huge end
    local best, bestDist = nil, range or math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local c = p.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - hrp.Position).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
    end
    return best, bestDist
end

local function getTargetRoot()
    local t = PvP.Target
    if not t or not t.Character then
        t = getNearestEnemy()
        if t then PvP.Target = t end
    end
    if not t or not t.Character then return nil end
    return t.Character:FindFirstChild("HumanoidRootPart")
end

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(_conns, c)
    return c
end

local function spawnLoop(name, fn)
    if _threads[name] then pcall(task.cancel, _threads[name]) end
    _threads[name] = task.spawn(fn)
end

local function pressKey(keyCode)
    pcall(function()
        local i = Instance.new("InputObject")
        i.KeyCode = keyCode
        i.UserInputType = Enum.UserInputType.Keyboard
        i.UserInputState = Enum.UserInputState.Begin
        UserInputService:ProcessInput(i, false)
    end)
end

-- Silent Aim
local function initSilentAim()
    connect(RunService.RenderStepped, function()
        if not PvP.Settings.SilentAim then return end
        local root = getTargetRoot()
        if not root then return end
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position + Vector3.new(0, 2, 0))
    end)
end

-- Anti-Knockback
local function initAntiKnockback()
    connect(RunService.Heartbeat, function()
        if not PvP.Settings.AntiKnockback then return end
        local _, hrp = getChar()
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

-- Kill Aura
local function initKillAura()
    spawnLoop("killaura", function()
        while true do
            task.wait(0.05)
            if not PvP.Settings.KillAura then continue end
            local enemy = getNearestEnemy(PvP.Settings.KillAuraRange)
            if enemy and enemy.Character then
                local root = enemy.Character:FindFirstChild("HumanoidRootPart")
                if root then pcall(mouse1click) end
            end
        end
    end)
end

-- Auto Block
local function attachAutoBlock()
    local _, _, hum = getChar()
    if not hum then return end
    connect(hum.HealthChanged, function()
        if not PvP.Settings.AutoBlock then return end
        pcall(function()
            for _, name in ipairs({"Block", "StartBlock", "BlockAction", "UseBlock"}) do
                local remote = ReplicatedStorage:FindFirstChild(name, true)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer(true)
                    task.delay(0.25, function() pcall(function() remote:FireServer(false) end) end)
                    break
                end
            end
        end)
    end)
end

-- Fast Attack
local function initFastAttack()
    spawnLoop("fastattack", function()
        while true do
            task.wait(PvP.Settings.FastAttackDelay or 0.02)
            if not PvP.Settings.FastAttack then continue end
            local root = getTargetRoot()
            if not root then continue end
            pcall(function()
                for _, name in ipairs({"M1", "Punch", "Attack", "Combat", "CombatAction"}) do
                    local remote = ReplicatedStorage:FindFirstChild(name, true)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(root.Position)
                        break
                    end
                end
            end)
        end
    end)
end

-- Hitbox Expander
local function applyHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not _origSizes[p.UserId] then
                _origSizes[p.UserId] = hrp.Size
                local s = PvP.Settings.HitboxSize
                hrp.Size = Vector3.new(s, s, s)
            end
        end
    end
end

local function restoreHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and _origSizes[p.UserId] then
                hrp.Size = _origSizes[p.UserId]
                _origSizes[p.UserId] = nil
            end
        end
    end
end

local function initHitboxExpander()
    spawnLoop("hitbox", function()
        while true do
            task.wait(0.1)
            if PvP.Settings.HitboxExpander then applyHitboxes() else restoreHitboxes() end
        end
    end)
end

-- Speed Boost
local function initSpeedBoost()
    connect(RunService.Heartbeat, function()
        local _, _, hum = getChar()
        if not hum then return end
        hum.WalkSpeed = PvP.Settings.SpeedBoost and PvP.Settings.SpeedValue or _origSpeed
    end)
end

-- No Clip
local function initNoClip()
    connect(RunService.Stepped, function()
        if not PvP.Settings.NoClip then return end
        local char = LP.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

-- Inf Stamina
local function initInfStamina()
    connect(RunService.Heartbeat, function()
        if not PvP.Settings.InfStamina then return end
        pcall(function()
            local container = LP:FindFirstChild("Data") or LP:FindFirstChild("Stats")
            if container then
                for _, name in ipairs({"Energy", "Stamina", "Mana", "Ki"}) do
                    local stat = container:FindFirstChild(name)
                    if stat and stat:IsA("NumberValue") then
                        local cap = stat.MaxValue or 9999
                        if stat.Value < cap then stat.Value = cap end
                    end
                end
            end
        end)
    end)
end

-- Teleport to Target
local function initTeleportToTarget()
    connect(UserInputService.InputBegan, function(input, gp)
        if gp or input.KeyCode ~= PvP.Settings.TeleportKey then return end
        if not PvP.Settings.TeleportToTarget then return end
        local _, hrp = getChar()
        local root   = getTargetRoot()
        if not hrp or not root then return end
        local dest = PvP.Settings.TeleportBehind
            and (root.CFrame * CFrame.new(0, 0, 3.5)).Position
            or  (root.CFrame * CFrame.new(0, 5,   0)).Position
        hrp.CFrame = CFrame.new(dest)
    end)
end

-- Auto Combo
local COMBO_SEQ = {
    { type = "m1" },
    { type = "m1" },
    { type = "m1" },
    { type = "skill", key = Enum.KeyCode.Z },
    { type = "m1" },
    { type = "m1" },
    { type = "skill", key = Enum.KeyCode.X },
    { type = "m1" },
    { type = "skill", key = Enum.KeyCode.C },
}

local function initAutoCombo()
    spawnLoop("combo", function()
        while true do
            task.wait(0.05)
            if not PvP.Settings.AutoCombo then continue end
            if not getTargetRoot() then continue end
            for _, step in ipairs(COMBO_SEQ) do
                if not PvP.Settings.AutoCombo then break end
                if step.type == "m1" then pcall(mouse1click)
                elseif step.type == "skill" then pressKey(step.key) end
                task.wait(PvP.Settings.ComboDelay or 0.08)
            end
            task.wait(0.4)
        end
    end)
end

-- Auto Skill
local SKILL_KEYS = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V }

local function initAutoSkill()
    spawnLoop("skill", function()
        while true do
            task.wait(PvP.Settings.AutoSkillDelay or 0.12)
            if not PvP.Settings.AutoSkill then continue end
            if not getTargetRoot() then continue end
            for _, key in ipairs(SKILL_KEYS) do
                if not PvP.Settings.AutoSkill then break end
                pressKey(key)
                task.wait(PvP.Settings.AutoSkillDelay or 0.12)
            end
        end
    end)
end

function PvP.Init()
    local _, _, hum = getChar()
    _origSpeed = hum and hum.WalkSpeed or 16
    initSilentAim(); initAntiKnockback(); initKillAura()
    initFastAttack(); initHitboxExpander(); initSpeedBoost()
    initNoClip(); initInfStamina(); initTeleportToTarget()
    initAutoCombo(); initAutoSkill(); attachAutoBlock()
    LP.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        attachAutoBlock()
    end)
    RunService.Heartbeat:Connect(function()
        local t = PvP.Target
        if not t then return end
        local c = t.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then PvP.Target = nil end
    end)
end

function PvP.Destroy()
    for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    _conns = {}
    for _, thread in pairs(_threads) do pcall(task.cancel, thread) end
    _threads = {}
    restoreHitboxes()
    local _, _, hum = getChar()
    if hum then hum.WalkSpeed = _origSpeed end
    PvP.Target = nil
end

-- ═══════════════════════════════════════════════════════════════
--  UI — using IDRIS's Library
-- ═══════════════════════════════════════════════════════════════

local Window = Library:CreateWindow({ Title = "CentuDox PvP" })

-- ─── Tab: Combat ────────────────────────────────────────────────
local TabCombat = Window:CreateTab("Combat", true)

TabCombat:CreatePageTitle("Combat")
TabCombat:CreatePageSubTitle("Aim & Attack")

TabCombat:CreateSwitch("Silent Aim", false,
    "Locks camera toward the nearest enemy when firing",
    function(v) PvP.Settings.SilentAim = v end, "SilentAim")

TabCombat:CreateSwitch("Kill Aura", false,
    "Automatically clicks on the nearest enemy in range",
    function(v) PvP.Settings.KillAura = v end, "KillAura")

TabCombat:CreateSlider("Kill Aura Range", 5, 60, 25,
    "Detection radius in studs",
    function(v) PvP.Settings.KillAuraRange = v end, "KillAuraRange")

TabCombat:CreateSwitch("Fast Attack", false,
    "Fires M1 remote faster than the animation lock allows",
    function(v) PvP.Settings.FastAttack = v end, "FastAttack")

TabCombat:CreateSwitch("Auto Combo", false,
    "Executes M1 + skill sequence automatically",
    function(v) PvP.Settings.AutoCombo = v end, "AutoCombo")

TabCombat:CreateSlider("Combo Delay (ms)", 30, 300, 80,
    "Delay between each combo step in milliseconds",
    function(v) PvP.Settings.ComboDelay = v / 1000 end, "ComboDelay")

TabCombat:CreateSwitch("Auto Skill", false,
    "Cycles Z/X/C/V skills automatically",
    function(v) PvP.Settings.AutoSkill = v end, "AutoSkill")

TabCombat:CreatePageSubTitle("Defense")

TabCombat:CreateSwitch("Auto Block", false,
    "Triggers block remote when taking damage",
    function(v) PvP.Settings.AutoBlock = v end, "AutoBlock")

TabCombat:CreateSwitch("Anti-Knockback", false,
    "Zeroes velocity every frame so hits cannot move you",
    function(v) PvP.Settings.AntiKnockback = v end, "AntiKnockback")

TabCombat:CreatePageSubTitle("Hitbox")

TabCombat:CreateSwitch("Hitbox Expander", false,
    "Inflates enemy HRP so M1 registers from farther away",
    function(v) PvP.Settings.HitboxExpander = v end, "HitboxExpander")

TabCombat:CreateSlider("Hitbox Size", 5, 50, 10,
    "Size of expanded hitbox in studs",
    function(v) PvP.Settings.HitboxSize = v end, "HitboxSize")

-- ─── Tab: Movement ───────────────────────────────────────────────
local TabMove = Window:CreateTab("Movement", false)

TabMove:CreatePageTitle("Movement")
TabMove:CreatePageSubTitle("Speed")

TabMove:CreateSwitch("Speed Boost", false,
    "Overrides WalkSpeed to the value below",
    function(v) PvP.Settings.SpeedBoost = v end, "SpeedBoost")

TabMove:CreateSlider("Walk Speed", 16, 150, 40,
    "Movement speed value",
    function(v) PvP.Settings.SpeedValue = v end, "SpeedValue")

TabMove:CreatePageSubTitle("Mobility")

TabMove:CreateSwitch("No Clip", false,
    "Disables collision on your character",
    function(v) PvP.Settings.NoClip = v end, "NoClip")

TabMove:CreateSwitch("Inf Stamina", false,
    "Keeps energy/stamina at maximum every frame",
    function(v) PvP.Settings.InfStamina = v end, "InfStamina")

TabMove:CreatePageSubTitle("Teleport")

TabMove:CreateSwitch("Teleport to Target", false,
    "Press the keybind below to teleport to your target",
    function(v) PvP.Settings.TeleportToTarget = v end, "TeleportToTarget")

TabMove:CreateSwitch("Teleport Behind", true,
    "ON = behind target, OFF = above target",
    function(v) PvP.Settings.TeleportBehind = v end, "TeleportBehind")

TabMove:CreateDropdown("Teleport Key", "Q",
    {"Q","E","R","F","G","T","Y","H","J","Z","X","C","V","B","N","M"},
    "Keybind to trigger teleport",
    function(v)
        local k = Enum.KeyCode[v]
        if k then PvP.Settings.TeleportKey = k end
    end, "TeleportKey")

-- ─── Tab: Target ────────────────────────────────────────────────
local TabTarget = Window:CreateTab("Target", false)

TabTarget:CreatePageTitle("Target")
TabTarget:CreatePageSubTitle("Select")

local function getPlayerList()
    local list = {"Auto (Nearest)"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

TabTarget:CreateDropdown("Target Player", "Auto (Nearest)",
    getPlayerList(), "Select a player to lock on to",
    function(v)
        if v == "Auto (Nearest)" then
            PvP.Target = nil
        else
            local p = Players:FindFirstChild(v)
            PvP.Target = p or nil
            Library:SendNotification("Target Set",
                p and ("Locked onto " .. v) or "Player not found")
        end
    end, "TargetPlayer")

TabTarget:CreateButton("Auto Target Nearest", "Lock onto the closest enemy right now",
    function()
        local nearest = getNearestEnemy()
        if nearest then
            PvP.Target = nearest
            Library:SendNotification("Target Set", "Locked onto " .. nearest.Name)
        else
            Library:SendNotification("No Target", "No enemies nearby")
        end
    end)

TabTarget:CreateButton("Clear Target", "Remove current lock, revert to auto-nearest",
    function()
        PvP.Target = nil
        Library:SendNotification("Target Cleared", "Auto-nearest active")
    end)

TabTarget:CreatePageSubTitle("Filters")

TabTarget:CreateSwitch("Skip Teammates", true,
    "Do not target players on the same team",
    function(v) PvP.Settings.TeamCheck = v end, "TeamCheck")

-- ─── Init ────────────────────────────────────────────────────────
PvP.Init()
Library:SendNotification("CentuDox PvP", "All systems loaded and ready.")
