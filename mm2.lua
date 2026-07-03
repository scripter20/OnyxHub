-- MM2 PutinHub | Часть 1
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui")
gui.Name = "PutinHub"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Основной фрейм
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 450, 0, 320)
main.Position = UDim2.new(0.5, -225, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
title.Text = "MM2 PutinHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Контейнер для вкладок
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabFrame.BorderSizePixel = 0
tabFrame.Parent = main

-- Контейнер контента
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -60)
content.Position = UDim2.new(0, 0, 0, 60)
content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
content.BorderSizePixel = 0
content.Parent = main

-- Создаём вкладки
local tabs = {"General","Player","Teleport"}
local selectedTab = nil
local tabButtons = {}

for i, name in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*150, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = tabFrame
    tabButtons[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = (name == "General")
    page.Parent = content

    if name == "General" then selectedTab = page end

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(content:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        page.Visible = true
        selectedTab = page
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    end)
end

-- Вспомогательная функция для создания тоггла (красный/зелёный)
local function createToggle(parent, text, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- выключен
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame

    local state = false
    local connection

    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            toggle.Text = "ON"
        else
            toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            toggle.Text = "OFF"
        end
        if connection then connection(state) end
    end)

    return {
        Frame = frame,
        SetState = function(s)
            if state ~= s then
                state = s
                if state then
                    toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    toggle.Text = "ON"
                else
                    toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    toggle.Text = "OFF"
                end
                if connection then connection(state) end
            end
        end,
        OnToggle = function(self, func)
            connection = func
        end,
    }
end

-- Вспомогательная функция для ползунка
local function createSlider(parent, text, min, max, default, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 55)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. " (0)"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 20, 1, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderFrame

    local value = default
    local connection
    local function updateThumb()
        local frac = (value-min)/(max-min)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        thumb.Position = UDim2.new(frac, -10, 0, 0)
        label.Text = text .. " (" .. math.floor(value) .. ")"
    end
    updateThumb()

    local dragging = false
    thumb.MouseButton1Down:Connect(function()
        dragging = true
    end)
    mouse.Move:Connect(function()
        if dragging then
            local relX = mouse.X - sliderFrame.AbsolutePosition.X
            local frac = math.clamp(relX / sliderFrame.AbsoluteSize.X, 0, 1)
            value = min + frac * (max - min)
            updateThumb()
            if connection then connection(value) end
        end
    end)
    mouse.Button1Up:Connect(function()
        dragging = false
    end)

    return {
        Frame = frame,
        SetValue = function(v)
            value = math.clamp(v, min, max)
            updateThumb()
            if connection then connection(value) end
        end,
        OnChange = function(self, func)
            connection = func
        end,
    }
end

-- Заполняем страницы тогглами и ползунками
-- General page
local generalPage = content:FindFirstChild("ScrollingFrame")
local generalY = 5
local autoFarmToggle = createToggle(generalPage, "AutoFarm", generalY)
generalY = generalY + 45
local antiFlingToggle = createToggle(generalPage, "Anti-fling", generalY)
generalY = generalY + 45
local antiAFKToggle = createToggle(generalPage, "AntiAFK", generalY)
generalY = generalY + 45
local espToggle = createToggle(generalPage, "ESP", generalY)
generalPage.CanvasSize = UDim2.new(0, 0, 0, generalY + 45)

-- Player page (создадим позже во 2-й части, пока объявим)
local playerPage = Instance.new("ScrollingFrame")
playerPage.Size = UDim2.new(1, 0, 1, 0)
playerPage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerPage.BorderSizePixel = 0
playerPage.ScrollBarThickness = 6
playerPage.CanvasSize = UDim2.new(0, 0, 0, 0)
playerPage.Visible = false
playerPage.Parent = content

-- Teleport page
local teleportPage = Instance.new("ScrollingFrame")
teleportPage.Size = UDim2.new(1, 0, 1, 0)
teleportPage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportPage.BorderSizePixel = 0
teleportPage.ScrollBarThickness = 6
teleportPage.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportPage.Visible = false
teleportPage.Parent = content

-- Сохраняем ссылки для последующего использования
_G.PutinHub = {
    Toggles = {
        AutoFarm = autoFarmToggle,
        AntiFling = antiFlingToggle,
        AntiAFK = antiAFKToggle,
        ESP = espToggle,
    },
    Pages = {
        General = generalPage,
        Player = playerPage,
        Teleport = teleportPage,
    }
}
-- MM2 PutinHub | Часть 2
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local virtualInput = game:GetService("VirtualInputManager")
local uis = game:GetService("UserInputService")

local hub = _G.PutinHub
local toggles = hub.Toggles
local pages = hub.Pages

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
    -- Обновим NoClip, InfJump если включены
    if noClipEnabled then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    if infJumpEnabled then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end)

