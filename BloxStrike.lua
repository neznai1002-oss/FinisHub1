-- ============================================================================
-- [[ shitaro.crack | FULL 1:1 BLOX STRIKE ENGINE & UI REPLICA (FIXED) ]]
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================================
-- 1. КОНФИГУРАЦИЯ
-- ============================================================================
local Config = {
    RageEnable = true,
    AutoShoot = true,
    SilentAim = true,
    FOV = 180,
    ShowFOV = false,
    Override = "none",
    Hitboxes = { head = true, chest = true, pelvis = true, arms = false, legs = false },
    Multipoint = { head = true, chest = true, pelvis = false, arms = false, legs = false },
    MultipointScale = 75,
    Hitchance = 85,
    MinDamage = 40,
    AutoWall = true,
    AutoScope = false,
    AutoStop = false,
    HitboxExpander = true,
    HitboxSize = 6.5,

    TriggerEnable = true,
    TriggerDelay = 15,
    TriggerBurst = 1,
    TriggerThroughWalls = true,
    TriggerHeadOnly = false,

    AAEnable = true,
    Yaw = "backward",
    YawOffset = 0,
    YawModifier = "jitter",
    ModifierOffset = 38,
    Pitch = "down",
    Spin = false,
    SpinSpeed = 35,
    EnableManuals = true,
    ManualLeftKey = Enum.KeyCode.Z,
    ManualRightKey = Enum.KeyCode.C,
    ManualBackKey = Enum.KeyCode.X,
    ManualMode = "toggle",
    ManualAngle = true,
    Freestanding = false,
    ActiveManual = "none",

    ESPEnable = true,
    TeamCheck = false,
    BoxESP = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameESP = true,
    WeaponESP = true,
    HealthBar = true,
    HealthText = true,
    EnemyChams = true,
    EnemyChamsColor = Color3.fromRGB(255, 255, 255),
    EnemyChamsTransparency = 0.05,
    SelfChams = true,
    SelfChamsColor = Color3.fromRGB(58, 75, 185),
    SelfChamsOutline = Color3.fromRGB(210, 220, 255),
    BulletTracers = true,
    TracerColor = Color3.fromRGB(240, 235, 255),
    TracerDuration = 0.75,
    HitChams = true,

    ThirdPerson = true,
    ThirdPersonDist = 11,
    ThirdPersonHeight = 1.2,
    BunnyHop = false,
    BhopSpeed = 26,
    NoFlash = true,
    NoSmoke = true,
    Hitlogs = true,
    Killsay = false,

    MenuKey = Enum.KeyCode.RightShift,
    Watermark = true,
    BottomIndicators = true
}

local Palette = {
    WindowBg = Color3.fromRGB(15, 15, 18),
    PanelBg = Color3.fromRGB(20, 20, 24),
    ElementBg = Color3.fromRGB(27, 27, 33),
    ElementHover = Color3.fromRGB(34, 34, 42),
    Stroke = Color3.fromRGB(36, 36, 44),
    Accent = Color3.fromRGB(165, 132, 245),
    AccentDim = Color3.fromRGB(108, 84, 168),
    TextMain = Color3.fromRGB(235, 235, 240),
    TextMuted = Color3.fromRGB(140, 140, 152),
    TextDark = Color3.fromRGB(95, 95, 108),
    White = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(110, 235, 130),
    Red = Color3.fromRGB(245, 95, 95)
}

