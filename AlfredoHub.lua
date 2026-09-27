-- ════════════════════════════════════════════════════════════════════════
-- ALFREDO HUB 🦫 | Steal an Egg
-- Минималистичный UI в стиле Lennon Hub
-- Автор: ты | Шрифт: GothamMedium | Цвет: бобровый коричневый
-- ════════════════════════════════════════════════════════════════════════

-- Singleton
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
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════
-- КОНФИГ
-- ════════════════════════════════════════════════════════════════════════
local CFG = {
    -- Ресурсы
    LOGO_ID       = "rbxassetid://107301914145735",
    BEAVER_ID     = "rbxassetid://86571455908132",
    
    -- Цвета
    ACCENT        = Color3.fromHex("#8B5A2B"),  -- бобровый коричневый
    ACCENT_LIGHT  = Color3.fromHex("#A0522D"),  -- светлее (hover)
    BG_WINDOW     = Color3.fromHex("#0D0D0D"),  -- фон окна
    BG_ELEMENT    = Color3.fromHex("#1A1A1A"),  -- фон кнопок
    BG_HOVER      = Color3.fromHex("#252525"),  -- hover
    BORDER        = Color3.fromHex("#2A2A2A"),  -- границы
    TEXT_WHITE    = Color3.fromHex("#FFFFFF"),  -- основной текст
    TEXT_GRAY     = Color3.fromHex("#909090"),  -- серый текст
    TEXT_DIM      = Color3.fromHex("#606060"),  -- тусклый текст
    
    -- Шрифт
    FONT          = Enum.Font.GothamMedium,
    FONT_BOLD     = Enum.Font.GothamBold,
    TEXT_SIZE     = 13,
    TEXT_SIZE_SM  = 11,
    TEXT_SIZE_LG  = 15,
    
    -- Размеры
    WINDOW_W      = 280,
    WINDOW_H      = 400,
    ICON_SIZE     = 46,
    
    -- Кража
    METHOD        = "Steal Speed",  -- "Steal Speed" или "Teleport"
    GLIDE_SPEED   = 750,
    STEAL_DELAY   = 1.5,
    
    -- Фильтры
    FILTER_COSMIC  = false,
    FILTER_SECRET  = false,
    FILTER_ETERNAL = false,
    FILTER_DIVINE  = false,
    
    -- Тоглы
    AUTO_TREADMILL = false,
    ANTI_AFK       = false,
    
    -- Состояние
    RUNNING       = true,
    STEALING      = false,
    BUSY          = false,
}

-- ════════════════════════════════════════════════════════════════════════
-- УТИЛИТЫ
-- ════════════════════════════════════════════════════════════════════════
local function try(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

local function char() return LP.Character end
local function hum() 
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function hrp()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Форматирование денег
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

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
end)
pcall(function()
    if hidename then hidename(ScreenGui) end
end)

ScreenGui.Parent = getParent()

-- ════════════════════════════════════════════════════════════════════════
-- ИКОНКА БОБРА (кнопка для открытия UI)
-- ════════════════════════════════════════════════════════════════════════
local BeaverButton = Instance.new("ImageButton")
BeaverButton.Name = "BeaverButton"
BeaverButton.Size = UDim2.fromOffset(CFG.ICON_SIZE, CFG.ICON_SIZE)
BeaverButton.Position = UDim2.new(0, 18, 0.5, -23)
BeaverButton.BackgroundColor3 = CFG.BG_ELEMENT
BeaverButton.BorderSizePixel = 0
BeaverButton.Image = CFG.BEAVER_ID
BeaverButton.ScaleType = Enum.ScaleType.Crop
BeaverButton.AutoButtonColor = false
BeaverButton.ZIndex = 20
BeaverButton.Parent = ScreenGui

local bbCorner = Instance.new("UICorner")
bbCorner.CornerRadius = UDim.new(0, 23)
bbCorner.Parent = BeaverButton

local bbStroke = Instance.new("UIStroke")
bbStroke.Color = CFG.ACCENT
bbStroke.Thickness = 1.5
bbStroke.Transparency = 0.15
bbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bbStroke.Parent = BeaverButton

-- Двигаем кнопку (drag)
local draggingBtn = false
local btnDragStart, btnStartPos
BeaverButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        btnDragStart = input.Position
        btnStartPos = BeaverButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement 
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        BeaverButton.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = false
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- ГЛАВНОЕ ОКНО
-- ════════════════════════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(CFG.WINDOW_W, CFG.WINDOW_H)
MainFrame.Position = UDim2.new(0, 80, 0.5, -CFG.WINDOW_H / 2)
MainFrame.BackgroundColor3 = CFG.BG_WINDOW
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 14)
mfCorner.Parent = MainFrame

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = CFG.ACCENT
mfStroke.Thickness = 1.5
mfStroke.Transparency = 0.3
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Parent = MainFrame

