-- AlfredoHub Simple & Stable Core
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🦫 AlfredoHub v1.0",
    Text = "AlfredoHub successfully loaded!",
    Duration = 5
})

-- Screen UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedBtn = Instance.new("TextButton")
local ChilliBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "AlfredoHubUI"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 220, 0, 170)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "🦫 AlfredoHub | Steal an Egg"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- Button 1: Speed
SpeedBtn.Parent = Frame
SpeedBtn.Text = "Set Speed (100)"
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
end)

-- Button 2: Run Chilli
ChilliBtn.Parent = Frame
ChilliBtn.Text = "Run Chilli Hub (AutoSteal)"
ChilliBtn.Size = UDim2.new(0.9, 0, 0, 35)
ChilliBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
ChilliBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ChilliBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChilliBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()
end)

-- Button 3: Close
CloseBtn.Parent = Frame
CloseBtn.Text = "Close Menu"
CloseBtn.Size = UDim2.new(0.9, 0, 0, 25)
CloseBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

