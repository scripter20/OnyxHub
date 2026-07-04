-- PutinHub Version: 3.9.1
-- ЧАСТЬ 1 (Скопируй и вставь первой в свой файл на GitHub)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Глобальные переменные интерфейса для связи всех частей скрипта
local targetParent, PutinHub, MainFrame, TopBar, TopBarFix, HubTitle, AccentLine, CloseButton, ToggleButton, ToggleStroke, TabsContainer, CreditsCard, CreditsStroke, ContentFrame, BackgroundImg
local pages = {}
local tabs = {}
local themeStrokes = {}
local currentThemeName = "Green"
local currentActiveTab = "Main"

local success, err = pcall(function()
    targetParent = CoreGui
end)
if not success or not targetParent then
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

if targetParent:FindFirstChild("PutinHub") then
    targetParent["PutinHub"]:Destroy()
end

PutinHub = Instance.new("ScreenGui")
PutinHub.Name = "PutinHub"
PutinHub.ResetOnSpawn = false
PutinHub.Parent = targetParent

-- Главное окно
MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 280)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = PutinHub

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

-- Фоновый контейнер
BackgroundImg = Instance.new("ImageLabel")
BackgroundImg.Name = "BackgroundImg"
BackgroundImg.Size = UDim2.new(1, 0, 1, 0)
BackgroundImg.BackgroundTransparency = 1
BackgroundImg.ImageTransparency = 1
BackgroundImg.ScaleType = Enum.ScaleType.Crop
BackgroundImg.ZIndex = 0
BackgroundImg.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 9)
BgCorner.Parent = BackgroundImg

-- Шапка (TopBar)
TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 38, 22)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 2
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 9)
TopBarCorner.Parent = TopBar

TopBarFix = Instance.new("Frame")
TopBarFix.Name = "TopBarFix"
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(22, 38, 22)
TopBarFix.BorderSizePixel = 0
TopBarFix.ZIndex = 2
TopBarFix.Parent = TopBar

HubTitle = Instance.new("TextLabel")
HubTitle.Name = "HubTitle"
HubTitle.Size = UDim2.new(1, -50, 1, 0)
HubTitle.Position = UDim2.new(0, 15, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "PutinHub"
HubTitle.TextColor3 = Color3.fromRGB(74, 222, 128)
HubTitle.TextSize = 20
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.ZIndex = 3
HubTitle.Parent = TopBar

AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3
AccentLine.Parent = TopBar

-- Кнопка закрытия
CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(239, 68, 68)
CloseButton.TextSize = 26
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 3
CloseButton.Parent = TopBar

-- Кнопка ZOV
ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ZOVButton"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(1, -60, 0.5, -22)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 35, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "ZOV"
ToggleButton.TextColor3 = Color3.fromRGB(74, 222, 128)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = PutinHub

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 5)
ToggleCorner.Parent = ToggleButton

ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(34, 197, 94)
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = ToggleButton

-- Левое меню
TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(0, 100, 0, 184)
TabsContainer.Position = UDim2.new(0, 10, 0, 45)
TabsContainer.BackgroundTransparency = 1
TabsContainer.ZIndex = 2
TabsContainer.Parent = MainFrame

local TabsList = Instance.new("UIListLayout")
TabsList.Padding = UDim.new(0, 6)
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.Parent = TabsContainer

-- Карточка создателя
CreditsCard = Instance.new("Frame")
CreditsCard.Name = "CreditsCard"
CreditsCard.Size = UDim2.new(0, 100, 0, 40)
CreditsCard.Position = UDim2.new(0, 10, 1, -45)
CreditsCard.BackgroundColor3 = Color3.fromRGB(22, 38, 22)
CreditsCard.BorderSizePixel = 0
CreditsCard.ZIndex = 2
CreditsCard.Parent = MainFrame

local CreditsCorner = Instance.new("UICorner")
CreditsCorner.CornerRadius = UDim.new(0, 6)
CreditsCorner.Parent = CreditsCard

CreditsStroke = Instance.new("UIStroke")
CreditsStroke.Color = Color3.fromRGB(34, 197, 94)
CreditsStroke.Thickness = 1
CreditsStroke.Parent = CreditsCard

local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Name = "CreditsLabel"
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "Created by:\nPavelDurak"
CreditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsLabel.TextSize = 11
CreditsLabel.Font = Enum.Font.GothamBold
CreditsLabel.TextWrapped = true
CreditsLabel.ZIndex = 3
CreditsLabel.Parent = CreditsCard

