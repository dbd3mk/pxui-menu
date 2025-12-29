local PixelUI = {}
local IsVisible, DUI, HoveredIndex = false, nil, 1
local ActiveMenu, CurrentMenu, MenuStack = {}, {}, {}
local CurrentPath = {"HOME"}
local ActiveSubTab = 0 -- 0: Player List, 1: Troll Menu
local CachedPlayerList = {}
local CachedVehicleMenu, CachedCustomizeMenu = {}, {}

-- Configuration
local BASE_URL = "https://dbd3mk.github.io/pxui-menu/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

local MenuKey = 72 -- H Key
local MenuPosX, MenuPosY = 30, 30
local IsPickingKey, IsInputting, InputTarget, CurrentInputVal = false, false, "", ""
local TempData, TempKey, TempName = {}, nil, nil
local isShiftPressed = false

local Banners = { "banner.gif", "banner.png", "MOSA.gif", "banner1.gif", "standard (1).gif", "standard (2).gif" }
local CurrentBannerIndex = 1

local Keys = {
    [8]="BACK",[13]="ENTER",[27]="ESC",[32]=" ", [189]="_", [190]=".",
    [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
    [96]="0",[97]="1",[98]="2",[99]="3",[100]="4",[101]="5",[102]="6",[103]="7",[104]="8",[105]="9",
    [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",
    [75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",
    [85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z"
}

local Gangs = {"trickster", "26yard", "quitless", "vagos", "carfix", "darkness", "syrians", "yakuza", "families", "listcool", "oldschool", "scrap", "salamanca", "217", "redreaper", "thelost", "dragons", "nomercy", "crips", "tufahi", "elmundo", "bloods", "nightmare", "11e", "ms13"}

local ItemsToGive = {
    { name = "weapon_pistol_mk2", label = "Pistol MK2", qty = false },
    { name = "weapon_pistol50", label = "Pistol .50", qty = false },
    { name = "weapon_heavypistol", label = "Heavy Pistol", qty = false },
    { name = "pistol_ammo", label = "Pistol Ammo", qty = true },
    { name = "armor", label = "Armor", qty = true },
    { name = "ziptie", label = "Ziptie", qty = false },
    { name = "lockpick", label = "Lockpick", qty = false },
    { name = "breaker", label = "Breaker", qty = false },
    { name = "key1", label = "Key 1", qty = false },
    { name = "pistol_extendedclip", label = "Pistol Ext. Clip", qty = false },
    { name = "pistol_suppressor", label = "Pistol Suppressor", qty = false },
    { name = "hourse", label = "House Items", qty = true },
    { name = "rifle_ammo", label = "Rifle Ammo", qty = true },
    { name = "gold_bar", label = "Gold Bar", qty = true },
    { name = "classified_docs", label = "Classified Docs", qty = true },
    { name = "rare_coins", label = "Rare Coins", qty = true },
    { name = "diamonds_box", label = "Diamonds Box", qty = true },
    { name = "diamond_necklace", label = "Diamond Necklace", qty = true },
    { name = "diamond_ring", label = "Diamond Ring", qty = true },
    { name = "luxurious_watch", label = "Luxurious Watch", qty = true },
    { name = "painting", label = "Painting", qty = true },
    { name = "rare_tequila", label = "Rare Tequila", qty = true },
    { name = "pink_diamond", label = "Pink Diamond", qty = true },
    { name = "hacking_device", label = "Hacking Device", qty = true },
    { name = "DRONE", label = "Drone", qty = false },
    { name = "cashroll", label = "Cash Roll", qty = true },
    { name = "medkit", label = "Medkit", qty = true },
    { name = "radio", label = "Radio", qty = false },
}

-- Core Functions
function PixelUI:Send(d) if DUI then MachoSendDuiMessage(DUI, json.encode(d)) end end
function PixelUI:Notify(t, ti, d) PixelUI:Send({ action="showNotification", type=t, title=ti, desc=d }) end
function PixelUI:UpdatePos() PixelUI:Send({ action = "updatePosition", x = MenuPosX, y = MenuPosY }) end

function PixelUI:GetTargetRes()
    local acs = {"ElectronAC", "WaveShield", "FiniAC", "ReaperV4", "Helen_Rp", "FiveGuard", "G-AC", "PhoenixAC"}
    for _, ac in ipairs(acs) do
        if GetResourceState(ac) == "started" then return ac end
    end
    return "any"
end

function PixelUI:ObfuscateCode(code)
    local wrapper = [[
        local function _N(h, ...) return Citizen.InvokeNative(h, ...) end
        local _P = function() return _N(0xD809547A) end -- PlayerPedId
        local _V = function(p, l) return _N(0x9A9112A0, p, l) end -- GetVehiclePedIsIn
    ]]
    return wrapper .. code
end

-- Injection Methods
function PixelUI:ThreadInject(code, msg)
    MachoSetLoggerState(0)
    MachoInjectThread(0, PixelUI:GetTargetRes(), 'main.lua', code)
    Citizen.Wait(100)
    MachoSetLoggerState(3)
    if msg then PixelUI:Notify("success", "INJECTED", msg) end
end

function PixelUI:StealthInject(code, msg)
    MachoSetLoggerState(0)
    MachoInjectResource2(3, PixelUI:GetTargetRes(), PixelUI:ObfuscateCode(code))
    Citizen.Wait(100)
    MachoSetLoggerState(3)
    if msg then PixelUI:Notify("success", "STEALTH", msg) end
end

function PixelUI:OpenMegaInventory()
    local shopItems = [[{ label = "Mega Store", slots = 100, items = {
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 1, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 2, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 3, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 4, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 5, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 6, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 7, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 8, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 9, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 10, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 11, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 12, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 13, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 14, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 15, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 16, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 17, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 18, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 19, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 20, type = "weapon" },
        { amount = 1500, info = {}, name = "pistol_ammo", price = 0, slot = 21, type = "item" },
        { amount = 1500, info = {}, name = "heavyarmor", price = 0, slot = 22, type = "item" },
        { amount = 1500, info = {}, name = "ziptie", price = 0, slot = 23, type = "item" },
        { amount = 1500, info = {}, name = "lockpick", price = 0, slot = 24, type = "item" },
        { amount = 1500, info = {}, name = "breaker", price = 0, slot = 25, type = "item" },
        { amount = 1500, info = {}, name = "key1", price = 0, slot = 26, type = "item" },
        { amount = 1500, info = {}, name = "pistol_extendedclip", price = 0, slot = 27, type = "item" },
        { amount = 1500, info = {}, name = "pistol_suppressor", price = 0, slot = 28, type = "item" },
        { amount = 99999999, info = {}, name = "hourse", price = 0, slot = 29, type = "item" },
        { amount = 1500, info = {}, name = "rifle_ammo", price = 0, slot = 30, type = "item" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 31, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 32, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 33, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 34, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 35, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 36, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 37, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 38, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 39, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 40, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 41, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 42, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 43, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 44, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 45, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 46, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 47, type = "weapon" },
        { amount = 1, info = {}, name = "weapon_heavypistol", price = 0, slot = 48, type = "weapon" },
        { amount = 9999, info = {}, name = "'gold_bar", price = 0, slot = 49, type = "weapon" },
        { amount = 9999, info = {}, name = "classified_docs", price = 0, slot = 50, type = "weapon" },
        { amount = 9999, info = {}, name = "rare_coins", price = 0, slot = 51, type = "weapon" },
        { amount = 99999, info = {}, name = "diamonds_box", price = 0, slot = 52, type = "weapon" },
        { amount = 999999, info = {}, name = "diamond_necklace", price = 0, slot = 53, type = "weapon" },
        { amount = 999999, info = {}, name = "diamond_ring", price = 0, slot = 54, type = "weapon" },
        { amount = 99999, info = {}, name = "'luxurious_watch", price = 0, slot = 55, type = "weapon" },
        { amount = 99999, info = {}, name = "painting", price = 0, slot = 56, type = "weapon" },
        { amount = 99999, info = {}, name = "rare_tequila", price = 0, slot = 57, type = "weapon" },
        { amount = 9999999, info = {}, name = "pink_diamond", price = 0, slot = 58, type = "weapon" },
        { amount = 10, info = {}, name = "hacking_device", price = 0, slot = 59, type = "weapon" },
        { amount = 1500, info = {}, name = "snp_ammo", price = 0, slot = 60, type = "weapon" },
        { amount = 1500, info = {}, name = "hornysdrink", price = 0, slot = 61, type = "weapon" },
        { amount = 1500, info = {}, name = "hornysheartstopper", price = 0, slot = 62, type = "weapon" },
        { amount = 1, info = {}, name = "DRONE", price = 0, slot = 63, type = "weapon" },
        { amount = 9999999, info = {}, name = "cashroll", price = 0, slot = 64, type = "weapon" },
        { amount = 9999, info = {}, name = "medkit", price = 0, slot = 65, type = "weapon" },
        { amount = 9999, info = {}, name = "copper", price = 0, slot = 66, type = "weapon" },
        { amount = 9999, info = {}, name = "aluminum", price = 0, slot = 67, type = "weapon" },
        { amount = 9999, info = {}, name = "iron", price = 0, slot = 68, type = "weapon" },
        { amount = 9999, info = {}, name = "steel", price = 0, slot = 69, type = "weapon" },
        { amount = 9999, info = {}, name = "rubber", price = 0, slot = 70, type = "weapon" },
        { amount = 9999, info = {}, name = "glass", price = 0, slot = 71, type = "weapon" },
        { amount = 9999, info = {}, name = "metalscrap", price = 0, slot = 72, type = "weapon" },
        { amount = 9999, info = {}, name = "plastic", price = 0, slot = 73, type = "weapon" },
        { amount = 9999, info = {}, name = "radio", price = 0, slot = 74, type = "weapon" },
    }}]]
    MachoSetLoggerState(0)
    MachoInjectResource2(3, "ElectronAC", string.format([[TriggerServerEvent("inventory:server:OpenInventory","shop","M_"..math.random(1,99),%s)]], shopItems))
    Citizen.Wait(1000)
    MachoSetLoggerState(3)
    PixelUI:Notify("success", "INJECTOR", "Mega Store Injected.")
end

function PixelUI:StartInput(target, title)
    IsInputting = true; InputTarget = target; CurrentInputVal = ""
    PixelUI:Send({ action = "updateKeyboard", visible = true, title = title, value = "_" })
end

-- Advanced Protection Scan Logic
function PixelUI:ScanAC()
    local numResources = GetNumResources()
    local acFiles = { { name = "ai_module_fg-obfuscated.lua", acName = "FiveGuard" } }
    local detected, found = {}, false
    for i = 0, numResources - 1 do
        local res = GetResourceByFindIndex(i)
        local lowRes = string.lower(res)
        for _, ac in ipairs(acFiles) do if LoadResourceFile(res, ac.name) then table.insert(detected, ac.acName) found = true end end
        local friendly = nil
        if lowRes:find("reaper") then friendly = "ReaperV4" elseif lowRes:find("fini") then friendly = "FiniAC" elseif lowRes:find("electron") then friendly = "ElectronAC" elseif lowRes:find("eshield") then friendly = "WaveShield" end
        if friendly then table.insert(detected, friendly) found = true end
    end
    if found then PixelUI:Notify("info", "SECURITY", "Detected: " .. table.concat(detected, ", "))
    else PixelUI:Notify("success", "SECURITY", "No footprints found.") end
end

function PixelUI:Build()
    local selfMenu = {
        { label = "Heal Player", type = "button", desc = "Refill your health via Injection", onSelect = function() 
            PixelUI:StealthInject([[ _N(0x6B76DC34, _P(), 200) ]], "Heal Injected!")
        end },
        { label = "Refill Armor", type = "button", desc = "Refill your armor via Injection", onSelect = function() 
            PixelUI:StealthInject([[ _N(0xCEA397D1, _P(), 100) ]], "Armor Injected!")
        end },
    }

    local teleportMenu = {
        { label = "Teleport to Waypoint", type = "button", desc = "Teleport to your map marker stealthily", onSelect = function() 
            local blip = GetFirstBlipInfoId(8)
            if DoesBlipExist(blip) then
                local coords = GetBlipInfoIdCoord(blip)
                local code = string.format([[
                    local function doNative(name, ...)
                        local native = _G[name]
                        if type(native) == "function" then return native(...) end
                        return Citizen.InvokeNative(GetHashKey(name), ...)
                    end
                    local ent = (veh ~= 0) and veh or ped
                    local x, y, z = %f, %f, %f
                    _N(0x239A3354, ent, x, y, z + 2.0, false, false, false) -- SetEntityCoordsNoOffset
                    
                    if z <= 0.0 then
                        Citizen.CreateThread(function()
                            for i = 1, 1000, 10 do
                                _N(0x239A3354, ent, x, y, i + 0.0, false, false, false)
                                Citizen.Wait(0)
                                local found, groundZ = _N(0xC906A7D1, x, y, i + 0.0) -- GetGroundZFor_3dCoord
                                if found then
                                    _N(0x239A3354, ent, x, y, groundZ + 2.0, false, false, false)
                                    break
                                end
                            end
                        end)
                    end
                ]], coords.x, coords.y, coords.z)

                PixelUI:StealthInject(code, "Teleported Safely!")
            else
                PixelUI:Notify("error", "FAILED", "No Waypoint found on map!")
            end
        end },
    }

    local vehicleMenu = {
        { label = "Stealth Fix", type = "button", desc = "Fix vehicle via Stealth Injection", onSelect = function() 
            local code = [[
                local veh = _V(_P(), false)
                if veh ~= 0 then
                    _N(0x1157D77F, veh) -- SetVehicleFixed
                    _N(0x45A35035, veh, 1000.0) -- SetVehicleEngineHealth
                    _N(0x01BBF73B, veh, 1000.0) -- SetVehicleBodyHealth
                end
            ]]
            PixelUI:StealthInject(code, "Vehicle Repaired!")
        end },
        { label = "Clean Vehicle", type = "button", desc = "Clean the current vehicle", onSelect = function() 
            PixelUI:StealthInject([[ local v = _V(_P(), false); if v ~= 0 then _N(0x796BAA11, v, 0.0) end ]], "Vehicle Cleaned!") -- SetVehicleDirtLevel
        end },
        { label = "Unlock Nearest", type = "button", desc = "Unlock the nearest vehicle", onSelect = function() 
            local code = [[
                local function getNearestVeh()
                    local pos = _N(0x3FEF770D, _P()) -- GetEntityCoords
                    local handle, veh = FindFirstVehicle()
                    local success, nearest, minDist = false, 0, 10.0
                    repeat
                        local vPos = _N(0x3FEF770D, veh)
                        local dist = #(pos - vPos)
                        if dist < minDist then minDist = dist; nearest = veh end
                        success, veh = FindNextVehicle(handle)
                    until not success
                    EndFindVehicle(handle)
                    return nearest
                end
                local veh = getNearestVeh()
                if veh ~= 0 then
                    _N(0xBEEBBC4A, veh, 1) -- SetVehicleDoorsLocked
                    _N(0x25E1353D, veh, false) -- SetVehicleDoorsLockedForAllPlayers
                end
            ]]
            PixelUI:StealthInject(code, "Nearest Vehicle Unlocked!")
        end },
    }

    local customizeMenu = {
        { label = "Primary Color", type = "slider", min = 0, max = 159, value = 0, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x4F1D4440, v, %d, select(2, _N(0x4F1D4440, v))) end ]], item.value)) -- SetVehicleColours
        end },
        { label = "Secondary Color", type = "slider", min = 0, max = 159, value = 0, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then local p, s = _N(0x4F1D4440, v); _N(0x4F1D4440, v, p, %d) end ]], item.value))
        end },
        { label = "Turbo", type = "checkbox", checked = false, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]; item.checked = not item.checked
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x2A1A1511, v, 18, %s) end ]], tostring(item.checked))) -- SetVehicleModKit, ToggleVehicleMod
            PixelUI:UpdateUI()
        end },
        { label = "Max Upgrade", type = "button", desc = "Fully upgrade the vehicle performance", onSelect = function() 
            local code = [[
                local v = _V(_P(), false)
                if v ~= 0 then
                    _N(0x1F2AA078, v, 0)
                    _N(0x6AF060E0, v, 11, _N(0xE38E3390, v, 11) - 1, false) -- SetVehicleMod, GetNumVehicleMods
                    _N(0x6AF060E0, v, 12, _N(0xE38E3390, v, 12) - 1, false)
                    _N(0x6AF060E0, v, 13, _N(0xE38E3390, v, 13) - 1, false)
                    _N(0x6AF060E0, v, 15, _N(0xE38E3390, v, 15) - 1, false)
                    _N(0x2A1A1511, v, 18, true)
                end
            ]]
            PixelUI:StealthInject(code, "Vehicle Maxed Out!")
        end },
        { label = "Engine Level", type = "slider", min = -1, max = 3, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 11, %d, false) end ]], item.value))
        end },
        { label = "Brakes Level", type = "slider", min = -1, max = 2, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 12, %d, false) end ]], item.value))
        end },
        { label = "Transmission", type = "slider", min = -1, max = 2, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 13, %d, false) end ]], item.value))
        end },
        { label = "Suspension", type = "slider", min = -1, max = 3, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 15, %d, false) end ]], item.value))
        end },
        { label = "Xenon Lights", type = "checkbox", checked = false, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]; item.checked = not item.checked
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x2A1A1511, v, 22, %s) end ]], tostring(item.checked)))
            PixelUI:UpdateUI()
        end },
        { label = "Neon Lights", type = "checkbox", checked = false, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]; item.checked = not item.checked
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then for i = 0, 3 do _N(0x2AAED7E1, v, i, %s) end; _N(0x8E0A5822, v, 255, 255, 255) end ]], tostring(item.checked)))
            PixelUI:UpdateUI()
        end },
        { label = "Window Tint", type = "slider", min = 0, max = 6, value = 0, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x7729216E, v, %d) end ]], item.value))
        end },
        { label = "Plate Text", type = "button", desc = "Change vehicle plate text", onSelect = function() 
            PixelUI:StartInput("plate_text", "Enter New Plate")
        end },
        { label = "Wheel Type", type = "slider", min = 0, max = 7, value = 0, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x488F2413, v, %d) end ]], item.value))
        end },
        { label = "Wheel Index", type = "slider", min = -1, max = 50, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 23, %d, false) end ]], item.value))
        end },
        { label = "Livery", type = "slider", min = -1, max = 20, value = -1, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x6AF060E0, v, 48, %d, false); _N(0x1FD09E73, v, %d) end ]], item.value, item.value))
        end },
        { label = "Tire Smoke", type = "checkbox", checked = false, onSelect = function() 
            local item = CurrentMenu[HoveredIndex]; item.checked = not item.checked
            PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x1F2AA078, v, 0); _N(0x2A1A1511, v, 20, %s); if %s then _N(0xE95B0C7D, v, 255, 255, 255) end end ]], tostring(item.checked), tostring(item.checked)))
            PixelUI:UpdateUI()
        end },
    }

    CachedVehicleMenu = vehicleMenu
    CachedCustomizeMenu = customizeMenu

    -- NICE City Features
    local addItemSub = {}
    for _, item in ipairs(ItemsToGive) do
        table.insert(addItemSub, {
            label = item.label,
            type = "button",
            onSelect = function()
                if item.qty then
                    TempData.itemName = item.name
                    PixelUI:StartInput("item_qty", "Enter Quantity for " .. item.label)
                else
                    PixelUI:ThreadInject(string.format([[TriggerServerEvent('QBCore:Server:AddItem', '%s', 1)]], item.name), "Added 1x " .. item.label)
                end
            end
        })
    end

    local gangManagementSub = {}
    for _, g in ipairs(Gangs) do
        local gangActions = {
            { label = "Open Boss Stash", type = "button", desc = "Open stash for " .. g, onSelect = function() 
                PixelUI:ThreadInject(string.format([[TriggerServerEvent('inventory:server:OpenInventory', "stash", "boss_%s", {["maxweight"]=4000000, ["slots"]=100})]], g), "Opened Boss Stash: "..g) 
            end },
            { label = "Add Gang XP", type = "button", desc = "Add XP to " .. g, onSelect = function() 
                TempData.g = g; PixelUI:StartInput("xp_val", "Enter XP for "..g) 
            end },
            { label = "Toggle Gang Door", type = "button", desc = "Open/Close door for " .. g, onSelect = function() 
                PixelUI:ThreadInject(string.format([[TriggerServerEvent('PRO-weed:server:toggleDoor', "%s", true, true)]], g), "Toggled Door: "..g)
            end },
            { label = "Set Gang Password", type = "button", desc = "Set password for " .. g, onSelect = function() 
                PixelUI:ThreadInject(string.format([[TriggerServerEvent('PRO-weed:server:GangPassword', "%s")]], g), "Pass set: "..g) 
            end }
        }
        table.insert(gangManagementSub, { label = g:upper(), type = "subMenu", desc = "Manage " .. g, subMenu = gangActions })
    end

    local niceCitySub = {
        { label = "Add Item", type = "subMenu", desc = "Give items to yourself", subMenu = addItemSub },
        { label = "Gang Management", type = "subMenu", desc = "Manage all gang features", subMenu = gangManagementSub },
        { label = "Open Inventory", type = "button", desc = "Open Mega Store Inventory", onSelect = function() PixelUI:OpenMegaInventory() end },
        { label = "Open Other Inventory", type = "button", desc = "Open inventory of another player", onSelect = function() PixelUI:StartInput("other_inv", "Enter ID") end },
        { label = "Set Stats", type = "button", desc = "Refill Thirst and Hunger", onSelect = function() PixelUI:ThreadInject([[TriggerServerEvent('QBCore:Server:SetMetaData',"thirst",100) TriggerServerEvent('QBCore:Server:SetMetaData',"hunger",100)]], "Stats Refilled") end },
        { label = "Revive Player", type = "button", desc = "Revive a player by ID", onSelect = function() PixelUI:StartInput("revive_id", "Enter ID") end },
        { label = "Clothing Menu", type = "button", desc = "Open QB Clothing menu", onSelect = function() PixelUI:ThreadInject([[TriggerEvent('qb-clothing:client:openOutfitMenu')]]) end },
    }

    local settingsMenu = {
        { label = "Menu X Position", type = "slider", min = 0, max = 1920, value = MenuPosX, onSelect = function() end },
        { label = "Menu Y Position", type = "slider", min = 0, max = 1080, value = MenuPosY, onSelect = function() end },
        { label = "Change Banner", type = "list", items = { "Default GIF", "Default PNG", "MOSA GIF", "Banner 1", "Standard 1", "Standard 2" }, value = CurrentBannerIndex, onSelect = function() 
            PixelUI:Send({ action = "updateBanner", url = Banners[CurrentBannerIndex] })
            PixelUI:Notify("success", "SETTINGS", "Banner Updated!")
        end },
        { label = "Change Toggle Key", type = "button", desc = "Change the key used to open the menu", onSelect = function() 
            IsPickingKey = true
            PixelUI:Send({action="updateKeyboard", visible=true, title="Press New Key", value="???"})
        end },
        { label = "Run Protection Scan", type = "button", desc = "Scan for server-side anti-cheat systems", onSelect = function() 
            PixelUI:ScanAC()
        end },
    }

    ActiveMenu = {
        { label = "SELF", type = "subMenu", desc = "Personal character options", subMenu = selfMenu },
        { label = "SERVER", type = "subMenu", desc = "Server-wide features and tools", subMenu = {
            { label = "NICE City", type = "subMenu", desc = "Features for NICE City server", subMenu = niceCitySub }
        }},
        { label = "PLAYER", type = "subMenu", desc = "Online players list and actions", subMenu = {}, onSelect = function()
            local players = {}
            for _, player in ipairs(GetActivePlayers()) do
                local sid = GetPlayerServerId(player)
                local name = GetPlayerName(player)
                
                local playerItem = { 
                    label = string.format("%s [%d]", name, sid), 
                    type = "checkbox", 
                    checked = false,
                    desc = "Select player for actions",
                    onSelect = function()
                        local currentItem = CurrentMenu[HoveredIndex]
                        if currentItem then
                            currentItem.checked = not currentItem.checked
                            PixelUI:UpdateUI()
                        end
                    end
                }

                playerItem.trollMenu = {
                    { label = "Open Inventory", type = "button", desc = "Stealthily open this player's inventory", onSelect = function()
                        if not playerItem.checked then
                            PixelUI:Notify("error", "DENIED", "You must select (check) the player first!")
                            return
                        end
                        MachoSetLoggerState(0)
                        PixelUI:StealthInject(string.format([[ _N(0x8E0A5822, 'otherplayer', %d) ]], sid)) -- Triggering via Native if possible or just stealth event
                        Citizen.Wait(1000)
                        MachoSetLoggerState(3)
                        PixelUI:Notify("success", "TROLL", "Opening inventory for: " .. name)
                    end },
                    { label = "Revive Player", type = "button", desc = "Revive this player via injection", onSelect = function()
                        if not playerItem.checked then
                            PixelUI:Notify("error", "DENIED", "You must select (check) the player first!")
                            return
                        end
                        PixelUI:ThreadInject(string.format([[TriggerServerEvent('deep:revivePlayer', %d)]], sid), "Revived: " .. name)
                    end }
                }

                table.insert(players, playerItem)
            end
            
            CachedPlayerList = players
            ActiveSubTab = 0
            
            -- Update the PLAYER subMenu dynamically
            for _, item in ipairs(ActiveMenu) do
                if item.label == "PLAYER" then
                    item.subMenu = players
                    break
                end
            end
        end },
        { label = "VEHICLE", type = "subMenu", desc = "Vehicle related features", subMenu = vehicleMenu },
        { label = "TELEPORT", type = "subMenu", desc = "Teleportation features", subMenu = teleportMenu },
        { label = "SETTINGS", type = "subMenu", desc = "Configure menu appearance and keys", subMenu = settingsMenu }
    }
