--[[ MM2 PutinHub v2.1 – часть 1 ]]
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
    SpeedToggle = false,
    JumpToggle = false,
    SpeedValue = 16,
    JumpValue = 50,
    DefaultSpeed = 16,
    DefaultJump = 50,
    FarmTask = nil,
    AntiAFKTask = nil,
    SpeedHeartbeat = nil,
    Connections = {},
    HighlightInstances = {},
    NameTags = {},
    AntiFlingConnections = {},
}

-- === РОЛИ ===
local function IsMurderer(p)
    local c = p.Character
    if not c then return false end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then return true end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, v in ipairs(bp:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then return true end
        end
    end
    return false
end

local function IsSheriff(p)
    local c = p.Character
    if not c then return false end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("sheriff")) then return true end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, v in ipairs(bp:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("sheriff")) then return true end
        end
    end
    return false
end

local function GetRole(p)
    if p == LocalPlayer then return "Innocent" end
    if IsMurderer(p) then return "Murderer" end
    if IsSheriff(p) then return "Sheriff" end
    return "Innocent"
end

local function RoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255,50,50) end
    if role == "Sheriff" then return Color3.fromRGB(50,150,255) end
    return Color3.fromRGB(50,255,50)
end

-- === ESP ===
local function UpdateESP()
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local c = p.Character
            local hrp = c.HumanoidRootPart
            local role = GetRole(p)
            local col = RoleColor(role)

            local h = Instance.new("Highlight")
            h.Adornee = c
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Enabled = true
            h.FillColor = col
            h.OutlineColor = col
            h.Parent = c
            table.insert(State.HighlightInstances, h)

            local b = Instance.new("BillboardGui")
            b.AlwaysOnTop = true
            b.Size = UDim2.new(0,200,0,50)
            b.Adornee = hrp
            b.StudsOffset = Vector3.new(0,3.5,0)
            b.Parent = c
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.Text = p.Name
            l.TextColor3 = col
            l.TextStrokeTransparency = 0.3
            l.TextSize = 18
            l.Font = Enum.Font.GothamBold
            l.Parent = b
            table.insert(State.NameTags, b)
        end
    end
end

-- === SPEED ===
local function ApplySpeed()
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = State.SpeedValue
    end
end

local function StartSpeedHeartbeat()
    if State.SpeedHeartbeat then return end
    State.SpeedHeartbeat = RunService.Heartbeat:Connect(function()
        if State.SpeedToggle then
            ApplySpeed()
        end
    end)
end

local function StopSpeedHeartbeat()
    if State.SpeedHeartbeat then
        State.SpeedHeartbeat:Disconnect()
        State.SpeedHeartbeat = nil
    end
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = State.DefaultSpeed
    end
end

-- === JUMP ===
local function ApplyJump()
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = State.JumpValue
    end
end

-- === AUTOFARM ===
local function StartFarm()
    if State.FarmTask then return end

    State.FarmTask = RunService.Heartbeat:Connect(function()
        if not State.FarmActive then return end
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

        local hrp = Character.HumanoidRootPart
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
        local hum = Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = true
            hum.UseJumpPower = false
            hum.Sit = false
            hum.WalkSpeed = 0
        end

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
                local det = targetCoin:FindFirstChild("ClickDetector")
                if det then fireclickdetector(det) end
                hrp.CFrame = CFrame.new(targetCoin.Position + Vector3.new(0,1,0))
            else
                hrp.Velocity = direction * 22
                hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            end
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

-- === ANTI‑FLING ===
local function SetCollisionAll(enable)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = enable end
        end
    end
    if Character then
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = enable end
    end
end

local flingHeartbeat = nil

local function StartAntiFling()
    if not State.AntiFlingActive then return end
    SetCollisionAll(false)

    local function onPlayerAdded(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if hrp and State.AntiFlingActive then hrp.CanCollide = false end
        end)
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and State.AntiFlingActive then hrp.CanCollide = false end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then onPlayerAdded(p) end
    end

    local conn1 = Players.PlayerAdded:Connect(onPlayerAdded)
    local conn2 = LocalPlayer.CharacterAdded:Connect(function(c)
        Character = c
        if State.AntiFlingActive then
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = false end
        end
    end)
    table.insert(State.AntiFlingConnections, conn1)
    table.insert(State.AntiFlingConnections, conn2)

    if flingHeartbeat then flingHeartbeat:Disconnect() end
    flingHeartbeat = RunService.Heartbeat:Connect(function()
        if not State.AntiFlingActive then return end
        if not Character then return end
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.Velocity * 0.9
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end)
    table.insert(State.AntiFlingConnections, flingHeartbeat)
end

local function StopAntiFling()
    SetCollisionAll(true)
    for _, c in ipairs(State.AntiFlingConnections) do c:Disconnect() end
    State.AntiFlingConnections = {}
    if flingHeartbeat then flingHeartbeat:Disconnect(); flingHeartbeat = nil end
end

-- === ANTI‑AFK ===
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

local function StopAntiAFK()
    State.AntiAFKActive = false
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
end
--[[ MM2 PutinHub v2.1 – часть 2 (GUI) ]]

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PutinHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(68, 255, 136)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

-- Фон
local Bg = Instance.new("ImageLabel")
Bg.Size = UDim2.new(1,0,1,0)
Bg.BackgroundTransparency = 1
Bg.Image = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Kazakhstan.svg/1280px-Flag_of_Kazakhstan.svg.png"
Bg.ScaleType = Enum.ScaleType.Fit
Bg.ImageTransparency = 0.85
Bg.ZIndex = 0
Bg.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 PutinHub"
Title.TextColor3 = Color3.fromRGB(68, 255, 136)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка Hide
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -72, 0, 4)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 50)
HideBtn.BackgroundTransparency = 0.5
HideBtn.Text = "−"
HideBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
HideBtn.TextSize = 22
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = MainFrame
local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 8)
HCorner.Parent = HideBtn

