--[[ MM2 Premium Utility v9.0 – максимально простой автофарм, без условий ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local State = {
    FarmActive = false,
    ESPActive = false,
    AntiFlingActive = false,
    AntiAFKActive = false,
    GUIHidden = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 22,
    Noclip = false,
    Connections = {},
    HighlightInstances = {},
    NameTags = {},
    FarmTask = nil,
    AntiAFKTask = nil,
    AntiFlingConnections = {},
    NoclipHeartbeat = nil,
}

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (роли, цвета) =====
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
local function ApplyNoclip(state)
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function StartNoclipHeartbeat()
    if State.NoclipHeartbeat then return end
    State.NoclipHeartbeat = RunService.Heartbeat:Connect(function()
        if State.Noclip then
            ApplyNoclip(true)
        end
    end)
end

local function StopNoclipHeartbeat()
    if State.NoclipHeartbeat then
        State.NoclipHeartbeat:Disconnect()
        State.NoclipHeartbeat = nil
    end
    ApplyNoclip(false)
end
-- ===== АВТОФАРМ (без остановок, без проверок) =====
local function StartFarm()
    if State.FarmTask then return end

    State.FarmTask = RunService.Heartbeat:Connect(function()
        if not State.FarmActive then
            return
        end

        -- Проверяем наличие персонажа и HRP
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local hrp = Character.HumanoidRootPart

        -- Принудительно включаем Noclip и облегчаем физику
        hrp.CanCollide = false
        hrp.Massless = true
        hrp.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,false,0)
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then
                part.CanCollide = false
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,false,0)
            end
        end
        local humanoid = Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            humanoid.UseJumpPower = false
            humanoid.Sit = false
            humanoid.WalkSpeed = 0
        end

        -- Поиск монеты
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
                if detector then
                    fireclickdetector(detector)
                end
                hrp.CFrame = CFrame.new(targetCoin.Position + Vector3.new(0,1,0))
            else
                hrp.Velocity = direction * State.FlySpeed
                hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            end
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end
-- ===== ANTI‑FLING (без изменений) =====
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

-- ===== GUI (полностью как в v8, но убрал восстановление физики при выключении фарма) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Utility"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 40, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(68, 255, 136)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Фон (флаг Казахстана)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Kazakhstan.svg/1280px-Flag_of_Kazakhstan.svg.png"
BackgroundImage.ScaleType = Enum.ScaleType.Fit
BackgroundImage.ImageTransparency = 0.85
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

-- Заголовок и кнопки
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Premium"
Title.TextColor3 = Color3.fromRGB(68, 255, 136)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

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

-- Панель вкладок
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

-- ScrollingFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -90)
ScrollFrame.Position = UDim2.new(0, 0, 0, 90)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(68, 255, 136)
ScrollFrame.Parent = MainFrame

local PlayerPanel = Instance.new("Frame")
PlayerPanel.Size = UDim2.new(1, 0, 0, 0)
PlayerPanel.BackgroundTransparency = 1
PlayerPanel.Parent = ScrollFrame

local GeneralPanel = Instance.new("Frame")
GeneralPanel.Size = UDim2.new(1, 0, 0, 0)
GeneralPanel.BackgroundTransparency = 1
GeneralPanel.Parent = ScrollFrame
GeneralPanel.Visible = false

local function UpdateCanvas()
    local ph, gh = 0, 0
    for _, c in ipairs(PlayerPanel:GetChildren()) do
        if c:IsA("Frame") then
            local y = c.Position.Y.Offset + c.Size.Y.Offset
            if y > ph then ph = y end
        end
    end
    for _, c in ipairs(GeneralPanel:GetChildren()) do
        if c:IsA("Frame") then
            local y = c.Position.Y.Offset + c.Size.Y.Offset
            if y > gh then gh = y end
        end
    end
    PlayerPanel.Size = UDim2.new(1, 0, 0, ph + 20)
    GeneralPanel.Size = UDim2.new(1, 0, 0, gh + 20)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(ph, gh) + 20)
end

-- Вспомогательные функции для создания элементов
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

local function CreateToggleInPanel(panel, label, stateVar, yPos, onFunc, offFunc)
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

-- Заполнение PlayerPanel
local yPosP = 10
local _, yPosP = CreateSliderInPanel(PlayerPanel, "Walk Speed", 0, 50, 0.5, "WalkSpeed", "%.1f", function(val)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = val
    end
end, yPosP)
local _, yPosP = CreateSliderInPanel(PlayerPanel, "Jump Power", 0, 200, 1, "JumpPower", "%.0f", function(val)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = val
    end
end, yPosP)
local _, yPosP = CreateSliderInPanel(PlayerPanel, "Fly Speed", 1, 50, 0.5, "FlySpeed", "%.1f", nil, yPosP)
local _, yPosP = CreateToggleInPanel(PlayerPanel, "Noclip", "Noclip", yPosP, function()
    StartNoclipHeartbeat()
    ApplyNoclip(true)
end, function()
    StopNoclipHeartbeat()
end)

-- Заполнение GeneralPanel
local yPosG = 10
local _, yPosG = CreateToggleInPanel(GeneralPanel, "Auto Farm", "FarmActive", yPosG, function()
    StartFarm()
end, function()
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    -- Не восстанавливаем физику!
end)
local _, yPosG = CreateToggleInPanel(GeneralPanel, "ESP Wallhack", "ESPActive", yPosG, UpdateESP, function()
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}
end)
local _, yPosG = CreateToggleInPanel(GeneralPanel, "Anti-Fling", "AntiFlingActive", yPosG, StartAntiFling, StopAntiFling)
local _, yPosG = CreateToggleInPanel(GeneralPanel, "Anti-AFK", "AntiAFKActive", yPosG, StartAntiAFK, function()
    State.AntiAFKActive = false
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
end)

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
ShowTab("Player")

-- Плавающая кнопка Show
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
    
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
    
    StopAntiFling()
    StopNoclipHeartbeat()
    
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
    end
    if State.Noclip then
        StartNoclipHeartbeat()
        ApplyNoclip(true)
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

print("[good]: MM2 Premium v9.0 – максимально простой автофарм, без восстановления физики.")
