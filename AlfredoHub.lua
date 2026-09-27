-- ════════════════════════════════════════════════════════════════════════
-- ALFREDO HUB 🦫 | Steal an Egg
-- Минималистичный UI | Бобровый стиль | Fix: Pathfinding (без телепорта)
-- ════════════════════════════════════════════════════════════════════════

if _G.AlfredoHubLoaded and _G.AlfredoHubDestroy then
    pcall(_G.AlfredoHubDestroy)
end
_G.AlfredoHubLoaded = true

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════
-- КОНФИГ
-- ════════════════════════════════════════════════════════════════════════
local CFG = {
    LOGO_ID       = "rbxassetid://107301914145735",
    BEAVER_ID     = "rbxassetid://86571455908132",
    
    -- Цвета (коричневый бобровый)
    ACCENT        = Color3.fromHex("#8B5A2B"),
    ACCENT_LIGHT  = Color3.fromHex("#A0522D"),
    BG_WINDOW     = Color3.fromHex("#0D0D0D"),
    BG_ELEMENT    = Color3.fromHex("#1A1A1A"),
    BG_HOVER      = Color3.fromHex("#252525"),
    BORDER        = Color3.fromHex("#2A2A2A"),
    TEXT_WHITE    = Color3.fromHex("#FFFFFF"),
    TEXT_GRAY     = Color3.fromHex("#909090"),
    TEXT_DIM      = Color3.fromHex("#606060"),
    
    -- Шрифт
    FONT          = Enum.Font.GothamMedium,
    FONT_BOLD     = Enum.Font.GothamBold,
    TEXT_SIZE     = 12,
    TEXT_SIZE_SM  = 10,
    
    -- Размеры (меньше)
    WINDOW_W      = 240,
    WINDOW_H      = 320,
    ICON_SIZE     = 42,
    
    -- Кража
    GLIDE_SPEED   = 750,
    STEAL_DELAY   = 1.5,
    
    -- Фильтры
    FILTER_COSMIC  = false,
    FILTER_SECRET  = false,
    FILTER_ETERNAL = false,
    FILTER_DIVINE  = false,
    
    -- Состояние
    RUNNING       = true,
    STEALING      = false,
    BUSY          = false,
}

-- ════════════════════════════════════════════════════════════════════════
-- УТИЛИТЫ
-- ════════════════════════════════════════════════════════════════════════
local function char() return LP.Character end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function hrp()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function shortMoney(n)
    n = tonumber(n) or 0
    if n >= 1e12 then return string.format("$%.2fT", n / 1e12) end
    if n >= 1e9 then return string.format("$%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("$%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("$%.2fK", n / 1e3) end
    return "$" .. tostring(math.floor(n))
end

-- ════════════════════════════════════════════════════════════════════════
-- СОЗДАНИЕ UI
-- ════════════════════════════════════════════════════════════════════════
local function getParent()
    local p
    if typeof(gethui) == "function" then p = gethui() end
    if p then return p end
    pcall(function() p = game:GetService("CoreGui") end)
    if p then return p end
    return LP:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlfredoHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 100
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
pcall(function() if hidename then hidename(ScreenGui) end end)
ScreenGui.Parent = getParent()

-- ════════════════════════════════════════════════════════════════════════
-- ИКОНКА БОБРА (кнопка открытия/закрытия) — ФИКС: различаем клик и drag
-- ════════════════════════════════════════════════════════════════════════
local BeaverButton = Instance.new("ImageButton")
BeaverButton.Name = "BeaverButton"
BeaverButton.Size = UDim2.fromOffset(CFG.ICON_SIZE, CFG.ICON_SIZE)
BeaverButton.Position = UDim2.new(0, 18, 0.5, -21)
BeaverButton.BackgroundColor3 = CFG.BG_ELEMENT
BeaverButton.BorderSizePixel = 0
BeaverButton.Image = CFG.BEAVER_ID
BeaverButton.ScaleType = Enum.ScaleType.Crop
BeaverButton.AutoButtonColor = false
BeaverButton.ZIndex = 20
BeaverButton.Parent = ScreenGui

local bbCorner = Instance.new("UICorner")
bbCorner.CornerRadius = UDim.new(0, 21)
bbCorner.Parent = BeaverButton

local bbStroke = Instance.new("UIStroke")
bbStroke.Color = CFG.ACCENT
bbStroke.Thickness = 1.5
bbStroke.Transparency = 0.15
bbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bbStroke.Parent = BeaverButton

-- Drag + клик
local btnDownPos = nil
local btnMoved = false

BeaverButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        btnDownPos = input.Position
        btnMoved = false
    end
end)