-- ============================================================================
-- 2. GUI ИНИЦИАЛИЗАЦИЯ
-- ============================================================================
local function GetSafeGuiParent()
    local ok, res = pcall(function()
        return (gethui and gethui()) or CoreGui
    end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = GetSafeGuiParent()
for _, v in ipairs(GuiParent:GetChildren()) do
    if v.Name == "ShitaroCrackV2" then v:Destroy() end
end
if Workspace:FindFirstChild("ShitaroEffects") then
    Workspace.ShitaroEffects:Destroy()
end

local EffectsFolder = Instance.new("Folder")
EffectsFolder.Name = "ShitaroEffects"
EffectsFolder.Parent = Workspace

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShitaroCrackV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GuiParent

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESPContainer"
ESPContainer.Parent = ScreenGui

local ChamsContainer = Instance.new("Folder")
ChamsContainer.Name = "ChamsContainer"
ChamsContainer.Parent = ScreenGui

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Palette.Stroke
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- ============================================================================
-- 3. ХИТЛОГИ
-- ============================================================================
local HitlogHolder = Instance.new("Frame")
HitlogHolder.Name = "HitlogHolder"
HitlogHolder.Size = UDim2.new(0, 560, 0, 190)
HitlogHolder.Position = UDim2.new(0.5, -280, 0.77, -190)
HitlogHolder.BackgroundTransparency = 1
HitlogHolder.Parent = ScreenGui

local HitlogList = Instance.new("UIListLayout")
HitlogList.SortOrder = Enum.SortOrder.LayoutOrder
HitlogList.VerticalAlignment = Enum.VerticalAlignment.Bottom
HitlogList.HorizontalAlignment = Enum.HorizontalAlignment.Center
HitlogList.Padding = UDim.new(0, 3)
HitlogList.Parent = HitlogHolder

local function PushHitlog(richText, duration)
    if not Config.Hitlogs then return end
    duration = duration or 4.5

    local Item = Instance.new("Frame")
    Item.Size = UDim2.new(0, 0, 0, 20)
    Item.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Item.BackgroundTransparency = 0.22
    Item.BorderSizePixel = 0
    Item.ClipsDescendants = true
    Item.Parent = HitlogHolder
    MakeCorner(Item, 3)
    local st = MakeStroke(Item, Palette.Stroke, 1, 0.35)

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 2, 1, 0)
    AccentBar.BackgroundColor3 = Palette.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Item

    local Txt = Instance.new("TextLabel")
    Txt.Size = UDim2.new(1, -14, 1, 0)
    Txt.Position = UDim2.new(0, 8, 0, 0)
    Txt.BackgroundTransparency = 1
    Txt.Font = Enum.Font.GothamMedium
    Txt.RichText = true
    Txt.Text = "<font color='rgb(165,132,245)'>shitaro.crack</font> <font color='rgb(110,110,125)'>|</font> " .. richText
    Txt.TextColor3 = Palette.TextMain
    Txt.TextSize = 11
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.TextStrokeTransparency = 0.5
    Txt.Parent = Item

    local targetW = math.clamp(Txt.TextBounds.X + 22, 240, 550)
    TweenService:Create(Item, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetW, 0, 20)
    }):Play()

    task.delay(duration, function()
        if not Item or not Item.Parent then return end
        local fade = TweenService:Create(Item, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, targetW, 0, 0)
        })
        TweenService:Create(Txt, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
        TweenService:Create(AccentBar, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        TweenService:Create(st, TweenInfo.new(0.18), {Transparency = 1}):Play()
        fade:Play()
        fade.Completed:Wait()
        if Item then Item:Destroy() end
    end)
end

-- ============================================================================
-- 4. ОКНО МЕНЮ
-- ============================================================================
local MainWin = Instance.new("Frame")
MainWin.Name = "MainWin"
MainWin.Size = UDim2.new(0, 640, 0, 410)
MainWin.Position = UDim2.new(0.5, -320, 0.45, -205)
MainWin.BackgroundColor3 = Palette.WindowBg
MainWin.BorderSizePixel = 0
MainWin.ClipsDescendants = true
MainWin.Parent = ScreenGui
MakeCorner(MainWin, 6)
MakeStroke(MainWin, Palette.Stroke, 1)

local TopHeader = Instance.new("Frame")
TopHeader.Size = UDim2.new(1, 0, 0, 30)
TopHeader.BackgroundColor3 = Palette.PanelBg
TopHeader.BorderSizePixel = 0
TopHeader.Parent = MainWin

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
HeaderDivider.BackgroundColor3 = Palette.Stroke
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = TopHeader

local LogoButton = Instance.new("TextButton")
LogoButton.Size = UDim2.new(0, 130, 1, 0)
LogoButton.Position = UDim2.new(0, 12, 0, 0)
LogoButton.BackgroundTransparency = 1
LogoButton.Font = Enum.Font.GothamBold
LogoButton.RichText = true
LogoButton.Text = "shitaro<font color='rgb(165,132,245)'>.crack</font>  <font size='9' color='rgb(140,140,152)'>▼</font>"
LogoButton.TextColor3 = Palette.TextMain
LogoButton.TextSize = 12
LogoButton.TextXAlignment = Enum.TextXAlignment.Left
LogoButton.Parent = TopHeader

local TopRightBar = Instance.new("Frame")
TopRightBar.Size = UDim2.new(0, 220, 1, 0)
TopRightBar.Position = UDim2.new(1, -228, 0, 0)
TopRightBar.BackgroundTransparency = 1
TopRightBar.Parent = TopHeader

local trLayout = Instance.new("UIListLayout")
trLayout.FillDirection = Enum.FillDirection.Horizontal
trLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
trLayout.VerticalAlignment = Enum.VerticalAlignment.Center
trLayout.Padding = UDim.new(0, 6)
trLayout.Parent = TopRightBar

for idx, hName in ipairs({"execution", "setting", "feedback"}) do
    local hb = Instance.new("TextButton")
    hb.Size = UDim2.new(0, 62, 0, 20)
    hb.BackgroundColor3 = (idx == 1) and Palette.ElementBg or Palette.PanelBg
    hb.BackgroundTransparency = (idx == 1) and 0 or 1
    hb.Font = Enum.Font.Gotham
    hb.Text = hName
    hb.TextColor3 = (idx == 1) and Palette.TextMain or Palette.TextMuted
    hb.TextSize = 11
    hb.Parent = TopRightBar
    MakeCorner(hb, 4)
    if idx == 1 then MakeStroke(hb, Palette.Stroke, 1) end
end

-- Перетаскивание
do
    local dragging, dragInput, dragStart, startPos
    TopHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainWin.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopHeader.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainWin.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local KeybindPopup = Instance.new("Frame")
KeybindPopup.Name = "KeybindPopup"
KeybindPopup.Size = UDim2.new(0, 105, 0, 92)
KeybindPopup.Position = UDim2.new(0, 440, 0, 275)
KeybindPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
KeybindPopup.Visible = false
KeybindPopup.ZIndex = 50
KeybindPopup.Parent = MainWin
MakeCorner(KeybindPopup, 5)
MakeStroke(KeybindPopup, Palette.Stroke, 1)

local kpLayout = Instance.new("UIListLayout")
kpLayout.Padding = UDim.new(0, 2)
kpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
kpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
kpLayout.Parent = KeybindPopup

local kpButtons = {}
for _, kpMode in ipairs({"key", "toggle", "hold", "always"}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 19)
    b.BackgroundColor3 = Palette.ElementBg
    b.BackgroundTransparency = (kpMode == "toggle") and 0 or 1
    b.Font = Enum.Font.Gotham
    b.Text = (kpMode == "key") and "  ⌨  key" or ("  ●  " .. kpMode)
    b.TextColor3 = (kpMode == "toggle") and Palette.Accent or Palette.TextMuted
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 51
    b.Parent = KeybindPopup
    MakeCorner(b, 3)
    kpButtons[kpMode] = b

    b.MouseButton1Click:Connect(function()
        if kpMode ~= "key" then
            Config.ManualMode = kpMode
            for m, btn in pairs(kpButtons) do
                if m ~= "key" then
                    btn.BackgroundTransparency = (m == kpMode) and 0 or 1
                    btn.TextColor3 = (m == kpMode) and Palette.Accent or Palette.TextMuted
                end
            end
        end
        KeybindPopup.Visible = false
    end)
end

-- ============================================================================
-- 5. КОНСТРУКТОР ЭЛЕМЕНТОВ
-- ============================================================================
local function CreateToggle(parent, text, defaultVal, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -40, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Gotham
    Lbl.Text = text
    Lbl.TextColor3 = Palette.TextMuted
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(0, 26, 0, 13)
    Track.Position = UDim2.new(1, -26, 0.5, -6.5)
    Track.BackgroundColor3 = defaultVal and Palette.AccentDim or Palette.ElementBg
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Row
    MakeCorner(Track, 99)
    MakeStroke(Track, Palette.Stroke, 1)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 9, 0, 9)
    Knob.Position = defaultVal and UDim2.new(1, -11, 0.5, -4.5) or UDim2.new(0, 2, 0.5, -4.5)
    Knob.BackgroundColor3 = defaultVal and Palette.Accent or Palette.TextDark
    Knob.Parent = Track
    MakeCorner(Knob, 99)

    local state = defaultVal
    Track.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Track, TweenInfo.new(0.14), {
            BackgroundColor3 = state and Palette.AccentDim or Palette.ElementBg
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -11, 0.5, -4.5) or UDim2.new(0, 2, 0.5, -4.5),
            BackgroundColor3 = state and Palette.Accent or Palette.TextDark
        }):Play()
        callback(state)
    end)
    return Row
end

local function CreateSlider(parent, text, minV, maxV, defV, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.46, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Gotham
    Lbl.Text = text
    Lbl.TextColor3 = Palette.TextMuted
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local BarBg = Instance.new("TextButton")
    BarBg.Size = UDim2.new(0.52, 0, 0, 6)
    BarBg.Position = UDim2.new(0.48, 0, 0.5, -3)
    BarBg.BackgroundColor3 = Palette.ElementBg
    BarBg.Text = ""
    BarBg.AutoButtonColor = false
    BarBg.Parent = Row
    MakeCorner(BarBg, 99)
    MakeStroke(BarBg, Palette.Stroke, 1)

    local alpha = math.clamp((defV - minV) / (maxV - minV), 0, 1)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(alpha, 0, 1, 0)
    Fill.BackgroundColor3 = Palette.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = BarBg
    MakeCorner(Fill, 99)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 10, 0, 10)
    Circle.Position = UDim2.new(alpha, -5, 0.5, -5)
    Circle.BackgroundColor3 = Palette.White
    Circle.Parent = BarBg
    MakeCorner(Circle, 99)

    local draggingSlider = false
    local function updateSlide(input)
        local rel = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / math.max(1, BarBg.AbsoluteSize.X), 0, 1)
        local val = math.floor(minV + (maxV - minV) * rel)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Circle.Position = UDim2.new(rel, -5, 0.5, -5)
        callback(val)
    end

    BarBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlide(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlide(input)
        end
    end)
    return Row
end

local function CreateDropdown(parent, text, options, defaultIndex, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.46, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Gotham
    Lbl.Text = text
    Lbl.TextColor3 = Palette.TextMuted
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local idx = defaultIndex or 1
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.52, 0, 0, 18)
    DropBtn.Position = UDim2.new(0.48, 0, 0.5, -9)
    DropBtn.BackgroundColor3 = Palette.ElementBg
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.Text = "  " .. options[idx]
    DropBtn.TextColor3 = Palette.TextMain
    DropBtn.TextSize = 10
    DropBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropBtn.Parent = Row
    MakeCorner(DropBtn, 3)
    MakeStroke(DropBtn, Palette.Stroke, 1)

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 14, 1, 0)
    Arrow.Position = UDim2.new(1, -15, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Font = Enum.Font.Gotham
    Arrow.Text = "▼"
    Arrow.TextColor3 = Palette.TextDark
    Arrow.TextSize = 8
    Arrow.Parent = DropBtn

    DropBtn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        DropBtn.Text = "  " .. options[idx]
        callback(options[idx])
    end)
    return Row
