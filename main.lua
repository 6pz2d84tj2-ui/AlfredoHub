-- ==========================================
-- 🦫 ALFREDOHUB v1.0 | STEAL AN EGG 🦫
-- ==========================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "🦫 AlfredoHub | Steal an Egg",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "AlfredoConfig",
    IntroEnabled = true,
    IntroText = "Welcome to AlfredoHub!",
    IntroIcon = "rbxassetid://13282218084"
})

-- Глобальные переменные
getgenv().AutoSteal = false
getgenv().AutoTreadmill = false
getgenv().AutoHatch = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Вкладки (Tabs)
local StealTab = Window:MakeTab({
    Name = "Auto Steal",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FarmTab = Window:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ================= AUTO STEAL =================
StealTab:AddSection({ Name = "Steal Options" })

StealTab:AddToggle({
    Name = "Auto Steal Eggs",
    Default = false,
    Callback = function(Value)
        getgenv().AutoSteal = Value
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
})

-- ================= FARMING =================
FarmTab:AddSection({ Name = "Auto Farm" })

FarmTab:AddToggle({
    Name = "Auto Treadmill (Train)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoTreadmill = Value
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
})

-- ================= PLAYER =================
PlayerTab:AddSection({ Name = "Character Movement" })

PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(100, 255, 100),
    Increment = 1,
    ValueName = "Jump",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

OrionLib:Init()
