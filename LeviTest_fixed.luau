Services = setmetatable({}, {__index = function(self, name)
    local s, c = pcall(function() return cloneref(game:GetService(name)) end)
    if s then rawset(self, name, c) return c
    else error("Invalid Roblox Service: " .. tostring(name)) end
end})
Players = Services.Players
LP = Players.LocalPlayer
ReplicatedStorage = Services.ReplicatedStorage
RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")
Lighting = game:GetService("Lighting")
VirtualInputManager = game:GetService("VirtualInputManager")
VirtualUser = game:GetService("VirtualUser")
Workspace = workspace
Camera = workspace.CurrentCamera
local MapFolder = Workspace:WaitForChild("Map", 5)
local _WaterBasePlane = MapFolder and MapFolder:FindFirstChild("WaterBase-Plane")

_G.ChonPhe = "Marines"
_G.BatNoclip = true
_G.TocDoTween = 170
_G.TocDoTweenBoat = 250
_G.XoaSuongMu = true
_G.NguoiMuaThuyen = LP.Name
_G.SoNguoiCanThiet = 5
_G.ChieuCaoBay = 20
_G.DangSan = false
_G.ChoPhepDiChuyen = false
_G.TenThuyen = "Beast Hunter"
_G.SpinPosition = true
_G.SelectedWeapon = "Melee"
_G.UseGunEvent = false
_G.UseM1FruitEvent = false
_G.EnableIgnoreIsland = true
_G.EnableIgnoreSeaEvent = true
_G.IgnoreHeight = 500
_G.IgnoreIslandHeight = 800
_G.SelectedEvents = {"Leviathan"}
_G.SelectedMelee = {"Z", "X", "C"}
_G.SelectedFruit = {"Z", "X", "C", "F"}
_G.SelectedGun = {"Z", "X"}
_G.SelectedScrolls = {}
_G.AutoCraftScrollSwitch = false
_G.SelectedSword = {"Z", "X"}
_G.ShootHeart = false
_G.DestroyIDK = false
_G.AutoRandomFruit = true
_G.AutoStoreFruit = true
_G.PullYHeight = 35
_G.SpyCheckResult = -1
_G.FoundLeviathanGate = false
_G.LastHRPPosition = nil
_G.DriveToTiki = false
_G.DriveToHydra = false
_G.DangKeoTim = false
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local spycheck = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("InfoLeviathan", "1")
            if spycheck then
                _G.SpyCheckResult = spycheck
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(30000) do
        pcall(function()
            if _G.SpyCheckResult ~= 5 and _G.SpyCheckResult > -1 then
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("InfoLeviathan", "2")
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local mapFolder = workspace:FindFirstChild("Map") or workspace:WaitForChild("Map", 5)
            if mapFolder then
                local waterPlane = mapFolder:FindFirstChild("WaterBase-Plane")
                if waterPlane and waterPlane.Size ~= Vector3.new(1000, 112, 1000) then
                    waterPlane.Size = Vector3.new(1000, 112, 1000)
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", _G.ChonPhe)
            end)
        end
    end
end)

repeat
    task.wait(0.5)
until LP.Team ~= nil and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")


local Themes = {
    ["Dark"] = {
        Background = Color3.fromRGB(15, 15, 15),
        Darker = Color3.fromRGB(8, 8, 8),
        ContainerBg = Color3.fromHex("#525252"),
        ContainerTrans = 0.6,
        PillBack = Color3.fromRGB(20, 25, 30),
        Text = Color3.fromHex("#FFFFFF"),
        TextDim = Color3.fromHex("#808080"),
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(130, 255, 100),
        Active = Color3.fromHex("#888888"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#808080")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#D3D3D3")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#000000"))
        }),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8A8A8A")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#1A1A1A")) 
        }),
        RowStroke = Color3.fromHex("#FFFFFF"),
        RowStrokeGrad = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#555555")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#54626F")) 
        }),
        StrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(20, 20, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(20, 20, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
    },


    ["Dream"] = {
        Background = Color3.fromHex("#0A1428"),
        Darker = Color3.fromHex("#050A14"),
        ContainerBg = Color3.fromHex("#151C3B"),
        ContainerTrans = 0.5,
        PillBack = Color3.fromHex("#0D162C"),
        Text = Color3.fromHex("#E6FFFF"),
        TextDim = Color3.fromHex("#FFFFFF"),
        Red = Color3.fromHex("#FF3C3C"),
        Green = Color3.fromHex("#82FF64"),
        Active = Color3.fromHex("#8C64FF"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#B4FFFF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#A08CFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        }),
        RowStroke = Color3.fromHex("#808080"),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        StrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        })
    },
["Candy"] = {
		Background = Color3.fromHex("#1C0F14"),
		Darker = Color3.fromHex("#12090D"),
		ContainerBg = Color3.fromHex("#331822"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#26111A"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#F2B8CA"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#C8A2C8"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#C8A2C8"))
		})
	},
	["Lavender"] = {
		Background = Color3.fromHex("#14101A"),
		Darker = Color3.fromHex("#0D0A12"),
		ContainerBg = Color3.fromHex("#251D30"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#1B1524"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#D8C8EA"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#9966CC"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#8A2BE2"))
		})
	},



	["Sky"] = {
		Background = Color3.fromHex("#0F161C"),
		Darker = Color3.fromHex("#090E12"),
		ContainerBg = Color3.fromHex("#1B2733"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#141D26"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#C2E2F5"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#5B9BD5"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#4A90E2"))
		})
	},



	["Luxury"] = {
		Background = Color3.fromHex("#1A1712"),
		Darker = Color3.fromHex("#100E0A"),
		ContainerBg = Color3.fromHex("#302A20"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#221E16"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#EAE0C8"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#D4AC0D"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#B7950B"))
		})
	},



	["Mint"] = {
		Background = Color3.fromHex("#0F1A17"),
		Darker = Color3.fromHex("#09100E"),
		ContainerBg = Color3.fromHex("#1B302B"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#142420"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#C2EAE2"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#329D9C"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#205072"))
		})
	},
}

local CurrentThemeName = "Dark"
local Theme = Themes[CurrentThemeName]
local UI_Elements = {
    Backgrounds = {},
    ContainerBgs = {},
    PillBacks = {},
    Texts = {},
    TextDims = {},
    RowStrokes = {},
    DarkerStrokes = {},
    TextGrads = {},
    ContrastGrads = {},
    RowStrokeGrads = {},
    MainStrokeGrads = {}
}
local StrokeGradients = {}
local AnimatedGradients = {}
local ValueLabels = {}



local function ChangeTheme(themeName)
    if not Themes[themeName] or CurrentThemeName == themeName then return end
    CurrentThemeName = themeName
    local newT = Themes[themeName]
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applySpatialWave(obj, tweenProps, directProps)
        local guiObj = obj
        if not guiObj:IsA("GuiObject") then
            guiObj = guiObj.Parent
        end

        local delayTime = 0
        if guiObj and guiObj:IsA("GuiObject") then
            local posX = guiObj.AbsolutePosition.X
            local posY = guiObj.AbsolutePosition.Y
            delayTime = (posX + posY) / 3500 
        end

        task.delay(delayTime, function()
            if tweenProps then
                TweenService:Create(obj, tweenInfo, tweenProps):Play()
            end
            if directProps then
                for k, v in pairs(directProps) do
                    obj[k] = v
                end
            end
        end)
    end

    for _, obj in pairs(UI_Elements.Backgrounds) do applySpatialWave(obj, {BackgroundColor3 = newT.Background}) end
    for _, obj in pairs(UI_Elements.ContainerBgs) do applySpatialWave(obj, {BackgroundColor3 = newT.ContainerBg, BackgroundTransparency = newT.ContainerTrans}) end
    for _, obj in pairs(UI_Elements.PillBacks) do applySpatialWave(obj, {BackgroundColor3 = newT.PillBack}) end
    for _, obj in pairs(UI_Elements.Texts) do applySpatialWave(obj, {TextColor3 = newT.Text}) end
    for _, obj in pairs(UI_Elements.TextDims) do applySpatialWave(obj, {TextColor3 = newT.TextDim}) end
    for _, obj in pairs(UI_Elements.RowStrokes) do applySpatialWave(obj, {Color = newT.RowStroke}) end
    for _, obj in pairs(UI_Elements.DarkerStrokes) do applySpatialWave(obj, {Color = newT.Darker}) end

    for _, grad in pairs(UI_Elements.TextGrads) do applySpatialWave(grad, nil, {Color = newT.TextGrad}) end
    for _, grad in pairs(UI_Elements.ContrastGrads) do applySpatialWave(grad, nil, {Color = newT.TextContrast}) end
    for _, grad in pairs(UI_Elements.RowStrokeGrads) do applySpatialWave(grad, nil, {Color = newT.RowStrokeGrad}) end
    for _, grad in pairs(UI_Elements.MainStrokeGrads) do applySpatialWave(grad, nil, {Color = newT.StrokeGrad}) end
end


-- Open button (ImageButton) — opens CentuLibrary window on click
local _OpenGui = Instance.new("ScreenGui")
_OpenGui.Name = "CentuKaitunOpenBtn"
_OpenGui.ResetOnSpawn = false
_OpenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() _OpenGui.Parent = gethui() end)
if not _OpenGui.Parent then
    pcall(function() _OpenGui.Parent = game:GetService("CoreGui") end)
end

local _OpenBtn = Instance.new("ImageButton")
_OpenBtn.Name = "OpenBtn"
_OpenBtn.Size = UDim2.fromOffset(60, 60)
_OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
_OpenBtn.BackgroundTransparency = 1
_OpenBtn.Image = "rbxassetid://123438604306607"
_OpenBtn.ScaleType = Enum.ScaleType.Fit
_OpenBtn.Parent = _OpenGui

-- Rounded corner on button
local _btnCorner = Instance.new("UICorner")
_btnCorner.CornerRadius = UDim.new(0.2, 0)
_btnCorner.Parent = _OpenBtn

-- Draggable
local _dragging, _dragStart, _startPos = false, nil, nil
_OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        _dragging = true
        _dragStart = input.Position
        _startPos  = _OpenBtn.Position
    end
end)
_OpenBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        _dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if _dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - _dragStart
        _OpenBtn.Position = UDim2.new(
            _startPos.X.Scale, _startPos.X.Offset + delta.X,
            _startPos.Y.Scale, _startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle visibility of CentuLibrary window on click
local _windowVisible = true
_OpenBtn.MouseButton1Click:Connect(function()
    _windowVisible = not _windowVisible
    if Window then
        pcall(function()
            Window:SetVisible(_windowVisible)
        end)
        pcall(function()
            -- fallback: some Fluent builds use this
            if Window.Gui then Window.Gui.Enabled = _windowVisible end
        end)
    end
end)

-- Stub: keep Meyy6Race_API so existing SetTask/SetTheme calls don't error
getgenv().Meyy6Race_API = {
    SetValue = function() end,
    SetTask  = function() end,
    SetTheme = function() end,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemReplicationService = require(ReplicatedStorage:WaitForChild("ItemReplicationService"))
local KEYS = require(ReplicatedStorage.ItemReplicationService.KEYS)
local ItemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))

while ItemReplicationService.IsInitialized ~= true do
    task.wait()
end



local function getItemName(itemId)
    local ok, name = pcall(function()
        return ItemConfig.match(itemId):unwrap().Index.DebugLabel
    end)
    if ok and name then
        return name
    end
    return "Unknown_" .. tostring(itemId)
end


local function GetIdItem(targetName)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if not quantityItems then return nil end

    local targetClean = string.lower(string.gsub(targetName, "%s+", ""))

    for _, item in pairs(quantityItems) do
        local rawName = getItemName(item.ItemId)
        local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
        local cleanMatch = string.lower(string.gsub(cleanName, "%s+", ""))

        if cleanMatch == targetClean then
            if string.find(rawName, "%[Material%-") or not string.find(rawName, "%[Accessory%-") then
                return item.ItemId
            end
        end
    end

    for _, item in pairs(quantityItems) do
        local rawName = getItemName(item.ItemId)
        if string.find(rawName, "%[Material%-") then
            local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
            local cleanMatch = string.lower(string.gsub(cleanName, "%s+", ""))
            if string.find(cleanMatch, targetClean, 1, true) then
                return item.ItemId
            end
        end
    end

    return nil
end



local function getItemCount(targetItemId)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if quantityItems then
        for _, item in pairs(quantityItems) do
            if item.ItemId == targetItemId then
                return item.Value or 0
            end
        end
    end
    return 0
end



local function CountItem(ItemName)
    local itemId = GetIdItem(ItemName)
    if itemId then
        return getItemCount(itemId)
    else
        return 0
    end
end


task.spawn(function()
    local itemsToCheck = {
        "Fool's Gold",
        "Shark Tooth",
        "Electric Wing",
        "Mutant Tooth",
        "Terror Eyes"
    }
    
    local lastCounts = {}
    
    while task.wait(0.5) do
        for _, itemName in ipairs(itemsToCheck) do
            local currentCount = CountItem(itemName)
            
            if lastCounts[itemName] == nil or currentCount ~= lastCounts[itemName] then
                lastCounts[itemName] = currentCount
                                
                if getgenv().Meyy6Race_API and getgenv().Meyy6Race_API.SetValue then
                    local targetName = itemName
                    local targetCount = currentCount
                    task.defer(function()
                        getgenv().Meyy6Race_API.SetValue(targetName, targetCount)
                    end)
                end
            end
        end
    end
end)

getgenv().CurrentTarget = nil
getgenv().CurrentTargetPart = nil
getgenv().MacroAimPos = nil

getgenv().IsPureM1 = false
getgenv().UseOnlyGunSkill = false

getgenv().currentEquippedGun = nil

local function checkEquippedGun()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then
        return nil
    end

    local equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool then
        return equippedTool.Name
    else
        return nil
    end
end

task.spawn(function()
    while task.wait(0.1) do
        getgenv().currentEquippedGun = checkEquippedGun()
    end
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/45hCw1JE/raw"))()
    end)
end)

repeat
    task.wait(0.5)
until LP.Team ~= nil and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")



-- ================================================================
-- CENTU LIBRARY — UI FOR KAITUN LEVI
-- ================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/idrisvale-dev/Scripts/refs/heads/master/Library/CentuLibrary.luau"))()

local Window = Library:CreateWindow({
    Title = "Centu Kaitun Levi",
    Theme = "Dark",
})

-- ── Helpers ───────────────────────────────────────────────────
local function MultiCb(val)         -- CentuLibrary already returns a plain array; passthrough
    return type(val) == "table" and val or {}
end

-- ================================================================
-- TAB 1 — HUNT LEVIATHAN
-- ================================================================

local W = 0
local lastChange = tick()

local function RoundVector3Down(vec)
    return Vector3.new(math.floor(vec.X), math.floor(vec.Y), math.floor(vec.Z))
end

local function CaculateCircreDirection(PositionCFrame, distanceY, radius)
    radius = radius or 25
    if W > 50000 then W = 60000 end
    W = W + ((tick() - lastChange) > 0.4 and 80 or 0)
    if tick() - lastChange > 0.4 then lastChange = tick() end
    local TargetPosition = PositionCFrame.Position + Vector3.new(math.cos(math.rad(W)) * radius, distanceY, math.sin(math.rad(W)) * radius)
    return CFrame.new(RoundVector3Down(TargetPosition))
end

local function EquipGun(gunName)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetPart = getgenv().CurrentTargetPart

    if hrp and targetPart then
        local myPos = hrp.Position
        local targetPos = targetPart.Position
        local distXZ = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude

        if distXZ > 200 then
            return 
        end
    end

    if not gunName then return end
    
    local char = LP.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if char:FindFirstChild(gunName) then
        return
    end

    local toolInBackpack = LP.Backpack:FindFirstChild(gunName)
    if toolInBackpack and toolInBackpack:IsA("Tool") then
        humanoid:EquipTool(toolInBackpack)
        return
    end

    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadItem", gunName)
end