-- Основной контейнер страниц
ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -125, 1, -50)
ContentFrame.Position = UDim2.new(0, 115, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainFrame
-- ЧАСТЬ 2 (Скопируй и вставь сразу под первой частью в свой файл на GitHub)

-- Настройки всех 7 цветовых тем хаба
local themes = {
    Green = {
        MainBg = Color3.fromRGB(15, 25, 15),
        TopBarBg = Color3.fromRGB(22, 38, 22),
        TitleText = Color3.fromRGB(74, 222, 128),
        Accent = Color3.fromRGB(34, 197, 94),
        TabBg = Color3.fromRGB(22, 38, 22),
        TabText = Color3.fromRGB(74, 222, 128),
        ActiveTabBg = Color3.fromRGB(34, 197, 94),
        ActiveTabText = Color3.fromRGB(15, 25, 15),
        CardBg = Color3.fromRGB(22, 38, 22),
        CardStroke = Color3.fromRGB(34, 197, 94),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(34, 255, 100)
    },
    White = {
        MainBg = Color3.fromRGB(245, 245, 245),
        TopBarBg = Color3.fromRGB(255, 255, 255),
        TitleText = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(180, 180, 180),
        TabBg = Color3.fromRGB(230, 230, 230),
        TabText = Color3.fromRGB(100, 100, 100),
        ActiveTabBg = Color3.fromRGB(200, 200, 200),
        ActiveTabText = Color3.fromRGB(30, 30, 30),
        CardBg = Color3.fromRGB(230, 230, 230),
        CardStroke = Color3.fromRGB(160, 160, 160),
        LabelText = Color3.fromRGB(40, 40, 40),
        SelectedStrokeColor = Color3.fromRGB(0, 160, 255)
    },
    Black = {
        MainBg = Color3.fromRGB(20, 20, 20),
        TopBarBg = Color3.fromRGB(12, 12, 12),
        TitleText = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(60, 60, 60),
        TabBg = Color3.fromRGB(28, 28, 28),
        TabText = Color3.fromRGB(160, 160, 160),
        ActiveTabBg = Color3.fromRGB(50, 50, 50),
        ActiveTabText = Color3.fromRGB(255, 255, 255),
        CardBg = Color3.fromRGB(28, 28, 28),
        CardStroke = Color3.fromRGB(70, 70, 70),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(255, 45, 45)
    },
    Blue = {
        MainBg = Color3.fromRGB(14, 20, 33),
        TopBarBg = Color3.fromRGB(20, 29, 48),
        TitleText = Color3.fromRGB(147, 197, 253),
        Accent = Color3.fromRGB(59, 130, 246),
        TabBg = Color3.fromRGB(20, 29, 48),
        TabText = Color3.fromRGB(147, 197, 253),
        ActiveTabBg = Color3.fromRGB(59, 130, 246),
        ActiveTabText = Color3.fromRGB(14, 20, 33),
        CardBg = Color3.fromRGB(20, 29, 48),
        CardStroke = Color3.fromRGB(59, 130, 246),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(0, 235, 255)
    },
    Orange = {
        MainBg = Color3.fromRGB(24, 18, 14),
        TopBarBg = Color3.fromRGB(36, 26, 20),
        TitleText = Color3.fromRGB(253, 186, 116),
        Accent = Color3.fromRGB(234, 88, 12),
        TabBg = Color3.fromRGB(36, 26, 20),
        TabText = Color3.fromRGB(253, 186, 116),
        ActiveTabBg = Color3.fromRGB(234, 88, 12),
        ActiveTabText = Color3.fromRGB(24, 18, 14),
        CardBg = Color3.fromRGB(36, 26, 20),
        CardStroke = Color3.fromRGB(234, 88, 12),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(255, 140, 0)
    },
    Purple = {
        MainBg = Color3.fromRGB(20, 14, 28),
        TopBarBg = Color3.fromRGB(29, 20, 41),
        TitleText = Color3.fromRGB(216, 180, 254),
        Accent = Color3.fromRGB(147, 51, 234),
        TabBg = Color3.fromRGB(29, 20, 41),
        TabText = Color3.fromRGB(216, 180, 254),
        ActiveTabBg = Color3.fromRGB(147, 51, 234),
        ActiveTabText = Color3.fromRGB(20, 14, 28),
        CardBg = Color3.fromRGB(29, 20, 41),
        CardStroke = Color3.fromRGB(147, 51, 234),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(230, 80, 255)
    },
    Kazakhstan = {
        MainBg = Color3.fromRGB(12, 32, 45),       
        TopBarBg = Color3.fromRGB(0, 155, 210),     
        TitleText = Color3.fromRGB(255, 215, 0),    
        Accent = Color3.fromRGB(255, 215, 0),       
        TabBg = Color3.fromRGB(16, 46, 64),
        TabText = Color3.fromRGB(0, 180, 240),
        ActiveTabBg = Color3.fromRGB(255, 215, 0),  
        ActiveTabText = Color3.fromRGB(12, 32, 45),
        CardBg = Color3.fromRGB(16, 46, 64),
        CardStroke = Color3.fromRGB(255, 215, 0),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(255, 215, 0) 
    }
}

-- Функция обновления темы интерфейса
local function updateTheme(themeName)
    local currentTheme = themes[themeName]
    if not currentTheme then return end

    MainFrame.BackgroundColor3 = currentTheme.MainBg
    TopBar.BackgroundColor3 = currentTheme.TopBarBg
    TopBarFix.BackgroundColor3 = currentTheme.TopBarBg
    HubTitle.TextColor3 = currentTheme.TitleText
    AccentLine.BackgroundColor3 = currentTheme.Accent
    CreditsCard.BackgroundColor3 = currentTheme.CardBg
    CreditsStroke.Color = currentTheme.CardStroke
    
    ToggleButton.BackgroundColor3 = currentTheme.TabBg
    ToggleButton.TextColor3 = currentTheme.TitleText
    ToggleStroke.Color = currentTheme.Accent

    -- Логика ярких неоновых обводок вокруг выбранной темы
    for tName, stroke in pairs(themeStrokes) do
        if tName == themeName then
            stroke.Enabled = true
            stroke.Color = currentTheme.SelectedStrokeColor
            stroke.Thickness = 2.5
        else
            stroke.Enabled = false
        end -- Ошибка исправлена здесь!
    end

    -- Адаптация текстов внутри страниц Кастомизации и Инфо
    for _, pageName in ipairs({"Theme", "Info"}) do
        if pages[pageName] then
            for _, object in ipairs(pages[pageName]:GetDescendants()) do
                if object:IsA("TextLabel") and not object.Name:find("Btn") then
                    object.TextColor3 = currentTheme.LabelText
                end
            end
        end
    end
end

-- Логика переключения табов
local function switchTab(activeName)
    currentActiveTab = activeName
    local currentTheme = themes[currentThemeName]
    
    for name, page in pairs(pages) do
        page.Visible = (name == activeName)
    end
    
    for name, button in pairs(tabs) do
        if name == activeName then
            button.BackgroundColor3 = currentTheme.ActiveTabBg
            button.TextColor3 = currentTheme.ActiveTabText
        else
            button.BackgroundColor3 = currentTheme.TabBg
            button.TextColor3 = currentTheme.TabText
        end
    end
end

-- Конструктор вкладок
local function createTab(name, layoutOrder)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 32)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamBold
    TabButton.ZIndex = 3
    TabButton.LayoutOrder = layoutOrder
    TabButton.Parent = TabsContainer

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local Page = Instance.new("Frame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ZIndex = 2
    Page.Parent = ContentFrame

    pages[name] = Page
    tabs[name] = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end
-- ЧАСТЬ 3 (Полностью скопируй и замени ею прошлую третью часть на GitHub)

-- Инициализация системных окон хаба
createTab("Main", 1)
createTab("Player", 2)
createTab("AutoFarm", 3)
createTab("Theme", 4)
createTab("Info", 5)

---------------------------------------------------------------------------
-- НАСТРОЙКА ВКЛАДКИ PLAYER (Движение и ESP для MM2)
---------------------------------------------------------------------------
local PlayerPage = pages["Player"]

-- Настройка вертикального списка элементов страницы Player
local PlayerList = Instance.new("UIListLayout")
PlayerList.Padding = UDim.new(0, 12)
PlayerList.SortOrder = Enum.SortOrder.LayoutOrder
PlayerList.Parent = PlayerPage

local PlayerPadding = Instance.new("UIPadding")
PlayerPadding.PaddingLeft = UDim.new(0, 15)
PlayerPadding.PaddingTop = UDim.new(0, 12)
PlayerPadding.PaddingRight = UDim.new(0, 15)
PlayerPadding.Parent = PlayerPage

-- Хранилище настроек движения персонажа
local currentWalkSpeed = 16
local currentJumpPower = 50

-- Функция создания текстовых заголовков разделов (Movement, Visuals)
local function createSectionHeader(text, layoutOrder)
    local header = Instance.new("TextLabel")
    header.Name = "Header_" .. text
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = text:upper()
    header.Font = Enum.Font.GothamBold
    header.TextSize = 15
    header.TextColor3 = Color3.fromRGB(240, 240, 240)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = layoutOrder
    header.ZIndex = 3
    header.Parent = PlayerPage
end

-- Универсальная функция создания плавных ползунков (Sliders)
local function createSlider(text, min, max, default, step, layoutOrder, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = text .. "SliderFrame"
    sliderFrame.Size = UDim2.new(1, 0, 0, 45)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = layoutOrder
    sliderFrame.Parent = PlayerPage

    local title = Instance.new("TextLabel")
    title.Name = "SliderTitle"
    title.Size = UDim2.new(1, 0, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = text .. ": " .. tostring(default)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(180, 180, 180)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = sliderFrame

    local track = Instance.new("TextButton")
    track.Name = "SliderTrack"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 25)
    track.BackgroundColor3 = Color3.fromRGB(35, 45, 35)
    track.Text = ""
    track.AutoButtonColor = false
    track.ZIndex = 3
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "SliderFill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Будет гармонировать с основной темой
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local holding = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local rawValue = min + (max - min) * pos
        local value = math.floor(rawValue / step + 0.5) * step
        value = math.clamp(value, min, max)
        
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        title.Text = text .. ": " .. tostring(value)
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = true
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = false
        end
    end)
end

-- Создаём блок Движения
createSectionHeader("Movement", 1)

createSlider("WalkSpeed", 0, 50, 16, 0.5, 2, function(value)
    currentWalkSpeed = value
end)

createSlider("JumpPower", 0, 200, 50, 1, 3, function(value)
    currentJumpPower = value
end)

-- Создаём блок Визуалов (ESP)
createSectionHeader("Visuals", 4)

local espToggleFrame = Instance.new("Frame")
espToggleFrame.Name = "EspToggleFrame"
espToggleFrame.Size = UDim2.new(1, 0, 0, 32)
espToggleFrame.BackgroundTransparency = 1
espToggleFrame.LayoutOrder = 5
espToggleFrame.Parent = PlayerPage

local espBtn = Instance.new("TextButton")
espBtn.Name = "EspToggleBtn"
espBtn.Size = UDim2.new(0, 130, 1, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
espBtn.Text = "ESP: OFF"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
espBtn.TextSize = 13
espBtn.ZIndex = 3
espBtn.Parent = espToggleFrame

local espBtnCorner = Instance.new("UICorner")
espBtnCorner.CornerRadius = UDim.new(0, 6)
espBtnCorner.Parent = espBtn

local espStroke = Instance.new("UIStroke")
espStroke.Color = Color3.fromRGB(239, 68, 68)
espStroke.Thickness = 1
espStroke.Parent = espBtn

---------------------------------------------------------------------------
-- СИСТЕМНАЯ ЛОГИКА ESP И ДВИЖЕНИЯ (Многопоточность)
---------------------------------------------------------------------------
local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "PutinHub_ESP"
espFolder.Parent = CoreGui -- Чтобы никто случайно не стёр из Workspace

local originalSheriff = nil

-- Обработчик клика по кнопке включения/выключения ESP
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP: ON"
        espBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
        espStroke.Color = Color3.fromRGB(34, 197, 94)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
        espStroke.Color = Color3.fromRGB(239, 68, 68)
        espFolder:ClearAllChildren()
        originalSheriff = nil
    end
end)

-- Постоянный цикл удержания WalkSpeed и JumpPower персонажа
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                if hum.WalkSpeed ~= currentWalkSpeed then
                    hum.WalkSpeed = currentWalkSpeed
                end
                if hum.JumpPower ~= currentJumpPower then
                    hum.UseJumpPower = true
                    hum.JumpPower = currentJumpPower
                end
            end
        end)
    end
