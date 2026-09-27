-- ════════════════════════════════════════════════════════════════════════
-- ЯДРО КРАЖИ (гибрид: логика из Steal Eggs Module)
-- ════════════════════════════════════════════════════════════════════════
local Net = ReplicatedStorage:FindFirstChild("Packages")
    and ReplicatedStorage.Packages:FindFirstChild("Networking")

-- Ищем ремоуты в двух местах (твой Packages + хабовский Shared)
local Remotes = {
    Carry    = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggCarry"),
    Snapshot = Net and Net:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot"),
    Strike   = Net and Net:FindFirstChild("RE/GuardPatrol/ForestStrike"),
}

local Shared   = ReplicatedStorage:FindFirstChild("Shared")
local ClientF  = ReplicatedStorage:FindFirstChild("Client")
local DataF    = ReplicatedStorage:FindFirstChild("Data")

-- Fallback: если в Packages нет — берём из Shared.Remotes
local RemotesMod = Shared and Shared:FindFirstChild("Remotes")
if RemotesMod then
    local ok, mod = pcall(require, RemotesMod)
    if ok and type(mod) == "table" then
        if mod.EggWorld then
            Remotes.Carry    = Remotes.Carry    or (mod.EggWorld.AskFieldEggCarry)
            Remotes.Snapshot = Remotes.Snapshot or (mod.EggWorld.AskFieldEggSnapshot)
        end
    end
end

local AreaEggCycle, AssetsData, PlotState, EggState, SaveMod
pcall(function() AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle) end)
pcall(function() AssetsData = require(ReplicatedStorage.Data.Assets) end)
pcall(function() PlotState = require(ReplicatedStorage.Client.PlotState) end)
pcall(function() EggState = require(ReplicatedStorage.Client.EggState) end)
pcall(function() SaveMod = require(ReplicatedStorage.Shared.Save) end)

-- Кэш поля яиц
local fieldCache = {}
local function refreshField()
    local snap
    if Remotes.Snapshot then
        local ok, s = pcall(function() return Remotes.Snapshot:InvokeServer() end)
        if ok then snap = s end
    end
    local recs = snap and snap.Records
    if type(recs) == "table" then
        local out = {}
        for _, rec in ipairs(recs) do if rec and rec.Uid then out[rec.Uid] = rec end end
        fieldCache = out
    elseif EggState and EggState.ReadFieldEggs then
        local ok, rows = pcall(function() return EggState.ReadFieldEggs() end)
        if ok and type(rows) == "table" then fieldCache = rows end
    end
end
task.spawn(function() while CFG.RUNNING do pcall(refreshField); task.wait(2) end end)
local function eggRecord(uid) return fieldCache[uid] end

