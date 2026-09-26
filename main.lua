-- Подгружаем UI библиотеку Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Создаем главное окно хаба
local Window = OrionLib:MakeWindow({
    Name = "AlfredoHub v1.0", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "AlfredoConfig"
})

-- Вкладка "Игрок"
local PlayerTab = Window:MakeTab({
    Name = "Главная",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Кнопка быстрой ходьбы
PlayerTab:AddButton({
    Name = "Быстрый бег (Speed 100)",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end    
})

-- Кнопка высокого прыжка
PlayerTab:AddButton({
    Name = "Высокий прыжок (Jump 120)",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 120
    end    
})

-- Кнопка сброса
PlayerTab:AddButton({
    Name = "Вернуть обычные настройки",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end    
})

-- Инициализация
OrionLib:Init()