end)

-- Умный цикл трекинга ролей в MM2 и отрисовки Highlight ESP
task.spawn(function()
    while task.wait(0.4) do
        if not espEnabled then continue end

        pcall(function()
            local knifeFound = false
            local gunHolders = {}

            -- Первичный скан инвентарей всех игроков на сервере
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                        knifeFound = true
                    end
                    if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                        table.insert(gunHolders, p)
                    end
                end
            end

            -- Автоматический сброс/определение изначального Шерифа при смене раундов
            if not knifeFound and #gunHolders == 0 then
                originalSheriff = nil -- Оружия нет, мы в Лобби
            elseif #gunHolders > 0 and originalSheriff == nil then
                originalSheriff = gunHolders[1].Name -- Первый зафиксированный владелец пистолета — Шериф
            end

            -- Собираем список текущих визуальных подсветок
            local currentVisuals = {}
            for _, hl in ipairs(espFolder:GetChildren()) do
                if hl:IsA("Highlight") and hl.Adornee then
                    currentVisuals[hl.Adornee] = hl
                end
            end

            -- Отрисовка ESP с разделением по цветам
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local char = p.Character
                    
                    -- По умолчанию все — Невинные (Зелёный)
                    local color = Color3.fromRGB(34, 197, 94) 
                    
                    if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                        -- Убийца (Красный)
                        color = Color3.fromRGB(239, 68, 68)
                    elseif p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
                        if originalSheriff == p.Name then
                            -- Шериф (Синий)
                            color = Color3.fromRGB(59, 130, 246)
                        else
                            -- Герой, который подобрал ствол (Жёлтый!)
                            color = Color3.fromRGB(234, 179, 8)
                        end
                    end

                    -- Создаём или обновляем Highlight для игрока
                    local hl = currentVisuals[char]
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = p.Name .. "_Highlight"
                        hl.Adornee = char
                        hl.Parent = espFolder
                    end
                    
                    hl.FillColor = color
                    hl.FillTransparency = 0.55
                    hl.OutlineColor = color
                    hl.OutlineTransparency = 0
                    
                    currentVisuals[char] = nil -- Игрок обработан, удалять его подсветку не нужно
                end
            end

            -- Чистим подсветку тех, кто вышел или погиб
            for char, hl in pairs(currentVisuals) do
                hl:Destroy()
            end
        end)
    end
end)