end

local function CreateKeybindRow(parent, text, defaultLabel, onActivate)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.46, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Gotham
    Lbl.Text = text
    Lbl.TextColor3 = Palette.TextMuted
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0.52, 0, 0, 18)
    BindBtn.Position = UDim2.new(0.48, 0, 0.5, -9)
    BindBtn.BackgroundColor3 = Palette.ElementBg
    BindBtn.Font = Enum.Font.Gotham
    BindBtn.Text = defaultLabel
    BindBtn.TextColor3 = Palette.TextMain
    BindBtn.TextSize = 10
    BindBtn.Parent = Row
    MakeCorner(BindBtn, 3)
    MakeStroke(BindBtn, Palette.Stroke, 1)

    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        KeybindPopup.Visible = not KeybindPopup.Visible
        onActivate()
    end)
    BindBtn.MouseButton2Click:Connect(function()
        listening = true
        BindBtn.Text = "..."
    end)
    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            BindBtn.Text = string.lower(input.KeyCode.Name)
            onActivate(input.KeyCode)
        end
    end)
    return Row
end

-- ============================================================================
-- 6. СТРАНИЦЫ
-- ============================================================================
local Pages = {}
local function CreatePage(name, visible)
    local p = Instance.new("Frame")
    p.Name = "Page_" .. name
    p.Size = UDim2.new(1, 0, 1, -30)
    p.Position = UDim2.new(0, 0, 0, 30)
    p.BackgroundTransparency = 1
    p.Visible = visible or false
    p.Parent = MainWin
    Pages[name] = p
    return p
end

local PageAim = CreatePage("aim", true)
local PageTrigger = CreatePage("trigger", false)
local PageVisuals = CreatePage("visuals", false)
local PageMisc = CreatePage("misc", false)
local PageAntiAim = CreatePage("anti-aim", false)
local PageSettings = CreatePage("settings", false)

-- AИМ страница
local LeftCol = Instance.new("Frame")
LeftCol.Size = UDim2.new(0, 235, 1, -20)
LeftCol.Position = UDim2.new(0, 10, 0, 10)
LeftCol.BackgroundColor3 = Palette.PanelBg
LeftCol.BorderSizePixel = 0
LeftCol.Parent = PageAim
MakeCorner(LeftCol, 5)
MakeStroke(LeftCol, Palette.Stroke, 1)

local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Size = UDim2.new(1, -18, 1, -14)
LeftScroll.Position = UDim2.new(0, 9, 0, 7)
LeftScroll.BackgroundTransparency = 1
LeftScroll.ScrollBarThickness = 2
LeftScroll.ScrollBarImageColor3 = Palette.Accent
LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 360)
LeftScroll.Parent = LeftCol

local lsLayout = Instance.new("UIListLayout")
lsLayout.Padding = UDim.new(0, 5)
lsLayout.SortOrder = Enum.SortOrder.LayoutOrder
lsLayout.Parent = LeftScroll

CreateToggle(LeftScroll, "enable", Config.RageEnable, function(v) Config.RageEnable = v end)
CreateToggle(LeftScroll, "auto shoot", Config.AutoShoot, function(v) Config.AutoShoot = v end)
CreateToggle(LeftScroll, "silent aim", Config.SilentAim, function(v) Config.SilentAim = v end)
CreateDropdown(LeftScroll, "override", {"none", "force head", "force body"}, 1, function(v) Config.Override = v end)
CreateDropdown(LeftScroll, "hitboxes", {"head, chest...", "head only", "all bones"}, 1, function(v)
    Config.Hitboxes.head = true
    Config.Hitboxes.chest = (v ~= "head only")
end)
CreateDropdown(LeftScroll, "multipoint", {"head, chest...", "head only", "off"}, 1, function(v)
    Config.Multipoint.head = (v ~= "off")
end)
CreateSlider(LeftScroll, "hitchance", 0, 100, Config.Hitchance, function(v) Config.Hitchance = v end)
CreateSlider(LeftScroll, "min damage", 1, 120, Config.MinDamage, function(v) Config.MinDamage = v end)
CreateToggle(LeftScroll, "auto wall", Config.AutoWall, function(v) Config.AutoWall = v end)
CreateToggle(LeftScroll, "hitbox expander", Config.HitboxExpander, function(v) Config.HitboxExpander = v end)
CreateSlider(LeftScroll, "hitbox size", 2, 14, math.floor(Config.HitboxSize), function(v) Config.HitboxSize = v end)
CreateToggle(LeftScroll, "third person", Config.ThirdPerson, function(v) Config.ThirdPerson = v end)

local RightAATop = Instance.new("Frame")
RightAATop.Size = UDim2.new(0, 375, 0, 215)
RightAATop.Position = UDim2.new(0, 255, 0, 10)
RightAATop.BackgroundColor3 = Palette.PanelBg
RightAATop.BorderSizePixel = 0
RightAATop.Parent = PageAim
MakeCorner(RightAATop, 5)
MakeStroke(RightAATop, Palette.Stroke, 1)

local aaHeader = Instance.new("TextLabel")
aaHeader.Size = UDim2.new(1, -16, 0, 16)
aaHeader.Position = UDim2.new(0, 10, 0, 4)
aaHeader.BackgroundTransparency = 1
aaHeader.Font = Enum.Font.GothamBold
aaHeader.Text = "anti-aim"
aaHeader.TextColor3 = Palette.TextMuted
aaHeader.TextSize = 11
aaHeader.TextXAlignment = Enum.TextXAlignment.Left
aaHeader.Parent = RightAATop

local aaControls = Instance.new("Frame")
aaControls.Size = UDim2.new(0, 210, 1, -24)
aaControls.Position = UDim2.new(0, 10, 0, 21)
aaControls.BackgroundTransparency = 1
aaControls.Parent = RightAATop

local aacLayout = Instance.new("UIListLayout")
aacLayout.Padding = UDim.new(0, 2)
aacLayout.SortOrder = Enum.SortOrder.LayoutOrder
aacLayout.Parent = aaControls