BeaverButton.InputChanged:Connect(function(input)
    if btnDownPos and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDownPos
        if delta.Magnitude > 8 then
            btnMoved = true
            BeaverButton.Position = UDim2.new(
                BeaverButton.Position.X.Scale,
                BeaverButton.Position.X.Offset + delta.X,
                BeaverButton.Position.Y.Scale,
                BeaverButton.Position.Y.Offset + delta.Y
            )
            btnDownPos = input.Position
        end
    end
end)

BeaverButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        if btnDownPos and not btnMoved then
            -- Клик → открыть/закрыть окно
            if MainFrame then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
        btnDownPos = nil
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- ГЛАВНОЕ ОКНО (компактнее: 240x320)
-- ════════════════════════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(CFG.WINDOW_W, CFG.WINDOW_H)
MainFrame.Position = UDim2.new(0, 70, 0.5, -CFG.WINDOW_H / 2)
MainFrame.BackgroundColor3 = CFG.BG_WINDOW
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 12)
mfCorner.Parent = MainFrame

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = CFG.ACCENT
mfStroke.Thickness = 1.5
mfStroke.Transparency = 0.3
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Parent = MainFrame

-- Drag окна
local draggingWin = false
local winDragStart, winStartPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingWin = true
        winDragStart = input.Position
        winStartPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWin and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - winDragStart
        MainFrame.Position = UDim2.new(
            winStartPos.X.Scale, winStartPos.X.Offset + delta.X,
            winStartPos.Y.Scale, winStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingWin = false
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- ЗАГОЛОВОК С ЛОГОТИПОМ "ALFREDOHUB"
-- ════════════════════════════════════════════════════════════════════════
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -16, 0, 44)
Header.Position = UDim2.fromOffset(8, 8)
Header.BackgroundTransparency = 1
Header.ZIndex = 11
Header.Parent = MainFrame

local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "Logo"
LogoImage.Size = UDim2.fromScale(1, 1)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = CFG.LOGO_ID
LogoImage.ScaleType = Enum.ScaleType.Fit
LogoImage.ZIndex = 12
LogoImage.Parent = Header

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -16, 0, 1)
Divider.Position = UDim2.fromOffset(8, 56)
Divider.BackgroundColor3 = CFG.BORDER
Divider.BorderSizePixel = 0
Divider.ZIndex = 11
Divider.Parent = MainFrame

print("[AlfredoHub] Часть 1 загружена")
-- ════════════════════════════════════════════════════════════════════════
-- BEST EGG (Top 4) — кликабельные ячейки
-- ════════════════════════════════════════════════════════════════════════
local BestEggSection = Instance.new("Frame")
BestEggSection.Name = "BestEggSection"
BestEggSection.Size = UDim2.new(1, -16, 0, 156)
BestEggSection.Position = UDim2.fromOffset(8, 62)
BestEggSection.BackgroundColor3 = CFG.BG_ELEMENT
BestEggSection.BackgroundTransparency = 0.2
BestEggSection.BorderSizePixel = 0
BestEggSection.ZIndex = 11
BestEggSection.Parent = MainFrame

local besCorner = Instance.new("UICorner")
besCorner.CornerRadius = UDim.new(0, 8)
besCorner.Parent = BestEggSection

local besStroke = Instance.new("UIStroke")
besStroke.Color = CFG.BORDER
besStroke.Thickness = 1
besStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
besStroke.Parent = BestEggSection

