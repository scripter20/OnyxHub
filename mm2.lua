--[[ MM2 PutinHub v1.0 – часть 1 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local State = {
    Farm = false,
    AntiFling = false,
    AntiAFK = false,
    ESP = false,
    Speed = 16,
    Jump = 50,
    NoClip = false,
    InfJump = false,
    FarmTask = nil,
    AntiAFKTask = nil,
    AntiFlingConn = {},
    ESPHighlights = {},
    ESPNames = {},
    NoClipConn = nil,
    InfJumpConn = nil,
}

-- === Роли ===
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
    for _, v in pairs(State.ESPHighlights) do v:Destroy() end
    for _, v in pairs(State.ESPNames) do v:Destroy() end
    State.ESPHighlights = {}
    State.ESPNames = {}

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
            table.insert(State.ESPHighlights, h)

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
            table.insert(State.ESPNames, b)
        end
    end
end

-- === NOCLIP ===
local function ApplyNoClip(state)
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function StartNoClip()
    if State.NoClipConn then return end
    State.NoClipConn = RunService.Heartbeat:Connect(function()
        if State.NoClip then ApplyNoClip(true) end
    end)
end

local function StopNoClip()
    if State.NoClipConn then State.NoClipConn:Disconnect(); State.NoClipConn = nil end
    ApplyNoClip(false)
end

-- === INFINITE JUMP ===
local function StartInfJump()
    if State.InfJumpConn then return end
    State.InfJumpConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Space and State.InfJump then
            local hum = Character and Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function StopInfJump()
    if State.InfJumpConn then State.InfJumpConn:Disconnect(); State.InfJumpConn = nil end
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
    if not State.AntiFling then return end
    SetCollisionAll(false)

    local function onPlayerAdded(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if hrp and State.AntiFling then hrp.CanCollide = false end
        end)
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and State.AntiFling then hrp.CanCollide = false end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then onPlayerAdded(p) end
    end

    local conn1 = Players.PlayerAdded:Connect(onPlayerAdded)
    local conn2 = LocalPlayer.CharacterAdded:Connect(function(c)
        Character = c
        if State.AntiFling then
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = false end
        end
    end)
    table.insert(State.AntiFlingConn, conn1)
    table.insert(State.AntiFlingConn, conn2)

    if flingHeartbeat then flingHeartbeat:Disconnect() end
    flingHeartbeat = RunService.Heartbeat:Connect(function()
        if not State.AntiFling then return end
        if not Character then return end
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.Velocity * 0.9
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end)
    table.insert(State.AntiFlingConn, flingHeartbeat)
end

local function StopAntiFling()
    SetCollisionAll(true)
    for _, c in ipairs(State.AntiFlingConn) do c:Disconnect() end
    State.AntiFlingConn = {}
    if flingHeartbeat then flingHeartbeat:Disconnect(); flingHeartbeat = nil end
end

-- === ANTI‑AFK ===
local function StartAntiAFK()
    if State.AntiAFKTask then return end
    State.AntiAFK = true
    State.AntiAFKTask = task.spawn(function()
        while State.AntiAFK do
            task.wait(300)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end

local function StopAntiAFK()
    State.AntiAFK = false
    if State.AntiAFKTask then task.cancel(State.AntiAFKTask); State.AntiAFKTask = nil end
end
--[[ MM2 PutinHub v1.0 – часть 2 (AutoFarm + Teleport) ]]

-- === AUTOFARM ===
local farmTask = nil

local function StartFarm()
    if farmTask then return end

    farmTask = RunService.Heartbeat:Connect(function()
        if not State.Farm then return end
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

        local hrp = Character.HumanoidRootPart

        -- Включаем ноклип для фарма
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

local function StopFarm()
    if farmTask then farmTask:Disconnect(); farmTask = nil end
    -- Не восстанавливаем физику, чтобы сохранить ноклип (но можно оставить как есть)
end

-- === TELEPORT FUNCTIONS ===
local function TpToLobby()
    -- В MM2 лобби обычно находится по координатам, но лучше искать спавн-точку
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("SpawnLocation")
    if lobby and lobby:IsA("BasePart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = lobby.CFrame + Vector3.new(0,2,0)
    else
        warn("Lobby not found")
    end
end

local function TpToMap()
    -- Просто телепортируем на центр карты (можно найти любой BasePart с именем "Map")
    local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Terrain")
    if map and map:IsA("BasePart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = map.CFrame + Vector3.new(0,5,0)
    else
        warn("Map not found")
    end
end

local function TpToMurder()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsMurderer(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
            return
        end
    end
    warn("No murderer found")
end

local function TpToSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsSheriff(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
            return
        end
    end
    warn("No sheriff found")
end
--[[ MM2 PutinHub v1.0 – часть 3 (GUI) ]]

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PutinHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 540)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -270)
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

-- Фоновое изображение (опционально, можно оставить флаг)
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
Title.Size = UDim2.new(1, -80, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 PutinHub"
Title.TextColor3 = Color3.fromRGB(68, 255, 136)
Title.TextSize = 24
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
local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 8)
HCorner.Parent = HideBtn

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
local CCorn = Instance.new("UICorner")
CCorn.CornerRadius = UDim.new(0, 8)
CCorn.Parent = CloseBtn

-- Вкладки
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -20, 0, 40)
Tabs.Position = UDim2.new(0, 10, 0, 50)
Tabs.BackgroundTransparency = 1
Tabs.Parent = MainFrame

local TabGen = Instance.new("TextButton")
TabGen.Size = UDim2.new(0.333, -5, 1, 0)
TabGen.Position = UDim2.new(0, 0, 0, 0)
TabGen.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
TabGen.BackgroundTransparency = 0.3
TabGen.Text = "General"
TabGen.TextColor3 = Color3.fromRGB(200, 255, 200)
TabGen.TextSize = 16
TabGen.Font = Enum.Font.GothamBold
TabGen.Parent = Tabs
local TCorner1 = Instance.new("UICorner")
TCorner1.CornerRadius = UDim.new(0, 8)
TCorner1.Parent = TabGen

local TabPlayer = Instance.new("TextButton")
TabPlayer.Size = UDim2.new(0.333, -5, 1, 0)
TabPlayer.Position = UDim2.new(0.333, 5, 0, 0)
TabPlayer.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
TabPlayer.BackgroundTransparency = 0.3
TabPlayer.Text = "Player"
TabPlayer.TextColor3 = Color3.fromRGB(200, 255, 200)
TabPlayer.TextSize = 16
TabPlayer.Font = Enum.Font.GothamBold
TabPlayer.Parent = Tabs
local TCorner2 = Instance.new("UICorner")
TCorner2.CornerRadius = UDim.new(0, 8)
TCorner2.Parent = TabPlayer

local TabTeleport = Instance.new("TextButton")
TabTeleport.Size = UDim2.new(0.333, -5, 1, 0)
TabTeleport.Position = UDim2.new(0.666, 10, 0, 0)
TabTeleport.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
TabTeleport.BackgroundTransparency = 0.3
TabTeleport.Text = "Teleport"
TabTeleport.TextColor3 = Color3.fromRGB(200, 255, 200)
TabTeleport.TextSize = 16
TabTeleport.Font = Enum.Font.GothamBold
TabTeleport.Parent = Tabs
local TCorner3 = Instance.new("UICorner")
TCorner3.CornerRadius = UDim.new(0, 8)
TCorner3.Parent = TabTeleport

-- ScrollingFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -100)
Scroll.Position = UDim2.new(0, 0, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(68, 255, 136)
Scroll.Parent = MainFrame

-- Контейнеры для каждой вкладки
local GenPanel = Instance.new("Frame")
GenPanel.Size = UDim2.new(1,0,0,0)
GenPanel.BackgroundTransparency = 1
GenPanel.Parent = Scroll

local PlayerPanel = Instance.new("Frame")
PlayerPanel.Size = UDim2.new(1,0,0,0)
PlayerPanel.BackgroundTransparency = 1
PlayerPanel.Parent = Scroll
PlayerPanel.Visible = false

local TeleportPanel = Instance.new("Frame")
TeleportPanel.Size = UDim2.new(1,0,0,0)
TeleportPanel.BackgroundTransparency = 1
TeleportPanel.Parent = Scroll
TeleportPanel.Visible = false

local function UpdateCanvas()
    local h1,h2,h3 = 0,0,0
    for _,c in ipairs(GenPanel:GetChildren()) do if c:IsA("Frame") then local y = c.Position.Y.Offset + c.Size.Y.Offset; if y>h1 then h1=y end end end
    for _,c in ipairs(PlayerPanel:GetChildren()) do if c:IsA("Frame") then local y = c.Position.Y.Offset + c.Size.Y.Offset; if y>h2 then h2=y end end end
    for _,c in ipairs(TeleportPanel:GetChildren()) do if c:IsA("Frame") then local y = c.Position.Y.Offset + c.Size.Y.Offset; if y>h3 then h3=y end end end
    GenPanel.Size = UDim2.new(1,0,0,h1+20)
    PlayerPanel.Size = UDim2.new(1,0,0,h2+20)
    TeleportPanel.Size = UDim2.new(1,0,0,h3+20)
    Scroll.CanvasSize = UDim2.new(0,0,0,math.max(h1,h2,h3)+20)
end

-- Функции создания элементов (переключатели и ползунки)
local function CreateToggle(panel, label, stateKey, yPos, onFunc, offFunc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,30)
    f.Position = UDim2.new(0,10,0,yPos)
    f.BackgroundTransparency = 1
    f.Parent = panel

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0,160,1,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(200,255,200)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,24)
    btn.Position = UDim2.new(1,-70,0.5,-12)
    btn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        if State[stateKey] then
            btn.BackgroundColor3 = Color3.fromRGB(68,255,136)
            btn.Text = "ON"
            if onFunc then onFunc() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200,50,50)
            btn.Text = "OFF"
            if offFunc then offFunc() end
        end
    end)
    return f, yPos+35
end

local function CreateSlider(panel, label, minVal, maxVal, step, stateKey, format, yPos, applyFunc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,50)
    f.Position = UDim2.new(0,10,0,yPos)
    f.BackgroundTransparency = 1
    f.Parent = panel

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20)
    l.Position = UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = label .. ": " .. string.format(format or "%.1f", State[stateKey])
    l.TextColor3 = Color3.fromRGB(200,255,200)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,0,6)
    bg.Position = UDim2.new(0,0,0,25)
    bg.BackgroundColor3 = Color3.fromRGB(50,70,50)
    bg.BorderSizePixel = 0
    bg.Parent = f
    local bgc = Instance.new("UICorner")
    bgc.CornerRadius = UDim.new(1,0)
    bgc.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(68,255,136)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = fill

    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0,18,0,18)
    thumb.Position = UDim2.new(0,-9,0.5,-9)
    thumb.BackgroundColor3 = Color3.fromRGB(200,255,200)
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.Parent = bg
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = thumb

    local dragging = false
    local function Update(val)
        local clamped = math.clamp(val, minVal, maxVal)
        local rounded = math.round(clamped/step)*step
        State[stateKey] = rounded
        local ratio = (rounded-minVal)/(maxVal-minVal)
        thumb.Position = UDim2.new(ratio, -9, 0.5, -9)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        l.Text = label .. ": " .. string.format(format or "%.1f", rounded)
        if applyFunc then applyFunc(rounded) end
    end

    Update(State[stateKey])

    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    thumb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and dragging then
            local pos = i.Position
            local absPos = bg.AbsolutePosition
            local sizeX = bg.AbsoluteSize.X
            local relX = math.clamp((pos.X - absPos.X)/sizeX, 0, 1)
            local val = minVal + relX*(maxVal-minVal)
            Update(val)
        end
    end)
    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if not dragging then
                local pos = i.Position
                local absPos = bg.AbsolutePosition
                local sizeX = bg.AbsoluteSize.X
                local relX = math.clamp((pos.X - absPos.X)/sizeX, 0, 1)
                local val = minVal + relX*(maxVal-minVal)
                Update(val)
            end
        end
    end)
    return f, yPos+60