CreateToggle(aaControls, "enable", Config.AAEnable, function(v) Config.AAEnable = v end)
CreateDropdown(aaControls, "yaw", {"backward", "none", "spin", "static"}, 1, function(v) Config.Yaw = v end)
CreateSlider(aaControls, "yaw offset", -180, 180, Config.YawOffset, function(v) Config.YawOffset = v end)
CreateDropdown(aaControls, "yaw modifier", {"jitter", "none", "offset", "random"}, 1, function(v) Config.YawModifier = v end)
CreateSlider(aaControls, "modifier offset", 0, 180, Config.ModifierOffset, function(v) Config.ModifierOffset = v end)
CreateDropdown(aaControls, "pitch", {"down", "none", "up", "zero"}, 1, function(v) Config.Pitch = v end)
CreateToggle(aaControls, "spin", Config.Spin, function(v) Config.Spin = v end)
CreateSlider(aaControls, "spin speed", 1, 100, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

local PreviewPane = Instance.new("Frame")
PreviewPane.Size = UDim2.new(0, 135, 0, 182)
PreviewPane.Position = UDim2.new(1, -145, 0, 22)
PreviewPane.BackgroundColor3 = Palette.WindowBg
PreviewPane.BorderSizePixel = 0
PreviewPane.Parent = RightAATop
MakeCorner(PreviewPane, 4)
MakeStroke(PreviewPane, Palette.Stroke, 1)

local PreviewBox = Instance.new("Frame")
PreviewBox.Size = UDim2.new(0, 76, 0, 126)
PreviewBox.Position = UDim2.new(0.5, -34, 0.5, -60)
PreviewBox.BackgroundTransparency = 1
PreviewBox.Parent = PreviewPane
MakeStroke(PreviewBox, Palette.White, 1)

local PreviewUser = Instance.new("TextLabel")
PreviewUser.Size = UDim2.new(1, 0, 0, 12)
PreviewUser.Position = UDim2.new(0, 0, 0, -14)
PreviewUser.BackgroundTransparency = 1
PreviewUser.Font = Enum.Font.Gotham
PreviewUser.Text = "username"
PreviewUser.TextColor3 = Palette.TextMain
PreviewUser.TextSize = 9
PreviewUser.Parent = PreviewBox

local PreviewWeapon = Instance.new("TextLabel")
PreviewWeapon.Size = UDim2.new(1, 0, 0, 12)
PreviewWeapon.Position = UDim2.new(0, 0, 1, 2)
PreviewWeapon.BackgroundTransparency = 1
PreviewWeapon.Font = Enum.Font.Gotham
PreviewWeapon.Text = "weapon"
PreviewWeapon.TextColor3 = Palette.TextMuted
PreviewWeapon.TextSize = 9
PreviewWeapon.Parent = PreviewBox

local PreviewHPBar = Instance.new("Frame")
PreviewHPBar.Size = UDim2.new(0, 2, 1, 0)
PreviewHPBar.Position = UDim2.new(0, -5, 0, 0)
PreviewHPBar.BackgroundColor3 = Palette.White
PreviewHPBar.BorderSizePixel = 0
PreviewHPBar.Parent = PreviewBox

local PreviewHPTxt = Instance.new("TextLabel")
PreviewHPTxt.Size = UDim2.new(0, 34, 0, 10)
PreviewHPTxt.Position = UDim2.new(0, -38, 0, -2)
PreviewHPTxt.BackgroundTransparency = 1
PreviewHPTxt.Font = Enum.Font.Gotham
PreviewHPTxt.Text = "100HP"
PreviewHPTxt.TextColor3 = Palette.TextMain
PreviewHPTxt.TextSize = 8
PreviewHPTxt.TextXAlignment = Enum.TextXAlignment.Right
PreviewHPTxt.Parent = PreviewBox

local function AddBoneLine(x, y, w, h)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, w, 0, h)
    line.Position = UDim2.new(0.5, x, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(205, 205, 215)
    line.BorderSizePixel = 0
    line.Parent = PreviewBox
end

local HeadRing = Instance.new("Frame")
HeadRing.Size = UDim2.new(0, 18, 0, 18)
HeadRing.Position = UDim2.new(0.5, -9, 0, 10)
HeadRing.BackgroundTransparency = 1
HeadRing.Parent = PreviewBox
MakeCorner(HeadRing, 99)
MakeStroke(HeadRing, Color3.fromRGB(215, 215, 225), 1.2)

AddBoneLine(-1, 28, 2, 44)
AddBoneLine(-18, 34, 36, 2)
AddBoneLine(-18, 34, 2, 34)
AddBoneLine(16, 34, 2, 34)
AddBoneLine(-10, 72, 20, 2)
AddBoneLine(-10, 72, 2, 40)
AddBoneLine(8, 72, 2, 40)

local function AddHitboxNode(x, y, boneKey)
    local node = Instance.new("TextButton")
    node.Size = UDim2.new(0, 6, 0, 6)
    node.Position = UDim2.new(0.5, x - 3, 0, y - 3)
    node.BackgroundColor3 = Config.Hitboxes[boneKey] and Palette.Accent or Palette.ElementBg
    node.Text = ""
    node.Parent = PreviewBox
    MakeCorner(node, 99)
    MakeStroke(node, Palette.White, 0.8)

    node.MouseButton1Click:Connect(function()
        Config.Hitboxes[boneKey] = not Config.Hitboxes[boneKey]
        node.BackgroundColor3 = Config.Hitboxes[boneKey] and Palette.Accent or Palette.ElementBg
    end)
end

AddHitboxNode(0, 19, "head")
AddHitboxNode(0, 42, "chest")
AddHitboxNode(0, 66, "pelvis")
AddHitboxNode(-17, 50, "arms")
AddHitboxNode(17, 50, "arms")
AddHitboxNode(-9, 95, "legs")
AddHitboxNode(9, 95, "legs")

local RightOtherBot = Instance.new("Frame")
RightOtherBot.Size = UDim2.new(0, 375, 0, 145)
RightOtherBot.Position = UDim2.new(0, 255, 0, 235)
RightOtherBot.BackgroundColor3 = Palette.PanelBg
RightOtherBot.BorderSizePixel = 0
RightOtherBot.Parent = PageAim
MakeCorner(RightOtherBot, 5)
MakeStroke(RightOtherBot, Palette.Stroke, 1)

local otherHeader = Instance.new("TextLabel")
otherHeader.Size = UDim2.new(1, -16, 0, 16)
otherHeader.Position = UDim2.new(0, 10, 0, 4)
otherHeader.BackgroundTransparency = 1
otherHeader.Font = Enum.Font.GothamBold
otherHeader.Text = "other"
otherHeader.TextColor3 = Palette.TextMuted
otherHeader.TextSize = 11
otherHeader.TextXAlignment = Enum.TextXAlignment.Left
otherHeader.Parent = RightOtherBot

local otherControls = Instance.new("Frame")
otherControls.Size = UDim2.new(0, 210, 1, -22)
otherControls.Position = UDim2.new(0, 10, 0, 20)
otherControls.BackgroundTransparency = 1
otherControls.Parent = RightOtherBot

local ocLayout = Instance.new("UIListLayout")
ocLayout.Padding = UDim.new(0, 1)
ocLayout.SortOrder = Enum.SortOrder.LayoutOrder
ocLayout.Parent = otherControls

CreateToggle(otherControls, "enable manuals", Config.EnableManuals, function(v) Config.EnableManuals = v end)
CreateKeybindRow(otherControls, "manual left", "z", function(k)
    if k then Config.ManualLeftKey = k end
    Config.ActiveManual = (Config.ActiveManual == "left") and "none" or "left"
end)
CreateKeybindRow(otherControls, "manual right", "c", function(k)
    if k then Config.ManualRightKey = k end
    Config.ActiveManual = (Config.ActiveManual == "right") and "none" or "right"
end)
CreateKeybindRow(otherControls, "manual back", "x", function(k)
    if k then Config.ManualBackKey = k end
    Config.ActiveManual = (Config.ActiveManual == "back") and "none" or "back"
end)
CreateToggle(otherControls, "manual angle", Config.ManualAngle, function(v) Config.ManualAngle = v end)
CreateToggle(otherControls, "freestanding", Config.Freestanding, function(v) Config.Freestanding = v end)

local function SetupTwoColumnPage(page, leftTitle, rightTitle)
    local L = Instance.new("Frame")
    L.Size = UDim2.new(0, 302, 1, -20)
    L.Position = UDim2.new(0, 10, 0, 10)
    L.BackgroundColor3 = Palette.PanelBg
    L.Parent = page
    MakeCorner(L, 5)
    MakeStroke(L, Palette.Stroke, 1)

    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(1, -16, 0, 18)
    lt.Position = UDim2.new(0, 10, 0, 5)
    lt.BackgroundTransparency = 1
    lt.Font = Enum.Font.GothamBold
    lt.Text = leftTitle
    lt.TextColor3 = Palette.TextMuted
    lt.TextSize = 11
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = L

    local lCont = Instance.new("Frame")
    lCont.Size = UDim2.new(1, -20, 1, -30)
    lCont.Position = UDim2.new(0, 10, 0, 26)
    lCont.BackgroundTransparency = 1
    lCont.Parent = L
    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0, 5)
    ll.Parent = lCont

    local R = Instance.new("Frame")
    R.Size = UDim2.new(0, 308, 1, -20)
    R.Position = UDim2.new(0, 322, 0, 10)
    R.BackgroundColor3 = Palette.PanelBg
    R.Parent = page
    MakeCorner(R, 5)
    MakeStroke(R, Palette.Stroke, 1)

    local rt = Instance.new("TextLabel")
    rt.Size = UDim2.new(1, -16, 0, 18)
    rt.Position = UDim2.new(0, 10, 0, 5)
    rt.BackgroundTransparency = 1
    rt.Font = Enum.Font.GothamBold
    rt.Text = rightTitle
    rt.TextColor3 = Palette.TextMuted
    rt.TextSize = 11
    rt.TextXAlignment = Enum.TextXAlignment.Left
    rt.Parent = R

    local rCont = Instance.new("Frame")
    rCont.Size = UDim2.new(1, -20, 1, -30)
    rCont.Position = UDim2.new(0, 10, 0, 26)
    rCont.BackgroundTransparency = 1
    rCont.Parent = R
    local rl = Instance.new("UIListLayout")
    rl.Padding = UDim.new(0, 5)
    rl.Parent = rCont

    return lCont, rCont
