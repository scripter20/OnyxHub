--[[ MM2 Premium Utility v6.0 – зелёная тема, вкладки Player/General ]]
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
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfiniteJump = false,
    Connections = {},
    HighlightInstances = {},
    NameTags = {},
    FarmTask = nil,
    AntiAFKTask = nil,
    AntiFlingConnections = {},
    InfiniteJumpConnection = nil,
    OriginalJumpPower = 50,
}

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
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

-- ===== NOCLIP =====
local function SetNoclip(state)
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- ===== INFINITE JUMP =====
local function SetupInfiniteJump(enable)
    if enable then
        if State.InfiniteJumpConnection then return end
        State.OriginalJumpPower = State.JumpPower
        -- Сохраняем оригинальный JumpPower
        if Character and Character:FindFirstChild("Humanoid") then
            State.OriginalJumpPower = Character.Humanoid.JumpPower
            Character.Humanoid.JumpPower = 9999
        end
        -- Подписываемся на нажатие пробела
        State.InfiniteJumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Space and State.InfiniteJump then
                local humanoid = Character and Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if State.InfiniteJumpConnection then
            State.InfiniteJumpConnection:Disconnect()
            State.InfiniteJumpConnection = nil
        end
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = State.OriginalJumpPower
        end
    end
end

-- ===== СБРОС ФИЗИКИ =====
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
        humanoid.WalkSpeed = State.WalkSpeed
        humanoid.JumpPower = State.JumpPower
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.05)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- ===== AUTO FARM (только по кнопке) =====
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
            humanoid.WalkSpeed = State.WalkSpeed
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
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
        local humanoid = Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        local hrp = Character.HumanoidRootPart

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
                hrp.Velocity = direction * 22
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
--[[ MM2 Premium Utility v6.0 – часть 2 (GUI с вкладками) ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Utility"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 40, 25) -- тёмно-зелёный
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление и тень (тень через дополнительный кастом, но для простоты используем UIStroke)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(68, 255, 136) -- ярко-зелёный
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Фоновое изображение (флаг Казахстана – оставлю, но можно убрать)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Kazakhstan.svg/1280px-Flag_of_Kazakhstan.svg.png"
BackgroundImage.ScaleType = Enum.ScaleType.Fit
BackgroundImage.ImageTransparency = 0.85 -- почти прозрачный, чтобы не мешать
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Premium"
Title.TextColor3 = Color3.fromRGB(68, 255, 136) -- ярко-зелёный
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка Hide
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 32, 0, 32)
HideBtn.Position = UDim2.new(1, -78, 0, 4)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 50)
HideBtn.BackgroundTransparency = 0.5
HideBtn.Text = "−"
HideBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
HideBtn.TextSize = 24
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = MainFrame
local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideBtn

-- Кнопка Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Панель вкладок (кнопки переключения)
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -20, 0, 40)
TabsFrame.Position = UDim2.new(0, 10, 0, 45)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local TabPlayer = Instance.new("TextButton")
TabPlayer.Size = UDim2.new(0.5, -5, 1, 0)
TabPlayer.Position = UDim2.new(0, 0, 0, 0)
TabPlayer.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
TabPlayer.BackgroundTransparency = 0.3
TabPlayer.Text = "Player"
TabPlayer.TextColor3 = Color3.fromRGB(200, 255, 200)
TabPlayer.TextSize = 16
TabPlayer.Font = Enum.Font.GothamBold
TabPlayer.Parent = TabsFrame
local TabCorner1 = Instance.new("UICorner")
TabCorner1.CornerRadius = UDim.new(0, 8)
TabCorner1.Parent = TabPlayer