local BestEggTitle = Instance.new("TextLabel")
BestEggTitle.Size = UDim2.new(1, -16, 0, 16)
BestEggTitle.Position = UDim2.fromOffset(8, 6)
BestEggTitle.BackgroundTransparency = 1
BestEggTitle.Text = "BEST EGG (кликни для выбора)"
BestEggTitle.Font = CFG.FONT_BOLD
BestEggTitle.TextSize = CFG.TEXT_SIZE_SM
BestEggTitle.TextColor3 = CFG.ACCENT
BestEggTitle.TextXAlignment = Enum.TextXAlignment.Left
BestEggTitle.ZIndex = 12
BestEggTitle.Parent = BestEggSection

local EggSlots = {}
for i = 1, 4 do
    local slot = Instance.new("Frame")
    slot.Name = "EggSlot" .. i
    slot.Size = UDim2.new(1, -16, 0, 30)
    slot.Position = UDim2.fromOffset(8, 26 + (i - 1) * 32)
    slot.BackgroundColor3 = CFG.BG_WINDOW
    slot.BackgroundTransparency = 0.3
    slot.BorderSizePixel = 0
    slot.ZIndex = 12
    slot.Parent = BestEggSection

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = slot

    -- Номер
    local numLabel = Instance.new("TextLabel")
    numLabel.Size = UDim2.fromOffset(20, 30)
    numLabel.Position = UDim2.fromOffset(2, 0)
    numLabel.BackgroundTransparency = 1
    numLabel.Text = "#" .. i
    numLabel.Font = CFG.FONT_BOLD
    numLabel.TextSize = CFG.TEXT_SIZE_SM
    numLabel.TextColor3 = CFG.TEXT_DIM
    numLabel.ZIndex = 13
    numLabel.Parent = slot

    -- Название
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -110, 0, 14)
    nameLabel.Position = UDim2.fromOffset(26, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "—"
    nameLabel.Font = CFG.FONT_BOLD
    nameLabel.TextSize = CFG.TEXT_SIZE
    nameLabel.TextColor3 = CFG.TEXT_WHITE
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.ZIndex = 13
    nameLabel.Parent = slot

    -- Редкость
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "Rarity"
    rarityLabel.Size = UDim2.new(1, -110, 0, 12)
    rarityLabel.Position = UDim2.fromOffset(26, 17)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "—"
    rarityLabel.Font = CFG.FONT
    rarityLabel.TextSize = CFG.TEXT_SIZE_SM
    rarityLabel.TextColor3 = CFG.TEXT_GRAY
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.TextTruncate = Enum.TextTruncate.AtEnd
    rarityLabel.ZIndex = 13
    rarityLabel.Parent = slot

    -- Цена
    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Name = "Money"
    moneyLabel.Size = UDim2.fromOffset(80, 30)
    moneyLabel.Position = UDim2.new(1, -84, 0, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "—"
    moneyLabel.Font = CFG.FONT_BOLD
    moneyLabel.TextSize = CFG.TEXT_SIZE
    moneyLabel.TextColor3 = CFG.ACCENT
    moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
    moneyLabel.ZIndex = 13
    moneyLabel.Parent = slot

    -- Кнопка-клик поверх ячейки
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.fromScale(1, 1)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 15
    clickBtn.Parent = slot

    EggSlots[i] = {
        frame = slot,
        name = nameLabel,
        rarity = rarityLabel,
        money = moneyLabel,
        click = clickBtn,
        egg = nil,
    }
end

-- ════════════════════════════════════════════════════════════════════════
-- RARITY FILTER (4 галочки)
-- ════════════════════════════════════════════════════════════════════════
local FilterSection = Instance.new("Frame")
FilterSection.Name = "FilterSection"
FilterSection.Size = UDim2.new(1, -16, 0, 56)
FilterSection.Position = UDim2.fromOffset(8, 222)
FilterSection.BackgroundTransparency = 1
FilterSection.ZIndex = 11
FilterSection.Parent = MainFrame

local FilterTitle = Instance.new("TextLabel")
FilterTitle.Size = UDim2.new(1, 0, 0, 14)
FilterTitle.Position = UDim2.fromOffset(0, 0)
FilterTitle.BackgroundTransparency = 1
FilterTitle.Text = "RARITY FILTER"
FilterTitle.Font = CFG.FONT_BOLD
FilterTitle.TextSize = CFG.TEXT_SIZE_SM
FilterTitle.TextColor3 = CFG.ACCENT
FilterTitle.TextXAlignment = Enum.TextXAlignment.Left
FilterTitle.ZIndex = 12
FilterTitle.Parent = FilterSection

local RarityOptions = {
    {key = "FILTER_COSMIC",  name = "Cosmic",  color = Color3.fromHex("#06B6D4")},
    {key = "FILTER_SECRET",  name = "Secret",  color = Color3.fromHex("#F97316")},
    {key = "FILTER_ETERNAL", name = "Eternal", color = Color3.fromHex("#D946EF")},
    {key = "FILTER_DIVINE",  name = "Divine",  color = Color3.fromHex("#F43F5E")},
}

for i, opt in ipairs(RarityOptions) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    
    local cb = Instance.new("TextButton")
    cb.Name = "CB_" .. opt.name
    cb.Size = UDim2.new(0.5, -2, 0, 18)
    cb.Position = UDim2.new(col * 0.5, col == 0 and 0 or 2, 0, 18 + row * 20)
    cb.BackgroundColor3 = CFG.BG_ELEMENT
    cb.BackgroundTransparency = 0.2
    cb.BorderSizePixel = 0
    cb.Text = ""
    cb.AutoButtonColor = false
    cb.ZIndex = 12
    cb.Parent = FilterSection

    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(0, 5)
    cbc.Parent = cb

    local cbs = Instance.new("UIStroke")
    cbs.Color = opt.color
    cbs.Thickness = 1
    cbs.Transparency = 0.5
    cbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cbs.Parent = cb

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(10, 10)
    box.Position = UDim2.fromOffset(4, 4)
    box.BackgroundColor3 = opt.color
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 0
    box.ZIndex = 13
    box.Parent = cb

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 2)
    bc.Parent = box

    local check = Instance.new("TextLabel")
    check.Size = UDim2.fromScale(1, 1)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.Font = CFG.FONT_BOLD
    check.TextSize = 9
    check.TextColor3 = CFG.BG_WINDOW
    check.Visible = false
    check.ZIndex = 14
    check.Parent = box

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -20, 1, 0)
    nameL.Position = UDim2.fromOffset(18, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = opt.name
    nameL.Font = CFG.FONT_BOLD
    nameL.TextSize = CFG.TEXT_SIZE_SM
    nameL.TextColor3 = opt.color
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.ZIndex = 13
    nameL.Parent = cb

    cb.MouseButton1Click:Connect(function()
        CFG[opt.key] = not CFG[opt.key]
        check.Visible = CFG[opt.key]
        box.BackgroundTransparency = CFG[opt.key] and 0.2 or 0.7
        cbs.Transparency = CFG[opt.key] and 0.2 or 0.5
    end)
end

print("[AlfredoHub] Часть 2 загружена")
-- ════════════════════════════════════════════════════════════════════════
-- GO / STOP
-- ════════════════════════════════════════════════════════════════════════
local ButtonsSection = Instance.new("Frame")
ButtonsSection.Size = UDim2.new(1, -16, 0, 30)
ButtonsSection.Position = UDim2.fromOffset(8, 282)
ButtonsSection.BackgroundTransparency = 1
ButtonsSection.ZIndex = 11
ButtonsSection.Parent = MainFrame

local GoButton = Instance.new("TextButton")
GoButton.Size = UDim2.new(0.5, -2, 1, 0)
GoButton.Position = UDim2.fromOffset(0, 0)
GoButton.BackgroundColor3 = CFG.ACCENT
GoButton.BorderSizePixel = 0
GoButton.Text = "▶ GO"
GoButton.Font = CFG.FONT_BOLD
GoButton.TextSize = CFG.TEXT_SIZE
GoButton.TextColor3 = CFG.TEXT_WHITE
GoButton.AutoButtonColor = false
GoButton.ZIndex = 12
GoButton.Parent = ButtonsSection

local gbc = Instance.new("UICorner")
gbc.CornerRadius = UDim.new(0, 6)
gbc.Parent = GoButton

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.5, -2, 1, 0)
StopButton.Position = UDim2.new(0.5, 2, 0, 0)
StopButton.BackgroundColor3 = CFG.BG_ELEMENT
StopButton.BorderSizePixel = 0
StopButton.Text = "■ STOP"
StopButton.Font = CFG.FONT_BOLD
StopButton.TextSize = CFG.TEXT_SIZE
StopButton.TextColor3 = CFG.TEXT_WHITE
StopButton.AutoButtonColor = false
StopButton.ZIndex = 12
StopButton.Parent = ButtonsSection

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 6)
sbc.Parent = StopButton