end

do
    local L, R = SetupTwoColumnPage(PageTrigger, "triggerbot", "accuracy & filter")
    CreateToggle(L, "enable triggerbot", Config.TriggerEnable, function(v) Config.TriggerEnable = v end)
    CreateSlider(L, "reaction delay (ms)", 0, 250, Config.TriggerDelay, function(v) Config.TriggerDelay = v end)
    CreateSlider(L, "burst shots", 1, 5, Config.TriggerBurst, function(v) Config.TriggerBurst = v end)
    CreateToggle(L, "shoot through walls", Config.TriggerThroughWalls, function(v) Config.TriggerThroughWalls = v end)
    CreateToggle(R, "head only", Config.TriggerHeadOnly, function(v) Config.TriggerHeadOnly = v end)
    CreateToggle(R, "team check (disable in warmup)", Config.TeamCheck, function(v) Config.TeamCheck = v end)
end

do
    local L, R = SetupTwoColumnPage(PageVisuals, "enemy esp", "chams & world")
    CreateToggle(L, "enable esp", Config.ESPEnable, function(v) Config.ESPEnable = v end)
    CreateToggle(L, "2d bounding box", Config.BoxESP, function(v) Config.BoxESP = v end)
    CreateToggle(L, "player name", Config.NameESP, function(v) Config.NameESP = v end)
    CreateToggle(L, "equipped weapon", Config.WeaponESP, function(v) Config.WeaponESP = v end)
    CreateToggle(L, "health bar & text", Config.HealthBar, function(v)
        Config.HealthBar = v
        Config.HealthText = v
    end)
    CreateToggle(L, "team check (disable for warmup)", Config.TeamCheck, function(v) Config.TeamCheck = v end)

    CreateToggle(R, "enemy white chams (wallhack)", Config.EnemyChams, function(v) Config.EnemyChams = v end)
    CreateToggle(R, "local thirdperson chams (blue)", Config.SelfChams, function(v) Config.SelfChams = v end)
    CreateToggle(R, "bullet beam tracers", Config.BulletTracers, function(v) Config.BulletTracers = v end)
    CreateToggle(R, "remove flashbang", Config.NoFlash, function(v) Config.NoFlash = v end)
    CreateToggle(R, "remove smoke", Config.NoSmoke, function(v) Config.NoSmoke = v end)
end

do
    local L, R = SetupTwoColumnPage(PageMisc, "camera & movement", "notifications & logs")
    CreateToggle(L, "third person", Config.ThirdPerson, function(v) Config.ThirdPerson = v end)
    CreateSlider(L, "third person distance", 4, 25, Config.ThirdPersonDist, function(v) Config.ThirdPersonDist = v end)
    CreateToggle(L, "bunny hop", Config.BunnyHop, function(v) Config.BunnyHop = v end)
    CreateSlider(L, "bhop speed", 16, 48, Config.BhopSpeed, function(v) Config.BhopSpeed = v end)

    CreateToggle(R, "center hit / kill logs", Config.Hitlogs, function(v) Config.Hitlogs = v end)
    CreateToggle(R, "bottom dock indicators", Config.BottomIndicators, function(v) Config.BottomIndicators = v end)
end

do
    local L, R = SetupTwoColumnPage(PageAntiAim, "anti-aim angles", "manuals & desync")
    CreateToggle(L, "enable anti-aim", Config.AAEnable, function(v) Config.AAEnable = v end)
    CreateDropdown(L, "yaw base", {"backward", "none", "spin", "static"}, 1, function(v) Config.Yaw = v end)
    CreateSlider(L, "yaw offset", -180, 180, Config.YawOffset, function(v) Config.YawOffset = v end)
    CreateDropdown(L, "yaw modifier", {"jitter", "none", "offset", "random"}, 1, function(v) Config.YawModifier = v end)
    CreateSlider(L, "modifier range", 0, 180, Config.ModifierOffset, function(v) Config.ModifierOffset = v end)

    CreateToggle(R, "spinbot override", Config.Spin, function(v) Config.Spin = v end)
    CreateSlider(R, "spin speed", 1, 100, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)
    CreateToggle(R, "enable manual arrows", Config.EnableManuals, function(v) Config.EnableManuals = v end)
end

do
    local L, R = SetupTwoColumnPage(PageSettings, "configuration", "script info")
    CreateToggle(L, "show bottom bar", Config.BottomIndicators, function(v) Config.BottomIndicators = v end)
    CreateDropdown(R, "build channel", {"shitaro.crack [live]", "nightly"}, 1, function() end)
end

-- ============================================================================
-- 7. НИЖНЯЯ ПАНЕЛЬ
-- ============================================================================
local BottomBarContainer = Instance.new("Frame")
BottomBarContainer.Name = "BottomBarContainer"
BottomBarContainer.Size = UDim2.new(0, 640, 0, 28)
BottomBarContainer.Position = UDim2.new(0.5, -320, 0.45, 214)
BottomBarContainer.BackgroundTransparency = 1
BottomBarContainer.Parent = ScreenGui

local LeftLogoPill = Instance.new("Frame")
LeftLogoPill.Size = UDim2.new(0, 28, 1, 0)
LeftLogoPill.Position = UDim2.new(0, 0, 0, 0)
LeftLogoPill.BackgroundColor3 = Palette.WindowBg
LeftLogoPill.Parent = BottomBarContainer
MakeCorner(LeftLogoPill, 5)
MakeStroke(LeftLogoPill, Palette.Stroke, 1)

local LeftLogoTxt = Instance.new("TextLabel")
LeftLogoTxt.Size = UDim2.new(1, 0, 1, 0)
LeftLogoTxt.BackgroundTransparency = 1
LeftLogoTxt.Font = Enum.Font.GothamBold
LeftLogoTxt.Text = "S"
LeftLogoTxt.TextColor3 = Palette.Accent
LeftLogoTxt.TextSize = 13
LeftLogoTxt.Parent = LeftLogoPill

local CenterDock = Instance.new("Frame")
CenterDock.Size = UDim2.new(0, 415, 1, 0)
CenterDock.Position = UDim2.new(0, 34, 0, 0)
CenterDock.BackgroundColor3 = Palette.WindowBg
CenterDock.Parent = BottomBarContainer
MakeCorner(CenterDock, 5)
MakeStroke(CenterDock, Palette.Stroke, 1)

