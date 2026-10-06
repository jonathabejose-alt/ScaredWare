if getgenv().ScaredWareSniper and getgenv().ScaredWareSniper.Unload then
    getgenv().ScaredWareSniper:Unload()
end

local compiler = loadstring or load
if type(compiler) ~= "function" then
    return warn("[Scared Ware UI · Sniper Arena] loadstring unavailable")
end

local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/VVind-UI/refs/heads/main/src.lua"))()
VindUI:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
VindUI:SetScaleRange(0.75, 1.35)

local ENV = (getgenv and getgenv()) or _G
if ENV.__SNIPER_ARENA_AIM_ESP_CLEANUP then
    pcall(ENV.__SNIPER_ARENA_AIM_ESP_CLEANUP)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SNIPER_ARENA_UNIVERSE_ID = 9534705677

if tonumber(game.GameId) ~= SNIPER_ARENA_UNIVERSE_ID then
    warn(("[Scared Ware UI · Sniper Arena] Wrong universe. Expected %s, got %s"):format(tostring(SNIPER_ARENA_UNIVERSE_ID), tostring(game.GameId)))
    return
end

local PLACE_INFO = {
    [122446657157717] = {Name = "Main Lobby", Kind = "lobby"},
    [74424488747487] = {Name = "Mobile Lobby", Kind = "lobby"},
    [80344694749728] = {Name = "Unnamed / Internal", Kind = "dynamic"},
    [81864505280935] = {Name = "Gun Game", Kind = "combat"},
    [90165746516953] = {Name = "Matchmaking / Ranked", Kind = "dynamic"},
    [90625015569871] = {Name = "Test Arcade", Kind = "dynamic"},
    [92726474449929] = {Name = "Test Trading Market", Kind = "market"},
    [96216501849190] = {Name = "Arcade Mobile", Kind = "combat"},
    [101571206862372] = {Name = "Knife FFA Mobile", Kind = "combat"},
    [102220551718323] = {Name = "Test", Kind = "dynamic"},
    [109094919875208] = {Name = "TDM 8v8", Kind = "combat"},
    [111189101942839] = {Name = "No Bots FFA Mobile", Kind = "combat"},
    [112261221918322] = {Name = "Test Matchmaking", Kind = "dynamic"},
    [113390337779988] = {Name = "Dash Arcade Mobile", Kind = "combat"},
    [114188007571146] = {Name = "Knife FFA", Kind = "combat"},
    [115517196855730] = {Name = "Dash Arcade", Kind = "combat"},
    [118561101017718] = {Name = "Rapid Fire Arcade", Kind = "combat"},
    [119259569670784] = {Name = "Arcade Beginner", Kind = "combat"},
    [119661268047775] = {Name = "Free For All (No Bots)", Kind = "combat"},
    [124955530864032] = {Name = "Free For All Mobile", Kind = "combat"},
    [125154235269776] = {Name = "Trading Market", Kind = "market"},
    [126042865144779] = {Name = "Classic Arcade", Kind = "combat"},
}

local function getCurrentPlaceInfo()
    return PLACE_INFO[game.PlaceId] or {Name = "Future / Unknown Sniper Arena Place", Kind = "dynamic"}
end