---------------------------------------------------------------------------
-- ТЕМЫ И ИНФОРМАЦИЯ (Кастомизация окон хаба)
---------------------------------------------------------------------------
-- Настройка вкладки Theme
local ThemePage = pages["Theme"]
local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0, 72, 0, 80)
ThemeGrid.CellPadding = UDim2.new(0, 12, 0, 12)
ThemeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThemeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
ThemeGrid.Parent = ThemePage

local function createThemeBlock(themeKey, blockColor, displayName)
    local blockFrame = Instance.new("Frame")
    blockFrame.Name = themeKey .. "Container"
    blockFrame.BackgroundTransparency = 1
    blockFrame.ZIndex = 3
    blockFrame.Parent = ThemePage

    local colorBtn = Instance.new("TextButton")
    colorBtn.Name = themeKey .. "Btn"
    colorBtn.Size = UDim2.new(1, 0, 0, 46)
    colorBtn.BackgroundColor3 = blockColor
    colorBtn.Text = ""
    colorBtn.AutoButtonColor = true
    colorBtn.ZIndex = 3
    colorBtn.Parent = blockFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = colorBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Enabled = false
    btnStroke.Parent = colorBtn
    themeStrokes[themeKey] = btnStroke

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = themeKey .. "Label"
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 50)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayName
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.ZIndex = 3
    nameLabel.Parent = blockFrame

    colorBtn.MouseButton1Click:Connect(function()
        currentThemeName = themeKey
        updateTheme(themeKey)
        switchTab(currentActiveTab)
    end)
