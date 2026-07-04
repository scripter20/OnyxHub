-- ===========================================================================
-- PUTIN HUB (Murder Mystery 2 Edition) - ПОЛНАЯ СБОРКА (ЧАСТИ 1, 2 и 3)
-- Оптимизировано для мобильных устройств (Nothing Phone 3a)
-- ===========================================================================

---------------------------------------------------------------------------
-- ЧАСТЬ 1: ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ И СОЗДАНИЕ ОСНОВЫ ИНТЕРФЕЙСА
---------------------------------------------------------------------------
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Защита от дублирования скрипта
if CoreGui:FindFirstChild("PutinHub") then
    CoreGui.PutinHub:Destroy()
end

-- Создание главного контейнера интерфейса
local PutinHub = Instance.new("ScreenGui")
PutinHub.Name = "PutinHub"
PutinHub.Parent = CoreGui
PutinHub.ResetOnSpawn = false

-- Главное окно Хаба
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 310)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true -- Удобное перетаскивание пальцем на экране телефона
MainFrame.Parent = PutinHub

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(34, 197, 94)
MainStroke.Parent = MainFrame

-- Боковая панель навигации (Сайдбар)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 125, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 9)
SidebarCorner.Parent = Sidebar

-- Скрытие правых углов сайдбара для красивого стыка с основным окном
local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 12, 1, 0)
SidebarFix.Position = UDim2.new(1, -12, 0, 0)
SidebarFix.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 42)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Логотип / Название хаба
local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 30)
HubTitle.Position = UDim2.new(0, 0, 0, 6)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "PUTIN HUB"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Parent = MainFrame

-- Контейнер для страниц вкладок
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -135, 1, -45)
Container.Position = UDim2.new(0, 130, 0, 38)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Системная кнопка закрытия меню (Крестик)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(239, 68, 68)
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Плавающая кнопка-иконка открытия/закрытия для мобильных экранов
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 44, 0, 44)
ToggleButton.Position = UDim2.new(0, 15, 0, 15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Text = "P"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.ZIndex = 10
ToggleButton.Parent = PutinHub

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 22)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 1.5
ToggleStroke.Color = Color3.fromRGB(34, 197, 94)
ToggleStroke.Parent = ToggleButton

-- Глобальные таблицы состояний
local pages = {}
local tabButtons = {}
local themeStrokes = {}
local currentThemeName = "Green"
local currentActiveTab = "Main"

---------------------------------------------------------------------------
-- ЧАСТЬ 2: СИСТЕМНЫЕ ФУНКЦИИ (УПРАВЛЕНИЕ ТАБАМИ И СТИЛЯМИ ТЕМ)
---------------------------------------------------------------------------
local themes = {
    White = Color3.fromRGB(240, 240, 240),
    Black = Color3.fromRGB(35, 35, 35),
    Green = Color3.fromRGB(34, 197, 94),
    Blue = Color3.fromRGB(30, 90, 220),
    Orange = Color3.fromRGB(234, 88, 12),
    Purple = Color3.fromRGB(130, 40, 210),
    Kazakhstan = Color3.fromRGB(0, 155, 210)
}

local function updateTheme(themeKey)
    local color = themes[themeKey] or themes.Green
    MainStroke.Color = color
    ToggleStroke.Color = color
    
    for name, stroke in pairs(themeStrokes) do
        if name == themeKey then
            stroke.Enabled = true
            stroke.Color = color
            stroke.Thickness = 2
        else
            stroke.Enabled = false
        end
    end

    for tName, btn in pairs(tabButtons) do
        if tName == currentActiveTab then
            btn.TextColor3 = color
        else
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

local function switchTab(tabName)
    currentActiveTab = tabName
    for pName, page in pairs(pages) do
        if pName == tabName then
            page.Visible = true
        else
            page.Visible = false
        end
    end
    updateTheme(currentThemeName)
end

