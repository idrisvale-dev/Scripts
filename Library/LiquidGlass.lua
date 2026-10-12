-- ================================================================
--  LiquidGlass UI Library
--  Style  : Transparent + Liquid Glass
--  Author : IDRIS
--  Compat : PC + Mobile (Touch)
--  API    : same shape as FluentPro
-- ================================================================
--
--  USAGE:
--    local LG = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--    local Window = LG:CreateWindow({
--        Title    = "My Hub",
--        SubTitle = "v1.0",
--        Size     = UDim2.fromOffset(700, 460),   -- optional
--        MinimizeKey = Enum.KeyCode.RightShift,   -- optional
--    })
--    local Tab = Window:AddTab({ Title = "Main", Icon = "⚙" })
--    Tab:AddSection("Config")
--    Tab:AddToggle("myToggle", { Title = "Enable", Default = false })
--       :OnChanged(function(v) print(v) end)
--
-- ================================================================

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

-- ── Services ──────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LP               = Players.LocalPlayer

-- ── Theme ─────────────────────────────────────────────────────
local T = {
    Bg          = Color3.fromRGB(14, 14, 20),
    Sidebar     = Color3.fromRGB(18, 18, 25),
    Card        = Color3.fromRGB(26, 26, 36),
    CardHover   = Color3.fromRGB(34, 34, 48),
    Accent      = Color3.fromRGB(82, 180, 255),
    AccentDim   = Color3.fromRGB(40, 100, 180),
    Success     = Color3.fromRGB(70, 210, 130),
    Danger      = Color3.fromRGB(220, 65, 65),
    Text        = Color3.fromRGB(240, 240, 248),
    Sub         = Color3.fromRGB(130, 130, 155),
    Border      = Color3.fromRGB(255, 255, 255),
    SwitchOff   = Color3.fromRGB(50, 50, 68),
    Knob        = Color3.fromRGB(255, 255, 255),
    TrackBg     = Color3.fromRGB(45, 45, 62),
    DropBg      = Color3.fromRGB(18, 18, 28),
    NotifBg     = Color3.fromRGB(16, 16, 24),
    TabSel      = Color3.fromRGB(36, 36, 52),
}

-- ── Transparency layers ────────────────────────────────────────
local A = {
    Window  = 0.22,   -- main frame
    Sidebar = 0.15,
    Card    = 0.32,
    TopBar  = 0.18,
    Drop    = 0.08,
    Notif   = 0.12,
}

-- ── Helpers ───────────────────────────────────────────────────
local Bold   = Enum.Font.GothamBold
local Medium = Enum.Font.GothamMedium
local Reg    = Enum.Font.Gotham

local function Tw(obj, props, t, s, d)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out),
        props):Play()
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p ; return c
end

local function Stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color        = color or T.Border
    s.Thickness    = thick or 1
    s.Transparency = trans or 0.84
    s.Parent = p ; return s
end

local function Pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p ; return u
end

local function List(p, padding, sort)
    local l = Instance.new("UIListLayout")
    l.SortOrder = sort or Enum.SortOrder.LayoutOrder
    l.Padding    = UDim.new(0, padding or 5)
    l.Parent = p ; return l
end

local function Gradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent = p ; return g
end

