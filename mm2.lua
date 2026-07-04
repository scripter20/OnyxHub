--[[ PutinHub v3.7 – ЧАСТЬ 1 (без Hero, полное закрытие) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PutinHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local State = {
    ESP = false,
    ESPHighlights = {},
    ESPNames = {},
    CleanupFunctions = {}, -- для очистки при закрытии
}

-- === ПРОСТЫЕ РОЛИ (без Hero) ===
local function IsMurderer(p)
    local c = p.Character
    if not c then return false end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then
            return true
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, v in ipairs(bp:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("knife") or v.Name:lower():find("murder")) then
                return true
            end
        end
    end
    return false
end

local function IsSheriff(p)
    local c = p.Character
    if not c then return false end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol")) then
            return true
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, v in ipairs(bp:GetDescendants()) do
            if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol")) then
                return true
            end
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

local function GetRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 50, 50) end
    if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end
    return Color3.fromRGB(50, 255, 50) -- Innocent
end

-- === ESP ===
local function UpdateESP()
    for _, v in pairs(State.ESPHighlights) do v:Destroy() end
    for _, v in pairs(State.ESPNames) do v:Destroy() end
    State.ESPHighlights = {}
    State.ESPNames = {}
    if not State.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local c = p.Character
            local hrp = c.HumanoidRootPart
            local role = GetRole(p)
            local col = GetRoleColor(role)
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
            b.Size = UDim2.new(0, 200, 0, 50)
            b.Adornee = hrp
            b.StudsOffset = Vector3.new(0, 3.5, 0)
            b.Parent = c
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 1, 0)
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

-- Автообновление ESP
local espUpdater = nil
local function StartESPUpdater()
    if espUpdater then return end
    espUpdater = task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if State.ESP then UpdateESP() end
            task.wait(2)
        end
    end)
    table.insert(State.CleanupFunctions, function()
        if espUpdater then task.cancel(espUpdater); espUpdater = nil end
    end)
end

-- === GUI ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
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

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, -4)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.4
Shadow.BorderSizePixel = 0
Shadow.ZIndex = -1
Shadow.Parent = MainFrame
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 18)
ShadowCorner.Parent = Shadow

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 130, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "PutinHub"
Title.TextColor3 = Color3.fromRGB(68, 255, 136)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = TopBar

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 5, 0.5, -4)
Dot.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
Dot.BackgroundTransparency = 0.4
Dot.BorderSizePixel = 0
Dot.Parent = TopBar
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = Dot

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 60, 0, 20)
SubTitle.Position = UDim2.new(1, -75, 0, 2)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v3.7"
SubTitle.TextColor3 = Color3.fromRGB(150, 200, 150)
SubTitle.TextSize = 13
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Right
SubTitle.TextYAlignment = Enum.TextYAlignment.Center
SubTitle.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local DialogFrame = Instance.new("Frame")
DialogFrame.Size = UDim2.new(0, 260, 0, 110)
DialogFrame.Position = UDim2.new(0.5, -130, 0.5, -55)
DialogFrame.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
DialogFrame.BackgroundTransparency = 0.15
DialogFrame.BorderSizePixel = 0
DialogFrame.ClipsDescendants = true
DialogFrame.Parent = MainFrame
DialogFrame.Visible = false

local DialogCorner = Instance.new("UICorner")
DialogCorner.CornerRadius = UDim.new(0, 12)
DialogCorner.Parent = DialogFrame

local DialogStroke = Instance.new("UIStroke")
DialogStroke.Color = Color3.fromRGB(68, 255, 136)
DialogStroke.Thickness = 2
DialogStroke.Transparency = 0.3
DialogStroke.Parent = DialogFrame