end

-- Заполняем General
local yG = 10
local _, yG = CreateToggle(GenPanel, "Auto Farm", "Farm", yG, function() StartFarm() end, function() StopFarm() end)
local _, yG = CreateToggle(GenPanel, "Anti-Fling", "AntiFling", yG, function() StartAntiFling() end, function() StopAntiFling() end)
local _, yG = CreateToggle(GenPanel, "Anti-AFK", "AntiAFK", yG, function() StartAntiAFK() end, function() StopAntiAFK() end)
local _, yG = CreateToggle(GenPanel, "ESP", "ESP", yG, function() UpdateESP() end, function()
    for _,v in pairs(State.ESPHighlights) do v:Destroy() end
    for _,v in pairs(State.ESPNames) do v:Destroy() end
    State.ESPHighlights = {}
    State.ESPNames = {}
end)

-- Заполняем Player
local yP = 10
local _, yP = CreateSlider(PlayerPanel, "Speed", 0, 30, 0.5, "Speed", "%.1f", yP, function(val)
    if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.WalkSpeed = val end
end)
local _, yP = CreateSlider(PlayerPanel, "Jump", 0, 200, 1, "Jump", "%.0f", yP, function(val)
    if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.JumpPower = val end
end)
local _, yP = CreateToggle(PlayerPanel, "NoClip", "NoClip", yP, function() StartNoClip() end, function() StopNoClip() end)
local _, yP = CreateToggle(PlayerPanel, "InfJump", "InfJump", yP, function() StartInfJump() end, function() StopInfJump() end)