local sbs = Instance.new("UIStroke")
sbs.Color = CFG.BORDER
sbs.Thickness = 1
sbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sbs.Parent = StopButton

GoButton.MouseEnter:Connect(function()
    TweenService:Create(GoButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.ACCENT_LIGHT}):Play()
end)
GoButton.MouseLeave:Connect(function()
    TweenService:Create(GoButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.ACCENT}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════
-- STATUS
-- ════════════════════════════════════════════════════════════════════════
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -16, 0, 18)
StatusFrame.Position = UDim2.new(0, 8, 1, -24)
StatusFrame.BackgroundTransparency = 1
StatusFrame.ZIndex = 11
StatusFrame.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(6, 6)
StatusDot.Position = UDim2.new(0, 3, 0.5, -3)
StatusDot.BackgroundColor3 = CFG.TEXT_DIM
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 12
StatusDot.Parent = StatusFrame

local sdc = Instance.new("UICorner")
sdc.CornerRadius = UDim.new(1, 0)
sdc.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -14, 1, 0)
StatusText.Position = UDim2.fromOffset(14, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Ready"
StatusText.Font = CFG.FONT
StatusText.TextSize = CFG.TEXT_SIZE_SM
StatusText.TextColor3 = CFG.TEXT_GRAY
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.ZIndex = 12
StatusText.Parent = StatusFrame

local function setStatus(text, color)
    StatusText.Text = tostring(text)
    if color then
        StatusDot.BackgroundColor3 = color
    end
end

print("[AlfredoHub] Часть 3 загружена")
-- ════════════════════════════════════════════════════════════════════════
-- ЯДРО КРАЖИ
-- ════════════════════════════════════════════════════════════════════════
local Net = ReplicatedStorage:FindFirstChild("Packages")
    and ReplicatedStorage.Packages:FindFirstChild("Networking")

local Remotes = {
    Carry = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggCarry"),
    Snapshot = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot"),
    Strike = Net and Net:FindFirstChild("RE/GuardPatrol/ForestStrike"),
}

local AreaEggCycle
pcall(function()
    AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
end)

local AssetsData
pcall(function()
    AssetsData = require(ReplicatedStorage.Data.Assets)
end)

local PlotState
pcall(function()
    PlotState = require(ReplicatedStorage.Client.PlotState)
end)

-- День/ночь
local function isDay()
    if AreaEggCycle and AreaEggCycle.IsNightPhase then
        local ok, res = pcall(function()
            return AreaEggCycle.IsNightPhase(workspace:GetServerTimeNow())
        end)
        if ok then return res ~= true end
    end
    local ct = Lighting.ClockTime
    return ct >= 6 and ct < 18
end

-- Редкость
local function getRarity(record)
    local cat = record.AssetCategory or record.Category
    if cat and AssetsData then
        local dir = AssetsData.Directory or AssetsData
        local info = dir[cat]
        if info and info.Rarity then
            local r = info.Rarity
            return type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
        end
    end
    return "Common"
end

local function passesFilter(record)
    local name = tostring(getRarity(record)):lower()
    local anyFilter = CFG.FILTER_COSMIC or CFG.FILTER_SECRET 
        or CFG.FILTER_ETERNAL or CFG.FILTER_DIVINE
    if not anyFilter then return true end
    if CFG.FILTER_COSMIC and name:find("cosmic") then return true end
    if CFG.FILTER_SECRET and name:find("secret") then return true end
    if CFG.FILTER_ETERNAL and name:find("eternal") then return true end
    if CFG.FILTER_DIVINE and name:find("divine") then return true end
    return false
end

-- Поиск яиц
local function getEggs()
    if not Remotes.Snapshot then return {} end
    
    local ok, snapshot = pcall(function()
        return Remotes.Snapshot:InvokeServer()
    end)
    if not ok or type(snapshot) ~= "table" or not snapshot.Records then
        return {}
    end
    
    local eggs = {}
    for _, rec in ipairs(snapshot.Records) do
        if rec.State == "Slot" and rec.BoundsCFrame then
            if passesFilter(rec) then
                local cat = rec.AssetCategory or "Egg"
                local money = 0
                if AssetsData then
                    local dir = AssetsData.Directory or AssetsData
                    local info = dir[cat]
                    money = info and (info.Income or info.EarningRate or info.Money or 0) or 0
                    money = money * (rec.AssetScale or 1)
                end
                
                table.insert(eggs, {
                    Uid = rec.Uid,
                    Category = cat,
                    Rarity = getRarity(rec),
                    Money = money,
                    CFrame = rec.BoundsCFrame,
                    Position = rec.BoundsCFrame.Position,
                    Record = rec,
                })
            end
        end
    end
    
    table.sort(eggs, function(a, b)
        return (a.Money or 0) > (b.Money or 0)
    end)
    
    return eggs
end

-- Промпты
local function triggerPromptsNear(targetPos)
    if not targetPos then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "CarryAreaEgg" then
            local p = obj.Parent
            if p:IsA("Attachment") then p = p.Parent end
            if p and p:IsA("BasePart") and (p.Position - targetPos).Magnitude < 18 then
                pcall(function()
                    obj.RequiresLineOfSight = false
                    obj.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(obj, 0)
                        fireproximityprompt(obj)
                    end
                end)
            end
        end
    end
end

-- Проверка яйца
local function isCarrying()
    local c = char()
    if not c then return false end
    for _, obj in ipairs(c:GetChildren()) do
        if obj:IsA("Tool") then
            local n = obj.Name:lower()
            if n:find("egg") or obj:GetAttribute("Uid") then return true end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then
                local n = obj.Name:lower()
                if n:find("egg") or obj:GetAttribute("Uid") then return true end
            end
        end
    end
    return false
end

-- ПЕШКОМ через Pathfinding (БЕЗ ТЕЛЕПОРТА)
local function walkToTarget(targetPos, timeout)
    timeout = timeout or 30
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return false end
    
    local dist = (root.Position - targetPos).Magnitude
    if dist <= 8 then
        humanoid:MoveTo(targetPos)
        local t0 = tick()
        while (root.Position - targetPos).Magnitude > 4 and tick() - t0 < 5 do
            if not CFG.STEALING then return false end
            humanoid:MoveTo(targetPos)
            RunService.Heartbeat:Wait()
        end
        return true
    end
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 6,
        AgentCanJump = true,
        AgentCanClimb = false,
        WaypointSpacing = 6,
    })
    
    local ok = pcall(function()
        path:ComputeAsync(root.Position, targetPos)
    end)
    
    if not ok or path.Status ~= Enum.PathStatus.Success then
        humanoid:MoveTo(targetPos)
        return true
    end
    
    local waypoints = path:GetWaypoints()
    local t0 = tick()
    
    for i = 2, #waypoints do
        if not CFG.STEALING or tick() - t0 > timeout then return false end
        
        local wp = waypoints[i]
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        humanoid:MoveTo(wp.Position)
        
        local reached = false
        local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
        local tWait = tick()
        while not reached and tick() - tWait < 5 do
            if not CFG.STEALING then
                conn:Disconnect()
                return false
            end
            task.wait(0.1)
        end
        conn:Disconnect()
    end
    
    humanoid:MoveTo(targetPos)
    local tFinal = tick()
    while (root.Position - targetPos).Magnitude > 4 and tick() - tFinal < 5 do
        if not CFG.STEALING then return false end
        humanoid:MoveTo(targetPos)
        RunService.Heartbeat:Wait()
    end
    
    return true
