-- Параметры по умолчанию
local defaultSpeed = 16
local defaultFOV = 70

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Уничтожаем старое меню, если оно было запущено, чтобы они не накладывались
if game:GetService("CoreGui"):FindFirstChild("TsumMenuGui") then
    game:GetService("CoreGui").TsumMenuGui:Destroy()
end

-- === СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TsumMenuGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 280)
MainFrame.Position = UDim2.new(0.5, -175, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой по экрану
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "TSUM BETA MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- === ЭЛЕМЕНТЫ НАСТРОЙКИ СКОРОСТИ ===
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Position = UDim2.new(0, 20, 0, 60)
SpeedLabel.Size = UDim2.new(0, 150, 0, 30)
SpeedLabel.Text = "Скорость бега:"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 16
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = MainFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Position = UDim2.new(0, 200, 0, 60)
SpeedInput.Size = UDim2.new(0, 120, 0, 30)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.Text = tostring(defaultSpeed)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 16
SpeedInput.BorderSizePixel = 0
SpeedInput.Parent = MainFrame

-- === ЭЛЕМЕНТЫ НАСТРОЙКИ FOV ===
local FovLabel = Instance.new("TextLabel")
FovLabel.Position = UDim2.new(0, 20, 0, 110)
FovLabel.Size = UDim2.new(0, 150, 0, 30)
FovLabel.Text = "Угол обзора (FOV):"
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FovLabel.TextSize = 16
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.BackgroundTransparency = 1
FovLabel.Parent = MainFrame

local FovInput = Instance.new("TextBox")
FovInput.Position = UDim2.new(0, 200, 0, 110)
FovInput.Size = UDim2.new(0, 120, 0, 30)
FovInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FovInput.Text = tostring(defaultFOV)
FovInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FovInput.TextSize = 16
FovInput.BorderSizePixel = 0
FovInput.Parent = MainFrame

-- === КНОПКА СЕРВЕР ХОП ===
local ServerHopBtn = Instance.new("TextButton")
ServerHopBtn.Position = UDim2.new(0, 20, 0, 170)
ServerHopBtn.Size = UDim2.new(1, -40, 0, 40)
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ServerHopBtn.Text = "Выполнить Сервер Хоп"
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.TextSize = 16
ServerHopBtn.Font = Enum.Font.SourceSansBold
ServerHopBtn.BorderSizePixel = 0
ServerHopBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 5)
BtnCorner.Parent = ServerHopBtn

-- Подсказка внизу меню
local HintLabel = Instance.new("TextLabel")
HintLabel.Position = UDim2.new(0, 0, 1, -35)
HintLabel.Size = UDim2.new(1, 0, 0, 30)
HintLabel.Text = "Нажми 'Insert' (или 'Insert' на вирт. клаве), чтобы скрыть меню"
HintLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
HintLabel.TextSize = 12
HintLabel.BackgroundTransparency = 1
HintLabel.Parent = MainFrame


-- === ЛОГИКА РАБОТЫ ФУНКЦИЙ ===

-- 1. Обновление скорости при изменении текста в поле
SpeedInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(SpeedInput.Text)
    if num then
        local character = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = num
    else
        SpeedInput.Text = "Ошибка!"
    end
end)

-- Поддержка скорости после респавна персонажа
lp.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    local num = tonumber(SpeedInput.Text)
    if num then
        task.wait(0.5) -- небольшая задержка для прогрузки
        humanoid.WalkSpeed = num
    end
end)

-- 2. Обновление FOV при изменении текста
FovInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(FovInput.Text)
    if num and camera then
        camera.FieldOfView = num
    else
        FovInput.Text = "Ошибка!"
    end
end)

-- Защита FOV от сброса игрой
if camera then
    camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        local num = tonumber(FovInput.Text)
        if num and camera.FieldOfView ~= num then
            camera.FieldOfView = num
        end
    end)
end

-- 3. Функция Сервер Хопа по нажатию на кнопку
ServerHopBtn.MouseButton1Click:Connect(function()
    ServerHopBtn.Text = "Ищу сервер..."
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                ServerHopBtn.Text = "Телепортация..."
                TeleportService:TeleportToPlaceInstance(placeId, server.id, lp)
                return
            end
        end
    end
    ServerHopBtn.Text = "Сервер не найден. Еще раз?"
end)

-- 4. Скрытие/Открытие меню на кнопку Insert
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end
end)