local function equip(typeCheck)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        while true do
            local tooClose = false
            local boats = workspace:FindFirstChild("Boats")
            if boats then
                for _, boat in pairs(boats:GetChildren()) do
                    for _, part in pairs(boat:GetDescendants()) do
                        if part:IsA("VehicleSeat") or part:IsA("Seat") then
                            if (part.Position - hrp.Position).Magnitude <= 20 then
                                tooClose = true
                                break
                            end
                        end
                    end
                    if tooClose then break end
                end
            end
            
            if not tooClose then
                break
            end
            task.wait(0.1)
        end
    end

    local tooltipToFind = typeCheck
    if typeCheck == "Fruit" then tooltipToFind = "Blox Fruit" end
    
    for _, item in pairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == tooltipToFind then
            local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid:IsDescendantOf(item) then
                humanoid:EquipTool(item)
                return item.Name
            end
        end
    end
    for _, item in pairs(LP.Character:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == tooltipToFind then
            return item.Name
        end
    end
    return nil
end

local function GetNearestSeaEvent()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil end

    local target = nil
    local minDist = 2000
    local eventType = nil
    local targetPosition = nil

   local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        local isFishBoatAlive = false
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name:find("FishBoat") then
                local healthVal = mob:FindFirstChild("Health")
                if healthVal and healthVal.Value > 0 then
                    isFishBoatAlive = true
                    break
                end
            end
        end

        for _, mob in ipairs(enemies:GetChildren()) do
            local n = mob.Name
            local mobPos = nil
            local isValid = false
            local eType = nil

            if n:find("Piranha") or n:find("Terrorshark") or n:find("Shark") or n:find("Fish Crew Member") then
                local hum = mob:FindFirstChild("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    mobPos = root.Position
                    if n:find("Piranha") and table.find(_G.SelectedEvents, "Piranha") then isValid = true; eType = "M1"
                    elseif n:find("Terrorshark") and table.find(_G.SelectedEvents, "Terrorshark") then isValid = true; eType = "M1"
                    elseif n:find("Shark") and table.find(_G.SelectedEvents, "Shark") then isValid = true; eType = "M1"
                    elseif n:find("Fish Crew Member") and table.find(_G.SelectedEvents, "FishBoat") then
                        if not isFishBoatAlive then
                            isValid = true; eType = "M1"
                        end
                    end
                end
            elseif n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("FishBoat") then
                local healthVal = mob:FindFirstChild("Health")
                if healthVal and healthVal.Value > 0 then
                    mobPos = mob:GetPivot().Position
                    if n:find("PirateGrandBrigade") then
                        if table.find(_G.SelectedEvents, "PirateGrandBrigade") then isValid = true; eType = "Skill" end
                    elseif n:find("PirateBrigade") then
                        if table.find(_G.SelectedEvents, "PirateBrigade") then isValid = true; eType = "Skill" end
                    elseif n:find("FishBoat") then
                        if table.find(_G.SelectedEvents, "FishBoat") then isValid = true; eType = "Skill" end
                    end
                end
            end

            if isValid and mobPos then
                local dist = (mobPos - hrp.Position).Magnitude
                if dist <= minDist then
                    minDist = dist
                    target = mob
                    eventType = eType
                    targetPosition = mobPos
                end
            end
        end
    end


	if workspace:FindFirstChild("SeaBeasts") then
		local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
		local segmentFound = false

		for _, mob in ipairs(seaBeastsFolder:GetChildren()) do
			if mob.Name == "Leviathan Segment" then
				local isAlive = false
				local success, health = pcall(function()
					local healthObj = mob:FindFirstChild("Health")
					if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "IntConstrainedValue") then
						return healthObj.Value
					end
					return mob:FindFirstChild("Humanoid").Health
				end)

				local mobRoot = mob:FindFirstChild("HumanoidRootPart")
				if mobRoot then
					if success and health > 0 then
						isAlive = true
					elseif not success then
						isAlive = true
					end
				end

				if isAlive then
					segmentFound = true
					break
				end
			end
		end

		for _, mob in ipairs(seaBeastsFolder:GetChildren()) do
			if mob.Name:find("SeaBeast1") or mob.Name == "Leviathan Segment" or mob.Name == "Leviathan" then
				local isAlive = false
				local success, health = pcall(function()
					local healthObj = mob:FindFirstChild("Health")
					if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "IntConstrainedValue") then
						return healthObj.Value
					end
					return mob:FindFirstChild("Humanoid").Health
				end)

				local mobRoot = mob:FindFirstChild("HumanoidRootPart")
				if mobRoot then
					if success and health > 0 then
						isAlive = true
					elseif not success then
						isAlive = true
					end
				end

				if isAlive and mobRoot then
					local mobPos = mobRoot.Position

					local isLevi = (mob.Name == "Leviathan Segment" or mob.Name == "Leviathan")
					local isSB = mob.Name:find("SeaBeast1")
					
					local canAttack = false
					if isLevi and table.find(_G.SelectedEvents, "Leviathan") then canAttack = true end
					if isSB and table.find(_G.SelectedEvents, "Sea Beast") then canAttack = true end

					if canAttack then
						if mob.Name == "Leviathan" and segmentFound then
							continue
						end

						local dist = (mobPos - hrp.Position).Magnitude
						if dist <= minDist or mob.Name == "Leviathan Segment" or mob.Name == "Leviathan" then
							minDist = dist
							target = mob
							eventType = "SeaBeast"
							targetPosition = mobPos
						end
					end
				end
			end
		end
	end



    return target, eventType, targetPosition
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local FOLDER_NAME = "Meyy_Leviathan_Kaitun"
local FILE_NAME = FOLDER_NAME .. "/Name.json"
local API_URL = "https://multi-api-web.onrender.com/api/leviathan" 
local SECRET_KEY = "iemnacutez.19.09.2011"

local function getHash(str)
    if syn and syn.crypt and syn.crypt.hash then return syn.crypt.hash(str, "sha256") end
    if crypt and crypt.hash then return crypt.hash(str, "sha256") end
    return "" -- Fallback nếu executor hông hỗ trợ hash
end

local function requestAPI(method, bodyInfo)
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if not req then return false, nil end
    
    local groupId = tostring(_G.NguoiMuaThuyen)
    local timestamp = math.floor(os.time())
    
    local dataToHash = tostring(timestamp) .. groupId
    if method == "POST" and bodyInfo then
        dataToHash = dataToHash .. tostring(bodyInfo.Name or "")
    end
    
    local signature = getHash(dataToHash .. SECRET_KEY)
    
    local success, res = pcall(function()
        return req({
            Url = API_URL,
            Method = method,
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-group"] = groupId,
                ["x-timestamp"] = tostring(timestamp),
                ["x-signature"] = signature
            },
            Body = bodyInfo and HttpService:JSONEncode(bodyInfo) or nil
        })
    end)
    if success and res and type(res) == "table" and res.StatusCode == 200 then
        local s, d = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if s and d then return true, d end
    end
    return false, nil
end

local function ReadJSONFile(path)
    if isfile and isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success and type(result) == "table" then
            return result
        end
    end
    return nil
end

local function WriteJSONFile(path, data)
    if writefile then
        pcall(function()
            writefile(path, HttpService:JSONEncode(data))
        end)
    end
end

getgenv().FetchUnifiedPartyData = function()
    local success, apiData = requestAPI("GET")
    if success and apiData then return apiData end
    return ReadJSONFile(FILE_NAME)
end

local function ManagePartyDatabase()
    if not makefolder or not isfolder or not writefile or not readfile then return end
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end

    local currentTime = os.time()
    local myName = LP.Name
    local myIDK = (_G.SpyCheckResult == -1)
    
    -- 1. Ưu tiên gửi Web API trước để đồng bộ liên máy
    local apiSuccess, finalApiData = requestAPI("POST", {Name = myName, LastTime = currentTime, IDK = myIDK})
    if apiSuccess and finalApiData then
        WriteJSONFile(FILE_NAME, finalApiData) -- Fallback backup ra workspace
        return
    end

    -- 2. Fallback Workspace nếu web down
    local rawData = ReadJSONFile(FILE_NAME)
    local accountList = {}

    if rawData then
        for _, info in pairs(rawData) do
            if type(info) == "table" and info.Name then
                table.insert(accountList, {
                    Name = tostring(info.Name),
                    LastTime = tonumber(info.LastTime) or 0,
                    IDK = (info.IDK == true)
                })
            end
        end
    end

    local isMeFound = false
    for _, acc in ipairs(accountList) do
        if acc.Name == myName then
            acc.LastTime = currentTime
            acc.IDK = myIDK
            isMeFound = true
            break
        end
    end

    if not isMeFound then
        table.insert(accountList, { Name = myName, LastTime = currentTime, IDK = myIDK })
    end

    local onlinePlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        onlinePlayers[plr.Name] = true
    end

    local filteredList = {}
    for _, acc in ipairs(accountList) do
        local timeDiff = currentTime - acc.LastTime
        if not ((timeDiff > 300) and not onlinePlayers[acc.Name]) then
            table.insert(filteredList, acc)
        end
    end

    table.sort(filteredList, function(a, b) return a.LastTime < b.LastTime end)

    local finalOutput = {}
    for index, acc in ipairs(filteredList) do
        finalOutput["acc " .. tostring(index)] = {
            Name = acc.Name,
            LastTime = acc.LastTime,
            IDK = acc.IDK
        }
    end
    WriteJSONFile(FILE_NAME, finalOutput)
end

task.spawn(function()
    ManagePartyDatabase()
    while task.wait(10) do
        pcall(ManagePartyDatabase)
    end
end)

local function getFrozenWatcherPosition()
    local mapFolder = workspace:FindFirstChild("Map")
    
    if mapFolder then
        local frozenWatcher = mapFolder:FindFirstChild("FrozenWatcherPart", true)
        
        if frozenWatcher then
            local position = frozenWatcher.Position
            local waterPlane = mapFolder:FindFirstChild("WaterBase-Plane")
            local waterBaseY = waterPlane and waterPlane.Position.Y or 20
            
            if position.Y > waterBaseY then
                return true, position
            end
        end
    end
    
    return false, nil
end

---------
local MoveConnection = nil
local targetCFrame = nil
local targetAttachment = nil
local rootAttachment = nil
local alignPosition = nil
local isAligningY = false

local function DungDiChuyen()
    if not _G.ChoPhepDiChuyen and not MoveConnection and (not alignPosition or not alignPosition.Enabled) then
        return
    end

    _G.ChoPhepDiChuyen = false
    targetCFrame = nil
    
    if MoveConnection then
        MoveConnection:Disconnect()
        MoveConnection = nil
    end
    
    if alignPosition then
        alignPosition.Enabled = false
    end
    
    local character = LP.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoid then
            local isBoat = humanoid.Sit or (humanoid.SeatPart ~= nil)
            if not isBoat then
                humanoid.PlatformStand = false
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function DiChuyenDen(mucTieuCFrame)
    if not mucTieuCFrame then DungDiChuyen() return end
    _G.ChoPhepDiChuyen = true
    targetCFrame = mucTieuCFrame
    local character = LP.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    local isBoat = humanoid.Sit or (humanoid.SeatPart ~= nil)
    local currentSpeed = isBoat and (_G.TocDoTweenBoat or 400) or (_G.TocDoTween or 400)

    if not isBoat then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end

    if not alignPosition or alignPosition.Parent ~= hrp then
        if alignPosition then alignPosition:Destroy() end
        if targetAttachment then targetAttachment:Destroy() end
        if rootAttachment and rootAttachment.Name == "MeyyRootAtt" then rootAttachment:Destroy() end
        
        targetAttachment = Instance.new("Attachment")
        targetAttachment.Name = "MeyyTargetAtt"
        targetAttachment.Parent = workspace.Terrain
        
        rootAttachment = Instance.new("Attachment")
        rootAttachment.Name = "MeyyRootAtt"
        rootAttachment.Parent = hrp
        
        alignPosition = Instance.new("AlignPosition")
        alignPosition.Name = "MeyyAlign"
        alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
        alignPosition.Attachment0 = rootAttachment
        alignPosition.Attachment1 = targetAttachment
        alignPosition.MaxForce = 9e99
        alignPosition.MaxVelocity = currentSpeed 
        alignPosition.Responsiveness = 200
        alignPosition.ApplyAtCenterOfMass = true
        alignPosition.Parent = hrp
    end

    local mapFolder = workspace:FindFirstChild("Map")
    local waterPlane = mapFolder and mapFolder:FindFirstChild("WaterBase-Plane")
    local waterLevel = waterPlane and (waterPlane.Position.Y + (waterPlane.Size.Y / 2)) or 20

    local initialTargetPos = mucTieuCFrame.Position
    if initialTargetPos.Y < waterLevel then
        initialTargetPos = Vector3.new(initialTargetPos.X, hrp.Position.Y, initialTargetPos.Z)
    end

    local diffY = math.abs(initialTargetPos.Y - hrp.Position.Y)
    if diffY > 25 then
        isAligningY = true
        targetAttachment.WorldPosition = Vector3.new(hrp.Position.X, initialTargetPos.Y, hrp.Position.Z)
        alignPosition.MaxVelocity = currentSpeed
    else
        isAligningY = false
        targetAttachment.WorldPosition = initialTargetPos
        alignPosition.MaxVelocity = currentSpeed
    end

    alignPosition.Enabled = true
    
    if not MoveConnection then
        MoveConnection = RunService.PostSimulation:Connect(function(dt)
            if not _G.ChoPhepDiChuyen or not targetCFrame then 
                DungDiChuyen()
                return 
            end
            
            local cChar = LP.Character
            if not cChar then return end
            local cHrp = cChar:FindFirstChild("HumanoidRootPart")
            local cHum = cChar:FindFirstChild("Humanoid")
            if not cHrp or not cHum then return end
            
            local loopIsBoat = cHum.Sit or (cHum.SeatPart ~= nil)
            local loopSpeed = (loopIsBoat and not _G.DangKeoTim) and (_G.TocDoTweenBoat or 400) or (_G.TocDoTween or 400)
            cHrp.AssemblyAngularVelocity = Vector3.zero
            
            local currentPos = cHrp.Position
            local rawFinalPos = targetCFrame.Position
            
            local currentWaterPlane = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
            local currentWaterLevel = currentWaterPlane and (currentWaterPlane.Position.Y + (currentWaterPlane.Size.Y / 2)) or 20
            
            local finalPos = rawFinalPos
            if rawFinalPos.Y < currentWaterLevel then
                finalPos = Vector3.new(rawFinalPos.X, currentPos.Y, rawFinalPos.Z)
            end
            
            if isAligningY then
                local currentDiffY = math.abs(finalPos.Y - currentPos.Y)
                if currentDiffY <= 3 then
                    isAligningY = false
                    targetAttachment.WorldPosition = finalPos
                    alignPosition.MaxVelocity = loopSpeed
                else
                    targetAttachment.WorldPosition = Vector3.new(targetAttachment.WorldPosition.X, finalPos.Y, targetAttachment.WorldPosition.Z)
                    alignPosition.MaxVelocity = loopSpeed
                end
            else
                targetAttachment.WorldPosition = finalPos
                alignPosition.MaxVelocity = loopSpeed
            end
            local distance = (finalPos - currentPos).Magnitude
            if distance < 3 then
                DungDiChuyen()
            end
        end)
    end
end

RunService.Stepped:Connect(function()
    if _G.BatNoclip and LP.Character then
        for _, part in ipairs(LP.Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    if _G.XoaSuongMu then
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    end
end)

task.spawn(function()
    while task.wait(2) do
        if _G.XoaSuongMu then
            local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos:Destroy() end
        end
    end
end)

local function KiemTraThuyen()
    local thuyenMoi = workspace:FindFirstChild("Boats")
    if not thuyenMoi then return nil end
    
    for _, v in ipairs(thuyenMoi:GetChildren()) do
        if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == _G.NguoiMuaThuyen then
            return v
        end
    end
    return nil
end
local function checkBoatJitter(boatModel, duration, threshold)
    duration = duration or 0.5
    threshold = threshold or 0.8

    local character = LP.Character
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not boatModel then
        return false
    end

    local boatPart = boatModel.PrimaryPart or boatModel:FindFirstChildWhichIsA("BasePart")
    if not boatPart then
        return false
    end

    local lastRelPos = boatPart.Position - hrp.Position
    local lastDir = 0
    local reversals = 0
    local samples = 0
    local startTime = tick()

    while tick() - startTime < duration do
        RunService.Heartbeat:Wait()
        
        if not hrp.Parent or not boatPart.Parent then
            break
        end

        local currentRelPos = boatPart.Position - hrp.Position
        local delta = currentRelPos - lastRelPos
        local mag = delta.Magnitude

        if mag > 0.05 and mag < 5 then
            local currentDir = math.sign(delta.Y ~= 0 and delta.Y or delta.Z)
            if lastDir ~= 0 and currentDir ~= 0 and currentDir ~= lastDir then
                reversals = reversals + 1
            end
            if currentDir ~= 0 then
                lastDir = currentDir
            end
        end

        lastRelPos = currentRelPos
        samples = samples + 1
    end

    local isJittering = (reversals >= 3)
    if isJittering then
        return true
    else
        return false
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.NguoiMuaThuyen == LP.Name then
                local isFoundHeart, _ = GetFrozenHeartData()
                if _G.ShootHeart and isFoundHeart then
                    return
                end
                local thuyen = KiemTraThuyen()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if thuyen and hum and hum.Sit then
                    local isJittering = checkBoatJitter(thuyen, 0.5, 0.8)
                    if isJittering then
                        hum.Sit = false
                        task.wait(0.1)
                        hum.Jump = true
                    end
                end
            end
        end)
    end
end)
local function DemNguoiTrenThuyen(thuyen)
    if not thuyen then return 0 end
    local dem = 0
    for _, part in ipairs(thuyen:GetDescendants()) do
        if (part:IsA("Seat") or part:IsA("VehicleSeat")) and part.Occupant then
            dem = dem + 1
        end
    end
    return dem
end

local RS = game:GetService("ReplicatedStorage")
local MaterialsList = {
    "Fool's Gold",       
    "Shark Tooth",      
    "Electric Wing",    
    "Mutant Tooth",     
    "Terror Eyes",    
    "Leviathan Scale",  
    "Leviathan Heart"    
}

local ScrollReqs = {
    CommonScroll    = {3, 2, 0, 0, 0, 0, 0},
    RareScroll      = {5, 4, 2, 0, 0, 0, 0},
    LegendaryScroll = {7, 0, 3, 1, 0, 5, 0},
    MythicalScroll  = {20, 0, 0, 0, 1, 15, 1}
}


local ScrollCaps = {
    CommonScroll    = 10,
    RareScroll      = 10,
    LegendaryScroll = 15,
    MythicalScroll  = 10
}