-- Заполняем Teleport
local yT = 10
local function TeleportButton(panel, label, func, yPos)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,30)
    f.Position = UDim2.new(0,10,0,yPos)
    f.BackgroundTransparency = 1
    f.Parent = panel

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundColor3 = Color3.fromRGB(34,68,34)
    btn.BackgroundTransparency = 0.3
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(200,255,200)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,8)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(func)
    return f, yPos+35
end

local _, yT = TeleportButton(TeleportPanel, "TP to Lobby", TpToLobby, yT)
local _, yT = TeleportButton(TeleportPanel, "TP to Map", TpToMap, yT)
local _, yT = TeleportButton(TeleportPanel, "TP to Murder", TpToMurder, yT)
local _, yT = TeleportButton(TeleportPanel, "TP to Sheriff", TpToSheriff, yT)

UpdateCanvas()

-- Переключение вкладок
local function ShowTab(tab)
    GenPanel.Visible = false
    PlayerPanel.Visible = false
    TeleportPanel.Visible = false
    if tab == "General" then
        GenPanel.Visible = true
        TabGen.BackgroundColor3 = Color3.fromRGB(68,255,136)
        TabGen.TextColor3 = Color3.fromRGB(0,0,0)
        TabPlayer.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabPlayer.TextColor3 = Color3.fromRGB(200,255,200)
        TabTeleport.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabTeleport.TextColor3 = Color3.fromRGB(200,255,200)
    elseif tab == "Player" then
        PlayerPanel.Visible = true
        TabPlayer.BackgroundColor3 = Color3.fromRGB(68,255,136)
        TabPlayer.TextColor3 = Color3.fromRGB(0,0,0)
        TabGen.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabGen.TextColor3 = Color3.fromRGB(200,255,200)
        TabTeleport.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabTeleport.TextColor3 = Color3.fromRGB(200,255,200)
    else
        TeleportPanel.Visible = true
        TabTeleport.BackgroundColor3 = Color3.fromRGB(68,255,136)
        TabTeleport.TextColor3 = Color3.fromRGB(0,0,0)
        TabGen.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabGen.TextColor3 = Color3.fromRGB(200,255,200)
        TabPlayer.BackgroundColor3 = Color3.fromRGB(34,68,34)
        TabPlayer.TextColor3 = Color3.fromRGB(200,255,200)
    end
    UpdateCanvas()
