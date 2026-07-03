--[[ MM2 Premium Utility v5.0 – с прокруткой, ползунками скорости и прыжка, автофарм на каждом раунде ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Состояние
local State = {
    FarmActive = false,
    ESPActive = false,
    AntiFlingActive = false,
    AntiAFKActive = false,
    GUIHidden = false,
    Speed = 22,          -- по умолчанию
    JumpPower = 50,      -- по умолчанию
    Connections = {},
    HighlightInstances = {},
    NameTags = {},
    FarmTask = nil,
    AntiAFKTask = nil,
    AntiFlingConnections = {},
}

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (роли, цвета, ESP) =====
local function IsMurderer(player)
    local char = player.Character
    if not char then return false end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then
            return true
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then
                return true
            end
        end
    end
    return false
end

local function IsSheriff(player)
    local char = player.Character
    if not char then return false end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("sheriff")) then
            return true
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("sheriff")) then
                return true
            end
        end
    end
    return false
end

local function GetPlayerRole(player)
    if player == LocalPlayer then return "Innocent" end
    if IsMurderer(player) then return "Murderer" end
    if IsSheriff(player) then return "Sheriff" end
    return "Innocent"
end

local function GetRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 50, 50) end
    if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end
    return Color3.fromRGB(50, 255, 50)
end

-- ESP
local function UpdateESP()
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.Parent = char
            
            local role = GetPlayerRole(player)
            highlight.FillColor = GetRoleColor(role)
            highlight.OutlineColor = GetRoleColor(role)
            table.insert(State.HighlightInstances, highlight)
            
            local billboard = Instance.new("BillboardGui")
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.Adornee = hrp
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.Parent = char
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = GetRoleColor(role)
            label.TextStrokeTransparency = 0.3
            label.TextSize = 18
            label.Font = Enum.Font.GothamBold
            label.Parent = billboard
            table.insert(State.NameTags, billboard)
        end
    end
end

-- ===== ПОЛНЫЙ СБРОС ФИЗИКИ =====
local function ResetPhysics()
    if not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame
    end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.Massless = false
            part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5, true, 1)
        end
    end
    local humanoid = Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.UseJumpPower = true
        humanoid.Sit = false
        humanoid.AutoRotate = true
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.05)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- ===== AUTO FARM (с использованием State.Speed) =====
local function StartFarm()
    if State.FarmTask then return end

    local function ApplyNoclip(state)
        if not Character then return end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end

    local function SetFlyMode(state)
        if not Character then return end
        local humanoid = Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = state
            humanoid.UseJumpPower = not state
            humanoid.Sit = false
            -- применяем текущий JumpPower
            humanoid.JumpPower = State.JumpPower
        end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Massless = state
                if state then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,false,0)
                else
                    part.CustomPhysicalProperties = PhysicalProperties.new(1,0.3,0.5,true,1)
                end
            end
        end
    end

    ApplyNoclip(true)
    SetFlyMode(true)

    State.FarmTask = RunService.Heartbeat:Connect(function()
        if not State.FarmActive then return end
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then 
            return 
        end
        -- Проверяем, жив ли персонаж (Health > 0)
        local humanoid = Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return
        end

        local hrp = Character.HumanoidRootPart

        -- Поиск монет
        local targetCoin = nil
        local closestDist = math.huge
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money")) then
                if (obj:FindFirstChild("ClickDetector") or obj:FindFirstChild("TouchInterest")) and obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetCoin = obj
                    end
                end
            end
        end

        if targetCoin then
            local targetPos = targetCoin.Position + Vector3.new(0, 2, 0)
            local direction = (targetPos - hrp.Position).Unit
            local distance = (hrp.Position - targetPos).Magnitude

            if distance < 3 then
                hrp.Velocity = Vector3.new(0,0,0)
                local detector = targetCoin:FindFirstChild("ClickDetector")
                if detector then fireclickdetector(detector) end
                hrp.CFrame = CFrame.new(targetCoin.Position + Vector3.new(0,1,0))
            else
                hrp.Velocity = direction * State.Speed  -- используем скорость из ползунка
                hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            end
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end

        ApplyNoclip(true)
        SetFlyMode(true)
    end)
end

-- ===== ANTI‑FLING =====
local function SetCollisionForAllPlayers(enable)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = enable end
        end
    end
    if Character then
        local myhrp = Character:FindFirstChild("HumanoidRootPart")
        if myhrp then myhrp.CanCollide = enable end
    end
end

local function SetupAntiFlingForPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp and State.AntiFlingActive then
            hrp.CanCollide = false
        end
    end)
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and State.AntiFlingActive then
            hrp.CanCollide = false
        end
    end
end

local AntiFlingHeartbeat = nil