local function AutoCraftScroll(scrollName)
    local rawName = tostring(scrollName):gsub("%s+", "")
    if not ScrollReqs[rawName] then 
        print(string.format("[Craft Debug] '%s' No ScrollReqs!", tostring(rawName)))
        return 0, {} 
    end
    
    local reqs = ScrollReqs[rawName]
    local currentScrolls = CountItem(rawName)
    local sliderCap = ScrollCaps[rawName]
    local capLimit = (sliderCap and sliderCap > 0) and sliderCap or 50
    local maxAllowed = capLimit - currentScrolls
    

    if maxAllowed <= 0 then
        print(string.format("[Craft Debug] STOP!! [%s] Max Cap!", rawName))
        return 0, {}
    end

    local maxCraft = math.huge
    local missingMaterials = {}

    for i = 1, #MaterialsList do
        local needAmount = reqs[i]
        if needAmount and needAmount > 0 then
            local matName = MaterialsList[i]
            local currentAmount = CountItem(matName)
            local canCraft = math.floor(currentAmount / needAmount)
            
            if canCraft < maxCraft then
                maxCraft = canCraft
            end
            if currentAmount < needAmount then
                missingMaterials[matName] = needAmount - currentAmount
            end
        end
    end
    
    if maxCraft == math.huge then
        maxCraft = 0
    end
    

    if maxCraft <= 0 then
        for mName, mDiff in pairs(missingMaterials) do
        end
        return 0, missingMaterials
    end

    if maxCraft > maxAllowed then
        maxCraft = maxAllowed
    end

    local args = {
        "Craft",
        rawName,
        maxCraft,
        {}
    }

    local ok, res = pcall(function()
        return RS:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
    end)


    return maxCraft, {}
end
---------

local function KiemTraDieuKienSan()
    local thuyen = KiemTraThuyen()
    if thuyen then
        local soNguoi = DemNguoiTrenThuyen(thuyen)
        if soNguoi >= _G.SoNguoiCanThiet then
            return true
        end
    end
    return false
end

local function IsFrozenHeartHarpooned()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local inside = frozenHeart:FindFirstChild("Inside")
            if inside then
                return inside:GetAttribute("Harpooned") or false
            end
        end
    end
    return false
end


local function bypassSit(seat, humanoid)
    if not seat or not humanoid then return end
    
    local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
    local touchPart = humanoid.Parent:FindFirstChild("LeftFoot") or humanoid.Parent:FindFirstChild("Torso") or rootPart
    
    if rootPart and touchPart then
        seat.CanTouch = true
        
        task.spawn(function()
            if firetouchtransmitter then
                firetouchtransmitter(seat, touchPart, 0)
                task.wait()
                firetouchtransmitter(seat, touchPart, 1)
            end
        end)
        
        local oldCFrame = rootPart.CFrame
        local tempTime = tick()
        
        repeat
            rootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
            seat:Sit(humanoid)
            task.wait()
        until humanoid.Sit or (tick() - tempTime > 1.5)
        
        if not humanoid.Sit then
            seat:Sit(humanoid)
        end
    end
end

local function GetFrozenHeartData()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        
        if frozenHeart then
            return true, frozenHeart:GetPivot().Position, frozenHeart
        end
    end
    
    return false, nil, nil
end

local function IsFrozenHeartHarpooned()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local inside = frozenHeart:FindFirstChild("Inside")
            if inside then
                return inside:GetAttribute("Harpooned") or false
            end
        end
    end
    return false
end

local function GetWaterLevel()
    local waterPlane = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if waterPlane then
        return waterPlane.Position.Y + (waterPlane.Size.Y / 2)
    end
    return 20 
end

local function KiemTraDaoIgnore()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return false end

    local prehistoric = mapFolder:FindFirstChild("PrehistoricIsland")
    if prehistoric then
        local p = prehistoric:GetPivot()
        if (Vector3.new(p.Position.X, 0, p.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude <= 4500 then
            return true
        end
    end

    local mystic = mapFolder:FindFirstChild("MysticIsland")
    if mystic then
        local p = mystic:GetPivot()
        if (Vector3.new(p.Position.X, 0, p.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude <= 4500 then
            return true
        end
    end

    return false
end

local function KiemTraQuaiKhongChon()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local minDist = 3500

    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local n = mob.Name
            local isUnselected = false
            if n:find("Piranha") and not table.find(_G.SelectedEvents, "Piranha") then isUnselected = true
            elseif n:find("Terrorshark") and not table.find(_G.SelectedEvents, "Terrorshark") then isUnselected = true
            elseif n:find("Shark") and not table.find(_G.SelectedEvents, "Shark") then isUnselected = true
            elseif n:find("Fish Crew Member") and not table.find(_G.SelectedEvents, "FishBoat") then isUnselected = true
            elseif n:find("PirateGrandBrigade") and not table.find(_G.SelectedEvents, "PirateGrandBrigade") then isUnselected = true
            elseif n:find("PirateBrigade") and not table.find(_G.SelectedEvents, "PirateBrigade") then isUnselected = true
            elseif n:find("FishBoat") and not table.find(_G.SelectedEvents, "FishBoat") then isUnselected = true
            end

            if isUnselected then
                local isAlive = false
                local hum = mob:FindFirstChild("Humanoid")
                local hpVal = mob:FindFirstChild("Health")
                
                if hum then
                    if hum:IsA("Humanoid") then
                        if hum.Health > 0 then isAlive = true end
                    elseif hum:IsA("NumberValue") or hum:IsA("IntValue") then
                        if hum.Value > 0 then isAlive = true end
                    end
                elseif hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) then
                    if hpVal.Value > 0 then isAlive = true end
                end

                local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("VehicleSeat") or mob.PrimaryPart
                if not root then
                    local ok, p = pcall(function() return mob:GetPivot() end)
                    if ok and p then
                        if isAlive and (p.Position - hrp.Position).Magnitude <= minDist then
                            return true
                        end
                    end
                elseif isAlive and root then
                    if (root.Position - hrp.Position).Magnitude <= minDist then
                        return true
                    end
                end
            end
        end
    end

    local sbFolder = workspace:FindFirstChild("SeaBeasts")
    if sbFolder then
        for _, mob in ipairs(sbFolder:GetChildren()) do
            local n = mob.Name
            local isUnselected = false
            if n:find("SeaBeast") and not table.find(_G.SelectedEvents, "Sea Beast") then isUnselected = true
            elseif (n == "Leviathan" or n == "Leviathan Segment") and not table.find(_G.SelectedEvents, "Leviathan") then isUnselected = true
            end
            
            if isUnselected then
                local isAlive = false
                local success, health = pcall(function()
                    local healthObj = mob:FindFirstChild("Health")
                    if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "NumberValue" or healthObj.ClassName == "IntConstrainedValue") then
                        return healthObj.Value
                    end
                    return mob:FindFirstChild("Humanoid").Health
                end)

                if success and health > 0 then
                    isAlive = true
                elseif not success then
                    local pivotSuccess = pcall(function() return mob:GetPivot() end)
                    if pivotSuccess then
                        isAlive = true
                    end
                end

                if isAlive then
                    local root = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")
                    local mobPos = nil
                    if root then
                        mobPos = root.Position
                    else
                        local ok, p = pcall(function() return mob:GetPivot() end)
                        if ok and p then mobPos = p.Position end
                    end

                    if mobPos and (mobPos - hrp.Position).Magnitude <= minDist then
                        return true
                    end
                end
            end
        end
    end
    return false
end

getgenv().LastTerrorY = nil
getgenv().LastTerrorMob = nil
getgenv().IsTerrorDodging = false

local function HandleTargetPositioning(seaEventTarget, eType, wName, targetPos)
    if not targetPos then return nil end

    local flyCFrame
    local yDist = 40
    local isM1 = getgenv().IsPureM1

    if wName == "Fruit" or wName == "Blox Fruit" then 
        yDist = 5
    elseif wName == "Gun" then 
        yDist = 100
    else 
        if seaEventTarget and seaEventTarget.Name:find("Terrorshark") and isM1 then
            yDist = 57
        else
            yDist = 40
        end
    end
    local waterTopY = GetWaterLevel()


    if eType == "SeaBeast" then
        local isLevi = seaEventTarget and (seaEventTarget.Name == "Leviathan Segment" or seaEventTarget.Name == "Leviathan")

        if isLevi then
            getgenv().MacroAimPos = CFrame.new(targetPos)

            if _G.SpinPosition then
                local radius = isM1 and 23 or 67
                flyCFrame = CaculateCircreDirection(CFrame.new(targetPos), 30, radius)
            else
                flyCFrame = CFrame.new(targetPos.X, targetPos.Y + 30, targetPos.Z)
            end
        else
            local waterBaseY = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane") and Workspace.Map["WaterBase-Plane"].Position.Y or 20

            local aimPos = Vector3.new(targetPos.X, waterBaseY, targetPos.Z)
            getgenv().MacroAimPos = CFrame.new(aimPos)

            local yOffset = 150

            local standPos = Vector3.new(aimPos.X, waterTopY + yOffset, aimPos.Z)
            
            if _G.SpinPosition then
                local radius = isM1 and 23 or 67
                if seaEventTarget and seaEventTarget.Name:find("Terrorshark") then
                    radius = 0
                end
                flyCFrame = CaculateCircreDirection(CFrame.new(Vector3.new(aimPos.X, waterTopY, aimPos.Z)), yOffset, radius)
            else
                flyCFrame = CFrame.new(standPos)
            end
        end

    else
       local finalTargetPos = targetPos
            if (seaEventTarget.Name:find("Brigade") or seaEventTarget.Name == "FishBoat") and isM1 then
                if wName == "Fruit" or wName == "Blox Fruit" then
                    if seaEventTarget.Name == "PirateGrandBrigade" or seaEventTarget.Name == "FishBoat" then
                        local vehicleSeat = seaEventTarget:FindFirstChild("VehicleSeat")
                        if vehicleSeat then
                            finalTargetPos = vehicleSeat.Position
                        end
                    else
                        local engine = seaEventTarget:FindFirstChild("Engine")
                        if engine and engine:IsA("Part") then
                            finalTargetPos = engine.Position
                        end
                    end
                else
                    local mobCFrame = seaEventTarget:GetPivot()
                    finalTargetPos = finalTargetPos + (mobCFrame.LookVector * 10)
                end
            end

        getgenv().MacroAimPos = CFrame.new(finalTargetPos)
        flyCFrame = CFrame.new(finalTargetPos) * CFrame.new(0, yDist, 0)

        if _G.SpinPosition then
            local radius = isM1 and 23 or 67
            if seaEventTarget and seaEventTarget.Name:find("Terrorshark") then
                radius = 0
            end
            flyCFrame = CaculateCircreDirection(CFrame.new(finalTargetPos), yDist, radius)
        end

        if seaEventTarget.Name:find("Terrorshark") then
            local currentTerrorY = targetPos.Y
            
            if currentTerrorY > (waterTopY + 20) then
                getgenv().IsTerrorDodging = true
            else
                getgenv().IsTerrorDodging = false
            end

            if getgenv().IsTerrorDodging then
                flyCFrame = CFrame.new(flyCFrame.Position.X, flyCFrame.Position.Y + 250, flyCFrame.Position.Z)
                if khoiDiChuyen then
                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, flyCFrame.Position.Y, khoiDiChuyen.Position.Z)
                end
            end
        end
    end

    return flyCFrame
end



task.spawn(function()
    while true do
        local map = workspace:FindFirstChild("Map")
        if map then
            local model = map:FindFirstChild("Model")
            if model then
                model:Destroy()
            end
        end
        task.wait(5)
    end
end)

task.spawn(function()
	while true do
		local rocksFolder = workspace:FindFirstChild("Rocks")
		if rocksFolder then
			rocksFolder:Destroy()
		end
		task.wait(30)
	end
end)

_G.WaitResetBoat = false

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.DangSan then
                local thuyen = workspace:FindFirstChild("Boats")
                if thuyen then
                    for _, v in ipairs(thuyen:GetChildren()) do
                        local ownerObj = v:FindFirstChild("Owner")
                        if ownerObj and (tostring(ownerObj.Value) == _G.NguoiMuaThuyen or tostring(ownerObj.Value) == LP.Name) then
                            local boatHp = v:FindFirstChild("Humanoid")
                            if boatHp and (boatHp:IsA("IntValue") or boatHp.ClassName == "IntValue") then
                                if boatHp.Value <= 0 then
                                    _G.WaitResetBoat = true
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)


task.spawn(function()
    local function setupResetLogic(char)
        _G.WaitResetBoat = false
        _G.PatrolState = 1
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                _G.WaitResetBoat = false
                _G.PatrolState = 1
            end)
        end
    end

    if LP.Character then
        setupResetLogic(LP.Character)
    end

    LP.CharacterAdded:Connect(function(char)
        setupResetLogic(char)
    end)
end)

local NpcPositions = {
    ["Uzoth"] = Vector3.new(5661.89794921875, 1210.876953125, 863.176025390625),
    ["Dragon Wizard"] = Vector3.new(5771.85302734375, 1208.89697265625, 804.2470092773438),
    ["Martial Arts Master"] = Vector3.new(-5004.72119140625, 370.42333984375, -3198.915283203125),
    ["Phoeyu, the Reformed"] = Vector3.new(-4999.23046875, 314.0144958496094, -3221.572265625),
    ["Sharkman Teacher"] = Vector3.new(-4971.2060546875, 313.8869323730469, -3223.0791015625),
    ["Previous Hero"] = Vector3.new(-10371.4716796875, 330.7640075683594, -10131.419921875),
    ["Ancient Monk"] = Vector3.new(-13774.0908203125, 333.7330017089844, -9879.9072265625),
    ["Shafi"] = Vector3.new(-16515.06640625, 22.811996459960938, -188.572998046875)
}

local function GetNpcPosition(npcName)
    return NpcPositions[npcName]
end

local function HandleBoatRespawnLogic(thuyen)
    local viTriMuaThuyen = CFrame.new(-16204.9668, 9.2812, 474.9888)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local isBoatBroken = _G.WaitResetBoat

    if thuyen then
        local ownerObj = thuyen:FindFirstChild("Owner")
        local ownerName = ownerObj and tostring(ownerObj.Value) or ""
        local targetOwner = _G.NguoiMuaThuyen and tostring(_G.NguoiMuaThuyen) or LP.Name

        if ownerName == targetOwner or ownerName == LP.Name then
            local boatHp = thuyen:FindFirstChild("Humanoid")
            if boatHp and (boatHp:IsA("IntValue") or boatHp.ClassName == "IntValue") then
                if boatHp.Value <= 0 then
                    isBoatBroken = true
                    _G.WaitResetBoat = true
                    thuyen = nil
                end
            end
        end
    end

    if thuyen and thuyen.PrimaryPart then
        local dist = (thuyen.PrimaryPart.Position - hrp.Position).Magnitude
        if dist > 5000 then
            thuyen = nil 
        end
    end

    if not thuyen then
        local distToSpawn = (hrp.Position - viTriMuaThuyen.Position).Magnitude
        if isBoatBroken and distToSpawn > 1000 then
            local w = game:GetService("Players")
            local S = w.LocalPlayer
            if S.Character and S.Character:FindFirstChild("Humanoid") then
                print("Resetting character due to broken boat...")
                if getgenv().Meyy6Race_API then
                    getgenv().Meyy6Race_API.SetTask("Resetting Character")
                    getgenv().Meyy6Race_API.SetTheme("Sky")
                end
                S.Character.Humanoid.Health = 0
                _G.WaitResetBoat = false
            end
        else
            _G.WaitResetBoat = false
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Buying Boat")
                getgenv().Meyy6Race_API.SetTheme("Candy")
            end

            DiChuyenDen(viTriMuaThuyen)
            if distToSpawn < 15 then
                _G.PatrolState = 1
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", _G.TenThuyen)
                task.wait(0.5)
            end
        end
        return true
    end

    return false 
end

---------

---------
local function HandleFrozenWatcherLogic(hrp, humanoid, watcherPos)
    local distToWatcher = (hrp.Position - watcherPos).Magnitude
    
    if distToWatcher > 200 then
        local myBoat = KiemTraThuyen()
        if not myBoat then
            if _G.NguoiMuaThuyen == LP.Name then
                HandleBoatRespawnLogic(nil)
            end
        else
            if _G.NguoiMuaThuyen == LP.Name then
                local gheLai = myBoat:FindFirstChild("VehicleSeat")
                if gheLai then
                    if not humanoid.Sit then
                        DiChuyenDen(gheLai.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5)
                        if (gheLai.Position - hrp.Position).Magnitude <= 10 then
                            gheLai:Sit(humanoid)
                        end
                    else
                        DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
                    end
                end
            else
                local gheTrong = nil
                local harpoon = myBoat:FindFirstChild("Harpoon")
                local harpoonSeat = harpoon and harpoon:FindFirstChild("Seat")
                for _, part in ipairs(myBoat:GetDescendants()) do
                    if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                        gheTrong = part
                        break
                    end
                end
                if gheTrong then
                    if not humanoid.Sit then
                        DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5)
                        if (gheTrong.Position - hrp.Position).Magnitude <= 10 then
                            gheTrong:Sit(humanoid)
                        end
                    else
                        DungDiChuyen()
                    end
                end
            end
        end
    else
        if humanoid.Sit then
            humanoid.Sit = false
            task.wait(0.1)
        end
        
        if distToWatcher <= 100 then
            local tocDoCu = _G.TocDoTween
            _G.TocDoTween = 55
            DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
            _G.TocDoTween = tocDoCu
        else
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Moving to NPC")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
            if khoiDiChuyen then
                local currentY = khoiDiChuyen.Position.Y
                local targetY = watcherPos.Y + 10
                if math.abs(currentY - targetY) > 5 then
                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, targetY, khoiDiChuyen.Position.Z)
                    task.wait(0.1)
                end
            end
            DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
        end
        
        if distToWatcher < 40 then
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Opening Gate")
                getgenv().Meyy6Race_API.SetTheme("Lavender")
            end
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("OpenLeviathanGate")
        end
    end
    return true
end