end

createThemeBlock("White", Color3.fromRGB(240, 240, 240), "White")
createThemeBlock("Black", Color3.fromRGB(35, 35, 35), "Black")
createThemeBlock("Green", Color3.fromRGB(34, 197, 94), "Green")
createThemeBlock("Blue", Color3.fromRGB(30, 90, 220), "Blue")
createThemeBlock("Orange", Color3.fromRGB(234, 88, 12), "Orange")
createThemeBlock("Purple", Color3.fromRGB(130, 40, 210), "Purple")
createThemeBlock("Kazakhstan", Color3.fromRGB(0, 155, 210), "Kazakh")

-- НАПОЛНЕНИЕ ВКЛАДКИ INFO (Красивое вертикальное меню контактов)
local InfoPage = pages["Info"]

local InfoList = Instance.new("UIListLayout")
InfoList.Padding = UDim.new(0, 4)
InfoList.SortOrder = Enum.SortOrder.LayoutOrder
InfoList.Parent = InfoPage

local InfoPadding = Instance.new("UIPadding")
InfoPadding.PaddingLeft = UDim.new(0, 15)
InfoPadding.PaddingTop = UDim.new(0, 10)
InfoPadding.Parent = InfoPage

local function createInfoLine(text, layoutOrder, isHeader)
    local label = Instance.new("TextLabel")
    label.Name = "InfoLabel_" .. layoutOrder
    label.Size = UDim2.new(1, -20, 0, isHeader and 22 or 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = isHeader and 15 or 13
    label.Font = isHeader and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = layoutOrder
    label.ZIndex = 3
    label.Parent = InfoPage
end

-- Твои обновленные данные
createInfoLine("📋 СВЕДЕНИЯ О СКРИПТЕ", 1, true)
createInfoLine("• Версия: 3.9.1 (Kazakhstan Edition)", 2)
createInfoLine("• Created by: PavelDurak", 3)
createInfoLine("• Telegram: @vamatuk", 4)
createInfoLine("• Discord: pavel_durak", 5)
createInfoLine("──────────────────────────────────", 6)
createInfoLine("🚀 ОТ РАЗРАБОТЧИКА", 7, true)
createInfoLine("Скрипт полностью переведён на безопасный режим.", 8)

-- Меню безопасности при закрытии (ConfirmFrame)
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Name = "ConfirmFrame"
ConfirmFrame.Size = UDim2.new(0, 260, 0, 120)
ConfirmFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(22, 33, 22)
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = false
ConfirmFrame.Active = true
ConfirmFrame.Draggable = true
ConfirmFrame.ZIndex = 5
ConfirmFrame.Parent = PutinHub

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 8)
ConfirmCorner.Parent = ConfirmFrame

