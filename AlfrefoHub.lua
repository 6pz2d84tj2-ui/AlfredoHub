-- ════════════════════════════════════════════════════════════════════════
-- ALFREDO HUB 🦫 | Steal an Egg (ГИБРИД v3)
-- UI: AlfredoHub | Ядро кражи: Steal Eggs Module (адаптировано)
-- Fix: скорость ↑↑, кнопка бобра работает
-- ════════════════════════════════════════════════════════════════════════

if _G.AlfredoHubLoaded and _G.AlfredoHubDestroy then
    pcall(_G.AlfredoHubDestroy)
end
_G.AlfredoHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════
-- КОНФИГ
-- ════════════════════════════════════════════════════════════════════════
local CFG = {
    LOGO_ID       = "rbxassetid://107301914145735",
    BEAVER_ID     = "rbxassetid://86571455908132",

    ACCENT        = Color3.fromHex("#8B5A2B"),
    ACCENT_LIGHT  = Color3.fromHex("#A0522D"),
    BG_WINDOW     = Color3.fromHex("#0D0D0D"),
    BG_ELEMENT    = Color3.fromHex("#1A1A1A"),
    BORDER        = Color3.fromHex("#2A2A2A"),
    TEXT_WHITE    = Color3.fromHex("#FFFFFF"),
    TEXT_GRAY     = Color3.fromHex("#909090"),
    TEXT_DIM      = Color3.fromHex("#606060"),

    FONT          = Enum.Font.GothamMedium,
    FONT_BOLD     = Enum.Font.GothamBold,
    TEXT_SIZE     = 12,
    TEXT_SIZE_SM  = 10,

    WINDOW_W      = 240,
    WINDOW_H      = 320,
    ICON_SIZE     = 42,

    STEAL_DELAY   = 1.5,
    MOVE_SPEED    = 900,   -- ⚡ скорость движения (было 320)

    FILTER_COSMIC  = false,
    FILTER_SECRET  = false,
    FILTER_ETERNAL = false,
    FILTER_DIVINE  = false,

    RUNNING       = true,
    STEALING      = false,
    BUSY          = false,
}

-- ════════════════════════════════════════════════════════════════════════
-- УТИЛИТЫ
-- ═════════════════════════════════