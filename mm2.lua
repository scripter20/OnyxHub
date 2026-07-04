-- PutinHub Version: 3.9
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

-- Настройки всех 7 цветовых тем хаба (С заменой на Казахстан)
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
        MainBg = Color3.fromRGB(12, 32, 45),       -- Глубокий бирюзово-синий
        TopBarBg = Color3.fromRGB(0, 155, 210),     -- Яркий небесно-голубой
        TitleText = Color3.fromRGB(255, 215, 0),    -- Золотой текст названия
        Accent = Color3.fromRGB(255, 215, 0),       -- Золотой разделитель
        TabBg = Color3.fromRGB(16, 46, 64),
        TabText = Color3.fromRGB(0, 180, 240),
        ActiveTabBg = Color3.fromRGB(255, 215, 0),  -- Золотая активная вкладка
        ActiveTabText = Color3.fromRGB(12, 32, 45),
        CardBg = Color3.fromRGB(16, 46, 64),
        CardStroke = Color3.fromRGB(255, 215, 0),
        LabelText = Color3.fromRGB(255, 255, 255),
        SelectedStrokeColor = Color3.fromRGB(255, 215, 0) -- Мощное неоново-золотое свечение кнопки
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
        end
    end

    -- Адаптация текстов внутри страницы кастомизации
    if pages["Theme"] then
        for _, object in ipairs(pages["Theme"]:GetDescendants()) do
            if object:IsA("TextLabel") and not object.Name:find("Btn") then
                object.TextColor3 = currentTheme.LabelText
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
-- ЧАСТЬ 3 (Скопируй и вставь сразу под второй частью в свой файл на GitHub)

-- Инициализация системных окон хаба
createTab("Main", 1)
createTab("Player", 2)
createTab("AutoFarm", 3)
createTab("Theme", 4)
createTab("Info", 5)

-- Настройка автоматической адаптивной сетки под 7 элементов
local ThemePage = pages["Theme"]

local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0, 72, 0, 80)
ThemeGrid.CellPadding = UDim2.new(0, 12, 0, 12)
ThemeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThemeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
ThemeGrid.Parent = ThemePage

-- Вспомогательный генератор карточек тем
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

    -- Обводка для красивого яркого выделения
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

-- Генерация 7 интерактивных кнопок палитр
createThemeBlock("White", Color3.fromRGB(240, 240, 240), "White")
createThemeBlock("Black", Color3.fromRGB(35, 35, 35), "Black")
createThemeBlock("Green", Color3.fromRGB(34, 197, 94), "Green")
createThemeBlock("Blue", Color3.fromRGB(30, 90, 220), "Blue")
createThemeBlock("Orange", Color3.fromRGB(234, 88, 12), "Orange")
createThemeBlock("Purple", Color3.fromRGB(130, 40, 210), "Purple")
createThemeBlock("Kazakhstan", Color3.fromRGB(0, 155, 210), "Kazakh") -- Плитка небесно-голубого цвета

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