-- Двигаем окно (drag)
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

-- Открыть/закрыть UI кнопкой бобра
BeaverButton.MouseButton1Click:Connect(function()
    if not draggingBtn then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- ЗАГОЛОВОК С ЛОГОТИПОМ "ALFREDOHUB"
-- ════════════════════════════════════════════════════════════════════════
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -20, 0, 50)
Header.Position = UDim2.fromOffset(10, 10)
Header.BackgroundTransparency = 1
Header.ZIndex = 11
Header.Parent = MainFrame

local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "Logo"
LogoImage.Size = UDim2.new(1, 0, 1, 0)
LogoImage.Position = UDim2.fromScale(0, 0)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = CFG.LOGO_ID
LogoImage.ScaleType = Enum.ScaleType.Fit
LogoImage.ZIndex = 12
LogoImage.Parent = Header

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.fromOffset(10, 65)
Divider.BackgroundColor3 = CFG.BORDER
Divider.BorderSizePixel = 0
Divider.ZIndex = 11
Divider.Parent = MainFrame

print("[AlfredoHub] Часть 1 загружена — UI каркас готов")
-- ════════════════════════════════════════════════════════════════════════
-- BEST EGG (Top 4 яйца)
-- ════════════════════════════════════════════════════════════════════════
local BestEggSection = Instance.new("Frame")
BestEggSection.Name = "BestEggSection"
BestEggSection.Size = UDim2.new(1, -20, 0, 200)
BestEggSection.Position = UDim2.fromOffset(10, 75)
BestEggSection.BackgroundColor3 = CFG.BG_ELEMENT
BestEggSection.BackgroundTransparency = 0.2
BestEggSection.BorderSizePixel = 0
BestEggSection.ZIndex = 11
BestEggSection.Parent = MainFrame

local besCorner = Instance.new("UICorner")
besCorner.CornerRadius = UDim.new(0, 10)
besCorner.Parent = BestEggSection

local besStroke = Instance.new("UIStroke")
besStroke.Color = CFG.BORDER
besStroke.Thickness = 1
besStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
besStroke.Parent = BestEggSection

-- Заголовок BEST EGG
local BestEggTitle = Instance.new("TextLabel")
BestEggTitle.Name = "Title"
BestEggTitle.Size = UDim2.new(1, -20, 0, 20)
BestEggTitle.Position = UDim2.fromOffset(10, 8)
BestEggTitle.BackgroundTransparency = 1
BestEggTitle.Text = "BEST EGG"
BestEggTitle.Font = CFG.FONT_BOLD
BestEggTitle.TextSize = CFG.TEXT_SIZE_SM
BestEggTitle.TextColor3 = CFG.ACCENT
BestEggTitle.TextXAlignment = Enum.TextXAlignment.Left
BestEggTitle.ZIndex = 12
BestEggTitle.Parent = BestEggSection

-- Создаём 4 ячейки для топ-4 яиц
local EggSlots = {}
for i = 1, 4 do
    local slot = Instance.new("Frame")
    slot.Name = "EggSlot" .. i
    slot.Size = UDim2.new(1, -20, 0, 38)
    slot.Position = UDim2.fromOffset(10, 30 + (i - 1) * 42)
    slot.BackgroundColor3 = CFG.BG_WINDOW
    slot.BackgroundTransparency = 0.3
    slot.BorderSizePixel = 0
    slot.ZIndex = 12
    slot.Parent = BestEggSection

    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 8)
    slotCorner.Parent = slot

    -- Номер (#1, #2, #3, #4)
    local numLabel = Instance.new("TextLabel")
    numLabel.Size = UDim2.fromOffset(24, 38)
    numLabel.Position = UDim2.fromOffset(4, 0)
    numLabel.BackgroundTransparency = 1
    numLabel.Text = "#" .. i
    numLabel.Font = CFG.FONT_BOLD
    numLabel.TextSize = CFG.TEXT_SIZE_SM
    numLabel.TextColor3 = CFG.TEXT_DIM
    numLabel.ZIndex = 13
    numLabel.Parent = slot

    -- Название яйца
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -130, 0, 16)
    nameLabel.Position = UDim2.fromOffset(32, 4)
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
    rarityLabel.Size = UDim2.new(1, -130, 0, 14)
    rarityLabel.Position = UDim2.fromOffset(32, 20)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "—"
    rarityLabel.Font = CFG.FONT
    rarityLabel.TextSize = CFG.TEXT_SIZE_SM
    rarityLabel.TextColor3 = CFG.TEXT_GRAY
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.TextTruncate = Enum.TextTruncate.AtEnd
    rarityLabel.ZIndex = 13
    rarityLabel.Parent = slot

    -- Цена ($/s)
    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Name = "Money"
    moneyLabel.Size = UDim2.fromOffset(90, 38)
    moneyLabel.Position = UDim2.new(1, -94, 0, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "—"
    moneyLabel.Font = CFG.FONT_BOLD
    moneyLabel.TextSize = CFG.TEXT_SIZE
    moneyLabel.TextColor3 = CFG.ACCENT
    moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
    moneyLabel.ZIndex = 13
    moneyLabel.Parent = slot

    EggSlots[i] = {
        frame = slot,
        name = nameLabel,
        rarity = rarityLabel,
        money = moneyLabel,
    }
end

-- ════════════════════════════════════════════════════════════════════════
-- МЕТОД КРАЖИ (переключатель)
-- ════════════════════════════════════════════════════════════════════════
local MethodSection = Instance.new("Frame")
MethodSection.Name = "MethodSection"
MethodSection.Size = UDim2.new(1, -20, 0, 32)
MethodSection.Position = UDim2.fromOffset(10, 285)
MethodSection.BackgroundColor3 = CFG.BG_ELEMENT
MethodSection.BackgroundTransparency = 0.2
MethodSection.BorderSizePixel = 0
MethodSection.ZIndex = 11
MethodSection.Parent = MainFrame

local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 8)
msCorner.Parent = MethodSection

