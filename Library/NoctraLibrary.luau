local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local CoreGui            = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local env         = (typeof(getgenv) == "function" and getgenv()) or _G

local GUI_NAME  = "NoctraUI"
local BLUR_NAME = "NoctraBlur"
local GAP       = 8
local ROW_H     = 26
local WHITE     = Color3.new(1, 1, 1)

local Theme = {
    Base     = Color3.fromRGB(10, 14, 24),
    Text     = Color3.fromRGB(246, 248, 255),
    SubText  = Color3.fromRGB(196, 204, 222),
    Muted    = Color3.fromRGB(142, 152, 174),
    Accent   = Color3.fromRGB(196, 224, 255),
    Good     = Color3.fromRGB(110, 240, 190),
    Warn     = Color3.fromRGB(255, 208, 110),
    Blurple  = Color3.fromRGB(104, 118, 255),
    WinT     = 0.38,
    CardT    = 0.93,
    CtrlT    = 0.9,
    HoverT   = 0.8,
    OffT     = 0.78,
    Font     = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

local Tints = {
    Midnight = Color3.fromRGB(10, 14, 24),
    Ice      = Color3.fromRGB(14, 36, 62),
    Violet   = Color3.fromRGB(26, 16, 50),
    Rose     = Color3.fromRGB(50, 16, 32),
    Mint     = Color3.fromRGB(10, 42, 36),
    Smoke    = Color3.fromRGB(24, 24, 28),
}

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok = pcall(function() return CoreGui:GetChildren() end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function new(class, props)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or WHITE, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent,
    })
end

local function shineStroke(s)
    return new("UIGradient", {
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.3, 0.7),
            NumberSequenceKeypoint.new(0.7, 0.85),
            NumberSequenceKeypoint.new(1, 0.15),
        }),
        Parent = s,
    })
end

local function pad(parent, l, t, r, b)
    l = l or 0; t = t or l; r = r or l; b = b or t
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
        PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b), Parent = parent,
    })
end

local function vlist(parent, gap)
    return new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, gap or 0),
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = parent,
    })
end

local function hlist(parent, gap, valign, halign)
    return new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, gap or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        Parent = parent,
    })
end

local function text(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Font = Theme.Font
    l.TextSize = 11
    l.TextColor3 = Theme.Text
    l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.TextStrokeTransparency = 0.82
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    local parent
    for k, v in pairs(props) do
        if k == "Parent" then parent = v else l[k] = v end
    end
    l.Parent = parent
    return l
end

local function tween(obj, time, props, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function makeIcon(parent, icon, size, color)
    icon = tostring(icon or "")
    local isImage = icon:find("^rbxasset") ~= nil or icon:match("^%d+$") ~= nil
    if isImage then
        local id = icon:match("^%d+$") and ("rbxassetid://" .. icon) or icon
        return new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1,
            Image = id, ImageColor3 = color, Parent = parent,
        })
    end
    return text({
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size), Text = icon, TextSize = size - 3,
        Font = Theme.FontBold, TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = parent,
    })
end

local function tweenIcon(icon, color, t)
    tween(icon, t or 0.2, icon:IsA("ImageLabel") and { ImageColor3 = color } or { TextColor3 = color })
end

local function chip(parent, label, o)
    o = o or {}
    local f = new("Frame", {
        Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = o.Bg or WHITE, BackgroundTransparency = o.BgTransparency or 0.88,
        BorderSizePixel = 0, LayoutOrder = o.Order or 0, Parent = parent,
    })
    corner(f, 8); stroke(f, WHITE, 1, 0.82); pad(f, 6, 0, 6, 0)
    hlist(f, 4, Enum.VerticalAlignment.Center)
    local dot
    if o.Dot then
        dot = new("Frame", {
            Size = UDim2.fromOffset(5, 5), BackgroundColor3 = o.DotColor or Theme.SubText,
            BorderSizePixel = 0, LayoutOrder = 1, Parent = f,
        })
        corner(dot, 3)
    end
    local lbl = text({
        Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X,
        Text = label, TextSize = 9, TextColor3 = o.Color or Theme.SubText,
        LayoutOrder = 2, Parent = f,
    })
    return f, lbl, dot
end

local function executorName()
    local ok, name = pcall(function() return identifyexecutor and identifyexecutor() end)
    if ok and type(name) == "string" then return name end
    return "Executor"
end

local function copyText(s)
    local fn = setclipboard or toclipboard
    if typeof(fn) == "function" then return pcall(fn, s) end
    return false
end

local function loadAvatar(img)
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and content and img.Parent then img.Image = content end
    end)
end

local function pressable(btn, down, target)
    local us = new("UIScale", { Scale = 1, Parent = target or btn })
    local token = 0
    local function release()
        token = token + 1
        tween(us, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
    end
    local function press()
        token = token + 1
        local my = token
        tween(us, 0.08, { Scale = down or 0.95 })
        task.delay(0.9, function()
            if token == my then release() end
        end)
    end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            press()
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            release()
        end
    end)
    btn.MouseLeave:Connect(release)
end

local function focusGlow(box, s, base)
    base = base or 0.75
    box.Focused:Connect(function() tween(s, 0.15, { Transparency = 0.3 }) end)
    box.FocusLost:Connect(function() tween(s, 0.2, { Transparency = base }) end)
end

local function newCollapser(frame, onChevron)
    local collapsed, lastH, token = false, 0, 0
    local function set(v, instant)
        if v == collapsed then return end
        collapsed = v
        token = token + 1
        local my = token
        if onChevron then onChevron(v) end
        if instant then
            frame.Visible = not v
            return
        end
        if v then
            if frame.AutomaticSize == Enum.AutomaticSize.Y then lastH = frame.AbsoluteSize.Y end
            frame.ClipsDescendants = true
            frame.AutomaticSize = Enum.AutomaticSize.None
            frame.Size = UDim2.new(1, 0, 0, frame.AbsoluteSize.Y)
            tween(frame, 0.24, { Size = UDim2.new(1, 0, 0, 0) }).Completed:Connect(function()
                if token == my then frame.Visible = false end
            end)
        else
            frame.Visible = true
            frame.ClipsDescendants = true
            frame.AutomaticSize = Enum.AutomaticSize.None
            frame.Size = UDim2.new(1, 0, 0, frame.AbsoluteSize.Y)
            tween(frame, 0.26, { Size = UDim2.new(1, 0, 0, lastH) }).Completed:Connect(function()
                if token == my then
                    frame.AutomaticSize = Enum.AutomaticSize.Y
                    frame.Size = UDim2.new(1, 0, 0, 0)
                    frame.ClipsDescendants = false
                end
            end)
        end
    end
    return set, function() return collapsed end
end

local function makeDraggable(handle, target, bag, onClick)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onClick and (input.Position - dragStart).Magnitude < 6 then onClick() end
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(bag, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end))
end

