--// ============================================================
--// UNIVERSAL TRIGGER BOT (Спам ЛКМ при наведении на игрока)
--// ============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Настройки
local TRIGGER_KEY = Enum.KeyCode.LeftAlt --// Кнопка включения/выключения (по умолчанию LeftAlt)
local CLICK_DELAY = 0.05 --// Задержка между кликами (сек)

local isEnabled = false
local isHolding = false

print("=== UNIVERSAL TRIGGER BOT ЗАГРУЖЕН ===")
print("Нажми [LeftAlt], чтобы включить/выключить.")

--// Функция проверки: находится ли мышь на игроке
local function isMouseOnPlayer()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    
    if hit then
        local model = hit.Instance:FindFirstAncestorOfClass("Model")
        if model then
            --// Проверяем, есть ли у модели Humanoid (игрок или NPC)
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                --// Проверяем, что это не мы сами
                if model ~= LocalPlayer.Character then
                    return true
                end
            end
        end
    end
    return false
end

--// Цикл триггера
RunService.Heartbeat:Connect(function()
    if not isEnabled then return end
    
    --// Если прицел на игроке — стреляем
    if isMouseOnPlayer() then
        if not isHolding then
            isHolding = true
            --// Зажимаем ЛКМ
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            
            --// Отпускаем через задержку
            task.spawn(function()
                task.wait(CLICK_DELAY)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                isHolding = false
            end)
        end
    end
end)

--// Включение/выключение
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TRIGGER_KEY then
        isEnabled = not isEnabled
        print("Триггер-бот:", isEnabled and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН")
    end
end)