local MethodLabel = Instance.new("TextLabel")
MethodLabel.Size = UDim2.new(0.5, -10, 1, 0)
MethodLabel.Position = UDim2.fromOffset(10, 0)
MethodLabel.BackgroundTransparency = 1
MethodLabel.Text = "METHOD"
MethodLabel.Font = CFG.FONT_BOLD
MethodLabel.TextSize = CFG.TEXT_SIZE_SM
MethodLabel.TextColor3 = CFG.TEXT_GRAY
MethodLabel.TextXAlignment = Enum.TextXAlignment.Left
MethodLabel.ZIndex = 12
MethodLabel.Parent = MethodSection

local MethodButton = Instance.new("TextButton")
MethodButton.Name = "MethodButton"
MethodButton.Size = UDim2.new(0.5, -10, 1, -8)
MethodButton.Position = UDim2.new(0.5, 5, 0, 4)
MethodButton.BackgroundColor3 = CFG.ACCENT
MethodButton.BackgroundTransparency = 0.15
MethodButton.BorderSizePixel = 0
MethodButton.Text = "Steal Speed"
MethodButton.Font = CFG.FONT_BOLD
MethodButton.TextSize = CFG.TEXT_SIZE_SM
MethodButton.TextColor3 = CFG.TEXT_WHITE
MethodButton.AutoButtonColor = false
MethodButton.ZIndex = 12
MethodButton.Parent = MethodSection

local mbCorner = Instance.new("UICorner")
mbCorner.CornerRadius = UDim.new(0, 6)
mbCorner.Parent = MethodButton