local function CalculateHarpoonAngles(harpoonFolder, targetPos)
    local seat = harpoonFolder:FindFirstChild("Seat")
    local baseCFrame
    
    if seat and seat:FindFirstChild("BoatWeld") and seat.BoatWeld.Part0 then
        baseCFrame = seat.BoatWeld.Part0.CFrame
    elseif seat and seat:IsA("BasePart") then
        baseCFrame = seat.CFrame
    else
        baseCFrame = harpoonFolder:GetPivot()
    end

    local localDir = baseCFrame:PointToObjectSpace(targetPos)

    local yaw = math.atan2(localDir.X, -localDir.Z)

    local x = math.sqrt(localDir.X^2 + localDir.Z^2)
    local y = localDir.Y - (baseCFrame.Position.Y - targetPos.Y)

    local v = 400
    local g = workspace.Gravity

    local root = v^4 - g * (g * x^2 + 2 * y * v^2)
    local pitch = 0

    if root >= 0 then
        pitch = math.atan2(v^2 - math.sqrt(root), g * x)
    else
        pitch = math.atan2(y, x)
    end

    local clampedPitch = math.clamp(pitch, -0.17453292519943295, 0.7853981633974483)
    local clampedYaw = math.clamp(yaw, -1.1344640137963142, 1.1344640137963142)

    return clampedPitch, clampedYaw
end



local function FiringHarpoonLogic(harpoonFolder, harpoonSeat, heartPos)
    DungDiChuyen()
    if getgenv().Meyy6Race_API then
        getgenv().Meyy6Race_API.SetTask("Shooting Heart")
        getgenv().Meyy6Race_API.SetTheme("Dream")
    end
    
    local currentTime = tick()
    if not getgenv().LastHarpoonShoot or currentTime - getgenv().LastHarpoonShoot >= 1 then
        getgenv().LastHarpoonShoot = currentTime
        
        local pitch, yaw = CalculateHarpoonAngles(harpoonFolder, heartPos)
        local boatWeld = harpoonSeat:FindFirstChild("BoatWeld")
        local cannonWeld = harpoonSeat:FindFirstChild("CannonWeld")
        
        if boatWeld then
            pcall(function()
                boatWeld.C0 = CFrame.Angles(0, yaw, 0)
                boatWeld.C1 = CFrame.Angles(0, yaw * 2, 0)
            end)
        end
        
        if cannonWeld then
            pcall(function()
                local v21 = math.max(pitch - 0.4363323129985824, 0) / 0.6108652381980153 * 2.5
                cannonWeld.C0 = CFrame.new(0, v21, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -v21 / 1.4142135623730951)
            end)
        end
        
        pcall(function()
            local shootTick = workspace:GetServerTimeNow()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("FireHarpoon", pitch, yaw, harpoonFolder, shootTick - (RunService.RenderStepped:Wait()))
        end)
    end
end

---------
local function GetHeartData()
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local core = frozenHeart:FindFirstChild("Inside") 
                or frozenHeart:FindFirstChild("Cube") 
                or frozenHeart:FindFirstChild("Hitbox")
                or frozenHeart.PrimaryPart
                or frozenHeart:FindFirstChildWhichIsA("BasePart", true)
            if core then
                return core.CFrame, frozenHeart
            end
            return frozenHeart:GetPivot(), frozenHeart
        end
    end
    return nil, nil
end



---------
local function bypassSit(seat, humanoid)
    if not seat or not humanoid then return end
    
    local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
    local touchPart = humanoid.Parent:FindFirstChild("LeftFoot") or humanoid.Parent:FindFirstChild("Torso") or rootPart
    
    if rootPart and touchPart then
        seat.CanTouch = true
        
        task.spawn(function()
            if firetouchtransmitter then
                firetouchtransmitter(seat, touchPart, 0)
                task.wait()
                firetouchtransmitter(seat, touchPart, 1)
            end
        end)
        
        local oldCFrame = rootPart.CFrame
        local tempTime = tick()
        
        repeat
            rootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
            seat:Sit(humanoid)
            task.wait()
        until humanoid.Sit or (tick() - tempTime > 1.5)
        
        if not humanoid.Sit then
            seat:Sit(humanoid)
        end
    end
end

local function HandleFrozenHeartLogic(hrp, humanoid, heartPosFallback)
    if not _G.ShootHeart then 
        return false 
    end
    
    local myBoat = KiemTraThuyen()
    if not myBoat or not hrp or not humanoid then 
        return false 
    end

    local heartCFrame, frozenHeart = GetHeartData()
    if not heartCFrame and heartPosFallback then
        if typeof(heartPosFallback) == "CFrame" then
            heartCFrame = heartPosFallback
        elseif typeof(heartPosFallback) == "Vector3" then
            heartCFrame = CFrame.new(heartPosFallback)
        end
    end

    local isHarpooned = IsFrozenHeartHarpooned()

    if _G.NguoiMuaThuyen == LP.Name then
        if not heartCFrame or isHarpooned then
            if isHarpooned then
                local vehicleSeat = myBoat:FindFirstChild("VehicleSeat")
                if vehicleSeat then
                    if humanoid.Sit and humanoid.SeatPart ~= vehicleSeat then
                        humanoid.Sit = false
                        task.wait(0.2)
                    end
                    if not humanoid.Sit then
                        bypassSit(vehicleSeat, humanoid)
                    end
                end
                DungDiChuyen()
                return true
            end
            return false
        end

        local heartPos = heartCFrame.Position
        local vehicleSeat = myBoat:FindFirstChild("VehicleSeat")
        local harpoonFolder = myBoat:FindFirstChild("Harpoon")
        local harpoonSeat = harpoonFolder and harpoonFolder:FindFirstChild("Seat")
        
        if not vehicleSeat or not harpoonSeat then return false end

        local direction = (Vector3.new(vehicleSeat.Position.X, 0, vehicleSeat.Position.Z) - Vector3.new(heartPos.X, 0, heartPos.Z)).Unit
        if direction.Magnitude == 0 or direction ~= direction then direction = Vector3.new(1,0,0) end
        local targetPos = Vector3.new(heartPos.X, 0, heartPos.Z) + (direction * 290)
        targetPos = Vector3.new(targetPos.X, (vehicleSeat.Position.Y + GetWaterLevel()) / 2, targetPos.Z)
        local aimCFrame = CFrame.new(targetPos, Vector3.new(heartPos.X, targetPos.Y, heartPos.Z))
        
        if not humanoid.Sit then
            if myBoat.PrimaryPart then
                myBoat:PivotTo(hrp.CFrame)
                task.wait(0.05)
            end
            bypassSit(vehicleSeat, humanoid)
        elseif humanoid.Sit and humanoid.SeatPart == vehicleSeat then
            local dist = (Vector3.new(vehicleSeat.Position.X, 0, vehicleSeat.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist > 50 then
                DiChuyenDen(aimCFrame)
            else
                DungDiChuyen()
                if myBoat.PrimaryPart then
                    myBoat:PivotTo(aimCFrame)
                end
                humanoid.Sit = false
                task.wait(0.2)
                bypassSit(harpoonSeat, humanoid)
            end
        elseif humanoid.Sit and humanoid.SeatPart == harpoonSeat then
            FiringHarpoonLogic(harpoonFolder, harpoonSeat, heartPos)
        end
        ---------
        
        return true
    else
        if isHarpooned then
            if getgenv().Meyy6Race_API then getgenv().Meyy6Race_API.SetTask("Boarding & Waiting") end
        end

        if not humanoid.Sit then
            local gheTrong = nil
            local harpoonSeat = myBoat:FindFirstChild("Harpoon") and myBoat.Harpoon:FindFirstChild("Seat")
            for _, part in ipairs(myBoat:GetDescendants()) do
                if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                    gheTrong = part
                    break
                end
            end
            if gheTrong then
                DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                if (gheTrong.Position - hrp.Position).Magnitude <= 5 then
                    gheTrong:Sit(humanoid)
                end
            elseif isHarpooned and myBoat.PrimaryPart then
                DiChuyenDen(myBoat.PrimaryPart.CFrame * CFrame.new(0, 15, 0))
            end
        else
            if humanoid.SeatPart and (hrp.Position - humanoid.SeatPart.Position).Magnitude > 10 then
                humanoid.Sit = false
            else
                DungDiChuyen()
            end
        end
        
        if isHarpooned then return true end
        return false
    end
end



---------
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()

            if IsFrozenHeartHarpooned() then
                return
            end

            local isFoundHeart, heartPos = GetFrozenHeartData()
            if not isFoundHeart or not heartPos then
                return
            end

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hum or not hrp or not hum.Sit then
                return
            end

            local thuyen = KiemTraThuyen()
            if not thuyen then
                return
            end

            local gheLai = thuyen:FindFirstChild("VehicleSeat") or thuyen:FindFirstChildWhichIsA("VehicleSeat", true)
            if not gheLai then
                return
            end

            if hum.SeatPart ~= gheLai and (hrp.Position - gheLai.Position).Magnitude > 8 then
                return
            end

            local boatPivot = thuyen:GetPivot()
            local boatPos = boatPivot.Position
            local boatTarget = Vector3.new(heartPos.X, boatPos.Y, heartPos.Z)

            local lookVec = (boatPivot.LookVector * Vector3.new(1, 0, 1)).Unit
            local dirVec = ((boatTarget - boatPos) * Vector3.new(1, 0, 1)).Unit
            local dotP = math.clamp(lookVec:Dot(dirVec), -1, 1)
            local gocLech = math.deg(math.acos(dotP))

            if gocLech > 5 then
                thuyen:PivotTo(CFrame.lookAt(boatPos, boatTarget))
            end
        end)
    end
end)
---------



getgenv().DangSafeMode = false
getgenv().ViTriSafe = nil

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.DangSan and getgenv().CurrentTarget then
                local char = LP.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hum and hrp and hum.Health > 0 then
                    local hpPercent = hum.Health / hum.MaxHealth

                    if hpPercent < 0.30 and not getgenv().DangSafeMode then
                        getgenv().DangSafeMode = true
                        
                        local toaDoHienTai = hrp.CFrame
                        hrp.CFrame = toaDoHienTai * CFrame.new(0, 2000, 0)
                        
                        getgenv().ViTriSafe = toaDoHienTai * CFrame.new(0, 2500, 0)
                        
                    elseif hpPercent > 0.65 and getgenv().DangSafeMode then
                        getgenv().DangSafeMode = false
                        getgenv().ViTriSafe = nil
                    end
                end
            else
                getgenv().DangSafeMode = false
                getgenv().ViTriSafe = nil
            end
        end)
    end
end)

local function HandleSeaEventCombat(hrp, seaEventTarget, eType, targetPos, isLeviathan)
    if getgenv().Meyy6Race_API then
        if isLeviathan then
            getgenv().Meyy6Race_API.SetTask("Killing Leviathan")
            getgenv().Meyy6Race_API.SetTheme("Sky")
        else
            local mobName = seaEventTarget.Name
            mobName = string.gsub(mobName, "%d+", "")
            getgenv().Meyy6Race_API.SetTask("Killing " .. mobName)
            getgenv().Meyy6Race_API.SetTheme("Lavender")
        end
    end

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if LP.Character.Humanoid.Sit then
            LP.Character.Humanoid.Sit = false
            task.wait(0.1)
        end
    end

    getgenv().CurrentTarget = seaEventTarget
    getgenv().CurrentTargetPart = seaEventTarget:FindFirstChild("HumanoidRootPart", true)
        or seaEventTarget:FindFirstChild("VehicleSeat", true)
        or seaEventTarget.PrimaryPart
        or seaEventTarget:FindFirstChildWhichIsA("BasePart", true)

    local wName = _G.SelectedWeapon
    getgenv().IsPureM1 = false
    getgenv().UseOnlyGunSkill = false

    if _G.UseGunEvent and _G.UseM1FruitEvent then
        if seaEventTarget.Name:find("Sea Beast") or seaEventTarget.Name:find("Rumbling") or seaEventTarget.Name:find("Brigade") then
            wName = "Fruit"
            getgenv().IsPureM1 = true
        else
            wName = "Gun"
            getgenv().UseOnlyGunSkill = true
        end
    elseif _G.UseGunEvent then
        wName = "Gun"
        getgenv().UseOnlyGunSkill = true
    elseif _G.UseM1FruitEvent then
        wName = "Fruit"
        getgenv().IsPureM1 = true
    else
        if seaEventTarget.Name:find("Terrorshark") then
            wName = _G.SelectedWeapon
            getgenv().IsPureM1 = true
            getgenv().UseOnlyGunSkill = false
        else
            if eType == "M1" then getgenv().IsPureM1 = true end
            if wName == "Gun" then getgenv().UseOnlyGunSkill = true end
        end
    end


    local flyCFrame = HandleTargetPositioning(seaEventTarget, eType, wName, targetPos)

    if getgenv().DangSafeMode and getgenv().ViTriSafe then
        flyCFrame = getgenv().ViTriSafe
    end

    if flyCFrame then
        if khoiDiChuyen then
            local currentY = khoiDiChuyen.Position.Y
            local targetY = flyCFrame.Position.Y
            if math.abs(currentY - targetY) > 5 then
                khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, targetY, khoiDiChuyen.Position.Z)
                task.wait(0.1)
            end
        end
        DiChuyenDen(flyCFrame)
    end


    if wName == "Gun" and _G.UseGunEvent then
        local gunEquipName = (seaEventTarget.Name:find("Sea Beast") or seaEventTarget.Name:find("Rumbling")) and "Skull Guitar" or "Dragonstorm"
        EquipGun(gunEquipName)
    else
        if getgenv().IsPureM1 then
            equip(wName)
        end
    end
end
local Tiki_Points = {
    Vector3.new(4574.8701, 22.5545, -4429.2261),
    Vector3.new(-3904.3430, 22.5565, -287.6272),
    Vector3.new(-10974.2920, 22.5565, 245.2649),
    Vector3.new(-15071.9961, 22.5554, 373.7648),
    Vector3.new(-16204.4648, 22.5554, 438.3202)
}

local Hydra_Points = {
    Vector3.new(13560.2676, 27.5490, -5763.9375),
    Vector3.new(12969.5615, 27.5565, -2921.5220),
    Vector3.new(12027.5146, 27.5565, 412.7256),
    Vector3.new(8967.5996, 27.5565, 3901.3904),
    Vector3.new(6061.9238, 27.5565, 5328.6504),
    Vector3.new(4839.1465, 27.5561, 5212.8022),
    Vector3.new(4698.8105, 27.5565, 4252.9385),
    Vector3.new(5005.5952, 27.5557, 3725.4436),
    Vector3.new(5176.7275, 27.5540, 3269.4182),
    Vector3.new(5141.3120, 27.5525, 2943.8655),
    Vector3.new(5190.1035, 27.5564, 2052.7825),
    Vector3.new(5201.9844, 27.7811, 1589.3344)
}

local currentPathIndex = 0
local lastDest = nil
local daBatDauKeoTim = false
local doiTimBayGan = false

local function TinhGocLech(thuyen, mucTieu)
    local cframeThuyen = thuyen.PrimaryPart.CFrame
    local posThuyen = cframeThuyen.Position
    local lookVec = (cframeThuyen.LookVector * Vector3.new(1, 0, 1)).Unit
    local dirVec = ((mucTieu - posThuyen) * Vector3.new(1, 0, 1)).Unit
    local dotP = lookVec:Dot(dirVec)
    local goc = math.deg(math.acos(math.clamp(dotP, -1, 1)))
    local crossP = lookVec:Cross(dirVec)
    return crossP.Y < 0 and -goc or goc
end

local function XoayThuyen(thuyen, mucTieu)
    local pos = thuyen.PrimaryPart.Position
    local targetFlat = Vector3.new(mucTieu.X, pos.Y, mucTieu.Z)
    thuyen:SetPrimaryPartCFrame(CFrame.lookAt(pos, targetFlat))
end

