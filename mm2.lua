-- ЧАСТЬ 1: ОСНОВНОЙ ИНТЕРФЕЙС (фикс перетаскивания, новая позиция)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function makeDraggable(object, onClick)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local moved = false

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = object.Position
        end
    end)

    object.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then moved = true end
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    object.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not moved and onClick then onClick() end
            dragging = false
        end
    end)
end

local hubGui = Instance.new("ScreenGui")
hubGui.Name = "MM2UltraHub"
hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubGui.ResetOnSpawn = false
hubGui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(1, -180, 0.4, 0) -- справа, чуть выше середины
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = Color3.fromRGB(200, 200, 220)
toggleButton.Text = "MM2 ULTRA HUB v1.0"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 10)
cornerToggle.Parent = toggleButton
toggleButton.Parent = hubGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 320)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(180, 180, 200)
mainFrame.Visible = false
local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 14)
cornerMain.Parent = mainFrame
mainFrame.Parent = hubGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "MM2 ULTRA HUB v1.0"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Передаём функцию открытия/закрытия при клике (без перетаскивания)
makeDraggable(toggleButton, function()
    mainFrame.Visible = not mainFrame.Visible
end)

print("[GOOD] Часть 1 загружена. Вставляй часть 2.")
-- ЧАСТЬ 2: КРЕСТ (теперь "X") И ПОДТВЕРЖДЕНИЕ
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -44, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.BorderSizePixel = 2
closeButton.BorderColor3 = Color3.fromRGB(255, 120, 120)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(0, 8)
cornerClose.Parent = closeButton
closeButton.Parent = mainFrame

local confirmFrame = Instance.new("Frame")
confirmFrame.Name = "ConfirmFrame"
confirmFrame.Size = UDim2.new(0, 280, 0, 120)
confirmFrame.Position = UDim2.new(0.5, -140, 0.5, -60)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
confirmFrame.BorderSizePixel = 2
confirmFrame.BorderColor3 = Color3.fromRGB(200, 200, 220)
confirmFrame.Visible = false
local cornerConfirm = Instance.new("UICorner")
cornerConfirm.CornerRadius = UDim.new(0, 14)
cornerConfirm.Parent = confirmFrame
confirmFrame.Parent = mainFrame

local confirmLabel = Instance.new("TextLabel")
confirmLabel.Size = UDim2.new(1, -20, 0, 30)
confirmLabel.Position = UDim2.new(0, 10, 0, 8)
confirmLabel.BackgroundTransparency = 1
confirmLabel.Text = "Закрыть хаб?"
confirmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmLabel.TextScaled = true
confirmLabel.Font = Enum.Font.GothamBold
confirmLabel.TextXAlignment = Enum.TextXAlignment.Center
confirmLabel.Parent = confirmFrame

local confirmYes = Instance.new("TextButton")
confirmYes.Size = UDim2.new(0, 100, 0, 35)
confirmYes.Position = UDim2.new(0, 20, 1, -45)
confirmYes.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
confirmYes.BorderSizePixel = 1
confirmYes.BorderColor3 = Color3.fromRGB(255, 80, 80)
confirmYes.Text = "Закрыть"
confirmYes.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmYes.TextScaled = true
confirmYes.Font = Enum.Font.GothamBold
local cornerYes = Instance.new("UICorner")
cornerYes.CornerRadius = UDim.new(0, 8)
cornerYes.Parent = confirmYes
confirmYes.Parent = confirmFrame

local confirmNo = Instance.new("TextButton")
confirmNo.Size = UDim2.new(0, 100, 0, 35)
confirmNo.Position = UDim2.new(1, -120, 1, -45)
confirmNo.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
confirmNo.BorderSizePixel = 1
confirmNo.BorderColor3 = Color3.fromRGB(180, 180, 200)
confirmNo.Text = "Отмена"
confirmNo.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmNo.TextScaled = true
confirmNo.Font = Enum.Font.GothamBold
local cornerNo = Instance.new("UICorner")
cornerNo.CornerRadius = UDim.new(0, 8)
cornerNo.Parent = confirmNo
confirmNo.Parent = confirmFrame

local function showConfirm()
    confirmFrame.Visible = true
end
local function hideConfirm()
    confirmFrame.Visible = false
end

closeButton.MouseButton1Click:Connect(showConfirm)
confirmNo.MouseButton1Click:Connect(hideConfirm)

confirmYes.MouseButton1Click:Connect(function()
    print("[GOOD] Отключение всех функций и закрытие хаба.")
    hubGui:Destroy()
end)

print("[GOOD] Часть 2 загружена. Хаб полностью готов.")