end

TabGen.MouseButton1Click:Connect(function() ShowTab("General") end)
TabPlayer.MouseButton1Click:Connect(function() ShowTab("Player") end)
TabTeleport.MouseButton1Click:Connect(function() ShowTab("Teleport") end)
ShowTab("General")

-- Кнопка Show (плавающая)
local ShowGui = Instance.new("ScreenGui")
ShowGui.Name = "ShowButton"
ShowGui.ResetOnSpawn = false
ShowGui.Enabled = false
ShowGui.Parent = PlayerGui

local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0,50,0,50)
ShowBtn.Position = UDim2.new(0.9,-25,0.9,-25)
ShowBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
ShowBtn.BackgroundTransparency = 0.2
ShowBtn.Text = "M"
ShowBtn.TextColor3 = Color3.fromRGB(68,255,136)
ShowBtn.TextSize = 28
ShowBtn.Font = Enum.Font.GothamBold
ShowBtn.Parent = ShowGui
local SC = Instance.new("UICorner")
SC.CornerRadius = UDim.new(1,0)
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
    State.Farm = false
    State.AntiFling = false
    State.AntiAFK = false
    State.ESP = false
    State.NoClip = false
    State.InfJump = false
    StopFarm()
    StopAntiFling()
    StopAntiAFK()
    StopNoClip()
    StopInfJump()
    for _,v in pairs(State.ESPHighlights) do v:Destroy() end
    for _,v in pairs(State.ESPNames) do v:Destroy() end
    ScreenGui:Destroy()
    ShowGui:Destroy()
end)

-- Автообновление ESP
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if State.ESP then UpdateESP() end
        task.wait(2)
    end
end)

-- Обработка респавна
LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = State.Speed
        Character.Humanoid.JumpPower = State.Jump
    end
    if State.NoClip then StartNoClip() end
    if State.InfJump then StartInfJump() end
    if State.Farm then
        if farmTask then farmTask:Disconnect() end
        StartFarm()
    end
    if State.AntiFling then
        task.wait(0.5)
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = false end
    end
end)

print("[good]: MM2 PutinHub v1.0 загружен.")