do
    local queueFunction =
        (type(queue_on_teleport) == "function" and queue_on_teleport)
        or (type(queueonteleport) == "function" and queueonteleport)
        or (syn and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport)

    if type(queueFunction) == "function" and not ENV.__SW_SNIPER_TELEPORT_QUEUED then
        ENV.__SW_SNIPER_TELEPORT_QUEUED = true
        pcall(queueFunction, [[loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/scared%20ware%20(sniper%20arena).lua"))()]])
    end
end

local Config = {
    AimMode = "Custom",
    Aim = {
        Enabled = true,
        HoldRMB = true,
        VisibleCheck = true,
        RespectGameVisibility = true,
        RespectSmoke = true,
        RespectFlash = true,
        HeadPriority = true,
        AimPoint = "Head",
        AutoShoot = false,
        AutoShootButton = "RMB",
        AutoShootRadius = 10,
        AutoShootDelay = 0.00,
        FOV = 220,
        SmoothSpeed = 46,
        MaxDistance = 700,
        StickyTarget = true,
        StickyMultiplier = 1.30,
        Prediction = true,
        PredictionTime = 0.06,
        PredictionSmoothing = 0.72,
        MaxPredictionOffset = 14,
        AdaptiveSmoothing = true,
        MicroSnapRadius = 1.5,
        TargetPriority = "Hybrid",
        SwitchDelay = 0.05,
        SwitchThreshold = 0.12,
        LockGrace = 0.18,
        ShowFOV = true,
        AimKeybind = Enum.KeyCode.RightAlt,
        AimKeybindEnabled = false,
        AutoShootKeybind = Enum.KeyCode.RightShift,
        AutoShootKeybindEnabled = false,
    },
    TriggerBot = {
        Enabled = false,
        WallCheck = true,
        Radius = 3,
        Delay = 0.05,
        HoldKey = Enum.KeyCode.LeftControl,
        HoldKeyEnabled = false,
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Chams = true,
        MaxDistance = 1200,
    },
}

local function normalizeAutoShootButton(value)
    value = tostring(value or "RMB"):upper()
    return value == "LMB" and "LMB" or "RMB"
end

ENV.__PUCKAFK_CONFIG_SHARED_STATE = ENV.__PUCKAFK_CONFIG_SHARED_STATE or {
    Root = "ScaredWare/Configs",
    AutoSaveDefault = true,
    AutoLoadDefault = true,
}

local SharedConfigState = ENV.__PUCKAFK_CONFIG_SHARED_STATE
SharedConfigState.Root = tostring(SharedConfigState.Root or "ScaredWare/Configs")
if SharedConfigState.AutoSaveDefault == nil then SharedConfigState.AutoSaveDefault = true end
if SharedConfigState.AutoLoadDefault == nil then SharedConfigState.AutoLoadDefault = true end

local ConfigStore = {
    Id = "SniperArena",
    Selected = "default",
    AutoSave = SharedConfigState.AutoSaveDefault == true,
    AutoLoad = SharedConfigState.AutoLoadDefault == true,
    Applying = false,
    LastFingerprint = nil,
    StatusLabel = nil,
    ProfileDropdown = nil,
    ProfileInput = nil,
    PendingProfile = nil,
}

local FS = {
    Write = type(writefile) == "function" and writefile or nil,
    Read = type(readfile) == "function" and readfile or nil,
    IsFile = type(isfile) == "function" and isfile or nil,
    MakeFolder = type(makefolder) == "function" and makefolder or nil,
    ListFiles = type(listfiles) == "function" and listfiles or nil,
    DeleteFile = type(delfile) == "function" and delfile or nil,
}

ConfigStore.Available = FS.Write ~= nil and FS.Read ~= nil and FS.IsFile ~= nil and FS.MakeFolder ~= nil
ConfigStore.Folder = SharedConfigState.Root .. "/" .. ConfigStore.Id
ConfigStore.MetaPath = ConfigStore.Folder .. "/_meta.json"

local function sanitizeConfigName(value, fallback)
    local text = tostring(value or "")
    text = text:gsub("[^%w%-%._ ]", "_")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("%s+", "_")
    text = text:gsub("_+", "_")
    if text == "" then text = tostring(fallback or "default") end
    return text:sub(1, 80)
end

local function ensureConfigFolders()
    if not FS.MakeFolder then return false end
    local current = ""
    for part in ConfigStore.Folder:gmatch("[^/\\]+") do
        current = current == "" and part or (current .. "/" .. part)
        pcall(FS.MakeFolder, current)
    end
    return true
end

local function configPath(name)
    return ConfigStore.Folder .. "/" .. sanitizeConfigName(name, "default") .. ".json"
end

local function encodeJSON(value)
    local ok, result = pcall(function() return HttpService:JSONEncode(value) end)
    return ok and result or nil
end

local function decodeJSON(text)
    local ok, result = pcall(function() return HttpService:JSONDecode(text) end)
    return ok and result or nil
end

local function setConfigStatus(text)
    if ConfigStore.StatusLabel and ConfigStore.StatusLabel.Set then
        ConfigStore.StatusLabel:Set(tostring(text or ""))
    end
end

local function configSnapshot()
    return {
        Version = 7,
        AimMode = Config.AimMode,
        Aim = {
            Enabled = Config.Aim.Enabled, HoldRMB = Config.Aim.HoldRMB,
            VisibleCheck = Config.Aim.VisibleCheck, RespectGameVisibility = Config.Aim.RespectGameVisibility,
            RespectSmoke = Config.Aim.RespectSmoke, RespectFlash = Config.Aim.RespectFlash,
            HeadPriority = Config.Aim.HeadPriority, AimPoint = Config.Aim.AimPoint,
            AutoShoot = Config.Aim.AutoShoot, AutoShootButton = normalizeAutoShootButton(Config.Aim.AutoShootButton),
            AutoShootRadius = Config.Aim.AutoShootRadius, AutoShootDelay = Config.Aim.AutoShootDelay,
            FOV = Config.Aim.FOV, SmoothSpeed = Config.Aim.SmoothSpeed, MaxDistance = Config.Aim.MaxDistance,
            StickyTarget = Config.Aim.StickyTarget, StickyMultiplier = Config.Aim.StickyMultiplier,
            Prediction = Config.Aim.Prediction, PredictionTime = Config.Aim.PredictionTime,
            PredictionSmoothing = Config.Aim.PredictionSmoothing, MaxPredictionOffset = Config.Aim.MaxPredictionOffset,
            AdaptiveSmoothing = Config.Aim.AdaptiveSmoothing, MicroSnapRadius = Config.Aim.MicroSnapRadius,
            TargetPriority = Config.Aim.TargetPriority, SwitchDelay = Config.Aim.SwitchDelay,
            SwitchThreshold = Config.Aim.SwitchThreshold, LockGrace = Config.Aim.LockGrace,
            ShowFOV = Config.Aim.ShowFOV,
            AimKeybind = Config.Aim.AimKeybind.Name,
            AimKeybindEnabled = Config.Aim.AimKeybindEnabled,
            AutoShootKeybind = Config.Aim.AutoShootKeybind.Name,
            AutoShootKeybindEnabled = Config.Aim.AutoShootKeybindEnabled,
        },
        TriggerBot = {
            Enabled = Config.TriggerBot.Enabled,
            WallCheck = Config.TriggerBot.WallCheck,
            Radius = Config.TriggerBot.Radius,
            Delay = Config.TriggerBot.Delay,
            HoldKey = Config.TriggerBot.HoldKey.Name,
            HoldKeyEnabled = Config.TriggerBot.HoldKeyEnabled,
        },
        ESP = {
            Enabled = Config.ESP.Enabled, Boxes = Config.ESP.Boxes, Names = Config.ESP.Names,
            Health = Config.ESP.Health, Distance = Config.ESP.Distance, Chams = Config.ESP.Chams,
            MaxDistance = Config.ESP.MaxDistance,
        },
    }
end

local function configFingerprint()
    return encodeJSON(configSnapshot()) or ""
end

local function applyConfigTable(data)
    if type(data) ~= "table" then return false end
    ConfigStore.Applying = true
    if type(data.AimMode) == "string" and data.AimMode ~= "" then Config.AimMode = data.AimMode end
    local aim = type(data.Aim) == "table" and data.Aim or {}
    local tb = type(data.TriggerBot) == "table" and data.TriggerBot or {}
    local esp = type(data.ESP) == "table" and data.ESP or {}
    local aimKeys = {
        "Enabled", "HoldRMB", "VisibleCheck", "RespectGameVisibility", "RespectSmoke", "RespectFlash",
        "HeadPriority", "AimPoint", "AutoShoot", "AutoShootButton", "AutoShootRadius", "AutoShootDelay",
        "FOV", "SmoothSpeed", "MaxDistance", "StickyTarget", "StickyMultiplier", "Prediction",
        "PredictionTime", "PredictionSmoothing", "MaxPredictionOffset", "AdaptiveSmoothing",
        "MicroSnapRadius", "TargetPriority", "SwitchDelay", "SwitchThreshold", "LockGrace", "ShowFOV",
        "AimKeybindEnabled", "AutoShootKeybindEnabled",
    }
    for _, key in ipairs(aimKeys) do
        if aim[key] ~= nil then Config.Aim[key] = aim[key] end
    end
    if type(aim.AimKeybind) == "string" then
        pcall(function() Config.Aim.AimKeybind = Enum.KeyCode[aim.AimKeybind] end)
    end
    if type(aim.AutoShootKeybind) == "string" then
        pcall(function() Config.Aim.AutoShootKeybind = Enum.KeyCode[aim.AutoShootKeybind] end)
    end
    local savedVersion = tonumber(data.Version) or 0
    if savedVersion < 5 and tonumber(aim.AutoShootDelay) == 0.12 then Config.Aim.AutoShootDelay = 0 end
    Config.Aim.AutoShootButton = normalizeAutoShootButton(Config.Aim.AutoShootButton)
    local tbKeys = {"Enabled", "WallCheck", "Radius", "Delay", "HoldKeyEnabled"}
    for _, key in ipairs(tbKeys) do
        if tb[key] ~= nil then Config.TriggerBot[key] = tb[key] end
    end
    if type(tb.HoldKey) == "string" then
        pcall(function() Config.TriggerBot.HoldKey = Enum.KeyCode[tb.HoldKey] end)
    end
    local espKeys = {"Enabled", "Boxes", "Names", "Health", "Distance", "Chams", "MaxDistance"}
    for _, key in ipairs(espKeys) do
        if esp[key] ~= nil then Config.ESP[key] = esp[key] end
    end
    ConfigStore.Applying = false
    return true
end

local function saveMeta()
    if not ConfigStore.Available then return false end
    local text = encodeJSON({Version = 1, Selected = ConfigStore.Selected, AutoSave = ConfigStore.AutoSave, AutoLoad = ConfigStore.AutoLoad})
    if not text then return false end
    return pcall(FS.Write, ConfigStore.MetaPath, text)
end

local function loadMeta()
    if not ConfigStore.Available or not FS.IsFile(ConfigStore.MetaPath) then return end
    local ok, text = pcall(FS.Read, ConfigStore.MetaPath)
    if not ok then return end
    local data = decodeJSON(text)
    if type(data) ~= "table" then return end
    if data.Selected ~= nil then ConfigStore.Selected = sanitizeConfigName(data.Selected, "default") end
    if data.AutoSave ~= nil then ConfigStore.AutoSave = data.AutoSave == true end
    if data.AutoLoad ~= nil then ConfigStore.AutoLoad = data.AutoLoad == true end
end

local function saveConfig(name, notify)
    if not ConfigStore.Available then setConfigStatus("Unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    ConfigStore.Selected = clean
    ensureConfigFolders()
    local text = encodeJSON(configSnapshot())
    if not text then setConfigStatus("Save failed") return false end
    local ok, err = pcall(FS.Write, configPath(clean), text)
    if not ok then setConfigStatus("Save failed: " .. tostring(err)) return false end
    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Saved • " .. clean)
    if notify then VindUI:Notify({Title = "Configs", Text = "Saved " .. clean, Type = "success", Duration = 2}) end
    return true
end

local function loadConfig(name, notify)
    if not ConfigStore.Available then setConfigStatus("Unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)
    if not FS.IsFile(path) then setConfigStatus("Not found • " .. clean) return false end
    local ok, text = pcall(FS.Read, path)
    if not ok then setConfigStatus("Load failed") return false end
    local data = decodeJSON(text)
    if type(data) ~= "table" then setConfigStatus("Load failed: invalid") return false end
    if not applyConfigTable(data) then setConfigStatus("Load failed: values") return false end
    ConfigStore.Selected = clean
    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Loaded • " .. clean)
    if notify then VindUI:Notify({Title = "Configs", Text = "Loaded " .. clean, Type = "success", Duration = 2}) end
    return true
end

local function listConfigProfiles()
    local result, seen = {}, {}
    local function add(name)
        local clean = sanitizeConfigName(name, "default")
        if not seen[clean] then seen[clean] = true table.insert(result, clean) end
    end
    add("default")
    add(ConfigStore.Selected)
    if ConfigStore.Available and FS.ListFiles then
        local ok, files = pcall(FS.ListFiles, ConfigStore.Folder)
        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                local normalized = tostring(file):gsub("\\", "/")
                local name = normalized:match("([^/]+)%.json$")
                if name and name ~= "_meta" then add(name) end
            end
        end
    end
    table.sort(result)
    return result
end

local function deleteConfig(name)
    if not ConfigStore.Available or not FS.DeleteFile then setConfigStatus("Delete unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)
    if not FS.IsFile(path) then setConfigStatus("Not found • " .. clean) return false end
    local ok = pcall(FS.DeleteFile, path)
    if not ok then setConfigStatus("Delete failed") return false end
    if ConfigStore.Selected == clean then ConfigStore.Selected = "default" end
    saveMeta()
    setConfigStatus("Deleted • " .. clean)
    return true
end

if ConfigStore.Available then
    ensureConfigFolders()
    loadMeta()
    if ConfigStore.AutoLoad and FS.IsFile(configPath(ConfigStore.Selected)) then
        local ok, text = pcall(FS.Read, configPath(ConfigStore.Selected))
        if ok then
            local data = decodeJSON(text)
            if type(data) == "table" then applyConfigTable(data) end
        end
    end
end

local EntityService, WorldManager, CameraController, GameService, WatchingHelper, EntityController, Effects, WeaponController, LocalEntity
local moduleInitState = "Starting..."
local backendName = "Fallback"
local setStatus = function(_) end
local requireErrors = {}

local function isForcedIdlePlace()
    local info = getCurrentPlaceInfo()
    return info.Kind == "lobby" or info.Kind == "market"
end

local function combatRuntimeActive()
    if tonumber(game.GameId) ~= SNIPER_ARENA_UNIVERSE_ID then return false end
    if isForcedIdlePlace() then return false end
    if LocalPlayer:GetAttribute("Team") == "Lobby" then return false end
    if GameService then
        local okJoined, joined = pcall(function() if GameService.IsJoined then return GameService.IsJoined() end end)
        if okJoined and joined == false then return false end
        local okPaused, paused = pcall(function() if GameService.IsPaused then return GameService.IsPaused() end end)
        if okPaused and paused == true then return false end
    end
    return true
end

local function getRuntimeStatusText()
    local info = getCurrentPlaceInfo()
    local state = combatRuntimeActive() and "COMBAT ACTIVE" or "IDLE"
    return ("%s • PlaceId %s • %s"):format(info.Name, tostring(game.PlaceId), state)
end

local function safeRequire(instance)
    if not instance or not instance:IsA("ModuleScript") then return nil end
    local ok, result = pcall(require, instance)
    if ok and result ~= nil then return result end
    if instance then requireErrors[instance:GetFullName()] = tostring(result) end
    return nil
end

local function getExactModule(folderName, moduleName)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    if not folder then return nil end
    local child = folder:FindFirstChild(moduleName)
    if child and child:IsA("ModuleScript") then return child end
    return nil
end

local function refreshLocalEntity()
    if not EntityService then LocalEntity = nil return nil end
    local current
    pcall(function()
        current = EntityService.LocalEntity
        if not current and EntityService.GetLocalEntity then current = EntityService.GetLocalEntity() end
    end)
    if current then LocalEntity = current end
    return LocalEntity
end

local function tableHasFunction(t, key)
    if type(t) ~= "table" then return false end
    local ok, value = pcall(rawget, t, key)
    return ok and type(value) == "function"
end

local function tableHasValue(t, key)
    if type(t) ~= "table" then return false end
    local ok, value = pcall(rawget, t, key)
    return ok and value ~= nil
end

local function classifyModuleTable(t)
    if type(t) ~= "table" then return end
    if not EntityService and tableHasFunction(t, "FetchEntity") and tableHasFunction(t, "GetOrCreateEntity") and tableHasFunction(t, "GetEntity") and tableHasValue(t, "WorldManager") then EntityService = t end
    if not GameService and tableHasFunction(t, "IsJoined") and tableHasFunction(t, "GetTeam") and tableHasValue(t, "RoomManager") and tableHasValue(t, "LocalGameClient") then GameService = t end
    if not CameraController and tableHasFunction(t, "GetCamera") and tableHasFunction(t, "GetTargetingFn") and (tableHasFunction(t, "UpdateTarging") or tableHasFunction(t, "GetTargetingEntity")) then CameraController = t end
    if not EntityController and tableHasFunction(t, "GetController") and tableHasValue(t, "ControllerChanged") then EntityController = t end
    if not Effects and tableHasValue(t, "Smoke") and tableHasValue(t, "Flash") and (tableHasValue(t, "Bullet") or tableHasValue(t, "Projectile")) then Effects = t end
    if not WatchingHelper and tableHasValue(t, "Watching") and tableHasValue(t, "WatchingEntity") and tableHasFunction(t, "FilterEntity") then WatchingHelper = t end
    if not WeaponController and tableHasFunction(t, "GetWeapon") and tableHasFunction(t, "GetWeapons") and tableHasValue(t, "Components") and tableHasValue(t, "ClientWeapon") and tableHasValue(t, "API") then WeaponController = t end
end

local function tryExactRequires()
    EntityService = EntityService or safeRequire(getExactModule("Remote", "EntityService"))
    GameService = GameService or safeRequire(getExactModule("Remote", "GameService"))
    CameraController = CameraController or safeRequire(getExactModule("Client", "CameraController"))
    EntityController = EntityController or safeRequire(getExactModule("Client", "EntityController"))
    Effects = Effects or safeRequire(getExactModule("Client", "Effects"))
    WatchingHelper = WatchingHelper or safeRequire(getExactModule("Client", "WatchingHelper"))
    WeaponController = WeaponController or safeRequire(getExactModule("Client", "WeaponController"))
    if EntityService then pcall(function() WorldManager = WorldManager or EntityService.WorldManager end) end
end

local function tryLoadedModules()
    if type(getloadedmodules) ~= "function" then return end
    local ok, modules = pcall(getloadedmodules)
    if not ok or type(modules) ~= "table" then return end
    for _, module in ipairs(modules) do
        if typeof(module) == "Instance" and module:IsA("ModuleScript") then
            local fullName = module:GetFullName()
            if not EntityService and fullName == "ReplicatedStorage.Remote.EntityService" then EntityService = safeRequire(module)
            elseif not GameService and fullName == "ReplicatedStorage.Remote.GameService" then GameService = safeRequire(module)
            elseif not CameraController and fullName == "ReplicatedStorage.Client.CameraController" then CameraController = safeRequire(module)
            elseif not EntityController and fullName == "ReplicatedStorage.Client.EntityController" then EntityController = safeRequire(module)
            elseif not Effects and fullName == "ReplicatedStorage.Client.Effects" then Effects = safeRequire(module)
            elseif not WatchingHelper and fullName == "ReplicatedStorage.Client.WatchingHelper" then WatchingHelper = safeRequire(module)
            elseif not WeaponController and fullName == "ReplicatedStorage.Client.WeaponController" then WeaponController = safeRequire(module) end
        end
    end
    if EntityService then pcall(function() WorldManager = WorldManager or EntityService.WorldManager end) end
end

local function tryGarbageCollector()
    if type(getgc) ~= "function" then return end
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return end
    for _, object in ipairs(objects) do
        if type(object) == "table" then pcall(classifyModuleTable, object) end
        if EntityService and GameService and CameraController and EntityController and Effects and WatchingHelper and WeaponController then break end
    end
    if EntityService then pcall(function() WorldManager = WorldManager or EntityService.WorldManager end) end
end

local function updateBackendStatus()
    refreshLocalEntity()
    local loaded = {}
    if EntityService then table.insert(loaded, "Entity") end
    if GameService then table.insert(loaded, "Room") end
    if CameraController then table.insert(loaded, "Camera") end
    if EntityController then table.insert(loaded, "Visibility") end
    if Effects then table.insert(loaded, "Effects") end
    if WeaponController then table.insert(loaded, "Weapon") end
    if EntityService and WorldManager and CameraController and WeaponController then
        backendName = "Native"
        moduleInitState = "READY • native " .. table.concat(loaded, "/")
    elseif #loaded > 0 then
        backendName = "Hybrid"
        moduleInitState = "READY • hybrid " .. table.concat(loaded, "/") .. " + fallback"
    else
        backendName = "Fallback"
        moduleInitState = "READY • replicated fallback active"
    end
    setStatus(moduleInitState)
end

local function initializeGameModules()
    moduleInitState = "Finding game backend..."
    setStatus(moduleInitState)
    tryExactRequires()
    if not (EntityService and GameService and CameraController and WeaponController) then tryLoadedModules() end
    if not (EntityService and GameService and CameraController and WeaponController) then tryGarbageCollector() end
    updateBackendStatus()
end

local destroyed = false
local lockedTarget = nil
local lockedTargetLastInfo = nil
local lockedTargetLastValidAt = 0
local lastTargetChangeAt = 0
local lastAutoShotAt = 0
local lastAutoShotAttemptAt = 0
local lastAutoShootTarget = nil
local autoShootPressPending = false
local lastTriggerShotAt = 0
local targetVelocityHistory = setmetatable({}, {__mode = "k"})
local espObjects = {}
local connections = {}
local renderName = "__SW_SniperArena_AimESP_" .. tostring(math.random(100000, 999999))

local FOVColorState = { mode = "Custom", custom = Color3.fromRGB(255, 255, 255) }
local ESPColorState = { mode = "Custom", custom = Color3.fromRGB(255, 78, 78) }

local function getRainbowColor(speed, offset)
    local t = (tick() * (speed or 1) + (offset or 0)) % 1
    return Color3.fromHSV(t, 1, 1)
end

local function getCurrentFOVColor()
    if FOVColorState.mode == "Rainbow" then return getRainbowColor(0.5, 0) end
    return FOVColorState.custom
end

local function getCurrentESPColor()
    if ESPColorState.mode == "Rainbow" then return getRainbowColor(0.5, 0) end
    return ESPColorState.custom
end

local mouseAimSupported = type(mousemoverel) == "function"
local mouseAimMoveConst = Vector2.new(1, 0.77) * math.rad(0.5)
local userGameSettings = nil
pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)

local function wrapAimAngle(value)
    value = value % math.pi
    value = value - (value >= (math.pi / 2) and math.pi or 0)
    value = value + (value < -(math.pi / 2) and math.pi or 0)
    return value
end

local function getAimMouseSensitivity()
    local sensitivity = 1
    if userGameSettings then
        local ok, value = pcall(function() return userGameSettings.MouseSensitivity end)
        if ok and type(value) == "number" and value > 0 then sensitivity = value end
    end
    return math.max(sensitivity, 0.001)
end

local function moveAimWithMouse(cam, targetPosition, dt, responseSpeed, snap)
    if not mouseAimSupported or not cam or not targetPosition then return false end
    local offset = targetPosition - cam.CFrame.Position
    if offset.Magnitude <= 0.001 then return true end
    local facing = cam.CFrame.LookVector
    local targetDirection = offset.Unit
    if targetDirection.X ~= targetDirection.X or targetDirection.Y ~= targetDirection.Y or targetDirection.Z ~= targetDirection.Z then return false end
    local diffYaw = wrapAimAngle(math.atan2(facing.X, facing.Z) - math.atan2(targetDirection.X, targetDirection.Z))
    local facingY = math.clamp(facing.Y, -1, 1)
    local targetY = math.clamp(targetDirection.Y, -1, 1)
    local diffPitch = math.asin(facingY) - math.asin(targetY)
    local sensitivity = getAimMouseSensitivity()
    local denominator = mouseAimMoveConst * sensitivity
    local delta = Vector2.new(
        diffYaw / math.max(math.abs(denominator.X), 0.000001),
        diffPitch / math.max(math.abs(denominator.Y), 0.000001)
    )
    local response = 1 - math.exp(-(math.max(responseSpeed, 0.01) * 0.68) * math.max(dt, 0))
    if snap then response = 1 end
    delta = delta * math.clamp(response, 0, 1)
    delta = Vector2.new(math.clamp(delta.X, -450, 450), math.clamp(delta.Y, -450, 450))
    local ok = pcall(mousemoverel, delta.X, delta.Y)
    return ok
end

local function addConnection(connection)
    table.insert(connections, connection)
    return connection
end

local function safeCall(fn, ...)
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
    return nil
end

local guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui", 10) end
if not guiParent and gethui then
    local ok, result = pcall(gethui)
    if ok and result then guiParent = result end
end
if not guiParent then guiParent = CoreGui end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScaredWareSniperArena"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
ScreenGui.Parent = guiParent

local OverlayFolder = Instance.new("Folder")
OverlayFolder.Name = "ESP"
OverlayFolder.Parent = ScreenGui

local function currentCamera()
    Camera = workspace.CurrentCamera or Camera
    return Camera
end

local function getRawInstance(entity)
    if typeof(entity) == "Instance" then return entity end
    if type(entity) == "table" then
        local instance = safeCall(function() return entity.Instance end)
        if typeof(instance) == "Instance" then return instance end
    end
    return nil
end

local function getPlayerFromEntityLike(entity)
    local instance = getRawInstance(entity)
    if not instance then return nil end
    if instance:IsA("Player") then return instance end
    if instance:IsA("Model") then return Players:GetPlayerFromCharacter(instance) end
    local model = instance:FindFirstAncestorOfClass("Model")
    if model then return Players:GetPlayerFromCharacter(model) end
    return nil
end

local function getEntityModel(entity)
    if not entity then return nil end
    local rawInstance = getRawInstance(entity)
    if rawInstance then
        if rawInstance:IsA("Player") then return rawInstance.Character
        elseif rawInstance:IsA("Model") then return rawInstance
        elseif rawInstance:IsA("BasePart") then return rawInstance:FindFirstAncestorOfClass("Model") or rawInstance end
    end
    local model = safeCall(function() if entity.GetModel then return entity:GetModel() end end)
    if typeof(model) == "Instance" then return model end
    local workspaceRoot = safeCall(function() if entity.GetWorkspaceRoot then return entity:GetWorkspaceRoot() end end)
    if typeof(workspaceRoot) == "Instance" then return workspaceRoot end
    local root = safeCall(function() if entity.GetRootPart then return entity:GetRootPart() end end)
    if typeof(root) == "Instance" then
        if root:IsA("Model") then return root
        elseif root:IsA("BasePart") then return root:FindFirstAncestorOfClass("Model") or root end
    end
    return nil
end

local function getRootPart(entity)
    if not entity then return nil end
    if typeof(entity) ~= "Instance" then
        local root = safeCall(function() if entity.GetRootPart then return entity:GetRootPart() end end)
        if typeof(root) == "Instance" and root:IsA("BasePart") then return root end
    end
    local model = getEntityModel(entity)
    if model then
        if model:IsA("Model") then
            return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
        elseif model:IsA("BasePart") then return model end
    end
    return nil
end

local function getHeadPart(entity)
    if not entity then return nil end
    if typeof(entity) ~= "Instance" then
        local head = safeCall(function() if entity.GetHeadPart then return entity:GetHeadPart() end end)
        if typeof(head) == "Instance" and head:IsA("BasePart") then return head end
    end
    local model = getEntityModel(entity)
    if model and model:IsA("Model") then
        local found = model:FindFirstChild("Head")
        if found and found:IsA("BasePart") then return found end
    end
    return nil
end

local function getAimPosition(entity)
    local model = getEntityModel(entity)
    local aimPoint = tostring(Config.Aim.AimPoint or "Head")
    local function validPart(part)
        return typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent ~= nil
    end
    local head = getHeadPart(entity)
    local torso = nil
    local root = getRootPart(entity)
    if model and model:IsA("Model") then
        torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("LowerTorso") or root
    else
        torso = root
    end
    if aimPoint == "Upper Torso" then
        if validPart(torso) then return torso.Position, torso end
        if validPart(head) then return head.Position, head end
    elseif aimPoint == "Closest Part" and model and model:IsA("Model") then
        local cam = currentCamera()
        local bestPart, bestScreenDistance = nil, math.huge
        if cam then
            local viewportCenter = cam.ViewportSize * 0.5
            local candidates = {head, model:FindFirstChild("UpperTorso"), model:FindFirstChild("Torso"), model:FindFirstChild("LowerTorso"), root}
            for _, part in ipairs(candidates) do
                if validPart(part) then
                    local screen, visible = cam:WorldToViewportPoint(part.Position)
                    if visible and screen.Z > 0 then
                        local delta = Vector2.new(screen.X, screen.Y) - viewportCenter
                        local distance = delta.Magnitude
                        if distance < bestScreenDistance then
                            bestScreenDistance = distance
                            bestPart = part
                        end
                    end
                end
            end
        end
        if bestPart then return bestPart.Position, bestPart end
    else
        if validPart(head) then return head.Position, head end
        if typeof(entity) ~= "Instance" then
            local headCF = safeCall(function() if entity.GetHeadAt then return entity:GetHeadAt() end end)
            if typeof(headCF) == "CFrame" then return headCF.Position, nil end
        end
    end
    if typeof(entity) ~= "Instance" then
        local pivot = safeCall(function() if entity.GetPivot then return entity:GetPivot(true) end end)
        if typeof(pivot) == "CFrame" then return pivot.Position, root end
    end
    if validPart(root) then return root.Position, root end
    if model and model:IsA("Model") then
        local pivot = safeCall(function() return model:GetPivot() end)
        if typeof(pivot) == "CFrame" then return pivot.Position, model.PrimaryPart end
    end
    return nil, nil
end

local function getTargetVelocity(entity, aimPart)
    local rawVelocity = nil
    if typeof(entity) ~= "Instance" then
        rawVelocity = safeCall(function() if entity.GetVelocity then return entity:GetVelocity() end end)
    end
    if typeof(rawVelocity) ~= "Vector3" then
        local part = aimPart
        if not (typeof(part) == "Instance" and part:IsA("BasePart")) then part = getRootPart(entity) end
        if typeof(part) == "Instance" and part:IsA("BasePart") then rawVelocity = part.AssemblyLinearVelocity end
    end
    if typeof(rawVelocity) ~= "Vector3" then rawVelocity = Vector3.zero end
    if rawVelocity.Magnitude > 250 then rawVelocity = rawVelocity.Unit * 250 end
    local smoothing = math.clamp(tonumber(Config.Aim.PredictionSmoothing) or 0.72, 0, 0.98)
    local previous = targetVelocityHistory[entity]
    local filtered
    if typeof(previous) == "Vector3" then filtered = previous:Lerp(rawVelocity, 1 - smoothing)
    else filtered = rawVelocity end
    targetVelocityHistory[entity] = filtered
    return filtered
end

local function getPredictedAimPosition(entity, position, part)
    if not Config.Aim.Prediction then return position end
    local lead = math.clamp(tonumber(Config.Aim.PredictionTime) or 0, 0, 0.30)
    if lead <= 0 then return position end
    local velocity = getTargetVelocity(entity, part)
    local verticalScale = math.abs(velocity.Y) >= 8 and 0.10 or 0.30
    local offset = Vector3.new(velocity.X * lead, velocity.Y * lead * verticalScale, velocity.Z * lead)
    offset = Vector3.new(offset.X, math.clamp(offset.Y, -2.25, 2.25), offset.Z)
    local maxOffset = math.max(tonumber(Config.Aim.MaxPredictionOffset) or 14, 0)
    if maxOffset > 0 and offset.Magnitude > maxOffset then offset = offset.Unit * maxOffset end
    return position + offset
end

local function getDisplayName(entity)
    local rawInstance = getRawInstance(entity)
    if rawInstance then
        if rawInstance:IsA("Player") then return rawInstance.DisplayName or rawInstance.Name end
        local display = safeCall(function() return rawInstance:GetAttribute("DisplayName") end)
        if type(display) == "string" and #display > 0 then return display end
        return rawInstance.Name
    end
    local name = safeCall(function() if entity.GetDisplayName then return entity:GetDisplayName() end end)
    if type(name) == "string" and #name > 0 then return name end
    local player = safeCall(function() return entity.Player end)
    if typeof(player) == "Instance" and player:IsA("Player") then return player.DisplayName or player.Name end
    return "Enemy"
end

local function getHealth(entity)
    local rawInstance = getRawInstance(entity)
    if rawInstance then
        local health = safeCall(function() return rawInstance:GetAttribute("Health") end)
        local maxHealth = safeCall(function() return rawInstance:GetAttribute("MaxHealth") end)
        if type(health) ~= "number" or type(maxHealth) ~= "number" then
            local model = getEntityModel(entity)
            local humanoid = model and model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                health = type(health) == "number" and health or humanoid.Health
                maxHealth = type(maxHealth) == "number" and maxHealth or humanoid.MaxHealth
            end
        end
        health = tonumber(health) or 0
        maxHealth = tonumber(maxHealth) or math.max(health, 100)
        if maxHealth <= 0 then maxHealth = math.max(health, 100) end
        return health, maxHealth
    end
    local health = safeCall(function() return entity.Health end)
    local maxHealth = safeCall(function() return entity.MaxHealth end)
    health = tonumber(health) or 0
    maxHealth = tonumber(maxHealth) or math.max(health, 100)
    if maxHealth <= 0 then maxHealth = math.max(health, 100) end
    return health, maxHealth
end

local function isAlive(entity)
    if not entity then return false end
    if typeof(entity) ~= "Instance" then
        local alive = safeCall(function() if entity.IsAlive then return entity:IsAlive() end end)
        if alive ~= nil then return alive == true end
    end
    local root = getRootPart(entity)
    if not root or not root.Parent then return false end
    local health = getHealth(entity)
    return health > 0
end

local function getTeamValue(entity)
    local instance = getRawInstance(entity)
    if instance then
        local team = safeCall(function() return instance:GetAttribute("Team") end)
        if team ~= nil then return team end
        local player = getPlayerFromEntityLike(entity)
        if player then
            local playerTeam = safeCall(function() return player:GetAttribute("Team") end)
            if playerTeam ~= nil then return playerTeam end
            if player.Team then return player.Team end
        end
    end
    return safeCall(function() return entity.Team end)
end

local function isEnemy(entity)
    refreshLocalEntity()
    if not entity or not isAlive(entity) then return false end
    local rawInstance = getRawInstance(entity)
    local player = getPlayerFromEntityLike(entity)
    if rawInstance == LocalPlayer or rawInstance == LocalPlayer.Character or player == LocalPlayer or entity == LocalEntity then return false end
    if LocalEntity and typeof(entity) ~= "Instance" then
        local friendly = safeCall(function() return LocalEntity:IsFriendly(entity) end)
        if friendly == true then return false
        elseif friendly == false then return true end
    end
    local localTeam = LocalPlayer:GetAttribute("Team")
    local targetTeam = getTeamValue(entity)
    if localTeam == "Lobby" or targetTeam == "Lobby" then return false end
    if localTeam == "Team3" then return true end
    if localTeam ~= nil and targetTeam ~= nil then return localTeam ~= targetTeam end
    if player and LocalPlayer.Team and player.Team and not LocalPlayer.Neutral and not player.Neutral then
        return LocalPlayer.Team ~= player.Team
    end
    return true
end

local function gameSaysVisible(entity)
    if not Config.Aim.RespectGameVisibility or not EntityController then return true end
    local controller = safeCall(function() return EntityController.GetController(entity) end)
    if not controller or not controller.VisibleController then return true end
    local visibleController = controller.VisibleController
    if visibleController.CurrentVisible == false then return false end
    if tonumber(visibleController.CurrentTransparency) == 1 then return false end
    return true
end

local function blockedByEffects(position)
    if not Effects then return false end
    if Config.Aim.RespectFlash then
        local flashAlpha = safeCall(function() return Effects.Flash.GetFlashingAlpha() end)
        if type(flashAlpha) == "number" and flashAlpha > 0.5 then return true end
    end
    if Config.Aim.RespectSmoke then
        local inSmoke = safeCall(function() return Effects.Smoke.InSmoke() end)
        if inSmoke then return true end
        local posInSmoke = safeCall(function() return Effects.Smoke.PosInSmoke(position) end)
        if posInSmoke then return true end
    end
    return false
end

local visibilityParams = RaycastParams.new()
visibilityParams.FilterType = Enum.RaycastFilterType.Exclude
visibilityParams.RespectCanCollide = false
pcall(function() visibilityParams.CollisionGroup = "CanCollide" end)

local function buildVisibilityFilter(entity)
    local filter = {}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    local model = getEntityModel(entity)
    if model then table.insert(filter, model) end
    local highlightFolder = workspace:FindFirstChild("Highlight")
    if highlightFolder then table.insert(filter, highlightFolder) end
    local tempFolder = workspace:FindFirstChild("_Temp")
    if tempFolder then table.insert(filter, tempFolder) end
    local terrain = workspace:FindFirstChild("Terrain")
    if terrain then
        local ball = terrain:FindFirstChild("Ball")
        if ball then table.insert(filter, ball) end
    end
    return filter
end

local function hasLineOfSight(entity, position)
    local cam = currentCamera()
    if not cam or not position then return false end
    if not Config.Aim.VisibleCheck then return true end
    visibilityParams.FilterDescendantsInstances = buildVisibilityFilter(entity)
    local origin = cam.CFrame.Position
    local direction = position - origin
    if direction.Magnitude <= 0.01 then return true end
    local result = workspace:Raycast(origin, direction, visibilityParams)
    if result then
        local hitDist = (result.Position - origin).Magnitude
        if hitDist < (direction.Magnitude - 1.5) then return false end
    end
    return true
end

local function getFocusedEntities()
    if not WorldManager then return {} end
    local result = safeCall(function() return WorldManager.GetFocusedEntities() end)
    if type(result) == "table" then return result end
    local world = safeCall(function() return WorldManager.GetFocusedWorld() end)
    if world and type(world.Entities) == "table" then return world.Entities end
    return {}
end

local function convertInstanceToNativeEntity(instance)
    if not EntityService or typeof(instance) ~= "Instance" then return nil end
    return safeCall(function() if EntityService.GetEntity then return EntityService.GetEntity(instance) end end)
end

local function iterateReplicatedFallback(callback, alreadySeen)
    local seen = alreadySeen or {}
    local function consider(candidate)
        if not candidate or seen[candidate] then return end
        seen[candidate] = true
        local native = convertInstanceToNativeEntity(candidate)
        if native and not seen[native] then
            seen[native] = true
            if isEnemy(native) then callback(native) return end
        end
        if isEnemy(candidate) then callback(candidate) end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then consider(player) end
    end
    for _, tagName in ipairs({"Entity", "Bot"}) do
        local tagged = safeCall(function() return CollectionService:GetTagged(tagName) end)
        if type(tagged) == "table" then
            for _, instance in ipairs(tagged) do
                if typeof(instance) == "Instance" then consider(instance) end
            end
        end
    end
end

local function iterateEnemies(callback)
    local seen = {}
    local usedNative = false
    if GameService and GameService.RoomManager then
        local room = safeCall(function() return GameService.RoomManager.GetFocusedRoom() end)
        local modeHandler = room and room.ModeHandler
        if room and modeHandler and room.ClientsByTeam and modeHandler.GetEnemyTeams then
            local enemyTeams = safeCall(function() return modeHandler:GetEnemyTeams() end)
            if type(enemyTeams) == "table" then
                for _, team in pairs(enemyTeams) do
                    local clients = room.ClientsByTeam[team]
                    if type(clients) == "table" then
                        for _, client in pairs(clients) do
                            local entity = safeCall(function() return client:GetEntity() end)
                            if entity and not seen[entity] and isEnemy(entity) then
                                seen[entity] = true
                                usedNative = true
                                callback(entity)
                            end
                        end
                    end
                end
            end
        end
    end
    if not usedNative then
        for _, entity in pairs(getFocusedEntities()) do
            if entity and not seen[entity] and isEnemy(entity) then
                seen[entity] = true
                usedNative = true
                callback(entity)
            end
        end
    end
    if not usedNative then iterateReplicatedFallback(callback, seen) end
end

local function worldToScreen(position)
    local cam = currentCamera()
    if not cam then return nil, false, nil end
    local v, onScreen = cam:WorldToViewportPoint(position)
    return Vector2.new(v.X, v.Y), onScreen and v.Z > 0, v.Z
end

local function screenCenter()
    local cam = currentCamera()
    if not cam then return Vector2.zero end
    return cam.ViewportSize / 2
end

local function targetInfo(entity, fovMultiplier)
    if not isEnemy(entity) then return nil end
    local rawPosition, part = getAimPosition(entity)
    if not rawPosition then return nil end
    local cam = currentCamera()
    if not cam then return nil end
    local selectionPosition = rawPosition
    local selectionRoot = getRootPart(entity)
    if typeof(selectionRoot) == "Instance" and selectionRoot:IsA("BasePart") and selectionRoot.Parent ~= nil then
        selectionPosition = selectionRoot.Position
    end
    local distance = (selectionPosition - cam.CFrame.Position).Magnitude
    if distance > Config.Aim.MaxDistance then return nil end
    if not gameSaysVisible(entity) then return nil end
    if blockedByEffects(rawPosition) then return nil end
    local visible = hasLineOfSight(entity, rawPosition)
    if Config.Aim.VisibleCheck and not visible then return nil end
    local rawScreenPos, rawOnScreen = worldToScreen(selectionPosition)
    if not rawOnScreen then return nil end
    local rawScreenDistance = (rawScreenPos - screenCenter()).Magnitude
    local maxFov = Config.Aim.FOV * (fovMultiplier or 1)
    if rawScreenDistance > maxFov then return nil end
    local position = getPredictedAimPosition(entity, rawPosition, part)
    local predictedScreenPos, predictedOnScreen = worldToScreen(position)
    if not predictedOnScreen then
        position = rawPosition
        predictedScreenPos = rawScreenPos
    end
    local predictedScreenDistance = (predictedScreenPos - screenCenter()).Magnitude
    local health, maxHealth = getHealth(entity)
    local healthRatio = maxHealth > 0 and math.clamp(health / maxHealth, 0, 1) or 1
    local distanceRatio = math.clamp(distance / math.max(Config.Aim.MaxDistance, 1), 0, 1)
    local priority = tostring(Config.Aim.TargetPriority or "Hybrid")
    local score
    if priority == "Distance" then
        score = (rawScreenDistance * 0.35) + (distanceRatio * maxFov * 0.65)
    elseif priority == "Low Health" then
        score = (rawScreenDistance * 0.60) + (healthRatio * maxFov * 0.40)
    elseif priority == "Hybrid" then
        score = (rawScreenDistance * 0.65) + (distanceRatio * maxFov * 0.20) + (healthRatio * maxFov * 0.15)
        if visible then score = score * 0.92 end
    else
        score = rawScreenDistance
    end
    return {
        Entity = entity, Position = position, RawPosition = rawPosition, Part = part,
        Distance = distance, ScreenDistance = predictedScreenDistance, RawScreenDistance = rawScreenDistance,
        Score = score, Visible = visible, Velocity = getTargetVelocity(entity, part),
    }
end

local function keepLockedTargetThroughGrace()
    if not lockedTarget or not lockedTargetLastInfo then return nil end
    local grace = math.max(tonumber(Config.Aim.LockGrace) or 0, 0)
    if grace <= 0 or (os.clock() - lockedTargetLastValidAt) > grace then return nil end
    if not isEnemy(lockedTarget) then return nil end
    local rawPosition, part = getAimPosition(lockedTarget)
    if rawPosition then
        local info = lockedTargetLastInfo
        info.RawPosition = rawPosition
        info.Part = part
        info.Position = getPredictedAimPosition(lockedTarget, rawPosition, part)
        info.Velocity = getTargetVelocity(lockedTarget, part)
        local screenPos, onScreen = worldToScreen(info.Position)
        if onScreen then info.ScreenDistance = (screenPos - screenCenter()).Magnitude end
        return info
    end
    return lockedTargetLastInfo
end

local function acquireTarget()
    local currentInfo = nil
    if lockedTarget then
        currentInfo = targetInfo(lockedTarget, Config.Aim.StickyMultiplier)
        if currentInfo then
            currentInfo.Score = currentInfo.Score * 0.78
            lockedTargetLastInfo = currentInfo
            lockedTargetLastValidAt = os.clock()
        else
            currentInfo = keepLockedTargetThroughGrace()
        end
    end
    local best = nil
    iterateEnemies(function(entity)
        if entity ~= lockedTarget then
            local info = targetInfo(entity, 1)
            if info and (not best or info.Score < best.Score) then best = info end
        end
    end)
    if currentInfo then
        if not best then return currentInfo end
        local threshold = math.clamp(tonumber(Config.Aim.SwitchThreshold) or 0.12, 0, 0.90)
        local requiredScore = currentInfo.Score * (1 - threshold)
        local delay = math.max(tonumber(Config.Aim.SwitchDelay) or 0, 0)
        local delayPassed = (os.clock() - lastTargetChangeAt) >= delay
        if not delayPassed or best.Score >= requiredScore then return currentInfo end
    end
    if best then
        if lockedTarget ~= best.Entity then lastTargetChangeAt = os.clock() end
        lockedTarget = best.Entity
        lockedTargetLastInfo = best
        lockedTargetLastValidAt = os.clock()
        return best
    end
    lockedTarget = nil
    lockedTargetLastInfo = nil
    return nil
end

local function localPlayerAlive()
    if LocalEntity then
        local alive = safeCall(function() return LocalEntity:IsAlive() end)
        if alive ~= nil then return alive == true end
    end
    local character = LocalPlayer.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local health = LocalPlayer:GetAttribute("Health")
    if type(health) == "number" then return health > 0 end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid == nil or humanoid.Health > 0
end

local function nativeMouseButtonHeld(buttonName)
    local normalized = normalizeAutoShootButton(buttonName)
    local inputType = normalized == "LMB" and Enum.UserInputType.MouseButton1 or Enum.UserInputType.MouseButton2
    local ok, held = pcall(function() return UserInputService:IsMouseButtonPressed(inputType) end)
    return ok and held == true
end

local function nativeRMBHeld() return nativeMouseButtonHeld("RMB") end
local function autoShootButtonHeld() return nativeMouseButtonHeld(Config.Aim.AutoShootButton) end

local function customAimKeyHeld()
    if not Config.Aim.AimKeybindEnabled then return false end
    local ok, held = pcall(function() return UserInputService:IsKeyDown(Config.Aim.AimKeybind) end)
    return ok and held == true
end

local function customAutoShootKeyHeld()
    if not Config.Aim.AutoShootKeybindEnabled then return false end
    local ok, held = pcall(function() return UserInputService:IsKeyDown(Config.Aim.AutoShootKeybind) end)
    return ok and held == true
end

local function autoShootActive()
    if not Config.Aim.AutoShoot then return false end
    if not combatRuntimeActive() then lockedTarget = nil return false end
    refreshLocalEntity()
    if not localPlayerAlive() then return false end
    if WatchingHelper and WatchingHelper.Watching and WatchingHelper.Watching ~= LocalPlayer then return false end
    if CameraController and CameraController.IsBusy then
        local busy = safeCall(CameraController.IsBusy)
        if busy == true then return false end
    end
    if Config.Aim.AutoShootKeybindEnabled then
        return customAutoShootKeyHeld()
    end
    return autoShootButtonHeld()
end

local function aimActive()
    if not Config.Aim.Enabled then return false end
    if not combatRuntimeActive() then lockedTarget = nil return false end
    refreshLocalEntity()
    if not localPlayerAlive() then return false end
    if WatchingHelper and WatchingHelper.Watching and WatchingHelper.Watching ~= LocalPlayer then return false end
    if CameraController and CameraController.IsBusy then
        local busy = safeCall(CameraController.IsBusy)
        if busy == true then return false end
    end
    if Config.Aim.AimKeybindEnabled then
        return customAimKeyHeld()
    end
    if not Config.Aim.HoldRMB then return true end
    return nativeRMBHeld()
end

local function triggerBotActive()
    if not Config.TriggerBot.Enabled then return false end
    if not combatRuntimeActive() then return false end
    refreshLocalEntity()
    if not localPlayerAlive() then return false end
    if WatchingHelper and WatchingHelper.Watching and WatchingHelper.Watching ~= LocalPlayer then return false end
    if CameraController and CameraController.IsBusy then
        local busy = safeCall(CameraController.IsBusy)
        if busy == true then return false end
    end
    if Config.TriggerBot.HoldKeyEnabled then
        local ok, held = pcall(function() return UserInputService:IsKeyDown(Config.TriggerBot.HoldKey) end)
        if not ok or not held then return false end
    end
    return true
end

local function getLocalShootable()
    if not WeaponController or type(WeaponController.GetWeapon) ~= "function" then return nil end
    local weapon = safeCall(function() return WeaponController.GetWeapon() end)
    if not weapon then return nil end
    local function fromWeapon(candidate)
        if type(candidate) ~= "table" then return nil end
        local shootable = safeCall(function() return candidate._Shootable end)
        if type(shootable) == "table" and type(shootable.LocalShoot) == "function" then return shootable end
        return nil
    end
    local direct = fromWeapon(weapon)
    if direct then return direct end
    local children = safeCall(function() return weapon.Weapons end)
    if type(children) == "table" then
        for _, child in pairs(children) do
            local shootable = fromWeapon(child)
            if shootable then return shootable end
        end
    end
    return nil
end

local function sendNativePrimaryFire()
    local shootable = getLocalShootable()
    if not shootable then return false end
    local ok = pcall(function() shootable:LocalShoot() end)
    return ok
end

local function sendPrimaryFireInput()
    if sendNativePrimaryFire() then return true end
    if type(mouse1click) == "function" then
        local ok = pcall(mouse1click)
        if ok then return true end
    end
    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        if autoShootPressPending then return false end
        autoShootPressPending = true
        local ok = pcall(mouse1press)
        task.delay(0.018, function()
            pcall(mouse1release)
            autoShootPressPending = false
        end)
        if ok then return true end
        autoShootPressPending = false
    end
    local okService, vim = pcall(function() return game:GetService("VirtualInputManager") end)
    if okService and vim then
        local centre = screenCenter()
        local ok = pcall(function()
            vim:SendMouseButtonEvent(math.floor(centre.X), math.floor(centre.Y), 0, true, game, 0)
            vim:SendMouseButtonEvent(math.floor(centre.X), math.floor(centre.Y), 0, false, game, 0)
        end)
        if ok then return true end
    end
    local okVU, virtualUser = pcall(function() return game:GetService("VirtualUser") end)
    if okVU and virtualUser then
        local centre = screenCenter()
        local ok = pcall(function()
            virtualUser:Button1Down(Vector2.new(centre.X, centre.Y), currentCamera() and currentCamera().CFrame or CFrame.new())
            task.delay(0.018, function()
                pcall(function()
                    virtualUser:Button1Up(Vector2.new(centre.X, centre.Y), currentCamera() and currentCamera().CFrame or CFrame.new())
                end)
            end)
        end)
        if ok then return true end
    end
    return false
end

local function tryAutoShoot(info)
    if not Config.Aim.AutoShoot or not info or not info.Entity then return end
    if lockedTarget ~= info.Entity or not isEnemy(info.Entity) then return end
    if not combatRuntimeActive() or not localPlayerAlive() then return end
    if normalizeAutoShootButton(Config.Aim.AutoShootButton) ~= "LMB" and nativeMouseButtonHeld("LMB") then return end
    local screenPos, onScreen = worldToScreen(info.Position)
    if not onScreen then return end
    local errorPixels = (screenPos - screenCenter()).Magnitude
    local radius = math.clamp(tonumber(Config.Aim.AutoShootRadius) or 10, 1, 50)
    if errorPixels > radius then return end
    local freshInfo = targetInfo(info.Entity, Config.Aim.StickyMultiplier)
    if not freshInfo then return end
    local now = os.clock()
    local delay = math.clamp(tonumber(Config.Aim.AutoShootDelay) or 0, 0, 1)
    if lastAutoShootTarget ~= info.Entity then
        lastAutoShootTarget = info.Entity
        lastAutoShotAttemptAt = 0
    elseif delay > 0 and (now - lastAutoShotAttemptAt) < delay then
        return
    end
    lastAutoShotAttemptAt = now
    if sendPrimaryFireInput() then lastAutoShotAt = now end
end

local function tryTriggerBot()
    if not triggerBotActive() then return end
    local cam = currentCamera()
    if not cam then return end
    local centre = screenCenter()
    local radius = math.clamp(tonumber(Config.TriggerBot.Radius) or 3, 1, 50)
    local best = nil
    local bestDistance = math.huge
    iterateEnemies(function(entity)
        if not isEnemy(entity) then return end
        local rawPos, part = getAimPosition(entity)
        if not rawPos then return end
        if Config.TriggerBot.WallCheck then
            local filter = buildVisibilityFilter(entity)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = filter
            params.RespectCanCollide = false
            params.IgnoreWater = true
            local origin = cam.CFrame.Position
            local direction = rawPos - origin
            local result = workspace:Raycast(origin, direction, params)
            if result then
                local hitDist = (result.Position - origin).Magnitude
                local enemyDist = direction.Magnitude
                if hitDist < (enemyDist - 2) then
                    return
                end
            end
        end
        local screenPos, onScreen = worldToScreen(rawPos)
        if not onScreen then return end
        local errorPixels = (screenPos - centre).Magnitude
        if errorPixels <= radius and errorPixels < bestDistance then
            bestDistance = errorPixels
            best = entity
        end
    end)
    if not best then return end
    local now = os.clock()
    local delay = math.clamp(tonumber(Config.TriggerBot.Delay) or 0.05, 0, 1)
    if now - lastTriggerShotAt < delay then return end
    if sendPrimaryFireInput() then lastTriggerShotAt = now end
end

local function applyAim(dt)
    local shouldAim = aimActive()
    local shouldAutoShoot = autoShootActive()
    if not shouldAim and not shouldAutoShoot then
        if not combatRuntimeActive() or not localPlayerAlive() or (not Config.Aim.Enabled and not Config.Aim.AutoShoot) then
            lockedTarget = nil
            lockedTargetLastInfo = nil
        end
        return
    end
    local info = acquireTarget()
    if not info then return end
    lockedTarget = info.Entity
    local cam = currentCamera()
    if not cam then return end
    if shouldAim then
        local current = cam.CFrame
        local instantAutoShot = shouldAutoShoot and (autoShootButtonHeld() or customAutoShootKeyHeld())
        if instantAutoShot then
            cam.CFrame = CFrame.lookAt(current.Position, info.Position)
        else
            local speed = math.max(tonumber(Config.Aim.SmoothSpeed) or 0.01, 0.01)
            if Config.Aim.AdaptiveSmoothing then
                local normalized = math.clamp(info.ScreenDistance / math.max(Config.Aim.FOV, 1), 0, 1)
                local multiplier = 0.55 + (math.sqrt(normalized) * 1.45)
                speed = speed * multiplier
            end
            local snapRadius = math.max(tonumber(Config.Aim.MicroSnapRadius) or 0, 0)
            local shouldSnap = snapRadius > 0 and info.ScreenDistance <= snapRadius
            local usedMouseAim = moveAimWithMouse(cam, info.Position, dt, speed, shouldSnap)
            if not usedMouseAim then
                local desired = CFrame.lookAt(current.Position, info.Position)
                local alpha = 1 - math.exp(-speed * math.max(dt, 0))
                if shouldSnap then alpha = 1 end
                cam.CFrame = current:Lerp(desired, math.clamp(alpha, 0, 1))
            end
        end
    end
    pcall(function()
        if CameraController and CameraController.UpdateTarging then
            CameraController.UpdateTarging()
        end
    end)
    if shouldAutoShoot then tryAutoShoot(info) end
end

local function makeStroke(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = Color3.fromRGB(255, 78, 78)
    stroke.Transparency = 0
    stroke.Parent = parent
    return stroke
end

local function makeText(parent)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.35
    label.TextSize = 13
    label.ZIndex = 10
    label.Parent = parent
    return label
end

local function createESP(entity)
    if espObjects[entity] then return espObjects[entity] end
    local holder = Instance.new("Frame")
    holder.Name = "EntityESP"
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 5
    holder.Parent = OverlayFolder

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.fromScale(1, 1)
    box.ZIndex = 5
    box.Parent = holder
    local boxStroke = makeStroke(box, 1.5)

    local nameLabel = makeText(holder)
    nameLabel.Name = "Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Position = UDim2.new(0.5, 0, 0, -3)
    nameLabel.Size = UDim2.new(1.7, 0, 0, 18)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center

    local infoLabel = makeText(holder)
    infoLabel.Name = "Info"
    infoLabel.AnchorPoint = Vector2.new(0.5, 0)
    infoLabel.Position = UDim2.new(0.5, 0, 1, 3)
    infoLabel.Size = UDim2.new(1.8, 0, 0, 18)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center

    local hpBack = Instance.new("Frame")
    hpBack.Name = "HealthBack"
    hpBack.AnchorPoint = Vector2.new(1, 0)
    hpBack.Position = UDim2.new(0, -4, 0, 0)
    hpBack.Size = UDim2.new(0, 4, 1, 0)
    hpBack.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    hpBack.BorderSizePixel = 0
    hpBack.ZIndex = 6
    hpBack.Parent = holder

    local hpFill = Instance.new("Frame")
    hpFill.Name = "Health"
    hpFill.AnchorPoint = Vector2.new(0, 1)
    hpFill.Position = UDim2.new(0, 0, 1, 0)
    hpFill.Size = UDim2.fromScale(1, 1)
    hpFill.BackgroundColor3 = Color3.fromRGB(85, 255, 110)
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = 7
    hpFill.Parent = hpBack

    local highlight = Instance.new("Highlight")
    highlight.Name = "SW_ESP_Highlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 60, 60)
    highlight.FillTransparency = 0.82
    highlight.OutlineColor = Color3.fromRGB(255, 115, 115)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = workspace

    local object = {
        Holder = holder, Box = box, BoxStroke = boxStroke,
        Name = nameLabel, Info = infoLabel,
        HealthBack = hpBack, HealthFill = hpFill,
        Highlight = highlight,
    }
    espObjects[entity] = object
    return object
end

local function removeESP(entity)
    local object = espObjects[entity]
    if not object then return end
    for _, instance in pairs(object) do
        if typeof(instance) == "Instance" then
            pcall(function() instance:Destroy() end)
        end
    end
    espObjects[entity] = nil
end

local function getBounds(entity)
    local model = getEntityModel(entity)
    if not model then return nil end
    local cf, size
    if model:IsA("Model") then
        local ok, a, b = pcall(model.GetBoundingBox, model)
        if not ok then return nil end
        cf, size = a, b
    elseif model:IsA("BasePart") then
        cf, size = model.CFrame, model.Size
    else
        return nil
    end
    if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then return nil end
    size = size + Vector3.new(0.25, 0.35, 0.25)
    local half = size * 0.5
    local corners = {
        Vector3.new(-half.X, -half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z),
        Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new(-half.X,  half.Y,  half.Z),
        Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new( half.X,  half.Y, -half.Z),
        Vector3.new( half.X,  half.Y,  half.Z),
    }
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyInFront = false
    local cam = currentCamera()
    for _, localCorner in ipairs(corners) do
        local worldCorner = cf:PointToWorldSpace(localCorner)
        local point = cam:WorldToViewportPoint(worldCorner)
        if point.Z > 0 then
            anyInFront = true
            minX = math.min(minX, point.X)
            minY = math.min(minY, point.Y)
            maxX = math.max(maxX, point.X)
            maxY = math.max(maxY, point.Y)
        end
    end
    if not anyInFront or minX == math.huge then return nil end
    local width = maxX - minX
    local height = maxY - minY
    if width < 2 or height < 2 then return nil end
    return minX, minY, width, height, model
end

local function hideESPObject(object)
    object.Holder.Visible = false
    object.Highlight.Enabled = false
end

local function updateESP()
    if not Config.ESP.Enabled or not combatRuntimeActive() then
        for _, object in pairs(espObjects) do hideESPObject(object) end
        return
    end
    local seen = {}
    local cam = currentCamera()
    local baseColor = getCurrentESPColor()
    iterateEnemies(function(entity)
        seen[entity] = true
        local position = getAimPosition(entity)
        if not position then
            local object = espObjects[entity]
            if object then hideESPObject(object) end
            return
        end
        local distance = (position - cam.CFrame.Position).Magnitude
        if distance > Config.ESP.MaxDistance then
            local object = espObjects[entity]
            if object then hideESPObject(object) end
            return
        end
        local object = createESP(entity)
        local minX, minY, width, height, model = getBounds(entity)
        local locked = entity == lockedTarget
        local mainColor = locked and Color3.fromRGB(100, 255, 125) or baseColor
        object.BoxStroke.Color = mainColor
        object.Highlight.FillColor = mainColor
        object.Highlight.OutlineColor = mainColor
        object.Highlight.Adornee = model
        object.Highlight.Enabled = Config.ESP.Chams and model ~= nil
        if minX then
            object.Holder.Visible = true
            object.Holder.Position = UDim2.fromOffset(minX, minY)
            object.Holder.Size = UDim2.fromOffset(width, height)
            object.Box.Visible = Config.ESP.Boxes
            object.Name.Visible = Config.ESP.Names
            object.Name.Text = getDisplayName(entity)
            local health, maxHealth = getHealth(entity)
            local ratio = math.clamp(health / math.max(maxHealth, 1), 0, 1)
            object.HealthBack.Visible = Config.ESP.Health
            object.HealthFill.Size = UDim2.fromScale(1, ratio)
            local info = {}
            if Config.ESP.Health then table.insert(info, ("%d HP"):format(math.max(0, math.floor(health + 0.5)))) end
            if Config.ESP.Distance then table.insert(info, ("%d studs"):format(math.floor(distance + 0.5))) end
            object.Info.Visible = #info > 0
            object.Info.Text = table.concat(info, "  •  ")
        else
            object.Holder.Visible = false
        end
    end)
    for entity, _ in pairs(espObjects) do
        if not seen[entity] or not isAlive(entity) then removeESP(entity) end
    end
end

local FOVRing = Instance.new("Frame")
FOVRing.Name = "FOV"
FOVRing.AnchorPoint = Vector2.new(0.5, 0.5)
FOVRing.BackgroundTransparency = 1
FOVRing.BorderSizePixel = 0
FOVRing.ZIndex = 2
FOVRing.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVRing

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.25
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVRing

local function updateFOV()
    local centre = screenCenter()
    local diameter = Config.Aim.FOV * 2
    FOVRing.Position = UDim2.fromOffset(centre.X, centre.Y)
    FOVRing.Size = UDim2.fromOffset(diameter, diameter)
    FOVRing.Visible = Config.Aim.ShowFOV and Config.Aim.Enabled and combatRuntimeActive()
    local baseColor = getCurrentFOVColor()
    FOVStroke.Color = lockedTarget and Color3.fromRGB(100, 255, 125) or baseColor
end

local TOGGLE_KEY = Enum.KeyCode.RightAlt

local Window = VindUI:CreateWindow({
    Title = "Scared Ware UI",
    Subtitle = "Sniper Arena - v0.1",
    Icon = "Lucide:ghost",
    Size = UDim2.fromOffset(660, 480),
    MinSize = Vector2.new(500, 360),
    Draggable = true,
    Resizable = true,
    UseBlur = true,
    DefaultTab = "Combat",
})

VindUI:Notify({
    Title = "Scared Ware UI",
    Text = "Sniper Arena v0.1 Loaded",
    Type = "success",
    Duration = 4,
})

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "Lucide:crosshair" })
local TriggerTab = Window:AddTab({ Name = "Trigger Bot", Icon = "Lucide:zap" })
local KeybindsTab = Window:AddTab({ Name = "Keybinds", Icon = "Lucide:keyboard" })
local LegitTab = Window:AddTab({ Name = "Legit", Icon = "Lucide:user-check" })
local RageTab = Window:AddTab({ Name = "Rage", Icon = "Lucide:flame" })
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "Lucide:eye" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "Lucide:settings" })
local ConfigsTab = Window:AddTab({ Name = "Configs", Icon = "Lucide:save" })
local HomeTab = Window:AddTab({ Name = "Home", Icon = "Lucide:layout-dashboard" })

local UIControls = {}
local syncUIFromConfig
local LegitModeLabel
local RageModeLabel

CombatTab:AddSection("Game Integration", "Lucide:server")
local BackendStatusLabel = CombatTab:AddLabel(moduleInitState)

setStatus = function(text)
    moduleInitState = tostring(text or "Unknown")
    if BackendStatusLabel and BackendStatusLabel.Set then BackendStatusLabel:Set(moduleInitState) end
end

CombatTab:AddLabel("Native game hooks are used when available; replicated fallback otherwise.")

local RuntimeStatusLabel = CombatTab:AddLabel(getRuntimeStatusText())
CombatTab:AddLabel("Universe-based support: all current and future Sniper Arena subplaces accepted.")

CombatTab:AddDivider()
CombatTab:AddSection("Auto Aim", "Lucide:crosshair")

UIControls.AimEnabled = CombatTab:AddToggle({
    Text = "Enable Auto Aim",
    Default = Config.Aim.Enabled,
    Callback = function(value) Config.Aim.Enabled = value if not value then lockedTarget = nil end end,
})

UIControls.AimActivation = CombatTab:AddDropdown({
    Text = "Aim Activation",
    Options = {"Hold RMB", "Always On"},
    Default = Config.Aim.HoldRMB and "Hold RMB" or "Always On",
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.HoldRMB = value ~= "Always On"
        Config.Aim.AimKeybindEnabled = false
        lockedTarget = nil
        VindUI:Notify({Title = "Auto Aim", Text = Config.Aim.HoldRMB and "Hold RMB" or "Always On", Type = "info", Duration = 2})
    end,
})

CombatTab:AddDivider()
CombatTab:AddSection("Auto Shoot", "Lucide:target")

UIControls.AutoShoot = CombatTab:AddToggle({
    Text = "Enable Auto Shoot",
    Default = Config.Aim.AutoShoot,
    Callback = function(value)
        Config.Aim.AutoShoot = value
        lastAutoShotAt = 0
        lastAutoShotAttemptAt = 0
        lastAutoShootTarget = nil
    end,
})

UIControls.AutoShootButton = CombatTab:AddDropdown({
    Text = "Auto Shoot Button",
    Options = {"RMB", "LMB"},
    Default = normalizeAutoShootButton(Config.Aim.AutoShootButton),
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.AutoShootButton = normalizeAutoShootButton(value)
        Config.Aim.AutoShootKeybindEnabled = false
        lastAutoShotAt = 0
        lastAutoShotAttemptAt = 0
        lastAutoShootTarget = nil
        VindUI:Notify({Title = "Auto Shoot", Text = "Button: " .. Config.Aim.AutoShootButton, Type = "info", Duration = 2})
    end,
})

UIControls.AutoShootRadius = CombatTab:AddSlider({
    Text = "Shoot Radius", Min = 2, Max = 30, Default = Config.Aim.AutoShootRadius, Increment = 1,
    Suffix = " px", Callback = function(value) Config.Aim.AutoShootRadius = value end,
})

UIControls.AutoShootDelay = CombatTab:AddSlider({
    Text = "Extra Shot Delay", Min = 0.00, Max = 0.50, Default = Config.Aim.AutoShootDelay, Increment = 0.01,
    Suffix = " s", Callback = function(value) Config.Aim.AutoShootDelay = value end,
})

CombatTab:AddDivider()
CombatTab:AddSection("Aim Point / Lock", "Lucide:locate-fixed")

UIControls.AimPoint = CombatTab:AddDropdown({
    Text = "Aim Point",
    Options = {"Head", "Upper Torso", "Closest Part"},
    Default = Config.Aim.AimPoint,
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.AimPoint = value or "Head"
        Config.Aim.HeadPriority = Config.Aim.AimPoint == "Head"
        lockedTarget = nil
    end,
})

UIControls.StickyTarget = CombatTab:AddToggle({
    Text = "Sticky Target",
    Default = Config.Aim.StickyTarget,
    Callback = function(value) Config.Aim.StickyTarget = value if not value then lockedTarget = nil end end,
})

CombatTab:AddDivider()
CombatTab:AddSection("Visibility", "Lucide:eye")

UIControls.VisibleCheck = CombatTab:AddToggle({
    Text = "Wall / Visibility Check",
    Default = Config.Aim.VisibleCheck,
    Callback = function(value) Config.Aim.VisibleCheck = value lockedTarget = nil end,
})

UIControls.GameVisibility = CombatTab:AddToggle({
    Text = "Respect Game Visibility",
    Default = Config.Aim.RespectGameVisibility,
    Callback = function(value) Config.Aim.RespectGameVisibility = value end,
})

UIControls.RespectSmoke = CombatTab:AddToggle({
    Text = "Respect Smoke",
    Default = Config.Aim.RespectSmoke,
    Callback = function(value) Config.Aim.RespectSmoke = value end,
})

UIControls.RespectFlash = CombatTab:AddToggle({
    Text = "Respect Flash",
    Default = Config.Aim.RespectFlash,
    Callback = function(value) Config.Aim.RespectFlash = value end,
})

CombatTab:AddDivider()
CombatTab:AddSection("FOV / Response", "Lucide:radius")

UIControls.ShowFOV = CombatTab:AddToggle({
    Text = "Show FOV Circle",
    Default = Config.Aim.ShowFOV,
    Callback = function(value) Config.Aim.ShowFOV = value end,
})

UIControls.FOV = CombatTab:AddSlider({
    Text = "FOV Radius", Min = 40, Max = 600, Default = Config.Aim.FOV, Increment = 5,
    Suffix = " px", Callback = function(value) Config.Aim.FOV = value end,
})

UIControls.AimSpeed = CombatTab:AddSlider({
    Text = "Aim Speed", Min = 4, Max = 120, Default = Config.Aim.SmoothSpeed, Increment = 1,
    Callback = function(value) Config.Aim.SmoothSpeed = value end,
})

UIControls.AimDistance = CombatTab:AddSlider({
    Text = "Aim Max Distance", Min = 100, Max = 700, Default = Config.Aim.MaxDistance, Increment = 25,
    Suffix = " studs",
    Callback = function(value) Config.Aim.MaxDistance = value lockedTarget = nil end,
})

CombatTab:AddDivider()
CombatTab:AddSection("FOV Colors", "Lucide:palette")

CombatTab:AddDropdown({
    Text = "FOV Color Mode",
    Options = {"Custom", "Rainbow"},
    Default = FOVColorState.mode,
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        FOVColorState.mode = value or "Custom"
    end,
})

CombatTab:AddColorPicker({
    Text = "FOV Custom Color",
    Default = FOVColorState.custom,
    Callback = function(color)
        FOVColorState.custom = color
        FOVColorState.mode = "Custom"
    end,
})

CombatTab:AddDivider()
CombatTab:AddSection("Advanced Targeting", "Lucide:cpu")

UIControls.TargetPriority = CombatTab:AddDropdown({
    Text = "Target Priority",
    Options = {"Crosshair", "Distance", "Low Health", "Hybrid"},
    Default = Config.Aim.TargetPriority,
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.TargetPriority = value or "Hybrid"
        lockedTarget = nil
    end,
})

UIControls.Prediction = CombatTab:AddToggle({
    Text = "Motion Prediction",
    Default = Config.Aim.Prediction,
    Callback = function(value) Config.Aim.Prediction = value end,
})

UIControls.PredictionTime = CombatTab:AddSlider({
    Text = "Prediction Time", Min = 0, Max = 0.30, Default = Config.Aim.PredictionTime, Increment = 0.01,
    Suffix = " s", Callback = function(value) Config.Aim.PredictionTime = value end,
})

UIControls.AdaptiveSmoothing = CombatTab:AddToggle({
    Text = "Adaptive Smoothing",
    Default = Config.Aim.AdaptiveSmoothing,
    Callback = function(value) Config.Aim.AdaptiveSmoothing = value end,
})

UIControls.MicroSnap = CombatTab:AddSlider({
    Text = "Micro Snap Radius", Min = 0, Max = 10, Default = Config.Aim.MicroSnapRadius, Increment = 0.5,
    Suffix = " px", Callback = function(value) Config.Aim.MicroSnapRadius = value end,
})

UIControls.SwitchDelay = CombatTab:AddSlider({
    Text = "Target Switch Delay", Min = 0, Max = 0.30, Default = Config.Aim.SwitchDelay, Increment = 0.01,
    Suffix = " s", Callback = function(value) Config.Aim.SwitchDelay = value end,
})

CombatTab:AddDivider()
CombatTab:AddSection("Lock Stability", "Lucide:anchor")

UIControls.LockGrace = CombatTab:AddSlider({
    Text = "Target Lock Grace", Min = 0, Max = 0.50, Default = Config.Aim.LockGrace, Increment = 0.01,
    Suffix = " s", Callback = function(value) Config.Aim.LockGrace = value end,
})

UIControls.SwitchThreshold = CombatTab:AddSlider({
    Text = "Switch Improvement Required", Min = 0, Max = 0.50, Default = Config.Aim.SwitchThreshold, Increment = 0.01,
    Callback = function(value) Config.Aim.SwitchThreshold = value end,
})

UIControls.PredictionSmoothing = CombatTab:AddSlider({
    Text = "Prediction Stability", Min = 0, Max = 0.95, Default = Config.Aim.PredictionSmoothing, Increment = 0.01,
    Callback = function(value) Config.Aim.PredictionSmoothing = value end,
})

UIControls.MaxPredictionOffset = CombatTab:AddSlider({
    Text = "Max Prediction Offset", Min = 0, Max = 30, Default = Config.Aim.MaxPredictionOffset, Increment = 1,
    Suffix = " studs", Callback = function(value) Config.Aim.MaxPredictionOffset = value end,
})

TriggerTab:AddSection("Trigger Bot", "Lucide:zap")

TriggerTab:AddParagraph({
    Title = "Trigger Bot",
    Icon = "Lucide:info",
    Text = "Automatically fires when your crosshair passes over an enemy. Uses the game's native weapon fire path. Wall Check controls whether the enemy must be visible or can be shot through walls.",
})

UIControls.TriggerBotEnabled = TriggerTab:AddToggle({
    Text = "Enable Trigger Bot",
    Default = Config.TriggerBot.Enabled,
    Callback = function(value)
        Config.TriggerBot.Enabled = value
        VindUI:Notify({Title = "Trigger Bot", Text = value and "Enabled" or "Disabled", Type = value and "success" or "warning", Duration = 2})
    end,
})

UIControls.TriggerBotWallCheck = TriggerTab:AddToggle({
    Text = "Wall Check",
    Description = "Only fire if the enemy is visible (respects walls / smoke / flash)",
    Default = Config.TriggerBot.WallCheck,
    Callback = function(value) Config.TriggerBot.WallCheck = value end,
})

UIControls.TriggerBotRadius = TriggerTab:AddSlider({
    Text = "Trigger Radius", Min = 1, Max = 50, Default = Config.TriggerBot.Radius, Increment = 1,
    Suffix = " px", Callback = function(value) Config.TriggerBot.Radius = value end,
})

UIControls.TriggerBotDelay = TriggerTab:AddSlider({
    Text = "Trigger Delay", Min = 0, Max = 0.50, Default = Config.TriggerBot.Delay, Increment = 0.01,
    Suffix = " s", Callback = function(value) Config.TriggerBot.Delay = value end,
})

TriggerTab:AddDivider()
TriggerTab:AddSection("Hold Key", "Lucide:keyboard")

TriggerTab:AddToggle({
    Text = "Enable Hold Key",
    Description = "Only fire while holding a specific key",
    Default = Config.TriggerBot.HoldKeyEnabled,
    Callback = function(value) Config.TriggerBot.HoldKeyEnabled = value end,
})

TriggerTab:AddKeybind({
    Text = "Trigger Hold Key",
    Description = "Key you must hold for the trigger bot to fire",
    Default = Config.TriggerBot.HoldKey,
    Callback = function(key, kind)
        if key then Config.TriggerBot.HoldKey = key end
    end,
})

TriggerTab:AddLabel("Wall Check ON: respects walls, smoke, and flash. Wall Check OFF: fires through walls.")

KeybindsTab:AddSection("Auto Aim Keybind", "Lucide:crosshair")

KeybindsTab:AddParagraph({
    Title = "Custom Aim Keybind",
    Icon = "Lucide:info",
    Text = "Enable this to use a custom key instead of Hold RMB for Auto Aim. When enabled, RMB is ignored and the assigned key activates aiming.",
})

KeybindsTab:AddToggle({
    Text = "Enable Custom Aim Keybind",
    Default = Config.Aim.AimKeybindEnabled,
    Callback = function(value)
        Config.Aim.AimKeybindEnabled = value
        if value then Config.Aim.HoldRMB = false end
        lockedTarget = nil
        VindUI:Notify({Title = "Aim Keybind", Text = value and "Enabled" or "Disabled", Type = value and "success" or "warning", Duration = 2})
    end,
})

KeybindsTab:AddKeybind({
    Text = "Aim Key",
    Description = "Hold this key to activate Auto Aim",
    Default = Config.Aim.AimKeybind,
    Callback = function(key, kind)
        if key then Config.Aim.AimKeybind = key end
    end,
})

KeybindsTab:AddDivider()
KeybindsTab:AddSection("Auto Shoot Keybind", "Lucide:target")

KeybindsTab:AddParagraph({
    Title = "Custom Auto Shoot Keybind",
    Icon = "Lucide:info",
    Text = "Enable this to use a custom key instead of RMB / LMB for Auto Shoot. When enabled, the mouse buttons are ignored and the assigned key activates Auto Shoot.",
})

KeybindsTab:AddToggle({
    Text = "Enable Custom Auto Shoot Keybind",
    Default = Config.Aim.AutoShootKeybindEnabled,
    Callback = function(value)
        Config.Aim.AutoShootKeybindEnabled = value
        VindUI:Notify({Title = "Auto Shoot Keybind", Text = value and "Enabled" or "Disabled", Type = value and "success" or "warning", Duration = 2})
    end,
})

KeybindsTab:AddKeybind({
    Text = "Auto Shoot Key",
    Description = "Hold this key to activate Auto Shoot",
    Default = Config.Aim.AutoShootKeybind,
    Callback = function(key, kind)
        if key then Config.Aim.AutoShootKeybind = key end
    end,
})

KeybindsTab:AddDivider()
KeybindsTab:AddSection("Menu", "Lucide:keyboard")

KeybindsTab:AddKeybind({
    Text = "Toggle Menu",
    Description = "Open / close the panel",
    Default = TOGGLE_KEY,
    Callback = function(key, kind)
        if kind == "press" then Window:Toggle() end
    end,
})

VisualTab:AddSection("ESP", "Lucide:eye")

UIControls.ESPEnabled = VisualTab:AddToggle({
    Text = "Enable ESP",
    Default = Config.ESP.Enabled,
    Callback = function(value)
        Config.ESP.Enabled = value
        if not value then
            for _, object in pairs(espObjects) do hideESPObject(object) end
        end
    end,
})

UIControls.Boxes = VisualTab:AddToggle({
    Text = "Boxes", Default = Config.ESP.Boxes,
    Callback = function(value) Config.ESP.Boxes = value end,
})

UIControls.Names = VisualTab:AddToggle({
    Text = "Names", Default = Config.ESP.Names,
    Callback = function(value) Config.ESP.Names = value end,
})

UIControls.Health = VisualTab:AddToggle({
    Text = "Health", Default = Config.ESP.Health,
    Callback = function(value) Config.ESP.Health = value end,
})

UIControls.Distance = VisualTab:AddToggle({
    Text = "Distance", Default = Config.ESP.Distance,
    Callback = function(value) Config.ESP.Distance = value end,
})

UIControls.Chams = VisualTab:AddToggle({
    Text = "Chams", Default = Config.ESP.Chams,
    Callback = function(value) Config.ESP.Chams = value end,
})

VisualTab:AddDivider()
VisualTab:AddSection("ESP Colors", "Lucide:palette")

VisualTab:AddDropdown({
    Text = "ESP Color Mode",
    Options = {"Custom", "Rainbow"},
    Default = ESPColorState.mode,
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        ESPColorState.mode = value or "Custom"
    end,
})

VisualTab:AddColorPicker({
    Text = "ESP Custom Color",
    Default = ESPColorState.custom,
    Callback = function(color)
        ESPColorState.custom = color
        ESPColorState.mode = "Custom"
    end,
})

VisualTab:AddDivider()
VisualTab:AddSection("ESP Range", "Lucide:maximize")

UIControls.ESPDistance = VisualTab:AddSlider({
    Text = "ESP Max Distance", Min = 100, Max = 3000, Default = Config.ESP.MaxDistance, Increment = 50,
    Suffix = " studs", Callback = function(value) Config.ESP.MaxDistance = value end,
})

local function updateAimModeLabels()
    local text = "Current mode • " .. tostring(Config.AimMode or "Custom")
    if LegitModeLabel and LegitModeLabel.Set then LegitModeLabel:Set(text) end
    if RageModeLabel and RageModeLabel.Set then RageModeLabel:Set(text) end
end

local function applyAimPreset(name, values, notification)
    ConfigStore.Applying = true
    Config.AimMode = name
    for key, value in pairs(values or {}) do
        if Config.Aim[key] ~= nil then Config.Aim[key] = value end
    end
    ConfigStore.Applying = false
    lockedTarget = nil
    if syncUIFromConfig then syncUIFromConfig() end
    updateAimModeLabels()
    VindUI:Notify({Title = name, Text = notification or (name .. " applied"), Type = "success", Duration = 2.2})
end

LegitTab:AddSection("Legit Aim", "Lucide:user-check")
LegitModeLabel = LegitTab:AddLabel("Current mode • " .. tostring(Config.AimMode))

LegitTab:AddParagraph({
    Title = "Legit Mode",
    Icon = "Lucide:info",
    Text = "Smooth visible-target aiming designed to look less abrupt. Legit presets keep wall checks, game visibility, smoke and flash handling enabled.",
})

LegitTab:AddButton({
    Text = "Legit • Subtle",
    Description = "Hold RMB • 80px FOV • smooth • visibility-safe",
    Icon = "Lucide:feather",
    Callback = function()
        applyAimPreset("Legit • Subtle", {
            Enabled = true, HoldRMB = true, VisibleCheck = true,
            RespectGameVisibility = true, RespectSmoke = true, RespectFlash = true,
            HeadPriority = true, AimPoint = "Head", Prediction = true,
            PredictionTime = 0.04, PredictionSmoothing = 0.82, MaxPredictionOffset = 10,
            SwitchThreshold = 0.22, LockGrace = 0.24, AdaptiveSmoothing = true,
            MicroSnapRadius = 0.5, TargetPriority = "Hybrid", SwitchDelay = 0.12,
            FOV = 80, SmoothSpeed = 13, MaxDistance = 700, StickyTarget = true,
            StickyMultiplier = 1.15, ShowFOV = false,
            AimKeybindEnabled = false, AutoShootKeybindEnabled = false,
        })
    end,
})

LegitTab:AddButton({
    Text = "Legit • Balanced",
    Description = "Hold RMB • 120px FOV • fast balanced response",
    Icon = "Lucide:scale",
    Callback = function()
        applyAimPreset("Legit • Balanced", {
            Enabled = true, HoldRMB = true, VisibleCheck = true,
            RespectGameVisibility = true, RespectSmoke = true, RespectFlash = true,
            HeadPriority = true, AimPoint = "Head", Prediction = true,
            PredictionTime = 0.06, PredictionSmoothing = 0.78, MaxPredictionOffset = 12,
            SwitchThreshold = 0.18, LockGrace = 0.22, AdaptiveSmoothing = true,
            MicroSnapRadius = 1.0, TargetPriority = "Hybrid", SwitchDelay = 0.08,
            FOV = 120, SmoothSpeed = 22, MaxDistance = 700, StickyTarget = true,
            StickyMultiplier = 1.20, ShowFOV = true,
            AimKeybindEnabled = false, AutoShootKeybindEnabled = false,
        })
    end,
})

LegitTab:AddButton({
    Text = "Legit • Strong",
    Description = "Hold RMB • 180px FOV • very fast response",
    Icon = "Lucide:zap",
    Callback = function()
        applyAimPreset("Legit • Strong", {
            Enabled = true, HoldRMB = true, VisibleCheck = true,
            RespectGameVisibility = true, RespectSmoke = true, RespectFlash = true,
            HeadPriority = true, AimPoint = "Head", Prediction = true,
            PredictionTime = 0.07, PredictionSmoothing = 0.72, MaxPredictionOffset = 14,
            SwitchThreshold = 0.14, LockGrace = 0.18, AdaptiveSmoothing = true,
            MicroSnapRadius = 1.5, TargetPriority = "Crosshair", SwitchDelay = 0.05,
            FOV = 180, SmoothSpeed = 36, MaxDistance = 700, StickyTarget = true,
            StickyMultiplier = 1.25, ShowFOV = true,
            AimKeybindEnabled = false, AutoShootKeybindEnabled = false,
        })
    end,
})

LegitTab:AddDivider()
LegitTab:AddSection("Legit Helpers", "Lucide:wrench")

LegitTab:AddButton({
    Text = "Force Visible Targets Only", Icon = "Lucide:eye",
    Callback = function()
        Config.AimMode = "Legit • Custom"
        Config.Aim.VisibleCheck = true
        Config.Aim.RespectGameVisibility = true
        Config.Aim.RespectSmoke = true
        Config.Aim.RespectFlash = true
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

LegitTab:AddButton({
    Text = "Use Hold RMB", Icon = "Lucide:mouse-pointer",
    Callback = function()
        Config.AimMode = "Legit • Custom"
        Config.Aim.HoldRMB = true
        Config.Aim.AimKeybindEnabled = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:AddSection("Rage Aim", "Lucide:flame")
RageModeLabel = RageTab:AddLabel("Current mode • " .. tostring(Config.AimMode))

RageTab:AddParagraph({
    Title = "Rage Mode",
    Icon = "Lucide:alert-triangle",
    Text = "Aggressive target snapping with Always On support, larger FOV and maximum response. Max Rage can acquire targets even when normal wall/effect filters are disabled.",
})

RageTab:AddButton({
    Text = "Rage • Visible",
    Description = "Always On • 500px FOV • very fast • visible targets only",
    Icon = "Lucide:eye",
    Callback = function()
        applyAimPreset("Rage • Visible", {
            Enabled = true, HoldRMB = false, VisibleCheck = true,
            RespectGameVisibility = true, RespectSmoke = false, RespectFlash = false,
            HeadPriority = true, AimPoint = "Head", Prediction = true,
            PredictionTime = 0.08, PredictionSmoothing = 0.62, MaxPredictionOffset = 16,
            SwitchThreshold = 0.07, LockGrace = 0.14, AdaptiveSmoothing = false,
            MicroSnapRadius = 4, TargetPriority = "Crosshair", SwitchDelay = 0,
            FOV = 500, SmoothSpeed = 92, MaxDistance = 700, StickyTarget = true,
            StickyMultiplier = 1.45, ShowFOV = true,
            AimKeybindEnabled = false, AutoShootKeybindEnabled = false,
        })
    end,
})

RageTab:AddButton({
    Text = "Rage • Max",
    Description = "Always On • max FOV • instant-class response",
    Icon = "Lucide:flame",
    Callback = function()
        applyAimPreset("Rage • Max", {
            Enabled = true, HoldRMB = false, VisibleCheck = false,
            RespectGameVisibility = false, RespectSmoke = false, RespectFlash = false,
            HeadPriority = true, AimPoint = "Closest Part", Prediction = true,
            PredictionTime = 0.10, PredictionSmoothing = 0.55, MaxPredictionOffset = 18,
            SwitchThreshold = 0.03, LockGrace = 0.12, AdaptiveSmoothing = false,
            MicroSnapRadius = 8, TargetPriority = "Crosshair", SwitchDelay = 0,
            FOV = 600, SmoothSpeed = 120, MaxDistance = 700, StickyTarget = true,
            StickyMultiplier = 1.60, ShowFOV = true,
            AimKeybindEnabled = false, AutoShootKeybindEnabled = false,
        })
    end,
})

RageTab:AddDivider()
RageTab:AddSection("Rage Helpers", "Lucide:wrench")

RageTab:AddButton({
    Text = "Always On", Icon = "Lucide:power",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.Enabled = true
        Config.Aim.HoldRMB = false
        Config.Aim.AimKeybindEnabled = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:AddButton({
    Text = "Ignore Walls / Visibility", Icon = "Lucide:eye-off",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.VisibleCheck = false
        Config.Aim.RespectGameVisibility = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:AddButton({
    Text = "Ignore Smoke / Flash", Icon = "Lucide:wind",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.RespectSmoke = false
        Config.Aim.RespectFlash = false
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:AddButton({
    Text = "Max Prediction / Closest Part", Icon = "Lucide:move-3d",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.AimPoint = "Closest Part"
        Config.Aim.Prediction = true
        Config.Aim.PredictionTime = 0.10
        Config.Aim.PredictionSmoothing = 0.55
        Config.Aim.MaxPredictionOffset = 18
        Config.Aim.TargetPriority = "Crosshair"
        Config.Aim.MicroSnapRadius = 8
        Config.Aim.SwitchDelay = 0
        Config.Aim.SwitchThreshold = 0.03
        Config.Aim.LockGrace = 0.12
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:AddButton({
    Text = "Max FOV / Aim Speed", Icon = "Lucide:maximize-2",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.FOV = 600
        Config.Aim.SmoothSpeed = 120
        Config.Aim.MaxDistance = 700
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

syncUIFromConfig = function()
    ConfigStore.Applying = true
    local pairsToSet = {
        {UIControls.AimEnabled, Config.Aim.Enabled},
        {UIControls.AimActivation, Config.Aim.HoldRMB and "Hold RMB" or "Always On"},
        {UIControls.AutoShoot, Config.Aim.AutoShoot},
        {UIControls.AutoShootButton, normalizeAutoShootButton(Config.Aim.AutoShootButton)},
        {UIControls.AutoShootRadius, Config.Aim.AutoShootRadius},
        {UIControls.AutoShootDelay, Config.Aim.AutoShootDelay},
        {UIControls.AimPoint, Config.Aim.AimPoint},
        {UIControls.StickyTarget, Config.Aim.StickyTarget},
        {UIControls.VisibleCheck, Config.Aim.VisibleCheck},
        {UIControls.GameVisibility, Config.Aim.RespectGameVisibility},
        {UIControls.RespectSmoke, Config.Aim.RespectSmoke},
        {UIControls.RespectFlash, Config.Aim.RespectFlash},
        {UIControls.ShowFOV, Config.Aim.ShowFOV},
        {UIControls.FOV, Config.Aim.FOV},
        {UIControls.AimSpeed, Config.Aim.SmoothSpeed},
        {UIControls.AimDistance, Config.Aim.MaxDistance},
        {UIControls.TargetPriority, Config.Aim.TargetPriority},
        {UIControls.Prediction, Config.Aim.Prediction},
        {UIControls.PredictionTime, Config.Aim.PredictionTime},
        {UIControls.AdaptiveSmoothing, Config.Aim.AdaptiveSmoothing},
        {UIControls.MicroSnap, Config.Aim.MicroSnapRadius},
        {UIControls.SwitchDelay, Config.Aim.SwitchDelay},
        {UIControls.LockGrace, Config.Aim.LockGrace},
        {UIControls.SwitchThreshold, Config.Aim.SwitchThreshold},
        {UIControls.PredictionSmoothing, Config.Aim.PredictionSmoothing},
        {UIControls.MaxPredictionOffset, Config.Aim.MaxPredictionOffset},
        {UIControls.TriggerBotEnabled, Config.TriggerBot.Enabled},
        {UIControls.TriggerBotWallCheck, Config.TriggerBot.WallCheck},
        {UIControls.TriggerBotRadius, Config.TriggerBot.Radius},
        {UIControls.TriggerBotDelay, Config.TriggerBot.Delay},
        {UIControls.ESPEnabled, Config.ESP.Enabled},
        {UIControls.Boxes, Config.ESP.Boxes},
        {UIControls.Names, Config.ESP.Names},
        {UIControls.Health, Config.ESP.Health},
        {UIControls.Distance, Config.ESP.Distance},
        {UIControls.Chams, Config.ESP.Chams},
        {UIControls.ESPDistance, Config.ESP.MaxDistance},
    }
    for _, pair in ipairs(pairsToSet) do
        local control, value = pair[1], pair[2]
        if control and control.Set then
            pcall(function() control:Set(value) end)
        end
    end
    ConfigStore.Applying = false
    lockedTarget = nil
    updateAimModeLabels()
end

ConfigsTab:AddSection("Profiles", "Lucide:user")
ConfigStore.StatusLabel = ConfigsTab:AddLabel(ConfigStore.Available and ("Ready • " .. ConfigStore.Selected) or "Unavailable • filesystem APIs missing")

if ConfigStore.Available then
    ConfigStore.ProfileDropdown = ConfigsTab:AddDropdown({
        Text = "Config Profile", Options = listConfigProfiles(), Default = ConfigStore.Selected,
        Callback = function(option)
            local value = type(option) == "table" and option[1] or option
            if value ~= nil then
                ConfigStore.Selected = sanitizeConfigName(value, "default")
                ConfigStore.PendingProfile = ConfigStore.Selected
                if ConfigStore.ProfileInput and ConfigStore.ProfileInput.Set then ConfigStore.ProfileInput:Set(ConfigStore.Selected) end
                saveMeta()
                setConfigStatus("Selected • " .. ConfigStore.Selected)
            end
        end,
    })
    ConfigStore.ProfileInput = ConfigsTab:AddTextbox({
        Text = "Profile Name", Default = ConfigStore.Selected, Placeholder = "default",
        Callback = function(value) ConfigStore.PendingProfile = sanitizeConfigName(value, ConfigStore.Selected) end,
    })
    ConfigsTab:AddButton({
        Text = "Save / Create Profile", Icon = "Lucide:save",
        Callback = function()
            local profile = ConfigStore.PendingProfile or ConfigStore.Selected
            ConfigStore.Selected = sanitizeConfigName(profile, "default")
            if saveConfig(ConfigStore.Selected, true) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            end
        end,
    })
    ConfigsTab:AddButton({
        Text = "Load Selected Profile", Icon = "Lucide:upload",
        Callback = function() if loadConfig(ConfigStore.Selected, true) then syncUIFromConfig() end end,
    })
    ConfigsTab:AddButton({
        Text = "Refresh Profiles", Icon = "Lucide:refresh-cw",
        Callback = function()
            ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
            ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            setConfigStatus("Profiles refreshed")
        end,
    })
    ConfigsTab:AddButton({
        Text = "Delete Selected Profile", Icon = "Lucide:trash-2",
        Callback = function()
            local deleted = ConfigStore.Selected
            if deleteConfig(deleted) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
                ConfigStore.ProfileInput:Set(ConfigStore.Selected)
                VindUI:Notify({Title = "Configs", Text = "Deleted " .. deleted, Type = "warning", Duration = 2})
            end
        end,
    })
    ConfigsTab:AddDivider()
    ConfigsTab:AddSection("Automation", "Lucide:cog")
    ConfigsTab:AddToggle({
        Text = "Auto Save", Default = ConfigStore.AutoSave,
        Callback = function(value)
            ConfigStore.AutoSave = value == true
            saveMeta()
            if ConfigStore.AutoSave then saveConfig(ConfigStore.Selected, false) end
            setConfigStatus(ConfigStore.AutoSave and ("Auto Save ON • " .. ConfigStore.Selected) or "Auto Save OFF")
        end,
    })
    ConfigsTab:AddToggle({
        Text = "Auto Load", Default = ConfigStore.AutoLoad,
        Callback = function(value)
            ConfigStore.AutoLoad = value == true
            saveMeta()
            setConfigStatus(ConfigStore.AutoLoad and ("Auto Load ON • " .. ConfigStore.Selected) or "Auto Load OFF")
        end,
    })
    ConfigsTab:AddLabel("Auto Save and Auto Load default to ON.")
else
    ConfigsTab:AddParagraph({
        Title = "Persistent Configs Unavailable",
        Icon = "Lucide:alert-triangle",
        Text = "Your executor needs writefile, readfile, isfile and makefolder. AutoAim/ESP still works normally without saved configs.",
    })
end

SettingsTab:AddSection("Sniper Arena", "Lucide:settings")

SettingsTab:AddButton({
    Text = "Reset Aim Settings", Icon = "Lucide:rotate-ccw",
    Callback = function()
        Config.AimMode = "Custom"
        Config.Aim.Enabled = true
        Config.Aim.HoldRMB = true
        Config.Aim.VisibleCheck = true
        Config.Aim.RespectGameVisibility = true
        Config.Aim.RespectSmoke = true
        Config.Aim.RespectFlash = true
        Config.Aim.HeadPriority = true
        Config.Aim.AimPoint = "Head"
        Config.Aim.AutoShoot = false
        Config.Aim.AutoShootButton = "RMB"
        Config.Aim.AutoShootRadius = 10
        Config.Aim.AutoShootDelay = 0.00
        Config.Aim.FOV = 220
        Config.Aim.SmoothSpeed = 46
        Config.Aim.MaxDistance = 700
        Config.Aim.StickyTarget = true
        Config.Aim.StickyMultiplier = 1.30
        Config.Aim.Prediction = true
        Config.Aim.PredictionTime = 0.06
        Config.Aim.PredictionSmoothing = 0.72
        Config.Aim.MaxPredictionOffset = 14
        Config.Aim.AdaptiveSmoothing = true
        Config.Aim.MicroSnapRadius = 1.5
        Config.Aim.TargetPriority = "Hybrid"
        Config.Aim.SwitchDelay = 0.05
        Config.Aim.SwitchThreshold = 0.12
        Config.Aim.LockGrace = 0.18
        Config.Aim.ShowFOV = true
        Config.Aim.AimKeybindEnabled = false
        Config.Aim.AutoShootKeybindEnabled = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        VindUI:Notify({Title = "Sniper Arena", Text = "Aim settings reset", Type = "success", Duration = 2.5})
    end,
})

SettingsTab:AddButton({
    Text = "Reset Trigger Bot Settings", Icon = "Lucide:rotate-ccw",
    Callback = function()
        Config.TriggerBot.Enabled = false
        Config.TriggerBot.WallCheck = true
        Config.TriggerBot.Radius = 3
        Config.TriggerBot.Delay = 0.05
        Config.TriggerBot.HoldKeyEnabled = false
        if syncUIFromConfig then syncUIFromConfig() end
        VindUI:Notify({Title = "Sniper Arena", Text = "Trigger Bot reset", Type = "success", Duration = 2.5})
    end,
})

SettingsTab:AddButton({
    Text = "Reset ESP Settings", Icon = "Lucide:rotate-ccw",
    Callback = function()
        Config.ESP.Enabled = true
        Config.ESP.Boxes = true
        Config.ESP.Names = true
        Config.ESP.Health = true
        Config.ESP.Distance = true
        Config.ESP.Chams = true
        Config.ESP.MaxDistance = 1200
        if syncUIFromConfig then syncUIFromConfig() end
        VindUI:Notify({Title = "Sniper Arena", Text = "ESP settings reset", Type = "success", Duration = 2.5})
    end,
})

SettingsTab:AddDivider()
SettingsTab:AddSection("Menu", "Lucide:keyboard")

SettingsTab:AddKeybind({
    Text = "Toggle Menu",
    Description = "Open / close the panel",
    Icon = "Lucide:keyboard",
    Default = TOGGLE_KEY,
    Callback = function(key, kind)
        if kind == "press" then Window:Toggle() end
    end,
})

local cleanup

SettingsTab:AddButton({
    Text = "Unload Scared Ware UI",
    Description = "Tears down the whole interface",
    Icon = "Lucide:power",
    Callback = function() if cleanup then cleanup() end end,
})

HomeTab:AddSubTab({ Name = "Details And Info", Icon = "Lucide:layout-grid" }):AddSystemInfoGrid({ Description = "Live session info" })

local ChangelogSub = HomeTab:AddSubTab({ Name = "Changelog", Icon = "Lucide:file-text" })

ChangelogSub:AddChangelogEntry({
    Version = "Scared Ware UI v0.1",
    Date    = "Release",
    Changes = {
        { Type = "Added",   Text = "Initial Sniper Arena release" },
        { Type = "Added",   Text = "Auto Aim with full targeting system" },
        { Type = "Added",   Text = "Auto Shoot with RMB / LMB activation" },
        { Type = "Added",   Text = "ESP (Boxes / Names / Health / Distance / Chams)" },
        { Type = "Added",   Text = "ESP Custom / Rainbow color modes" },
        { Type = "Added",   Text = "FOV Custom / Rainbow color modes" },
        { Type = "Added",   Text = "Legit presets (Subtle / Balanced / Strong)" },
        { Type = "Added",   Text = "Rage presets (Visible / Max)" },
        { Type = "Added",   Text = "Configs system (Save / Load / Delete)" },
        { Type = "Added",   Text = "Universe-wide Sniper Arena support" },
        { Type = "Added",   Text = "Menu keybind: Right Alt" },
        { Type = "Added",   Text = "Aim Keybind (custom key for Auto Aim)" },
        { Type = "Added",   Text = "Auto Shoot Keybind (custom key for Auto Shoot)" },
        { Type = "Added",   Text = "Trigger Bot feature" },
        { Type = "Added",   Text = "Trigger Bot Wall Check toggle (with proper filter for Highlight / _Temp / Ball)" },
        { Type = "Added",   Text = "Trigger Bot Hold Key option" },
        { Type = "Added",   Text = "New Keybinds tab" },
        { Type = "Added",   Text = "New Trigger Bot tab" },
    },
})

task.spawn(function()
    task.wait(1)
    if not ConfigStore.Available then return end
    ConfigStore.LastFingerprint = configFingerprint()
    if ConfigStore.AutoSave and not FS.IsFile(configPath(ConfigStore.Selected)) then
        saveConfig(ConfigStore.Selected, false)
    end
    while not destroyed do
        if ConfigStore.AutoSave and not ConfigStore.Applying then
            local current = configFingerprint()
            if current ~= "" and current ~= ConfigStore.LastFingerprint then
                saveConfig(ConfigStore.Selected, false)
            end
        end
        task.wait(0.5)
    end
end)

cleanup = function()
    if destroyed then return end
    destroyed = true
    lockedTarget = nil
    lastAutoShotAt = 0
    if type(mouse1release) == "function" then pcall(mouse1release) end
    autoShootPressPending = false
    pcall(function() RunService:UnbindFromRenderStep(renderName) end)
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(connections)
    for entity, _ in pairs(espObjects) do removeESP(entity) end
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() Window:Destroy() end)
    if ENV.__SNIPER_ARENA_AIM_ESP_CLEANUP == cleanup then
        ENV.__SNIPER_ARENA_AIM_ESP_CLEANUP = nil
    end
end

ENV.__SNIPER_ARENA_AIM_ESP_CLEANUP = cleanup

addConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end))

task.spawn(function()
    for attempt = 1, 6 do
        if destroyed then return end
        local ok = pcall(initializeGameModules)
        if not ok then
            moduleInitState = "READY • fallback (native init failed)"
            setStatus(moduleInitState)
        end
        if EntityService and WorldManager and CameraController and WeaponController then break end
        task.wait(2)
    end
    if not destroyed then updateBackendStatus() end
end)

task.spawn(function()
    while not destroyed do
        if RuntimeStatusLabel and RuntimeStatusLabel.Set then
            pcall(function() RuntimeStatusLabel:Set(getRuntimeStatusText()) end)
        end
        task.wait(1)
    end
end)

RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 25, function(dt)
    if destroyed then return end
    applyAim(dt)
    tryTriggerBot()
    updateFOV()
    updateESP()
end)

Window:SelectTab("Combat")
Window:Open()