-- Навигация (взято из хаба, адаптировано)
local Nav = {}
do
    Nav.Speed, Nav.ArriveDist = 80, 3
    local SAFE_ZONE = Vector3.new(497.264, 70.673, -361.122)

    local function areasFolder()
        local obj = Workspace:FindFirstChild("__OBJECTS")
        return obj and obj:FindFirstChild("Areas")
    end
    local function findPart(c, name)
        if not c then return nil end
        local o = c:FindFirstChild(name) or c:FindFirstChild(name, true)
        if not o then return nil end
        if o:IsA("BasePart") then return o end
        return o:FindFirstChild("Bounds") or o:FindFirstChildWhichIsA("BasePart")
    end
    local _laneY, _laneZ
    function Nav.getLaneY()
        if _laneY then return _laneY end
        local gz = findPart(areasFolder(), "GameplayZ")
        if gz then _laneY = gz.Position.Y + 3 end
        return _laneY or 73
    end
    function Nav.getLaneZ()
        if _laneZ then return _laneZ end
        local sl = findPart(areasFolder(), "SeparationLine") or findPart(areasFolder(), "GameplayZ")
        if sl then _laneZ = sl.Position.Z end
        local r = hrp()
        return _laneZ or (r and r.Position.Z) or -365.5
    end
    function Nav.groundY(x, z, fb)
        local laneY = Nav.getLaneY()
        local pr = RaycastParams.new()
        pr.FilterType = Enum.RaycastFilterType.Exclude
        pr.FilterDescendantsInstances = { LP.Character }
        local hit = Workspace:Raycast(Vector3.new(x, laneY + 40, z), Vector3.new(0, -160, 0), pr)
        if hit then return math.clamp(hit.Position.Y + 3, laneY - 2, laneY + 5) end
        return fb or laneY
    end
    function Nav.stealMoveTo(x, z, keepGoing, speed)
        local root = hrp(); if not root then return false end
        local humanoid = hum()
        speed = speed or Nav.Speed
        local deadline = os.clock() + 8
        while CFG.RUNNING do
            if os.clock() >= deadline then return false end
            if keepGoing and not keepGoing() then return false end
            root = hrp(); if not root then return false end
            local gy = Nav.groundY(x, z, root.Position.Y)
            local target = Vector3.new(x, gy, z)
            local delta = target - root.Position
            local dist = delta.Magnitude
            if dist <= Nav.ArriveDist then
                root.CFrame = CFrame.new(target) * (root.CFrame - root.CFrame.Position)
                root.AssemblyLinearVelocity = Vector3.zero
                return true
            end
            local dt = RunService.Heartbeat:Wait()
            if typeof(dt) ~= "number" or dt <= 0 then dt = 1 / 60 end
            local dir = delta.Unit
            local newPos = root.Position + dir * math.min(dist, speed * dt)
            local flat = Vector3.new(dir.X, 0, dir.Z)
            if flat.Magnitude > 0 then root.CFrame = CFrame.lookAt(newPos, newPos + flat)
            else root.CFrame = CFrame.new(newPos) * (root.CFrame - root.CFrame.Position) end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            if humanoid then pcall(function() humanoid.Sit = false; humanoid.PlatformStand = false end) end
        end
    end
    function Nav.buildLaneWaypoints(target)
        local laneZ, laneY = Nav.getLaneZ(), Nav.getLaneY()
        local root = hrp(); if not root then return {} end
        local wp = {}
        if math.abs(root.Position.Z - laneZ) > 6 then
            wp[#wp + 1] = Vector3.new(root.Position.X, laneY, laneZ)
        end
        wp[#wp + 1] = Vector3.new(target.X, laneY, laneZ)
        return wp
    end
    function Nav.travelToEggViaLane(eggPos, keepGoing, speed)
        local root = hrp()
        if root and (Vector3.new(eggPos.X, root.Position.Y, eggPos.Z) - root.Position).Magnitude <= 35 then
            return Nav.stealMoveTo(eggPos.X, eggPos.Z, keepGoing, speed)
        end
        for _, w in ipairs(Nav.buildLaneWaypoints(eggPos)) do
            if keepGoing and not keepGoing() then return false end
            Nav.stealMoveTo(w.X, w.Z, keepGoing, speed)
        end
        return Nav.stealMoveTo(eggPos.X, eggPos.Z, keepGoing, speed)
    end
    function Nav.returnViaLane(basePos, keepGoing, speed)
        if typeof(basePos) ~= "Vector3" then return false end
        for _, w in ipairs(Nav.buildLaneWaypoints(basePos)) do
            if keepGoing and not keepGoing() then return false end
            Nav.stealMoveTo(w.X, w.Z, keepGoing, speed)
        end
        Nav.stealMoveTo(basePos.X, basePos.Z, keepGoing, speed)
        local root = hrp()
        if root and (root.Position - basePos).Magnitude > 10 then
            root.CFrame = CFrame.new(basePos + Vector3.new(0, 3, 0)) * (root.CFrame - root.CFrame.Position)
            root.AssemblyLinearVelocity = Vector3.zero
        end
        return true
    end
    Nav.SAFE_ZONE = SAFE_ZONE
end

-- Выход/возврат (из хаба)
local function travelOutToEgg(eggPos, keepGoing, sp)
    if typeof(eggPos) ~= "Vector3" then return false end
    Nav.stealMoveTo(Nav.SAFE_ZONE.X, Nav.SAFE_ZONE.Z, keepGoing, sp)
    return Nav.travelToEggViaLane(eggPos, keepGoing, sp)
end

local function resolveOwnBase()
    if PlotState and PlotState.ResolvePlot then
        local ok, plot = pcall(PlotState.ResolvePlot)
        if ok and type(plot) == "table" then
            if plot.PetArea and plot.PetArea:IsA("BasePart") then
                local pa = plot.PetArea
                return CFrame.new(pa.Position + Vector3.new(0, pa.Size.Y * 0.5 + 3, 0))
            end
            if plot.CenterPoint and plot.CenterPoint:IsA("BasePart") then
                return CFrame.new(plot.CenterPoint.Position + Vector3.new(0, 4, 0))
            end
        end
    end
    return nil
end

local function returnToOwnBase(keepGoing, sp)
    local cf = resolveOwnBase()
    local targetPos = cf and cf.Position or Vector3.new(464.7, 70.4, -364.0)
    return Nav.returnViaLane(targetPos, keepGoing, sp)
end

-- Захват яйца (из хаба)
local fireprompt = fireproximityprompt or (getgenv and getgenv().fireproximityprompt)

local function fieldEggModel(uid)
    local f = Workspace:FindFirstChild("AreaEggSlotsClient")
    if f then local e = f:FindFirstChild(uid); if e then return e end end
    return Workspace:FindFirstChild(uid)
end

local function fieldSlotKey(uid)
    if type(uid) == "string" and uid:find("FirstAreaEgg_", 1, true) == 1 then return nil end
    local r = eggRecord(uid)
    if r and r.AreaId ~= nil and r.NestId ~= nil then
        return tostring(r.AreaId) .. ":" .. tostring(r.NestId)
    end
    return nil
end

local function grabEgg(m, uid)
    local slotKey = fieldSlotKey(uid)
    if EggState and EggState.CarryFieldEgg then
        pcall(EggState.CarryFieldEgg, uid, slotKey)
    else
        local r = Remotes.Carry
        if r then
            pcall(function() r:InvokeServer({ Uid = uid, FirstAreaSlotKey = slotKey }) end)
        end
    end
    if fireprompt and m then
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local was = d.Enabled
                pcall(function() d.HoldDuration = 0; d.Enabled = true end)
                pcall(fireprompt, d)
                pcall(function() d.Enabled = was end)
            end
        end
    end
end

-- День/ночь
local function isDay()
    if AreaEggCycle and AreaEggCycle.IsNightPhase then
        local ok, res = pcall(function()
            return AreaEggCycle.IsNightPhase(workspace:GetServerTimeNow())
        end)
        if ok then return res ~= true end
    end
    local ct = Lighting.ClockTime
    return ct >= 6 and ct < 18
end

-- Редкость
local function getRarity(record)
    local cat = record.AssetCategory or record.Category
    if cat and AssetsData then
        local dir = AssetsData.Directory or AssetsData
        local info = dir[cat]
        if info and info.Rarity then
            local r = info.Rarity
            return type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
        end
    end
    return "Common"
end

local function passesFilter(record)
    local name = tostring(getRarity(record)):lower()
    local anyFilter = CFG.FILTER_COSMIC or CFG.FILTER_SECRET
        or CFG.FILTER_ETERNAL or CFG.FILTER_DIVINE
    if not anyFilter then return true end
    if CFG.FILTER_COSMIC and name:find("cosmic") then return true end
    if CFG.FILTER_SECRET and name:find("secret") then return true end
    if CFG.FILTER_ETERNAL and name:find("eternal") then return true end
    if CFG.FILTER_DIVINE and name:find("divine") then return true end
    return false
end

-- Поиск яиц (адаптировано под refreshField + snapshot)
local function getEggs()
    refreshField()
    local eggs = {}
    for uid, rec in pairs(fieldCache) do
        if rec and rec.Uid and rec.State == "Slot" and passesFilter(rec) then
            local cat = rec.AssetCategory or rec.Category or "Egg"
            local money = 0
            if AssetsData then
                local dir = AssetsData.Directory or AssetsData
                local info = dir[cat]
                money = info and (info.Income or info.EarningRate or info.Money or 0) or 0
                money = money * (rec.AssetScale or 1)
            end
            local pos
            local m = fieldEggModel(uid)
            if m and m:IsA("Model") then
                local pp = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if pp then pos = pp.Position end
            end
            if rec.BoundsCFrame then pos = rec.BoundsCFrame.Position end
            if pos then
                table.insert(eggs, {
                    Uid = uid,
                    Category = cat,
                    Rarity = getRarity(rec),
                    Money = money,
                    Position = pos,
                    Record = rec,
                })
            end
        end
    end
    table.sort(eggs, function(a, b) return (a.Money or 0) > (b.Money or 0) end)
    return eggs
end

-- Проверка "несу ли яйцо"
local function isCarrying()
    local c = char()
    if not c then return false end
    for _, obj in ipairs(c:GetChildren()) do
        if obj:IsA("Tool") then
            local n = obj.Name:lower()
            if n:find("egg") or obj:GetAttribute("Uid") then return true end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then
                local n = obj.Name:lower()
                if n:find("egg") or obj:GetAttribute("Uid") then return true end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════
-- НОВЫЙ АВТОСТИЛ (на логике хаба)
-- ════════════════════════════════════════════════════════════════════════
local function stealEgg(egg)
    if not egg or not egg.Uid or not egg.Position then return false end
    local root = hrp()
    local humanoid = hum()
    if not root or not humanoid then return false end

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid.PlatformStand = false

    CFG.BUSY = true
    local keepGoing = function() return CFG.STEALING and CFG.RUNNING end

    -- 1: идём к яйцу через коридор
    setStatus("Traveling to egg...", CFG.ACCENT)
    local ok = travelOutToEgg(egg.Position, keepGoing, Nav.Speed)
    if not ok or not keepGoing() then CFG.BUSY = false return false end

    -- 2: хватаем яйцо
    setStatus("Grabbing egg...", CFG.ACCENT)
    local m = fieldEggModel(egg.Uid)
    local t0 = tick()
    while not isCarrying() and tick() - t0 < 4 do
        if not keepGoing() then CFG.BUSY = false return false end
        grabEgg(m, egg.Uid)
        Nav.stealMoveTo(egg.Position.X, egg.Position.Z, keepGoing, Nav.Speed)
        RunService.Heartbeat:Wait()
    end

    if not isCarrying() then
        setStatus("Failed to grab", CFG.TEXT_DIM)
        CFG.BUSY = false
        return false
    end

    -- 3: удар стража
    setStatus("Waiting guard strike...", CFG.ACCENT)
    t0 = tick()
    local struck = false
    while isCarrying() and tick() - t0 < 4.5 do
        if not keepGoing() then break end
        if Remotes.Strike and not struck then
            task.spawn(function()
                pcall(function()
                    if Remotes.Strike:IsA("RemoteFunction") then
                        Remotes.Strike:InvokeServer()
                    else
                        Remotes.Strike:FireServer()
                    end
                end)
            end)
            struck = true
        end
        RunService.Heartbeat:Wait()
    end

    -- 4: реграб
    setStatus("Re-grabbing...", CFG.ACCENT)
    t0 = tick()
    while not isCarrying() and tick() - t0 < 3 do
        if not keepGoing() then break end
        grabEgg(m, egg.Uid)
        RunService.Heartbeat:Wait()
    end

    local success = isCarrying()
    setStatus(success and "Egg secured!" or "Failed",
        success and CFG.ACCENT or CFG.TEXT_DIM)
    CFG.BUSY = false
    return success
end