local TabGeneral = Instance.new("TextButton")
TabGeneral.Size = UDim2.new(0.5, -5, 1, 0)
TabGeneral.Position = UDim2.new(0.5, 5, 0, 0)
TabGeneral.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
TabGeneral.BackgroundTransparency = 0.3
TabGeneral.Text = "General"
TabGeneral.TextColor3 = Color3.fromRGB(200, 255, 200)
TabGeneral.TextSize = 16
TabGeneral.Font = Enum.Font.GothamBold
TabGeneral.Parent = TabsFrame
local TabCorner2 = Instance.new("UICorner")
TabCorner2.CornerRadius = UDim.new(0, 8)
TabCorner2.Parent = TabGeneral

-- Контейнер для содержимого вкладок (ScrollingFrame)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -90)
ScrollFrame.Position = UDim2.new(0, 0, 0, 90)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(68, 255, 136)
ScrollFrame.Parent = MainFrame

-- Две панели для каждой вкладки (будут находиться внутри ScrollFrame)
local PlayerPanel = Instance.new("Frame")
PlayerPanel.Size = UDim2.new(1, 0, 0, 0)
PlayerPanel.BackgroundTransparency = 1
PlayerPanel.Parent = ScrollFrame

local GeneralPanel = Instance.new("Frame")
GeneralPanel.Size = UDim2.new(1, 0, 0, 0)
GeneralPanel.BackgroundTransparency = 1
GeneralPanel.Parent = ScrollFrame
GeneralPanel.Visible = false

-- Функция обновления Canvas
local function UpdateCanvas()
    local playerHeight = 0
    local generalHeight = 0
    -- Считаем высоту PlayerPanel
    for _, child in ipairs(PlayerPanel:GetChildren()) do
        if child:IsA("Frame") then
            local pos = child.Position.Y.Offset + child.Size.Y.Offset
            if pos > playerHeight then playerHeight = pos end
        end
    end
    -- Считаем высоту GeneralPanel
    for _, child in ipairs(GeneralPanel:GetChildren()) do
        if child:IsA("Frame") then
            local pos = child.Position.Y.Offset + child.Size.Y.Offset
            if pos > generalHeight then generalHeight = pos end
        end
    end
    -- Устанавливаем высоту панелей и Canvas
    PlayerPanel.Size = UDim2.new(1, 0, 0, playerHeight + 20)
    GeneralPanel.Size = UDim2.new(1, 0, 0, generalHeight + 20)
    local maxHeight = math.max(playerHeight, generalHeight) + 20
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
end

-- Создание элементов для PlayerPanel
local yPosP = 10

-- WalkSpeed ползунок
local function CreateSliderInPanel(panel, label, minVal, maxVal, step, stateKey, format, applyFunc, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = panel

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. string.format(format or "%.1f", State[stateKey])
    lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 70, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, -9, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(200, 255, 200)
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderBg
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local dragging = false

    local function UpdateSlider(value)
        local clamped = math.clamp(value, minVal, maxVal)
        local rounded = math.round(clamped / step) * step
        State[stateKey] = rounded
        local ratio = (rounded - minVal) / (maxVal - minVal)
        thumb.Position = UDim2.new(ratio, -9, 0.5, -9)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        lbl.Text = label .. ": " .. string.format(format or "%.1f", rounded)
        if applyFunc then applyFunc(rounded) end
    end

    UpdateSlider(State[stateKey])

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local pos = input.Position
            local absPos = sliderBg.AbsolutePosition
            local sizeX = sliderBg.AbsoluteSize.X
            local relativeX = math.clamp((pos.X - absPos.X) / sizeX, 0, 1)
            local value = minVal + relativeX * (maxVal - minVal)
            UpdateSlider(value)
        end
    end)
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

    return frame, yPos + 60
end