local function NoclipThuyenKeoTim(thuyen)
    for _, v in ipairs(thuyen:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part")) and v.CanCollide then
            v.CanCollide = false
        end
    end
end

local function KeoTimVeDao()
    if not _G.DangSan or not _G.ShootHeart then 
        daBatDauKeoTim = false
        doiTimBayGan = false
        currentPathIndex = 0
        lastDest = nil
        return false 
    end
    if not _G.DriveToTiki and not _G.DriveToHydra then 
        daBatDauKeoTim = false
        doiTimBayGan = false
        currentPathIndex = 0
        lastDest = nil
        return false 
    end
    
    local isFoundHeart, heartPos = GetFrozenHeartData()
    if not isFoundHeart then
        if daBatDauKeoTim then
            DungDiChuyen()
            daBatDauKeoTim = false
            doiTimBayGan = false
            currentPathIndex = 0
            lastDest = nil

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then
                repeat
                    hum.Sit = false
                    task.wait(0.1)
                until not hum.Sit or not hum.Parent
            end
            task.wait(1)
            pcall(function()
                local thuyenCu = KiemTraThuyen()
                if thuyenCu then
                    thuyenCu:Destroy()
                end
            end)
            if hum and hum.Parent then
                hum.Health = 0
            end
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Heart Claimed - Resetting")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
        else
            currentPathIndex = 0
        end
        return false
    end
    
    local isHarpooned = IsFrozenHeartHarpooned()
    if not isHarpooned then
        currentPathIndex = 0
        return false
    end
    
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")
    local boat = KiemTraThuyen()
    
    if not boat or not boat.PrimaryPart or not hrp or not humanoid then return false end
    
    local vehicleSeat = boat:FindFirstChild("VehicleSeat")
    if not vehicleSeat then return false end

    if not humanoid.Sit or humanoid.SeatPart ~= vehicleSeat then
        return false
    end
    
    daBatDauKeoTim = true
    _G.DangKeoTim = true
    local currentDest = _G.DriveToTiki and "Tiki" or "Hydra"
    if lastDest ~= currentDest then
        lastDest = currentDest
        currentPathIndex = 0
    end
    
    local targetPath = _G.DriveToTiki and Tiki_Points or Hydra_Points
    local boatPos = boat.PrimaryPart.Position
    
    if currentPathIndex == 0 then
        local minDist = math.huge
        local nearestIdx = 1
        for i, point in ipairs(targetPath) do
            local dist = (Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(point.X, 0, point.Z)).Magnitude
            if dist < minDist then
                minDist = dist
                nearestIdx = i
            end
        end
        currentPathIndex = nearestIdx
    end

    local targetPoint = targetPath[currentPathIndex]
    local flyHeight = _G.PullYHeight or 35
    local distToTarget = (Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(targetPoint.X, 0, targetPoint.Z)).Magnitude
    
    if heartPos then
        local distToHeart = (boatPos - heartPos).Magnitude
        local safeBackDist = math.clamp(distToHeart * 0.45, 185, 230)
        if distToHeart > 550 then
            doiTimBayGan = true
        elseif distToHeart < safeBackDist then
            doiTimBayGan = false
        end
    end
    
    if doiTimBayGan then
        DungDiChuyen()
        task.spawn(function()
            vehicleSeat.MaxSpeed = 135
            NoclipThuyenKeoTim(boat)
        end)
        
        if boat.PrimaryPart then
            boat.PrimaryPart.ThrottleFloat = -0.65
            boat.PrimaryPart.Throttle = -1
        end
        if getgenv().Meyy6Race_API then
            getgenv().Meyy6Race_API.SetTask("Backing up to Heart")
            getgenv().Meyy6Race_API.SetTheme("Red")
        end
        return true
    end
    
    if getgenv().Meyy6Race_API then
        local destName = currentDest == "Tiki" and "Tiki" or "Hydra"
        local themeName = currentDest == "Tiki" and "Luxury" or "Mint"
        local finalPoint = targetPath[#targetPath]
        local distToFinal = math.floor((Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(finalPoint.X, 0, finalPoint.Z)).Magnitude)
        getgenv().Meyy6Race_API.SetTask("Driving to " .. destName .. " (" .. distToFinal .. "m)")
        getgenv().Meyy6Race_API.SetTheme(themeName)
    end

    if currentPathIndex < #targetPath and distToTarget <= 50 then
        currentPathIndex = currentPathIndex + 1
        targetPoint = targetPath[currentPathIndex]
    end

    local flatTargetPos = Vector3.new(targetPoint.X, flyHeight, targetPoint.Z)
    
    local gocLech = TinhGocLech(boat, flatTargetPos)
    
    task.spawn(function()
        vehicleSeat.MaxSpeed = _G.TocDoTweenBoat or 250
        NoclipThuyenKeoTim(boat)
    end)
    
    if currentPathIndex < #targetPath or distToTarget > 50 then
        DungDiChuyen()
        
        if math.abs(gocLech) > 5 then
            XoayThuyen(boat, flatTargetPos)
            boat.PrimaryPart.ThrottleFloat = 0
            boat.PrimaryPart.Throttle = 0
        else
            boat.PrimaryPart.ThrottleFloat = 1
            boat.PrimaryPart.Throttle = 1
        end
    else
        boat.PrimaryPart.ThrottleFloat = 0
        boat.PrimaryPart.Throttle = 0
        DungDiChuyen()
        if getgenv().Meyy6Race_API then
            getgenv().Meyy6Race_API.SetTask("Arrived at Destination")
            getgenv().Meyy6Race_API.SetTheme("Green")
        end
    end
    
    return true
end
local function HandlePatrolAndIdle(hrp, isLeviathan, isFoundWatcher)
    getgenv().CurrentTarget = nil
    getgenv().CurrentTargetPart = nil
    getgenv().MacroAimPos = nil
    getgenv().IsPureM1 = false
    getgenv().UseOnlyGunSkill = false
    if isFoundWatcher then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            if LP.Character.Humanoid.Sit then
                LP.Character.Humanoid.Sit = false
            end
        end
        DungDiChuyen()
    else
        local thuyen = KiemTraThuyen()
        
        if _G.NguoiMuaThuyen == LP.Name then
            local dangMuaThuyen = false
            if not isLeviathan then
                dangMuaThuyen = HandleBoatRespawnLogic(thuyen)
            end

            if not dangMuaThuyen and thuyen then
                local gheLai = thuyen:FindFirstChild("VehicleSeat")
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if gheLai and hrp and hum then
                        if not hum.Sit then
                            if getgenv().Meyy6Race_API then
                            getgenv().Meyy6Race_API.SetTask("Boarding Boat")
                            getgenv().Meyy6Race_API.SetTheme("Dream")
                        end
                        DiChuyenDen(gheLai.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.2)
                        if (gheLai.Position - hrp.Position).Magnitude <= 10 and hum and hum.Parent then
                            gheLai:Sit(hum)
                        end
                    else 
                        if KiemTraDieuKienSan() then
                        local viTriXuatPhat = Vector3.new(-16204.9668, 0, 474.9888)
                        local distToSpawn = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - viTriXuatPhat).Magnitude

                        if not _G.PatrolState or distToSpawn < 500 then
                            _G.PatrolState = 1
                        end
                            local hrpPos = hrp.Position
                            local isIgnoring = _G.EnableIgnoreSeaEvent and KiemTraQuaiKhongChon()
                            local isIgnoringIsland = _G.EnableIgnoreIsland and KiemTraDaoIgnore()
                            local currentBay = isIgnoringIsland and _G.IgnoreIslandHeight or (isIgnoring and _G.IgnoreHeight or _G.ChieuCaoBay)
                            local yHigh = currentBay
                            local yNormal = currentBay
                            
                            local sea1 = Vector3.new(-14202.8643, yHigh, 447.1369)
                            local sea6 = Vector3.new(-16143.5469, yNormal, 37085.2148)
                            local sea9999 = Vector3.new(-16256.7344, yNormal, 106649.3828)
                            if _G.PatrolState == 1 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Patrolling Sea")
                                    getgenv().Meyy6Race_API.SetTheme("Candy")
                                end
                                if math.abs(hrpPos.Y - yHigh) > 20 and khoiDiChuyen then
                                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, yHigh, khoiDiChuyen.Position.Z)
                                    task.wait(0.1)
                                end
                                DiChuyenDen(CFrame.new(sea1))
                                
                                if (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea1.X, 0, sea1.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 2
                                end
                            elseif _G.PatrolState == 2 then
                                if khoiDiChuyen then
                                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, yNormal, khoiDiChuyen.Position.Z)
                                    task.wait(0.1)
                                end
                                _G.PatrolState = 3
                            elseif _G.PatrolState == 3 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea6))
                                
                                if hrpPos.Z >= sea6.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea6.X, 0, sea6.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 4
                                end
                            elseif _G.PatrolState == 4 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea9999))
                                
                                if hrpPos.Z >= sea9999.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea9999.X, 0, sea9999.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 5
                                end
                            elseif _G.PatrolState == 5 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea6))
                                
                                if hrpPos.Z <= sea6.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea6.X, 0, sea6.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 4
                                end
                            end
                        else
                            if getgenv().Meyy6Race_API then
                                getgenv().Meyy6Race_API.SetTask("Waiting for Members")
                                getgenv().Meyy6Race_API.SetTheme("Lavender")
                            end
                            DungDiChuyen()
                        end
                    end
                end
            end
        else
            if thuyen and hrp then
                local dist = thuyen.PrimaryPart and (thuyen.PrimaryPart.Position - hrp.Position).Magnitude or 0
                if dist > 30000000000 then
                    DungDiChuyen()
                else
                    local quaiHienTai = GetNearestSeaEvent()
                    if LP.Character and LP.Character:FindFirstChild("Humanoid") and not LP.Character.Humanoid.Sit and not quaiHienTai then
                        local gheTrong = nil
                        local harpoon = thuyen:FindFirstChild("Harpoon")
                        local harpoonSeat = harpoon and harpoon:FindFirstChild("Seat")
                        for _, part in ipairs(thuyen:GetDescendants()) do
                            if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                                gheTrong = part
                                break
                            end
                        end
                        
                        if gheTrong then
                            if getgenv().Meyy6Race_API then
                                getgenv().Meyy6Race_API.SetTask("Boarding Boat")
                                getgenv().Meyy6Race_API.SetTheme("Dream")
                            end
                            DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                            task.wait(0.5)
                        local quaiSauKhiCho = GetNearestSeaEvent()
                            if (gheTrong.Position - hrp.Position).Magnitude <= 10 and not quaiSauKhiCho then
                                gheTrong:Sit(LP.Character.Humanoid)
                            end
                        else
                            if thuyen.PrimaryPart then
                                DiChuyenDen(thuyen.PrimaryPart.CFrame * CFrame.new(0, 5, 0))
                            end
                        end
                    elseif quaiHienTai then
                        if LP.Character and LP.Character.Humanoid.Sit then
                            LP.Character.Humanoid.Sit = false
                        end

                    else
                        DungDiChuyen()
                    end
                end
            else
                DungDiChuyen()
            end
        end
    end
end
---------
task.spawn(function()
    while task.wait() do
        if getgenv().DangDiMuaDo then
            continue
        end
        if _G.DangSan then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")

            local isFoundWatcher, watcherPos = getFrozenWatcherPosition()
            if isFoundWatcher then
                if HandleFrozenWatcherLogic(hrp, humanoid, watcherPos) then continue end
            end

            local isFoundHeart, heartPos, frozenHeartObj = GetFrozenHeartData()
            
            if _G.ShootHeart then
                if isFoundHeart or daBatDauKeoTim then
                    local isHarpooned = IsFrozenHeartHarpooned()
                    
                    if (_G.DriveToTiki or _G.DriveToHydra) and (isHarpooned or daBatDauKeoTim) then
                        if KeoTimVeDao() then continue end
                    end
                    
                    if isFoundHeart then
                        if HandleFrozenHeartLogic(hrp, humanoid, heartPos) then continue end
                    end
                end
            end
            
            if daBatDauKeoTim then continue end
            
            local seaEventTarget, eType, targetPos = GetNearestSeaEvent()
            local skipSeaEvents = false
            
            if _G.DestroyIDK then
                local allCleared = true
                local rawData = nil
                
                if getgenv().FetchUnifiedPartyData then
                    rawData = getgenv().FetchUnifiedPartyData()
                end
                
                if rawData then
                    for _, acc in pairs(rawData) do
                        if acc.IDK == true then
                            allCleared = false
                            break
                        end
                    end
                else
                    allCleared = (_G.SpyCheckResult > -1 and _G.SpyCheckResult <= 5)
                end

                if allCleared then
                    skipSeaEvents = true
                end
            end
            local isLeviathan = false
            if seaEventTarget and (seaEventTarget.Name == "Leviathan Segment" or seaEventTarget.Name == "Leviathan") then 
                isLeviathan = true 
                task.wait() 
            end

            if getgenv().DangSafeMode and getgenv().ViTriSafe then
                if getgenv().Meyy6Race_API then
                    getgenv().Meyy6Race_API.SetTask("Low HP - Healing")
                end
                DiChuyenDen(getgenv().ViTriSafe)
            elseif seaEventTarget and targetPos and (not skipSeaEvents or isLeviathan) then
                HandleSeaEventCombat(hrp, seaEventTarget, eType, targetPos, isLeviathan)
            else
                HandlePatrolAndIdle(hrp, isLeviathan, isFoundWatcher)
            end
        else
            getgenv().CurrentTarget = nil
            getgenv().CurrentTargetPart = nil
            getgenv().MacroAimPos = nil
            getgenv().IsPureM1 = false
            getgenv().UseOnlyGunSkill = false
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Idle")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
            DungDiChuyen()
        end
    end
end)
---------

local function down(use, waitTime)
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            VirtualInputManager:SendKeyEvent(true, use, false, LP.Character.HumanoidRootPart)
            task.wait(waitTime or 0.1)
            VirtualInputManager:SendKeyEvent(false, use, false, LP.Character.HumanoidRootPart)
        end
    end)
end

local function Useskills(weapon, skill)
    if weapon == "nil" and skill == "Y" then
        VirtualInputManager:SendKeyEvent(true, "Y", false, game)
        VirtualInputManager:SendKeyEvent(false, "Y", false, game)
    end
end

local SkillConfig = {
    ["Auto Enable V3"] = false, 
    ["Auto Enable V4"] = false,
    ["Custom Health"] = true,
    ["Health"] = 3000,
    ["Melee"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 1, ["Count"] = 30},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 2, ["Count"] = 30},
        ["C"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 3, ["Count"] = 30}
    },        
    ["Sword"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 4, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 5, ["Count"] = 20}
    },        
    ["Gun"] = {
        ["Enable"] = true,
        ["GunMode"] = false,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 6, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 7, ["Count"] = 20}
    },        
    ["Fruit"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 8, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 9, ["Count"] = 20},
        ["C"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 10, ["Count"] = 20},
        ["V"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 11, ["Count"] = 20},
        ["F"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 12, ["Count"] = 20}
    }
}

local function getDelay(toolName)
    if _G.NoSkillDelay then return 0.05 end
    local delayMs = 100
    if toolName == "Melee" then delayMs = _G.SkillDelayMelee or 100 end
    if toolName == "Sword" then delayMs = _G.SkillDelaySword or 100 end
    if toolName == "Gun" then delayMs = _G.SkillDelayGun or 100 end
    if toolName == "Fruit" then delayMs = _G.SkillDelayFruit or 100 end
    return delayMs / 1000
end

task.spawn(function()
    while task.wait() do 
        pcall(function()
            if getgenv().CurrentTarget and getgenv().CurrentTargetPart and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                if (getgenv().CurrentTargetPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 50 then
                    if SkillConfig["Auto Enable V3"] then
                        if SkillConfig["Custom Health"] and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health <= SkillConfig["Health"] then
                            down("T", 0.1)
                        end
                    end
                    if SkillConfig["Auto Enable V4"] then
                        if LP.Character:FindFirstChild("RaceEnergy") and LP.Character.RaceEnergy.Value == 1 then
                            Useskills("nil", "Y")
                        end
                    end
                end
            end
        end)
    end
end)

local HttpService = game:GetService("HttpService")
local FILE_NAME = "Meyy_Leviathan_Kaitun/Name.json"

local function GetPartyFromJSON()
    if getgenv().FetchUnifiedPartyData then
        return getgenv().FetchUnifiedPartyData()
    end
    return nil
end

getgenv().LastSpawnTime = os.time()

task.spawn(function()
    local LP = game:GetService("Players").LocalPlayer
    if LP.Character then
        getgenv().LastSpawnTime = os.time()
    end
    LP.CharacterAdded:Connect(function()
        getgenv().LastSpawnTime = os.time()
    end)
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.DangSan then
                return
            end
            if os.time() - getgenv().LastSpawnTime < 20 then
                return
            end
            local w = game:GetService("Players")
            local S = w.LocalPlayer
            local isSomeoneDead = false
            local rawData = GetPartyFromJSON()

            if rawData then
                for _, acc in pairs(rawData) do
                    local memberName = acc.Name
                    if memberName ~= S.Name then
                        local member = w:FindFirstChild(memberName)
                        if member then
                            local mChar = member.Character
                            local mHum = mChar and mChar:FindFirstChild("Humanoid")
                            if mChar and mHum and mHum.Health <= 0 then
                                isSomeoneDead = true
                                break
                            end
                        end
                    end
                end
            end

            if isSomeoneDead then
                local target = GetNearestSeaEvent()
                local isLeviathan = target and (target.Name == "Leviathan Segment" or target.Name == "Leviathan")
                local isFoundWatcher, _ = getFrozenWatcherPosition()
                local isFoundHeart, _1, _2 = GetFrozenHeartData()
                
                if not isLeviathan and not isFoundWatcher and not isFoundHeart then
                    print("Someone in the party is dead. Attempting to kill self to respawn.")
                    if S.Character and S.Character:FindFirstChild("Humanoid") then
                        if S.Character.Humanoid.Health > 0 then
                            S.Character.Humanoid.Health = 0
                            getgenv().LastSpawnTime = os.time()
                        end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            if getgenv().DangSafeMode then return end
            if not getgenv().CurrentTarget or not getgenv().CurrentTargetPart then return end
            if getgenv().IsPureM1 then return end
            
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local targetPos = getgenv().CurrentTargetPart.Position
            local myPos = hrp.Position
            local distXZ = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            
            if distXZ > 150 then return end

            local toolMappings = {
                ["Melee"] = _G.SelectedMelee or {},
                ["Sword"] = _G.SelectedSword or {},
                ["Gun"] = _G.SelectedGun or {},
                ["Fruit"] = _G.SelectedFruit or {}
            }
            
            local queue = {}
            for typeName, selectedList in pairs(toolMappings) do
                if getgenv().UseOnlyGunSkill and typeName ~= "Gun" then
                    continue
                end
                
                if SkillConfig[typeName] and SkillConfig[typeName].Enable then
                    for skillKey, skillData in pairs(SkillConfig[typeName]) do
                        if type(skillData) == "table" and skillData.Priority then
                            skillData.Enable = table.find(selectedList, skillKey) ~= nil
                            
                            if skillData.Enable then
                                table.insert(queue, {
                                    Type = typeName,
                                    Key = skillKey,
                                    Data = skillData
                                })
                            end
                        end
                    end
                end
            end
            
            table.sort(queue, function(a, b) return a.Data.Priority < b.Data.Priority end)
            
            for _, item in ipairs(queue) do
                local toolName = equip(item.Type)
                if toolName then
                    local skillGui = LP.PlayerGui.Main.Skills:FindFirstChild(toolName)
                    if skillGui and skillGui:FindFirstChild(item.Key) then
                        local titleLabel = skillGui[item.Key]:FindFirstChild("Title")
                        if titleLabel and titleLabel:IsA("TextLabel") and titleLabel.TextColor3 == Color3.fromRGB(255, 255, 255) then
                            local cdGui = skillGui[item.Key]:FindFirstChild("Cooldown")
                            if cdGui and cdGui.AbsoluteSize.X <= 0 then
                                local useDelay = getDelay(item.Type)
                                for i = 1, (item.Data.Count or 1) do
                                    if cdGui.AbsoluteSize.X > 0 then
                                        break
                                    end
                                    down(item.Key, item.Data.HoldTime)
                                    task.wait(useDelay)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local PlayerMouse = game:GetService("Players").LocalPlayer:GetMouse()
local MT = getrawmetatable(game)
local OldNameCall = MT.__namecall
local OldIndex = MT.__index
setreadonly(MT, false)

MT.__index = newcclosure(function(self, key)
    if (key == "Hit" or key == "Target") then
        if not checkcaller() and self == PlayerMouse then
            local targetPart = getgenv().CurrentTargetPart
            if targetPart then
                if key == "Hit" then
                    return getgenv().MacroAimPos or CFrame.new(targetPart.Position)
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
    end
    return OldIndex(self, key)
end)

MT.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    
    if (Method == "FireServer" or Method == "InvokeServer") and not checkcaller() and getgenv().MacroAimPos then
        local Args = {...}
        local rawTarget = getgenv().CurrentTargetPart
        local fireAimPos = getgenv().MacroAimPos.Position

        if Method == "FireServer" and typeof(self) == "Instance" and (self.Name == "RemoteEvent" or self.ClassName == "RemoteEvent") then
            local arg1str = tostring(Args[1])
            if arg1str ~= "true" and arg1str ~= "false" then
                for i, v in ipairs(Args) do
                    local t1 = typeof(v)
                    if t1 == "Vector3" then
                        Args[i] = fireAimPos
                    elseif t1 == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif t1 == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    end
                end
                return OldNameCall(self, unpack(Args))
            end
            
        elseif Method == "InvokeServer" and typeof(self) == "Instance" and self.ClassName == "RemoteFunction" then
            local skill = tostring(Args[1])
            local isSkill = (typeof(skill) == "string" and string.len(skill) == 1 and skill:match("%u"))
            
            if isSkill then
                local function scanTable(t)
                    for tk, tv in pairs(t) do
                        local typeTv = typeof(tv)
                        if typeTv == "Vector3" then
                            t[tk] = fireAimPos
                        elseif typeTv == "CFrame" then
                            t[tk] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                        elseif typeTv == "table" then
                            scanTable(tv)
                        end
                    end
                end

                for i, v in ipairs(Args) do
                    local typeV = typeof(v)
                    if typeV == "Vector3" then
                        Args[i] = fireAimPos
                    elseif typeV == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif typeV == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    elseif typeV == "Instance" and (v:IsA("BasePart") or v:IsA("Model")) then
                        if rawTarget then Args[i] = rawTarget end
                    elseif typeV == "table" then
                        scanTable(v)
                    end
                end
                
                if typeof(Args[2]) == "Vector3" or typeof(Args[2]) == "CFrame" then
                    if rawTarget then
                        Args[3] = rawTarget
                    end
                end
                
                return OldNameCall(self, unpack(Args))
            else
                for i, v in ipairs(Args) do
                    local typeV = typeof(v)
                    if typeV == "Vector3" then
                        Args[i] = fireAimPos
                    elseif typeV == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif typeV == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    end
                end
                return OldNameCall(self, unpack(Args))
            end
        end
    end
    
    return OldNameCall(self, ...)
end)

setreadonly(MT, true)

local GunValidator = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")
local AimBotSkillPosition = nil 

pcall(function()
    local gg = getrawmetatable(game);
    local old = gg.__namecall;
    setreadonly(gg, false);

    gg.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod();
        local args = { ... }
        
        if _G.UseGunEvent and tostring(method) == "FireServer" and tostring(self) == "ShootGunEvent" then
            if AimBotSkillPosition then
                args[1] = AimBotSkillPosition 
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end);
end)