local cdLayout = Instance.new("UIListLayout")
cdLayout.FillDirection = Enum.FillDirection.Horizontal
cdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
cdLayout.Padding = UDim.new(0, 4)
cdLayout.Parent = CenterDock

local dockTabDefs = {
    {id = "aim", label = "⊕ aim"},
    {id = "trigger", label = "⚡ trigger"},
    {id = "visuals", label = "👁 visuals"},
    {id = "misc", label = "❖ misc"},
    {id = "anti-aim", label = "↻ anti-aim"},
    {id = "settings", label = "⚙ settings"}
}

local dockBtns = {}
for idx, def in ipairs(dockTabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 64, 0, 20)
    btn.BackgroundColor3 = Palette.ElementBg
    btn.BackgroundTransparency = (idx == 1) and 0 or 1
    btn.Font = Enum.Font.GothamMedium
    btn.Text = def.label
    btn.TextColor3 = (idx == 1) and Palette.Accent or Palette.TextMuted
    btn.TextSize = 10
    btn.Parent = CenterDock
    MakeCorner(btn, 4)
    dockBtns[def.id] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(Pages) do
            p.Visible = (k == def.id)
        end
        for k, b in pairs(dockBtns) do
            b.BackgroundTransparency = (k == def.id) and 0 or 1
            b.TextColor3 = (k == def.id) and Palette.Accent or Palette.TextMuted
        end
    end)
end

local RightStatusPill = Instance.new("Frame")
RightStatusPill.Size = UDim2.new(0, 185, 1, 0)
RightStatusPill.Position = UDim2.new(1, -185, 0, 0)
RightStatusPill.BackgroundColor3 = Palette.WindowBg
RightStatusPill.Parent = BottomBarContainer
MakeCorner(RightStatusPill, 5)
MakeStroke(RightStatusPill, Palette.Stroke, 1)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -12, 1, 0)
StatusLabel.Position = UDim2.new(0, 6, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.RichText = true
StatusLabel.Text = "🎥 3rd camera  |  ⇄ manual: none"
StatusLabel.TextColor3 = Palette.TextMuted
StatusLabel.TextSize = 10
StatusLabel.Parent = RightStatusPill

local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Size = UDim2.new(0, 102, 0, 26)
FloatingToggle.Position = UDim2.new(0, 12, 0.45, 0)
FloatingToggle.BackgroundColor3 = Palette.WindowBg
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.RichText = true
FloatingToggle.Text = "shitaro<font color='rgb(165,132,245)'>.crack</font>"
FloatingToggle.TextColor3 = Palette.TextMain
FloatingToggle.TextSize = 11
FloatingToggle.Parent = ScreenGui
MakeCorner(FloatingToggle, 5)
MakeStroke(FloatingToggle, Palette.Accent, 1)

local menuShown = true
local function ToggleMainUI()
    menuShown = not menuShown
    MainWin.Visible = menuShown
    BottomBarContainer.Visible = menuShown and Config.BottomIndicators
    if not menuShown then KeybindPopup.Visible = false end
end

FloatingToggle.MouseButton1Click:Connect(ToggleMainUI)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.MenuKey or input.KeyCode == Enum.KeyCode.Insert then
        ToggleMainUI()
    elseif Config.EnableManuals then
        if input.KeyCode == Config.ManualLeftKey then
            Config.ActiveManual = (Config.ActiveManual == "left") and "none" or "left"
        elseif input.KeyCode == Config.ManualRightKey then
            Config.ActiveManual = (Config.ActiveManual == "right") and "none" or "right"
        elseif input.KeyCode == Config.ManualBackKey then
            Config.ActiveManual = (Config.ActiveManual == "back") and "none" or "back"
        end
    end
end)

-- ============================================================================
-- 8. СКАНЕР СУЩНОСТЕЙ (С КЭШЕМ)
-- ============================================================================
local CachedEntities = {}
local LastEntityScan = 0

local function GetLocalCharacter()
    if LocalPlayer.Character and LocalPlayer.Character.Parent then
        return LocalPlayer.Character
    end
    local charsFolder = Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("Players")
    if charsFolder then
        local found = charsFolder:FindFirstChild(LocalPlayer.Name)
        if found then return found end
    end
    return Workspace:FindFirstChild(LocalPlayer.Name)
end

local function IsSameTeam(plr, model)
    if not Config.TeamCheck then return false end
    if plr and LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then
        return true
    end
    local myChar = GetLocalCharacter()
    if myChar and model then
        local myTeamAttr = myChar:GetAttribute("Team") or (plr and plr:GetAttribute("Team"))
        local theirTeamAttr = model:GetAttribute("Team") or (plr and plr:GetAttribute("Team"))
        if myTeamAttr ~= nil and theirTeamAttr ~= nil and myTeamAttr == theirTeamAttr then
            return true
        end
    end
    return false
end

local function GetEntityHealth(model, plr)
    if not model then return 0, 100 end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    local hpAttr = model:GetAttribute("Health") or (plr and plr:GetAttribute("Health"))
    if type(hpAttr) == "number" then return hpAttr, 100 end
    local hpVal = model:FindFirstChild("Health")
    if hpVal and hpVal:IsA("ValueBase") then
        return tonumber(hpVal.Value) or 100, 100
    end
    return 100, 100
end

local function GetWeaponName(model)
    if not model then return "knife" end
    local tool = model:FindFirstChildOfClass("Tool")
    if tool then return string.lower(tool.Name) end
    local weapAttr = model:GetAttribute("Weapon") or model:GetAttribute("EquippedWeapon") or model:GetAttribute("Gun")
    if type(weapAttr) == "string" and #weapAttr > 0 then
        return string.lower(weapAttr)
    end
    for _, ch in ipairs(model:GetChildren()) do
        if ch:IsA("Model") or ch:IsA("Folder") then
            local n = string.lower(ch.Name)
            if n ~= "head" and n ~= "arms" and n ~= "shirt" and n ~= "pants" then
                return n
            end
        end
    end
    return "awp"
end

local function ScanAllEnemies()
    -- Кэш увеличен до 0.4с для снижения нагрузки в бою
    if tick() - LastEntityScan < 0.4 then
        return CachedEntities
    end
    LastEntityScan = tick()

    local list = {}
    local seenModels = {}
    local myChar = GetLocalCharacter()
    if myChar then seenModels[myChar] = true end

    local function TryAddModel(model, plr)
        if not model or seenModels[model] or not model:IsA("Model") then return end
        local head = model:FindFirstChild("Head")
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model.PrimaryPart
        if not head or not root then return end

        local hp, maxHp = GetEntityHealth(model, plr)
        if hp <= 0 then return end
        if IsSameTeam(plr, model) then return end

        seenModels[model] = true
        table.insert(list, {
            Model = model,
            Player = plr,
            Name = plr and plr.Name or model.Name,
            Head = head,
            Root = root,
            Health = hp,
            MaxHealth = maxHp
        })
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then TryAddModel(plr.Character, plr) end
            local charsFolder = Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("Players")
            if charsFolder and charsFolder:FindFirstChild(plr.Name) then
                TryAddModel(charsFolder:FindFirstChild(plr.Name), plr)
            end
        end
    end

    -- Только специализированные контейнеры (БЕЗ рекурсии по Workspace — это главный краш-фактор)
    for _, cname in ipairs({"Characters", "Players", "Bots"}) do
        local container = Workspace:FindFirstChild(cname)
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") and child.Name ~= LocalPlayer.Name then
                    local linkedPlr = Players:GetPlayerFromCharacter(child) or Players:FindFirstChild(child.Name)
                    if linkedPlr ~= LocalPlayer then
                        TryAddModel(child, linkedPlr)
                    end
                end
            end
        end
    end

    CachedEntities = list
    return list
end