local function StartAntiFling()
    if not State.AntiFlingActive then return end

    SetCollisionForAllPlayers(false)

    local playerAddedConn = Players.PlayerAdded:Connect(function(newPlayer)
        SetupAntiFlingForPlayer(newPlayer)
    end)
    table.insert(State.AntiFlingConnections, playerAddedConn)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            SetupAntiFlingForPlayer(player)
        end
    end

    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        if State.AntiFlingActive then
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = false end
        end
    end)
    table.insert(State.AntiFlingConnections, charAddedConn)

    if AntiFlingHeartbeat then AntiFlingHeartbeat:Disconnect() end
    AntiFlingHeartbeat = RunService.Heartbeat:Connect(function()
        if not State.AntiFlingActive then return end
        if not Character then return end
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.Velocity * 0.9
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end)
    table.insert(State.AntiFlingConnections, AntiFlingHeartbeat)
end

local function StopAntiFling()
    SetCollisionForAllPlayers(true)
    for _, conn in ipairs(State.AntiFlingConnections) do
        conn:Disconnect()
    end
    State.AntiFlingConnections = {}
    if AntiFlingHeartbeat then
        AntiFlingHeartbeat:Disconnect()
        AntiFlingHeartbeat = nil
    end
end

-- ===== ANTI‑AFK =====
local function StartAntiAFK()
    if State.AntiAFKTask then return end
    State.AntiAFKActive = true
    State.AntiAFKTask = task.spawn(function()
        while State.AntiAFKActive do
            task.wait(300)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end
--[[ MM2 Premium Utility v5.0 – часть 2 (GUI с прокруткой и ползунками) ]]
-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Utility"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)  -- увеличил высоту
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Фоновое изображение (флаг Казахстана) – замени на свою ссылку
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Kazakhstan.svg/1280px-Flag_of_Kazakhstan.svg.png"
BackgroundImage.ScaleType = Enum.ScaleType.Fit
BackgroundImage.ImageTransparency = 0.25
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

-- Запасной текст
local FallbackText = Instance.new("TextLabel")
FallbackText.Size = UDim2.new(1, 0, 1, 0)
FallbackText.Position = UDim2.new(0, 0, 0, 0)
FallbackText.BackgroundTransparency = 1
FallbackText.Text = "ҚАЗАҚСТАН"
FallbackText.TextColor3 = Color3.fromRGB(0, 150, 255)
FallbackText.TextSize = 40
FallbackText.Font = Enum.Font.GothamBold
FallbackText.TextTransparency = 0.6
FallbackText.ZIndex = 0
FallbackText.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок и кнопки (фиксированные)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Premium"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -75, 0, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
HideBtn.BackgroundTransparency = 0.3
HideBtn.Text = "−"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 22
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = MainFrame
local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ScrollingFrame для содержимого
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -35)  -- отступаем от заголовка
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollFrame.Parent = MainFrame

-- Контейнер для всех элементов внутри ScrollFrame (для удобства вычисления CanvasSize)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = ScrollFrame

-- Счетчик для позиционирования
local yPos = 10

-- Функция создания переключателей (теперь добавляем в Content)
local function CreateToggle(name, label, stateVar)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = Content
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 24)
    btn.Position = UDim2.new(1, -70, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        State[stateVar] = not State[stateVar]
        if State[stateVar] then
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            btn.Text = "ON"
            if stateVar == "FarmActive" then StartFarm() end
            if stateVar == "ESPActive" then UpdateESP() end
            if stateVar == "AntiFlingActive" then StartAntiFling() end
            if stateVar == "AntiAFKActive" then StartAntiAFK() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if stateVar == "FarmActive" then
                if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
                ResetPhysics()
            end
            if stateVar == "ESPActive" then
                for _, v in pairs(State.HighlightInstances) do v:Destroy() end
                for _, v in pairs(State.NameTags) do v:Destroy() end
                State.HighlightInstances = {}
                State.NameTags = {}
            end
            if stateVar == "AntiFlingActive" then StopAntiFling() end
            if stateVar == "AntiAFKActive" then
                State.AntiAFKActive = false
                if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
            end
        end
    end)
    
    yPos = yPos + 35
    return frame
end

-- Создаём тоглы
CreateToggle("FarmActive", "Auto Farm", "FarmActive")
CreateToggle("ESPActive", "ESP Wallhack", "ESPActive")
CreateToggle("AntiFlingActive", "Anti-Fling", "AntiFlingActive")
CreateToggle("AntiAFKActive", "Anti-AFK", "AntiAFKActive")

-- ===== ПОЛЗУНКИ =====