-- Кнопка Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
local CCorn = Instance.new("UICorner")
CCorn.CornerRadius = UDim.new(0, 8)
CCorn.Parent = CloseBtn

-- ScrollingFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -45)
Scroll.Position = UDim2.new(0, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(68, 255, 136)
Scroll.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Scroll

local yPos = 10

-- === ТОГЛ ===
local function CreateToggle(label, toggleVar, onFunc, offFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 130, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 24)
    btn.Position = UDim2.new(1, -65, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        State[toggleVar] = not State[toggleVar]
        if State[toggleVar] then
            btn.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
            btn.Text = "ON"
            if onFunc then onFunc() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if offFunc then offFunc() end
        end
    end)

    yPos = yPos + 35
    return frame
end

-- === ПОЛЗУНОК С ТОГЛОМ ===
local function CreateSliderToggle(label, sliderVar, toggleVar, minVal, maxVal, step, defaultVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 48)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 130, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 24)
    btn.Position = UDim2.new(1, -65, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, 100, 0, 6)
    slider.Position = UDim2.new(0, 105, 0.5, -3)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = slider

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local valText = Instance.new("TextLabel")
    valText.Size = UDim2.new(0, 40, 1, 0)
    valText.Position = UDim2.new(1, -40, 0, 0)
    valText.BackgroundTransparency = 1
    valText.Text = tostring(defaultVal)
    valText.TextColor3 = Color3.fromRGB(200, 200, 200)
    valText.TextSize = 12
    valText.Font = Enum.Font.Gotham
    valText.TextXAlignment = Enum.TextXAlignment.Right
    valText.Parent = frame

    State[sliderVar] = defaultVal

    btn.MouseButton1Click:Connect(function()
        State[toggleVar] = not State[toggleVar]
        if State[toggleVar] then
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            btn.Text = "ON"
            if toggleVar == "SpeedToggle" then
                StartSpeedHeartbeat()
                ApplySpeed()
            elseif toggleVar == "JumpToggle" then
                ApplyJump()
            end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if toggleVar == "SpeedToggle" then
                StopSpeedHeartbeat()
            elseif toggleVar == "JumpToggle" then
                if Character and Character:FindFirstChild("Humanoid") then
                    Character.Humanoid.JumpPower = State.DefaultJump
                end
            end
        end
    end)

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local newVal = minVal + (maxVal - minVal) * relX
            local rounded = math.floor(newVal / step + 0.5) * step
            if sliderVar == "SpeedValue" then
                State.SpeedValue = rounded
                valText.Text = string.format("%.1f", rounded)
                if State.SpeedToggle then ApplySpeed() end
            elseif sliderVar == "JumpValue" then
                State.JumpValue = rounded
                valText.Text = tostring(rounded)
                if State.JumpToggle then ApplyJump() end
            end
            fill.Size = UDim2.new((rounded - minVal) / (maxVal - minVal), 0, 1, 0)
        end
    end)

    slider.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local newVal = minVal + (maxVal - minVal) * relX
            local rounded = math.floor(newVal / step + 0.5) * step
            if sliderVar == "SpeedValue" then
                State.SpeedValue = rounded
                valText.Text = string.format("%.1f", rounded)
                if State.SpeedToggle then ApplySpeed() end
            elseif sliderVar == "JumpValue" then
                State.JumpValue = rounded
                valText.Text = tostring(rounded)
                if State.JumpToggle then ApplyJump() end
            end
            fill.Size = UDim2.new((rounded - minVal) / (maxVal - minVal), 0, 1, 0)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    yPos = yPos + 53
    return frame