end

-- GUARD STRIKE (без телепорта)
local function guardStrike(egg)
    if not egg or not egg.Uid or not egg.Position then return false end
    
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return false end
    
    local targetPos = egg.Position + Vector3.new(0, 2, 0)
    
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid.PlatformStand = false
    
    CFG.BUSY = true
    
    -- 1: идём
    setStatus("Walking to egg...", CFG.ACCENT)
    local walked = walkToTarget(targetPos, 30)
    if not walked or not CFG.STEALING then
        CFG.BUSY = false
        return false
    end
    
    -- 2: подъём
    setStatus("Lifting egg...", CFG.ACCENT)
    local t0 = tick()
    while not isCarrying() and tick() - t0 < 4 do
        if not CFG.STEALING then CFG.BUSY = false return false end
        triggerPromptsNear(targetPos)
        if Remotes.Carry then
            pcall(function() Remotes.Carry:InvokeServer({Uid = egg.Uid}) end)
        end
        humanoid:MoveTo(targetPos)
        RunService.Heartbeat:Wait()
    end
    
    if not isCarrying() then
        setStatus("Failed to lift", CFG.TEXT_DIM)
        CFG.BUSY = false
        return false
    end
    
    -- 3: ждём удар
    setStatus("Waiting guard...", CFG.ACCENT)
    t0 = tick()
    local struck = false
    while isCarrying() and tick() - t0 < 4.5 do
        if not CFG.STEALING then break end
        if Remotes.Strike and not struck then
            task.spawn(function()
                pcall(function()
                    if Remotes.Strike:IsA("RemoteFunction") then
                        Remotes.Strike:InvokeServer()
                    else
                        Remotes.Strike:FireServer()
                    end
                end)
            end)
            struck = true
        end
        RunService.Heartbeat:Wait()
    end
    
    -- 4: реграб
    setStatus("Re-grabbing...", CFG.ACCENT)
    t0 = tick()
    while not isCarrying() and tick() - t0 < 3 do
        if not CFG.STEALING then break end
        triggerPromptsNear(targetPos)
        if Remotes.Carry then
            pcall(function() Remotes.Carry:InvokeServer({Uid = egg.Uid}) end)
        end
        RunService.Heartbeat:Wait()
    end
    
    local success = isCarrying()
    setStatus(success and "Egg secured!" or "Failed", 
        success and CFG.ACCENT or CFG.TEXT_DIM)
    CFG.BUSY = false
    return success