local function createTab(name, layoutOrder)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabBtn.LayoutOrder = layoutOrder
    tabBtn.Parent = Sidebar

    tabButtons[name] = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = Container

    pages[name] = page

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    -- Динамический пересчет высоты контента, чтобы на телефонах плавно работала прокрутка
    page.ChildAdded:Connect(function()
        task.wait(0.05)
        local list = page:FindFirstChildOfClass("UIListLayout")
        if list then
            page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 25)
        end
    end)
end

---------------------------------------------------------------------------
-- ЧАСТЬ 3: ИНИЦИАЛИЗАЦИЯ ВКЛАДОК, НАСТРОЙКА ФУНКЦИЙ И ЦИКЛЫ РАБОТЫ МЕНЮ
---------------------------------------------------------------------------

-- Создаём структуру вкладок
createTab("Main", 1)
createTab("Player", 2)
createTab("AutoFarm", 3)
createTab("Theme", 4)
createTab("Info", 5)

-- Хелпер для разметки красивых жирных заголовков подразделов
local function createSectionHeader(page, text, layoutOrder)
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
    header.Parent = page
end

---------------------------------------------------------------------------
-- НАСТРОЙКА ВКЛАДКИ MAIN (Умный ESP и Ники для MM2)
---------------------------------------------------------------------------
local MainPage = pages["Main"]

local MainList = Instance.new("UIListLayout")
MainList.Padding = UDim.new(0, 12)
MainList.SortOrder = Enum.SortOrder.LayoutOrder
MainList.Parent = MainPage

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingLeft = UDim.new(0, 15)
MainPadding.PaddingTop = UDim.new(0, 12)
MainPadding.PaddingRight = UDim.new(0, 15)
MainPadding.Parent = MainPage

createSectionHeader(MainPage, "Visuals", 1)

local espToggleFrame = Instance.new("Frame")
espToggleFrame.Name = "EspToggleFrame"
espToggleFrame.Size = UDim2.new(1, 0, 0, 34)
espToggleFrame.BackgroundTransparency = 1
espToggleFrame.LayoutOrder = 2
espToggleFrame.Parent = MainPage

local espBtn = Instance.new("TextButton")
espBtn.Name = "EspToggleBtn"
espBtn.Size = UDim2.new(0, 140, 1, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
espBtn.Text = "ESP & NAMES: OFF"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
espBtn.TextSize = 11
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
-- НАСТРОЙКА ВКЛАДКИ PLAYER (Слайдеры движения)
---------------------------------------------------------------------------
local PlayerPage = pages["Player"]

local PlayerList = Instance.new("UIListLayout")
PlayerList.Padding = UDim.new(0, 12)
PlayerList.SortOrder = Enum.SortOrder.LayoutOrder
PlayerList.Parent = PlayerPage

local PlayerPadding = Instance.new("UIPadding")
PlayerPadding.PaddingLeft = UDim.new(0, 15)
PlayerPadding.PaddingTop = UDim.new(0, 12)
PlayerPadding.PaddingRight = UDim.new(0, 15)
PlayerPadding.Parent = PlayerPage

createSectionHeader(PlayerPage, "Movement", 1)

local currentWalkSpeed = 16
local currentJumpPower = 50

local function createSlider(text, min, max, default, step, layoutOrder)
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
    fill.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
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
        
        if text == "WalkSpeed" then currentWalkSpeed = value
        elseif text == "JumpPower" then currentJumpPower = value end
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

createSlider("WalkSpeed", 0, 50, 16, 0.5, 2)
createSlider("JumpPower", 0, 200, 50, 1, 3)

---------------------------------------------------------------------------
-- СИСТЕМНАЯ ЛОГИКА УМНОГО МАКСИМАЛЬНО ОПТИМИЗИРОВАННОГО ESP
---------------------------------------------------------------------------
local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "PutinHub_ESP"
espFolder.Parent = CoreGui

local originalSheriff = nil

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP & NAMES: ON"
        espBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
        espStroke.Color = Color3.fromRGB(34, 197, 94)
    else
        espBtn.Text = "ESP & NAMES: OFF"
        espBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
        espStroke.Color = Color3.fromRGB(239, 68, 68)
        espFolder:ClearAllChildren()
        originalSheriff = nil
    end
end)