end

function PixelUI:UpdateUI()
    local subTabs = {}
    if CurrentPath[#CurrentPath] == "PLAYER" then
        subTabs = {"PLAYER", "TROLL"}
    elseif CurrentPath[#CurrentPath] == "VEHICLE" then
        subTabs = {"VEHICLE", "CUSTOMIZE"}
    end

    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            path = CurrentPath,
            items = CurrentMenu,
            selectedIndex = HoveredIndex - 1,
            subTabs = subTabs,
            activeSubTab = ActiveSubTab
        }
    })
    PixelUI:UpdatePos()
end

-- Thread for Position Adjustment
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsVisible then
            local item = CurrentMenu[HoveredIndex]
            if item then
                if IsDisabledControlPressed(0, 175) then -- Right
                    if item.type == "slider" then
                        item.value = math.min(item.max, item.value + 5)
                        if item.label:find("X") then MenuPosX = item.value
                        elseif item.label:find("Y") then MenuPosY = item.value end
                        PixelUI:UpdateUI()
                    elseif item.type == "list" then
                        item.value = item.value < #item.items and item.value + 1 or 1
                        if item.label:find("Banner") then CurrentBannerIndex = item.value end
                        PixelUI:UpdateUI()
                    end
                elseif IsDisabledControlPressed(0, 174) then -- Left
                    if item.type == "slider" then
                        item.value = math.max(item.min, item.value - 5)
                        if item.label:find("X") then MenuPosX = item.value
                        elseif item.label:find("Y") then MenuPosY = item.value end
                        PixelUI:UpdateUI()
                    elseif item.type == "list" then
                        item.value = item.value > 1 and item.value - 1 or #item.items
                        if item.label:find("Banner") then CurrentBannerIndex = item.value end
                        PixelUI:UpdateUI()
                    end
                end
            end
        end
    end