-- Функция создания ползунка
local function CreateSlider(label, minVal, maxVal, step, stateKey, format)
    -- label - текст над ползунком
    -- stateKey - ключ в State, например "Speed" или "JumpPower"
    -- format - функция форматирования значения (например, "%.1f")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    -- Текст с названием и значением
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. string.format(format or "%.1f", State[stateKey])
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    -- Фон ползунка
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg

    -- Заполненная часть (индикатор)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Кнопка-ползунок
    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, -9, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderBg
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    -- Переменные для перетаскивания
    local dragging = false
    local thumbPos = 0  -- от 0 до 1

    -- Функция обновления позиции thumb и fill
    local function UpdateSlider(value)
        local clamped = math.clamp(value, minVal, maxVal)
        local rounded = math.round(clamped / step) * step
        State[stateKey] = rounded
        local ratio = (rounded - minVal) / (maxVal - minVal)
        thumbPos = ratio
        thumb.Position = UDim2.new(ratio, -9, 0.5, -9)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        lbl.Text = label .. ": " .. string.format(format or "%.1f", rounded)
        -- Применяем JumpPower сразу
        if stateKey == "JumpPower" then
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.JumpPower = rounded
            end
        end
    end

    -- Инициализация
    UpdateSlider(State[stateKey])

    -- Обработка ввода на thumb
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            -- вычисляем начальную позицию мыши относительно thumb
        end
    end)

    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Обработка движения мыши (на любом объекте, чтобы не терять)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local pos = input.Position
            -- Переводим в координаты sliderBg
            local absPos = sliderBg.AbsolutePosition
            local sizeX = sliderBg.AbsoluteSize.X
            local relativeX = math.clamp((pos.X - absPos.X) / sizeX, 0, 1)
            local value = minVal + relativeX * (maxVal - minVal)
            UpdateSlider(value)
        end
    end)

    -- Также клик по фону для быстрой установки
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging then
                local pos = input.Position
                local absPos = sliderBg.AbsolutePosition
                local sizeX = sliderBg.AbsoluteSize.X
                local relativeX = math.clamp((pos.X - absPos.X) / sizeX, 0, 1)
                local value = minVal + relativeX * (maxVal - minVal)
                UpdateSlider(value)
            end
        end
    end)

    yPos = yPos + 60
    return frame
end

-- Создаём ползунки
CreateSlider("Speed (Fly)", 0, 30, 0.5, "Speed", "%.1f")
CreateSlider("Jump Power", 0, 200, 1, "JumpPower", "%.0f")

-- Обновляем CanvasSize
local function UpdateCanvas()
    local totalHeight = yPos + 20
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    Content.Size = UDim2.new(1, 0, 0, totalHeight)
end
UpdateCanvas()

-- ===== Кнопка Show (плавающая) =====
local ShowButtonGui = Instance.new("ScreenGui")
ShowButtonGui.Name = "ShowButton"
ShowButtonGui.ResetOnSpawn = false
ShowButtonGui.Enabled = false
ShowButtonGui.Parent = PlayerGui

local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0, 50, 0, 50)
ShowBtn.Position = UDim2.new(0.9, -25, 0.9, -25)
ShowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ShowBtn.BackgroundTransparency = 0.2
ShowBtn.Text = "M"
ShowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowBtn.TextSize = 24
ShowBtn.Font = Enum.Font.GothamBold
ShowBtn.Parent = ShowButtonGui
local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius = UDim.new(1, 0)
ShowCorner.Parent = ShowBtn

local ShowDrag = false
local ShowDragStart, ShowDragStartPos
ShowBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ShowDrag = true
        ShowDragStart = input.Position
        ShowDragStartPos = ShowBtn.Position
    end
end)
ShowBtn.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and ShowDrag then
        local delta = input.Position - ShowDragStart
        ShowBtn.Position = UDim2.new(
            ShowDragStartPos.X.Scale,
            ShowDragStartPos.X.Offset + delta.X,
            ShowDragStartPos.Y.Scale,
            ShowDragStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ShowDrag = false
    end
end)

local function HideGUI()
    State.GUIHidden = true
    ScreenGui.Enabled = false
    ShowButtonGui.Enabled = true
end

local function ShowGUI()
    State.GUIHidden = false
    ScreenGui.Enabled = true
    ShowButtonGui.Enabled = false
end

HideBtn.MouseButton1Click:Connect(HideGUI)
ShowBtn.MouseButton1Click:Connect(ShowGUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Minus then
        if State.GUIHidden then ShowGUI() else HideGUI() end
    end
end)

-- Закрытие
CloseBtn.MouseButton1Click:Connect(function()
    State.FarmActive = false
    State.ESPActive = false
    State.AntiFlingActive = false
    State.AntiAFKActive = false
    
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
    
    StopAntiFling()
    ResetPhysics()
    
    for _, conn in ipairs(State.Connections) do conn:Disconnect() end
    State.Connections = {}
    
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}
    
    ScreenGui:Destroy()
    ShowButtonGui:Destroy()
end)

-- Автообновление ESP
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if State.ESPActive then UpdateESP() end
        task.wait(2)
    end
end)

-- Обработка респавна персонажа
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    -- Применяем текущий JumpPower к новому персонажу
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = State.JumpPower
    end
    if State.FarmActive then
        if State.FarmTask then State.FarmTask:Disconnect() end
        StartFarm()
    end
    if State.AntiFlingActive then
        task.wait(0.5)
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = false end
    end
end)

print("[good]: MM2 Premium v5.0 загружен. Прокрутка, ползунки, автофарм на каждом раунде.")