local ConfirmStroke = Instance.new("UIStroke")
ConfirmStroke.Color = Color3.fromRGB(239, 68, 68)
ConfirmStroke.Thickness = 1.5
ConfirmStroke.Parent = ConfirmFrame

local ConfirmLabel = Instance.new("TextLabel")
ConfirmLabel.Name = "ConfirmLabel"
ConfirmLabel.Size = UDim2.new(1, -20, 0, 40)
ConfirmLabel.Position = UDim2.new(0, 10, 0, 15)
ConfirmLabel.BackgroundTransparency = 1
ConfirmLabel.Text = "Закрыть Hub?"
ConfirmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmLabel.TextSize = 16
ConfirmLabel.Font = Enum.Font.GothamBold
ConfirmLabel.TextWrapped = true
ConfirmLabel.ZIndex = 5
ConfirmLabel.Parent = ConfirmFrame

local YesButton = Instance.new("TextButton")
YesButton.Name = "YesButton"
YesButton.Size = UDim2.new(0, 100, 0, 32)
YesButton.Position = UDim2.new(0, 20, 1, -45)
YesButton.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
YesButton.Text = "Да, закрыть"
YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
YesButton.TextSize = 13
YesButton.Font = Enum.Font.GothamBold
YesButton.ZIndex = 5
YesButton.Parent = ConfirmFrame

local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0, 6)
YesCorner.Parent = YesButton

local NoButton = Instance.new("TextButton")
NoButton.Name = "NoButton"
NoButton.Size = UDim2.new(0, 100, 0, 32)
NoButton.Position = UDim2.new(1, -120, 1, -45)
NoButton.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
NoButton.Text = "Отмена"
NoButton.TextColor3 = Color3.fromRGB(74, 222, 128)
NoButton.TextSize = 13
NoButton.Font = Enum.Font.GothamBold
NoButton.ZIndex = 5
NoButton.Parent = ConfirmFrame

local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0, 6)
NoCorner.Parent = NoButton

-- Слушатели кликов
CloseButton.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = true
end)

YesButton.MouseButton1Click:Connect(function()
    espFolder:Destroy()
    PutinHub:Destroy()
end)

NoButton.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Первоначальный запуск интерфейса в дефолтном стиле
updateTheme("Green")
switchTab("Main")