local function FindNearestMob()
    return getgenv().CurrentTarget 
end

local function GetValidator2(shootFunc)
    if not getupvalue or not setupvalue or not shootFunc then return nil, nil end
    local success, v1_val, v7_val = pcall(function()
        local u27 = getupvalue(shootFunc, 13)
        local u23 = getupvalue(shootFunc, 14)
        local u26 = getupvalue(shootFunc, 15)
        local u22 = getupvalue(shootFunc, 16)
        local u24 = getupvalue(shootFunc, 17)
        local u25 = getupvalue(shootFunc, 18)
        local u28 = getupvalue(shootFunc, 19)
        
        local u81 = u27 * u23
        local u82 = (u26 * u23 + u27 * u22) % u24
        u82 = (u82 * u24 + u81) % u25
        u26 = math.floor(u82 / u24)
        u27 = u82 - u26 * u24
        u28 = u28 + 1
        
        setupvalue(shootFunc, 13, u27)
        setupvalue(shootFunc, 14, u23)
        setupvalue(shootFunc, 15, u26)
        setupvalue(shootFunc, 16, u22)
        setupvalue(shootFunc, 17, u24)
        setupvalue(shootFunc, 18, u25)
        setupvalue(shootFunc, 19, u28)
        
        return math.floor(u82 / u25 * 16777215), u28
    end)
    if success and v1_val and v7_val then 
        return v1_val, v7_val 
    end
    return nil, nil
end

task.spawn(function()
    while true do
        if _G.UseGunEvent then
            local targetMob = FindNearestMob()
            if targetMob and getgenv().CurrentTargetPart then
                local targetPos = getgenv().CurrentTargetPart.Position
                local partToShoot = getgenv().CurrentTargetPart
                
                if targetPos then
                    AimBotSkillPosition = targetPos 
                    pcall(function()
                        local NetModule = require(ReplicatedStorage.Modules.Net)
                        NetModule:RemoteEvent("ShootGunEvent"):FireServer(targetPos, {partToShoot})
                    end)
                end
            end
        else
            AimBotSkillPosition = nil 
        end
        task.wait()
    end
end)

task.spawn(function()
    local CombatController, ShootFunction
    pcall(function()
        local Modules = ReplicatedStorage:WaitForChild("Modules")
        CombatController = require(ReplicatedStorage.Controllers.CombatController)
        if getupvalue then
            ShootFunction = getupvalue(CombatController.Attack, 9)
        end
    end)

    while true do
        if _G.UseGunEvent then
            local targetMob = FindNearestMob()
            if targetMob and getgenv().CurrentTargetPart then
                local targetPos = getgenv().CurrentTargetPart.Position
                
                if targetPos then
                    pcall(function()
                        if ShootFunction and GunValidator then
                            local val1, val2 = GetValidator2(ShootFunction)
                            if val1 and val2 then
                                GunValidator:FireServer(val1, val2)
                            end
                        end
                        local NetModule = require(ReplicatedStorage.Modules.Net)
                        NetModule:RemoteEvent("ShootGunEvent"):FireServer(targetPos)
                    end)
                end
            end
            task.wait(1.95) 
        else
            task.wait(1) 
        end
    end
end)


-- ----------------------------------------------------------------
-- Helper: convert CentuLibrary multi-dropdown result → plain array
-- ----------------------------------------------------------------

local HuntTab = Window:CreateTab({ Name = "Hunt Levi" })

-- ── FPS & Visuals ─────────────────────────────────────────────
local SecFPS = HuntTab:CreateSection("FPS & Visuals")

SecFPS:AddToggle({
    Text    = "Remove Fog",
    Default = true,
    Callback = function(val) _G.XoaSuongMu = val end
})

_G.BoostFPS_Executed = false
SecFPS:AddToggle({
    Text    = "Boost FPS",
    Default = false,
    Callback = function(val)
        if val and not _G.BoostFPS_Executed then
            _G.BoostFPS_Executed = true
            task.spawn(function()
                local CFG = {
                    soundOff=true, lowQuality=true, postFXOff=true, zeroWater=true,
                    hide={geometry=true, castShadowOff=true, reflectance0=true, materialPlastic=true, includeCharacter=true},
                    kill={particles=true, lights=true, decals=true, ui3d=true, prompts=true, highlights=true, clothes=true, accessories=true},
                    batchSize=2000, hookNewSpawn=true,
                }
                local S = setmetatable({},{__index=function(t,k) local s=game:GetService(k) rawset(t,k,s) return s end})
                local RunService,Workspace,Lighting,Players,ReplicatedStorage =
                    S.RunService,S.Workspace,S.Lighting,S.Players,S.ReplicatedStorage
                local _LP = Players.LocalPlayer
                local function safe(_,f) pcall(f) end
                if CFG.soundOff then safe(nil,function() UserSettings():GetService("UserGameSettings").MasterVolume=0 end) end
                if CFG.lowQuality then safe(nil,function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end) end
                local t=Workspace.Terrain
                if CFG.zeroWater then t.WaterWaveSize,t.WaterWaveSpeed=0,0 t.WaterReflectance=0 t.WaterTransparency=1 end
                sethiddenproperty(Lighting,"Technology",2)
                sethiddenproperty(t,"Decoration",false)
                Lighting.GlobalShadows=0 Lighting.FogEnd=9e9 Lighting.Brightness=0
                if CFG.postFXOff then
                    for _,e in ipairs(Lighting:GetChildren()) do
                        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                        or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end
                    end
                end
                if not _G.FastMode then
                    _G.FastMode=true _G.reducing=true _G.FastModeCache={}
                    local Map=Workspace:FindFirstChild("Map")
                    local Unloaded=ReplicatedStorage:FindFirstChild("Unloaded")
                    local SP=Enum.Material.SmoothPlastic
                    local function optimize(list)
                        local st=os.clock()
                        for _,obj in ipairs(list) do
                            if obj:IsA("BasePart") then _G.FastModeCache[obj]=obj.Material obj.Material=SP
                            elseif obj:IsA("Texture") and not obj:GetAttribute("Offset") then obj:Destroy() end
                            if os.clock()-st>0.008 then task.wait() st=os.clock() end
                        end
                    end
                    if Map then optimize(Map:GetDescendants()) end
                    if Unloaded then optimize(Unloaded:GetDescendants()) end
                    local Opt=_LP.PlayerScripts:FindFirstChild("OptimizerClientActor")
                    if Opt and Opt.SendMessage then Opt:SendMessage("Optimize",true) end
                end
                _LP:SetAttribute("DisableAllyEffects",true)
                pcall(function() require(ReplicatedStorage.Util.CameraShake):SetEnabled(false) end)
                pcall(function() require(ReplicatedStorage.Util.CameraShaker):SetEnabled(false) end)
                pcall(function() ReplicatedStorage.Remotes.ChangeSetting:FireServer("CameraShake",false) end)
                pcall(function() game.ReplicatedStorage.Events.ToggleMusic.Event:Fire(true) end)
                for _,s in pairs(Workspace._WorldOrigin.Sounds.Locations:GetChildren()) do
                    if s:IsA("Sound") then s:Pause() end
                end
                local function hideGeo(obj)
                    if not CFG.hide.geometry or not obj:IsA("BasePart") or obj.Transparency==1 then return end
                    if CFG.hide.castShadowOff then obj.CastShadow=false end
                    if CFG.hide.reflectance0 then obj.Reflectance=0 end
                    if obj.Material~=Enum.Material.Plastic then obj.Material=Enum.Material.Plastic end
                end
                local function cull(obj)
                    if not obj or not obj.Parent then return end
                    hideGeo(obj)
                    if CFG.kill.particles and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                    or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")) then
                        if obj:IsA("ParticleEmitter") then obj.Rate=0 end
                        if obj:IsA("Trail") then obj.Lifetime=NumberRange.new(0) end
                        if obj.Enabled~=nil then obj.Enabled=false end return
                    end
                    if CFG.kill.lights and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
                        obj.Enabled=false return
                    end
                    if CFG.kill.decals then
                        if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1 return end
                        if obj:IsA("SurfaceAppearance") then safe(nil,function() obj.ColorMap="rbxassetid://0" end) return end
                    end
                    if obj:IsA("Explosion") then obj.BlastPressure=1 obj.BlastRadius=1 end
                end
                local processed=setmetatable({},{__mode="k"}) local queue2={}
                local function push(x) if x and not processed[x] then queue2[#queue2+1]=x processed[x]=true end end
                local function pop2() local n=#queue2 if n==0 then return end local v=queue2[n] queue2[n]=nil return v end
                for _,v in ipairs(Workspace:GetDescendants()) do push(v) end
                for _,v in ipairs(Lighting:GetDescendants()) do push(v) end
                if CFG.hookNewSpawn then
                    Workspace.DescendantAdded:Connect(push)
                    Lighting.DescendantAdded:Connect(push)
                end
                RunService.Heartbeat:Connect(function()
                    local n=0
                    while n<CFG.batchSize do local obj=pop2() if not obj then break end if obj.Parent then cull(obj) end n+=1 end
                end)
                local function simpChar(char)
                    if not char then return end
                    for _,ch in ipairs(char:GetChildren()) do
                        if ch:IsA("Accessory") or ch:IsA("Shirt") or ch:IsA("Pants") or ch:IsA("ShirtGraphic") then
                            safe(nil,function() ch:Destroy() end)
                        end
                    end
                    local anim=char:FindFirstChild("Animate")
                    if anim and anim:IsA("LocalScript") then safe(nil,function() anim.Disabled=true end) end
                end
                if _LP.Character then simpChar(_LP.Character) end
                _LP.CharacterAdded:Connect(function(c) c:WaitForChild("HumanoidRootPart",10) simpChar(c) end)
            end)
        end
    end
})

-- ── Sea Event & Setup ──────────────────────────────────────────
local SecEvent = HuntTab:CreateSection("Sea Event & Setup")

SecEvent:AddToggle({
    Text    = "Use Gun For Sea Event",
    Default = false,
    Callback = function(val) _G.UseGunEvent = val end
})
SecEvent:AddToggle({
    Text    = "Use M1 Fruit For Sea Event",
    Default = false,
    Callback = function(val) _G.UseM1FruitEvent = val end
})
SecEvent:AddMultiDropdown({
    Text    = "Select Sea Events",
    Options = {"Piranha","Terrorshark","Shark","PirateBrigade","PirateGrandBrigade","FishBoat","Sea Beast","Leviathan"},
    Default = {"Leviathan"},
    Callback = function(val) _G.SelectedEvents = MultiCb(val) end
})

-- ── Boat Setup ────────────────────────────────────────────────
local SecBoat = HuntTab:CreateSection("Boat Setup")

local _playerList = {}
for _,p in ipairs(Players:GetPlayers()) do table.insert(_playerList, p.Name) end

local function _FormatBoat(name)
    if name=="Beast Hunter" then return "Beast Hunter" end
    return string.gsub(name,"%s+","")
end
local function _GetBoatOptions()
    local pfx=(_G.ChonPhe=="Marines" or _G.ChonPhe=="Marine") and "Marine " or "Pirate "
    return {pfx.."Sloop", pfx.."Brigade", pfx.."Grand Brigade", "Beast Hunter"}
end

local _curBoat = "Beast Hunter"
_G.TenThuyen  = _FormatBoat(_curBoat)

local BoatDd = SecBoat:AddDropdown({
    Text     = "Select Boat",
    Options  = _GetBoatOptions(),
    Default  = "Beast Hunter",
    Callback = function(val)
        _curBoat = val
        _G.TenThuyen = _FormatBoat(val)
    end
})

task.spawn(function()
    local lastTeam=_G.ChonPhe
    while task.wait(1) do
        if _G.ChonPhe~=lastTeam then
            lastTeam=_G.ChonPhe
            if BoatDd and BoatDd.SetOptions then BoatDd:SetOptions(_GetBoatOptions()) end
            _curBoat="Beast Hunter" _G.TenThuyen=_FormatBoat(_curBoat)
        end
    end
end)

local BoatBuyerDd = SecBoat:AddDropdown({
    Text     = "Account Buy Boat",
    Options  = _playerList,
    Default  = _playerList[1],
    Callback = function(val)
        _G.NguoiMuaThuyen = val
        local msg = (val==LP.Name) and "You are the boat buyer" or "You are the helper clone"
        Library:Notify({ Title="Role Update", Content=msg, Type="Info", Duration=3 })
    end
})

SecBoat:AddButton({
    Text     = "Refresh Player List",
    Callback = function()
        local fresh={}
        for _,p in ipairs(Players:GetPlayers()) do table.insert(fresh, p.Name) end
        if BoatBuyerDd and BoatBuyerDd.SetOptions then BoatBuyerDd:SetOptions(fresh) end
        Library:Notify({ Title="System", Content="Player list refreshed", Type="Success", Duration=3 })
    end
})

SecBoat:AddDropdown({
    Text     = "Required Players",
    Options  = {"1","2","3","4","5","6"},
    Default  = "5",
    Callback = function(val)
        _G.SoNguoiCanThiet = tonumber(val)
        Library:Notify({ Title="Hunt Config", Content="Required players: "..val, Type="Info", Duration=3 })
    end
})

-- ── Drive Boat & Shoot Heart ───────────────────────────────────
local SecHeart = HuntTab:CreateSection("Drive Boat & Shoot Heart")

SecHeart:AddToggle({
    Text    = "Drive Boat To Tiki",
    Default = false,
    Callback = function(val) _uDriveTiki=val if val then _uDriveHydra=false end end
})
SecHeart:AddToggle({
    Text    = "Drive Boat To Hydra",
    Default = false,
    Callback = function(val) _uDriveHydra=val if val then _uDriveTiki=false end end
})
SecHeart:AddSlider({
    Text      = "Pull Y Height",
    Min       = 0, Max=100, Default=35, Increment=1,
    Callback  = function(val) _G.PullYHeight=val end
})
SecHeart:AddToggle({
    Text    = "Shoot Heart",
    Default = false,
    Callback = function(val) _G.ShootHeart=val end
})

-- ── Hunt Leviathan ────────────────────────────────────────────
local SecHunt = HuntTab:CreateSection("Hunt Leviathan")

SecHunt:AddToggle({
    Text    = "Destroy IDK",
    Default = false,
    Callback = function(val) _G.DestroyIDK=val end
})
SecHunt:AddParagraph({
    Title   = "Destroy IDK Info",
    Content = "[ON] Focus 100% on Levi, destroy IDK after kill.\n[OFF] Multi-task: fight all nearby sea events while searching."
})
SecHunt:AddToggle({
    Text    = "Start Hunt",
    Default = false,
    Callback = function(val)
        _G.DangSan=val
        Library:Notify({
            Title   = "Hunt Status",
            Content = val and "Hunting Started" or "Hunting Stopped",
            Type    = val and "Success" or "Warning",
            Duration = 4
        })
    end
})

-- ================================================================
-- TAB 2 — SETTINGS
-- ================================================================
local SettTab = Window:CreateTab({ Name = "Settings" })

-- ── General Config ────────────────────────────────────────────
local SecGen = SettTab:CreateSection("General Config")

SecGen:AddDropdown({
    Text     = "Select Team",
    Options  = {"Marines","Pirates"},
    Default  = "Marines",
    Callback = function(val)
        _G.ChonPhe=val
        Library:Notify({ Title="Team Setup", Content="Team set to "..val, Type="Info", Duration=3 })
    end
})
SecGen:AddDropdown({
    Text     = "Select Weapon",
    Options  = {"Melee","Sword","Blox Fruit","Gun"},
    Default  = "Melee",
    Callback = function(val) _G.SelectedWeapon=val end
})
SecGen:AddToggle({ Text="Spin Position",          Default=true,  Callback=function(v) _G.SpinPosition=v end })
SecGen:AddToggle({ Text="Enable Ignore Sea Event", Default=true,  Callback=function(v) _G.EnableIgnoreSeaEvent=v end })
SecGen:AddToggle({ Text="Enable Ignore Island",    Default=true,  Callback=function(v) _G.EnableIgnoreIsland=v end })
_G.SafeFlyingBoat=true
SecGen:AddToggle({ Text="Safe Flying Boat",        Default=true,  Callback=function(v) _G.SafeFlyingBoat=v end })
SecGen:AddToggle({
    Text    = "Enable Noclip",
    Default = true,
    Callback = function(val)
        _G.BatNoclip=val
        Library:Notify({ Title="Noclip", Content=val and "Enabled" or "Disabled", Type="Info", Duration=3 })
    end
})
_G.AutoBuso=true
SecGen:AddToggle({ Text="Auto Buso Haki",        Default=true, Callback=function(v) _G.AutoBuso=v end })
_G.AutoV3=true
SecGen:AddToggle({ Text="Auto V3",               Default=true, Callback=function(v) _G.AutoV3=v end })
_G.AutoKen=true
SecGen:AddToggle({ Text="Auto Observation Haki", Default=true, Callback=function(v) _G.AutoKen=v end })

-- ── Movement Config ───────────────────────────────────────────
local SecMove = SettTab:CreateSection("Movement Config")

SecMove:AddSlider({ Text="Tween Speed",        Min=50, Max=500, Default=170, Increment=1, Callback=function(v) _G.TocDoTween=v end })
SecMove:AddSlider({ Text="Tween Boat Speed",   Min=50, Max=500, Default=250, Increment=1, Callback=function(v) _G.TocDoTweenBoat=v end })
SecMove:AddSlider({ Text="Flight Height",      Min=10, Max=500, Default=20,  Increment=1, Callback=function(v) _G.ChieuCaoBay=v end })
SecMove:AddSlider({ Text="Ignore Height",      Min=50, Max=1500,Default=500, Increment=1, Callback=function(v) _G.IgnoreHeight=v end })
SecMove:AddSlider({ Text="Ignore Island Height",Min=50,Max=2000,Default=800, Increment=1, Callback=function(v) _G.IgnoreIslandHeight=v end })
_G.SafeHeightY=400
SecMove:AddSlider({ Text="Safe Height Y",      Min=50, Max=1000,Default=400, Increment=1, Callback=function(v) _G.SafeHeightY=v end })
_G.SafeRadius=250
SecMove:AddSlider({ Text="Safe Orbit Radius",  Min=0,  Max=500, Default=250, Increment=1, Callback=function(v) _G.SafeRadius=v end })

-- ================================================================
-- TAB 3 — SHOP & STATUS
-- ================================================================
local ShopTab = Window:CreateTab({ Name = "Shop" })

-- ── Server Status ─────────────────────────────────────────────
local SecStatus = ShopTab:CreateSection("Server Status")

local SpyPara    = SecStatus:AddParagraph({ Title="Spy Status",       Content="Loading..." })
local FrozenPara = SecStatus:AddParagraph({ Title="Frozen Dimension", Content="Loading..." })

task.spawn(function()
    while task.wait(1) do pcall(function()
        local spyText
        if     _G.SpyCheckResult==-1 then spyText="I Don't Know"
        elseif _G.SpyCheckResult>=1 and _G.SpyCheckResult<=4 then spyText="Done Destroy — Can Bride "..(5-_G.SpyCheckResult).." More"
        elseif _G.SpyCheckResult==5 then spyText="Done Bride — Can Find Levi"
        else spyText="I Don't Know" end
        if SpyPara then
            pcall(function() SpyPara:Set({Title="Spy Status", Content=spyText}) end)
            pcall(function() SpyPara:Set("Spy Status", spyText) end)
        end
        local isFoundWatcher = getFrozenWatcherPosition()
        local frozenText = isFoundWatcher and "Frozen Dimension Found In Server" or "No Frozen Dimension In Server"
        if FrozenPara then
            pcall(function() FrozenPara:Set({Title="Frozen Dimension", Content=frozenText}) end)
            pcall(function() FrozenPara:Set("Frozen Dimension", frozenText) end)
        end
    end) end
end)

-- ── Random Fruit ──────────────────────────────────────────────
local SecFruit = ShopTab:CreateSection("Random Fruit")

SecFruit:AddToggle({ Text="Auto Random Fruit", Default=true, Callback=function(v) _G.AutoRandomFruit=v end })
SecFruit:AddToggle({ Text="Auto Store Fruit",  Default=true, Callback=function(v) _G.AutoStoreFruit=v end })

task.spawn(function()
    while task.wait(60) do
        if _G.AutoRandomFruit then pcall(function()
            local Net=game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
            Net:WaitForChild("RF/GachaNetworkRF"):InvokeServer({BoxName="ZiolesGacha",Context="Check",SpokeNPC="Blox Fruit Gacha"})
            task.wait(1)
            Net:WaitForChild("RF/GachaNetworkRF"):InvokeServer({Context="Purchase",BoxName="ZiolesGacha"})
        end) end
    end
end)

local _lastStoredFruit,_fruitAttempts=nil,0
task.spawn(function()
    while task.wait(1) do
        if _G.AutoStoreFruit then pcall(function()
            local char=LP.Character local bp=LP:FindFirstChild("Backpack") local fruit=nil
            local function isFruit(t) return t:IsA("Tool") and (t:GetAttribute("Fruit") or string.find(t.Name,"Fruit")) end
            if char then for _,t in ipairs(char:GetChildren()) do if isFruit(t) then fruit=t break end end end
            if not fruit and bp then for _,t in ipairs(bp:GetChildren()) do if isFruit(t) then fruit=t break end end end
            if fruit then
                if _lastStoredFruit~=fruit then _lastStoredFruit=fruit _fruitAttempts=0 end
                if _fruitAttempts<10 then
                    local fname=fruit:GetAttribute("OriginalName") or fruit:GetAttribute("FruitName") or fruit.Name
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StoreFruit",fname,fruit)
                    _fruitAttempts+=1
                end
            else _lastStoredFruit=nil _fruitAttempts=0 end
        end) end
    end
end)

-- ── Shop ──────────────────────────────────────────────────────
local SecShop = ShopTab:CreateSection("Shop")

SecShop:AddButton({ Text="Reroll Race", Callback=function()
    local RS=game:GetService("ReplicatedStorage")
    RS.Remotes.CommF_:InvokeServer("BlackbeardReward","Reroll","1")
    RS.Remotes.CommF_:InvokeServer("BlackbeardReward","Reroll","2")
end})
SecShop:AddButton({ Text="Reset Stats", Callback=function()
    local RS=game:GetService("ReplicatedStorage")
    RS.Remotes.CommF_:InvokeServer("BlackbeardReward","Refund","1")
    RS.Remotes.CommF_:InvokeServer("BlackbeardReward","Refund","2")
end})
SecShop:AddButton({ Text="Buy Ghoul Race",  Callback=function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Ectoplasm","Change",4) end})
SecShop:AddButton({ Text="Buy Cyborg Race", Callback=function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CyborgTrainer","Buy") end})
SecShop:AddButton({ Text="Buy Draco Race",  Callback=function()
    task.spawn(function()
        local npcPos=NpcPositions["Dragon Wizard"] if not npcPos then return end
        getgenv().DangDiMuaDo=true
        if getgenv().Meyy6Race_API then getgenv().Meyy6Race_API.SetTask("Moving to NPC") getgenv().Meyy6Race_API.SetTheme("Dark") end
        DiChuyenDen(CFrame.new(npcPos))
        while task.wait(0.1) do
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position-npcPos).Magnitude<=15 then
                DungDiChuyen()
                local Net=game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
                Net:WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC="Dragon Wizard",Command="Speak"})
                task.wait(0.5)
                Net:WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC="Dragon Wizard",Command="DragonRace"})
                getgenv().DangDiMuaDo=false break
            end
        end
    end)
end})

