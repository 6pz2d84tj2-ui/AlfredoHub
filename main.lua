-- ==========================================
-- 🦫 ALFREDOHUB v1.0 | STEAL AN EGG 🦫
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Флаги функций (Toggles)
getgenv().AutoSteal = false
getgenv().AutoTreadmill = false

-- Создание главного UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlfredoHubUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 260)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.04, 0, 0, 0)
Title.Text = "🦫 AlfredoHub | Steal an Egg"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 16
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Контейнер для кнопок
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- Функция создания тумблера (Toggle)
local function CreateToggle(name, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    Button.Text = "   " .. text .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(200, 100, 100)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansSemiBold
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.Text = "   " .. text .. ": ON"
            Button.TextColor3 = Color3.fromRGB(100, 220, 120)
            Button.BackgroundColor3 = Color3.fromRGB(45, 55, 48)
        else
            Button.Text = "   " .. text .. ": OFF"
            Button.TextColor3 = Color3.fromRGB(200, 100, 100)
            Button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        end
        callback(state)
    end)
end

-- Функция создания обычной кнопки
local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansSemiBold
    Button.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

-- 1. Тумблер: Auto Steal Eggs
CreateToggle("AutoStealToggle", "⚡ Auto Steal Eggs (Воровать яйца)", function(enabled)
    getgenv().AutoSteal = enabled
    if enabled then
        task.spawn(function()
            while getgenv().AutoSteal do
                task.wait(0.1)
                pcall(function()
                    for _, v in pairs(workspace:GetChildren()) do
                        if v.Name:find("Egg") and v:FindFirstChild("TouchInterest") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                        end
                    end
                end)
            end
        end)
    end
end)

-- 2. Тумблер: Auto Treadmill
CreateToggle("TreadmillToggle", "🏃 Auto Treadmill (Беговая дорожка)", function(enabled)
    getgenv().AutoTreadmill = enabled
    if enabled then
        task.spawn(function()
            while getgenv().AutoTreadmill do
                task.wait(0.1)
                pcall(function()
                    local treadmill = workspace:FindFirstChild("Treadmills") or workspace:FindFirstChild("Treadmill")
                    if treadmill then
                        local part = treadmill:FindFirstChildWhichIsA("BasePart")
                        if part then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
                        end
                    end
                end)
            end
        end)
    end
end)

-- 3. Кнопка: Увеличить скорость
CreateButton("⚡ Speed 100 (Быстрый бег)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
end)

-- Уведомление о успешном запуске
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🦫 AlfredoHub",
    Text = "Успешно запущен!",
    Duration = 3
})