local function makeResizable(grip, target, minSize, bag)
    local resizing, dragInput, startPos, startSize = false, nil, nil, nil
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startPos = input.Position
            startSize = target.AbsoluteSize
            if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    grip.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(bag, UserInputService.InputChanged:Connect(function(input)
        if resizing and input == dragInput then
            local d = input.Position - startPos
            target.Size = UDim2.fromOffset(
                math.max(startSize.X + d.X, minSize.X),
                math.max(startSize.Y + d.Y, minSize.Y)
            )
        end
    end))
end

local function newSection(window, column, opts)
    opts = opts or {}
    local Section = { _n = 0 }
    function Section:_next()
        self._n = self._n + 1
        return self._n
    end
    local scroller = column.Page and column.Page.Frame

    local card = new("Frame", {
        BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CardT, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = column:_next(), Parent = column.Frame,
    })
    corner(card, 8); stroke(card, WHITE, 1, 0.84); vlist(card, 0)
    Section.Card = card
    Section.TitleLower = string.lower(opts.Title or "")
    table.insert(window.Sections, Section)

    local header = new("TextButton", {
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1, Parent = card,
    })
    local tx = 10
    if opts.Icon then
        local holder = new("Frame", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 0),
            Size = UDim2.fromOffset(16, 26), Parent = header,
        })
        makeIcon(holder, opts.Icon, 10, Theme.SubText)
        tx = 24
    end
    text({
        Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(1, -(tx + 26), 1, 0),
        Text = string.upper(opts.Title or "Section"), Font = Theme.FontBold, TextSize = 9,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
    })
    local chevron = text({
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(12, 12), Text = "v", TextSize = 9, TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = header,
    })
    local body = new("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = card,
    })
    vlist(body, 0); pad(body, 0, 0, 0, 6)
    Section.Body = body

    local setCollapsed, isCollapsed = newCollapser(body, function(v)
        tween(chevron, 0.22, { Rotation = v and -90 or 0 })
    end)
    function Section:SetCollapsed(v, instant) setCollapsed(v, instant) end
    header.Activated:Connect(function() setCollapsed(not isCollapsed()) end)
    if opts.Collapsed then setCollapsed(true, true) end

    local function newRow(h)
        return new("Frame", {
            BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, h or ROW_H), LayoutOrder = Section:_next(), Parent = body,
        })
    end
    local function labelFor(row, name, scale)
        return text({
            Position = UDim2.fromOffset(10, 0), Size = UDim2.new(scale or 0.45, -10, 1, 0),
            Text = name or "", TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
        })
    end
    local function register(row, name)
        table.insert(window.Elements, { Row = row, Name = string.lower(name or ""), Section = Section })
    end
    local function hoverRow(row, hit)
        hit.MouseEnter:Connect(function() tween(row, 0.15, { BackgroundTransparency = 0.92 }) end)
        hit.MouseLeave:Connect(function() tween(row, 0.2, { BackgroundTransparency = 1 }) end)
    end
    local function setFlag(o, v)
        if o.Flag then window.Flags[o.Flag] = v end
    end

    function Section:AddLabel(textValue)
        local row = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = Section:_next(), Parent = body,
        })
        pad(row, 10, 3, 10, 3)
        local lbl = text({
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Text = textValue or "", TextSize = 10, TextColor3 = Theme.SubText,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = row,
        })
        local obj = {}
        function obj:SetText(t) lbl.Text = t end
        return obj
    end

    function Section:AddToggle(o)
        o = o or {}
        local state = o.Default == true
        local row = newRow()
        labelFor(row, o.Name, 0.75)
        local track = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(28, 14), BackgroundColor3 = WHITE,
            BackgroundTransparency = Theme.OffT, BorderSizePixel = 0, Parent = row,
        })
        corner(track, 7); stroke(track, WHITE, 1, 0.75)
        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(10, 10), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, Parent = track,
        })
        corner(knob, 5)
        local hit = new("TextButton", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = row,
        })
        hoverRow(row, hit)

        local KNOB_ON = Color3.fromRGB(14, 20, 34)
        local seq = 0
        local function apply(animate)
            local trackColor = state and Theme.Accent or WHITE
            local trackT = state and 0.05 or Theme.OffT
            local knobColor = state and KNOB_ON or WHITE
            local restX = state and 16 or 2
            if not animate then
                track.BackgroundColor3 = trackColor
                track.BackgroundTransparency = trackT
                knob.BackgroundColor3 = knobColor
                knob.Position = UDim2.new(0, restX, 0.5, 0)
                return
            end
            seq = seq + 1
            local my = seq
            tween(track, 0.22, { BackgroundColor3 = trackColor, BackgroundTransparency = trackT })
            tween(knob, 0.1, {
                BackgroundColor3 = knobColor, Size = UDim2.fromOffset(15, 10),
                Position = UDim2.new(0, state and 11 or 2, 0.5, 0),
            })
            task.delay(0.1, function()
                if seq == my then
                    tween(knob, 0.24, {
                        Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, restX, 0.5, 0),
                    }, Enum.EasingStyle.Back)
                end
            end)
        end

        local obj = {}
        function obj:Set(v, silent)
            state = v and true or false
            apply(true)
            setFlag(o, state)
            if not silent and o.Callback then task.spawn(o.Callback, state) end
        end
        function obj:Get() return state end
        hit.Activated:Connect(function() obj:Set(not state) end)
        setFlag(o, state)
        apply(false)
        register(row, o.Name)
        return obj
    end

    function Section:AddButton(o)
        o = o or {}
        local row = newRow()
        local props = {
            BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT, BorderSizePixel = 0,
            Text = o.Text or "Run", Font = Theme.FontBold, TextSize = 10, AutoButtonColor = false,
            TextColor3 = o.Accent and Theme.Warn or Theme.Text, Parent = row,
        }
        if o.Name then
            labelFor(row, o.Name, 0.6)
            props.AnchorPoint = Vector2.new(1, 0.5)
            props.Position = UDim2.new(1, -10, 0.5, 0)
            props.Size = UDim2.new(0, 0, 0, 18)
            props.AutomaticSize = Enum.AutomaticSize.X
        else
            props.AnchorPoint = Vector2.new(0.5, 0.5)
            props.Position = UDim2.fromScale(0.5, 0.5)
            props.Size = UDim2.new(1, -20, 0, 20)
        end
        local btn = new("TextButton", props)
        corner(btn, 5)
        local btnStroke = stroke(btn, WHITE, 1, 0.75)
        if o.Name then pad(btn, 10, 0, 10, 0) end
        pressable(btn, 0.93)
        btn.MouseEnter:Connect(function()
            tween(btn, 0.15, { BackgroundTransparency = Theme.HoverT })
            tween(btnStroke, 0.15, { Transparency = 0.5 })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.2, { BackgroundTransparency = Theme.CtrlT })
            tween(btnStroke, 0.2, { Transparency = 0.75 })
        end)
        btn.Activated:Connect(function()
            if o.Callback then task.spawn(o.Callback) end
        end)
        register(row, o.Name or o.Text)
        local obj = {}
        function obj:SetText(t) btn.Text = t end
        return obj
    end

    function Section:AddSlider(o)
        o = o or {}
        local min, max = o.Min or 0, o.Max or 100
        local inc = o.Increment or 1
        local value = math.clamp(o.Default or min, min, max)
        local row = newRow()
        labelFor(row, o.Name, 0.4)

        local holder = new("TextButton", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.42, 0, 0.5, 0),
            Size = UDim2.new(0.58, -62, 0, 20), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, Parent = row,
        })
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = WHITE,
            BackgroundTransparency = Theme.OffT, BorderSizePixel = 0, Parent = holder,
        })
        corner(bar, 2)
        local fill = new("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar,
        })
        corner(fill, 2)
        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(10, 10), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, ZIndex = 2, Parent = bar,
        })
        corner(knob, 7)
        local box = new("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(40, 18), BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
            BorderSizePixel = 0, Text = "", Font = Theme.Font, TextSize = 10, TextColor3 = Theme.Text,
            ClearTextOnFocus = true, Parent = row,
        })
        corner(box, 5)
        focusGlow(box, stroke(box, WHITE, 1, 0.75), 0.75)

        local function render(t)
            local rel = (max > min) and (value - min) / (max - min) or 0
            tween(fill, t, { Size = UDim2.fromScale(rel, 1) }, Enum.EasingStyle.Quad)
            tween(knob, t, { Position = UDim2.new(rel, 0, 0.5, 0) }, Enum.EasingStyle.Quad)
            if o.OffAtMin and value == min then
                box.Text = "Off"
            else
                box.Text = tostring(value) .. (o.Suffix or "")
            end
        end
        local function setValue(v, silent, t)
            v = min + math.floor((v - min) / inc + 0.5) * inc
            v = tonumber(string.format("%.4f", math.clamp(v, min, max)))
            if v == value then
                render(t or 0.15)
                return
            end
            value = v
            render(t or 0.2)
            setFlag(o, value)
            if not silent and o.Callback then task.spawn(o.Callback, value) end
        end
        local function setFromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            setValue(min + (max - min) * rel, false, 0.07)
        end

        holder.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            window:BeginDrag(input, setFromX, function()
                if scroller then scroller.ScrollingEnabled = true end
                tween(knob, 0.2, { Size = UDim2.fromOffset(10, 10) }, Enum.EasingStyle.Back)
            end)
            if scroller then scroller.ScrollingEnabled = false end
            tween(knob, 0.15, { Size = UDim2.fromOffset(14, 14) }, Enum.EasingStyle.Back)
            setFromX(input.Position.X)
        end)
        box.FocusLost:Connect(function()
            local n = tonumber((box.Text:gsub("[^%d%.%-]", "")))
            if n then setValue(n) else render(0.15) end
        end)

        local obj = {}
        function obj:Set(v) setValue(v) end
        function obj:Get() return value end
        setFlag(o, value)
        render(0)
        register(row, o.Name)
        return obj
    end

    function Section:AddDropdown(o)
        o = o or {}
        local items = o.Options or {}
        local multi = o.Multi == true
        local selected, single = {}, o.Default
        if multi then
            if type(o.Default) == "table" then
                for _, v in ipairs(o.Default) do selected[v] = true end
            end
        elseif single == nil then
            single = items[1]
        end

        local row = newRow()
        labelFor(row, o.Name, 0.4)
        local btn = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(112, 18), BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row,
        })
        corner(btn, 5)
        local btnStroke = stroke(btn, WHITE, 1, 0.75)
        btn.MouseEnter:Connect(function()
            tween(btn, 0.15, { BackgroundTransparency = Theme.HoverT })
            tween(btnStroke, 0.15, { Transparency = 0.5 })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.2, { BackgroundTransparency = Theme.CtrlT })
            tween(btnStroke, 0.2, { Transparency = 0.75 })
        end)
        local valueLbl = text({
            Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, multi and -50 or -24, 1, 0),
            TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", Parent = btn,
        })
        local badge = text({
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
            Size = UDim2.fromOffset(0, 12), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 0.82, BackgroundColor3 = WHITE, Text = "", TextSize = 8,
            TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Center,
            Visible = false, Parent = btn,
        })
        corner(badge, 6); pad(badge, 4, 0, 4, 0)
        local arrow = text({
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.fromOffset(10, 10), Text = "v", TextSize = 8, TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Center, Parent = btn,
        })

        local function result()
            if not multi then return single end
            local out = {}
            for _, it in ipairs(items) do
                if selected[it] then out[#out + 1] = it end
            end
            return out
        end
        local function refresh()
            if multi then
                local r = result()
                valueLbl.Text = (#r == 0) and "None" or tostring(r[1])
                badge.Visible = #r > 1
                badge.Text = "+" .. tostring(#r - 1)
            else
                valueLbl.Text = (single == nil) and "-" or tostring(single)
            end
        end
        local function fire()
            local r = result()
            setFlag(o, r)
            if o.Callback then task.spawn(o.Callback, r) end
        end

        local function open()
            if #items == 0 then return end
            local ph = math.min(#items * 22 + 8, 150)
            tween(arrow, 0.22, { Rotation = 180 })
            local frame = window:OpenPopup(btn, ph, function()
                tween(arrow, 0.22, { Rotation = 0 })
            end)
            local list = new("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, ph), BackgroundTransparency = 1, BorderSizePixel = 0,
                CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Muted, Parent = frame,
            })
            vlist(list, 0); pad(list, 4, 4, 4, 4)
            for i, item in ipairs(items) do
                local ib = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
                    BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = list,
                })
                corner(ib, 4)
                local tx2, check = 8, nil
                if multi then
                    check = new("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 6, 0.5, 0),
                        Size = UDim2.fromOffset(10, 10), BorderSizePixel = 0,
                        BackgroundColor3 = selected[item] and Theme.Accent or WHITE,
                        BackgroundTransparency = selected[item] and 0 or 0.8, Parent = ib,
                    })
                    corner(check, 3); stroke(check, WHITE, 1, 0.6)
                    tx2 = 22
                end
                text({
                    Position = UDim2.fromOffset(tx2, 0), Size = UDim2.new(1, -(tx2 + 4), 1, 0),
                    Text = tostring(item), TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
                    TextColor3 = ((not multi) and item == single) and Theme.Accent or Theme.Text, Parent = ib,
                })
                ib.MouseEnter:Connect(function() tween(ib, 0.12, { BackgroundTransparency = 0.88 }) end)
                ib.MouseLeave:Connect(function() tween(ib, 0.18, { BackgroundTransparency = 1 }) end)
                ib.Activated:Connect(function()
                    if multi then
                        selected[item] = (not selected[item]) or nil
                        local on = selected[item] == true
                        tween(check, 0.15, {
                            BackgroundColor3 = on and Theme.Accent or WHITE,
                            BackgroundTransparency = on and 0 or 0.8,
                        })
                        refresh()
                        fire()
                    else
                        single = item
                        refresh()
                        window:ClosePopup()
                        fire()
                    end
                end)
            end
        end
        btn.Activated:Connect(open)

        local obj = {}
        function obj:Get() return result() end
        function obj:Set(v, silent)
            if multi then
                selected = {}
                if type(v) == "table" then
                    for _, x in ipairs(v) do selected[x] = true end
                end
            else
                single = v
            end
            refresh()
            if not silent then fire() end
        end
        function obj:SetOptions(list, keep)
            items = list or {}
            if not keep then
                if multi then selected = {} else single = items[1] end
            end
            refresh()
        end
        setFlag(o, result())
        refresh()
        register(row, o.Name)
        return obj
    end

    function Section:AddInput(o)
        o = o or {}
        local row = newRow()
        labelFor(row, o.Name, 0.4)
        local box = new("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(120, 18), BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
            BorderSizePixel = 0, Text = o.Default or "", PlaceholderText = o.Placeholder or "",
            PlaceholderColor3 = Theme.Muted, Font = Theme.Font, TextSize = 10, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = row,
        })
        corner(box, 5); pad(box, 6, 0, 6, 0)
        focusGlow(box, stroke(box, WHITE, 1, 0.75), 0.75)
        box.FocusLost:Connect(function(enter)
            if o.Numeric then box.Text = (box.Text:gsub("[^%d%.%-]", "")) end
            setFlag(o, box.Text)
            if o.Callback then task.spawn(o.Callback, box.Text, enter) end
        end)
        register(row, o.Name)
        local obj = {}
        function obj:Get() return box.Text end
        function obj:Set(t) box.Text = tostring(t) end
        return obj
    end

    function Section:AddStats(o)
        o = o or {}
        local cols = o.Columns or 3
        local holder = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = Section:_next(), Parent = body,
        })
        pad(holder, 8, 2, 8, 2)
        new("UIGridLayout", {
            CellSize = UDim2.new(1 / cols, -math.floor(6 * (cols - 1) / cols), 0, 30),
            CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder,
        })
        local values = {}
        for i, it in ipairs(o.Items or {}) do
            local tile = new("Frame", {
                BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, BorderSizePixel = 0,
                LayoutOrder = i, Parent = holder,
            })
            corner(tile, 6); stroke(tile, WHITE, 1, 0.88)
            local ix = 8
            if it.Icon then
                local ih = new("Frame", {
                    BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 0),
                    Size = UDim2.fromOffset(18, 30), Parent = tile,
                })
                makeIcon(ih, it.Icon, 12, Theme.SubText)
                ix = 26
            end
            text({
                Position = UDim2.fromOffset(ix, 4), Size = UDim2.new(1, -(ix + 4), 0, 10),
                Text = string.upper(it.Name or ""), TextSize = 8, TextColor3 = Theme.Muted,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = tile,
            })
            values[it.Name or tostring(i)] = text({
                Position = UDim2.fromOffset(ix, 14), Size = UDim2.new(1, -(ix + 4), 0, 14),
                Text = tostring(it.Value or "-"), Font = Theme.FontBold, TextSize = 11,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = tile,
            })
        end
        local obj = {}
        function obj:Set(name, v)
            if values[name] then values[name].Text = tostring(v) end
        end
        return obj
    end

    function Section:AddFeed(o)
        o = o or {}
        local holder = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = Section:_next(), Parent = body,
        })
        pad(holder, 10, 2, 10, 2); vlist(holder, 8)
        for i, it in ipairs(o.Items or {}) do
            local item = new("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, Parent = holder,
            })
            local tag = it.Tag or "NEW"
            local isFix = (tag == "FIX")
            local tagBox = new("Frame", {
                Size = UDim2.fromOffset(26, 12), BorderSizePixel = 0,
                BackgroundColor3 = isFix and WHITE or Theme.Good,
                BackgroundTransparency = isFix and 0.86 or 0.8, Parent = item,
            })
            corner(tagBox, 3)
            text({
                Size = UDim2.fromScale(1, 1), Text = tag, Font = Theme.FontBold, TextSize = 7,
                TextColor3 = isFix and Theme.SubText or Theme.Good,
                TextXAlignment = Enum.TextXAlignment.Center, Parent = tagBox,
            })
            local content = new("Frame", {
                BackgroundTransparency = 1, Position = UDim2.fromOffset(32, 0),
                Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = item,
            })
            vlist(content, 2)
            text({
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Text = it.Text or "", TextSize = 9, TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 1, Parent = content,
            })
            if it.Meta then
                text({
                    Size = UDim2.new(1, 0, 0, 10), Text = it.Meta, TextSize = 8,
                    TextColor3 = Theme.Muted, LayoutOrder = 2, Parent = content,
                })
            end
        end
    end

    return Section