end

-- Возврат на базу (пешком)
local function returnToBase()
    local root = hrp()
    if not root then return false end
    
    setStatus("Returning to base...", CFG.ACCENT)
    
    local basePos = Vector3.new(464.7, 70.4, -364.0)
    if PlotState and PlotState.ResolvePlot then
        local ok, plot = pcall(function() return PlotState.ResolvePlot() end)
        if ok and plot and plot.CenterPoint then
            basePos = plot.CenterPoint.Position or plot.CenterPoint
        end
    end
    
    local humanoid = hum()
    if not humanoid then return false end
    
    local t0 = tick()
    while (root.Position - basePos).Magnitude > 6 and tick() - t0 < 20 do
        if not CFG.STEALING then break end
        humanoid:MoveTo(basePos)
        RunService.Heartbeat:Wait()
    end
    return true
end

print("[AlfredoHub] Часть 4 загружена")
-- ════════════════════════════════════════════════════════════════════════
-- ВЫБОР ЯЙЦА
-- ════════════════════════════════════════════════════════════════════════
local SelectedEgg = nil

for i = 1, 4 do
    local slot = EggSlots[i]
    slot.click.MouseButton1Click:Connect(function()
        if slot.egg then
            SelectedEgg = slot.egg
            setStatus("Selected: " .. slot.egg.Category, CFG.ACCENT)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════
-- STEAL ONE
-- ════════════════════════════════════════════════════════════════════════
local function StealBestEggOnce()
    if CFG.BUSY then return false end
    if not isDay() then
        setStatus("Waiting for day...", CFG.TEXT_DIM)
        return false
    end
    
    local target = nil
    if SelectedEgg then
        local eggs = getEggs()
        for _, e in ipairs(eggs) do
            if e.Uid == SelectedEgg.Uid then
                target = e
                break
            end
        end
        if not target then SelectedEgg = nil end
    end
    
    if not target then
        local eggs = getEggs()
        if #eggs == 0 then
            setStatus("No matching eggs", CFG.TEXT_DIM)
            return false
        end
        target = eggs[1]
    end
    
    setStatus("Stealing " .. target.Category .. "...", CFG.ACCENT)
    local success = guardStrike(target)
    
    if success then
        returnToBase()
        setStatus("Secured! " .. target.Category, CFG.ACCENT)
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════
-- ОБНОВЛЕНИЕ BEST EGG
-- ════════════════════════════════════════════════════════════════════════
local function UpdateBestEgg()
    local eggs = getEggs()
    
    for i = 1, 4 do
        local slot = EggSlots[i]
        local egg = eggs[i]
        slot.egg = egg
        
        if egg then
            slot.name.Text = egg.Category or "—"
            slot.rarity.Text = egg.Rarity or "—"
            slot.money.Text = shortMoney(egg.Money)
            
            -- Подсветка выбранного
            if SelectedEgg and SelectedEgg.Uid == egg.Uid then
                slot.frame.BackgroundColor3 = CFG.ACCENT
                slot.frame.BackgroundTransparency = 0.5
            else
                slot.frame.BackgroundColor3 = CFG.BG_WINDOW
                slot.frame.BackgroundTransparency = 0.3
            end
            
            -- Цвет редкости
            local rn = tostring(egg.Rarity):lower()
            if rn:find("divine") then
                slot.rarity.TextColor3 = Color3.fromHex("#F43F5E")
            elseif rn:find("eternal") then
                slot.rarity.TextColor3 = Color3.fromHex("#D946EF")
            elseif rn:find("secret") then
                slot.rarity.TextColor3 = Color3.fromHex("#F97316")
            elseif rn:find("cosmic") then
                slot.rarity.TextColor3 = Color3.fromHex("#06B6D4")
            else
                slot.rarity.TextColor3 = CFG.TEXT_GRAY
            end
        else
            slot.name.Text = "—"
            slot.rarity.Text = "—"
            slot.money.Text = "—"
            slot.frame.BackgroundColor3 = CFG.BG_WINDOW
            slot.frame.BackgroundTransparency = 0.7
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while CFG.RUNNING do
        if CFG.STEALING and not CFG.BUSY then
            pcall(StealBestEggOnce)
            task.wait(CFG.STEAL_DELAY)
        else
            task.wait(0.3)
        end
    end
end)

-- Loop BEST EGG
task.spawn(function()
    while CFG.RUNNING do
        pcall(UpdateBestEgg)
        task.wait(2)
    end
end)

-- Loop Anti-Stun
task.spawn(function()
    while CFG.RUNNING do
        local h = hum()
        if h then
            pcall(function()
                if h:GetState() == Enum.HumanoidStateType.Physics
                   or h:GetState() == Enum.HumanoidStateType.Ragdoll then
                    h:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                h.PlatformStand = false
            end)
        end
        task.wait(0.1)
    end
end)

-- GO / STOP
GoButton.MouseButton1Click:Connect(function()
    CFG.STEALING = true
    setStatus("GO!", CFG.ACCENT)
end)

StopButton.MouseButton1Click:Connect(function()
    CFG.STEALING = false
    CFG.BUSY = false
    setStatus("STOPPED", CFG.TEXT_GRAY)
end)

-- Финал
setStatus("Ready", CFG.ACCENT)
UpdateBestEgg()

_G.AlfredoHubDestroy = function()
    CFG.RUNNING = false
    CFG.STEALING = false
    pcall(function() ScreenGui:Destroy() end)
    _G.AlfredoHubLoaded = false
end

print("[AlfredoHub] 🦫 Загружен!")