MethodButton.MouseButton1Click:Connect(function()
    if CFG.METHOD == "Steal Speed" then
        CFG.METHOD = "Teleport"
        MethodButton.Text = "Teleport"
    else
        CFG.METHOD = "Steal Speed"
        MethodButton.Text = "Steal Speed"
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- RARITY FILTER (4 галочки)
-- ════════════════════════════════════════════════════════════════════════
local FilterSection = Instance.new("Frame")
FilterSection.Name = "FilterSection"
FilterSection.Size = UDim2.new(1, -20, 0, 60)
FilterSection.Position = UDim2.fromOffset(10, 325)
FilterSection.BackgroundTransparency = 1
FilterSection.ZIndex = 11
FilterSection.Parent = MainFrame

local FilterTitle = Instance.new("TextLabel")
FilterTitle.Size = UDim2.new(1, 0, 0, 16)
FilterTitle.Position = UDim2.fromOffset(0, 0)
FilterTitle.BackgroundTransparency = 1
FilterTitle.Text = "RARITY FILTER"
FilterTitle.Font = CFG.FONT_BOLD
FilterTitle.TextSize = CFG.TEXT_SIZE_SM
FilterTitle.TextColor3 = CFG.ACCENT
FilterTitle.TextXAlignment = Enum.TextXAlignment.Left
FilterTitle.ZIndex = 12
FilterTitle.Parent = FilterSection

-- Создаём 4 галочки (2x2)
local RarityOptions = {
    {key = "FILTER_COSMIC",  name = "Cosmic",  color = Color3.fromHex("#06B6D4")},
    {key = "FILTER_SECRET",  name = "Secret",  color = Color3.fromHex("#F97316")},
    {key = "FILTER_ETERNAL", name = "Eternal", color = Color3.fromHex("#D946EF")},
    {key = "FILTER_DIVINE",  name = "Divine",  color = Color3.fromHex("#F43F5E")},
}

local Checkboxes = {}
for i, opt in ipairs(RarityOptions) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "CB_" .. opt.name
    checkbox.Size = UDim2.new(0.5, -3, 0, 20)
    checkbox.Position = UDim2.new(col * 0.5, col == 0 and 0 or 3, 0, 20 + row * 22)
    checkbox.BackgroundColor3 = CFG.BG_ELEMENT
    checkbox.BackgroundTransparency = 0.2
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.AutoButtonColor = false
    checkbox.ZIndex = 12
    checkbox.Parent = FilterSection

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = checkbox

    local cbStroke = Instance.new("UIStroke")
    cbStroke.Color = opt.color
    cbStroke.Thickness = 1
    cbStroke.Transparency = 0.5
    cbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cbStroke.Parent = checkbox

    -- Квадратик-галочка
    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(12, 12)
    box.Position = UDim2.fromOffset(5, 4)
    box.BackgroundColor3 = opt.color
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 0
    box.ZIndex = 13
    box.Parent = checkbox

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 3)
    boxCorner.Parent = box

    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.fromScale(1, 1)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "✓"
    checkMark.Font = CFG.FONT_BOLD
    checkMark.TextSize = 10
    checkMark.TextColor3 = CFG.BG_WINDOW
    checkMark.Visible = false
    checkMark.ZIndex = 14
    checkMark.Parent = box

    -- Название редкости
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -22, 1, 0)
    nameLabel.Position = UDim2.fromOffset(22, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = opt.name
    nameLabel.Font = CFG.FONT_BOLD
    nameLabel.TextSize = CFG.TEXT_SIZE_SM
    nameLabel.TextColor3 = opt.color
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = checkbox

    checkbox.MouseButton1Click:Connect(function()
        CFG[opt.key] = not CFG[opt.key]
        checkMark.Visible = CFG[opt.key]
        box.BackgroundTransparency = CFG[opt.key] and 0.2 or 0.7
        cbStroke.Transparency = CFG[opt.key] and 0.2 or 0.5
    end)

    Checkboxes[opt.name] = {frame = checkbox, box = box, check = checkMark, stroke = cbStroke}
end

print("[AlfredoHub] Часть 2 загружена — BEST EGG, метод, фильтр")
-- ════════════════════════════════════════════════════════════════════════
-- GO / STOP КНОПКИ
-- ════════════════════════════════════════════════════════════════════════
local ButtonsSection = Instance.new("Frame")
ButtonsSection.Name = "ButtonsSection"
ButtonsSection.Size = UDim2.new(1, -20, 0, 34)
ButtonsSection.Position = UDim2.fromOffset(10, 262)
ButtonsSection.BackgroundTransparency = 1
ButtonsSection.ZIndex = 11
ButtonsSection.Parent = MainFrame

-- GO кнопка
local GoButton = Instance.new("TextButton")
GoButton.Name = "GoButton"
GoButton.Size = UDim2.new(0.5, -3, 1, 0)
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

local goCorner = Instance.new("UICorner")
goCorner.CornerRadius = UDim.new(0, 8)
goCorner.Parent = GoButton

-- STOP кнопка
local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(0.5, -3, 1, 0)
StopButton.Position = UDim2.new(0.5, 3, 0, 0)
StopButton.BackgroundColor3 = CFG.BG_ELEMENT
StopButton.BorderSizePixel = 0
StopButton.Text = "■ STOP"
StopButton.Font = CFG.FONT_BOLD
StopButton.TextSize = CFG.TEXT_SIZE
StopButton.TextColor3 = CFG.TEXT_WHITE
StopButton.AutoButtonColor = false
StopButton.ZIndex = 12
StopButton.Parent = ButtonsSection

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = StopButton

local stopStroke = Instance.new("UIStroke")
stopStroke.Color = CFG.BORDER
stopStroke.Thickness = 1
stopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stopStroke.Parent = StopButton

-- Hover эффекты
GoButton.MouseEnter:Connect(function()
    TweenService:Create(GoButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.ACCENT_LIGHT}):Play()
end)
GoButton.MouseLeave:Connect(function()
    TweenService:Create(GoButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.ACCENT}):Play()
end)

StopButton.MouseEnter:Connect(function()
    TweenService:Create(StopButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.BG_HOVER}):Play()