end

local function newColumn(window, frame, page)
    local Column = { Frame = frame, Page = page, _n = 0 }
    function Column:_next()
        self._n = self._n + 1
        return self._n
    end

    function Column:AddSection(o)
        return newSection(window, Column, o)
    end

    function Column:AddWelcome(o)
        o = o or {}
        local card = new("Frame", {
            BackgroundColor3 = WHITE, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 78), LayoutOrder = Column:_next(), Parent = Column.Frame,
        })
        corner(card, 8); stroke(card, WHITE, 1, 0.78)
        new("UIGradient", {
            Rotation = 20,
            Color = ColorSequence.new(Color3.fromRGB(214, 150, 112), Color3.fromRGB(122, 104, 232)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.42),
                NumberSequenceKeypoint.new(1, 0.5),
            }),
            Parent = card,
        })
        local avatar = new("ImageLabel", {
            Position = UDim2.fromOffset(12, 16), Size = UDim2.fromOffset(46, 46),
            BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, BorderSizePixel = 0,
            Image = "", Parent = card,
        })
        corner(avatar, 23); stroke(avatar, WHITE, 1, 0.55)
        loadAvatar(avatar)
        text({
            Position = UDim2.fromOffset(68, 12), Size = UDim2.new(1, -76, 0, 12),
            Text = o.Title or "Welcome back", TextSize = 9, TextColor3 = Theme.SubText, Parent = card,
        })
        text({
            Position = UDim2.fromOffset(68, 24), Size = UDim2.new(1, -76, 0, 20),
            Text = o.Name or LocalPlayer.DisplayName, Font = Theme.FontBold, TextSize = 15,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
        })
        local chips = new("Frame", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(68, 50),
            Size = UDim2.new(1, -76, 0, 16), Parent = card,
        })
        hlist(chips, 4)
        for i, c in ipairs(o.Chips or { executorName(), "Noctra" }) do
            chip(chips, c, { Bg = Color3.new(0, 0, 0), BgTransparency = 0.5, Color = Theme.Text, Order = i })
        end
        return card
    end

    function Column:AddLinkCard(o)
        o = o or {}
        local color = o.Color or Theme.Blurple
        local card = new("Frame", {
            BackgroundColor3 = color, BackgroundTransparency = 0.82, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 78), LayoutOrder = Column:_next(), Parent = Column.Frame,
        })
        corner(card, 8); stroke(card, color:Lerp(WHITE, 0.4), 1, 0.45)
        local icon = new("Frame", {
            Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(22, 22),
            BackgroundColor3 = color, BorderSizePixel = 0, Parent = card,
        })
        corner(icon, 6)
        text({
            Size = UDim2.fromScale(1, 1), Text = o.Icon or "D", Font = Theme.FontBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center, Parent = icon,
        })
        text({
            Position = UDim2.fromOffset(38, 9), Size = UDim2.new(1, -46, 0, 12),
            Text = o.Title or "Link", Font = Theme.FontBold, TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
        })
        text({
            Position = UDim2.fromOffset(38, 22), Size = UDim2.new(1, -46, 0, 10),
            Text = o.Sub or "", TextSize = 8, TextColor3 = Theme.SubText,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
        })
        local btn = new("TextButton", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8),
            Size = UDim2.new(1, -20, 0, 22), BackgroundColor3 = color, BorderSizePixel = 0,
            Text = o.ButtonText or "Open", Font = Theme.FontBold, TextSize = 10,
            TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Parent = card,
        })
        corner(btn, 5)
        pressable(btn, 0.96)
        btn.MouseEnter:Connect(function() tween(btn, 0.15, { BackgroundColor3 = color:Lerp(WHITE, 0.15) }) end)
        btn.MouseLeave:Connect(function() tween(btn, 0.2, { BackgroundColor3 = color }) end)
        btn.Activated:Connect(function()
            if o.Copy then
                copyText(o.Copy)
                window:Notify({ Title = o.Title or "Copied", Text = "Copied to clipboard." })
            end
            if o.Callback then task.spawn(o.Callback) end
        end)
        return card
    end

    function Column:AddActionBar(list)
        local n = #list
        local bar = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = Column:_next(), Parent = Column.Frame,
        })
        hlist(bar, 6)
        for i, a in ipairs(list) do
            local b = new("TextButton", {
                Size = UDim2.new(1 / n, -math.floor(6 * (n - 1) / n), 1, 0),
                BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CardT, BorderSizePixel = 0,
                Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = bar,
            })
            corner(b, 7); stroke(b, WHITE, 1, 0.84)
            local inner = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1, Parent = b,
            })
            hlist(inner, 5, Enum.VerticalAlignment.Center, Enum.HorizontalAlignment.Center)
            if a.Icon then
                text({
                    Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X, Text = a.Icon,
                    Font = Theme.FontBold, TextSize = 10, TextColor3 = Theme.SubText, LayoutOrder = 1, Parent = inner,
                })
            end
            text({
                Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X,
                Text = a.Text or "", TextSize = 9, LayoutOrder = 2, Parent = inner,
            })
            pressable(b, 0.9, inner)
            b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundTransparency = 0.85 }) end)
            b.MouseLeave:Connect(function() tween(b, 0.2, { BackgroundTransparency = Theme.CardT }) end)
            b.Activated:Connect(function()
                if a.Callback then task.spawn(a.Callback) end
            end)
        end
    end

    return Column