-- ============================================================================
-- 9. ESP + CHAMS (только Highlight, без BoxHandleAdornment)
-- ============================================================================
local ESPObjects = {}
local HealthMemory = {}

local function GetOrCreateESP(model)
    if ESPObjects[model] then return ESPObjects[model] end

    local BoxFrame = Instance.new("Frame")
    BoxFrame.Name = "ESPBox"
    BoxFrame.BackgroundTransparency = 1
    BoxFrame.Visible = false
    BoxFrame.Parent = ESPContainer

    local OuterStroke = Instance.new("UIStroke")
    OuterStroke.Color = Palette.White
    OuterStroke.Thickness = 1.2
    OuterStroke.Parent = BoxFrame

    local NameTag = Instance.new("TextLabel")
    NameTag.Size = UDim2.new(0, 160, 0, 13)
    NameTag.Position = UDim2.new(0.5, 0, 0, -14)
    NameTag.AnchorPoint = Vector2.new(0.5, 0)
    NameTag.BackgroundTransparency = 1
    NameTag.Font = Enum.Font.GothamMedium
    NameTag.TextColor3 = Palette.White
    NameTag.TextStrokeTransparency = 0.2
    NameTag.TextSize = 11
    NameTag.Parent = BoxFrame

    local WeapTag = Instance.new("TextLabel")
    WeapTag.Size = UDim2.new(0, 160, 0, 12)
    WeapTag.Position = UDim2.new(0.5, 0, 1, 2)
    WeapTag.AnchorPoint = Vector2.new(0.5, 0)
    WeapTag.BackgroundTransparency = 1
    WeapTag.Font = Enum.Font.Gotham
    WeapTag.TextColor3 = Color3.fromRGB(225, 225, 235)
    WeapTag.TextStrokeTransparency = 0.2
    WeapTag.TextSize = 10
    WeapTag.Parent = BoxFrame

    local HPBg = Instance.new("Frame")
    HPBg.Size = UDim2.new(0, 3, 1, 0)
    HPBg.Position = UDim2.new(0, -6, 0, 0)
    HPBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    HPBg.BackgroundTransparency = 0.3
    HPBg.BorderSizePixel = 0
    HPBg.Parent = BoxFrame

    local HPFill = Instance.new("Frame")
    HPFill.Size = UDim2.new(1, 0, 1, 0)
    HPFill.Position = UDim2.new(0, 0, 1, 0)
    HPFill.AnchorPoint = Vector2.new(0, 1)
    HPFill.BackgroundColor3 = Palette.White
    HPFill.BorderSizePixel = 0
    HPFill.Parent = HPBg

    local HPLabel = Instance.new("TextLabel")
    HPLabel.Size = UDim2.new(0, 44, 0, 11)
    HPLabel.Position = UDim2.new(0, -52, 0, -2)
    HPLabel.BackgroundTransparency = 1
    HPLabel.Font = Enum.Font.GothamBold
    HPLabel.TextColor3 = Palette.White
    HPLabel.TextStrokeTransparency = 0.2
    HPLabel.TextSize = 9
    HPLabel.TextXAlignment = Enum.TextXAlignment.Right
    HPLabel.Parent = BoxFrame

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ShitaroEnemyHL"
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillColor = Config.EnemyChamsColor
    Highlight.OutlineColor = Palette.White
    Highlight.FillTransparency = 0.08
    Highlight.OutlineTransparency = 0
    Highlight.Adornee = model
    Highlight.Parent = ChamsContainer

    ESPObjects[model] = {
        Box = BoxFrame,
        Name = NameTag,
        Weap = WeapTag,
        HPBg = HPBg,
        HPFill = HPFill,
        HPLabel = HPLabel,
        Highlight = Highlight
    }
    return ESPObjects[model]
end

local function CleanupStaleESP(activeModels)
    for model, data in pairs(ESPObjects) do
        if not model or not model.Parent or not activeModels[model] then
            if data.Box then data.Box:Destroy() end
            if data.Highlight then data.Highlight:Destroy() end
            ESPObjects[model] = nil
            HealthMemory[model] = nil
        end
    end
end

local function SpawnBulletTracer(startPos, endPos)
    if not Config.BulletTracers then return end
    local dist = (endPos - startPos).Magnitude
    if dist < 1 then return end

    local beamPart = Instance.new("Part")
    beamPart.Name = "ShitaroTracer"
    beamPart.Anchored = true
    beamPart.CanCollide = false
    beamPart.CanQuery = false
    beamPart.CanTouch = false
    beamPart.Material = Enum.Material.Neon
    beamPart.Color = Config.TracerColor
    beamPart.Transparency = 0.1
    beamPart.Size = Vector3.new(0.065, 0.065, dist)
    beamPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
    beamPart.Parent = EffectsFolder

    local tw = TweenService:Create(beamPart, TweenInfo.new(Config.TracerDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
        Size = Vector3.new(0.01, 0.01, dist)
    })
    tw:Play()
    tw.Completed:Connect(function()
        if beamPart then beamPart:Destroy() end
    end)
end

-- ============================================================================
-- 10. КАМЕРА + AA (БЕЗ CFrame-форса камеры и БЕЗ телепорта позиции)
-- ============================================================================
local SelfHighlight = Instance.new("Highlight")
SelfHighlight.Name = "ShitaroSelfHL"
SelfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
SelfHighlight.FillColor = Config.SelfChamsColor
SelfHighlight.OutlineColor = Config.SelfChamsOutline
SelfHighlight.FillTransparency = 0.3
SelfHighlight.OutlineTransparency = 0.05
SelfHighlight.Parent = ChamsContainer

local spinYaw = 0
local jitterSide = false

RunService:BindToRenderStep("ShitaroCameraAndAA", Enum.RenderPriority.Camera.Value + 50, function()
    local myChar = GetLocalCharacter()
    StatusLabel.Text = string.format(
        "🎥 %s  |  ⇄ manual: %s",
        Config.ThirdPerson and "3rd camera" or "1st camera",
        Config.ActiveManual
    )

    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")

    -- Anti-Aim: только вращение yaw, позиция НЕ меняется (устранён краш)
    if Config.AAEnable and myRoot and myHum then
        myHum.AutoRotate = false
        local camLook = Camera.CFrame.LookVector
        local baseYaw = math.deg(math.atan2(-camLook.X, -camLook.Z))

        if Config.EnableManuals and Config.ActiveManual ~= "none" then
            if Config.ActiveManual == "left" then baseYaw = baseYaw + 90
            elseif Config.ActiveManual == "right" then baseYaw = baseYaw - 90
            elseif Config.ActiveManual == "back" then baseYaw = baseYaw + 180 end
        elseif Config.Spin or Config.Yaw == "spin" then
            spinYaw = (spinYaw + Config.SpinSpeed) % 360
            baseYaw = spinYaw
        elseif Config.Yaw == "backward" then
            baseYaw = baseYaw + 180 + Config.YawOffset
        elseif Config.Yaw == "static" then
            baseYaw = Config.YawOffset
        end

        if Config.YawModifier == "jitter" then
            jitterSide = not jitterSide
            baseYaw = baseYaw + (jitterSide and Config.ModifierOffset or -Config.ModifierOffset)
        elseif Config.YawModifier == "offset" then
            baseYaw = baseYaw + Config.ModifierOffset
        elseif Config.YawModifier == "random" then
            baseYaw = baseYaw + math.random(-Config.ModifierOffset, Config.ModifierOffset)
        end

        local curPos = myRoot.CFrame.Position
        myRoot.CFrame = CFrame.new(curPos) * CFrame.Angles(0, math.rad(baseYaw), 0)
    elseif myHum then
        myHum.AutoRotate = true
    end

    -- 3-е лицо: ТОЛЬКО через CameraMinZoomDistance/Max — никакого Camera.CFrame
    if Config.ThirdPerson and myRoot then
        pcall(function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = Config.ThirdPersonDist
            LocalPlayer.CameraMaxZoomDistance = Config.ThirdPersonDist
        end)

        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = 0
            end
        end

        if Config.SelfChams then
            SelfHighlight.Adornee = myChar
            SelfHighlight.Enabled = true
        else
            SelfHighlight.Enabled = false
        end
    else
        SelfHighlight.Enabled = false
    end
end)