-- Многопоточный вечный цикл контроля скорости и прыжка
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                if hum.WalkSpeed ~= currentWalkSpeed then hum.WalkSpeed = currentWalkSpeed end
                if hum.JumpPower ~= currentJumpPower then
                    hum.UseJumpPower = true
                    hum.JumpPower = currentJumpPower
                end
            end
        end)
    end
end)

-- Глобальный точный цикл отслеживания ролей в MM2 + Ники + Обводка силуэтов
task.spawn(function()
    while task.wait(0.4) do
        if not espEnabled then continue end

        pcall(function()
            local knifeFound = false
            local gunHolders = {}

            -- Сканируем ВСЕХ на сервере для идеального вычисления текущей фазы раунда
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                        knifeFound = true
                    end
                    if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                        table.insert(gunHolders, p.Name)
                    end
                end
            end

            -- Автоматическое переключение Шериф / Герой
            if not knifeFound and #gunHolders == 0 then
                originalSheriff = nil
            elseif #gunHolders > 0 and originalSheriff == nil then
                originalSheriff = gunHolders[1] -- Самый первый владелец ствола — истинный Шериф
            end

            -- Таблица текущего кэша отрисованных визуальных элементов
            local currentVisuals = {}
            for _, obj in ipairs(espFolder:GetChildren()) do
                if (obj:IsA("Highlight") or obj:IsA("BillboardGui")) and obj.Adornee then
                    currentVisuals[obj.Name] = obj
                end
            end

            -- Рендеринг ESP и цветных ников над головами врагов/союзников
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
                    local char = p.Character
                    local color = Color3.fromRGB(34, 197, 94) -- По умолчанию: зеленый (Невинный)

                    if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                        color = Color3.fromRGB(239, 68, 68) -- Убийца (Красный)
                    elseif p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
                        if originalSheriff == p.Name then
                            color = Color3.fromRGB(59, 130, 246) -- Шериф (Синий)
                        else
                            color = Color3.fromRGB(234, 179, 8) -- Герой, который подобрал ствол (Желтый)
                        end
                    end

                    local hlName = p.Name .. "_HL"
                    local nameTagName = p.Name .. "Tag"

                    -- Рендеринг силуэта через Highlight
                    local hl = currentVisuals[hlName]
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = hlName
                        hl.Adornee = char
                        hl.Parent = espFolder
                    else
                        currentVisuals[hlName] = nil
                    end
                    hl.FillColor = color
                    hl.FillTransparency = 0.6
                    hl.OutlineColor = color
                    hl.OutlineTransparency = 0

                    -- Рендеринг 3D-текста Ника над головой игрока
                    local bgui = currentVisuals[nameTagName]
                    if not bgui then
                        bgui = Instance.new("BillboardGui")
                        bgui.Name = nameTagName
                        bgui.Size = UDim2.new(0, 120, 0, 24)
                        bgui.StudsOffset = Vector3.new(0, 2.8, 0)
                        bgui.AlwaysOnTop = true
                        bgui.Adornee = char.Head
                        bgui.Parent = espFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Name = "TextLabel"
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = p.Name
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12
                        lbl.TextStrokeTransparency = 0
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.Parent = bgui
                    else
                        currentVisuals[nameTagName] = nil
                    end
                    bgui.TextLabel.TextColor3 = color
                end
            end

            -- Автоматическая очистка памяти Nothing 3a от сущностей мертвых/вышедших игроков
            for _, obj in pairs(currentVisuals) do
                obj:Destroy()
            end
        end)
    end
end)

---------------------------------------------------------------------------
-- НАСТРОЙКА ОСТАЛЬНЫХ ВКЛАДОК (THEME, INFO, CONFIRMATION)
