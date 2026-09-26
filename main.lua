-- AlfredoHub Loader (поверх Chilli)
-- Фон-бобёр
local sg = Instance.new("ScreenGui")
sg.Name = "AlfredoBg"
sg.IgnoreGuiInset = true
sg.DisplayOrder = 0
if gethui then sg.Parent = gethui() else sg.Parent = game:GetService("CoreGui") end

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://131493629"  -- бобёр
bg.ImageTransparency = 0.5
bg.ScaleType = Enum.ScaleType.Crop
bg.Parent = sg

-- Надпись AlfredoHub поверх окна Chilli
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 400, 0, 40)
title.Position = UDim2.new(0.5, -200, 0, 10)
title.BackgroundTransparency = 1
title.Text = "AlfredoHub"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextStrokeTransparency = 0
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = sg

-- Загрузка Chilli (обфусцированного)
loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()