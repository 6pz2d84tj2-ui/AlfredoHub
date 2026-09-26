--[[
    AlfredoHub for "Steal an Egg"
    UI Library: Rayfield (https://sirius.menu/rayfield)
    Features:
    - Auto Steal Eggs
    - Auto Treadmill
    - WalkSpeed / JumpPower Sliders
    - Infinite Jump
    - FPS Booster
    - Rejoin Server
]]

--================================================================================
-- RAYFIELD UI LOADING
--================================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AlfredoHub | Steal an Egg",
   Icon = 0,
   LoadingTitle = "AlfredoHub",
   LoadingSubtitle = "by Expert",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AlfredoHub",
      FileName = "StealAnEgg"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false,
})

--================================================================================
-- GLOBAL STATE
--================================================================================
getgenv().AutoSteal = false
getgenv().AutoTreadmill = false
getgenv().InfiniteJump = false

--================================================================================
-- TAB 1: AUTO STEAL
--================================================================================
local AutoStealTab = Window:CreateTab("Auto Steal", 0)

AutoStealTab:CreateSection("Egg Automation")

AutoStealTab:CreateToggle({
    Name = "Auto Steal Eggs",
    CurrentValue = false,
    Flag = "AutoStealEggs",
    Callback = function(Value)
        getgenv().AutoSteal = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoSteal do
                    pcall(function()
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if not getgenv().AutoSteal then break end
                            if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
                                if firetouchinterest then
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 0)
                                    task.wait()
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 1)
                                elseif firetouchinterest then
                                    firetouchinterest(obj, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                                    task.wait()
                                    firetouchinterest(obj, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
            Rayfield:Notify({
                Title = "Auto Steal",
                Content = "Auto Steal Eggs: ENABLED",
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Auto Steal",
                Content = "Auto Steal Eggs: DISABLED",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

--================================================================================
-- TAB 2: FARMING
--================================================================================
local FarmingTab = Window:CreateTab("Farming", 0)

FarmingTab:CreateSection("Treadmill Automation")

FarmingTab:CreateToggle({
    Name = "Auto Treadmill",
    CurrentValue = false,
    Flag = "AutoTreadmill",
    Callback = function(Value)
        getgenv().AutoTreadmill = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoTreadmill do
                    pcall(function()
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if not getgenv().AutoTreadmill then break end
                            if obj:IsA("BasePart") and obj.Name:lower():find("treadmill") then
                                if firetouchinterest then
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 0)
                                    task.wait()
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 1)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
            Rayfield:Notify({
                Title = "Farming",
                Content = "Auto Treadmill: ENABLED",
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Farming",
                Content = "Auto Treadmill: DISABLED",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

--================================================================================
-- TAB 3: PLAYER
--================================================================================
local PlayerTab = Window:CreateTab("Player", 0)

PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
            end
        end)
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").UseJumpPower = true
                char:FindFirstChildOfClass("Humanoid").JumpPower = Value
            end
        end)
    end,
})

PlayerTab:CreateSection("Misc")

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        getgenv().InfiniteJump = Value
        if Value then
            task.spawn(function()
                while getgenv().InfiniteJump do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChildOfClass("Humanoid") then
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
            Rayfield:Notify({
                Title = "Player",
                Content = "Infinite Jump: ENABLED",
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Player",
                Content = "Infinite Jump: DISABLED",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

--================================================================================
-- TAB 4: VISUALS & UTILS
--================================================================================
local VisualsTab = Window:CreateTab("Visuals & Utils", 0)

VisualsTab:CreateSection("Performance")

VisualsTab:CreateButton({
    Name = "FPS Booster",
    Callback = function()
        pcall(function()
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") then
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("Lighting") then
                    obj.GlobalShadows = false
                    obj.FogEnd = 100000
                end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = 1
            settings().Rendering.SavedQualityLevel = 1
        end)
        Rayfield:Notify({
            Title = "FPS Booster",
            Content = "Graphics lowered & effects removed.",
            Duration = 4,
            Image = 4483362458,
        })
    end,
})

VisualsTab:CreateSection("Server")

VisualsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function()
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end)
    end,
})

--================================================================================
-- NOTIFICATION: HUB LOADED
--================================================================================
Rayfield:Notify({
    Title = "AlfredoHub",
    Content = "Steal an Egg script loaded successfully.",
    Duration = 5,
    Image = 4483362458,
})