-- ============================================================================
-- 11. RAGE / SILENT AIM / TRIGGER
-- ============================================================================
local BestTarget = nil
local LastFireTick = 0

local function CanHitTarget(origin, targetPart, targetModel)
    if Config.AutoWall or Config.TriggerThroughWalls then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {GetLocalCharacter(), Camera, EffectsFolder}
    local res = Workspace:Raycast(origin, (targetPart.Position - origin), params)
    if not res or res.Instance:IsDescendantOf(targetModel) then return true end
    return false
end

local function TriggerShoot(targetEntity)
    if not targetEntity or not targetEntity.Head then return end
    local delaySec = math.max(0.03, Config.TriggerDelay / 1000)
    if tick() - LastFireTick < delaySec then return end
    LastFireTick = tick()

    local myChar = GetLocalCharacter()
    local myHead = myChar and myChar:FindFirstChild("Head")
    local aimPart = (Config.Override == "force body" and targetEntity.Root) or targetEntity.Head

    -- Никакого Camera.CFrame — только click
    if mouse1click then
        mouse1click()
    elseif VirtualInputManager then
        local vp = Camera.ViewportSize
        VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
        task.defer(function()
            VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
        end)
    end

    if myHead and aimPart then
        SpawnBulletTracer(myHead.Position, aimPart.Position)
    end
end

-- ХУК __namecall УДАЛЁН ПОЛНОСТЬЮ (был главный краш-фактор)

RunService.RenderStepped:Connect(function()
    local enemies = ScanAllEnemies()
    local activeMap = {}
    local myChar = GetLocalCharacter()
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))

    if Config.BunnyHop and myHum and myRoot and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if myHum.FloorMaterial ~= Enum.Material.Air then
            myHum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        local moveDir = myHum.MoveDirection
        if moveDir.Magnitude > 0 then
            myRoot.Velocity = Vector3.new(moveDir.X * Config.BhopSpeed, myRoot.Velocity.Y, moveDir.Z * Config.BhopSpeed)
        end
    end

    if Config.NoFlash then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, g in ipairs(pg:GetDescendants()) do
                if g.Name:lower():find("flash") or g.Name:lower():find("blind") then
                    if g:IsA("GuiObject") then g.Visible = false end
                end
            end
        end
    end

    local closestDist = math.huge
    BestTarget = nil
    local vpCenter = Camera.ViewportSize / 2

    for _, ent in ipairs(enemies) do
        activeMap[ent.Model] = true
        local esp = GetOrCreateESP(ent.Model)

        local prevHP = HealthMemory[ent.Model] or ent.Health
        if ent.Health < prevHP then
            local dmg = math.max(1, math.floor(prevHP - ent.Health))
            local left = math.max(0, math.floor(ent.Health))
            local weap = GetWeaponName(myChar)
            local jumping = (myHum and myHum.FloorMaterial == Enum.Material.Air)
            local flags = "headshot, no-scope" .. (Config.AutoWall and ", wallbang" or "") .. (jumping and ", jump" or "")

            if left <= 0 then
                PushHitlog(string.format(
                    "killed <font color='rgb(165,132,245)'>%s</font> with <font color='rgb(165,132,245)'>%s</font> (%s)",
                    ent.Name, weap, flags
                ), 5)
            else
                PushHitlog(string.format(
                    "hit <font color='rgb(165,132,245)'>%s</font> in the <font color='rgb(165,132,245)'>head</font> for <font color='rgb(165,132,245)'>%d</font> damage (<font color='rgb(165,132,245)'>%d</font> health left)",
                    ent.Name, dmg, left
                ), 4.5)
            end
        end
        HealthMemory[ent.Model] = ent.Health

        if ent.Head then
            if Config.HitboxExpander then
                ent.Head.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                ent.Head.Transparency = 0.65
                ent.Head.CanCollide = false
                ent.Head.Massless = true
            else
                ent.Head.Size = Vector3.new(1.2, 1.2, 1.2)
                ent.Head.Transparency = 0
            end
        end

        local chamsActive = Config.ESPEnable and Config.EnemyChams
        if esp.Highlight then
            esp.Highlight.Enabled = chamsActive
        end

        local pos3D = ent.Root.Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos3D)

        if Config.ESPEnable and onScreen and screenPos.Z > 0 then
            local topW = Camera:WorldToViewportPoint(pos3D + Vector3.new(0, 3.1, 0))
            local botW = Camera:WorldToViewportPoint(pos3D - Vector3.new(0, 3.5, 0))
            local boxH = math.clamp(math.abs(botW.Y - topW.Y), 16, 600)
            local boxW = boxH * 0.62

            esp.Box.Size = UDim2.new(0, boxW, 0, boxH)
            esp.Box.Position = UDim2.new(0, screenPos.X - boxW / 2, 0, screenPos.Y - boxH / 2)
            esp.Box.Visible = Config.BoxESP

            esp.Name.Visible = Config.NameESP
            esp.Name.Text = ent.Name

            esp.Weap.Visible = Config.WeaponESP
            esp.Weap.Text = GetWeaponName(ent.Model)

            local hpRatio = math.clamp(ent.Health / math.max(1, ent.MaxHealth), 0, 1)
            esp.HPBg.Visible = Config.HealthBar
            esp.HPFill.Size = UDim2.new(1, 0, hpRatio, 0)
            esp.HPLabel.Visible = Config.HealthText
            esp.HPLabel.Text = tostring(math.floor(ent.Health)) .. "HP"

            local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - vpCenter).Magnitude
            if dist2D < closestDist and CanHitTarget(Camera.CFrame.Position, ent.Head, ent.Model) then
                closestDist = dist2D
                BestTarget = ent
            end
        else
            esp.Box.Visible = false
        end
    end

    CleanupStaleESP(activeMap)

    if (Config.RageEnable and Config.AutoShoot) or Config.TriggerEnable then
        local unitRay = Camera:ViewportPointToRay(vpCenter.X, vpCenter.Y)
        local rParams = RaycastParams.new()
        rParams.IgnoreWater = true

        if Config.AutoWall or Config.TriggerThroughWalls then
            local targetModels = {}
            for _, ent in ipairs(enemies) do
                table.insert(targetModels, ent.Model)
            end
            rParams.FilterType = Enum.RaycastFilterType.Include
            rParams.FilterDescendantsInstances = targetModels
        else
            rParams.FilterType = Enum.RaycastFilterType.Exclude
            rParams.FilterDescendantsInstances = {myChar, Camera, EffectsFolder}
        end

        local rayHit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1500, rParams)
        if rayHit and rayHit.Instance then
            for _, ent in ipairs(enemies) do
                if rayHit.Instance:IsDescendantOf(ent.Model) then
                    if math.random(1, 100) <= Config.Hitchance then
                        TriggerShoot(ent)
                    end
                    break
                end
            end
        elseif Config.RageEnable and Config.AutoShoot and Config.SilentAim and BestTarget then
            if math.random(1, 100) <= Config.Hitchance then
                TriggerShoot(BestTarget)
            end
        end
    end
end)

PushHitlog("initialized <font color='rgb(165,132,245)'>shitaro.crack v2.0-fixed</font> | crash-safe build", 5)