end

-- === РАЗМЕЩЕНИЕ ===
CreateToggle("Auto Farm", "FarmActive", StartFarm, function()
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
end)

CreateToggle("ESP Wallhack", "ESPActive", UpdateESP, function()
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}
end)

CreateToggle("Anti-Fling", "AntiFlingActive", StartAntiFling, StopAntiFling)
CreateToggle("Anti-AFK", "AntiAFKActive", StartAntiAFK, StopAntiAFK)

-- Speed: 1–30, шаг 0.5
CreateSliderToggle("Speed", "SpeedValue", "SpeedToggle", 1, 30, 0.5, 16)
-- Jump: 1–200, шаг 1
CreateSliderToggle("Jump", "JumpValue", "JumpToggle", 1, 200, 1, 50)

-- Обновляем Canvas
local function UpdateCanvas()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    Content.Size = UDim2.new(1, 0, 0, yPos + 10)
end
UpdateCanvas()

-- Плавающая кнопка Show
local ShowGui = Instance.new("ScreenGui")
ShowGui.Name = "ShowButton"
ShowGui.ResetOnSpawn = false
ShowGui.Enabled = false
ShowGui.Parent = PlayerGui

local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0, 45, 0, 45)
ShowBtn.Position = UDim2.new(0.9, -22, 0.9, -22)
ShowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ShowBtn.BackgroundTransparency = 0.2
ShowBtn.Text = "M"
ShowBtn.TextColor3 = Color3.fromRGB(68, 255, 136)
ShowBtn.TextSize = 26
ShowBtn.Font = Enum.Font.GothamBold
ShowBtn.Parent = ShowGui
local SC = Instance.new("UICorner")
SC.CornerRadius = UDim.new(1, 0)
SC.Parent = ShowBtn

local function HideGUI()
    State.GUIHidden = true
    ScreenGui.Enabled = false
    ShowGui.Enabled = true
end

local function ShowGUI()
    State.GUIHidden = false
    ScreenGui.Enabled = true
    ShowGui.Enabled = false
end

HideBtn.MouseButton1Click:Connect(HideGUI)
ShowBtn.MouseButton1Click:Connect(ShowGUI)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Minus then
        if State.GUIHidden then ShowGUI() else HideGUI() end
    end
end)

-- Закрытие
CloseBtn.MouseButton1Click:Connect(function()
    State.FarmActive = false
    State.ESPActive = false
    State.AntiFlingActive = false
    State.AntiAFKActive = false
    State.SpeedToggle = false
    State.JumpToggle = false
    
    if State.FarmTask then State.FarmTask:Disconnect(); State.FarmTask = nil end
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
    StopAntiFling()
    StopSpeedHeartbeat()
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = State.DefaultJump
        Character.Humanoid.WalkSpeed = State.DefaultSpeed
    end
    
    for _, v in pairs(State.HighlightInstances) do v:Destroy() end
    for _, v in pairs(State.NameTags) do v:Destroy() end
    State.HighlightInstances = {}
    State.NameTags = {}
    
    ScreenGui:Destroy()
    ShowGui:Destroy()
end)

-- Применяем начальные значения
task.wait(0.5)
if Character and Character:FindFirstChild("Humanoid") then
    Character.Humanoid.JumpPower = State.DefaultJump
    Character.Humanoid.WalkSpeed = State.DefaultSpeed
end

-- Автообновление ESP
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if State.ESPActive then UpdateESP() end
        task.wait(2)
    end
end)

-- Обработка респавна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    if State.FarmActive then
        if State.FarmTask then State.FarmTask:Disconnect() end
        StartFarm()
    end
    if State.AntiFlingActive then
        task.wait(0.5)
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = false end
    end
    task.wait(0.2)
    if State.JumpToggle then
        ApplyJump()
    else
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = State.DefaultJump
        end
    end
    if State.SpeedToggle then
        StartSpeedHeartbeat()
        ApplySpeed()
    else
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = State.DefaultSpeed
        end
    end
end)

print("[good]: MM2 PutinHub v2.1 загружен. Speed 1-30 (шаг 0.5), Jump 1-200 (шаг 1).")