-- ── Buy Melee ─────────────────────────────────────────────────
local SecMelee = ShopTab:CreateSection("Buy Melee")

local MeleeConfig = {
    {Name="Sanguine Art",    NPC="Shafi",                Remote="BuySanguineArt"},
    {Name="Godhuman",        NPC="Ancient Monk",         Remote="BuyGodhuman"},
    {Name="Dragon Talon",    NPC="Uzoth",                Remote="BuyDragonTalon"},
    {Name="Electric Claw",   NPC="Previous Hero",        Remote="BuyElectricClaw"},
    {Name="Sharkman Karate", NPC="Sharkman Teacher",     Remote="BuySharkmanKarate"},
    {Name="Death Step",      NPC="Phoeyu, the Reformed", Remote="BuyDeathStep"},
    {Name="Superhuman",      NPC="Martial Arts Master",  Remote="BuySuperhuman"},
}
for _,melee in ipairs(MeleeConfig) do
    local tVar="AutoBuy_"..string.gsub(melee.Name," ","")
    local cap=melee
    _G[tVar]=false
    SecMelee:AddToggle({
        Text    = "Buy "..melee.Name,
        Default = false,
        Callback = function(val)
            _G[tVar]=val
            if val then
                task.spawn(function()
                    local npcPos=NpcPositions[cap.NPC] if not npcPos then return end
                    getgenv().DangDiMuaDo=true
                    DiChuyenDen(CFrame.new(npcPos))
                    while _G[tVar] do
                        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position-npcPos).Magnitude<=15 then
                            DungDiChuyen()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(cap.Remote)
                            _G[tVar]=false getgenv().DangDiMuaDo=false break
                        end
                        task.wait(0.2)
                    end
                end)
            else getgenv().DangDiMuaDo=false DungDiChuyen() end
        end
    })
end

-- ================================================================
-- TAB 4 — CRAFT SCROLLS
-- ================================================================
local CraftTab = Window:CreateTab({ Name = "Craft" })
local SecCraft = CraftTab:CreateSection("Auto Craft Config")

SecCraft:AddMultiDropdown({
    Text     = "Select Scrolls",
    Options  = {"Common Scroll","Rare Scroll","Legendary Scroll","Mythical Scroll"},
    Default  = {},
    Callback = function(val) _G.SelectedScrolls=MultiCb(val) end
})
SecCraft:AddToggle({ Text="Enable Auto Craft", Default=false, Callback=function(v) _G.AutoCraftScrollSwitch=v end })
SecCraft:AddSlider({ Text="Common Scroll Cap",    Min=0, Max=50, Default=0,  Increment=1, Callback=function(v) ScrollCaps.CommonScroll=v end })
SecCraft:AddSlider({ Text="Rare Scroll Cap",      Min=0, Max=50, Default=0,  Increment=1, Callback=function(v) ScrollCaps.RareScroll=v end })
SecCraft:AddSlider({ Text="Legendary Scroll Cap", Min=0, Max=15, Default=15, Increment=1, Callback=function(v) ScrollCaps.LegendaryScroll=v end })
SecCraft:AddSlider({ Text="Mythical Scroll Cap",  Min=0, Max=10, Default=10, Increment=1, Callback=function(v) ScrollCaps.MythicalScroll=v end })

task.spawn(function()
    while task.wait(2) do pcall(function()
        if _G.AutoCraftScrollSwitch and type(_G.SelectedScrolls)=="table" then
            for _,name in ipairs(_G.SelectedScrolls) do AutoCraftScroll(name) end
        end
    end) end
end)

-- ================================================================
-- TAB 5 — SKILLS
-- ================================================================
local SkillTab = Window:CreateTab({ Name = "Skills" })
local SecSkill = SkillTab:CreateSection("Auto Skill Config")

SecSkill:AddMultiDropdown({ Text="Melee Skills",      Options={"Z","X","C"},       Default={"Z","X","C"},   Callback=function(v) _G.SelectedMelee=MultiCb(v) end })
SecSkill:AddMultiDropdown({ Text="Blox Fruit Skills", Options={"Z","X","C","V","F"},Default={"Z","X","C","F"},Callback=function(v) _G.SelectedFruit=MultiCb(v) end })
SecSkill:AddMultiDropdown({ Text="Gun Skills",        Options={"Z","X"},           Default={"Z","X"},       Callback=function(v) _G.SelectedGun=MultiCb(v) end })
SecSkill:AddMultiDropdown({ Text="Sword Skills",      Options={"Z","X"},           Default={"Z","X"},       Callback=function(v) _G.SelectedSword=MultiCb(v) end })

local SecDelay = SkillTab:CreateSection("Delay Config")

_G.SkillDelayMelee=100
SecDelay:AddSlider({ Text="Melee Delay (ms)", Min=0, Max=1000, Default=100, Increment=1, Callback=function(v) _G.SkillDelayMelee=v end })
_G.SkillDelayFruit=100
SecDelay:AddSlider({ Text="Fruit Delay (ms)", Min=0, Max=1000, Default=100, Increment=1, Callback=function(v) _G.SkillDelayFruit=v end })
_G.SkillDelayGun=100
SecDelay:AddSlider({ Text="Gun Delay (ms)",   Min=0, Max=1000, Default=100, Increment=1, Callback=function(v) _G.SkillDelayGun=v end })
_G.SkillDelaySword=100
SecDelay:AddSlider({ Text="Sword Delay (ms)", Min=0, Max=1000, Default=100, Increment=1, Callback=function(v) _G.SkillDelaySword=v end })
_G.NoSkillDelay=true
SecDelay:AddToggle({ Text="Use Skill No Delay", Default=true, Callback=function(v) _G.NoSkillDelay=v end })

-- ================================================================
-- BACKGROUND LOOPS
-- ================================================================
task.spawn(function()
    while task.wait(0.5) do pcall(function()
        if _G.AutoBuso then
            local char=LP.Character
            if char and not char:FindFirstChild("HasBuso") then ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end
        end
    end) end
end)
task.spawn(function()
    while task.wait(1) do pcall(function()
        if _G.AutoV3 then ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility") end
    end) end
end)
task.spawn(function()
    while task.wait(0.5) do pcall(function()
        if _G.AutoKen then
            local char=LP.Character
            if char and not char:FindFirstChild("HasObservation") then
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommE"):FireServer("Ken",true)
            end
        end
    end) end
end)

_G.DaResetLeviathan=false
local _dangResetLevi=false
task.spawn(function()
    while task.wait(0.5) do pcall(function()
        if _dangResetLevi then return end
        if not _G.DangSan then _G.DaResetLeviathan=false return end
        local target=GetNearestSeaEvent()
        local isLevi=target and (target.Name=="Leviathan Segment" or target.Name=="Leviathan")
        if isLevi then
            if not _G.DaResetLeviathan then
                _dangResetLevi=true _G.DaResetLeviathan=true task.wait()
                if _G.DangSan then
                    _G.DangSan=false
                    if getgenv().Meyy6Race_API then getgenv().Meyy6Race_API.SetTask("Waiting Leviathan") getgenv().Meyy6Race_API.SetTheme("Mint") end
                    task.wait(9) _G.DangSan=true
                end
                _dangResetLevi=false
            end
        else _G.DaResetLeviathan=false end
    end) end
end)

task.spawn(function()
    local plrRef=game:GetService("Players").LocalPlayer
    while task.wait(0.2) do
        local char=plrRef.Character
        if char and char:FindFirstChild("RaceEnergy") and char.RaceEnergy.Value>=1 then pcall(function()
            local aw=plrRef.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
            if aw and aw:FindFirstChild("RemoteFunction") then aw.RemoteFunction:InvokeServer(true) end
        end) end
    end
end)