local function Label(p, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font      = props.Font    or Reg
    l.TextSize  = props.Size    or 13
    l.TextColor3= props.Color   or T.Text
    l.Text      = props.Text    or ""
    l.Size      = props.SZ      or UDim2.new(1,0,0,20)
    l.Position  = props.Pos     or UDim2.fromOffset(0,0)
    l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    l.RichText  = props.Rich    or false
    l.ZIndex    = props.Z       or 1
    l.Parent    = p
    return l
end

-- Draggable setup (works for both Mouse + Touch)
local function MakeDraggable(handle, target)
    local drag, dStart, tStart = false, nil, nil
    local function onStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag   = true
            dStart = input.Position
            tStart = target.Position
        end
    end
    local function onEnd(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end
    local function onMove(input)
        if drag and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - dStart
            target.Position = UDim2.new(
                tStart.X.Scale, tStart.X.Offset + d.X,
                tStart.Y.Scale, tStart.Y.Offset + d.Y
            )
        end
    end
    handle.InputBegan:Connect(onStart)
    handle.InputEnded:Connect(onEnd)
    UserInputService.InputChanged:Connect(onMove)
end

-- ── Create Window ─────────────────────────────────────────────
function LiquidGlass:CreateWindow(cfg)
    cfg = cfg or {}
    local title       = cfg.Title       or "LiquidGlass"
    local subtitle    = cfg.SubTitle    or ""
    local winSize     = cfg.Size        or UDim2.fromOffset(700, 460)
    local minKey      = cfg.MinimizeKey or Enum.KeyCode.RightShift
    local W           = winSize.X.Offset
    local H           = winSize.Y.Offset
    local TOPBAR_H    = 50
    local SIDEBAR_W   = 198

    -- ── Root GUI ─────────────────────────────────────────────
    local Gui = Instance.new("ScreenGui")
    Gui.Name          = "LiquidGlassUI"
    Gui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
    Gui.ResetOnSpawn  = false
    pcall(function() Gui.Parent = gethui() end)
    if not Gui.Parent then
        pcall(function() Gui.Parent = game:GetService("CoreGui") end)
    end

    -- ── Main Frame ───────────────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name                 = "LGMain"
    Main.Size                 = winSize
    Main.Position             = UDim2.new(0.5, -W/2, 0.5, -H/2)
    Main.BackgroundColor3     = T.Bg
    Main.BackgroundTransparency = A.Window
    Main.BorderSizePixel      = 0
    Main.ClipsDescendants     = true
    Main.Parent               = Gui
    Corner(Main, 14)
    Stroke(Main, T.Border, 1, 0.80)
    -- Glass gradient
    Gradient(Main,
        Color3.fromRGB(30, 30, 44),
        Color3.fromRGB(10, 10, 16),
        125)

    -- subtle noise texture feel — inner glow at top
    local glowBar = Instance.new("Frame")
    glowBar.Size = UDim2.new(1, 0, 0, 1)
    glowBar.BackgroundColor3 = T.Border
    glowBar.BackgroundTransparency = 0.60
    glowBar.BorderSizePixel = 0
    glowBar.ZIndex = 2
    glowBar.Parent = Main

    -- ── Top Bar ──────────────────────────────────────────────
    local TopBar = Instance.new("Frame")
    TopBar.Name               = "TopBar"
    TopBar.Size               = UDim2.new(1, 0, 0, TOPBAR_H)
    TopBar.BackgroundColor3   = T.Sidebar
    TopBar.BackgroundTransparency = A.TopBar
    TopBar.BorderSizePixel    = 0
    TopBar.ZIndex             = 3
    TopBar.Parent             = Main

    -- bottom line on topbar
    local tbLine = Instance.new("Frame")
    tbLine.Size = UDim2.new(1,0,0,1)
    tbLine.Position = UDim2.new(0,0,1,-1)
    tbLine.BackgroundColor3 = T.Border
    tbLine.BackgroundTransparency = 0.80
    tbLine.BorderSizePixel = 0
    tbLine.ZIndex = 4
    tbLine.Parent = TopBar

    -- Hub name + subtitle
    Label(TopBar, {
        Text   = title,
        Font   = Bold,
        Size   = 16,
        Color  = T.Text,
        SZ     = UDim2.fromOffset(260, 24),
        Pos    = UDim2.fromOffset(18, 8),
        Z      = 4,
    })
    Label(TopBar, {
        Text   = subtitle,
        Font   = Reg,
        Size   = 11,
        Color  = T.Sub,
        SZ     = UDim2.fromOffset(260, 16),
        Pos    = UDim2.fromOffset(18, 30),
        Z      = 4,
    })

    -- Window control buttons
    local function CtrlBtn(text, col, offX)
        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(22, 22)
        f.Position = UDim2.new(1, offX, 0.5, -11)
        f.BackgroundColor3 = col
        f.BackgroundTransparency = 0.20
        f.BorderSizePixel = 0
        f.ZIndex = 5
        f.Parent = TopBar
        Corner(f, 11)

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,1,0)
        b.BackgroundTransparency = 1
        b.Text = text
        b.Font = Bold
        b.TextSize = 10
        b.TextColor3 = T.Text
        b.ZIndex = 6
        b.Parent = f

        b.MouseEnter:Connect(function() Tw(f, {BackgroundTransparency = 0}, 0.1) end)
        b.MouseLeave:Connect(function() Tw(f, {BackgroundTransparency = 0.20}, 0.1) end)
        return b, f
    end

    local CloseBtn,  CloseF  = CtrlBtn("✕", T.Danger,   -14)
    local MinBtn,    MinF    = CtrlBtn("—", Color3.fromRGB(240,180,40), -42)

    -- ── Content Area ─────────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
    ContentArea.Position = UDim2.new(0, 0, 0, TOPBAR_H)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main

    -- ── Sidebar ──────────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name               = "Sidebar"
    Sidebar.Size               = UDim2.new(0, SIDEBAR_W, 1, 0)
    Sidebar.BackgroundColor3   = T.Sidebar
    Sidebar.BackgroundTransparency = A.Sidebar
    Sidebar.BorderSizePixel    = 0
    Sidebar.Parent             = ContentArea

    -- right divider line
    local sbLine = Instance.new("Frame")
    sbLine.Size = UDim2.new(0,1,1,0)
    sbLine.Position = UDim2.new(1,-1,0,0)
    sbLine.BackgroundColor3 = T.Border
    sbLine.BackgroundTransparency = 0.80
    sbLine.BorderSizePixel = 0
    sbLine.Parent = Sidebar

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1,-8,1,-8)
    TabScroll.Position = UDim2.fromOffset(4,4)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.CanvasSize = UDim2.new(0,0,0,0)
    TabScroll.Parent = Sidebar
    List(TabScroll, 3)

    -- ── Right Panel ───────────────────────────────────────────
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
    RightPanel.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
    RightPanel.BackgroundTransparency = 1
    RightPanel.Parent = ContentArea

    local PageTitle = Label(RightPanel, {
        Text   = "",
        Font   = Bold,
        Size   = 20,
        Color  = T.Text,
        SZ     = UDim2.new(1,-20, 0, 36),
        Pos    = UDim2.fromOffset(16, 10),
        Z      = 2,
    })

    local RightScroll = Instance.new("ScrollingFrame")
    RightScroll.Name = "RightScroll"
    RightScroll.Size = UDim2.new(1,-14, 1, -(36+14))
    RightScroll.Position = UDim2.fromOffset(8, 50)
    RightScroll.BackgroundTransparency = 1
    RightScroll.ScrollBarThickness = 3
    RightScroll.ScrollBarImageColor3 = Color3.fromRGB(90,90,120)
    RightScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightScroll.CanvasSize = UDim2.new(0,0,0,0)
    RightScroll.Parent = RightPanel
    List(RightScroll, 6)

    -- ── Draggable (TopBar) ────────────────────────────────────
    MakeDraggable(TopBar, Main)

    -- ── Window Controls Logic ─────────────────────────────────
    local minimized = false
    CloseBtn.MouseButton1Click:Connect(function()
        Tw(Main, {BackgroundTransparency=1, Size=UDim2.fromOffset(0,0)}, 0.22)
        task.wait(0.25) ; Gui:Destroy()
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tw(Main, {Size = minimized and UDim2.new(0,W,0,TOPBAR_H) or winSize}, 0.22)
    end)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == minKey then
            Main.Visible = not Main.Visible
        end
    end)

    -- ── Notification ─────────────────────────────────────────
    local notifQueue = {}
    local notifRunning = false

    local function ShowNotif(cfg2)
        cfg2 = cfg2 or {}
        local nGui = Instance.new("ScreenGui")
        nGui.Name = "LGNotif"
        nGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        nGui.ResetOnSpawn = false
        pcall(function() nGui.Parent = gethui() end)
        if not nGui.Parent then pcall(function() nGui.Parent = game:GetService("CoreGui") end) end

        local nF = Instance.new("Frame")
        nF.Size = UDim2.fromOffset(288, 66)
        nF.Position = UDim2.new(1, 10, 1, -(74 + (#notifQueue * 72)))
        nF.BackgroundColor3 = T.NotifBg
        nF.BackgroundTransparency = A.Notif
        nF.BorderSizePixel = 0
        nF.Parent = nGui
        Corner(nF, 11)
        Stroke(nF, T.Border, 1, 0.80)
        Gradient(nF, Color3.fromRGB(28,28,42), Color3.fromRGB(14,14,22), 135)

        -- accent left bar
        local acBar = Instance.new("Frame")
        acBar.Size = UDim2.fromOffset(3, 38)
        acBar.Position = UDim2.fromOffset(0, 14)
        acBar.BackgroundColor3 = T.Accent
        acBar.BorderSizePixel = 0
        acBar.Parent = nF
        Corner(acBar, 2)

        Label(nF, {Text=cfg2.Title or "", Font=Bold,  Size=13, Color=T.Text, SZ=UDim2.new(1,-24,0,22), Pos=UDim2.fromOffset(16,10)})
        Label(nF, {Text=cfg2.Content or "", Font=Reg, Size=11, Color=T.Sub,  SZ=UDim2.new(1,-24,0,20), Pos=UDim2.fromOffset(16,32)})

        Tw(nF, {Position = UDim2.new(1,-298, 1, -(74 + (#notifQueue*72)))}, 0.28)
        task.delay(cfg2.Duration or 5, function()
            Tw(nF, {Position = UDim2.new(1,10,1, -(74+(#notifQueue*72)))}, 0.22)
            task.wait(0.25) ; nGui:Destroy()
        end)
    end

    -- ── Tab system ────────────────────────────────────────────
    local tabList  = {}
    local selTab   = nil
    local tabOrder = 0

    local function SelectTab(tabData)
        if selTab then
            Tw(selTab.btn, {BackgroundTransparency=1}, 0.15)
            Tw(selTab.icon, {TextColor3=T.Sub}, 0.15)
            Tw(selTab.lbl,  {TextColor3=T.Sub}, 0.15)
            Tw(selTab.bar,  {BackgroundTransparency=1}, 0.15)
            selTab.page.Visible = false
        end
        selTab = tabData
        Tw(tabData.btn,  {BackgroundTransparency=0.62}, 0.15)
        Tw(tabData.icon, {TextColor3=T.Accent}, 0.15)
        Tw(tabData.lbl,  {TextColor3=T.Text},   0.15)
        Tw(tabData.bar,  {BackgroundTransparency=0}, 0.15)
        tabData.page.Visible = true
        PageTitle.Text = tabData.title
        RightScroll.CanvasPosition = Vector2.zero
    end

    -- ── Window Object ─────────────────────────────────────────
    local Window = {}

    function Window:Notify(c) ShowNotif(c) end

    function Window:SelectTab(idx)
        if tabList[idx] then SelectTab(tabList[idx]) end
    end

    function Window:AddTab(cfg2)
        cfg2 = type(cfg2)=="string" and {Title=cfg2} or cfg2
        local tTitle = cfg2.Title or "Tab"
        local tIcon  = cfg2.Icon  or "•"
        tabOrder += 1

        -- ── Tab Button ───────────────────────────────────────
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_"..tTitle
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.BackgroundColor3 = T.TabSel
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.LayoutOrder = tabOrder
        TabBtn.Parent = TabScroll
        Corner(TabBtn, 8)

        -- selected indicator
        local SelBar = Instance.new("Frame")
        SelBar.Name = "SelBar"
        SelBar.Size = UDim2.fromOffset(3, 22)
        SelBar.Position = UDim2.new(0, 0, 0.5, -11)
        SelBar.BackgroundColor3 = T.Accent
        SelBar.BackgroundTransparency = 1
        SelBar.BorderSizePixel = 0
        SelBar.Parent = TabBtn
        Corner(SelBar, 2)

        local IconLbl = Label(TabBtn, {
            Text   = tIcon,
            Font   = Bold,
            Size   = 15,
            Color  = T.Sub,
            SZ     = UDim2.fromOffset(22, 22),
            Pos    = UDim2.fromOffset(14, 9),
        })

        local TitleLbl = Label(TabBtn, {
            Text   = tTitle,
            Font   = Medium,
            Size   = 13,
            Color  = T.Sub,
            SZ     = UDim2.new(1,-46,1,0),
            Pos    = UDim2.fromOffset(42, 0),
        })

        -- ── Tab Page (inside RightScroll) ─────────────────────
        local Page = Instance.new("Frame")
        Page.Name = "Page_"..tTitle
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = RightScroll
        List(Page, 6)

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingBottom = UDim.new(0,10)
        PagePad.Parent = Page

        -- ── Tab click ─────────────────────────────────────────
        local tabData = {btn=TabBtn, icon=IconLbl, lbl=TitleLbl, bar=SelBar, page=Page, title=tTitle}
        table.insert(tabList, tabData)
        if #tabList == 1 then SelectTab(tabData) end

        TabBtn.MouseButton1Click:Connect(function() SelectTab(tabData) end)
        TabBtn.MouseEnter:Connect(function()
            if selTab ~= tabData then Tw(TabBtn, {BackgroundTransparency=0.82}, 0.12) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if selTab ~= tabData then Tw(TabBtn, {BackgroundTransparency=1}, 0.12) end
        end)

        -- ── Element builder ───────────────────────────────────
        local Tab       = {}
        local elemOrder = 0
        local function EO() elemOrder+=1 ; return elemOrder end

        -- Card base
        local function Card(h)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, h or 50)
            f.BackgroundColor3 = T.Card
            f.BackgroundTransparency = A.Card
            f.BorderSizePixel = 0
            f.LayoutOrder = EO()
            f.Parent = Page
            Corner(f, 9)
            Stroke(f, T.Border, 1, 0.86)
            return f
        end

        -- ── AddSection ────────────────────────────────────────
        function Tab:AddSection(name)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1,0,0,22)
            f.BackgroundTransparency = 1
            f.LayoutOrder = EO()
            f.Parent = Page
            Label(f, {
                Text   = string.upper(name or ""),
                Font   = Bold,
                Size   = 10,
                Color  = T.Sub,
                SZ     = UDim2.new(1,-10,1,0),
                Pos    = UDim2.fromOffset(6,0),
            })
        end

        -- ── AddParagraph ──────────────────────────────────────
        function Tab:AddParagraph(cfg3)
            cfg3 = type(cfg3)=="table" and cfg3 or {Title=tostring(cfg3)}
            local c = Card(56)

            local iconLbl = Label(c, {
                Text   = "≡",
                Font   = Bold,
                Size   = 18,
                Color  = T.Sub,
                SZ     = UDim2.fromOffset(22,22),
                Pos    = UDim2.fromOffset(12,17),
            })
            local tLbl = Label(c, {
                Text   = cfg3.Title or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-50,0,22),
                Pos    = UDim2.fromOffset(40,8),
            })
            local cLbl = Label(c, {
                Text   = cfg3.Content or "",
                Font   = Reg,
                Size   = 11,
                Color  = T.Sub,
                SZ     = UDim2.new(1,-50,0,18),
                Pos    = UDim2.fromOffset(40,30),
            })

            local P = {}
            function P:Set(a, b)
                if type(a)=="table" then
                    if a.Title   then tLbl.Text = a.Title   end
                    if a.Content then cLbl.Text = a.Content end
                else
                    tLbl.Text = tostring(a or "")
                    cLbl.Text = tostring(b or "")
                end
            end
            return P
        end

        -- ── AddButton ─────────────────────────────────────────
        function Tab:AddButton(cfg3)
            cfg3 = type(cfg3)=="table" and cfg3 or {Title=tostring(cfg3)}
            local hasDesc = cfg3.Description and cfg3.Description ~= ""
            local c = Card(hasDesc and 62 or 48)

            Label(c, {
                Text   = cfg3.Title or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-50,0,22),
                Pos    = UDim2.fromOffset(14, hasDesc and 6 or 13),
            })

            if hasDesc then
                Label(c, {
                    Text   = cfg3.Description,
                    Font   = Reg,
                    Size   = 11,
                    Color  = T.Sub,
                    SZ     = UDim2.new(1,-50,0,18),
                    Pos    = UDim2.fromOffset(14,28),
                })
            end

            -- Arrow icon
            Label(c, {
                Text   = "›",
                Font   = Bold,
                Size   = 22,
                Color  = T.Sub,
                SZ     = UDim2.fromOffset(22,22),
                Pos    = UDim2.new(1,-34,0.5,-11),
                Z      = 2,
            })

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency = 1
            btn.Text = "" ; btn.ZIndex = 3
            btn.Parent = c

            btn.MouseEnter:Connect(function()  Tw(c,{BackgroundTransparency=0.15},0.1) end)
            btn.MouseLeave:Connect(function()  Tw(c,{BackgroundTransparency=A.Card},0.1) end)
            btn.MouseButton1Click:Connect(function()
                Tw(c,{BackgroundTransparency=0.05},0.08)
                task.wait(0.1)
                Tw(c,{BackgroundTransparency=A.Card},0.14)
                if cfg3.Callback then pcall(cfg3.Callback) end
            end)
        end

        -- ── AddToggle ─────────────────────────────────────────
        function Tab:AddToggle(id, cfg3)
            cfg3 = cfg3 or {}
            local val = cfg3.Default == true

            local hasDesc = cfg3.Description and cfg3.Description ~= ""
            local c = Card(hasDesc and 58 or 48)

            Label(c, {
                Text   = cfg3.Title or id or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-72,0,22),
                Pos    = UDim2.fromOffset(14, hasDesc and 6 or 13),
            })

            if hasDesc then
                Label(c, {
                    Text   = cfg3.Description,
                    Font   = Reg,
                    Size   = 11,
                    Color  = T.Sub,
                    SZ     = UDim2.new(1,-72,0,17),
                    Pos    = UDim2.fromOffset(14,28),
                })
            end

            -- Switch track
            local sw = Instance.new("Frame")
            sw.Size = UDim2.fromOffset(44,24)
            sw.Position = UDim2.new(1,-56,0.5,-12)
            sw.BackgroundColor3 = val and T.Accent or T.SwitchOff
            sw.BorderSizePixel = 0
            sw.Parent = c
            Corner(sw,12)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(18,18)
            knob.Position = val and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)
            knob.BackgroundColor3 = T.Knob
            knob.BorderSizePixel = 0
            knob.Parent = sw
            Corner(knob,9)
            -- knob shadow
            Stroke(knob, Color3.fromRGB(0,0,0), 1, 0.70)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,1,0) ; btn.BackgroundTransparency=1
            btn.Text="" ; btn.ZIndex=3 ; btn.Parent=c

            local cbs = {}
            local function SetVal(v)
                val = v
                Tw(sw,    {BackgroundColor3 = v and T.Accent or T.SwitchOff}, 0.16)
                Tw(knob,  {Position = v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}, 0.16)
                for _,cb in ipairs(cbs) do pcall(cb,v) end
            end

            btn.MouseButton1Click:Connect(function() SetVal(not val) end)
            btn.MouseEnter:Connect(function() Tw(c,{BackgroundTransparency=0.18},0.10) end)
            btn.MouseLeave:Connect(function() Tw(c,{BackgroundTransparency=A.Card},0.10) end)

            local Tog = {}
            function Tog:OnChanged(cb) table.insert(cbs,cb) end
            function Tog:Set(v) SetVal(v) end
            function Tog:Get() return val end
            return Tog
        end

        -- ── AddSlider ─────────────────────────────────────────
        function Tab:AddSlider(id, cfg3)
            cfg3 = cfg3 or {}
            local mn  = cfg3.Min     or 0
            local mx  = cfg3.Max     or 100
            local def = math.clamp(cfg3.Default or mn, mn, mx)
            local rnd = cfg3.Rounding or 0
            local val = def

            local hasDesc = cfg3.Description and cfg3.Description ~= ""
            local c = Card(hasDesc and 70 or 60)

            Label(c, {
                Text   = cfg3.Title or id or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-80,0,22),
                Pos    = UDim2.fromOffset(14,6),
            })

            local valLbl = Label(c, {
                Text   = tostring(def),
                Font   = Bold,
                Size   = 13,
                Color  = T.Accent,
                SZ     = UDim2.fromOffset(62,22),
                Pos    = UDim2.new(1,-76,0,6),
                XAlign = Enum.TextXAlignment.Right,
            })

            if hasDesc then
                Label(c, {
                    Text   = cfg3.Description,
                    Font   = Reg,
                    Size   = 11,
                    Color  = T.Sub,
                    SZ     = UDim2.new(1,-20,0,16),
                    Pos    = UDim2.fromOffset(14,26),
                })
            end

            -- Track
            local trackBg = Instance.new("Frame")
            trackBg.Size = UDim2.new(1,-28,0,6)
            trackBg.Position = UDim2.new(0,14,1,-18)
            trackBg.BackgroundColor3 = T.TrackBg
            trackBg.BorderSizePixel = 0
            trackBg.Parent = c
            Corner(trackBg,3)

            local pct0 = (def-mn)/(mx-mn)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(pct0,0,1,0)
            fill.BackgroundColor3 = T.Accent
            fill.BorderSizePixel = 0
            fill.Parent = trackBg
            Corner(fill,3)
            -- fill glow gradient
            Gradient(fill, T.Accent, T.AccentDim, 0)

            local knob2 = Instance.new("Frame")
            knob2.Size = UDim2.fromOffset(14,14)
            knob2.AnchorPoint = Vector2.new(0.5,0.5)
            knob2.Position = UDim2.new(pct0,0,0.5,0)
            knob2.BackgroundColor3 = T.Knob
            knob2.BorderSizePixel = 0
            knob2.Parent = trackBg
            Corner(knob2,7)
            Stroke(knob2, Color3.fromRGB(0,0,0), 1, 0.68)

            local cbs = {}
            local dragging2 = false
            local iConn

            local function Update(inputPos)
                local aP = trackBg.AbsolutePosition
                local aS = trackBg.AbsoluteSize
                local rel = math.clamp((inputPos.X - aP.X)/aS.X, 0, 1)
                local raw = mn + (mx-mn)*rel
                val = rnd==0 and math.round(raw) or (math.floor(raw/rnd+0.5)*rnd)
                local p = (val-mn)/(mx-mn)
                fill.Size = UDim2.new(p,0,1,0)
                knob2.Position = UDim2.new(p,0,0.5,0)
                valLbl.Text = tostring(val)
                for _,cb in ipairs(cbs) do pcall(cb,val) end
            end

            trackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1
                or inp.UserInputType==Enum.UserInputType.Touch then
                    dragging2=true ; Update(inp.Position)
                    iConn = UserInputService.InputChanged:Connect(function(i)
                        if dragging2 and (i.UserInputType==Enum.UserInputType.MouseMovement
                        or i.UserInputType==Enum.UserInputType.Touch) then
                            Update(i.Position)
                        end
                    end)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1
                or inp.UserInputType==Enum.UserInputType.Touch then
                    if dragging2 then
                        dragging2=false
                        if iConn then iConn:Disconnect() ; iConn=nil end
                    end
                end
            end)

            c.MouseEnter:Connect(function() Tw(c,{BackgroundTransparency=0.18},0.10) end)
            c.MouseLeave:Connect(function() Tw(c,{BackgroundTransparency=A.Card},0.10) end)

            local Sl = {}
            function Sl:OnChanged(cb) table.insert(cbs,cb) end
            function Sl:Set(v)
                val = math.clamp(v,mn,mx)
                local p=(val-mn)/(mx-mn)
                fill.Size=UDim2.new(p,0,1,0) ; knob2.Position=UDim2.new(p,0,0.5,0)
                valLbl.Text=tostring(val)
                for _,cb in ipairs(cbs) do pcall(cb,val) end
            end
            function Sl:Get() return val end
            return Sl
        end

        -- ── AddDropdown ───────────────────────────────────────
        function Tab:AddDropdown(id, cfg3)
            cfg3 = cfg3 or {}
            local opts    = cfg3.Values or {}
            local isMulti = cfg3.Multi == true
            local val     = nil
            local mVal    = {}

            if isMulti then
                if type(cfg3.Default)=="table" then
                    for _,v in ipairs(cfg3.Default) do mVal[v]=true end
                end
            else
                if type(cfg3.Default)=="number"  then val = opts[cfg3.Default]
                elseif type(cfg3.Default)=="string" then val = cfg3.Default end
            end

            local function DisplayText()
                if isMulti then
                    local s={}
                    for k,v in pairs(mVal) do if v then table.insert(s,k) end end
                    return #s>0 and table.concat(s,", ") or "None"
                end
                return val or "Select..."
            end

            local c = Card(52)
            local expanded = false
            local ITEM_H   = 34
            local LIST_H   = math.min(#opts, 6) * ITEM_H

            Label(c, {
                Text   = cfg3.Title or id or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-38,0,22),
                Pos    = UDim2.fromOffset(14,6),
            })

            local valLbl2 = Label(c, {
                Text   = DisplayText(),
                Font   = Reg,
                Size   = 11,
                Color  = T.Accent,
                SZ     = UDim2.new(1,-38,0,18),
                Pos    = UDim2.fromOffset(14,28),
            })

            local arrLbl = Label(c, {
                Text   = "▾",
                Font   = Bold,
                Size   = 14,
                Color  = T.Sub,
                SZ     = UDim2.fromOffset(20,20),
                Pos    = UDim2.new(1,-28,0.5,-10),
                Z      = 2,
            })

            -- Drop list
            local dList = Instance.new("ScrollingFrame")
            dList.Name = "DropList"
            dList.Size = UDim2.new(1,0,0,0)
            dList.Position = UDim2.new(0,0,1,6)
            dList.BackgroundColor3 = T.DropBg
            dList.BackgroundTransparency = A.Drop
            dList.BorderSizePixel = 0
            dList.ClipsDescendants = true
            dList.ZIndex = 8
            dList.ScrollBarThickness = 2
            dList.ScrollBarImageColor3 = Color3.fromRGB(80,80,110)
            dList.ScrollingDirection = Enum.ScrollingDirection.Y
            dList.CanvasSize = UDim2.new(0,0,0,#opts*ITEM_H)
            dList.Visible = false
            dList.Parent = c
            Corner(dList,8)
            Stroke(dList, T.Border, 1, 0.82)
            List(dList,0)

            local cbs = {}

            for i, opt in ipairs(opts) do
                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1,0,0,ITEM_H)
                row.BackgroundColor3 = T.CardHover
                row.BackgroundTransparency = 1
                row.Text="" ; row.ZIndex=9
                row.AutoButtonColor=false
                row.LayoutOrder=i
                row.Parent=dList

                Label(row, {
                    Text   = opt,
                    Font   = Medium,
                    Size   = 12,
                    Color  = T.Text,
                    SZ     = UDim2.new(1,-40,1,0),
                    Pos    = UDim2.fromOffset(14,0),
                    Z      = 10,
                })

                local chk = Label(row, {
                    Text   = (isMulti and mVal[opt]) and "✓" or "",
                    Font   = Bold,
                    Size   = 13,
                    Color  = T.Accent,
                    SZ     = UDim2.fromOffset(22,22),
                    Pos    = UDim2.new(1,-30,0.5,-11),
                    XAlign = Enum.TextXAlignment.Center,
                    Z      = 10,
                })

                -- separator line
                if i < #opts then
                    local sep = Instance.new("Frame")
                    sep.Size = UDim2.new(1,-20,0,1)
                    sep.Position = UDim2.new(0,10,1,-1)
                    sep.BackgroundColor3 = T.Border
                    sep.BackgroundTransparency = 0.88
                    sep.BorderSizePixel=0 ; sep.ZIndex=9
                    sep.Parent=row
                end

                row.MouseEnter:Connect(function() Tw(row,{BackgroundTransparency=0.78},0.10) end)
                row.MouseLeave:Connect(function() Tw(row,{BackgroundTransparency=1},0.10) end)

                row.MouseButton1Click:Connect(function()
                    if isMulti then
                        mVal[opt] = not mVal[opt]
                        chk.Text = mVal[opt] and "✓" or ""
                        valLbl2.Text = DisplayText()
                        local cp={}
                        for k,v in pairs(mVal) do cp[k]=v end
                        for _,cb in ipairs(cbs) do pcall(cb,cp) end
                    else
                        val = opt ; valLbl2.Text=val
                        expanded=false
                        Tw(c,{Size=UDim2.new(1,0,0,52)},0.15)
                        Tw(arrLbl,{Rotation=0},0.15)
                        dList.Visible=false
                        for _,cb in ipairs(cbs) do pcall(cb,val) end
                    end
                end)
            end

            local hBtn = Instance.new("TextButton")
            hBtn.Size=UDim2.new(1,0,1,0) ; hBtn.BackgroundTransparency=1
            hBtn.Text="" ; hBtn.ZIndex=5 ; hBtn.Parent=c

            hBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    c.Size = UDim2.new(1,0,0,52+LIST_H+6)
                    Tw(arrLbl,{Rotation=180},0.15)
                    dList.Visible=true
                    Tw(dList,{Size=UDim2.new(1,0,0,LIST_H)},0.15)
                else
                    Tw(c,{Size=UDim2.new(1,0,0,52)},0.15)
                    Tw(arrLbl,{Rotation=0},0.15)
                    task.wait(0.15) ; dList.Visible=false
                end
            end)

            c.MouseEnter:Connect(function() if not expanded then Tw(c,{BackgroundTransparency=0.18},0.10) end end)
            c.MouseLeave:Connect(function() if not expanded then Tw(c,{BackgroundTransparency=A.Card},0.10) end end)

            local Dd = {}
            function Dd:OnChanged(cb) table.insert(cbs,cb) end
            function Dd:Set(v)
                if isMulti then mVal=type(v)=="table" and v or {}
                else val=v end
                valLbl2.Text=DisplayText()
            end
            function Dd:Get() return isMulti and mVal or val end
            function Dd:Refresh(newOpts) opts=newOpts end
            return Dd
        end

        -- ── AddInput ──────────────────────────────────────────
        function Tab:AddInput(id, cfg3)
            cfg3 = cfg3 or {}
            local c = Card(60)

            Label(c, {
                Text   = cfg3.Title or id or "",
                Font   = Medium,
                Size   = 13,
                Color  = T.Text,
                SZ     = UDim2.new(1,-20,0,22),
                Pos    = UDim2.fromOffset(14,5),
            })

            local iBg = Instance.new("Frame")
            iBg.Size = UDim2.new(1,-28,0,28)
            iBg.Position = UDim2.fromOffset(14,28)
            iBg.BackgroundColor3 = T.DropBg
            iBg.BackgroundTransparency = 0.15
            iBg.BorderSizePixel=0
            iBg.Parent=c
            Corner(iBg,6)
            Stroke(iBg, T.Border, 1, 0.86)

            local iBox = Instance.new("TextBox")
            iBox.Size = UDim2.new(1,-16,1,0)
            iBox.Position = UDim2.fromOffset(8,0)
            iBox.BackgroundTransparency=1
            iBox.Text = cfg3.Default or ""
            iBox.PlaceholderText = cfg3.Placeholder or "Type here..."
            iBox.Font = Reg ; iBox.TextSize=12
            iBox.TextColor3 = T.Text
            iBox.PlaceholderColor3 = T.Sub
            iBox.TextXAlignment = Enum.TextXAlignment.Left
            iBox.ClearTextOnFocus = false
            iBox.Parent = iBg

            local cbs={}
            if cfg3.Finished then
                iBox.FocusLost:Connect(function() for _,cb in ipairs(cbs) do pcall(cb,iBox.Text) end end)
            else
                iBox:GetPropertyChangedSignal("Text"):Connect(function()
                    for _,cb in ipairs(cbs) do pcall(cb,iBox.Text) end
                end)
            end

            local I={}
            function I:OnChanged(cb) table.insert(cbs,cb) end
            function I:Set(v) iBox.Text=v end
            function I:Get() return iBox.Text end
            return I
        end

        return Tab
    end

    -- ── Expose Notify on Window ───────────────────────────────
    function Window:Notify(cfg2) ShowNotif(cfg2) end

    return Window
end

return LiquidGlass