-- Функция создания тогла в панели
local function CreateToggleInPanel(panel, label, stateVar, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = panel

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 160, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
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

    -- Храним ссылку на btn в State для возможности обновления при включении Noclip/InfJump
    btn.MouseButton1Click:Connect(function()
        State[stateVar] = not State[stateVar]
        if State[stateVar] then
            btn.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
            btn.Text = "ON"
            -- Действия при включении
            if stateVar == "Noclip" then
                SetNoclip(true)
            elseif stateVar == "InfiniteJump" then
                SetupInfiniteJump(true)
            end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if stateVar == "Noclip" then
                SetNoclip(false)
            elseif stateVar == "InfiniteJump" then
                SetupInfiniteJump(false)
            end
        end
    end)

    return frame, yPos + 35
end

-- Заполняем PlayerPanel
local yPosP = 10
local slW, yPosP = CreateSliderInPanel(PlayerPanel, "Walk Speed", 0, 30, 0.5, "WalkSpeed", "%.1f", function(val)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = val
    end
end, yPosP)

local slJ, yPosP = CreateSliderInPanel(PlayerPanel, "Jump Power", 0, 200, 1, "JumpPower", "%.0f", function(val)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = val
        State.OriginalJumpPower = val
    end
end, yPosP)

local togN, yPosP = CreateToggleInPanel(PlayerPanel, "Noclip", "Noclip", yPosP)
local togI, yPosP = CreateToggleInPanel(PlayerPanel, "Infinite Jump", "InfiniteJump", yPosP)

-- Заполняем GeneralPanel
local yPosG = 10
-- Автофарм
local function CreateGeneralToggle(label, stateVar, yPos, onFunc, offFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = GeneralPanel

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 160, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
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
            btn.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
            btn.Text = "ON"
            if onFunc then onFunc() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if offFunc then offFunc() end
        end
    end)

    return frame, yPos + 35
end

local _, yPosG = CreateGeneralToggle("Auto Farm", "FarmActive", yPosG, StartFarm, function()
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    ResetPhysics()
end)

local _, yPosG = CreateGeneralToggle("ESP Wallhack", "ESPActive", yPosG, UpdateESP, function()
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}
end)

local _, yPosG = CreateGeneralToggle("Anti-Fling", "AntiFlingActive", yPosG, StartAntiFling, StopAntiFling)

local _, yPosG = CreateGeneralToggle("Anti-AFK", "AntiAFKActive", yPosG, StartAntiAFK, function()
    State.AntiAFKActive = false
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
end)

-- Обновляем Canvas после создания всех элементов
UpdateCanvas()

-- Переключение вкладок
local function ShowTab(tab)
    if tab == "Player" then
        PlayerPanel.Visible = true
        GeneralPanel.Visible = false
        TabPlayer.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
        TabPlayer.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabGeneral.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
        TabGeneral.TextColor3 = Color3.fromRGB(200, 255, 200)
    else
        PlayerPanel.Visible = false
        GeneralPanel.Visible = true
        TabGeneral.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
        TabGeneral.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabPlayer.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
        TabPlayer.TextColor3 = Color3.fromRGB(200, 255, 200)
    end
    UpdateCanvas()
end

TabPlayer.MouseButton1Click:Connect(function() ShowTab("Player") end)
TabGeneral.MouseButton1Click:Connect(function() ShowTab("General") end)

-- По умолчанию показываем Player
ShowTab("Player")

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
ShowBtn.TextColor3 = Color3.fromRGB(68, 255, 136)
ShowBtn.TextSize = 28
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
    State.Noclip = false
    State.InfiniteJump = false
    
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
    if State.InfiniteJumpConnection then State.InfiniteJumpConnection:Disconnect(); State.InfiniteJumpConnection = nil end
    
    StopAntiFling()
    SetNoclip(false)
    SetupInfiniteJump(false)
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
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = State.WalkSpeed
        Character.Humanoid.JumpPower = State.JumpPower
        State.OriginalJumpPower = State.JumpPower
    end
    if State.Noclip then SetNoclip(true) end
    if State.InfiniteJump then SetupInfiniteJump(true) end
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

print("[good]: MM2 Premium v6.0 – зелёная тема, вкладки Player/General, Noclip, Infinite Jump загружены.")