-- ========== AutoFarm ==========
local autoFarmEnabled = false
local autoFarmCoin = nil
toggles.AutoFarm:OnToggle(function(on)
    autoFarmEnabled = on
    if on then
        -- Запускаем цикл фарма
        spawn(function()
            while autoFarmEnabled do
                if not char or not rootPart then wait(0.5) continue end
                -- Ищем монеты (обычно "Coin" в Workspace)
                local coins = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "Coin" and obj:IsA("BasePart") then
                        table.insert(coins, obj)
                    end
                end
                if #coins == 0 then
                    wait(0.5)
                    continue
                end
                -- Сортируем по расстоянию
                table.sort(coins, function(a,b)
                    return (rootPart.Position - a.Position).Magnitude < (rootPart.Position - b.Position).Magnitude
                end)
                local target = coins[1]
                -- Проверка заполненности мешка (обычно Bag IntValue в leaderstats)
                local bag = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Bag")
                local maxBag = 40 -- типичный максимум в MM2
                if bag and bag.Value >= maxBag then
                    wait(1) -- ждём новый раунд
                    continue
                end
                -- Летим к монете с NoClip (временно включаем, если не включен)
                local tween = tweenService:Create(rootPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = target.CFrame + Vector3.new(0, 3, 0)})
                tween:Play()
                tween.Completed:Wait()
                wait(0.1)
            end
        end)
    end
end)

-- ========== Anti-fling ==========
local antiFlingEnabled = false
local lastPos = rootPart.Position
toggles.AntiFling:OnToggle(function(on)
    antiFlingEnabled = on
    if on then
        lastPos = rootPart.Position
        spawn(function()
            while antiFlingEnabled do
                if rootPart and (rootPart.Position - lastPos).Magnitude > 200 then
                    -- Возвращаем на место
                    rootPart.CFrame = CFrame.new(lastPos)
                end
                lastPos = rootPart.Position
                runService.Heartbeat:Wait()
            end
        end)
    end
end)

-- ========== AntiAFK ==========
local antiAFKEnabled = false
toggles.AntiAFK:OnToggle(function(on)
    antiAFKEnabled = on
    if on then
        spawn(function()
            while antiAFKEnabled do
                virtualInput:SendMouseMoveEvent(10, 10, game)
                wait(300) -- каждые 5 минут
            end
        end)
    end
end)

-- ========== ESP ==========
local espEnabled = false
local highlights = {} -- player -> Highlight
toggles.ESP:OnToggle(function(on)
    espEnabled = on
    if not on then
        -- Удаляем все подсветки
        for p, hl in pairs(highlights) do
            hl:Destroy()
        end
        highlights = {}
        return
    end
    -- Функция обновления подсветки для всех игроков
    local function updateESP()
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr == player then continue end
            local roleObj = plr:FindFirstChild("Role") or plr.Character and plr.Character:FindFirstChild("Role")
            local role = "Innocent"
            if roleObj and roleObj:IsA("StringValue") then
                role = roleObj.Value
            end
            local color
            if role == "Murderer" then
                color = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                color = Color3.fromRGB(0, 100, 255)
            else
                color = Color3.fromRGB(0, 255, 0)
            end

            local charPlr = plr.Character
            if charPlr and not highlights[plr] then
                local hl = Instance.new("Highlight")
                hl.FillColor = color
                hl.OutlineColor = Color3.new(1,1,1)
                hl.Parent = charPlr
                highlights[plr] = hl

                -- Ник над головой
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 50)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = charPlr:FindFirstChild("Head") or charPlr
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = color
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.Parent = bb
                highlights[plr].Billboard = bb
            elseif charPlr and highlights[plr] then
                highlights[plr].FillColor = color
                if highlights[plr].Billboard then
                    highlights[plr].Billboard.TextLabel.TextColor3 = color
                end
            end
        end
    end

    -- Периодическое обновление
    spawn(function()
        while espEnabled do
            updateESP()
            wait(1)
        end
    end)
end)

-- ========== Player Page элементы ==========
local playerY = 5
local speedSlider = createSlider(pages.Player, "Speed", 0, 30, 16, playerY)
playerY = playerY + 60
local jumpSlider = createSlider(pages.Player, "Jump", 0, 200, 50, playerY)
playerY = playerY + 60
local noClipToggle = createToggle(pages.Player, "NoClip", playerY)
playerY = playerY + 45
local infJumpToggle = createToggle(pages.Player, "InfJump", playerY)
pages.Player.CanvasSize = UDim2.new(0, 0, 0, playerY + 45)

-- SpeedChange
speedSlider:OnChange(function(val)
    if humanoid then humanoid.WalkSpeed = val end
end)
-- JumpChange
jumpSlider:OnChange(function(val)
    if humanoid then humanoid.JumpPower = val end
end)

-- NoClip
local noClipEnabled = false
noClipToggle:OnToggle(function(on)
    noClipEnabled = on
    local function setNoClip()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = not on
                end
            end
        end
    end
    setNoClip()
    if on then
        char.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") then
                child.CanCollide = false
            end
        end)
    end