end

local function makeRow(parent, weights, order)
    local count, total = #weights, 0
    for _, w in ipairs(weights) do total = total + w end
    local row = new("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Parent = parent,
    })
    hlist(row, GAP)
    local cols = {}
    for i, w in ipairs(weights) do
        local s = w / total
        cols[i] = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(s, -math.floor((count - 1) * GAP * s), 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, Parent = row,
        })
        vlist(cols[i], GAP)
    end
    return row, cols
end

local Noctra = {}
Noctra.Version = "1.2.0"
Noctra.Copy = copyText
Noctra.Tints = Tints
Noctra.Theme = Theme

function Noctra:CreateWindow(config)
    config = config or {}
    if env.NoctraUI and type(env.NoctraUI.Destroy) == "function" then
        pcall(function() env.NoctraUI:Destroy() end)
    end

    local Window = { Tabs = {}, Elements = {}, Sections = {}, Flags = {}, Connections = {}, Visible = false }
    local conns = Window.Connections

    local guiParent = getGuiParent()
    local leftover = guiParent:FindFirstChild(GUI_NAME)
    if leftover then leftover:Destroy() end
    local oldBlur = Lighting:FindFirstChild(BLUR_NAME)
    if oldBlur then oldBlur:Destroy() end

    local gui = new("ScreenGui", {
        Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = guiParent,
    })
    Window.Gui = gui
    env.NoctraUI = Window

    local blurFx = new("BlurEffect", { Name = BLUR_NAME, Size = 0, Parent = Lighting })
    local blurOn, blurSize = false, 14

    local vp = (Camera and Camera.ViewportSize) or Vector2.new(800, 600)
    local width  = math.clamp(config.Width or 560, 380, math.max(vp.X - 24, 380))
    local height = math.clamp(config.Height or 340, 260, math.max(vp.Y - 24, 260))
    local baseT  = Theme.WinT

    local root = new("Frame", {
        Name = "Window", BackgroundTransparency = 1, Visible = false,
        Position = UDim2.new(0.5, -math.floor(width / 2), 0.5, -math.floor(height / 2)),
        Size = UDim2.fromOffset(width, height), Parent = gui,
    })
    local main = new("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Base, BackgroundTransparency = baseT,
        BorderSizePixel = 0, Active = true, Parent = root,
    })
    corner(main, 10)
    local mainStroke = stroke(main, WHITE, 1, 0)
    shineStroke(mainStroke)
    local winScale = new("UIScale", { Scale = 1, Parent = main })

    local sheen = new("Frame", {
        Name = "Sheen", BackgroundColor3 = WHITE, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), Parent = main,
    })
    corner(sheen, 10)
    new("UIGradient", {
        Rotation = 35,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.84),
            NumberSequenceKeypoint.new(0.28, 0.94),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(0.82, 0.96),
            NumberSequenceKeypoint.new(1, 0.9),
        }),
        Parent = sheen,
    })

    local veil = new("Frame", {
        Name = "Veil", BackgroundColor3 = Theme.Base, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = main,
    })
    corner(veil, 10)
    Window.Root, Window.Main = root, main

    local titleBar = new("Frame", {
        Name = "TitleBar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = main,
    })
    new("Frame", {
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), Parent = titleBar,
    })
    makeDraggable(titleBar, root, conns)

    local left = new("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = titleBar,
    })
    hlist(left, 6, Enum.VerticalAlignment.Center)
    local logo = new("Frame", {
        Size = UDim2.fromOffset(22, 22), BackgroundColor3 = WHITE, BackgroundTransparency = 0.86,
        BorderSizePixel = 0, LayoutOrder = 1, Parent = left,
    })
    corner(logo, 6); stroke(logo, WHITE, 1, 0.7)
    text({
        Size = UDim2.fromScale(1, 1), Text = config.Logo or "N", Font = Theme.FontBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = logo,
    })
    text({
        Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
        Text = config.Name or "NOCTRA", Font = Theme.FontBold, TextSize = 13, LayoutOrder = 2, Parent = left,
    })
    local gameLbl = text({
        Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
        Text = "/ " .. (config.Game or "Game"), TextSize = 10, TextColor3 = Theme.SubText,
        LayoutOrder = 3, Parent = left,
    })
    chip(left, config.Version or "v1.0.0", { Order = 4 })
    local _, statusLbl, statusDot = chip(left, config.Status or "Idle", {
        Dot = true, Order = 5, Color = Theme.Text,
    })
    if not config.Game then
        task.spawn(function()
            local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
            if ok and info and info.Name and gameLbl.Parent then gameLbl.Text = "/ " .. info.Name end
        end)
    end

    local right = new("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X, Parent = titleBar,
    })
    hlist(right, 6, Enum.VerticalAlignment.Center)
    local searchFrame = new("Frame", {
        Size = UDim2.fromOffset(140, 22), BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
        BorderSizePixel = 0, LayoutOrder = 1, Parent = right,
    })
    corner(searchFrame, 7)
    local searchStroke = stroke(searchFrame, WHITE, 1, 0.75)
    local lens = new("Frame", {
        Position = UDim2.fromOffset(8, 6), Size = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1, Parent = searchFrame,
    })
    corner(lens, 4); stroke(lens, Theme.SubText, 1)
    new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(17, 16),
        Size = UDim2.fromOffset(4, 1), Rotation = 45, BackgroundColor3 = Theme.SubText,
        BorderSizePixel = 0, Parent = searchFrame,
    })
    local searchBox = new("TextBox", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -28, 1, 0),
        Text = "", PlaceholderText = "Search", PlaceholderColor3 = Theme.SubText,
        TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = searchFrame,
    })
    focusGlow(searchBox, searchStroke, 0.75)
    local minBtn = new("TextButton", {
        Size = UDim2.fromOffset(22, 22), BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
        BorderSizePixel = 0, Text = "-", Font = Theme.FontBold, TextSize = 14, TextColor3 = Theme.SubText,
        AutoButtonColor = false, LayoutOrder = 2, Parent = right,
    })
    corner(minBtn, 7); stroke(minBtn, WHITE, 1, 0.75)
    pressable(minBtn, 0.88)
    minBtn.MouseEnter:Connect(function() tween(minBtn, 0.15, { BackgroundTransparency = Theme.HoverT }) end)
    minBtn.MouseLeave:Connect(function() tween(minBtn, 0.2, { BackgroundTransparency = Theme.CtrlT }) end)

    local sidebar = new("Frame", {
        Position = UDim2.fromOffset(6, 44), Size = UDim2.new(0, 34, 1, -50),
        BackgroundColor3 = Theme.Base, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = main,
    })
    corner(sidebar, 8); stroke(sidebar, WHITE, 1, 0.86)
    local selector = new("Frame", {
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.82, BorderSizePixel = 0, Visible = false,
        Position = UDim2.fromOffset(4, 5), Size = UDim2.fromOffset(26, 26), Parent = sidebar,
    })
    corner(selector, 7); stroke(selector, WHITE, 1, 0.7)
    local tabHolder = new("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -34), Parent = sidebar,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = tabHolder,
    })
    pad(tabHolder, 0, 5, 0, 0)
    local sideAvatar = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -6),
        Size = UDim2.fromOffset(22, 22), BackgroundColor3 = WHITE, BackgroundTransparency = 0.85,
        BorderSizePixel = 0, Image = "", Parent = sidebar,
    })
    corner(sideAvatar, 11)
    loadAvatar(sideAvatar)

    local body = new("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(48, 44),
        Size = UDim2.new(1, -56, 1, -52), Parent = main,
    })
    local headerTitle = text({
        Size = UDim2.new(0.5, 0, 0, 20), Text = "", Font = Theme.FontBold, TextSize = 15, Parent = body,
    })
    local headerSub = text({
        Position = UDim2.fromOffset(0, 20), Size = UDim2.new(0.5, 0, 0, 12), Text = "",
        Font = Theme.FontBold, TextSize = 8, TextColor3 = Theme.Muted, Parent = body,
    })
    local pagesHolder = new("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(1, 0, 1, -40), ClipsDescendants = true, Parent = body,
    })
    local pageVeil = new("Frame", {
        BackgroundColor3 = Theme.Base, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = pagesHolder,
    })
    local function playPageIn(frame)
        frame.Position = UDim2.fromOffset(0, 14)
        pageVeil.BackgroundTransparency = 0.45
        tween(frame, 0.4, { Position = UDim2.fromOffset(0, 0) })
        tween(pageVeil, 0.3, { BackgroundTransparency = 1 })
    end

    local grip = new("TextButton", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -2, 1, -2),
        Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, ZIndex = 5, Parent = main,
    })
    new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(12, 1),
        Rotation = -45, BackgroundColor3 = Theme.Muted, BorderSizePixel = 0, ZIndex = 5, Parent = grip,
    })
    new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(6, 1),
        Rotation = -45, BackgroundColor3 = Theme.Muted, BorderSizePixel = 0, ZIndex = 5, Parent = grip,
    })
    makeResizable(grip, root, Vector2.new(400, 260), conns)

    local activeDrag
    local function endDrag()
        local d = activeDrag
        if not d then return end
        activeDrag = nil
        if d.conn then d.conn:Disconnect() end
        if d.stop then d.stop() end
    end
    function Window:EndDrag() endDrag() end
    function Window:BeginDrag(input, move, stop)
        endDrag()
        local d = {
            input = input, move = move, stop = stop,
            touch = (input.UserInputType == Enum.UserInputType.Touch),
        }
        d.conn = input.Changed:Connect(function()
            local st = input.UserInputState
            if st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
                if activeDrag == d then endDrag() end
            end
        end)
        activeDrag = d
        return d
    end
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        local d = activeDrag
        if not d then return end
        if d.touch then
            if input == d.input then
                local st = input.UserInputState
                if st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
                    endDrag()
                else
                    d.move(input.Position.X)
                end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                d.move(input.Position.X)
            else
                endDrag()
            end
        end
    end))
    table.insert(conns, UserInputService.InputEnded:Connect(function(input)
        local d = activeDrag
        if not d then return end
        if (d.touch and input == d.input)
            or (not d.touch and input.UserInputType == Enum.UserInputType.MouseButton1) then
            endDrag()
        end
    end))

    local overlay = new("Frame", {
        Name = "Overlay", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = gui,
    })
    local popup
    function Window:ClosePopup(instant)
        local p = popup
        if not p then return end
        popup = nil
        if p.onClose then pcall(p.onClose) end
        p.blocker.Visible = false
        if instant then
            p.holder:Destroy()
            return
        end
        tween(p.frame, 0.16, { Size = UDim2.fromOffset(p.w, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if p.holder.Parent then p.holder:Destroy() end
        end)
    end
    function Window:OpenPopup(anchor, h, onClose)
        Window:ClosePopup(true)
        local holder = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = overlay,
        })
        local blocker = new("TextButton", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "",
            AutoButtonColor = false, Parent = holder,
        })
        blocker.Activated:Connect(function() Window:ClosePopup() end)
        local frame = new("Frame", {
            BackgroundColor3 = Theme.Base, BackgroundTransparency = 0.08, BorderSizePixel = 0,
            ClipsDescendants = true, ZIndex = 2, Parent = holder,
        })
        corner(frame, 6); shineStroke(stroke(frame, WHITE, 1, 0.2))
        local ox, oy = overlay.AbsolutePosition.X, overlay.AbsolutePosition.Y
        local ax, ay = anchor.AbsolutePosition.X - ox, anchor.AbsolutePosition.Y - oy
        local w = math.max(anchor.AbsoluteSize.X, 110)
        local x = math.max(math.min(ax, overlay.AbsoluteSize.X - w - 4), 4)
        local below = ay + anchor.AbsoluteSize.Y + 4
        if below + h > overlay.AbsoluteSize.Y - 4 then
            frame.AnchorPoint = Vector2.new(0, 1)
            frame.Position = UDim2.fromOffset(x, ay - 4)
        else
            frame.Position = UDim2.fromOffset(x, below)
        end
        frame.Size = UDim2.fromOffset(w, 0)
        tween(frame, 0.22, { Size = UDim2.fromOffset(w, h) })
        popup = { holder = holder, blocker = blocker, frame = frame, w = w, onClose = onClose }
        return frame
    end

    local toasts = new("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, -12), Size = UDim2.fromOffset(230, 300), ZIndex = 20, Parent = gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = toasts,
    })
    function Window:Notify(o)
        o = o or {}
        local wrap = new("Frame", {
            BackgroundTransparency = 1, Size = UDim2.fromOffset(220, 46), Parent = toasts,
        })
        local card = new("Frame", {
            BackgroundColor3 = Theme.Base, BackgroundTransparency = 0.12, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 30, 0, 0), Parent = wrap,
        })
        corner(card, 8); shineStroke(stroke(card, WHITE, 1, 0.1))
        text({
            Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 14),
            Text = o.Title or "Noctra", Font = Theme.FontBold, TextSize = 10, Parent = card,
        })
        text({
            Position = UDim2.fromOffset(10, 21), Size = UDim2.new(1, -20, 0, 20),
            Text = o.Text or "", TextSize = 9, TextColor3 = Theme.SubText,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
        })
        tween(card, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
        task.delay(o.Duration or 3.5, function()
            if not card.Parent then return end
            tween(card, 0.3, { Position = UDim2.new(1, 30, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
            wrap:Destroy()
        end)
    end

    local orb = new("TextButton", {
        Name = "Orb", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 32, 0.5, 0),
        Size = UDim2.fromOffset(36, 36), BackgroundColor3 = Theme.Base, BackgroundTransparency = 0.25,
        BorderSizePixel = 0, Text = config.Logo or "N", Font = Theme.FontBold, TextSize = 15,
        TextColor3 = Theme.Text, AutoButtonColor = false, ZIndex = 5, Parent = gui,
    })
    corner(orb, 10); shineStroke(stroke(orb, WHITE, 1, 0.1))
    pressable(orb, 0.88)

    local contentParts = { titleBar, sidebar, body, grip }
    local function setContentVisible(v)
        for _, c in ipairs(contentParts) do c.Visible = v end
    end
    local function applyBlur()
        tween(blurFx, 0.35, { Size = (blurOn and Window.Visible) and blurSize or 0 })
    end

    local animId = 0
    function Window:SetVisible(v)
        animId = animId + 1
        local id = animId
        Window.Visible = v
        endDrag()
        Window:ClosePopup(true)
        applyBlur()
        if v then
            root.Visible = true
            winScale.Scale = 0.9
            setContentVisible(false)
            veil.BackgroundTransparency = 1
            main.BackgroundTransparency = 1
            sheen.BackgroundTransparency = 1
            mainStroke.Transparency = 1
            tween(winScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
            tween(main, 0.25, { BackgroundTransparency = baseT })
            tween(sheen, 0.25, { BackgroundTransparency = 0 })
            tween(mainStroke, 0.25, { Transparency = 0 })
            task.delay(0.12, function()
                if animId ~= id then return end
                veil.BackgroundTransparency = 0.3
                setContentVisible(true)
                tween(veil, 0.36, { BackgroundTransparency = 1 })
            end)
        else
            tween(veil, 0.12, { BackgroundTransparency = 0.3 })
            tween(winScale, 0.3, { Scale = 0.92 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.12, function()
                if animId ~= id then return end
                setContentVisible(false)
                tween(veil, 0.16, { BackgroundTransparency = 1 })
                tween(main, 0.16, { BackgroundTransparency = 1 })
                tween(sheen, 0.16, { BackgroundTransparency = 1 })
                tween(mainStroke, 0.16, { Transparency = 1 })
            end)
            task.delay(0.3, function()
                if animId == id then root.Visible = false end
            end)
        end
    end
    function Window:SetTransparency(t)
        baseT = math.clamp(t, 0, 0.85)
        if Window.Visible then main.BackgroundTransparency = baseT end
    end
    function Window:SetTint(color)
        if typeof(color) ~= "Color3" then return end
        Theme.Base = color
        tween(main, 0.4, { BackgroundColor3 = color })
        tween(sidebar, 0.4, { BackgroundColor3 = color })
        tween(orb, 0.4, { BackgroundColor3 = color })
        veil.BackgroundColor3 = color
        pageVeil.BackgroundColor3 = color
    end
    function Window:SetBlur(on, size)
        if on ~= nil then blurOn = on and true or false end
        if size then blurSize = size end
        applyBlur()
    end
    function Window:SetStatus(label, color)
        statusLbl.Text = label
        if statusDot then tween(statusDot, 0.2, { BackgroundColor3 = color or Theme.SubText }) end
    end
    function Window:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() blurFx:Destroy() end)
        gui:Destroy()
        if env.NoctraUI == Window then env.NoctraUI = nil end
    end
    Window.Unload = Window.Destroy

    minBtn.Activated:Connect(function() Window:SetVisible(false) end)
    makeDraggable(orb, orb, conns, function() Window:SetVisible(not Window.Visible) end)
    table.insert(conns, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            Window:SetVisible(not Window.Visible)
        end
    end))

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        local titleMatch, anyVisible = {}, {}
        for _, s in ipairs(Window.Sections) do
            if q ~= "" and s.TitleLower ~= "" and string.find(s.TitleLower, q, 1, true) then
                titleMatch[s] = true
            end
        end
        for _, e in ipairs(Window.Elements) do
            local match = (q == "") or titleMatch[e.Section] or (string.find(e.Name, q, 1, true) ~= nil)
            e.Row.Visible = match and true or false
            if match then anyVisible[e.Section] = true end
        end
        for _, s in ipairs(Window.Sections) do
            s.Card.Visible = (q == "") or (anyVisible[s] == true)
        end
    end)

    local currentTab
    local function selectTab(tab)
        if currentTab == tab then return end
        if currentTab then currentTab:_hide() end
        currentTab = tab
        Window.CurrentTab = tab
        tab:_show()
    end

    function Window:AddTab(o)
        if type(o) ~= "table" then o = { Name = tostring(o) } end
        local Tab = { Name = o.Name or "Tab", Pages = {}, Index = #Window.Tabs + 1 }
        local ty = 5 + (Tab.Index - 1) * 30

        local btn = new("TextButton", {
            Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false, LayoutOrder = Tab.Index, Parent = tabHolder,
        })
        corner(btn, 7)
        local icon = makeIcon(btn, o.Icon or string.upper(string.sub(Tab.Name, 1, 1)), 14, Theme.Muted)
        local active = false
        btn.MouseEnter:Connect(function()
            if not active then tweenIcon(icon, Theme.SubText, 0.15) end
        end)
        btn.MouseLeave:Connect(function()
            if not active then tweenIcon(icon, Theme.Muted, 0.2) end
        end)

        local pillBar = new("Frame", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2),
            Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = WHITE, BackgroundTransparency = Theme.CtrlT,
            BorderSizePixel = 0, Visible = false, Parent = body,
        })
        corner(pillBar, 8); stroke(pillBar, WHITE, 1, 0.78); pad(pillBar, 2, 2, 2, 2)
        hlist(pillBar, 2, Enum.VerticalAlignment.Center)

        function Tab:SelectPage(page)
            Tab.CurrentPage = page
            for _, p in ipairs(Tab.Pages) do
                local on = (p == page)
                local show = on and currentTab == Tab
                if show then
                    if not p.Frame.Visible then
                        p.Frame.Visible = true
                        if Window.Visible then
                            playPageIn(p.Frame)
                        else
                            p.Frame.Position = UDim2.fromOffset(0, 0)
                        end
                    end
                else
                    p.Frame.Visible = false
                end
                tween(p.Pill, 0.2, {
                    BackgroundTransparency = on and 0.78 or 1,
                    TextColor3 = on and Theme.Text or Theme.SubText,
                })
            end
            if currentTab == Tab and page then
                local same = (#Tab.Pages == 1) and (string.lower(page.Name) == string.lower(Tab.Name))
                headerSub.Text = same and "" or string.upper(page.Name)
            end
        end
        function Tab:_show()
            active = true
            tweenIcon(icon, Theme.Text)
            selector.Visible = true
            tween(selector, 0.32, { Position = UDim2.fromOffset(4, ty) })
            headerTitle.Text = Tab.Name
            pillBar.Visible = #Tab.Pages > 1
            if Tab.CurrentPage then
                Tab:SelectPage(Tab.CurrentPage)
            else
                headerSub.Text = ""
            end
        end
        function Tab:_hide()
            active = false
            tweenIcon(icon, Theme.Muted)
            pillBar.Visible = false
            for _, p in ipairs(Tab.Pages) do p.Frame.Visible = false end
        end
        btn.Activated:Connect(function()
            Window:ClosePopup()
            selectTab(Tab)
        end)

        function Tab:AddPage(name)
            local Page = { Name = name or Tab.Name, _n = 0 }
            function Page:_next()
                self._n = self._n + 1
                return self._n
            end

            local scroller = new("ScrollingFrame", {
                Name = Page.Name, BackgroundTransparency = 1, BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
                ScrollBarImageColor3 = WHITE, ScrollBarImageTransparency = 0.6,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = false, Parent = pagesHolder,
            })
            vlist(scroller, GAP); pad(scroller, 2, 2, 8, 10)
            Page.Frame = scroller

            local pill = new("TextButton", {
                Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = WHITE, BackgroundTransparency = 1,
                BorderSizePixel = 0, Text = Page.Name, Font = Theme.FontBold, TextSize = 9,
                TextColor3 = Theme.SubText, AutoButtonColor = false,
                LayoutOrder = #Tab.Pages + 1, Parent = pillBar,
            })
            corner(pill, 6); pad(pill, 8, 0, 8, 0)
            Page.Pill = pill
            table.insert(Tab.Pages, Page)
            pill.Activated:Connect(function()
                Window:ClosePopup()
                Tab:SelectPage(Page)
            end)
            if #Tab.Pages == 1 then Tab:SelectPage(Page) end
            if currentTab == Tab then pillBar.Visible = #Tab.Pages > 1 end

            function Page:AddRow(weights)
                local _, cols = makeRow(scroller, weights or { 1 }, Page:_next())
                local out = {}
                for i, c in ipairs(cols) do out[i] = newColumn(Window, c, Page) end
                return out
            end

            function Page:AddGroup(label)
                local Group = {}
                local holder = new("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = Page:_next(), Parent = scroller,
                })
                vlist(holder, 6)
                local content = new("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = holder,
                })
                if label then
                    local gh = new("TextButton", {
                        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, Parent = holder,
                    })
                    text({
                        Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -20, 1, 0),
                        Text = string.upper(label), Font = Theme.FontBold, TextSize = 8,
                        TextColor3 = Theme.Muted, Parent = gh,
                    })
                    local chev = text({
                        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
                        Size = UDim2.fromOffset(12, 12), Text = "v", TextSize = 9, TextColor3 = Theme.Muted,
                        TextXAlignment = Enum.TextXAlignment.Center, Parent = gh,
                    })
                    local setHidden, isHidden = newCollapser(content, function(v)
                        tween(chev, 0.22, { Rotation = v and -90 or 0 })
                    end)
                    gh.Activated:Connect(function() setHidden(not isHidden()) end)
                end
                local _, cols = makeRow(content, { 1, 1 }, 1)
                Group.Left = newColumn(Window, cols[1], Page)
                Group.Right = newColumn(Window, cols[2], Page)
                function Group:AddSection(so)
                    so = so or {}
                    return ((so.Side == "Right") and Group.Right or Group.Left):AddSection(so)
                end
                return Group
            end

            function Page:AddSection(so)
                Page._default = Page._default or Page:AddGroup(nil)
                return Page._default:AddSection(so)
            end

            return Page
        end

        function Tab:AddSection(so)
            Tab._default = Tab._default or Tab:AddPage(Tab.Name)
            return Tab._default:AddSection(so)
        end

        table.insert(Window.Tabs, Tab)
        if not currentTab then selectTab(Tab) end
        return Tab
    end

    task.defer(function() Window:SetVisible(true) end)
    return Window
end

return Noctra
