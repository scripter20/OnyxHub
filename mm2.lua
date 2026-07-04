--[[ PutinHub v2.0 – три вкладки: Player, Main, Info ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PutinHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- === ГЛАВНОЕ ОКНО (растянуто по высоте для вкладок) ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)  -- высота увеличена
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

-- Обводка
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(68, 255, 136)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Тень
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

-- Верхняя панель (заголовок + кнопки)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

-- Заголовок
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

-- Зелёный кружок
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

-- Версия
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 60, 0, 20)
SubTitle.Position = UDim2.new(1, -75, 0, 2)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v2.0"
SubTitle.TextColor3 = Color3.fromRGB(150, 200, 150)
SubTitle.TextSize = 13
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Right
SubTitle.TextYAlignment = Enum.TextYAlignment.Center
SubTitle.Parent = TopBar

-- Кнопка закрытия (теперь обычная X)
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

-- === ВКЛАДКИ ===
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -20, 0, 36)
TabsFrame.Position = UDim2.new(0, 10, 0, 48)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

-- Функция создания вкладки
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

-- Контейнеры для содержимого вкладок (пока пустые)
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

-- Текст в Info (пока просто)
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "PutinHub v2.0\nДля Murder Mystery 2\n\nСделано с любовью ❤️"
InfoLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
InfoLabel.TextSize = 16
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Center
InfoLabel.TextYAlignment = Enum.TextYAlignment.Center
InfoLabel.Parent = InfoContent

-- Переключение вкладок
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
ShowTab("Player")

-- === ПЕРЕМЕЩАЕМАЯ КНОПКА ZOV ===
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

-- Перетаскивание ZOV
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

-- Логика показа/скрытия
local guiVisible = true
TopButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

-- Анимация
MainFrame.BackgroundTransparency = 1
local tweenService = game:GetService("TweenService")
local tween = tweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.1
})
tween:Play()

print("[good]: PutinHub v2.0 – три вкладки: Player, Main, Info.")
