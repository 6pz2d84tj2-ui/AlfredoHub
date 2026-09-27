-- Drag + клик бобра (фикс)
local btnDownPos = nil
local btnMoved = false
local btnDragging = false

BeaverButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        btnDownPos = input.Position
        btnMoved = false
        btnDragging = true
    end
end)

BeaverButton.InputChanged:Connect(function(input)
    if not btnDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - btnDownPos
        if delta.Magnitude > 12 then
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

-- Используем MouseButton1Up вместо InputEnded — надёжнее
BeaverButton.MouseButton1Up:Connect(function()
    if btnDragging and not btnMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
    btnDragging = false
    btnDownPos = nil
end)

BeaverButton.TouchEnded:Connect(function()
    if btnDragging and not btnMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
    btnDragging = false
    btnDownPos = nil
end)