local DialogText = Instance.new("TextLabel")
DialogText.Size = UDim2.new(1, -20, 0, 40)
DialogText.Position = UDim2.new(0, 10, 0, 10)
DialogText.BackgroundTransparency = 1
DialogText.Text = "Точно закрыть PutinHub?"
DialogText.TextColor3 = Color3.fromRGB(200, 255, 200)
DialogText.TextSize = 16
DialogText.Font = Enum.Font.GothamBold
DialogText.TextXAlignment = Enum.TextXAlignment.Center
DialogText.Parent = DialogFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0, 80, 0, 30)
YesBtn.Position = UDim2.new(0.5, -85, 0, 65)
YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
YesBtn.BackgroundTransparency = 0.3
YesBtn.Text = "Да"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.TextSize = 14
YesBtn.Font = Enum.Font.GothamBold
YesBtn.Parent = DialogFrame
local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0, 6)
YesCorner.Parent = YesBtn

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0, 80, 0, 30)
NoBtn.Position = UDim2.new(0.5, 5, 0, 65)
NoBtn.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
NoBtn.BackgroundTransparency = 0.3
NoBtn.Text = "Нет"
NoBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
NoBtn.TextSize = 14
NoBtn.Font = Enum.Font.GothamBold
NoBtn.Parent = DialogFrame
local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0, 6)
NoCorner.Parent = NoBtn
--[[ PutinHub v3.7 – ЧАСТЬ 2 ]]

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -20, 0, 36)
TabsFrame.Position = UDim2.new(0, 10, 0, 48)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local function CreateTab(text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Position = UDim2.new(0, xPos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 255, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabsFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

local TabPlayer = CreateTab("Player", 0)
local TabMain = CreateTab("Main", 115)
local TabInfo = CreateTab("Info", 230)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local PlayerContent = Instance.new("Frame")
PlayerContent.Size = UDim2.new(1, 0, 1, 0)
PlayerContent.BackgroundTransparency = 1
PlayerContent.Parent = ContentFrame

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.Parent = ContentFrame
MainContent.Visible = false

local InfoContent = Instance.new("Frame")
InfoContent.Size = UDim2.new(1, 0, 1, 0)
InfoContent.BackgroundTransparency = 1
InfoContent.Parent = ContentFrame
InfoContent.Visible = false

local function CreateToggle(text, stateKey, yPos, onFunc, offFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = MainContent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 130, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
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
        State[stateKey] = not State[stateKey]
        if State[stateKey] then
            btn.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
            btn.Text = "ON"
            if onFunc then onFunc() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "OFF"
            if offFunc then offFunc() end
        end
    end)
end

CreateToggle("ESP Wallhack", "ESP", 10, function()
    UpdateESP()
    StartESPUpdater()
end, function()
    for _, v in pairs(State.ESPHighlights) do v:Destroy() end
    for _, v in pairs(State.ESPNames) do v:Destroy() end
    State.ESPHighlights = {}
    State.ESPNames = {}
    if espUpdater then task.cancel(espUpdater); espUpdater = nil end
end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "PutinHub v3.7\nДля Murder Mystery 2\n\nСделано с любовью ❤️"
InfoLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
InfoLabel.TextSize = 16
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Center
InfoLabel.TextYAlignment = Enum.TextYAlignment.Center
InfoLabel.Parent = InfoContent

local function ShowTab(tab)
    PlayerContent.Visible = false
    MainContent.Visible = false
    InfoContent.Visible = false
    TabPlayer.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
    TabPlayer.TextColor3 = Color3.fromRGB(200, 255, 200)
    TabMain.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
    TabMain.TextColor3 = Color3.fromRGB(200, 255, 200)
    TabInfo.BackgroundColor3 = Color3.fromRGB(34, 68, 34)
    TabInfo.TextColor3 = Color3.fromRGB(200, 255, 200)
    if tab == "Player" then
        PlayerContent.Visible = true
        TabPlayer.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
        TabPlayer.TextColor3 = Color3.fromRGB(0, 0, 0)
    elseif tab == "Main" then
        MainContent.Visible = true
        TabMain.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
        TabMain.TextColor3 = Color3.fromRGB(0, 0, 0)
    elseif tab == "Info" then
        InfoContent.Visible = true
        TabInfo.BackgroundColor3 = Color3.fromRGB(68, 255, 136)
        TabInfo.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end

TabPlayer.MouseButton1Click:Connect(function() ShowTab("Player") end)
TabMain.MouseButton1Click:Connect(function() ShowTab("Main") end)
TabInfo.MouseButton1Click:Connect(function() ShowTab("Info") end)
ShowTab("Main")

local TopButton = Instance.new("TextButton")
TopButton.Size = UDim2.new(0, 65, 0, 55)
TopButton.Position = UDim2.new(0.5, -32, 0, 15)
TopButton.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
TopButton.BackgroundTransparency = 0.15
TopButton.Text = "ZOV"
TopButton.TextColor3 = Color3.fromRGB(68, 255, 136)
TopButton.TextSize = 20
TopButton.Font = Enum.Font.GothamBold
TopButton.Parent = ScreenGui

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopButton

local TopStroke = Instance.new("UIStroke")
TopStroke.Color = Color3.fromRGB(68, 255, 136)
TopStroke.Thickness = 2
TopStroke.Transparency = 0.3
TopStroke.Parent = TopButton

local TopShadow = Instance.new("Frame")
TopShadow.Size = UDim2.new(1, 8, 1, 8)
TopShadow.Position = UDim2.new(0, -4, 0, -4)
TopShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopShadow.BackgroundTransparency = 0.4
TopShadow.BorderSizePixel = 0
TopShadow.ZIndex = -1
TopShadow.Parent = TopButton
local TopShadowCorner = Instance.new("UICorner")
TopShadowCorner.CornerRadius = UDim.new(0, 14)
TopShadowCorner.Parent = TopShadow

local dragging = false
local dragStart, dragStartPos

TopButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragStartPos = TopButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        TopButton.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local guiVisible = true

TopButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
end)

local function ShowDialog()
    DialogFrame.Visible = true
    DialogFrame.BackgroundTransparency = 1
    TweenService:Create(DialogFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    }):Play()
end

local function HideDialog()
    TweenService:Create(DialogFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.2)
    DialogFrame.Visible = false
end

-- === ПОЛНАЯ ОЧИСТКА ПРИ ЗАКРЫТИИ ===
local function CleanupAll()
    -- Отключаем ESP
    State.ESP = false
    for _, v in pairs(State.ESPHighlights) do v:Destroy() end
    for _, v in pairs(State.ESPNames) do v:Destroy() end
    State.ESPHighlights = {}
    State.ESPNames = {}
    if espUpdater then task.cancel(espUpdater); espUpdater = nil end
    
    -- Очищаем все подключения
    for _, func in ipairs(State.CleanupFunctions) do
        pcall(func)
    end
    State.CleanupFunctions = {}
end

CloseBtn.MouseButton1Click:Connect(ShowDialog)

YesBtn.MouseButton1Click:Connect(function()
    CleanupAll()
    ScreenGui:Destroy()
end)

NoBtn.MouseButton1Click:Connect(function()
    HideDialog()
end)

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and DialogFrame.Visible then
        local pos = input.Position
        local absPos = DialogFrame.AbsolutePosition
        local size = DialogFrame.AbsoluteSize
        if not (pos.X >= absPos.X and pos.X <= absPos.X + size.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + size.Y) then
            HideDialog()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        if DialogFrame.Visible then
            HideDialog()
        else
            guiVisible = not guiVisible
            MainFrame.Visible = guiVisible
        end
    end
end)

-- Автоматическая очистка при закрытии ScreenGui
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        CleanupAll()
    end
end)

-- Запуск
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.1
}):Play()

print("[good]: PutinHub v3.7 – без Hero, полная очистка при закрытии.")
