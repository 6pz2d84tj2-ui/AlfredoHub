-- Подгружаем UI библиотеку Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Создаем главное окно AlfredoHub с кастомной аватаркой Бобра
local Window = OrionLib:MakeWindow({
    Name = "🦫 AlfredoHub v1.0 | Steal an Egg", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "AlfredoConfig",
    IntroEnabled = true,
    IntroText = "AlfredoHub Loading...",
    IntroIcon = "rbxassetid://13282218084" -- Иконка бобра
})

-- Вкладка "Скрипты"
local MainTab = Window:MakeTab({
    Name = "Главная (Софты)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Вкладка "Персонаж"
local PlayerTab = Window:MakeTab({
    Name = "Персонаж",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Кнопка запуска Chilli Hub
MainTab:AddButton({
    Name = "🌶️ Запустить Chilli Hub (AutoSteal/Treadmill)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()
    end    
})

-- Кнопка запуска NEVAHUB
MainTab:AddButton({
    Name = "⚡ Запустить NEVAHUB (Запасной софт)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VEZ2/NEVAHUB/main/2"))()
    end    
})

-- Настройки игрока
PlayerTab:AddButton({
    Name = "Быстрый бег (Speed 100)",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end    
})

PlayerTab:AddButton({
    Name = "Высокий прыжок (Jump 120)",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 120
    end    
})

PlayerTab:AddButton({
    Name = "Сбросить скорость/прыжок",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end    
})

-- Запуск интерфейса
OrionLib:Init()