end)
StopButton.MouseLeave:Connect(function()
    TweenService:Create(StopButton, TweenInfo.new(0.15), {BackgroundColor3 = CFG.BG_ELEMENT}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════
-- AUTO TREADMILL + ANTI-AFK
-- ════════════════════════════════════════════════════════════════════════
local TogglesSection = Instance.new("Frame")
TogglesSection.Name = "TogglesSection"
TogglesSection.Size = UDim2.new(1, -20, 0, 60)
TogglesSection.Position = UDim2.fromOffset(10, 300)
TogglesSection.BackgroundTransparency = 1
TogglesSection.ZIndex = 11
TogglesSection.Parent = MainFrame

-- Функция создания тогла
local function createToggle(parent, name, yOffset, initialValue, callback)
    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, 0, 0, 26)
    row.Position = UDim2.fromOffset(0, yOffset)
    row.BackgroundColor3 = CFG.BG_ELEMENT
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CFG.FONT_BOLD
    label.TextSize = CFG.TEXT_SIZE_SM
    label.TextColor3 = CFG.TEXT_WHITE
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = row

    -- Toggle pill
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.fromOffset(32, 18)
    pill.Position = UDim2.new(1, -42, 0.5, -9)
    pill.BackgroundColor3 = initialValue and CFG.ACCENT or CFG.BG_HOVER
    pill.BorderSizePixel = 0
    pill.Text = ""
    pill.AutoButtonColor = false
    pill.ZIndex = 13
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pill

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = initialValue and UDim2.new(0, 16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = CFG.TEXT_WHITE
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = pill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = initialValue

    pill.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(0, 16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        TweenService:Create(pill, TweenInfo.new(0.15), {
            BackgroundColor3 = state and CFG.ACCENT or CFG.BG_HOVER
        }):Play()
        if callback then callback(state) end
    end)

    return {pill = pill, knob = knob, state = state}
end

-- Auto Treadmill тогл
local TreadmillToggle = createToggle(TogglesSection, "Auto Treadmill", 0, CFG.AUTO_TREADMILL, function(v)
    CFG.AUTO_TREADMILL = v
end)

-- Anti-AFK тогл
local AntiAFKToggle = createToggle(TogglesSection, "Anti-AFK", 30, CFG.ANTI_AFK, function(v)
    CFG.ANTI_AFK = v
end)

-- ════════════════════════════════════════════════════════════════════════
-- STATUS (внизу)
-- ════════════════════════════════════════════════════════════════════════
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, -20, 0, 22)
StatusFrame.Position = UDim2.new(0, 10, 1, -32)
StatusFrame.BackgroundTransparency = 1
StatusFrame.ZIndex = 11
StatusFrame.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(0, 4, 0.5, -4)
StatusDot.BackgroundColor3 = CFG.TEXT_DIM
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 12
StatusDot.Parent = StatusFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.fromOffset(18, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Ready"
StatusText.Font = CFG.FONT
StatusText.TextSize = CFG.TEXT_SIZE_SM
StatusText.TextColor3 = CFG.TEXT_GRAY
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.ZIndex = 12
StatusText.Parent = StatusFrame

-- Функция обновления статуса
local function setStatus(text, color)
    StatusText.Text = tostring(text)
    if color then
        StatusDot.BackgroundColor3 = color
    end
end

-- Экспорт для следующих частей
_G.AlfredoStatus = setStatus
_G.AlfredoUI = {
    MainFrame = MainFrame,
    GoButton = GoButton,
    StopButton = StopButton,
    EggSlots = EggSlots,
    Checkboxes = Checkboxes,
    setStatus = setStatus,
}

print("[AlfredoHub] Часть 3 загружена — кнопки, тоглы, статус")
-- ════════════════════════════════════════════════════════════════════════
-- ЯДРО КРАЖИ — яйца, промпты, Guard Strike
-- ════════════════════════════════════════════════════════════════════════

-- Ссылки на Remote'ы (найдём при загрузке)
local Net = ReplicatedStorage:FindFirstChild("Packages") 
    and ReplicatedStorage.Packages:FindFirstChild("Networking")

local Remotes = {
    Carry = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggCarry"),
    Snapshot = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot"),
    Strike = Net and Net:FindFirstChild("RE/GuardPatrol/ForestStrike"),
    PlaceEgg = Net and Net:FindFirstChild("RF/EggWorld/AskPlaceEgg"),
    Hatch = Net and Net:FindFirstChild("RF/EggWorld/AskHatch"),
}

-- EggState модуль
local EggState
pcall(function()
    EggState = require(ReplicatedStorage.Client.EggState)
end)

-- AreaEggSlotIdentity модуль
local SlotIdentity
pcall(function()
    SlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
end)

print("[AlfredoHub] Remotes:", 
    "Carry=" .. tostring(Remotes.Carry ~= nil),
    "Snapshot=" .. tostring(Remotes.Snapshot ~= nil),
    "Strike=" .. tostring(Remotes.Strike ~= nil))

-- ════════════════════════════════════════════════════════════════════════
-- ПРОВЕРКА ДЕНЬ / НОЧЬ
-- ════════════════════════════════════════════════════════════════════════
local AreaEggCycle
pcall(function()
    AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
end)

local function isDay()
    if AreaEggCycle and AreaEggCycle.IsNightPhase then
        local ok, res = pcall(function()
            return AreaEggCycle.IsNightPhase(workspace:GetServerTimeNow())
        end)
        if ok then return res ~= true end
    end
    -- Fallback: ClockTime
    local ct = Lighting.ClockTime
    return ct >= 6 and ct < 18
end

-- ════════════════════════════════════════════════════════════════════════
-- ФИЛЬТР ПО РЕДКОСТИ
-- ════════════════════════════════════════════════════════════════════════
local RARITY_MAP = {
    ["Divine"] = 6,
    ["Eternal"] = 5,
    ["Secret"] = 4,
    ["Cosmic"] = 3,
    ["Mythic"] = 2,
    ["Legendary"] = 1,
}

local function getRarity(record)
    if not record then return "Common", 0 end
    
    -- Из Assets
    local AssetsData = require(ReplicatedStorage.Data.Assets)
    local cat = record.AssetCategory or record.Category
    if cat and AssetsData then
        local dir = AssetsData.Directory or AssetsData
        local info = dir[cat]
        if info and info.Rarity then
            local r = info.Rarity
            local name = type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
            return name, RARITY_MAP[name] or 0
        end
    end
    
    return "Common", 0
end

local function passesFilter(record)
    local rarityName, tier = getRarity(record)
    local name = tostring(rarityName):lower()
    
    -- Если Cosmic выбран и это Cosmic → пропускаем
    if CFG.FILTER_COSMIC and name:find("cosmic") then return true, rarityName end
    if CFG.FILTER_SECRET and name:find("secret") then return true, rarityName end
    if CFG.FILTER_ETERNAL and name:find("eternal") then return true, rarityName end
    if CFG.FILTER_DIVINE and name:find("divine") then return true, rarityName end
    
    -- Если ни один фильтр не выбран → пропускаем всё
    if not (CFG.FILTER_COSMIC or CFG.FILTER_SECRET or CFG.FILTER_ETERNAL or CFG.FILTER_DIVINE) then
        return true, rarityName
    end
    
    return false, rarityName
end

-- ════════════════════════════════════════════════════════════════════════
-- ПОИСК ЯИЦ
-- ════════════════════════════════════════════════════════════════════════
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
            local passes, rarityName = passesFilter(rec)
            if passes then
                local AssetsData = require(ReplicatedStorage.Data.Assets)
                local cat = rec.AssetCategory or "Egg"
                local dir = AssetsData.Directory or AssetsData
                local info = dir[cat]
                local money = info and (info.Income or info.EarningRate or info.Money or 0) or 0
                money = money * (rec.AssetScale or 1)
                
                table.insert(eggs, {
                    Uid = rec.Uid,
                    Category = cat,
                    Rarity = rarityName,
                    Money = money,
                    CFrame = rec.BoundsCFrame,
                    Position = rec.BoundsCFrame.Position,
                    AreaId = rec.AreaId,
                    NestId = rec.NestId,
                    Record = rec,
                })
            end
        end
    end
    
    -- Сортируем по цене (дорогие первые)
    table.sort(eggs, function(a, b)
        return (a.Money or 0) > (b.Money or 0)
    end)
    
    return eggs
end

-- ════════════════════════════════════════════════════════════════════════
-- ТРИГГЕР ПРОМПТОВ РЯДОМ
-- ════════════════════════════════════════════════════════════════════════
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

-- ════════════════════════════════════════════════════════════════════════
-- ПРОВЕРКА "ЯЙЦО В РУКАХ"
-- ════════════════════════════════════════════════════════════════════════
local function isCarrying()
    local c = char()
    if not c then return false end
    for _, obj in ipairs(c:GetChildren()) do
        if obj:IsA("Tool") then
            local n = obj.Name:lower()
            if n:find("egg") or obj:GetAttribute("Uid") or obj:GetAttribute("EggUid") then
                return true
            end
        end
    end
    -- Проверка Backpack
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then
                local n = obj.Name:lower()
                if n:find("egg") or obj:GetAttribute("Uid") then
                    return true
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════
-- GUARD STRIKE — 4-фазная кража
-- ════════════════════════════════════════════════════════════════════════
local function guardStrike(egg)
    if not egg or not egg.Uid or not egg.CFrame then return false end
    
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return false end
    
    local targetCF = egg.CFrame * CFrame.new(0, 0.4, 0)
    local targetPos = egg.Position
    
    -- Anti-Stun (постоянно)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid.PlatformStand = false
    
    CFG.BUSY = true
    
    -- ═══ ФАЗА 1: Подъём яйца ═══
    setStatus("[1/4] Lifting egg...", CFG.ACCENT)
    
    -- Телепорт к яйцу
    local oldWalk = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0
    root.CFrame = targetCF
    
    local t0 = tick()
    while not isCarrying() and tick() - t0 < 3.5 do
        if not CFG.STEALING then 
            humanoid.WalkSpeed = oldWalk
            CFG.BUSY = false
            return false 
        end
        
        root.CFrame = targetCF
        triggerPromptsNear(targetPos)
        
        if Remotes.Carry then
            pcall(function()
                Remotes.Carry:InvokeServer({Uid = egg.Uid})
            end)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if not isCarrying() then
        setStatus("Failed to lift egg", CFG.TEXT_DIM)
        humanoid.WalkSpeed = oldWalk
        CFG.BUSY = false
        return false
    end
    
    -- ═══ ФАЗА 2: Ждём Guard Strike ═══
    setStatus("[2/4] Waiting for guard...", CFG.ACCENT)
    
    t0 = tick()
    local struck = false
    while isCarrying() and tick() - t0 < 4.5 do
        if not CFG.STEALING then break end
        
        root.CFrame = targetCF
        
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
    
    -- ═══ ФАЗА 3: Перехват яйца ═══
    setStatus("[3/4] Re-grabbing egg...", CFG.ACCENT)
    
    t0 = tick()
    while not isCarrying() and tick() - t0 < 3 do
        if not CFG.STEALING then break end
        
        root.CFrame = targetCF
        triggerPromptsNear(targetPos)
        
        if Remotes.Carry then
            pcall(function()
                Remotes.Carry:InvokeServer({Uid = egg.Uid})
            end)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    humanoid.WalkSpeed = oldWalk
    
    -- ═══ ФАЗА 4: Проверка ═══
    local success = isCarrying()
    
    if success then
        setStatus("[4/4] Egg secured!", CFG.ACCENT)
    else
        setStatus("Guard Strike failed", CFG.TEXT_DIM)
    end
    
    CFG.BUSY = false
    return success
end

-- ════════════════════════════════════════════════════════════════════════
-- TELEPORT-МЕТОД (Warp) — быстрый
-- ════════════════════════════════════════════════════════════════════════
local function warpSteal(egg, session)
    if not egg or not egg.CFrame then return false end
    
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return false end
    
    CFG.BUSY = true
    local targetCF = egg.CFrame * CFrame.new(0, 0.4, 0)
    local targetPos = egg.Position
    
    setStatus("[WARP] Teleporting...", CFG.ACCENT)
    
    -- Телепорт
    local oldWalk = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0
    root.CFrame = targetCF
    
    task.wait(0.1)
    
    -- Промпты
    triggerPromptsNear(targetPos)
    
    -- Carry
    if Remotes.Carry then
        pcall(function()
            Remotes.Carry:InvokeServer({Uid = egg.Uid})
        end)
    end
    
    task.wait(0.3)
    
    -- Проверка и реграб
    if not isCarrying() then
        setStatus("[WARP] Re-grabbing...", CFG.ACCENT)
        triggerPromptsNear(targetPos)
        if Remotes.Carry then
            pcall(function()
                Remotes.Carry:InvokeServer({Uid = egg.Uid})
            end)
        end
        task.wait(0.5)
    end
    
    humanoid.WalkSpeed = oldWalk
    local success = isCarrying()
    
    if success then
        setStatus("[WARP] Secured!", CFG.ACCENT)
    else
        setStatus("[WARP] Failed", CFG.TEXT_DIM)
    end
    
    CFG.BUSY = false
    return success
end

-- ════════════════════════════════════════════════════════════════════════
-- ВОЗВРАТ НА БАЗУ
-- ════════════════════════════════════════════════════════════════════════
local function returnToBase(session)
    local root = hrp()
    if not root then return false end
    
    setStatus("Returning to base...", CFG.ACCENT)
    
    -- Ищем свою базу
    local PlotState
    pcall(function()
        PlotState = require(ReplicatedStorage.Client.PlotState)
    end)
    
    local basePos = Vector3.new(464.7, 70.4, -364.0)
    if PlotState and PlotState.ResolvePlot then
        local ok, plot = pcall(function() return PlotState.ResolvePlot() end)
        if ok and plot and plot.CenterPoint then
            basePos = plot.CenterPoint.Position or plot.CenterPoint
        end
    end
    
    -- Летим на базу
    local t0 = tick()
    while (root.Position - basePos).Magnitude > 5 and tick() - t0 < 15 do
        if not CFG.STEALING then break end
        
        local dir = (basePos - root.Position).Unit
        root.CFrame = CFrame.new(root.Position + dir * 15)
        root.AssemblyLinearVelocity = Vector3.zero
        
        RunService.Heartbeat:Wait()
    end
    
    root.CFrame = CFrame.new(basePos)
    return true
end

-- Экспорт для Части 5
_G.AlfredoCore = {
    getEggs = getEggs,
    guardStrike = guardStrike,
    warpSteal = warpSteal,
    returnToBase = returnToBase,
    isCarrying = isCarrying,
    isDay = isDay,
}

print("[AlfredoHub] Часть 4 загружена — ядро кражи")
-- ════════════════════════════════════════════════════════════════════════
-- ЦИКЛ КРАЖИ (StealBestEggOnce)
-- ════════════════════════════════════════════════════════════════════════
local function StealBestEggOnce()
    if CFG.BUSY then return false end
    if not isDay() then
        setStatus("Waiting for day...", CFG.TEXT_DIM)
        return false
    end
    
    local eggs = getEggs()
    if #eggs == 0 then
        setStatus("No matching eggs", CFG.TEXT_DIM)
        return false
    end
    
    local target = eggs[1]
    setStatus("Stealing " .. target.Category .. "...", CFG.ACCENT)
    
    local method = CFG.METHOD
    local success
    if method == "Teleport" then
        success = warpSteal(target, session)
    else
        success = guardStrike(target, session)
    end
    
    if success then
        returnToBase(session)
        setStatus("Egg secured! (" .. method .. ")", CFG.ACCENT)
        return true
    end
    
    return false
end

-- ════════════════════════════════════════════════════════════════════════
-- ОБНОВЛЕНИЕ BEST EGG (Top 4)
-- ════════════════════════════════════════════════════════════════════════
local function UpdateBestEgg()
    local eggs = getEggs()
    
    for i = 1, 4 do
        local slot = EggSlots[i]
        if not slot then continue end
        
        local egg = eggs[i]
        if egg then
            slot.name.Text = egg.Category or "—"
            slot.rarity.Text = egg.Rarity or "—"
            slot.money.Text = shortMoney(egg.Money)
            
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
            
            slot.frame.BackgroundTransparency = 0.3
        else
            slot.name.Text = "—"
            slot.rarity.Text = "—"
            slot.money.Text = "—"
            slot.frame.BackgroundTransparency = 0.7
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════
-- AUTO TREADMILL
-- ════════════════════════════════════════════════════════════════════════
local function runTreadmill()
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return end
    
    -- Ищем дорожку на своей базе
    local Plots = workspace:FindFirstChild("Plots")
    if not Plots then return end
    
    local myPlot
    for _, plot in ipairs(Plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner") or plot:GetAttribute("OwnerUserId")
        if tostring(owner) == tostring(LP.UserId) or tostring(owner) == LP.Name then
            myPlot = plot
            break
        end
    end
    
    if not myPlot then return end
    
    local treadmill = myPlot:FindFirstChild("TreadmillBottom", true)
    if not treadmill then return end
    
    -- Идём к дорожке
    if (root.Position - treadmill.Position).Magnitude > 5 then
        local dir = (treadmill.Position - root.Position).Unit
        root.CFrame = CFrame.new(root.Position + dir * 10)
        root.AssemblyLinearVelocity = Vector3.zero
        return
    end
    
    -- На дорожке — сбрасываем скорость
    root.CFrame = CFrame.new(treadmill.Position + Vector3.new(0, 2, 0))
end

-- ════════════════════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════════════════════
local VirtualUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if CFG.ANTI_AFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ════════════════════════════════════════════════════════════════════════
-- MAIN LOOP (главный цикл)
-- ════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while CFG.RUNNING do
        if CFG.STEALING and not CFG.BUSY then
            -- Крадём
            pcall(StealBestEggOnce)
            task.wait(CFG.STEAL_DELAY)
        elseif CFG.AUTO_TREADMILL and not CFG.BUSY then
            -- Идём на дорожку
            pcall(runTreadmill)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end)

-- Отдельный loop для обновления BEST EGG
task.spawn(function()
    while CFG.RUNNING do
        pcall(UpdateBestEgg)
        task.wait(2)
    end
end)

-- Отдельный loop для Anti-Stun (постоянно)
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

-- ════════════════════════════════════════════════════════════════════════
-- ПРИВЯЗКА GO / STOP
-- ════════════════════════════════════════════════════════════════════════
GoButton.MouseButton1Click:Connect(function()
    CFG.STEALING = true
    setStatus("GO! Stealing started", CFG.ACCENT)
    _G.AlfredoStatus("GO! Started", CFG.ACCENT)
end)

StopButton.MouseButton1Click:Connect(function()
    CFG.STEALING = false
    CFG.BUSY = false
    setStatus("STOPPED", CFG.TEXT_GRAY)
end)

-- ════════════════════════════════════════════════════════════════════════
-- ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
-- ════════════════════════════════════════════════════════════════════════
setStatus("Ready", CFG.ACCENT)
UpdateBestEgg()

-- Destroy
_G.AlfredoHubDestroy = function()
    CFG.RUNNING = false
    CFG.STEALING = false
    pcall(function()
        if ScreenGui then ScreenGui:Destroy() end
    end)
    _G.AlfredoHubLoaded = false
    print("[AlfredoHub] Destroyed")
end

print("[AlfredoHub] 🦫 Полностью загружен!")
print("[AlfredoHub] Метод: " .. CFG.METHOD)
print("[AlfredoHub] Шрифт: GothamMedium")
print("[AlfredoHub] Цвет: #8B5A2B")