-- Safe Flying Boat loop (full)
local _oldMovers={} local _dodgeAngle=0 local _isFlyingSafe=false
task.spawn(function()
    while task.wait() do pcall(function()
        local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local thuyen=KiemTraThuyen()
        local vSeat=thuyen and (thuyen:FindFirstChild("VehicleSeat") or thuyen:FindFirstChildWhichIsA("VehicleSeat",true))
        local mPart=thuyen and (thuyen.PrimaryPart or vSeat or thuyen:FindFirstChild("Engine"))
        local tPart=getgenv().CurrentTargetPart or (getgenv().CurrentTarget and (getgenv().CurrentTarget:FindFirstChild("HumanoidRootPart") or getgenv().CurrentTarget.PrimaryPart))
        if _G.SafeFlyingBoat and _G.DangSan and hrp and hum and thuyen and vSeat and mPart and tPart then
            local distSeat=(hrp.Position-vSeat.Position).Magnitude
            local isSit=hum.Sit and hum.SeatPart==vSeat
            if not isSit and distSeat>20 then
                _isFlyingSafe=true
                for _,v in ipairs(thuyen:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false pcall(function() v.CanTouch=false v.CanQuery=false end) end
                end
                local bv=vSeat:FindFirstChild("SafeFlyBV") local bg=vSeat:FindFirstChild("SafeFlyBG")
                if not bv or not bg or bv.Parent~=vSeat or bg.Parent~=vSeat then
                    if bv then bv:Destroy() end if bg then bg:Destroy() end
                    for _,v in pairs(vSeat:GetChildren()) do
                        if (v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") or
                            v:IsA("LinearVelocity") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") or
                            v:IsA("AngularVelocity")) and v.Name~="SafeFlyBV" and v.Name~="SafeFlyBG" then
                            local found=false
                            for _,old in pairs(_oldMovers) do if old==v then found=true break end end
                            if not found then table.insert(_oldMovers,v) end
                            v.Parent=nil
                        end
                    end
                    bv=Instance.new("BodyVelocity") bv.Name="SafeFlyBV"
                    bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge) bv.P=9e9 bv.Velocity=Vector3.zero bv.Parent=vSeat
                    bg=Instance.new("BodyGyro") bg.Name="SafeFlyBG"
                    bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge) bg.P=9e9 bg.D=500 bg.Parent=vSeat
                end
                _dodgeAngle=_dodgeAngle+(math.rad(_G.TocDoTween or 170)*0.015)
                if _dodgeAngle>=math.pi*2 then _dodgeAngle=0 end
                local tCenter=tPart.Position local rad=tonumber(_G.SafeRadius) or 100
                local tY=tonumber(_G.SafeHeightY) or 200
                local orbit=Vector3.new(tCenter.X+math.cos(_dodgeAngle)*rad, tY, tCenter.Z+math.sin(_dodgeAngle)*rad)
                local bPos=mPart.Position local spd=tonumber(_G.TocDoTween) or 170
                if bPos.Y<tY-10 then
                    bv.Velocity=Vector3.new(0,spd,0)
                    bg.CFrame=CFrame.new(bPos)*CFrame.Angles(0,math.atan2(vSeat.CFrame.LookVector.X,vSeat.CFrame.LookVector.Z),0)
                else
                    local dir=(orbit-bPos).Magnitude>0 and (orbit-bPos).Unit or Vector3.zero
                    bv.Velocity=dir*spd
                    if Vector3.new(dir.X,0,dir.Z).Magnitude>0 then bg.CFrame=CFrame.lookAt(bPos,bPos+Vector3.new(dir.X,0,dir.Z)) end
                end
                mPart.AssemblyLinearVelocity=bv.Velocity mPart.AssemblyAngularVelocity=Vector3.zero
                if vSeat:IsA("BasePart") then vSeat.AssemblyLinearVelocity=bv.Velocity vSeat.AssemblyAngularVelocity=Vector3.zero end
            else
                if _isFlyingSafe then
                    _isFlyingSafe=false
                    local b1=vSeat:FindFirstChild("SafeFlyBV") local b2=vSeat:FindFirstChild("SafeFlyBG")
                    if b1 then b1:Destroy() end if b2 then b2:Destroy() end
                    for _,v in pairs(_oldMovers) do if v then v.Parent=vSeat end end _oldMovers={}
                    for _,v in ipairs(thuyen:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end
                end
            end
        else
            if _isFlyingSafe and vSeat then
                _isFlyingSafe=false
                local b1=vSeat:FindFirstChild("SafeFlyBV") local b2=vSeat:FindFirstChild("SafeFlyBG")
                if b1 then b1:Destroy() end if b2 then b2:Destroy() end
                for _,v in pairs(_oldMovers) do if v then v.Parent=vSeat end end _oldMovers={}
                if thuyen then for _,v in ipairs(thuyen:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end end
            end
        end
    end) end
end)

-- notify moved to end of sync system init
-- ================================================================
-- SYNC SYSTEM — CentuKaitunLevi
-- Communication via Character StringValues (replicated to all
-- clients in the same server automatically by Roblox engine)
-- ================================================================

-- ── Shadow vars for drive (driver gate controls the real _G) ──
local _uDriveTiki  = false
local _uDriveHydra = false

-- ── Sync constants ────────────────────────────────────────────
local S_ONLINE  = "CKL_Online"   -- presence tag (name|driver)
local S_REQ_PFX = "CKL_Req_"    -- request:  CKL_Req_[targetName]
local S_RSP_PFX = "CKL_Rsp_"    -- response: CKL_Rsp_[requesterName]

-- ── Sync state ────────────────────────────────────────────────
local Sync = {
    Peers    = {},       -- { [name] = Player }  currently synced
    Shown    = {},       -- { [key]  = true }    shown request notifs
    Driver   = LP.Name, -- name of the player designated to drive
}
_G.NguoiDrive = LP.Name

-- ── Driver gate monitoring loop ───────────────────────────────
-- Enforces: only the designated driver may move the boat.
-- Runs every 0.5s, overrides _G.DriveToTiki / _G.DriveToHydra.
task.spawn(function()
    while task.wait(0.5) do
        local amDriver = (Sync.Driver == LP.Name)
        _G.DriveToTiki  = amDriver and _uDriveTiki  or false
        _G.DriveToHydra = amDriver and _uDriveHydra or false
    end
end)

-- ── Broadcast our presence into Character ─────────────────────
local function broadcast()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local v = char:FindFirstChild(S_ONLINE)
        if not v then
            v        = Instance.new("StringValue")
            v.Name   = S_ONLINE
            v.Parent = char
        end
        v.Value = LP.Name .. "|" .. Sync.Driver
    end)
end
LP.CharacterAdded:Connect(function() task.wait(1) broadcast() end)
broadcast()

-- ── Driver dropdown reference (forward-declared, set in UI) ───
local _driverDd = nil
local function refreshDriverDd()
    if not _driverDd then return end
    local opts = { LP.Name }
    for name in pairs(Sync.Peers) do table.insert(opts, name) end
    pcall(function()
        if _driverDd.SetOptions then _driverDd:SetOptions(opts) end
    end)
end

-- ── Send sync request to a player ────────────────────────────
local function sendRequest(target)
    pcall(function()
        local char = LP.Character
        if not char then return end
        local tag = S_REQ_PFX .. target.Name
        local old = char:FindFirstChild(tag)
        if old then old:Destroy() end
        local sv      = Instance.new("StringValue")
        sv.Name       = tag
        sv.Value      = tostring(os.time())
        sv.Parent     = char
    end)
    Library:Notify({ Title="Sync", Content="Request sent to "..target.Name, Type="Info", Duration=3 })
end

-- ── Accept/Reject notification GUI ───────────────────────────
local function showSyncRequest(fromPlayer)
    pcall(function()
        local nGui = Instance.new("ScreenGui")
        nGui.Name         = "CKL_SReq_"..fromPlayer.Name
        nGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        nGui.ResetOnSpawn = false
        pcall(function() nGui.Parent = gethui() end)
        if not nGui.Parent then pcall(function() nGui.Parent = game:GetService("CoreGui") end) end

        -- Card
        local F = Instance.new("Frame")
        F.Size               = UDim2.fromOffset(320, 108)
        F.Position           = UDim2.new(0.5, -160, 0, 28)
        F.BackgroundColor3   = Color3.fromRGB(14, 14, 22)
        F.BackgroundTransparency = 0.08
        F.BorderSizePixel    = 0
        F.ZIndex             = 10
        F.Parent             = nGui
        local co = Instance.new("UICorner") co.CornerRadius = UDim.new(0,12) co.Parent = F
        local st = Instance.new("UIStroke") st.Color = Color3.fromRGB(255,255,255) st.Thickness = 1 st.Transparency = 0.78 st.Parent = F

        -- Accent bar
        local ab = Instance.new("Frame")
        ab.Size = UDim2.fromOffset(3,64) ab.Position = UDim2.fromOffset(0,22)
        ab.BackgroundColor3 = Color3.fromRGB(82,180,255) ab.BorderSizePixel=0 ab.Parent=F
        local abc = Instance.new("UICorner") abc.CornerRadius=UDim.new(0,2) abc.Parent=ab

        -- Labels
        local function Lbl(txt, sz, col, pos, fsz)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency=1 l.Text=txt l.Font=fsz or Enum.Font.GothamBold
            l.TextSize=sz l.TextColor3=col l.TextXAlignment=Enum.TextXAlignment.Left
            l.Size=UDim2.new(1,-24,0,sz+6) l.Position=pos l.ZIndex=11 l.Parent=F
            return l
        end

        Lbl("Sync Request",         14, Color3.fromRGB(240,240,248), UDim2.fromOffset(16,12))
        Lbl(fromPlayer.Name.." wants to sync with you", 12,
            Color3.fromRGB(130,130,155), UDim2.fromOffset(16,34), Enum.Font.Gotham)

        -- Buttons
        local function Btn(txt, col, x)
            local b = Instance.new("TextButton")
            b.Size=UDim2.fromOffset(128,30) b.Position=UDim2.fromOffset(x,66)
            b.BackgroundColor3=col b.BackgroundTransparency=0.12
            b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=13
            b.TextColor3=Color3.fromRGB(255,255,255)
            b.AutoButtonColor=false b.BorderSizePixel=0 b.ZIndex=12 b.Parent=F
            local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,8) bc.Parent=b
            b.MouseEnter:Connect(function() b.BackgroundTransparency=0 end)
            b.MouseLeave:Connect(function() b.BackgroundTransparency=0.12 end)
            return b
        end

        local AccBtn = Btn("✓  Accept", Color3.fromRGB(35,155,75),  16)
        local RejBtn = Btn("✕  Reject", Color3.fromRGB(175,45,45), 160)

        local function respond(ans)
            pcall(function()
                local char = LP.Character
                if not char then return end
                local old = char:FindFirstChild(S_RSP_PFX..fromPlayer.Name)
                if old then old:Destroy() end
                local sv      = Instance.new("StringValue")
                sv.Name       = S_RSP_PFX..fromPlayer.Name
                sv.Value      = ans    -- "accept" | "reject"
                sv.Parent     = char
            end)
        end

        AccBtn.MouseButton1Click:Connect(function()
            Sync.Peers[fromPlayer.Name] = fromPlayer
            respond("accept")
            nGui:Destroy()
            Library:Notify({ Title="Sync", Content="Synced with "..fromPlayer.Name.."!", Type="Success", Duration=4 })
            refreshDriverDd()
            broadcast()
        end)

        RejBtn.MouseButton1Click:Connect(function()
            respond("reject")
            nGui:Destroy()
        end)

        -- Auto-dismiss 30s
        task.delay(30, function() if nGui and nGui.Parent then nGui:Destroy() end end)
    end)
end

-- ── Main polling loop ─────────────────────────────────────────
task.spawn(function()
    while task.wait(1.5) do pcall(function()
        broadcast()

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            local pChar = player.Character
            if not pChar then continue end

            -- Did they send US a sync request?
            local req = pChar:FindFirstChild(S_REQ_PFX .. LP.Name)
            if req then
                local key = player.Name.."_"..req.Value
                if not Sync.Shown[key] then
                    Sync.Shown[key] = true
                    showSyncRequest(player)
                end
            end

            -- Did they respond to OUR request?
            local rsp = pChar:FindFirstChild(S_RSP_PFX .. LP.Name)
            if rsp and rsp.Value ~= "" then
                if rsp.Value == "accept" and not Sync.Peers[player.Name] then
                    Sync.Peers[player.Name] = player
                    Library:Notify({ Title="Sync", Content=player.Name.." accepted!", Type="Success", Duration=4 })
                    refreshDriverDd() broadcast()
                elseif rsp.Value == "reject" then
                    if not Sync.Shown["rej_"..player.Name] then
                        Sync.Shown["rej_"..player.Name] = true
                        Library:Notify({ Title="Sync", Content=player.Name.." rejected sync", Type="Warning", Duration=3 })
                    end
                end
                -- Clear the response so we don't re-fire
                pcall(function() rsp.Value = "" end)
            end
        end

        -- Remove disconnected peers
        for name in pairs(Sync.Peers) do
            if not Players:FindFirstChild(name) then
                Sync.Peers[name] = nil
                if Sync.Driver == name then
                    Sync.Driver   = LP.Name
                    _G.NguoiDrive = LP.Name
                    Library:Notify({ Title="Sync", Content=name.." left — you are now driver", Type="Warning", Duration=4 })
                end
                refreshDriverDd() broadcast()
            end
        end
    end) end
end)

-- ================================================================
-- SYNC TAB UI
-- ================================================================
local SyncTab = Window:CreateTab({ Name = "Sync" })

-- ── Request Sync section ──────────────────────────────────────
local SecReq = SyncTab:CreateSection("Request Sync")

-- Only show players who have CKL_Online in their character
-- = players running the same script. Others are invisible here.
local function getScriptUsers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if char and char:FindFirstChild(S_ONLINE) then
            table.insert(list, p.Name)
        end
    end
    return list
end

local _scriptUsers = getScriptUsers()

SecReq:AddParagraph({
    Title   = "Script Users Only",
    Content = "Only players running CentuKaitunLevi\nwill appear in this list."
})
local ReqPlayerDd = SecReq:AddDropdown({
    Text     = "Select Player",
    Options  = #_scriptUsers > 0 and _scriptUsers or {"(none detected)"},
    Default  = _scriptUsers[1],
    Callback = function(_) end
})

SecReq:AddButton({
    Text     = "Refresh Script Users",
    Callback = function()
        local fresh = getScriptUsers()
        _scriptUsers = fresh
        if ReqPlayerDd and ReqPlayerDd.SetOptions then
            ReqPlayerDd:SetOptions(#fresh > 0 and fresh or {"(none detected)"})
        end
        local msg = #fresh > 0
            and (#fresh.." script user(s) found")
            or  "No other script users in server"
        Library:Notify({ Title="Sync", Content=msg, Type="Info", Duration=3 })
    end
})

-- Auto-refresh every 5s (in case new players load the script)
task.spawn(function()
    while task.wait(5) do pcall(function()
        local fresh = getScriptUsers()
        if #fresh ~= #_scriptUsers then
            _scriptUsers = fresh
            if ReqPlayerDd and ReqPlayerDd.SetOptions then
                ReqPlayerDd:SetOptions(#fresh > 0 and fresh or {"(none detected)"})
            end
        end
    end) end
end)

SecReq:AddButton({
    Text     = "Send Sync Request",
    Callback = function()
        local selName = ReqPlayerDd and ReqPlayerDd:Get()
        if not selName or selName == "(none detected)" then
            Library:Notify({ Title="Sync", Content="Select a player first", Type="Warning", Duration=3 })
            return
        end
        local target = Players:FindFirstChild(selName)
        if not target then
            Library:Notify({ Title="Sync", Content="Player not found in server", Type="Warning", Duration=3 })
            return
        end
        if Sync.Peers[selName] then
            Library:Notify({ Title="Sync", Content=selName.." is already synced", Type="Info", Duration=3 })
            return
        end
        sendRequest(target)
    end
})

-- ── Driver Control section ────────────────────────────────────
local SecDriver = SyncTab:CreateSection("Driver Control")

SecDriver:AddParagraph({
    Title   = "How it works",
    Content = "Only the selected driver will move the boat.\nOthers stay still even if Drive Boat is ON."
})

_driverDd = SecDriver:AddDropdown({
    Text     = "Set Driver",
    Options  = { LP.Name },
    Default  = LP.Name,
    Callback = function(val)
        Sync.Driver   = val
        _G.NguoiDrive = val
        broadcast()
        local tag = (val == LP.Name) and "You are the driver" or val.." is the driver"
        Library:Notify({ Title="Driver", Content=tag, Type="Info", Duration=3 })
    end
})

-- ── Synced Players section ────────────────────────────────────
local SecPeers = SyncTab:CreateSection("Synced Players")

local PeersPara = SecPeers:AddParagraph({
    Title   = "Connected",
    Content = "None"
})

-- Update peers paragraph every 3s
task.spawn(function()
    while task.wait(3) do pcall(function()
        local names = { LP.Name.." (you)" }
        for name in pairs(Sync.Peers) do table.insert(names, name) end
        local txt = table.concat(names, "\n")
        if PeersPara then
            pcall(function() PeersPara:Set({ Title="Connected ("..#names..")", Content=txt }) end)
            pcall(function() PeersPara:Set("Connected ("..#names..")", txt) end)
        end
    end) end
end)

SecPeers:AddButton({
    Text     = "Disconnect All",
    Callback = function()
        -- Clean up our presence and requests
        pcall(function()
            local char = LP.Character
            if not char then return end
            local tags = {S_ONLINE}
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(tags, S_REQ_PFX..p.Name)
                table.insert(tags, S_RSP_PFX..p.Name)
            end
            for _, tag in ipairs(tags) do
                local v = char:FindFirstChild(tag)
                if v then v:Destroy() end
            end
        end)
        Sync.Peers   = {}
        Sync.Driver  = LP.Name
        _G.NguoiDrive = LP.Name
        refreshDriverDd()
        Library:Notify({ Title="Sync", Content="Disconnected from all peers", Type="Warning", Duration=3 })
    end
})

-- ================================================================
-- DONE
-- ================================================================
Library:Notify({ Title="Centu Kaitun Levi", Content="Script loaded!", Type="Success", Duration=5 })