end)

-- InfJump
local infJumpEnabled = false
infJumpToggle:OnToggle(function(on)
    infJumpEnabled = on
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
    if on then
        -- Отслеживаем нажатие пробела для доп. прыжка в воздухе
        uis.JumpRequest:Connect(function()
            if infJumpEnabled and humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- Сохраняем слайдеры и тогглы в глобальной таблице для Части 3
hub.Sliders = {
    Speed = speedSlider,
    Jump = jumpSlider,
}
hub.PlayerToggles = {
    NoClip = noClipToggle,
    InfJump = infJumpToggle,
}
-- MM2 PutinHub | Часть 3
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local hub = _G.PutinHub
local pages = hub.Pages
local teleportPage = pages.Teleport

local teleportY = 5

-- Вспомогательная функция для создания кнопки телепорта
local function createTeleportButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    return btn
end

-- Кнопки телепортов
local lobbyBtn = createTeleportButton(teleportPage, "TP to Lobby", teleportY)
teleportY = teleportY + 45
local mapBtn = createTeleportButton(teleportPage, "TP to Map", teleportY)
teleportY = teleportY + 45
local murderBtn = createTeleportButton(teleportPage, "TP to Murder", teleportY)
teleportY = teleportY + 45
local sheriffBtn = createTeleportButton(teleportPage, "TP to Sheriff", teleportY)
teleportY = teleportY + 45
teleportPage.CanvasSize = UDim2.new(0, 0, 0, teleportY + 5)

-- Функция поиска игрока по роли
local function findPlayerByRole(roleName)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local roleObj = plr:FindFirstChild("Role") or plr.Character and plr.Character:FindFirstChild("Role")
            if roleObj and roleObj:IsA("StringValue") and roleObj.Value == roleName then
                return plr
            end
        end
    end
    return nil
end

-- TP to Lobby (обычно spawn-зона)
lobbyBtn.MouseButton1Click:Connect(function()
    -- Пробуем найти точку появления в лобби (часто это Part с именем "Lobby" или "Spawn")
    local lobbyPart = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("SpawnLocation")
    if lobbyPart and lobbyPart:IsA("BasePart") then
        rootPart.CFrame = lobbyPart.CFrame + Vector3.new(0, 3, 0)
    else
        -- Запасной вариант: телепорт к координатам (0, 10, 0) или какому-то известному месту
        rootPart.CFrame = CFrame.new(0, 20, 0) -- приблизительные координаты лобби
    end
end)

-- TP to Map (обычно зона игры, не лобби)
mapBtn.MouseButton1Click:Connect(function()
    -- Ищем зону карты, часто отдельный Model "Map"
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("GameMap")
    if map then
        -- Берём любую часть внутри
        for _, obj in pairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "SafeZone" then
                rootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                return
            end
        end
    else
        -- Альтернатива: телепорт к первому игроку на карте (не в лобби)
        local found = false
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos = plr.Character.HumanoidRootPart.Position
                if pos.Y < 50 then -- предполагаем, что карта ниже лобби
                    rootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 5, 0)
                    found = true
                    break
                end
            end
        end
        if not found then
            rootPart.CFrame = CFrame.new(0, 20, 0) -- fallback
        end
    end
end)

-- TP to Murder
murderBtn.MouseButton1Click:Connect(function()
    local murd = findPlayerByRole("Murderer")
    if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = murd.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    else
        -- Оповещение в чат/гуи
        local msg = Instance.new("Hint")
        msg.Text = "Murderer не найден или игра не началась"
        msg.Parent = game.CoreGui
        game.Debris:AddItem(msg, 3)
    end
end)

-- TP to Sheriff
sheriffBtn.MouseButton1Click:Connect(function()
    local sher = findPlayerByRole("Sheriff")
    if sher and sher.Character and sher.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = sher.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    else
        local msg = Instance.new("Hint")
        msg.Text = "Sheriff не найден или игра не началась"
        msg.Parent = game.CoreGui
        game.Debris:AddItem(msg, 3)
    end
end)

-- Восстанавливаем обработчик переключения вкладок (Часть 1 уже сделал, но Player и Teleport страницы должны реагировать)
-- Дополнительно свяжем кнопки вкладок со страницами Player и Teleport, которые были созданы в Части 1 и уже добавлены.
-- Вкладки уже работают, т.к. мы их создали в Части 1, но для Player и Teleport нужно обновить видимость.
-- Переопределим нажатия для всех кнопок вкладок (tabButtons) из Части 1, но они не доступны глобально. Проще передать управление через хаб.
-- В Части 1 мы уже связали кнопки, но для страниц Player и Teleport видимость менялась через поиск ScrollingFrame. Мы добавили обе страницы в content. Код вкладок в Части 1 перебирает все ScrollingFrame в content и включает нужную. Так что Player и Teleport уже будут переключаться.

print("MM2 PutinHub полностью загружен и готов к использованию!")
