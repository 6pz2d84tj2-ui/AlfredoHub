-- ════════════════════════════════════════════════════════════════════════════
-- ALFREDO HUB — Loader
-- Загружает библиотеку Alfredo UI и скрипт Steal an Egg
-- ════════════════════════════════════════════════════════════════════════════

local LIB_URL  = "https://raw.githubusercontent.com/6pz2d84tj2-ui/AlfredoHub/main/AlfredoHub.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/6pz2d84tj2-ui/AlfredoHub/main/StealAnEgg_Alfredo.lua"

-- 1. Загрузка библиотеки
local libSource = game:HttpGet(LIB_URL)
local Library = loadstring(libSource)()
if not Library then
    error("[AlfredoHub] Не удалось загрузить библиотеку")
end

-- Проверка маркера AlfredoHub
if Library.AlfredoChat ~= true then
    warn("[AlfredoHub] Внимание: маркер AlfredoChat не найден. Возможно, это старая копия файла.")
end

-- 2. Загрузка скрипта с инъекцией Library
local scriptSource = game:HttpGet(SCRIPT_URL)
-- Вставляем `local Library = _G.ArcLib` в начало скрипта
_G.ArcLib = Library
local fullSource = "local Library = _G.ArcLib\n" .. scriptSource

local chunk = loadstring(fullSource)
if not chunk then
    error("[AlfredoHub] Ошибка компиляции скрипта")
end

-- 3. Запуск
local ok, err = pcall(chunk)
if not ok then
    error("[AlfredoHub] Ошибка выполнения: " .. tostring(err))
end

print("[AlfredoHub] 🦫 Загружено успешно!")