end)

-- Input Handling
MachoOnKeyDown(function(key)
    if key == 16 or key == 160 or key == 161 then isShiftPressed = true return end

    if IsInputting then
        local char = Keys[key]
        if char == "ENTER" then
            IsInputting = false; PixelUI:Send({action="updateKeyboard", visible=false})
            if InputTarget == "item_qty" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('QBCore:Server:AddItem', '%s', %d)]], TempData.itemName, tonumber(CurrentInputVal) or 1), "Added Items")
            elseif InputTarget == "other_inv" then MachoSetLoggerState(0); MachoInjectResource2(3, "ElectronAC", string.format([[TriggerServerEvent('inventory:server:OpenInventory','otherplayer',%d)]], tonumber(CurrentInputVal) or 0)); Citizen.Wait(1000); MachoSetLoggerState(3)
            elseif InputTarget == "revive_id" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('deep:revivePlayer',%d)]], tonumber(CurrentInputVal) or 0))
            elseif InputTarget == "xp_val" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('PRO-weed:server:addGangXP', "%s", %d)]], TempData.g, tonumber(CurrentInputVal) or 0))
            elseif InputTarget == "plate_text" then
                PixelUI:StealthInject(string.format([[ local v = _V(_P(), false); if v ~= 0 then _N(0x95A0BD27, v, "%s") end ]], CurrentInputVal)) -- SetVehicleNumberPlateText
            end
        elseif char == "BACK" then CurrentInputVal = CurrentInputVal:sub(1,-2); PixelUI:Send({action="updateKeyboard", visible=true, value=CurrentInputVal.."_"})
        elseif char == "ESC" then IsInputting = false; PixelUI:Send({action="updateKeyboard", visible=false})
        elseif char and #char == 1 then
            if not isShiftPressed then char = string.lower(char) end
            CurrentInputVal = CurrentInputVal .. char; PixelUI:Send({action="updateKeyboard", visible=true, value=CurrentInputVal.."_"})
        end
        return
    end

    if IsPickingKey then
        local char = Keys[key]
        if char == "ENTER" and TempKey then 
            MenuKey = TempKey
            IsPickingKey = false
            PixelUI:Send({action="updateKeyboard", visible=false})
            PixelUI:Notify("success", "SETTINGS", "New Key Bound: " .. (TempName or "Unknown"))
        elseif char == "BACK" then 
            IsPickingKey = false
            PixelUI:Send({action="updateKeyboard", visible=false})
        else 
            TempKey = key
            TempName = char or "Key "..key
            PixelUI:Send({action="updateKeyboard", visible=true, value=TempName})
        end
        return
    end

    if key == MenuKey then
        IsVisible = not IsVisible
        PixelUI:Send({ action = "showUI", visible = IsVisible, elements = CurrentMenu, index = HoveredIndex - 1, path = CurrentPath })
        SetNuiFocus(IsVisible, false)
        SetNuiFocusKeepInput(IsVisible)
        if IsVisible then PixelUI:UpdateUI() end
    elseif IsVisible then
        if key == 38 then -- UP
            HoveredIndex = HoveredIndex > 1 and HoveredIndex - 1 or #CurrentMenu
            PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 40 then -- DOWN
            HoveredIndex = HoveredIndex < #CurrentMenu and HoveredIndex + 1 or 1
            PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 69 then -- E (Switch Tab)
            if CurrentPath[#CurrentPath] == "PLAYER" and ActiveSubTab == 0 then
                local player = CurrentMenu[HoveredIndex]
                if player and player.trollMenu then
                    ActiveSubTab = 1
                    CurrentMenu = player.trollMenu
                    HoveredIndex = 1
                    PixelUI:UpdateUI()
                end
            elseif CurrentPath[#CurrentPath] == "VEHICLE" and ActiveSubTab == 0 then
                ActiveSubTab = 1
                CurrentMenu = CachedCustomizeMenu
                HoveredIndex = 1
                PixelUI:UpdateUI()
            end
        elseif key == 81 then -- Q (Switch Tab)
            if CurrentPath[#CurrentPath] == "PLAYER" and ActiveSubTab == 1 then
                ActiveSubTab = 0
                CurrentMenu = CachedPlayerList
                HoveredIndex = 1
                PixelUI:UpdateUI()
            elseif CurrentPath[#CurrentPath] == "VEHICLE" and ActiveSubTab == 1 then
                ActiveSubTab = 0
                CurrentMenu = CachedVehicleMenu
                HoveredIndex = 1
                PixelUI:UpdateUI()
            end
        elseif key == 13 then -- ENTER
            local item = CurrentMenu[HoveredIndex]
            if item and item.type == "subMenu" then
                -- Execute onSelect if it exists to populate dynamic menus (like PLAYER list)
                if item.onSelect then item.onSelect() end
                
                table.insert(MenuStack, {menu = CurrentMenu, index = HoveredIndex, path = {table.unpack(CurrentPath)}})
                table.insert(CurrentPath, item.label)
                
                -- Use the updated subMenu if it was changed in onSelect
                CurrentMenu = item.subMenu
                HoveredIndex = 1
                ActiveSubTab = 0
                PixelUI:UpdateUI()
            elseif item and item.onSelect then 
                item.onSelect() 
            end
        elseif key == 8 then -- BACKSPACE
            if #MenuStack > 0 then 
                local last = table.remove(MenuStack)
                CurrentMenu = last.menu
                HoveredIndex = last.index
                CurrentPath = last.path
                PixelUI:UpdateUI()
            else 
                IsVisible = false
                PixelUI:Send({action="showUI", visible=false})
                SetNuiFocus(false, false)
            end
        end
    end
end)

MachoOnKeyUp(function(key) if key == 16 or key == 160 or key == 161 then isShiftPressed = false end end)

-- Initialization
function PixelUI:Init() 
    DUI = MachoCreateDui(MENU_URL, 1920, 1080)
    MachoShowDui(DUI)
    PixelUI:Build()
    CurrentMenu = ActiveMenu
    Citizen.Wait(1500)
    PixelUI:Notify("success", "PIXEL TEAM", "Welcome to PixelUI Premium Edition")
    PixelUI:ScanAC()
end

PixelUI:Init()

return PixelUI
