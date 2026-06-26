-- === НАСТРОЙКИ СКРИПТА ===
local WALK_SPEED = 50   -- Скорость бега (стандартная: 16)
local FOV_VALUE = 110   -- Угол обзора / FOV (стандартный: 70)

-- Клавиши управления (можно поменять на свои):
local TOGGLE_SPEED_KEY = Enum.KeyCode.V  -- Включить/выключить скорость на V
local SERVER_HOP_KEY   = Enum.KeyCode.H  -- Сменить сервер на H

-- === СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local speedEnabled = false

print("[Tsum Beta Script] Загрузка успешна! Нажми V для скорости, H для смены сервера.")

-- === 1. ИЗМЕНЕНИЕ FOV (УГОЛ ОБЗОРА) ===
-- FOV меняется сразу при запуске скрипта
if camera then
    camera.FieldOfView = FOV_VALUE
    -- Защита от сброса FOV при возрождении
    camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if camera.FieldOfView ~= FOV_VALUE then
            camera.FieldOfView = FOV_VALUE
        end
    end)
end

-- === 2. ИЗМЕНЕНИЕ СКОРОСТИ (WALKSPEED) ===
local function toggleSpeed()
    speedEnabled = not speedEnabled
    local character = lp.Character or lp.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if speedEnabled then
        humanoid.WalkSpeed = WALK_SPEED
        print("[Script] Скорость увеличена до: " .. WALK_SPEED)
    else
        humanoid.WalkSpeed = 16 -- возвращаем стандартную
        print("[Script] Скорость сброшена до стандартной")
    end
end

-- Следим, чтобы скорость сохранялась после смерти персонажа
lp.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if speedEnabled then
        humanoid.WalkSpeed = WALK_SPEED
    end
end)

-- === 3. СЕРВЕР ХОП (SERVER HOP) ===
local function serverHop()
    print("[Script] Ищу новый сервер... Подожди.")
    local placeId = game.PlaceId
    -- Запрашиваем список активных серверов у API Roblox
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            -- Ищем сервер, где есть места, но который не пустой и не наш текущий
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                print("[Script] Сервер найден! Телепортация...")
                TeleportService:TeleportToPlaceInstance(placeId, server.id, lp)
                return
            end
        end
    end
    print("[Script] Не удалось найти подходящий сервер. Попробуй еще раз.")
end

-- === ОБРАБОТКА НАЖАТИЯ КЛАВИШ ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Если ты пишешь в чат, скрипт не должен срабатывать
    if gameProcessed then return end 

    if input.KeyCode == TOGGLE_SPEED_KEY then
        toggleSpeed()
    elseif input.KeyCode == SERVER_HOP_KEY then
        serverHop()
    end
end)
