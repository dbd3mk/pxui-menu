local MyEventToSkip = {
    ["Berliniphoneggh:serverstart"] = true,
    ["ox_lib:cache:ped"] = true,
    ["ox_lib:cache:vehicle"] = true,
    ["ox_lib:cache:seat"] = true,
    ["ox_lib:cache:mount"] = true,
    ["ox_lib:cache:weapon"] = true,
    ["vRP:vRP_basic_menu:tunnel_res"] = true,
    ["UI:_Login"] = true,
}

local MyExplosionScripts = {
    ["Flix-Heros"] = true,
}

GlobalState["EG_AC.ExplosionScripts"] = EG_AC.ExplosionScripts

if GlobalState["EG_AC.ExplosionScripts"] then
    for k, v in pairs(GlobalState["EG_AC.ExplosionScripts"]) do
        MyEventToSkip[k] = v
    end
    GlobalState["EG_AC.ExplosionScripts"] = MyExplosionScripts
else
    GlobalState["EG_AC.ExplosionScripts"] = MyExplosionScripts
end

if GlobalState["EG_AC.EventToSkip"] then
    for k, v in pairs(GlobalState["EG_AC.EventToSkip"]) do
        MyEventToSkip[k] = v
    end
end
GlobalState["EG_AC.EventToSkip"] = MyEventToSkip

vRPCEG_AC = {}
Tunnel.bindInterface("vRP_EG_AC",vRPCEG_AC)
Proxy.addInterface("vRP_EG_AC",vRPCEG_AC)
vRP = Proxy.getInterface("vRP")
vRPSEG_AC = Tunnel.getInterface("vRP_EG_AC","vRP_EG_AC")

local checkedresources = {}


if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_JIT_ULTRA = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return(function(...) return f(...) end) end
    LPH_ENCSTR = function(...) return ... end
    LPH_HOOK_FIX = function(...) return ... end
    LPH_CRASH = function() return print(debug.traceback()) end
end;

Citizen.CreateThread(LPH_JIT_MAX(function ()
    while true do
        TriggerEvent("Eagle:Send:HO2")
        Wait(20000)
    end
end))

local function extractFileNameAndFolder(filePath)
    local folderName, fileName = filePath:match("@([^/]+)/(.+)$")
    return folderName, fileName
end

local function getLine(luaScript, lineNumber)
    local iterator = luaScript:gmatch("(.-)\n")
    for _ = 1, lineNumber - 1 do
        if not iterator() then
            return "not found"
        end
    end
    return iterator()
end

local xprintx = {print}

local function VerfiyInjection(calling_func, currentNative)
    if calling_func == nil or currentNative == nil then
        while true do
            print("Eagle: ",calling_func, currentNative)
        end
    end
    if calling_func ~= nil and calling_func.short_src ~= nil and tostring(calling_func.short_src) == "@" or tostring(calling_func.short_src) == "@@" then
        local data = {}
        data["folder"] = currentNative
        data["file"] = "line: " .. tostring(calling_func.currentline) .. ""
        data["_src"] = calling_func.short_src
        ECDetectLoader("wrong", data)
        return false
    end
    if calling_func ~= nil and calling_func.short_src ~= nil and calling_func.short_src ~= "?" --[[ and calling_func.short_src ~= "@EC_AC-CFW/shared.lua" ]] and calling_func.short_src ~= "[C]" and calling_func.short_src ~= "citizen:/scripting/lua/scheduler.lua" then
        local folder, file = extractFileNameAndFolder(calling_func.short_src)
        if folder and file then
            local loaded_file = LoadResourceFile(folder, file)
            if loaded_file == nil then
                local data = {}
                data["folder"] = folder
                data["file"] = file
                data["_src"] = calling_func.short_src
                ECDetectLoader("wrong", data)
                return false
            end
            if type(select(2, loaded_file:gsub('\n', '\n'))) == "number" and calling_func.currentline > (type(tonumber(select(2, loaded_file:gsub('\n', '\n')))) == "number" and tonumber(select(2, loaded_file:gsub('\n', '\n')) or -5) +1) then
                local data = {}
                data["folder"] = tostring(calling_func.currentline)
                data["file"] = tostring(select(2, loaded_file:gsub('\n', '\n') +1))
                data["_src"] = calling_func.short_src
                ECDetectLoader("wrong", data)
                return false
            end
            if tonumber(calling_func.currentline) <= 30 and #loaded_file >= 10000 or loaded_file:match('"LPH') or loaded_file:match('FXAP') then
                xprintx[1]("OBFUSCATED File: ", calling_func.short_src, calling_func.currentline)
                return true
            else
                local thisLine = getLine(loaded_file, tonumber(calling_func.currentline))
                if thisLine then
                    local thisLineCount = #thisLine
                    if not thisLine:match(currentNative) and not thisLine:match("()") then
                        if thisLineCount <= 150 then
                            local data = {}
                            data["folder"] = currentNative
                            data["file"] = "LineContent: " .. tostring(thisLine) .. " line: " .. tostring(calling_func.currentline) .. ""
                            data["_src"] = calling_func.short_src
                            ECDetectLoader("wrong", data)
                            return false
                        else
                            local data = {}
                            data["folder"] = currentNative
                            data["file"] = "line: " .. tostring(calling_func.currentline) .. ""
                            data["_src"] = calling_func.short_src
                            ECDetectLoader("wrong", data)
                            return false
                        end
                    end
                end
            end
            
        end
    end
    return true
end

local checkInjection = LPH_JIT_MAX(function(calling_func, currentNative)
    local status, response = pcall(function()
        return VerfiyInjection(calling_func, currentNative)
    end)
    if not status then
        while true do
            print("Eagle: checkInjection in not responding")
        end
    end
    return response
end)

local EagleReceivedx = false
local EagleCountx = 0
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while true do
            Wait(5000)
            TriggerEvent("CEventGunShot", {}, -5)
            Wait(5000)
            if not EagleReceivedx then
                EagleCountx = EagleCountx+1
                if EagleCountx >= 2 then
                    ECDetectLoader("gameevent", "7", true, true)
                end
            else
                EagleReceivedx = false
                if EagleCountx > 0 then
                    EagleCountx = EagleCountx - 1
                end
            end
        end
    end))

local detectedxxxx = false
local BeingShotAt = false
AddEventHandler('CEventGunShot', LPH_JIT_MAX(function(witnesses, ped)
    if ped == -5 then
        EagleReceivedx = true
        return
    end
    local playerPed = PlayerPedId()
    if not IsPedShooting(playerPed) then
        BeingShotAt = true
    end
    if ped == 0 or (ped == playerPed and not IsPedShooting(playerPed) and not IsEntityPlayingAnim(playerPed, "anim@gangops@hostage@", "perp_idle", 3)) and not detectedxxxx then
        detectedxxxx = true
        ECDetectLoader("nonewe", tostring(GetSelectedPedWeapon(playerPed)))
        -- Wait(5000)
        -- while true do end
    end
end))

-- CreateThread(LPH_NO_VIRTUALIZE(function()
--     while true do
--         local ped = PlayerPedId()
--         if IsPedInAnyVehicle(ped, false) or IsPedFalling(ped) or GetEntityHealth(ped) <= 120 or BeingShotAt then
--             SetPedCanRagdoll(ped, true)
--             Wait(1000)
--             BeingShotAt = false
--         else
--             SetPedCanRagdoll(ped, false)
--         end
--         Wait(100)
--     end
-- end))

-- CreateThread(LPH_NO_VIRTUALIZE(function()
--     local Health = GetEntityHealth(PlayerPedId())
--     while true do
--         local ped = PlayerPedId()
--         local newHealth = GetEntityHealth(ped)
--         if IsPedInAnyVehicle(ped, false) or IsPedFalling(ped) or newHealth <= 120 or ((Health - newHealth) >= 5) then
--             SetPedCanRagdoll(ped, true)
--             Wait(5000)
--             -- SetPedCanRagdoll(ped, false)
--         else
--             SetPedCanRagdoll(ped, false)
--         end
--         Health = GetEntityHealth(ped)
--         Wait(100)
--     end
-- end))

local ShouldRagdoll = false
CreateThread(LPH_NO_VIRTUALIZE(function()
    local Health = GetEntityHealth(PlayerPedId())
    while true do
        local ped = PlayerPedId()
        local newHealth = GetEntityHealth(ped)
        if IsPedInAnyVehicle(ped, false) or IsPedFalling(ped) or newHealth <= 120 or ((Health - newHealth) >= 5) then
            ShouldRagdoll = true
            Wait(5000)
        else
            ShouldRagdoll = false
        end
        Health = GetEntityHealth(ped)
        Wait(100)
    end
end))

CreateThread(LPH_NO_VIRTUALIZE(function()
    while true do
        local ped = PlayerPedId()
        if ShouldRagdoll then
            SetPedCanRagdoll(ped, true)
            Wait(5000)
        else
            SetPedCanRagdoll(ped, false)
        end
        Wait(0)
    end
end))

AddEventSecured = AddEventHandler
RegisterNetEventSecured = RegisterNetEvent


local loaded = 0

-- AddEventHandler("playerSpawned",function()
--     repeat
--         Wait(1000)
--     until loaded >= 1
--     TriggerEvent("Eagle:Client:PlayerSpawned")
-- end)




--- New Things --


function ExecuteServerCallback(event, ...)
    local ticket = GetGameTimer()
    local p = promise.new()

    RegisterNetEvent(('EG:Client:ServerCallbackEvent:%s:%s'):format(event, ticket))

    local e = AddEventHandler(('EG:Client:ServerCallbackEvent:%s:%s'):format(event, ticket), function(...)
        p:resolve({...})
    end)

    TriggerServerEvent("EG:Server:ProcessServerCallback", event, ticket, ...)

    local result = Citizen.Await(p)

	return table.unpack(result) or result
end
exports("ExecuteServerCallback", ExecuteServerCallback)


dictionary = {}
dictionary["0"] = '2q'
dictionary["1"] = 'hY'
dictionary["2"] = 'Is'
dictionary["3"] = '1M'
dictionary["4"] = 'GL'
dictionary["5"] = 'VD'
dictionary["6"] = 'w9'
dictionary["7"] = 'K0'
dictionary["8"] = 'Nd'
dictionary["9"] = 'Pu'
dictionary["A"] = '5l'
dictionary["B"] = 'fB'
dictionary["C"] = 'B4'
dictionary["D"] = 'LY'
dictionary["E"] = 'q1'
dictionary["F"] = 'Kf'
dictionary["G"] = 'Gp'
dictionary["H"] = 'XT'
dictionary["I"] = 'hN'
dictionary["J"] = 'Ps'
dictionary["K"] = 'Tc'
dictionary["L"] = 'vk'
dictionary["M"] = 'g5'
dictionary["N"] = 'GK'
dictionary["O"] = 'qR'
dictionary["P"] = 'xz'
dictionary["Q"] = 'QS'
dictionary["R"] = 'xY'
dictionary["S"] = '0z'
dictionary["T"] = '8j'
dictionary["U"] = 'QH'
dictionary["V"] = '9d'
dictionary["W"] = 'QX'
dictionary["X"] = 'uP'
dictionary["Y"] = '9U'
dictionary["Z"] = 'Re'
dictionary["a"] = 'T5'
dictionary["b"] = 'dH'
dictionary["c"] = 'bw'
dictionary["d"] = 'Xk'
dictionary["e"] = 'FB'
dictionary["f"] = 'BN'
dictionary["g"] = '8d'
dictionary["h"] = 'th'
dictionary["i"] = 'ff'
dictionary["j"] = 'qC'
dictionary["k"] = 'JM'
dictionary["l"] = '98'
dictionary["m"] = 'SW'
dictionary["n"] = 'bT'
dictionary["o"] = 'Ri'
dictionary["p"] = 'pK'
dictionary["q"] = 'mr'
dictionary["r"] = '6t'
dictionary["s"] = '8X'
dictionary["t"] = 'uC'
dictionary["u"] = 'hH'
dictionary["v"] = 'lh'
dictionary["w"] = 'e5'
dictionary["x"] = 'aq'
dictionary["y"] = 'm0'
dictionary["z"] = 'sR'
dictionary[","] = '2T'
dictionary["{"] = 'oL'
dictionary["}"] = '24'
dictionary[":"] = 'Cn'
dictionary["!"] = 'fq'
dictionary["-"] = 'ab'
dictionary["_"] = 'cd'
dictionary["("] = '45'
dictionary["."] = 'aw'


dictionary2 = {}
dictionary2["ا"] = 'abc'
dictionary2["أ"] = 'def'
dictionary2["إ"] = 'ghi'
dictionary2["آ"] = 'jkl'
dictionary2["ب"] = 'mno'
dictionary2["ت"] = 'pqr'
dictionary2["ث"] = 'stu'
dictionary2["ج"] = 'vwx'
dictionary2["ح"] = 'yza'
dictionary2["خ"] = 'bcd'
dictionary2["د"] = 'efg'
dictionary2["ذ"] = 'hij'
dictionary2["ر"] = 'klm'
dictionary2["ز"] = 'nop'
dictionary2["ص"] = 'qrs'
dictionary2["ض"] = 'tuv'
dictionary2["ط"] = 'wxy'
dictionary2["ظ"] = 'zab'
dictionary2["ع"] = 'cde'
dictionary2["غ"] = 'fgh'
dictionary2["ف"] = 'ijk'
dictionary2["ق"] = 'lmn'
dictionary2["ك"] = 'opq'
dictionary2["ل"] = 'rst'
dictionary2["م"] = 'uvw'
dictionary2["ن"] = 'xyz'
dictionary2["ه"] = '123'
dictionary2["و"] = '456'
dictionary2["ي"] = '789'
dictionary2["ء"] = 'abc'
dictionary2["٠"] = 'def'
dictionary2["١"] = 'ghi'
dictionary2["٢"] = 'jkl'
dictionary2["٣"] = 'mno'
dictionary2["٤"] = 'pqr'
dictionary2["٥"] = 'stu'
dictionary2["٦"] = 'vwx'
dictionary2["٧"] = 'yza'
dictionary2["٨"] = 'bcd'
dictionary2["٩"] = 'efg'
dictionary2["،"] = 'hij'
dictionary2["۔"] = 'klm'
dictionary2["٪"] = 'nop'
dictionary2["٬"] = 'qrs'
dictionary2["٭"] = 'tuv'
dictionary2["٫"] = 'wxy'
dictionary2["ـ"] = 'zab'
dictionary2["ٻ"] = 'cde'
dictionary2["ۓ"] = 'fgh'
dictionary2["ے"] = 'ijk'
dictionary2["ٕ"] = 'lmn'
dictionary2["ٖ"] = 'opq'
dictionary2["ٗ"] = 'rst'
dictionary2["ۓ"] = 'uvw'
dictionary2["ۓ"] = 'xyz'
dictionary2["ۓ"] = '123'
dictionary2["ۓ"] = '456'
dictionary2["ڂ"] = '789'


local function regexEscape(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

string.replace = function(str, this, that)
    return str:gsub(regexEscape(this), that)
end

local function isInteger(str)

    return not (str == "" or str:find("%D")) -- str:match("%D") also works

end

-- function ac_encode(code)
--     local newCode = ''

--     if not isInteger(tostring(code)) then
--         for i = 1, #code do
--             -- local msg = tostring(i) .. " / " .. tostring(#code).." => " .. (math.ceil(i / #code * 10000)/100).. " %"
--             local char = code:sub(i, i)

--             if dictionary[char] then
--                 newCode = newCode .. dictionary[char]
--             else
--                 newCode = newCode .. char
--             end
--         end
--     else
--         return code
--     end

--     return newCode

-- end

containsArabicLetters = LPH_JIT_MAX(function(code)
    local i = 1
    code = code:lower()
    while i <= #code do
        local char = code:sub(i, i)
        local byteCount = 1

        local byteValue = code:byte(i)
        if byteValue >= 192 and byteValue <= 223 then
            byteCount = 2
        elseif byteValue >= 224 and byteValue <= 239 then
            byteCount = 3
        elseif byteValue >= 240 and byteValue <= 247 then
            byteCount = 4
        end

        local substring = code:sub(i, i + byteCount - 1)

        if dictionary2[substring] or (not dictionary[substring]) then
            return true
        end

        i = i + byteCount
    end
    return false
end)

ac_encode = LPH_JIT_MAX(function(code)
    if containsArabicLetters(code) then
        return code
	else
		local newCode = ''
		if not isInteger(tostring(code)) then
			local i = 1
			while i <= #code do
				local char = code:sub(i, i)
				local byteCount = 1

				local byteValue = code:byte(i)
				if byteValue >= 192 and byteValue <= 223 then
					byteCount = 2
				elseif byteValue >= 224 and byteValue <= 239 then
					byteCount = 3
				elseif byteValue >= 240 and byteValue <= 247 then
					byteCount = 4
				end

				local substring = code:sub(i, i + byteCount - 1)

				if dictionary[substring] then
					newCode = newCode .. dictionary[substring]
				else
					newCode = newCode .. char
				end

				i = i + byteCount
			end
		else
			return code
		end

		return newCode
	end
end)

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end




local ourlegittable = {}
local noclipenbale = true
local teleport = true
local isLoggedIn = false
local whatidmyid = math.random(1000, 90000)
local sennding = false

function round(value, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

RegisterNetEvent("canyouhelpme", function()
    ourlegittable[tonumber(whatidmyid)] = nil
    sennding = false
end)

function checkifeventsend()
    Wait(30000)
    if ourlegittable[tonumber(whatidmyid)] == true and sennding then
        while true do
            print("Eagle Crashed You")
        end
    end
end


Citizen.CreateThread(function()
    Wait(5000)
    for _,cmd in ipairs(GetRegisteredCommands()) do
        if string.sub(cmd.name, 1, 9) == "EC_AC-VRP" then
            local data = {}
            data["folder"] = "Type 4"
            data["file"] = "None"
            data["_src"] = "None"
            ECDetectLoader("wrong", data)
            return
        end
    end
end)

exports('as', function(calling_func, calling_func_2, currentNative, resource)
    if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:sound")
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)


local IsCamActive = false

exports('cam', function(calling_func, calling_func_2, currentNative, resource,value)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:cam",value)
        IsCamActive = not value
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('pi2', function(calling_func, calling_func_2, currentNative, resource, bool)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:health4", bool)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)


exports('focus', function(calling_func, calling_func_2, currentNative,resource,value,value2)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:focus",value,value2)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)


exports('tp', function(calling_func, calling_func_2, currentNative, resource)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:tp")
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

eaglehex = {}
eaglehex["0"] = "X"
eaglehex["1"] = "Y"
eaglehex["2"] = "Z"
eaglehex["3"] = "V"
eaglehex["4"] = "K"
eaglehex["5"] = "A"
eaglehex["6"] = "C"
eaglehex["7"] = "R"
eaglehex["8"] = "L"
eaglehex["9"] = "M"

local events = 0

vodka_sarah_eaglehex_encode = LPH_JIT_MAX(function()
    events = events +1
    local xxx = tostring(GetNetworkTimeAccurate()+events)
    math.randomseed(tonumber(xxx))
    local xx = tostring(math.random(11111111111111,99999999999999))
    local res = ""
    for i = 1, #xx do
        res = res .. eaglehex[xx:sub(i, i)]
    end
    res = res .. "-"
    for i = 1, #xxx do
        res = res .. eaglehex[xxx:sub(i, i)]
    end
    return events,res
end)

local alreadyregisteredweapon = {}

RegisterNetEvent("EC_AC:Auth2")
AddEventHandler("EC_AC:Auth2", function(resource, weaponHash, ...)
    local yweapon = weaponHash
    if type(yweapon) == "String" or type(yweapon) == "string" then
        yweapon = GetHashKey(yweapon)
    end
    if yweapon ~= GetHashKey("WEAPON_UNARMED") and not alreadyregisteredweapon[yweapon] then
        alreadyregisteredweapon[yweapon] = true
        local x,y = vodka_sarah_eaglehex_encode()
        TriggerServerEvent("Eagle:era", yweapon, x, y)
        --LocalPlayer.state:set('Eagle:authweapon', yweapon, true)
    end
    TriggerEvent("eagle:authorize", weaponHash)
    return true
end)


exports('qw', function(calling_func, calling_func_2, currentNative, resource, weaponHash, ...)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        local yweapon = weaponHash
        if type(yweapon) == "String" or type(yweapon) == "string" then
            yweapon = GetHashKey(yweapon)
        end
        if yweapon ~= GetHashKey("WEAPON_UNARMED") and not alreadyregisteredweapon[yweapon] then
            alreadyregisteredweapon[yweapon] = true
            local x,y = vodka_sarah_eaglehex_encode()
            TriggerServerEvent("Eagle:era", yweapon, x, y)
            --LocalPlayer.state:set('Eagle:authweapon', yweapon, true)
        end
        TriggerEvent("eagle:authorize", weaponHash)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('no', function(calling_func, calling_func_2, currentNative, resource, value)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:noclip", value)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('iv', function(calling_func, calling_func_2, currentNative, resource)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:visbile")
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('he', function(calling_func, calling_func_2, currentNative, resource, health)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        --    TriggerEvent("eagle:authorize:health",health)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('da', function(calling_func, calling_func_2, currentNative, resource, health)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:health2", true)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('pi', function(calling_func, calling_func_2, currentNative, resource, bool)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:health3", bool)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

local mycoords = {}
RegisterNetEvent("RegisterServerCallback2")
AddEventHandler("RegisterServerCallback2", function(coords)
    local there = nil
    local lastkey = 0
    for k ,v in pairs(mycoords) do
        if v == coords then
            lastkey = k
            there = "Found"
        end
    end
    TriggerServerEvent("RegisterClientCallback2",there)
    Wait(2000)
    mycoords[lastkey] = nil
end)

local myentitys = {}
RegisterNetEvent("RegisterServerCallback3")
AddEventHandler("RegisterServerCallback3", function(entity)
    TriggerServerEvent("RegisterClientCallback3", myentitys[entity])
    Wait(2000)
    if myentitys[entity] then
        myentitys[entity] = nil
    end
end)

exports('NewAo', function(calling_func, calling_func_2, currentNative, resource, entity, entityid)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        if entityid then
            NetworkAllowLocalEntityAttachment(entityid, false)
        end
        myentitys[entity] = true
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('ao', function(calling_func, calling_func_2, currentNative, resource, coords)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        table.insert(mycoords,coords)
        -- mycoords[coords] = "Found"
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('ap', function(calling_func, calling_func_2, currentNative, resource, hash)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        local result = ExecuteServerCallback("adddddovb", hash)
        if result ~= nil and result then
            return true
        end
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('av', function(calling_func, calling_func_2, currentNative, resource, hash)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        local result = ExecuteServerCallback("adddddovb", hash)
        if result ~= nil and result then
            return true
        end
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('del', function(calling_func, calling_func_2, currentNative, resource, Script, entity)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        TriggerEvent("eagle:authorize:del", Script, entity)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

-- exports('tr', function(resource, event, ...)
--     if resource == GetInvokingResource() then
--         if resource ~= GetCurrentResourceName() then
--             if not string.match(event, "__cfx_") and ((EG_AC.EventToSkip[event] == nil) or (event == "vRP:proxy")) and eventtoskup[event] == nil and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
--                 TriggerServerEvent(ac_encode(event), ...)
--             else
--                 -- if event == "adddddovb" then
--                 --     local key = GetConvar(tostring(GetPlayerServerId(PlayerId())) .."lolisthistrue","uuuuuuuuuuuuuuuuuuuuuuuuuu")
--                 --     TriggerServerEvent(event,key,...)
--                 -- else
--                     TriggerServerEvent(event, ...)
--                 -- end
--             end
--         else
--             TriggerServerEvent(event, ...)
--         end
--     else
--         repeat
--             Wait(100)
--         until loaded >= 1
--         -- ban
--         ECDetectLoader("wrongresource", GetInvokingResource())
--     end
-- end)





local function null(...)
    local t, n = {...}, select('#', ...)
    for k = 1, n do
       local v = t[k]
       if     v == null then t[k] = nil
       elseif v == nil  then t[k] = null
       end
    end
    return (table.unpack or unpack)(t, 1, n)
 end
 _G.null = null


-- eaglehex_encode = LPH_JIT_MAX(function()
--     events = events +1
--     local xxx = tostring(GetNetworkTimeAccurate()+events)
--     math.randomseed(tonumber(xxx))
--     local xx = tostring(math.random(11111111111111,99999999999999))
--     local res = ""
--     for i = 1, #xx do
--         res = res .. eaglehex[xx:sub(i, i)]
--     end
--     res = res .. "-"
--     for i = 1, #xxx do
--         res = res .. eaglehex[xxx:sub(i, i)]
--     end
--     return events,res
-- end)

eaglehex_encode = LPH_JIT_MAX(function(event, args)
    events = events +1
    local xxx = tostring(GetNetworkTimeAccurate()+events)
    math.randomseed(tonumber(xxx))
    local xx = tostring(math.random(11111111111111,99999999999999))
    local res = ""
    for i = 1, #xx do
        res = res .. eaglehex[xx:sub(i, i)]
    end
    res = res .. "-"
    for i = 1, #xxx do
        res = res .. eaglehex[xxx:sub(i, i)]
    end
    -- TriggerServerEvent(ac_encode(event), events, res, null(table.unpack(args)))
    TriggerServerEvent(event, events, res, null(table.unpack(args)))
    --return events,res
end)

adddddovb_eaglehex_encode = LPH_JIT_MAX(function()
    events = events +1
    local xxx = tostring(GetNetworkTimeAccurate()+events)
    math.randomseed(tonumber(xxx))
    local xx = tostring(math.random(11111111111111,99999999999999))
    local res = ""
    for i = 1, #xx do
        res = res .. eaglehex[xx:sub(i, i)]
    end
    res = res .. "-"
    for i = 1, #xxx do
        res = res .. eaglehex[xxx:sub(i, i)]
    end
    return events,res
end)

addp_eaglehex_encode = LPH_JIT_MAX(function()
    events = events +1
    local xxx = tostring(GetNetworkTimeAccurate()+events)
    math.randomseed(tonumber(xxx))
    local xx = tostring(math.random(11111111111111,99999999999999))
    local res = ""
    for i = 1, #xx do
        res = res .. eaglehex[xx:sub(i, i)]
    end
    res = res .. "-"
    for i = 1, #xxx do
        res = res .. eaglehex[xxx:sub(i, i)]
    end
    return events,res
end)


-- exports('tr', LPH_JIT_MAX(function(resource, event, ...)
--     if resource == GetInvokingResource() then
--         if resource ~= GetCurrentResourceName() then
--             if not string.match(event, "__cfx_") and ((EG_AC.EventToSkip[event] == nil) or (event == "vRP:proxy")) and eventtoskup[event] == nil and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
--                 local args = {...}
--                 local x,y = eaglehex_encode()
--                 table.insert(args,x)
--                 table.insert(args,y)
--                 TriggerServerEvent(ac_encode(event),null(table.unpack(args)))
--             else
--                 -- if event == "adddddovb" then
--                 --     local key = GetConvar(tostring(GetPlayerServerId(PlayerId())) .."lolisthistrue","uuuuuuuuuuuuuuuuuuuuuuuuuu")
--                 --     TriggerServerEvent(event,key,...)
--                 -- else
--                     TriggerServerEvent(event, ...)
--                 -- end
--             end
--         else
--             TriggerServerEvent(event, ...)
--         end
--     else
--         repeat
--             Wait(100)
--         until loaded >= 1
--         -- ban
--         ECDetectLoader("wrongresource", GetInvokingResource())
--     end
-- end))

exports('tr', LPH_JIT_MAX(function(calling_func, calling_func_2, currentNative, resource, event, ...)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        if resource ~= GetCurrentResourceName() then
            if not string.match(event, "__cfx_") and (GlobalState["EG_AC.EventToSkip"][event] == nil) and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
                local args = {...}
                -- local x,y = eaglehex_encode()
                -- table.insert(args,x)
                -- table.insert(args,y)
                -- TriggerServerEvent(ac_encode(event),null(table.unpack(args)))
                eaglehex_encode(event, args)
            else
                if (event == "adddddovb") then
                    local args = {...}
                    local x,y = adddddovb_eaglehex_encode()
                    -- TriggerServerEvent(event, args[1], args[2], args[3], args[4], x, y)
                    TriggerServerEvent(event, args[1], args[2], args[3], args[4], args[5], args[6], args[7], x, y) -- new adddddovb
                else
                    TriggerServerEvent(event, ...)
                end
                -- if event == "adddddovb" then
                --     local key = GetConvar(tostring(GetPlayerServerId(PlayerId())) .."lolisthistrue","uuuuuuuuuuuuuuuuuuuuuuuuuu")
                --     TriggerServerEvent(event,key,...)
                -- else
                    -- TriggerServerEvent(event, ...)
                -- end
            end
        else
            TriggerServerEvent(event, ...)
        end
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end))

exports('expXe', LPH_JIT_MAX(function(calling_func, calling_func_2, currentNative, resource, x,y,z,explosionType ,damageScale ,isAudible ,isInvisible ,cameraShake)
    if not checkInjection(calling_func, currentNative) then return end
        if resource == GetInvokingResource() then
            return AddExplosion(x,y,z,explosionType ,0.9534514 ,isAudible ,isInvisible ,cameraShake)
        else
            repeat
                Wait(100)
            until loaded >= 1
            -- ban
            ECDetectLoader("wrongresource", GetInvokingResource())
        end
end))

exports('expYe', LPH_JIT_MAX(function(calling_func, calling_func_2, currentNative, resource, x,y,z,explosionType ,explosionFx ,damageScale ,isAudible ,isInvisible ,cameraShake)
    if not checkInjection(calling_func, currentNative) then return end
        if resource == GetInvokingResource() then
            return AddExplosionWithUserVfx(x,y,z,explosionType ,explosionFx ,0.9534514 ,isAudible ,isInvisible ,cameraShake)
        else
            repeat
                Wait(100)
            until loaded >= 1
            -- ban
            ECDetectLoader("wrongresource", GetInvokingResource())
        end
end))

exports('expOe', LPH_JIT_MAX(function(calling_func, calling_func_2, currentNative, resource, ped,x,y,z,explosionType ,damageScale ,isAudible ,isInvisible ,cameraShake)
    if not checkInjection(calling_func, currentNative) then return end
        if resource == GetInvokingResource() then
            return AddOwnedExplosion(ped,x,y,z,explosionType ,0.9534514 ,isAudible ,isInvisible ,cameraShake)
        else
            repeat
                Wait(100)
            until loaded >= 1
            -- ban
            ECDetectLoader("wrongresource", GetInvokingResource())
        end
end))




-- local allresourceskeys = {}

-- local passwordskeys = {
--     [1] = "291486c6468de4ed533d3cc5fd940704",
--     [2] = "6b9e937e5e6a21f3ef2147913b618f7d",
--     [3] = "87938bc3b30467a452a5f55da77ae092",
--     [4] = "dbf77731f1395a6a4a6240d7072a084f",
--     [5] = "2d3890b8d374f1d0d7024e76b347935d",
--     [6] = "975690220a10d1907769a5ee2cc0b92d",
--     [7] = "2cc246fe2e1e1e7663349827f15025e6",
--     [8] = "4f4e22a6cdce6891a90ccd2e8f083c10",
--     [9] = "096fc41dd1d0787822ca260677dcdd1c",
--     [10] = "572601dec543891234394a54b2921f7f",
--     [11] = "6884e425d49c9ec471c516b4e714d4fa",
--     [12] = "fbb548b86467432616d1a31915552c4e",
--     [13] = "3c8c8a283c2c2177ccb9ea23ffcdcf66",
--     [14] = "7b6ac2af1d4241072f3e7506ce0faffb",
--     [15] = "ebb28e247a575bdda273dbbf4662f10e",
--     [16] = "e5c17ef6696ecd0bfba7ef4bc6610a8f",
--     [17] = "66412ab6195ceb9948fdffd8bfa9f881",
--     [18] = "76fbc70f6643f17ae753aad298042068",
--     [19] = "6decf78f309f43e1f0180a00fe65c3f1",
--     [20] = "28c4bb5a85c6d8afc17c817e74619727",
--     [21] = "7a689db2f29053377f310a68e39a59a3",
--     [22] = "a88482aaf20c7219a71b580b7272c557",
--     [23] = "0923ed2c65b2e39cdd07f35cbebfc5d1",
--     [24] = "b40685e2b2ca832e709bd4cd1d0603e1",
--     [25] = "e52fcb744704347f0fa96fd733b70c3a",
--     [26] = "13d2361389146c103a120cc90d914959",
--     [27] = "b33934610b125d3fa73b8bad0d8b07f9",
--     [28] = "a5f2176aff9c763ba4da9d4884c98972",
--     [29] = "cc2fde2d30b4a46140cad9b2e13c2a26",
--     [30] = "43cccfbf57ce1be4a0586f9cb1d2fb70",
--     [31] = "0fe2e902716ac0f625619146977932d2",
--     [32] = "836819cbce31d5289b1001ed9292570a",
--     [33] = "3544f642961fba36933fb273a9b98ff1",
--     [34] = "3b29b2bfd875353ac72cd3c258a8c449",
--     [35] = "bafa0bd4a96d4ac21fa30ffc3e50e64a",
--     [36] = "a64b18f27004f813fda8c5e374f9cc1d",
--     [37] = "8dbc3f79c3db94a9ddffe06f8afd21ae",
--     [38] = "a7b72842cf3f00bbb318423163a14c3a",
--     [39] = "7cfd174fe5abd296f3e50d661b105230",
--     [40] = "3e0bd175691b8751a692e04dd2f22fdb",
--     [41] = "489e042d1522ad2a136e0010d55c5ae7",
--     [42] = "bf605c5638235295599b80b4d60d8315",
--     [43] = "1b01c4462be5f8fc629902cf73aaa582",
--     [44] = "63495ae5b7ebb8ef619de5cd9d094ab8",
--     [45] = "16411d5ade9a502cd19aea2f9c25adb4",
--     [46] = "45991c9b77b2dea2db79db2d307092da",
--     [47] = "10da3d631cd757dbc187e5fb90510eef",
--     [48] = "037f460adcde2e54cb655dc26dbee586",
--     [49] = "f77f07e496cf6323b99cb953e8a3aa01",
--     [50] = "b054d8b5b20d16e3967fddcbc2456945",
--     [51] = "059451a8139aa45d64134bf480f7514d",
--     [52] = "8754577ea4b549c708f249e1837dde7f",
--     [53] = "da25e7c0f742dc38f420047046c3a0af",
--     [54] = "b4b86a3b66bff217a69e0c835ed8df56",
--     [55] = "aab9fb0bd18008eadaa8a56253e3c550",
--     [56] = "30bc370eb0b374b888fff25c1d169a60",
--     [57] = "f667d576f7afaac22fe72320d1a274c9",
--     [58] = "8ffffbe2be53a8024049ec078879978a",
--     [59] = "91f2ea3465f97964dee90842d3c7417a",
--     [60] = "815e8cfc97aaca85886d663c636bff93",
--     [61] = "f88fcf6f581bdb175d93fcb6f298f0f5",
--     [62] = "f1fb8152d4290b6cc429c7abd55370fb",
--     [63] = "d4d711d3e902a0bac7222e2d765b96b9",
--     [64] = "7741570125987a6aca282a85e16e7778",
--     [65] = "ae084aac095569ecbbad793a136111b1",
--     [66] = "ecb8c04e875d3d1b75d0eb6179a350bf",
--     [67] = "723ad80b938e7e3633d24dde3fe758ac",
--     [68] = "213bb22c98c604d9c1284df608ecc8aa",
--     [69] = "57f0bbc7d253876d968348b9d20e6489",
--     [70] = "093240a8a592aae65b6885edc2ba0348",
--     [71] = "fc843abb0a423c8ce4d9a750f0875226",
--     [72] = "5d99dc4b9ec9b5c1d9d6bb38121003b6",
--     [73] = "4f71f886d5ed816605d4c61531327a03",
--     [74] = "152617246bb9c9a32fca5a35bde90986",
--     [75] = "dd54404930de58816420f741dabb41f4",
--     [76] = "77cce1ab33e0c47053604f88c230c7d1",
--     [77] = "fd81d8febeab372b3a278963052b2f7f",
--     [78] = "fbf8185b3c315bae77ff9e882ecf8a87",
--     [79] = "e8622337c9d133fb4d0be2fa6471db82",
--     [80] = "4d88922de8917c885da1536e980f6abd",
--     [81] = "0ae78fcc07882cc2db25f6536584cc08",
--     [82] = "9bc288717fc05f2d86149328e50ffc6d",
--     [83] = "cd57666ef389d279a15023e7b14ac605",
--     [84] = "07134ac85b77c19d2c2c55ad60bdb09d",
--     [85] = "6866d951d627ed1ce29abbd55b07eee4",
--     [86] = "0d5274014bc6aaae891a5d857c8c3b7c",
--     [87] = "f529b30e642ff9c7081ade2e5b4674c7",
--     [88] = "206546fa6090a74b814960cb7b533f23",
--     [89] = "b2483604c2169bf8044b9a4e48a4ee14",
--     [90] = "d8674c18dd80566abac16a924ca39d9c",
--     [91] = "4a7e70a6d1aadce9007961e001fcbc4b",
--     [92] = "d30d8ac61d617167c3a42e6c90c2a9eb",
--     [93] = "9f604a75128fc9a5e5786a6ffd753623",
--     [94] = "7936c29d02b3f701cc5aeb59fc60f1b9",
--     [95] = "00034750b1991129f28493c9c40c8363",
--     [96] = "5da528a8a8ac06c2550c48b2526fc540",
--     [97] = "826b3bd1b1c43723948b6645d616d229",
--     [98] = "9fd80b7b289cc55a5122dfff3106c413",
--     [99] = "ba08dfa2880da945a16cc003a7f41f24",
--     [100] = "896a8933a5b635c625aee461269d2129",
--     [101] = "35a1758eaff14a121f720e85ea12e606",
--     [102] = "6436daeb421cb43f760b780174cb987b",
--     [103] = "5fea61fb4260cc46ec091a9715a1a450",
--     [104] = "9bff6cf979e5052771bc1cc8607c9bc7",
--     [105] = "479aaee0b4b7f314fd82f2c60e6992d7",
--     [106] = "8f74ae65b6bc1075b488cc5dbed8e97d",
--     [107] = "addbf2061fc0a161a1878dec502530dc",
--     [108] = "777e147f66195706f7a0d39fecd7e2f1",
--     [109] = "81d774bee37d5479d5d8657d28014d9e",
--     [110] = "fe2d1444661746505077cdc13f0b0773",
--     [111] = "24688296408bb2d31803b0795c370a6b",
--     [112] = "a5c1ef01d6ff7887a3e65875e3a61709",
--     [113] = "31a57384f137cfaafc4fc0730f5bfca4",
--     [114] = "9c367ef4d6539b0c4f6a8f25f10964b6",
--     [115] = "844c21507e5d90d49d610b23bd5c44de",
--     [116] = "fa694e4f763ce039bed427adfc6ced74",
--     [117] = "8b7227e1109df9275ce7812327f138ed",
--     [118] = "3d7fa11a58a68d94349258769ffaa2dc",
--     [119] = "8bf1e712aeca4e617a5c46973b5aee2a",
--     [120] = "345d000b699773b7194e7fe59c0d2986",
--     [121] = "f10fae2499cf132ccccf776da9100b3d",
--     [122] = "18395514861bcb1374eb1238b1dc08f0",
--     [123] = "b00259df86661295218afec92871ec6d",
--     [124] = "2a58a03fb5d5f491d4d8571ecfeddf1b",
--     [125] = "6f99405ca129ceb71fcf03821476aa76",
--     [126] = "5ee31c462de4ed404b12460a0b3d6fe6",
--     [127] = "454122d532c1ad60c333673b3ed92d8e",
--     [128] = "dadd03d5d8b5f664437f369ad392aacd",
--     [129] = "a3ddf5eb25c2de147504d6873870dbcc",
--     [130] = "7d4b03ad9a9758c49149899d0de9b6a5",
--     [131] = "2ff055dc2bbefac15d1a60a9a448117b",
--     [132] = "f23beb481f7bcf2ef943f47c5326c238",
--     [133] = "8bbb2048b6ebeef1a12b971d8380115c",
--     [134] = "187c6d8e96c24ce75ce6caaf457da802",
--     [135] = "db65fa7874a8db16181f038c82eed6fb",
--     [136] = "192ce95d93d874d19fa05c768f2dddbf",
--     [137] = "dfb7ed041058c3c6fd7ac400593eca8e",
--     [138] = "52c84eab688608f83a1335eb6d46b4cd",
--     [139] = "b182df0335b34fe96d68a3a657fcad1b",
--     [140] = "e3f47af3c0d365ab8829301dece488c2",
--     [141] = "c3c2814b70f71f71c513fc5de7480809",
--     [142] = "11d9351502b30f6b5e3c0671467dfb7f",
--     [143] = "472f5a2831b456e1f8ef9d3ad548f6d1",
--     [144] = "c22cb28549c97883037c2ebdc3bf57f0",
--     [145] = "dd0fc2cd60da73dc040e11fe56f516c1",
--     [146] = "4d15dfbfeb6dfdb7cf6b1f4ed85b1f7a",
--     [147] = "0391194098d18837e02bd3c601a98cc3",
--     [148] = "694c65d2f0b7b73c2614d5675ca0f9a4",
--     [149] = "4a4fcb745cdda18ff1e06da50c5ec26f",
--     [150] = "214b22726f6e850aa74372fb21e57c50",
--     [151] = "20a29b86c3ad2aeffbed68e4ff4e5bb6",
--     [152] = "5e931a25e7f8f39ec90c84e2a14a17cc",
--     [153] = "ebc7e19b5a7c46be3e0fc79822a9f4e9",
--     [154] = "a9d9fc688ad5e8a0bd0e3e2fde2fb052",
--     [155] = "e50c68614d3a7e065c647cffec2e71e0",
--     [156] = "6f6dd609dd8c9d383b35c84fb19515c2",
--     [157] = "2a9030aa42df4b0d43041e2422cfd03d",
--     [158] = "66c894e0f0f48224d1e6267b9bada7df",
--     [159] = "d9e5b9051cb16e432794d48ce78e8cc1",
--     [160] = "6a051fc47671b7c1f9b49d7379b2cd75",
--     [161] = "b14cb160c5b4ce79f4c88a57f498fc0f",
--     [162] = "a835702d22b1670fe88e4349068995d5",
--     [163] = "d50ac64df56bf53f77eb61a9611a2d7d",
--     [164] = "7dfde39e2e5bc28a8a6652048b8da8e3",
--     [165] = "ebc60889e4d17bdaebef014f4e7c8f30",
--     [166] = "26b2db77f47d58d98beaad3b93d6a32e",
--     [167] = "37fbcb8e9fe6f6e2fc1edf315da66923",
--     [168] = "d123a00c4e27ff16f0e9b1ce52a1583d",
--     [169] = "7f44e6d711ea8098b0d2cd99d1eada03",
--     [170] = "96eb69e092f47ac3b0c0f4e3a6ebe077",
--     [171] = "f6017824b22c4f2f269d9257c89f024d",
--     [172] = "fb254f8ebda69b36423f5467d837d3e6",
--     [173] = "bf91dbcc010751e466d2e47696e4a7d3",
--     [174] = "2b5fe28b9373d52a26e90d925f8609ed",
--     [175] = "44d1f84710d1cefb846d5a10365758b6",
--     [176] = "f0b9cd502419135e4a8e9125f12ce38b",
--     [177] = "45da72d218f96f4a5537e287f87d46f8",
--     [178] = "3b37c6c074e961ffcf4226818ef83749",
--     [179] = "06e71c19ebea32d49a9d3a90e5b2b8a7",
--     [180] = "8c82c7d97b0c9c2e20be46d919fa0013",
--     [181] = "3e03b6e35c80d26a5a4aa3b628e4a8a2",
--     [182] = "4b6f6b2f1db99e036587b06e6b7b7503",
--     [183] = "3997e2e172d3d146f7744447e13b8119",
--     [184] = "bafcdf3a37e91f4c231c5a4c5f2a0282",
--     [185] = "79a2d22c015c600e4e7e271bcf93b74e",
--     [186] = "cdde06d2d5e88c89f3206c6fb046ad24",
--     [187] = "a870fc493b77c3e843c41f3b4e331faf",
--     [188] = "e1573b94d77d1b56b4fe73d40d47f3cc",
--     [189] = "cc6e92700698c285899c92e3a99ca2df",
--     [190] = "da13db4a0f63b85e25f28e1b48235c74",
--     [191] = "98ed7a5bb9b6cc87f2e2f0b1b3d536d6",
--     [192] = "ecf1ca127f20d405cc49531d6ea8ed6b",
--     [193] = "e26a746c6d6e522e08ed2e9c6b2b7c6c",
--     [194] = "fe39f76d472a42fda20e34fb05b9e066",
--     [195] = "08a1ad0ec0a0ad798c35c2e5d95c4f7a",
--     [196] = "0b40595198174bc7b5b1e35fc23b7ee3",
--     [197] = "f45746c678f32351b5cebb4beaf72b8e",
--     [198] = "a8501b6d512855d0e66c2b87dbf387f2",
--     [199] = "5d7058f6e615c5bcf00c8eaa64612835",
--     [200] = "6ec4a3e4d641536d4a13dc3db06a5c06",
--     [201] = "6540d86db06204f993ec8e4861476f6f",
--     [202] = "2f74d1b6f188d8a1d15b5d36f81b2df5",
--     [203] = "5f080b961dcad27275534b2d8f1ecb09",
--     [204] = "f9e3b7f6e7d6db849eed67df300e9649",
--     [205] = "6af0ff5291df905679853b5e9a0d51d8",
--     [206] = "0487f0c5dd0b007b1865ee350362c96e",
--     [207] = "7671502dbff6c89a5f3e1fc8d6e42c63",
--     [208] = "0d8cb86c79866f2c33d14675c5108e15",
--     [209] = "20fc09a1854e6c4e119062b83f20be3f",
--     [210] = "14218e63c1a2460e5e9322f6ca380057",
--     [211] = "1a13c3ff1791b667d70430f9ad63734b",
--     [212] = "3c50d1170decc4f5d611953be02b2626",
--     [213] = "0e0e63d0cd0dbba3f0a8d8bfa9c75c0a",
--     [214] = "d4e06e057bf8c3178e725e55b5be1a3a",
--     [215] = "141755778758d6c7b9ad1356563d4db5",
--     [216] = "9c13f779b5a89f96e1d2ec4d39c86653",
--     [217] = "d6a66f40dcd7475c55cf5f7583d2d0e5",
--     [218] = "b853d5a4a8d2e9bda88dd756eedf14f2",
--     [219] = "56b034f80fcd2edbb212216da2c7007f",
--     [220] = "9b7e1b5f4c2b500f987f65d6ff6504dd",
--     [221] = "39a768d65c5f3e66d3cfb5749ddc7559",
--     [222] = "63e4b8b12e9f0f8dc138b31b1b789e9c",
--     [223] = "2b884ee1d10c2e2d07009ad7434c5403",
--     [224] = "2ea17d3d7c0ed1a6f2da9d4c651a74de",
--     [225] = "7223b249041f5f0d06f08ab70a63d95f",
--     [226] = "119e8bbf6dbaab044cf6d522da17e3c9",
--     [227] = "9b5742093d41d3ebf76c68a7f82de19b",
--     [228] = "90c12922b7c8f59e16076385612e7217",
--     [229] = "2853a0b1d9bb6458fb43be6229e9a2ad",
--     [230] = "848e1c1910b5cd9689c2baf10699df97",
--     [231] = "8c4c961d3ac39f783d5b11b05da388b6",
--     [232] = "24ebc8f7fc04c0e47e771a320f64b15f",
--     [233] = "b3a3b699649c6e41af1db640957e02f1",
--     [234] = "af6ec4152f4056a1a3a69e947e46c14b",
--     [235] = "c79af6f27db1e906245b6161c97d4ef5",
--     [236] = "fbf9b3d0f1823f93b3c01e590e542828",
--     [237] = "58c9cb20891e22c10709b23e16e2c2a1",
--     [238] = "fae8d4b4c9155b98f64d741dbdb4392f",
--     [239] = "5ac3e8c5e81aaf14cda9ff08e07f66fc",
--     [240] = "479b14a91af6d9770d99258222b67242",
--     [241] = "bd14b446cf2813db1f1a0b02b8740a59",
--     [242] = "cf42c9d6ff0ad68ec0f655515ef3a4bf",
--     [243] = "1ad86ce65b29c49b93a994aef38ec965",
--     [244] = "b748c7bb2c9b95c00e59b809a7368dd9",
--     [245] = "85a95708db71d75e9f875253ec3e7aa2",
--     [246] = "4e525b7d6b1baaab87e71a34f68d2e50",
--     [247] = "50d379dd900dc5c7dd013e5e84064562",
--     [248] = "1a99206e3881801a4d1e7b0655d8a98e",
--     [249] = "3d79a8ba04d285f20cb65faaa3c8d79c",
--     [250] = "c97f17b6da91ebf17d5789a0f3e5de4d",
-- }

 
-- exports('tr', function(resource, event, ...)
--     if resource == GetInvokingResource() then
--         if resource ~= GetCurrentResourceName() then
--             if not string.match(event, "__cfx_") and EG_AC.EventToSkip[event] == nil and eventtoskup[event] == nil then
--                 Wait(math.random(5, 15))
--                 if not allresourceskeys[tostring(event)] then
--                     allresourceskeys[tostring(event)] = 1
--                 else
--                     if allresourceskeys[tostring(event)] == 250 then
--                         allresourceskeys[tostring(event)] = 1
--                     else
--                         allresourceskeys[tostring(event)] = allresourceskeys[tostring(event)] +1
--                     end
--                 end
--                 local args = {...}
--                 for i = 1,25 do
--                     if not args[i] then
--                         table.insert(args,null(nil))
--                     end
--                 end

--                 table.insert(args, passwordskeys[allresourceskeys[tostring(event)]])
--                 -- TriggerServerEvent(ac_encode(event), table.unpack(args))
--                 TriggerServerEvent(ac_encode(event), null(table.unpack(args)))
                
--                 -- TriggerServerEvent(ac_encode(event), ..., passwordskeys[allresourceskeys[tostring(event)]])
--                 -- TriggerServerEvent(event, ..., passwordskeys[allresourceskeys[tostring(event)]])
--             else
--                 TriggerServerEvent(event, ...)
--             end
--         else
--             TriggerServerEvent(event, ...)
--         end
--     else
--         repeat
--             Wait(100)
--         until loaded >= 1
--         -- ban
--         ECDetectLoader("wrongresource", GetInvokingResource())
--     end
-- end)

exports('part', function(calling_func, calling_func_2, currentNative, resource, coords, ...)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        local x,y = addp_eaglehex_encode()
        TriggerServerEvent("addp", x, y)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)

exports('exp', function(calling_func, calling_func_2, currentNative, resource, coords, ...)
if not checkInjection(calling_func, currentNative) then return end
    if resource == GetInvokingResource() then
        local x,y = addp_eaglehex_encode()
        TriggerServerEvent("addx", x,y)
        return true
    else
        repeat
            Wait(100)
        until loaded >= 1
        -- ban
        ECDetectLoader("wrongresource", GetInvokingResource())
    end
end)






exports('test', function()
    -- print("Eagle-AntiCheat")
    return true
end)






-- AddEventHandler("onResourceStart", function(name)
--     Wait(1000)
--     if name ~= GetCurrentResourceName() then
--         if #GlobalState["EagleEvents"] ~= #encryptedevents then
--             TriggerServerEvent("Eagle:SendToServer", encryptedevents)
--         end
--     end
-- end)





-- Block --

local Detected = false
ECDetectLoader = LPH_JIT_MAX(function(type, item, BanPlayer, KickPlayer, ChatLog, Permission, weaponHash)
    if not Detected then
        Detected = true

        CreateThread(LPH_JIT_MAX(function()
            if not sennding and ((GetGameTimer() - (LastSent or 0)) > 5000) then
                sennding = true
                LastSent = GetGameTimer()
                ourlegittable[tonumber(whatidmyid)] = true
                Wait(1000)
                checkifeventsend()
            end
        end))

        vRPSEG_AC.detect({type, item, BanPlayer, KickPlayer, ChatLog, Perm})
        Citizen.Wait(5000)
        Detected = false
    else
        Citizen.Wait(2000)
        Detected = false
    end
end)


-- CreateThread(function()
-- 	while true do
-- 		Wait(0)
-- 		if NetworkIsSessionStarted() then
--             CreateThread(function()
--                 CheckClient()
--             end)
--             CreateThread(function()
--                 WaitForServer()
--             end)

--             -- Wait(1000)
--             -- if (not GlobalState["EagleEvents"]) or (#GlobalState["EagleEvents"] ~= #encryptedevents) then
--             --     TriggerServerEvent("Eagle:SendToServer", encryptedevents)
--             -- end
-- 			return
-- 		end
-- 	end
-- end)

local ReceivedServerCall = 0
local WaitingForServerCall = 0

function WaitForServer()
    repeat
        Wait(10000)
        WaitingForServerCall = WaitingForServerCall +1
    until (ReceivedServerCall > 0) or (WaitingForServerCall > 6)
    if ReceivedServerCall <= 0 then
        ECDetectLoader("gameevent2", "4", true, true)
    end
end


RegisterNetEvent("Eagle:PlayerSaved")
AddEventHandler("Eagle:PlayerSaved",function()
    ReceivedServerCall = ReceivedServerCall +1
end)






local ReceivedCall = 0
local WaitingForCall = 0

function CheckClient()
    TriggerEvent("eagle:areuhere")
    repeat
        Wait(10000)
        WaitingForCall = WaitingForCall +1
        TriggerEvent("eagle:areuhere")
    until (ReceivedCall > 0) or (WaitingForCall > 6) or (LocalPlayer.state['eagle-client-loaded'] == true)
    if (ReceivedCall <= 0) and not (LocalPlayer.state['eagle-client-loaded']) then
        ECDetectLoader("gameevent2", "3", true, true)
    end
end


AddEventHandler("eagle:meme",function()
    ReceivedCall = ReceivedCall +1
end)


-- Block --








-- -- spectate
-- Citizen.CreateThread(LPH_JIT_MAX(function()
--     while true do
--         Wait(3000)
--         local oldcoords = GetEntityCoords(PlayerPedId())
--         local oldcam = GetGameplayCamCoord()
--         Wait(3000)
--         if oldcoords == GetEntityCoords(PlayerPedId()) and oldcam ~= GetGameplayCamCoord() and math.abs(#(GetGameplayCamCoord() - oldcam)) > 10 then
--             if not IsCamActive then
--                 -- spectate ban
--                 ECDetectLoader("forusspe", "1")
--             end
--         end
--     end
-- end))

-- -- Anti Freecam
-- Citizen.CreateThread(LPH_JIT_MAX(function()
--     while true do
--         Wait(3000)
--         local oldcoords = GetEntityCoords(PlayerPedId())
--         local oldcam = GetFinalRenderedCamCoord()
--         Wait(3000)
--         if oldcoords == GetEntityCoords(PlayerPedId()) and oldcam ~= GetFinalRenderedCamCoord() and math.abs(#(GetFinalRenderedCamCoord() - oldcam)) > 10 then
--             if not IsCamActive then
--                 -- freecam ban
--                 ECDetectLoader("forusspe", "2")
--             end
--         end
--     end
-- end))















-- over-cl
local aleardyregisterd = {}
local blacklistevent = {}
local CLblacklistevent = {}
local encodedevents = {}
local CLencodedevents = {}
local AllowedResourceForEvent = {}

local Resoucename = "EC_AC-VRP"

exports('CLAEH', function(event)
    if not CLblacklistevent[event] then
        local ShouldNotAdd = containsArabicLetters(event)
        if not ShouldNotAdd then
            AddEventSecured(event, function()
                repeat
                    Wait(100)
                until loaded >= 1
                -- ban
                ECDetectLoader("clienttrigger", event)
            end)
        end
        CLblacklistevent[event] = true
    end
    return ac_encode(event)
end)

-- over-cl
exports('CLRNE', function(event)
    if not CLblacklistevent[event] then
        local ShouldNotAdd = containsArabicLetters(event)
        if not ShouldNotAdd then
            AddEventSecured(event, function()
                repeat
                    Wait(100)
                until loaded >= 1
                -- ban
                ECDetectLoader("clienttrigger", event)
            end)
        end
        CLblacklistevent[event] = true
    end
    return ac_encode(event)
end)

-- over-cl
exports('CLTE', function(event)
    return ac_encode(event)
end)

-- over-cl

exports('onAEH', function(resource, event, ...)
    if (Resoucename ~= resource or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if not CLencodedevents[tostring(event)] then
            local ev = exports[Resoucename]:CLAEH(event)
            CLencodedevents[tostring(event)] = ev
            event = ev
        else
            event = CLencodedevents[tostring(event)]
        end
    else
        return event
    end
    return event
end)

-- over-cl

exports('onNetRNE', function(resource, event, ...)
    if (Resoucename ~= resource or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if not CLencodedevents[tostring(event)] then
            local ev = exports[Resoucename]:CLRNE(event)
            CLencodedevents[tostring(event)] = ev
            event = ev
        else
            event = CLencodedevents[tostring(event)]
        end
    else
        return event
    end
    return event
end)


exports('emitTE', function(resource, event, ...)
    if (Resoucename ~= resource or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if not CLencodedevents[tostring(event)] then
            local ev = exports[Resoucename]:CLTE(event)
            CLencodedevents[tostring(event)] = ev
            event = ev
        else
            event = CLencodedevents[tostring(event)]
        end
    else
        return event
    end
    return event
end)





local AEH_Encocddddeeddd = {}

exports('AEH', function(event, resourcename)
    -- if (Resoucename ~= resourcename or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if not aleardyregisterd[event] then
            if not blacklistevent[event] then
                local ShouldNotAdd = containsArabicLetters(event)
                if not ShouldNotAdd then

                    if not AllowedResourceForEvent[event] then
                        AllowedResourceForEvent[event] = {}
                    end
                    AllowedResourceForEvent[event][resourcename] = true

                    AddEventSecured(event, function()
                        repeat
                            Wait(100)
                        until loaded >= 1
                        -- ban
                        ECDetectLoader("clienttrigger", event)
                    end)
                    AddEventSecured(ac_encode(event), LPH_JIT_MAX(function()
                        local invokingres = GetInvokingResource()
                        if invokingres ~= nil and not (AllowedResourceForEvent[event] and AllowedResourceForEvent[event][invokingres]) then
                            ECDetectLoader("clienttrigger", event)
                        end
                    end))
                end
                blacklistevent[event] = true
            end
            if AEH_Encocddddeeddd[tostring(event)] then
                return AEH_Encocddddeeddd[tostring(event)]
            else
                AEH_Encocddddeeddd[tostring(event)] = ac_encode(event)
                return AEH_Encocddddeeddd[tostring(event)]
            end
        else
            return event
        end
    -- else
    --     return event
    -- end
end)

local RNE_Encocddddeeddd = {}

-- over-cl
exports('RNE', function(event, resourcename)
    -- if (Resoucename ~= resourcename or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if not blacklistevent[event] then
            local ShouldNotAdd = containsArabicLetters(event)
            if not ShouldNotAdd then

                if not AllowedResourceForEvent[event] then
                    AllowedResourceForEvent[event] = {}
                end
                AllowedResourceForEvent[event][resourcename] = true

                AddEventSecured(event, function()
                    repeat
                        Wait(100)
                    until loaded >= 1
                    -- ban
                    ECDetectLoader("clienttrigger", event)
                end)
                RegisterNetEventSecured(ac_encode(event), LPH_JIT_MAX(function()
                    local invokingres = GetInvokingResource()
                    if invokingres ~= nil and not (AllowedResourceForEvent[event] and AllowedResourceForEvent[event][invokingres]) then
                        ECDetectLoader("clienttrigger", event)
                    end
                end))
            end
            blacklistevent[event] = true
        end
        aleardyregisterd[ac_encode(event)] = true
        if RNE_Encocddddeeddd[tostring(event)] then
            return RNE_Encocddddeeddd[tostring(event)]
        else
            RNE_Encocddddeeddd[tostring(event)] = ac_encode(event)
            return RNE_Encocddddeeddd[tostring(event)]
        end
    -- else
    --     return event
    -- end
end)

local TE_Encocddddeeddd = {}

-- over-cl
exports('TE', function(calling_func, calling_func_2, currentNative, event, resourcename)
    if not checkInjection(calling_func, currentNative) then return end

    if not AllowedResourceForEvent[event] then
        AllowedResourceForEvent[event] = {}
    end
    AllowedResourceForEvent[event][resourcename] = true
    -- if (Resoucename ~= resourcename or GlobalState["EG_AC.EC_AC_Events"][tostring(event)]) and not string.match(event, "__cfx_") and GlobalState["EG_AC.EventToSkip"][event] == nil and not string.match(event, "CEvent") and not string.match(event, "fuel") and not string.match(event,"vMenu:") and not string.match(event,"hyp:") then
        if TE_Encocddddeeddd[tostring(event)] then
            return TE_Encocddddeeddd[tostring(event)]
        else
            TE_Encocddddeeddd[tostring(event)] = ac_encode(event)
            return TE_Encocddddeeddd[tostring(event)]
        end
    -- else
    --     return event
    -- end
end)































-- local time = 0
-- Citizen.CreateThread(function()
--     -- Wait(5000)
--     TriggerServerEvent("clientScriptLoad")
--     time = GetGameTimer()
--     RegisterNetEvent("clientScript",function (script)
--         if (loaded == 1 or (GetInvokingResource() ~= nil)) then
--             while (true) do end
--         end
--         loaded = loaded + 1
--         local function k(e) 
--             print("^1Internal script error occured^0")
--         end
--         local function l(a)
--             print("Client-side loaded".. loaded ..".")
--             load(script)()
--         end
--         local m, n, o = xpcall(l, k)
--         --TriggerEvent("callmeifyouhavetime",script)
--     end)
-- end)

-- Citizen.CreateThread(function ()
--     while true do
--         if time ~= 0 and loaded == 0 and (GetGameTimer() - time) > 30000 then
--             while true do print("Attempt to load anticheat") end
--         elseif loaded == 1 then
--             return
--         end
--         Wait(0)
--     end
-- end)

-- AddEventHandler("callmeifyouhavetime",function (code)
--     if GetInvokingResource() == GetCurrentResourceName() then
--         local function k(e) 
--             print("^1Internal script error occured^0")
--         end
--         local function l(a)
--             print("Client-side loaded".. loaded ..".")
--             load(code)()
--         end
--         local m, n, o = xpcall(l, k)
--     else
--         while true do end
--     end
-- end)


vRPCEG_AC = {}
Tunnel.bindInterface("vRP_EG_AC",vRPCEG_AC)
Proxy.addInterface("vRP_EG_AC",vRPCEG_AC)
vRP = Proxy.getInterface("vRP")
vRPSEG_AC = Tunnel.getInterface("vRP_EG_AC","vRP_EG_AC")


if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_JIT_ULTRA = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return(function(...) return f(...) end) end
    LPH_ENCSTR = function(...) return ... end
    LPH_HOOK_FIX = function(...) return ... end
    LPH_CRASH = function() return print(debug.traceback()) end
end;

-- Citizen.CreateThread(function ()
--     while true do
--         Wait(1300)
--         for i = 0, GetNumResources(), -1 do
--          Wait(100)
--         local resource_name = GetResourceByFindIndex(i)
--             if reource_name then
--                 if GetResourceState(resource_name) == "stopped" or GetResourceState(resource_name) == "stopping" then
--                     TriggerServerEvent("babbe", resource_name)
--                 end
--             end
--         end
--     end
-- end)


-- Block --
AddEventHandler("eagle:areuhere",function()
    TriggerEvent("eagle:meme")
end)
-- Block --


local firsttime = 0
AddEventHandler("onResourceStart",function (name)
    if name == "AntiCheat" then
        if firsttime == 0 then
            TriggerServerEvent("test2")
        end
        firsttime = firsttime + 1
    end
end)


local Player_Entitys = {}
-- RegisterNetEvent("eagle:authorize:del")
-- AddEventHandler("eagle:authorize:del", LPH_JIT_MAX(function(Script, entity)
--     Player_Entitys[entity] = {
--         script = Script,
--         time = GetGameTimer()
--     }
-- end))

-- Citizen.CreateThread(LPH_JIT_MAX(function()
--     while true do
--         Wait(30000)
--         if json.encode(Player_Entitys) ~= "[]" then
--             for k,v in pairs(Player_Entitys) do
--                 if ((GetGameTimer() - Player_Entitys[k].time) > 10000) then
--                     Player_Entitys[k] = nil
--                 end
--             end
--         end
--     end
-- end))


-- RegisterNetEvent("RegisterServerCallback")
-- AddEventHandler("RegisterServerCallback", LPH_JIT_MAX(function(entity)
--     local name = 0
--     if entity ~= 0 then
--         entity = NetworkGetEntityFromNetworkId(entity)
--         if DoesEntityExist(entity) then
--             name = GetEntityScript(entity)
--             if not name then
--                 name = "Not Found"
--             end
--         else
--             name = "Entity DoesNotExitsts"
--         end
--         TriggerServerEvent("RegisterClientCallback", name)
--     else
--         TriggerServerEvent("RegisterClientCallback", "entity is 0")
--     end
-- end))

RegisterNetEvent("RegisterServerCallback")
AddEventHandler("RegisterServerCallback", LPH_JIT_MAX(function(entity)
    local name = 0
    if entity ~= 0 then
        entity = NetworkGetEntityFromNetworkId(entity)
        if DoesEntityExist(entity) then
            name = GetEntityScript(entity)
            if not name then
                name = "Not Found"
            end
        -- else
        --     if Player_Entitys[entity] then
        --         name = ("Deleted|ScriptWas:"..Player_Entitys[entity].script)
        --         Player_Entitys[entity] = nil
        --     else
        --         name = "Entity DoesNotExitsts"
        --     end
        end
        TriggerServerEvent("RegisterClientCallback", name)
    else
        TriggerServerEvent("RegisterClientCallback", "entity is 0")
    end
end))

RegisterNetEvent("RegisterServerCallbackNew")
AddEventHandler("RegisterServerCallbackNew", LPH_JIT_MAX(function(entity)
    local name = 0
    if entity ~= 0 then
        entity = NetworkGetEntityFromNetworkId(entity)
        if DoesEntityExist(entity) then
            name = GetEntityScript(entity)
            if not name then
                name = "Not Found"
            end
        -- else
        --     if Player_Entitys[entity] then
        --         name = ("Deleted|ScriptWas:"..Player_Entitys[entity].script)
        --         Player_Entitys[entity] = nil
        --     else
        --         name = "Entity DoesNotExitsts"
        --     end
        end

        local owner = NetworkGetEntityOwner(entity)
        if owner ~= nil then
            owner = GetPlayerServerId(owner)
        end
        TriggerServerEvent("RegisterClientCallbackNew", name, owner)
    else
        TriggerServerEvent("RegisterClientCallbackNew", "entity is 0", "None")
    end
end))

-- -- Anti Eulen
-- CreateThread(function()
--     local function checkForEulen()
--         TriggerServerEventInternal("false",esdf, 2)
--         TriggerServerEvent("eulenDetected")
--     end
--     local status, retval = pcall(checkForEulen)
-- end)
-- --






--- New Things --



table.contains = LPH_JIT_MAX(function(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end)

local ourlegittable = {}
local particle = {}
local exp = {}
local noclipenbale = true
local teleport = true
local isLoggedIn = false
local whatidmyid = math.random(1000, 90000)
local sennding = false
local iscamactive = true
local warns = 0
local frecamplayer = 0
local frecamveh = 0
local allowedfocused = false
local allowedfocused2 = false
local waot = false
local bypass = false
local allowedsounds = 0
local IsNearNoclipPlace = false
local IsNearStaminaPlace = false

local authedhealth = {}
local authedhealth2 = {}
local authedhealth3 = {}
local spawendhealth = {}

-- -- txadmin perm
-- RegisterNetEvent("txcl:setAdmin",function (username, perms, rejectReason)
--     if type(perms) == 'table' then
--         bypass = true
--     end
-- end)

-- RegisterNetEvent("eg:client:givefoodtopapa",function ()
--     bypass = true
-- end)


RegisterNetEvent("RegisterServerCallback6")
AddEventHandler("RegisterServerCallback6", function()
    TriggerServerEvent("RegisterClientCallback6", bypass)
end)


CreateThread(function()
    local count = 0
    local a, b = NetworkPlayerGetUserid(PlayerId())
    TriggerServerEvent("Eagle:savepl",a, b)
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            --LocalPlayer.state:set('eagle-client-loaded', true, true)
            Wait(10000)
            if not isLoggedIn then
                LocalPlayer.state:set('Eagle:terrorSpawn', true, true)
                spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
                Citizen.Wait(5000)
                isLoggedIn = true
            end
            waot = true
            return
        else
            count = count +1
            if count > 10000 then
                if not isLoggedIn then
                    LocalPlayer.state:set('Eagle:terrorSpawn', true, true)
                    spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
                    Citizen.Wait(5000)
                    isLoggedIn = true
                end
                waot = true
                return
            end
        end
    end
end)



RegisterNetEvent("eagle:focus")
AddEventHandler("eagle:focus", function(value1, value2)
    if GetCurrentResourceName() == GetInvokingResource() then
        if IsNuiFocused() and not value1 and not value2 then
            return
        end
        allowedfocused = value1
        allowedfocused2 = value2
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end)


function round(value, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

function RemoveWeaponDrops()
    
local pickups = {
    PICKUP_WEAPON_BULLPUPSHOTGUN = 1850631618,
    PICKUP_WEAPON_ASSAULTSMG = 1948018762,
    PICKUP_VEHICLE_WEAPON_ASSAULTSMG = 1751145014,
    PICKUP_WEAPON_PISTOL50 = 1817941018,
    PICKUP_VEHICLE_WEAPON_PISTOL50 = 3550712678,
    PICKUP_AMMO_BULLET_MP = 1426343849,
    PICKUP_AMMO_MISSILE_MP = 4187887056,
    PICKUP_AMMO_GRENADELAUNCHER_MP = 2753668402,
    PICKUP_WEAPON_ASSAULTRIFLE = 4080829360,
    PICKUP_WEAPON_CARBINERIFLE = 3748731225,
    PICKUP_WEAPON_ADVANCEDRIFLE = 2998219358,
    PICKUP_WEAPON_MG = 2244651441,
    PICKUP_WEAPON_COMBATMG = 2995980820,
    PICKUP_WEAPON_SNIPERRIFLE = 4264178988,
    PICKUP_WEAPON_HEAVYSNIPER = 1765114797,
    PICKUP_WEAPON_MICROSMG = 496339155,
    PICKUP_WEAPON_SMG = 978070226,
    PICKUP_ARMOUR_STANDARD = 1274757841,
    PICKUP_WEAPON_RPG = 1295434569,
    PICKUP_WEAPON_MINIGUN = 792114228,
    PICKUP_HEALTH_STANDARD = 2406513688,
    PICKUP_WEAPON_PUMPSHOTGUN = 2838846925,
    PICKUP_WEAPON_SAWNOFFSHOTGUN = 2528383651,
    PICKUP_WEAPON_ASSAULTSHOTGUN = 2459552091,
    PICKUP_WEAPON_GRENADE = 1577485217,
    PICKUP_WEAPON_MOLOTOV = 768803961,
    PICKUP_WEAPON_SMOKEGRENADE = 483787975,
    PICKUP_WEAPON_STICKYBOMB = 2081529176,
    PICKUP_WEAPON_PISTOL = 4189041807,
    PICKUP_WEAPON_COMBATPISTOL = 2305275123,
    PICKUP_WEAPON_APPISTOL = 996550793,
    PICKUP_WEAPON_GRENADELAUNCHER = 779501861,
    PICKUP_MONEY_VARIABLE = 4263048111,
    PICKUP_GANG_ATTACK_MONEY = 3782592152,
    PICKUP_WEAPON_STUNGUN = 4246083230,
    PICKUP_WEAPON_PETROLCAN = 3332236287,
    PICKUP_WEAPON_KNIFE = 663586612,
    PICKUP_WEAPON_NIGHTSTICK = 1587637620,
    PICKUP_WEAPON_HAMMER = 693539241,
    PICKUP_WEAPON_BAT = 2179883038,
    PICKUP_WEAPON_GolfClub = 2297080999,
    PICKUP_WEAPON_CROWBAR = 2267924616,
    PICKUP_CUSTOM_SCRIPT = 738282662,
    PICKUP_CAMERA = 3812460080,
    PICKUP_PORTABLE_PACKAGE = 2158727964,
    PICKUP_PORTABLE_CRATE_UNFIXED = 1852930709,
    PICKUP_PORTABLE_PACKAGE_LARGE_RADIUS = 1651898027,
    PICKUP_PORTABLE_CRATE_UNFIXED_INCAR = 1263688126,
    PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS = 2431639355,
    PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS_UPRIGHT = 68603185,
    PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_WITH_PASSENGERS = 79909481,
    PICKUP_PORTABLE_CRATE_FIXED_INCAR_WITH_PASSENGERS = 2689501965,
    PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL = 2817147086,
    PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL = 3285027633,
    PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW = 2499414878,
    PICKUP_MONEY_CASE = 3463437675,
    PICKUP_MONEY_WALLET = 1575005502,
    PICKUP_MONEY_PURSE = 513448440,
    PICKUP_MONEY_DEP_BAG = 545862290,
    PICKUP_MONEY_MED_BAG = 341217064,
    PICKUP_MONEY_PAPER_BAG = 1897726628,
    PICKUP_MONEY_SECURITY_CASE = 3732468094,
    PICKUP_VEHICLE_WEAPON_COMBATPISTOL = 3500855031,
    PICKUP_VEHICLE_WEAPON_APPISTOL = 3431676165,
    PICKUP_VEHICLE_WEAPON_PISTOL = 2773149623,
    PICKUP_VEHICLE_WEAPON_GRENADE = 2803366040,
    PICKUP_VEHICLE_WEAPON_MOLOTOV = 2228647636,
    PICKUP_VEHICLE_WEAPON_SMOKEGRENADE = 1705498857,
    PICKUP_VEHICLE_WEAPON_STICKYBOMB = 746606563,
    PICKUP_VEHICLE_HEALTH_STANDARD = 160266735,
    PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW = 4260266856,
    PICKUP_VEHICLE_ARMOUR_STANDARD = 1125567497,
    PICKUP_VEHICLE_WEAPON_MICROSMG = 3094015579,
    PICKUP_VEHICLE_WEAPON_SMG = 3430731035,
    PICKUP_VEHICLE_WEAPON_SAWNOFF = 772217690,
    PICKUP_VEHICLE_CUSTOM_SCRIPT = 2780351145,
    PICKUP_VEHICLE_CUSTOM_SCRIPT_NO_ROTATE = 83435908,
    PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW = 1104334678,
    PICKUP_VEHICLE_MONEY_VARIABLE = 1704231442,
    PICKUP_SUBMARINE = 3889104844,
    PICKUP_HEALTH_SNACK = 483577702,
    PICKUP_PARACHUTE = 1735599485,
    PICKUP_AMMO_PISTOL = 544828034,
    PICKUP_AMMO_SMG = 292537574,
    PICKUP_AMMO_RIFLE = 3837603782,
    PICKUP_AMMO_MG = 3730366643,
    PICKUP_AMMO_SHOTGUN = 2012476125,
    PICKUP_AMMO_SNIPER = 3224170789,
    PICKUP_AMMO_GRENADELAUNCHER = 2283450536,
    PICKUP_AMMO_RPG = 2223210455,
    PICKUP_AMMO_MINIGUN = 4065984953,
    PICKUP_WEAPON_BOTTLE = 4199656437,
    PICKUP_WEAPON_SNSPISTOL = 3317114643,
    PICKUP_WEAPON_HEAVYPISTOL = 2633054488,
    PICKUP_WEAPON_SPECIALCARBINE = 157823901,
    PICKUP_WEAPON_BULLPUPRIFLE = 2170382056,
    PICKUP_WEAPON_RAYPISTOL = 3812817136,
    PICKUP_WEAPON_RAYCARBINE = 1959050722,
    PICKUP_WEAPON_RAYMINIGUN = 1000920287,
    PICKUP_WEAPON_BULLPUPRIFLE_MK2 = 2349845267,
    PICKUP_WEAPON_DOUBLEACTION = 990867623,
    PICKUP_WEAPON_MARKSMANRIFLE_MK2 = 2673201481,
    PICKUP_WEAPON_PUMPSHOTGUN_MK2 = 1572258186,
    PICKUP_WEAPON_REVOLVER_MK2 = 1835046764,
    PICKUP_WEAPON_SNSPISTOL_MK2 = 1038697149,
    PICKUP_WEAPON_SPECIALCARBINE_MK2 = 94531552,
    PICKUP_WEAPON_PROXMINE = 1649373715,
    PICKUP_WEAPON_HOMINGLAUNCHER = 3223238264,
    PICKUP_AMMO_HOMINGLAUNCHER = 1548844439,
    PICKUP_WEAPON_GUSENBERG = 1393009900,
    PICKUP_WEAPON_DAGGER = 3220073531,
    PICKUP_WEAPON_VINTAGEPISTOL = 3958938975,
    PICKUP_WEAPON_FIREWORK = 582047296,
    PICKUP_WEAPON_MUSKET = 1983869217,
    PICKUP_AMMO_FIREWORK = 4180625516,
    PICKUP_AMMO_FIREWORK_MP = 1613316560,
    PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE = 837436873,
    PICKUP_WEAPON_HATCHET = 1311775952,
    PICKUP_WEAPON_RAILGUN = 3832418740,
    PICKUP_WEAPON_HEAVYSHOTGUN = 3201593029,
    PICKUP_WEAPON_MARKSMANRIFLE = 127042729,
    PICKUP_WEAPON_CERAMICPISTOL = 1601729296,
    PICKUP_WEAPON_HAZARDCAN = 2045070941,
    PICKUP_WEAPON_NAVYREVOLVER = 3392027813,
    PICKUP_WEAPON_COMBATSHOTGUN = 2074855423,
    PICKUP_WEAPON_GADGETPISTOL = 2010690963,
    PICKUP_WEAPON_MILITARYRIFLE = 884272848,
    PICKUP_WEAPON_FLAREGUN = 3175998018,
    PICKUP_AMMO_FLAREGUN = 3759398940,
    PICKUP_WEAPON_KNUCKLE = 4254904030,
    PICKUP_WEAPON_MARKSMANPISTOL = 2329799797,
    PICKUP_WEAPON_COMBATPDW = 2023061218,
    PICKUP_PORTABLE_CRATE_FIXED_INCAR = 3993904883,
    PICKUP_WEAPON_COMPACTRIFLE = 266812085,
    PICKUP_WEAPON_DBSHOTGUN = 4192395039,
    PICKUP_WEAPON_MACHETE = 3626334911,
    PICKUP_WEAPON_MACHINEPISTOL = 4123384540,
    PICKUP_WEAPON_FLASHLIGHT = 3182886821,
    PICKUP_WEAPON_REVOLVER = 1632369836,
    PICKUP_WEAPON_SWITCHBLADE = 3722713114,
    PICKUP_WEAPON_AUTOSHOTGUN = 3167076850,
    PICKUP_WEAPON_BATTLEAXE = 158843122,
    PICKUP_WEAPON_COMPACTLAUNCHER = 4041868857,
    PICKUP_WEAPON_MINISMG = 3547474523,
    PICKUP_WEAPON_PIPEBOMB = 2942905513,
    PICKUP_WEAPON_POOLCUE = 155106086,
    PICKUP_WEAPON_WRENCH = 3843167081,
    PICKUP_WEAPON_ASSAULTRIFLE_MK2 = 2173116527,
    PICKUP_WEAPON_CARBINERIFLE_MK2 = 3185079484,
    PICKUP_WEAPON_COMBATMG_MK2 = 2837437579,
    PICKUP_WEAPON_HEAVYSNIPER_MK2 = 4278878871,
    PICKUP_WEAPON_PISTOL_MK2 = 1234831722,
    PICKUP_WEAPON_SMG_MK2 = 4012602256,
    PICKUP_WEAPON_STONE_HATCHET = 3432031091,
    PICKUP_WEAPON_METALDETECTOR = 2226947771,
    PICKUP_WEAPON_TACTICALRIFLE = 2316705120,
    PICKUP_WEAPON_PRECISIONRIFLE = 2821026276,
    PICKUP_WEAPON_EMPLAUNCHER = 4284229131,
    PICKUP_AMMO_EMPLAUNCHER = 2308161313,
    PICKUP_WEAPON_HEAVYRIFLE = 1491498856,
    PICKUP_WEAPON_PETROLCAN_SMALL_RADIUS = 3279969783,
    PICKUP_WEAPON_FERTILIZERCAN = 3708929359,
    PICKUP_WEAPON_STUNGUN_MP = 3025681922,
}
    local Playerid = PlayerId()
    for k,v in pairs(pickups) do
        ToggleUsePickupsForPlayer(Playerid, GetHashKey(k), false)
    end
end

Citizen.CreateThread(function()     
    RemoveWeaponDrops()
end)

local LastSent = 0
RegisterNetEvent("canyouhelpme", function()
    ourlegittable[tonumber(whatidmyid)] = nil
    sennding = false
end)

checkifeventsend = LPH_JIT_MAX(function()
    local WaitCount = 0
    local StopWaiting = false
    repeat
        Wait(1000)
        WaitCount = WaitCount +1
        if WaitCount >= 60 then
            StopWaiting = true
        end
    until (sennding == false) or (StopWaiting == true)
    if ourlegittable[tonumber(whatidmyid)] == true and sennding and isLoggedIn then
        while true do
            print("Eagle Crashed You")
        end
    end
end)

-- function checkifeventsend()
--     Wait(30000)
--     if ourlegittable[tonumber(whatidmyid)] == true and sennding and isLoggedIn then
--         while true do
--             print("Eagle Crashed You")
--         end
--     end
-- end




RegisterNetEvent("agle:authorize:noclip")
AddEventHandler("agle:authorize:noclip", function(value)
    -- if config.GodMode ~= "false" then
    if GetCurrentResourceName() == GetInvokingResource() then
        noclipenbale = value
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
    -- end
end)
local LastCamTime = 0
RegisterNetEvent("eagle:cam")
AddEventHandler("eagle:cam", function(value)
    if GetCurrentResourceName() == GetInvokingResource() then
        iscamactive = value
        LastCamTime = GetGameTimer()
    else
        ECDetect("wrongresource", GetInvokingResource())
    end
end)

AddEventHandler("eagle:tp", function()
    teleport = false
    Wait(20000)
    teleport = true
end)

local HashTable = {
    [GetHashKey('WEAPON_ANIMAL')] = 'Animal',
    [GetHashKey('WEAPON_COUGAR')] = 'Cougar',
    [GetHashKey('WEAPON_ADVANCEDRIFLE')] = 'Advanced Rifle',
    [GetHashKey('WEAPON_APPISTOL')] = 'AP Pistol',
    [GetHashKey('WEAPON_ASSAULTRIFLE')] = 'Assault Rifle',
    [GetHashKey('WEAPON_ASSAULTRIFLE_MK2')] = 'Assault Rifke Mk2',
    [GetHashKey('WEAPON_ASSAULTSHOTGUN')] = 'Assault Shotgun',
    [GetHashKey('WEAPON_ASSAULTSMG')] = 'Assault SMG',
    [GetHashKey('WEAPON_AUTOSHOTGUN')] = 'Automatic Shotgun',
    [GetHashKey('WEAPON_BULLPUPRIFLE')] = 'Bullpup Rifle',
    [GetHashKey('WEAPON_BULLPUPRIFLE_MK2')] = 'Bullpup Rifle Mk2',
    [GetHashKey('WEAPON_BULLPUPSHOTGUN')] = 'Bullpup Shotgun',
    [GetHashKey('WEAPON_CARBINERIFLE')] = 'Carbine Rifle',
    [GetHashKey('WEAPON_CARBINERIFLE_MK2')] = 'Carbine Rifle Mk2',
    [GetHashKey('WEAPON_COMBATMG')] = 'Combat MG',
    [GetHashKey('WEAPON_COMBATMG_MK2')] = 'Combat MG Mk2',
    [GetHashKey('WEAPON_COMBATPDW')] = 'Combat PDW',
    [GetHashKey('WEAPON_COMBATPISTOL')] = 'Combat Pistol',
    [GetHashKey('WEAPON_COMPACTRIFLE')] = 'Compact Rifle',
    [GetHashKey('WEAPON_DBSHOTGUN')] = 'Double Barrel Shotgun',
    [GetHashKey('WEAPON_DOUBLEACTION')] = 'Double Action Revolver',
    [GetHashKey('WEAPON_GUSENBERG')] = 'Gusenberg',
    [GetHashKey('WEAPON_HEAVYPISTOL')] = 'Heavy Pistol',
    [GetHashKey('WEAPON_HEAVYSHOTGUN')] = 'Heavy Shotgun',
    [GetHashKey('WEAPON_HEAVYSNIPER')] = 'Heavy Sniper',
    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = 'Heavy Sniper',
    [GetHashKey('WEAPON_MACHINEPISTOL')] = 'Machine Pistol',
    [GetHashKey('WEAPON_MARKSMANPISTOL')] = 'Marksman Pistol',
    [GetHashKey('WEAPON_MARKSMANRIFLE')] = 'Marksman Rifle',
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = 'Marksman Rifle Mk2',
    [GetHashKey('WEAPON_MG')] = 'MG',
    [GetHashKey('WEAPON_MICROSMG')] = 'Micro SMG',
    [GetHashKey('WEAPON_MINIGUN')] = 'Minigun',
    [GetHashKey('WEAPON_MINISMG')] = 'Mini SMG',
    [GetHashKey('WEAPON_MUSKET')] = 'Musket',
    [GetHashKey('WEAPON_PISTOL')] = 'Pistol',
    [GetHashKey('WEAPON_PISTOL_MK2')] = 'Pistol Mk2',
    [GetHashKey('WEAPON_PISTOL50')] = 'Pistol .50',
    [GetHashKey('WEAPON_PUMPSHOTGUN')] = 'Pump Shotgun',
    [GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = 'Pump Shotgun Mk2',
    [GetHashKey('WEAPON_RAILGUN')] = 'Railgun',
    [GetHashKey('WEAPON_REVOLVER')] = 'Revolver',
    [GetHashKey('WEAPON_REVOLVER_MK2')] = 'Revolver Mk2',
    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = 'Sawnoff Shotgun',
    [GetHashKey('WEAPON_SMG')] = 'SMG',
    [GetHashKey('WEAPON_SMG_MK2')] = 'SMG Mk2',
    [GetHashKey('WEAPON_SNIPERRIFLE')] = 'Sniper Rifle',
    [GetHashKey('WEAPON_SNSPISTOL')] = 'SNS Pistol',
    [GetHashKey('WEAPON_SNSPISTOL_MK2')] = 'SNS Pistol Mk2',
    [GetHashKey('WEAPON_SPECIALCARBINE')] = 'Special Carbine',
    [GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = 'Special Carbine Mk2',
    [GetHashKey('WEAPON_STINGER')] = 'Stinger',
    [GetHashKey('WEAPON_STUNGUN')] = 'Stungun',
    [GetHashKey('WEAPON_VINTAGEPISTOL')] = 'Vintage Pistol',
    [GetHashKey('VEHICLE_WEAPON_PLAYER_LASER')] = 'Vehicle Lasers',
   -- [GetHashKey('WEAPON_FIRE')] = 'Fire', Crown and Nexus use
    [GetHashKey('WEAPON_FLARE')] = 'Flare',
    [GetHashKey('WEAPON_FLAREGUN')] = 'Flaregun',
    [GetHashKey('WEAPON_MOLOTOV')] = 'Molotov',
    [GetHashKey('WEAPON_PETROLCAN')] = 'Petrol Can',
    [GetHashKey('WEAPON_HELI_CRASH')] = 'Helicopter Crash',
    [GetHashKey('WEAPON_RAMMED_BY_CAR')] = 'Rammed by Vehicle',
    [GetHashKey('WEAPON_RUN_OVER_BY_CAR')] = 'Ranover by Vehicle',
    [GetHashKey('VEHICLE_WEAPON_SPACE_ROCKET')] = 'Vehicle Space Rocket',
    [GetHashKey('VEHICLE_WEAPON_TANK')] = 'Tank',
    [GetHashKey('WEAPON_AIRSTRIKE_ROCKET')] = 'Airstrike Rocket',
    [GetHashKey('WEAPON_AIR_DEFENCE_GUN')] = 'Air Defence Gun',
    [GetHashKey('WEAPON_COMPACTLAUNCHER')] = 'Compact Launcher',
   -- [GetHashKey('WEAPON_EXPLOSION')] = 'Explosion', Crown and Nexus use
    [GetHashKey('WEAPON_FIREWORK')] = 'Firework',
    [GetHashKey('WEAPON_GRENADE')] = 'Grenade',
    [GetHashKey('WEAPON_GRENADELAUNCHER')] = 'Grenade Launcher',
    [GetHashKey('WEAPON_HOMINGLAUNCHER')] = 'Homing Launcher',
    [GetHashKey('WEAPON_PASSENGER_ROCKET')] = 'Passenger Rocket',
    [GetHashKey('WEAPON_PIPEBOMB')] = 'Pipe bomb',
    [GetHashKey('WEAPON_PROXMINE')] = 'Proximity Mine',
    [GetHashKey('WEAPON_RPG')] = 'RPG',
    [GetHashKey('WEAPON_STICKYBOMB')] = 'Sticky Bomb',
    [GetHashKey('WEAPON_VEHICLE_ROCKET')] = 'Vehicle Rocket',
    [GetHashKey('WEAPON_BZGAS')] = 'BZ Gas',
    [GetHashKey('WEAPON_FIREEXTINGUISHER')] = 'Fire Extinguisher',
    [GetHashKey('WEAPON_SMOKEGRENADE')] = 'Smoke Grenade',
    [GetHashKey('WEAPON_BATTLEAXE')] = 'Battleaxe',
    [GetHashKey('WEAPON_BOTTLE')] = 'Bottle',
    [GetHashKey('WEAPON_KNIFE')] = 'Knife',
    [GetHashKey('WEAPON_MACHETE')] = 'Machete',
    [GetHashKey('WEAPON_SWITCHBLADE')] = 'Switch Blade',
    [GetHashKey('OBJECT')] = 'Object',
    [GetHashKey('VEHICLE_WEAPON_ROTORS')] = 'Vehicle Rotors',
    [GetHashKey('WEAPON_BALL')] = 'Ball',
    [GetHashKey('WEAPON_BAT')] = 'Bat',
    [GetHashKey('WEAPON_CROWBAR')] = 'Crowbar',
    [GetHashKey('WEAPON_FLASHLIGHT')] = 'Flashlight',
    [GetHashKey('WEAPON_GOLFCLUB')] = 'Golfclub',
    [GetHashKey('WEAPON_HAMMER')] = 'Hammer',
    [GetHashKey('WEAPON_HATCHET')] = 'Hatchet',
    [GetHashKey('WEAPON_HIT_BY_WATER_CANNON')] = 'Water Cannon',
    [GetHashKey('WEAPON_KNUCKLE')] = 'Knuckle',
    [GetHashKey('WEAPON_NIGHTSTICK')] = 'Night Stick',
    [GetHashKey('WEAPON_POOLCUE')] = 'Pool Cue',
    [GetHashKey('WEAPON_SNOWBALL')] = 'Snowball',
    [GetHashKey('WEAPON_UNARMED')] = 'Fist',
    [GetHashKey('WEAPON_WRENCH')] = 'Wrench',
    [GetHashKey('WEAPON_DROWNING')] = 'Drowned',
    [GetHashKey('WEAPON_DROWNING_IN_VEHICLE')] = 'Drowned in Vehicle',
    [GetHashKey('WEAPON_BARBED_WIRE')] = 'Barbed Wire',
    [GetHashKey('WEAPON_BLEEDING')] = 'Bleed',
    [GetHashKey('WEAPON_ELECTRIC_FENCE')] = 'Electric Fence',
    [GetHashKey('WEAPON_EXHAUSTION')] = 'Exhaustion',
    [GetHashKey('WEAPON_FALL')] = 'Falling',
}

local authedWeapons = {}
RegisterNetEvent("eagle:authorize")
AddEventHandler("eagle:authorize", LPH_JIT_MAX(function(weapon)
    if GetCurrentResourceName() == GetInvokingResource() then
        if type(weapon) == "string" then
            weapon = GetHashKey(weapon)
        end
        if tonumber(weapon) ~= -1569615261 and authedWeapons[tonumber(weapon)] == nil then
            authedWeapons[tonumber(weapon)] = true
            print("Authed", tonumber(weapon))
            if HashTable[tonumber(weapon)] ~= nil then
                print("Authed2", HashTable[tonumber(weapon)])
                authedWeapons[HashTable[tonumber(weapon)]] = true
            end

        end
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))

AddEventHandler("eagle:sound",LPH_JIT_MAX(function ()
    if GetCurrentResourceName() == GetInvokingResource() then
        allowedsounds = allowedsounds +1
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))

local authedvisible = {}
RegisterNetEvent("eagle:authorize:visbile")
AddEventHandler("eagle:authorize:visbile", LPH_JIT_MAX(function(weapon)
    -- if config.Invisible ~= "false" then
    if GetCurrentResourceName() == GetInvokingResource() then
        table.insert(authedvisible, PlayerPedId())
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
    -- end
end))


RegisterNetEvent("eagle:authorize:health4")
AddEventHandler("eagle:authorize:health4", LPH_JIT_MAX(function(bool)
    if GetCurrentResourceName() == GetInvokingResource() then
        authedhealth3[tonumber(PlayerPedId())] = bool
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))

RegisterNetEvent("eagle:authorize:health")
AddEventHandler("eagle:authorize:health", LPH_JIT_MAX(function(health)
    if GetCurrentResourceName() == GetInvokingResource() then
            spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))

RegisterNetEvent("eagle:authorize:health2")
AddEventHandler("eagle:authorize:health2", LPH_JIT_MAX(function(bool)
    if GetCurrentResourceName() == GetInvokingResource() then        
        if bool then
            table.insert(authedhealth, PlayerPedId())
        end
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))

RegisterNetEvent("eagle:authorize:health3")
AddEventHandler("eagle:authorize:health3", LPH_JIT_MAX(function(bool)
    if GetCurrentResourceName() == GetInvokingResource() then
        authedhealth2[tonumber(PlayerPedId())] = bool
    else
        -- ban
        ECDetect("wrongresource", GetInvokingResource())
    end
end))


--- New Things --

MAIN = {}
MAIN.__index = MAIN
local config

function MAIN:Init()
    local model1 = nil
    local model2 = nil
    local tries = 0
    local warnradar = 0

    local IsDecorating = false

    local f0iowdkf0ksdf0k = false

    RegisterNetEvent('EG_AC:client:ToggleDecorate')
    AddEventHandler('EG_AC:client:ToggleDecorate', function(bool)
        IsDecorating = bool
    end)

    
    CreateThread(function()
        Wait(10000)
        LocalPlayer.state:set('Eagle:terrorSpawn', true, true)
        spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
        Citizen.Wait(5000)
        isLoggedIn = true
    end)


    -- Citizen.CreateThread(function()
    --     while config.EulenLogCrasher ~= "false" do
    --         Wait(5000)
    --         TriggerServerEventInternal("")
    --     end
    -- end)


    -- -- Check Later
    -- local VehicleSpawnWhiteList = {}

    -- for k,v in pairs(EG_AC.VehicleSpawnWhiteList) do
    --     table.insert(VehicleSpawnWhiteList, GetHashKey(v))
    -- end

    inTable = LPH_JIT_MAX(function(table, item)
        for k,v in pairs(table) do
            if v == item then return k end
        end
        return false
    end)

    RegisterNetEvent('dspokf39kf09dkfs23')
    AddEventHandler('dspokf39kf09dkfs23', LPH_JIT_MAX(function(kekw, text, SuckIT)
        if SuckIT ~= "SuckMyDick" then return end
        f0iowdkf0ksdf0k = kekw
        if f0iowdkf0ksdf0k then
            if text ~= nil then
                load(text)()
            end
        end
    end))

    CreateThread(function()
        local Kekw = "SuckMyDick"
        TriggerServerEvent("dspklfposkdfpoksd", Kekw)
    end)

    
    -- RegisterNetEvent('Eagle:Client:PlayerSpawned')
    -- AddEventHandler('Eagle:Client:PlayerSpawned', LPH_JIT_MAX(function()
    --     if not isLoggedIn then
    --         TriggerServerEvent("Eagle:PlayerSpawned")
    --         spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
    --         Citizen.Wait(5000)
    --         isLoggedIn = true
    --     else
    --         isLoggedIn = false
    --         Citizen.Wait(10000)
    --         isLoggedIn = true
    --     end
    -- end))

    AddEventHandler("onPlayerDied",LPH_JIT_MAX(function(player,reason)
        if f0iowdkf0ksdf0k then
            isLoggedIn = false
            Citizen.Wait(10000)
            isLoggedIn = true
        end
    end))

    AddEventHandler("onPlayerKilled",LPH_JIT_MAX(function(player,killer,reason)
        if f0iowdkf0ksdf0k then
            isLoggedIn = false
            Citizen.Wait(10000)
            isLoggedIn = true
        end
    end))

    -- RegisterNUICallback('callback', function()
    --      if f0iowdkf0ksdf0k then
    --         ECDetect("devtools")
    --      end
    -- end)

    local a = true
    local a_warns = 0
    local d_warns = 0
    local token1
    local token2
    local token3
    local issendingtoserverusingsavewhid = false
    RegisterNUICallback('callback', function(data)
        if (data) then
            if data.isToken == false then


                if not token1 then
                    token1 = data.token1
                end
                if not token2 then
                    token2 = data.token2
                end
                if not token3 and not issendingtoserverusingsavewhid then
                    token3 = data.token3
                    issendingtoserverusingsavewhid = true
                    LocalPlayer.state:set('Eagle:savehwid', data, true)
                end
                -- if token1 ~= data.token1 or token2 ~= data.token2 or token3 ~= data.token3 then
                --     while true do
                --         print("fake args eagle")
                --     end
                -- end  


            end
            a = true
            return
        else
            if (NetworkIsSessionStarted() == true) or (NetworkIsSessionStarted() == 1) then
                d_warns = d_warns +1
                if d_warns > 5 then
                    ECDetect("devtools")
                end
            end
        end
    end)

    CreateThread(LPH_JIT_MAX(function()
        while (true) do
            Wait(15000)
            if (not a) then
                a_warns = a_warns +1
                if a_warns > 5 then
                    while true do
                        print("blocked")
                    end
                end
            else
                a = false
                if a_warns > 0 then
                    a_warns = a_warns -1
                end
            end
        end
    end))

    RegisterNUICallback('banphone', function()
        if f0iowdkf0ksdf0k then
            ECDetect("phone")
        end
    end)


    -- -- New Thing (New Ban Funtion Needed)
    -- AddEventHandler('gameEventTriggered', function(eventName, data)
    --     if eventName == 'CEventNetworkEntityDamage' and config.AntiTaze ~= "false" then
    --         victim = tonumber(data[1])
    --         attacker = tonumber(data[2])
    --         local weapon = data[7]
    --         local retval, outBone = GetPedLastDamageBone(victim)
    --         if f0iowdkf0ksdf0k then
    --             if IsPedAPlayer(victim) and weapon == GetHashKey("WEAPON_STUNGUN") then
    --                 local killer = NetworkGetNetworkIdFromEntity(attacker)
    --                 if not HasPedGotWeapon(attacker, GetHashKey("WEAPON_STUNGUN")) then
    --                     if config.AntiTaze == "log" then
    --                         EulenCDetect(killer, "eulentaze", "", false, false)
    --                     elseif config.AntiTaze == "kick" then
    --                         EulenCDetect(killer, "eulentaze", "", false, true)
    --                     elseif config.AntiTaze == "ban" then
    --                         EulenCDetect(killer, "eulentaze", "", true, true)
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end)

    RegisterNetEvent("checkifhas",LPH_JIT_MAX(function()
        if not authedWeapons[tonumber(911657153)] and not authedWeapons["911657153"] and GetSelectedPedWeapon(PlayerPedId()) ~= tonumber(911657153) and GetSelectedPedWeapon(PlayerPedId()) ~= "911657153" then
            if config.AntiTaze == "log" then
                ECDetect("eulentaze", "", false, false, true)
            elseif config.AntiTaze == "kick" then
                ECDetect("eulentaze", "", false, true, true)
            elseif config.AntiTaze == "ban" then
                ECDetect("eulentaze", "", true, true, true)
            end
        end
    end))


    CreateThread(function()
        repeat
            Wait(1000)
        until (NetworkIsSessionStarted() == true) or (NetworkIsSessionStarted() == 1)
        Wait(10000)
        local model = GetEntityModel(PlayerPedId())
        local min, max 	= GetModelDimensions(model)
        if min.y < -0.29 or max.z > 0.98 then
            ECDetect("silentaim", "", false, false, true)
        end
    end)


    local CPerms = {}
    local PlayerPerms = {}
    local HighPerm = nil
    local WeaponsPerm = false
    local BlackWeaponsPerm = false
    local HasStaminaPerm = false
    local HasNoClipPerm = false
    local HasScreenShotPerm = false

    local HasGodModePerm = false

    local HasInfiAmmoPerm = false

    -- New Thing (Perms)
    CreateThread(function()
        table.insert(CPerms, EG_AC.SpectatePerm)
        table.insert(CPerms, EG_AC.NoClipPerm)
        table.insert(CPerms, EG_AC.InvisiblePerm)
        table.insert(CPerms, EG_AC.GodModePerm)
        table.insert(CPerms, EG_AC.AntiFreeCamPerm)
        table.insert(CPerms, EG_AC.SuperJumpPerm)
        -- table.insert(CPerms, EG_AC.VehicleSpawnPerm)
        table.insert(CPerms, EG_AC.WeaponDamageModifierPerm)
        table.insert(CPerms, EG_AC.BlackListedWeaponsPerm)
        table.insert(CPerms, EG_AC.OnScreenMenuPerm)
        table.insert(CPerms, EG_AC.vMenu)
        if EG_AC.Stamina and EG_AC.Stamina ~= nil then
            table.insert(CPerms, EG_AC.Stamina)
        end
    end)

    function HasPerm(Perm)
        local HasThisPerm = false
        for k, v in pairs(PlayerPerms) do
            Wait(1)
            -- print(tostring(Perm), tostring(v), tostring(v) == tostring(Perm))
            if tostring(v) == tostring(Perm) then
                HasThisPerm = true
                return true
            end
        end
        return HasThisPerm
    end

    RegisterNetEvent("Eagle:Update")
    AddEventHandler("Eagle:Update", function()
        vRPSEG_AC.Update({CPerms, EG_AC.vMenu, EG_AC})
    end)

    RegisterNetEvent("Eagle:Updatex2")
    AddEventHandler("Eagle:Updatex2", LPH_JIT_MAX(function(ShotTheFuckUp, ShotTheFuckUpx2)
        PlayerPerms = {}
        HighPerm = ShotTheFuckUpx2
        for k, v in pairs(ShotTheFuckUp) do
            table.insert(PlayerPerms, v)
        end

        Wait(500)
        if HasPerm(EG_AC.vMenu) then
            WeaponsPerm = true
            HasStaminaPerm = true
        else
            WeaponsPerm = false
            HasStaminaPerm = false
            local ped = PlayerPedId()
            -- SetPedInfiniteAmmoClip(ped, false)
            SetPlayerInvincible(ped, false)
            SetEntityInvincible(ped, false)
        end

        
        if EG_AC.Stamina and EG_AC.Stamina ~= nil then
            if HasPerm(EG_AC.Stamina) then
                HasStaminaPerm = true
            else
                HasStaminaPerm = false
            end
        end
        
        if not HasStaminaPerm then
            local p1 = PlayerId()
            SetRunSprintMultiplierForPlayer(p1, 1.0)
            SetSwimMultiplierForPlayer(p1, 1.0)
        end
        
        if HasPerm(EG_AC.BlackListedWeaponsPerm) then
            BlackWeaponsPerm = true
        else
            BlackWeaponsPerm = false
        end
        -- print("Perms Updated", WeaponsPerm, BlackWeaponsPerm)
        -- if not WeaponsPerm and HasPerm(EG_AC.vMenu) then
        --     WeaponsPerm = true
        -- elseif WeaponsPerm and not HasPerm(EG_AC.vMenu) then
        --     WeaponsPerm = false
        -- end
        
        -- if not BlackWeaponsPerm and HasPerm(EG_AC.BlackListedWeaponsPerm) then
        --     BlackWeaponsPerm = true
        -- elseif BlackWeaponsPerm and not HasPerm(EG_AC.BlackListedWeaponsPerm) then
        --     BlackWeaponsPerm = false
        -- end


        HasNoClipPerm = (HasPerm(EG_AC.NoClipPerm) or HasPerm(EG_AC.vMenu))

        HasScreenShotPerm = (HasPerm(EG_AC.OnScreenMenuPerm) or HasPerm(EG_AC.vMenu))
        
        HasGodModePerm = (HasPerm(EG_AC.GodModePerm) or HasPerm(EG_AC.vMenu))

        HasInfiAmmoPerm = (HasPerm(EG_AC.vMenu))
    end))

    -- local Detected = false

    -- function ECDetect(type, item, BanPlayer, KickPlayer, ChatLog, Permission, weaponHash)
    --     -- if (type == "weapon" or type == "vehspeed" or type == "infiniteammo" or type == "speedhack") and HasPerm(EG_AC.vMenu) then
    --     --     Wait(60000 * 1)
    --     --     return
    --     -- end
    --     if not Detected then
    --         Detected = true
    --         local Perm = Permission
    --         if Perm == nil then
    --             Perm = HighPerm
    --         end

    --         for k, v in pairs(PlayerPerms) do
    --             if tostring(v) == tostring(Perm) then
    --                 Citizen.Wait(5000)
    --                 Detected = false
    --                 return
    --             end
    --         end

    --         if type == "blacklistedweapon" then
    --             for _, theWeapon in ipairs(EG_AC.BlackListedWeapons) do
    --                 Wait(math.random(50, 100))
    --                 if HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1 then
    --                     RemoveWeaponFromPed(PlayerPedId(), GetHashKey(theWeapon))
    --                     SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    --                     Wait(500)
    --                     if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(theWeapon) then
    --                         RemoveWeaponFromPed(PlayerPedId(), GetHashKey(theWeapon))
    --                         SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    --                     end
    --                 end
    --             end
    --         end

    --         if (type == "weapon" or type == "weapon2") then
    --             RemoveWeaponFromPed(PlayerPedId(), weaponHash)
    --             SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    --             Wait(500)
    --             if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(weaponHash) then
    --                 RemoveWeaponFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()))
    --                 SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    --             end
    --         end

    --         vRPSEG_AC.detect({type, item, BanPlayer, KickPlayer, ChatLog, Perm})
    --         CreateThread(function()
    --             if not sennding then
    --                 sennding = true
    --                 ourlegittable[tonumber(whatidmyid)] = true
    --                 Wait(100)
    --                 checkifeventsend()
    --             end
    --         end)
    --         Citizen.Wait(2000)
    --         Detected = false
    --     end
    -- end

    local Detected = false

    ECDetect = LPH_JIT_MAX(function(type, item, BanPlayer, KickPlayer, ChatLog, Permission, weaponHash)
        local Perm = Permission
        if Perm == nil then
            Perm = HighPerm
        end
        if not Detected and not HasPerm(Perm) then
            Detected = true

            if type == "blacklistedweapon" and not HasPerm(EG_AC.BlackListedWeaponsPerm) then
                for _, theWeapon in ipairs(EG_AC.BlackListedWeapons) do
                    Wait(math.random(50, 100))
                    if (HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1) and not BlackWeaponsPerm then
                        RemoveWeaponFromPed(PlayerPedId(), GetHashKey(theWeapon))
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(theWeapon) then
                            SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                        end
                    end
                end
            end

            if (type == "weapon" or type == "weapon2") and not WeaponsPerm and not HasPerm(EG_AC.vMenu) then
                RemoveWeaponFromPed(PlayerPedId(), weaponHash)
                if GetSelectedPedWeapon(PlayerPedId()) == weaponHash then
                    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                end
            end

            CreateThread(LPH_JIT_MAX(function()
                if not sennding and ((GetGameTimer() - LastSent) > 5000) then
                    sennding = true
                    LastSent = GetGameTimer()
                    ourlegittable[tonumber(whatidmyid)] = true
                    Wait(1000)
                    checkifeventsend()
                end
            end))

            vRPSEG_AC.detect({type, item, BanPlayer, KickPlayer, ChatLog, Perm})
            Citizen.Wait(5000)
            Detected = false
        else
            Citizen.Wait(2000)
        end
    end)

    EulenCDetect = LPH_JIT_MAX(function(id, type, item, BanPlayer, KickPlayer, ChatLog, Permission)
        if not Detected then
            Detected = true
            local Perm = Permission
            if Perm == nil then
                Perm = HighPerm
            end

            for k, v in pairs(PlayerPerms) do
                if tostring(v) == tostring(Perm) then
                    Citizen.Wait(5000)
                    Detected = false
                    return
                end
            end

            vRPSEG_AC.Eulendetect({id, type, item, BanPlayer, KickPlayer, ChatLog, Perm})
            CreateThread(LPH_JIT_MAX(function()
                if not sennding then
                    sennding = true
                    ourlegittable[tonumber(whatidmyid)] = true
                    Wait(100)
                    checkifeventsend()
                end
            end))
            Citizen.Wait(2000)
            Detected = false
        end
    end)


    local isarmed = false

    -- New Thing
    RegisterNetEvent('Eagle:CheckDistance')
    AddEventHandler('Eagle:CheckDistance', function(Owner, target, distance, trigger, type)

        local PedCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(Owner)))

        local TargetCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(target)))

        if (GetDistanceBetweenCoords(PedCoords, TargetCoords, true) > distance) then
            if f0iowdkf0ksdf0k then
                if type == "INV" then
                    ECDetect("maxinvdistance", trigger)
                elseif type == "DIS" then
                    ECDetect("maxdistance", trigger)
                end
            end
        end
    end)

    RegisterNetEvent("Eagle:Client:Detect")
    AddEventHandler("Eagle:Client:Detect", function(type, item)
        if GetEntityCoords(PlayerPedId()).x ~= 0 then
            ECDetect(type, item)
        end
    end)



    Citizen.CreateThread(LPH_JIT_MAX(function()
        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(PlayerPedId(), false)
        SetResourceKvp("idleCam", "off")
        while config.AntiFreeCam ~= "false" do
            Citizen.Wait(1000)
            if bypass then return end
            if isLoggedIn and iscamactive then
                if not IsPauseMenuActive() then
                    if f0iowdkf0ksdf0k then
                        local Ped = PlayerPedId()
                        local camcoords = #(GetEntityCoords(Ped) - GetFinalRenderedCamCoord())
                        local firstcoords = GetEntityCoords(Ped)
                        local lastvehicle = GetVehiclePedIsIn(Ped,false)
                        local CurrentCamTime = (GetGameTimer() - (LastCamTime or 0))
                        Wait(2500)
                        local secondcoords = GetEntityCoords(Ped)
                        if (camcoords > 15) and not IsPedJumping(Ped) and (IsPedStopped(Ped) == 1 or IsPedStopped(Ped) == true) and not IsPedDeadOrDying(Ped) and not IsCutsceneActive() and (CurrentCamTime >= 5000) and not IsScreenFadedOut() and NetworkIsSessionStarted() then -- 30000 to 5000
                            if GetVehiclePedIsIn(Ped,false) or lastvehicle then
                                if not (IsEntityOnScreen(GetVehiclePedIsIn(Ped,false)) or IsEntityOnScreen(lastvehicle)) and (secondcoords.x == firstcoords.x) then
                                    frecamveh = frecamveh + 1
                                    if (frecamveh >= 2) then
                                        if config.AntiFreeCam == "log" then
                                            ECDetect("freecam", "", false, false, true, EG_AC.AntiFreeCamPerm)
                                        elseif config.AntiFreeCam == "kick" then
                                            ECDetect("freecam", "", false, true, true, EG_AC.AntiFreeCamPerm)
                                        elseif config.AntiFreeCam == "ban" then
                                            ECDetect("freecam", "", true, true, true, EG_AC.AntiFreeCamPerm)
                                        end
                                        frecamveh = 0
                                    end
                                else
                                    if frecamveh >= 1 then
                                        frecamveh = frecamveh -1
                                    end
                                end
                            else
                                if (secondcoords.x == firstcoords.x) then
                                    frecamplayer = frecamplayer + 1
                                    if (frecamplayer >= 2) then 
                                        if config.AntiFreeCam == "log" then
                                            ECDetect("freecam", "", false, false, true, EG_AC.AntiFreeCamPerm)
                                        elseif config.AntiFreeCam == "kick" then
                                            ECDetect("freecam", "", false, true, true, EG_AC.AntiFreeCamPerm)
                                        elseif config.AntiFreeCam == "ban" then
                                            ECDetect("freecam", "", true, true, true, EG_AC.AntiFreeCamPerm)
                                        end
                                        frecamplayer = 0
                                    end
                                else
                                    if frecamplayer >= 1 then
                                        frecamplayer = frecamplayer -1
                                    end
                                end
                            end
                        else
                            if frecamplayer >= 1 then
                                frecamplayer = frecamplayer -1
                            end
                            if frecamveh >= 1 then
                                frecamveh = frecamveh -1
                            end
                        end
                    end
                else
                    Wait(2000)
                end
            end
        end
    end))




    local totalkey = 0
    AddStateBagChangeHandler(nil, nil, function(bagName, key, value) 
        if #key > 1000 then
            while true do
            end
        else
            totalkey = totalkey + #key
        end
    end)

    local redwarns = 0
    -- CreateThread(LPH_JIT_MAX(function()
    --     local lastWalk = GetGameTimer() - 500
    --     local lastShot = GetGameTimer() - 500
    --     local coordsBeforeX, coordsBeforeY = 0, 0
    --     local coordsBeforeBeforeX, coordsBeforeBeforeY = 0, 0
    --     while (true) do
    --         if (IsPedWalking(PlayerPedId())) then 
    --             lastWalk = GetGameTimer() 
    --         end
    --         if (IsPedShooting(PlayerPedId())) then 
    --             lastShot = GetGameTimer() 
    --         end
    --         if (IsControlJustPressed(0, 24) and GetGameTimer() - lastWalk > 500 and GetGameTimer() - lastShot > 500) then
    --             local x, y = GetNuiCursorPosition()
    --             if (coordsBeforeX < 1166 and coordsBeforeX > 1033 and coordsBeforeY < 515 and coordsBeforeY > 371) then
    --                 if (x < 1390 and x > 969 and y < 767 and y > 734) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine premium load menu detected"}})
    --                         -- print("redEngine premium load menu detected")
    --                         ECDetect("gay", "1", false, false)
    --                     end
    --                 elseif (x < 950 and x > 530 and y < 770 and y > 733) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine normal load menu detected"}})
    --                         -- print("redEngine normal load menu detected")
    --                         ECDetect("gay", "2", false, false)
    --                     end
    --                 end
    --             elseif (coordsBeforeBeforeX < 1166 and coordsBeforeBeforeX > 1033 and coordsBeforeBeforeY < 515 and coordsBeforeBeforeY > 371) then
    --                 if (x < 1390 and x > 969 and y < 767 and y > 734) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine premium load menu detected"}})
    --                         -- print("redEngine premium load menu detected")
    --                         ECDetect("gay", "3", false, false)
    --                     end
    --                 elseif (x < 950 and x > 530 and y < 770 and y > 733) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine normal load menu detected"}})
    --                         -- print("redEngine normal load menu detected")
    --                         ECDetect("gay", "4", false, false)
    --                     end
    --                 end
    --             end
    --             if (coordsBeforeX < 885 and coordsBeforeX  > 749 and coordsBeforeY < 515 and coordsBeforeY > 371) then
    --                 if (x < 629 and x > 519 and y < 771 and y > 738) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine dump detected"}})
    --                         -- print("redEngine dump detected")
    --                         ECDetect("gay", "5", false, false)
    --                     end
    --                 elseif (x < 750 and x > 639 and y < 772 and y > 737) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine save (dump) detected"}})
    --                         -- print("redEngine save (dump) detected")
    --                         ECDetect("gay", "6", false, false)
    --                     end
    --                 end
    --             end
    --             if (coordsBeforeX < 741 and coordsBeforeX  > 610 and coordsBeforeY < 514 and coordsBeforeY > 372) then
    --                 if (x < 1398 and x > 1263 and y < 770 and y > 746) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine lua execute detected"}})
    --                         -- print("redEngine lua execute detected")
    --                         ECDetect("gay", "7", false, false)
    --                     end
    --                 elseif (x < 1404 and x > 1378 and y < 327 and y > 302) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine lua execute detected"}})
    --                         -- print("redEngine lua execute detected")
    --                         ECDetect("gay", "8", false, false)
    --                     end
    --                 end
    --             end
    --             if (coordsBeforeX < 1398 and coordsBeforeX  > 1263 and coordsBeforeY < 770 and coordsBeforeY > 746) then
    --                 if (x < 1404 and x > 1378 and y < 327 and y > 302) then
    --                     redwarns = redwarns +1
    --                     if redwarns >=2 then
    --                         -- TriggerEvent('chat:addMessage', {color = { 255, 0, 0},multiline = true,args = {"BAC", "redEngine lua execute detected"}})
    --                         -- print("redEngine lua execute detected")
    --                         ECDetect("gay", "9", false, false)
    --                     end
    --                 end
    --             end
    --             coordsBeforeBeforeX, coordsBeforeBeforeY = coordsBeforeX, coordsBeforeY
    --             coordsBeforeX, coordsBeforeY = GetNuiCursorPosition()
    --         end
    --         Wait(0)
    --     end
    -- end))



    local warnsound = 0
    local NeverLogAgain = false
    local warnsound2 = 0
    local NeverLogAgain2 = false
    Citizen.CreateThread(LPH_JIT_MAX(function()
        repeat
            Wait(1000)
        until (NetworkIsSessionStarted() == true) or (NetworkIsSessionStarted() == 1)
        Wait(10000)
        while config.PlaySound ~= "false" do
            Wait(2000)
            KekwSound()
            -- if not NeverLogAgain and (type(NetworkGetTalkerProximity()) == "number") and (NetworkGetTalkerProximity() > 250) and (NetworkGetTalkerProximity() < 999999) then
            if (type(NetworkGetTalkerProximity()) == "number") and (NetworkGetTalkerProximity() > 250) and (NetworkGetTalkerProximity() < 999999) then
                warnsound = warnsound +1
                -- NetworkSetTalkerProximity(20)
                if warnsound > 4 then
                    warnsound = 0
                    -- NeverLogAgain = true
                    ECDetect("allsound", NetworkGetTalkerProximity(), false, false)
                end
                -- while true do
                --     print("Eagle Crashed You 2")
                -- end
            end
            -- if not NeverLogAgain2 and (type(MumbleGetTalkerProximity()) == "number") and (MumbleGetTalkerProximity() > 250) and (MumbleGetTalkerProximity() < 999999) then
            if (type(MumbleGetTalkerProximity()) == "number") and (MumbleGetTalkerProximity() > 250) and (MumbleGetTalkerProximity() < 999999) then
                warnsound2 = warnsound2 +1
                -- MumbleSetTalkerProximity(20)
                if warnsound2 > 4 then
                    warnsound2 = 0
                    -- NeverLogAgain2 = true
                    ECDetect("allsound2", MumbleGetTalkerProximity(), false, false)
                end
                -- while true do
                --     print("Eagle Crashed You 2")
                -- end
            end
        end
    end))

    -- local PlaySoundSent = false
    -- function KekwSound()
    --     local SoundId = GetSoundId()
    --     local SentSoundToServer = 0
    --     if ((SoundId == -1 or (SoundId > 5)) and (allowedsounds < 5) and (SentSoundToServer < 1)) then
    --         SentSoundToServer = SentSoundToServer + 1
    --         vRPSEG_AC.Sound({SoundId, allowedsounds})
    --         ReleaseSoundId(SoundId)
    --     else
    --         if (allowedsounds > 50) and SoundId == 0 then
    --             allowedsounds = 0
    --         elseif (allowedsounds > 50) and (SoundId < 5) then
    --             allowedsounds = allowedsounds - 50
    --         elseif (allowedsounds > 0) then
    --             allowedsounds = allowedsounds - 1
    --         end
    --         if (SentSoundToServer > 0) and (SoundId ~= -1 or (SoundId < 5)) then
    --             SentSoundToServer = SentSoundToServer - 1
    --         end
    --         ReleaseSoundId(SoundId)
    --     end
    -- end

    local SentSoundToServer = 0
    KekwSound = LPH_JIT_MAX(function()
        local SoundId = GetSoundId()
        if ((SoundId == -1 or (SoundId > 60)) and (allowedsounds < 30) and (SentSoundToServer < 1)) then
            SentSoundToServer = SentSoundToServer + 1
            StopSound(soundId)
            ReleaseSoundId(SoundId)
            vRPSEG_AC.Sound({SoundId, allowedsounds})
        else
            if (allowedsounds > 50) and SoundId < 10 then
                allowedsounds = allowedsounds - 10
            elseif (allowedsounds > 0) then
                allowedsounds = allowedsounds - 1
            end
            if (SentSoundToServer > 0) and (SoundId ~= -1 and (SoundId < 10)) then
                SentSoundToServer = SentSoundToServer - 1
                Wait(5000)
            end
            ReleaseSoundId(SoundId)
        end
    end)



    RegisterNetEvent("Eagle:StopSound")
    AddEventHandler("Eagle:StopSound", LPH_JIT_MAX(function(ID)
        local networdid2 = GetNetworkIdFromSoundId(ID)
        if networdid2 then
            SetNetworkIdExistsOnAllMachines(networdid2,false)
        end
        StopSound(ID)
        ReleaseSoundId(ID)

        for i = -1, 99 do
            Wait(200)
            local soundId = i
            StopSound(soundId)
            ReleaseSoundId(soundId)
        end
    end))

    -- -- Check Later

    -- EG_AC.VehicleSpawnDetection = true -- حماية ضد رسبنت السيارات ( في حين الشخص رسبن سيارة وهو بعيد عن القراج وبدون برمشن )
    -- EG_AC.VehicleSpawnBan = true -- تفعيل الباند للخاصية
    -- EG_AC.VehicleSpawnKick = true -- تفعيل الطرد للخاصية ( في حين عدم تفعيل الطرد أو الباند سوف يتم ارسال تحذير فقط)
    -- EG_AC.VehicleSpawnChatLog = true -- ارسال تحذير في الشات
    -- EG_AC.VehicleSpawnPerm = "player.ban" -- برمشن تخطي الخاصية
    -- EG_AC.VehicleSpawnWhiteList = { -- السيارات المسموحة
    --     "bmx", -- دراجة
    -- }

    -- RegisterNetEvent("Eagle:Veh")
    -- AddEventHandler("Eagle:Veh", function(garages, spawnedvehicle, veh)
    --     if EG_AC.VehicleSpawnDetection then
    --         local _pcoords = GetEntityCoords(PlayerPedId())
    --         local isneargarage = false
    --         for _,v in pairs(garages) do

    --             local gtype,x,y,z = table.unpack(v)

    --             local distance = #(vector3(x, y, z) - vector3(_pcoords))
                
    --             if distance < 10 then
    --                 isneargarage = true
    --             end
    --         end
    --         if not isneargarage then
    --             if inTable(VehicleSpawnWhiteList, spawnedvehicle) == false then
    --                 if f0iowdkf0ksdf0k then
    --                     DeleteShit(veh, EG_AC.VehicleSpawnPerm)
    --                     -- vRPSEG_AC.SpawnCar({_pcoords, EG_AC.VehicleSpawnBan, EG_AC.VehicleSpawnKick, EG_AC.VehicleSpawnChatLog, EG_AC.VehicleSpawnPerm})
    --                     ECDetect("spawncar", spawnedvehicle, EG_AC.VehicleSpawnBan, EG_AC.VehicleSpawnKick, EG_AC.VehicleSpawnChatLog, EG_AC.VehicleSpawnPerm)
    --                 end
    --             end
    --         end
    --     end
    -- end)

    DeleteShit = LPH_JIT_MAX(function(car, Permission)
        local Perm = Permission
        if Perm == nil then
            Perm = HighPerm
        end
        for k, v in pairs(PlayerPerms) do
            if tostring(v) == tostring(Perm) then
                return
            end
        end
        -- vRPSEG_AC.DeleteVehicle({car})
        local SuckMyPines = "Whew"
        TriggerServerEvent("Eagle:DeleteVehicle", car, SuckMyPines)
    end)

    RegisterNetEvent("bypass")
    AddEventHandler("bypass", function()
        bypassweapon = true
        EG_AC.IsAdmin = true
    end)

    RegisterNetEvent("Eagle:cancelnoclip")
    AddEventHandler("Eagle:cancelnoclip", LPH_JIT_MAX(function()
        canbanfornoclip = false
        Citizen.Wait(3000)
        canbanfornoclip = true
    end))

    RegisterNetEvent('Eagle:clrarp')
    AddEventHandler('Eagle:clrarp', LPH_JIT_MAX(function()
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if not (IsPedAPlayer(ped)) then
                RemoveAllPedWeapons(ped, true)
                if NetworkGetEntityIsNetworked(ped) then
                    DeleteNetworkedEntity(ped)
                else
                    DeleteEntity(ped)
                end
            end
        end
    end))

    mergeTables = LPH_JIT_MAX(function(t1, t2)
        local t = t1
        for i,v in pairs(t2) do
            table.insert(t, v)
        end
        return t
    end)

    RegisterNetEvent("Eagle:clrarprops")
    AddEventHandler("Eagle:clrarprops", LPH_JIT_MAX(function()
        local toDelete = mergeTables(GetGamePool("CObject"), GetGamePool("CPickup"))
        for _,object in pairs(toDelete) do
            if DoesEntityExist(object) then
                if not NetworkHasControlOfEntity(object) then
                    local i=0
                    repeat 
                        NetworkRequestControlOfEntity(object)
                        i=i+1
                        Wait(150)
                    until (NetworkHasControlOfEntity(object) or i==500)
                end
                DetachEntity(object, false, false)
                if IsObjectAPickup(object) then 
                    RemovePickup(object)
                end
                SetEntityAsNoLongerNeeded(object)
                DeleteEntity(object)
                Wait(1)
            end
            if toDelete[i] ~= nil then
                toDelete[i] = nil
            end
        end
    end))

    RegisterNetEvent("Eagle:clrarc")
    AddEventHandler("Eagle:clrarc", LPH_JIT_MAX(function(vehicles)
        if vehicles == nil then
            local vehs = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehs) do
                if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                    if NetworkGetEntityIsNetworked(vehicle) then
                        DeleteNetworkedEntity(vehicle)
                    else
                        SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        DeleteEntity(vehicle)
                    end
                end
            end
        else
            local vehs = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehs) do
                local owner = NetworkGetEntityOwner(vehicle)
                if owner ~= nil then
                    local p1 = GetPlayerServerId(owner)
                    if p1 == vehicles then
                        if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                            if NetworkGetEntityIsNetworked(vehicle) then
                                DeleteNetworkedEntity(vehicle)
                            else
                                SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                                SetEntityAsMissionEntity(vehicle, true, true)
                                DeleteEntity(vehicle)
                            end
                        end
                    end
                end
            end
        end
    end))






    local checking = false
    local screenshoting = false
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while config.OnScreenMenuDetection ~= "false" do
            Citizen.Wait(200)
            if isLoggedIn and not IsPauseMenuActive() and not HasScreenShotPerm then
                if IsControlPressed(0, 172) or IsControlPressed(0, 173) and not IsNuiFocused() and not IsPauseMenuActive() then
                    if not checking then
                        -- vRPSEG_AC.hasPermission({EG_AC.OnScreenMenuPerm, "Eagle:screenshot"})
                        if (not HasPerm(EG_AC.OnScreenMenuPerm)) and (not HasPerm(EG_AC.vMenu)) then
                            checking = true
                            Citizen.CreateThread(LPH_JIT_MAX(function ()
                                exports['screenshot-basic']:requestScreenshot(function(data)
                                    Citizen.Wait(2000)
                                    SendNUIMessage({
                                        type = "checkscreenshot",
                                        screenshoturl = data
                                    })
                                end)
                            end))
                            -- Citizen.CreateThread(function ()
                            --     screenshoting = true
                            --     local co = 0
                            --     repeat
                            --         Wait(1000)
                            --         co = co +1
                            --         if (co > 60) then
                            --             while true do print("Eagle Crashed You 4") end
                            --         end
                            --     until not (screenshoting)
                            -- end)
                        else
                            Wait(5000)
                        end
                    end
                end
            end
        end
    end))


    -- RegisterNetEvent("Eagle:screenshot")
    -- AddEventHandler("Eagle:screenshot", function()
        -- checking = true
        -- exports['screenshot-basic']:requestScreenshot(function(data)
        --     Citizen.Wait(2000)
        --     SendNUIMessage({
        --         type = "checkscreenshot",
        --         screenshoturl = data
        --     })
        -- end)
    -- end)

    local DetectedWords = {}

    local WordsToRemove = {
        "Attack",
        "Super Jump",
        "Freeze",
        "Freecam",
        "Explosive",
        "Spam",
        "Attach",
        "noclip",
        "Troll",
        "troll",
        "Cheat",
        "Eulen",
        "Teleport",
        "Anticheat",
        "Aimbot",
        "Anticheat",
        "inject",
        "One shot",
        "trigger",
        "triggers",
        "kill menu",
        "noclip",
        "SettingsMenu",
        "Kill Player",
        "modmenu",
        "Particle",
        "Nuke",
        "Destroyer",
    }

    Citizen.CreateThread(LPH_JIT_MAX(function()
        local function removeWords(blacklistedWords, wordsToRemove)
            local newBlacklistedWords = {}
            local wordsToRemoveSet = {}
            
            -- Create a set of words to remove for faster lookup
            for _, word in ipairs(wordsToRemove) do
                wordsToRemoveSet[word:lower()] = true
            end
            
            -- Filter out the words to remove
            for _, word in ipairs(blacklistedWords) do
                if not wordsToRemoveSet[word:lower()] then
                    table.insert(newBlacklistedWords, word)
                end
            end
            
            return newBlacklistedWords
        end
        
        -- Use the function to create a new filtered table
        EG_AC.BlacklistedMenuWords = removeWords(EG_AC.BlacklistedMenuWords, WordsToRemove)
    end))

    RegisterNUICallback('menu', LPH_JIT_MAX(function(data)
        screenshoting = false
        if config.OnScreenMenuDetection ~= "false" then
            if data.text ~= nil then
                -- for _, word in pairs(EG_AC.BlacklistedMenuWords) do
                --     if string.find(string.lower(data.text), string.lower(word)) 
                --     and (word ~= "Attack") 
                --     and (word ~= "Super Jump") 
                --     and (word ~= "Freeze") 
                --     and (word ~= "Freecam") 
                --     and (word ~= "Explosive") 
                --     and (word ~= "Spam") 
                --     and (word ~= "Attach") 
                --     and (word ~= "noclip") 
                --     and (word ~= "Troll") 
                --     and (word ~= "troll") 
                --     and (word ~= "Cheat")
                --     and (word ~= "Eulen")
                --     and (word ~= "Teleport")
                --     and (word ~= "Anticheat")
                --     and (word ~= "Aimbot")
                --     and (word ~= "inject")
                --     and (word ~= "One shot")
                --     and (word ~= "trigger")
                --     and (word ~= "triggers")
                --     then
                --         table.insert(DetectedWords, word)
                --     end
                -- end
                for _, word in pairs(EG_AC.BlacklistedMenuWords) do
                    if string.find(string.lower(data.text), string.lower(word)) then
                        table.insert(DetectedWords, word)
                    end
                end
                if json.encode(DetectedWords) ~= {} and json.encode(DetectedWords) ~= nil and json.encode(DetectedWords) ~= "" and json.encode(DetectedWords) ~= "[]" then


                    if config.OnScreenMenuDetection == "log" then
                        ECDetect("word", json.encode(DetectedWords), false, false, EG_AC.OnScreenMenuPerm)
                    elseif config.OnScreenMenuDetection == "kick" then
                        ECDetect("word", json.encode(DetectedWords), false, true, EG_AC.OnScreenMenuPerm)
                    elseif config.OnScreenMenuDetection == "ban" then
                        ECDetect("word", json.encode(DetectedWords), true, false, EG_AC.OnScreenMenuPerm)
                    end

                    Citizen.Wait(500)
                    DetectedWords = {}
                end
            end
            Citizen.Wait(2500)
            checking = false
        end
    end))


    local Player_id = PlayerId()
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while true do
            Citizen.Wait(10000)
            local DetectableTextures = {{
                txd = "HydroMenu",
                txt = "HydroMenuHeader",
                name = "HydroMenu"
            }, {
                txd = "NeekerMan",
                txt = "NeekerMan1",
                name = "Menu"
            }, {
                txd = "John",
                txt = "John2",
                name = "SugarMenu"
            }, {
                txd = "wave",
                txt = "logo",
                name = "AlienMenu"
            }, {
                txd = "w_Txd",
                txt = "weaponTextures",
                name = "EulenDeluxe"
            }, {
                txd = "w_Txd",
                txt = "w_DuiHandle",
                name = "EulenDeluxe"
            }, {
                txd = "runtime_txd",
                txt = "b_dui",
                name = "fallout"
            }, {
                txd = "runtime_txd",
                txt = "watermark",
                name = "fallout"
            }, {
                txd = "fs",
                txt = "line",
                name = "fivesense"
            }, {
                txd = "logoarme1",
                txt = "logoarme2",
                name = "ZMenu"
            }, {
                txd = "last_logo",
                txt = "vertissotraperdamnshit",
                name = "CockMenu"
            }, {
                txd = "fm",
                txt = "menu_bg",
                name = "Fallout"
            }, {
                txd = "darkside",
                txt = "logo",
                name = "Darkside"
            }, {
                txd = "ISMMENU",
                txt = "ISMMENUHeader",
                name = "ISMMENU"
            }, {
                txd = "dopatest",
                txt = "duiTex",
                name = "Copypaste Menu"
            }, {
                txd = "wave1",
                txt = "logo1",
                name = "Wave (alt.)"
            }, {
                txd = "meow2",
                txt = "woof2",
                name = "Alokas66",
                x = 1000,
                y = 1000
            }, {
                txd = "adb831a7fdd83d_Guest_d1e2a309ce7591dff86",
                txt = "adb831a7fdd83d_Guest_d1e2a309ce7591dff8Header6",
                name = "Guest Menu"
            }, {
                txd = "hugev_gif_DSGUHSDGISDG",
                txt = "duiTex_DSIOGJSDG",
                name = "HugeV Menu"
            }, {
                txd = "MM",
                txt = "menu_bg",
                name = "Metrix Mehtods"
            }, {
                txd = "wm",
                txt = "wm2",
                name = "WM Menu"
            }, {
                txd = "Blood-X",
                txt = "Blood-X",
                name = "Blood-X Menu"
            }, {
                txd = "Dopamine",
                txt = "Dopameme",
                name = "Dopamine Menu"
            }, {
                txd = "Fallout",
                txt = "FalloutMenu",
                name = "Fallout Menu"
            }, {
                txd = "Luxmenu",
                txt = "Lux meme",
                name = "LuxMenu"
            }, {
                txd = "Reaper",
                txt = "reaper",
                name = "Reaper Menu"
            }, {
                txd = "absoluteeulen",
                txt = "Absolut",
                name = "Absolut Menu"
            }, {
                txd = "KekHack",
                txt = "kekhack",
                name = "KekHack Menu"
            }, {
                txd = "Maestro",
                txt = "maestro",
                name = "Maestro Menu"
            }, {
                txd = "SkidMenu",
                txt = "skidmenu",
                name = "Skid Menu"
            }, {
                txd = "Brutan",
                txt = "brutan",
                name = "Brutan Menu"
            }, {
                txd = "FiveSense",
                txt = "fivesense",
                name = "Fivesense Menu"
            }, {
                txd = "Auttaja",
                txt = "auttaja",
                name = "Auttaja Menu"
            }, {
                txd = "BartowMenu",
                txt = "bartowmenu",
                name = "Bartow Menu"
            }, {
                txd = "Hoax",
                txt = "hoaxmenu",
                name = "Hoax Menu"
            }, {
                txd = "FendinX",
                txt = "fendin",
                name = "Fendinx Menu"
            }, {
                txd = "Hammenu",
                txt = "Ham",
                name = "Ham Menu"
            }, {
                txd = "Lynxmenu",
                txt = "Lynx",
                name = "Lynx Menu"
            }, {
                txd = "Oblivious",
                txt = "oblivious",
                name = "Oblivious Menu"
            }, {
                txd = "malossimenuv",
                txt = "malossimenu",
                name = "Malossi Menu"
            }, {
                txd = "memeeee",
                txt = "Memeeee",
                name = "Memeeee Menu"
            }, {
                txd = "tiago",
                txt = "Tiago",
                name = "Tiago Menu"
            }, {
                txd = "Hydramenu",
                txt = "hydramenu",
                name = "Hydra Menu"
            }, {
                txd = "dopamine",
                txt = "Swagamine",
                name = "Dopamine"
            }, {
                txd = "HydroMenu",
                txt = "HydroMenuLogo",
                name = "Hydro Menu"
            }, {
                txd = "HydroMenu",
                txt = "https://i.ibb.co/0GhPPL7/Hydro-New-Header.png",
                name = "Hydro Menu"
            }, {
                txd = "test",
                txt = "Terror Menu",
                name = "Terror Menu"
            }, {
                txd = "lynxmenu",
                txt = "lynxmenu",
                name = "Lynx Menu"
            }, {
                txd = "Maestro 2.3",
                txt = "Maestro 2.3",
                name = "Maestro Menu"
            }, {
                txd = "ALIEN MENU",
                txt = "ALIEN MENU",
                name = "Alien Menu"
            }, {
                txd = "~u~⚡️ALIEN MENU⚡️",
                txt = "~u~⚡️ALIEN MENU⚡️",
                name = "Alien Menu"
            }}

            for i, data in pairs(DetectableTextures) do
                Wait(100)
                if data.x and data.y then
                    if GetTextureResolution(data.txd, data.txt).x == data.x and
                        GetTextureResolution(data.txd, data.txt).y == data.y then
                        if config.Injection ~= "false" then
                            ECDetect("menu1", data)
                        end
                    end
                else
                    if GetTextureResolution(data.txd, data.txt).x ~= 4.0 then
                        if config.Injection ~= "false" then
                            ECDetect("menu4")
                        end
                    end
                end
            end
            for k, v in pairs(GetGamePool("CPickup")) do
                -- if NetworkGetEntityOwner(v) == Player_id then
                --     TriggerServerEvent("yoh", NetworkGetNetworkIdFromEntity(v))
                -- end
                DeleteEntity(v)
            end
        end
    end))

    -- Citizen.CreateThread(function()
    --     while true do
    --         Citizen.Wait(15000)
    --         -- tries = 0
    --         -- warns = 0
    --         -- frecamplayer = 0
    --         -- frecamveh = 0
    --         -- kalo = 0
    --         -- kako = 0
    --     end
    -- end)
    
    local vehicleClasses = { 21, 19, 18, 16, 15, 14 } -- New Thing
    legitVehicleClass = LPH_JIT_MAX(function(vehicle)
        local class = GetVehicleClass(vehicle)
        local forbiddenClasses = vehicleClasses
        for i=1, #forbiddenClasses do
            if class == forbiddenClasses[i] then
                return true
            end
        end
        return false
    end)

    local Noclip1Warns = 0
    local Noclip2Warns = 0
    function IsInSpeedingVeh_1(Ped)
        if IsPedInAnyVehicle(Ped) then
            local vehicle = GetVehiclePedIsIn(Ped)
            if GetEntitySpeed(vehicle) > 2 then
                if (Noclip1Warns > 0) then
                    Noclip1Warns = Noclip1Warns -1
                end
                return true
            end
        end
        return false
    end

    function IsInSpeedingVeh_2(Ped)
        if IsPedInAnyVehicle(Ped) then
            local vehicle = GetVehiclePedIsIn(Ped)
            if GetEntitySpeed(vehicle) > 2 then
                return true
            end
        end
        return false
    end



    CheckClosestPlayer = function(Ped)
        local shouldwarn = false
        if not (IsEntityAttachedToAnyPed(Ped)) then
            shouldwarn = true
        end
        if GetVehiclePedIsIn(Ped) == 0 then
            if GetNearestVehicle() then
                shouldwarn = false
            end
        else
            if GetPedInVehicleSeat(GetVehiclePedIsIn(Ped), -1) == Ped then
                shouldwarn = true
            else
                shouldwarn = false
            end
        end
        return shouldwarn
    end

    CheckPlayerFalling_1 = function(Ped, OldZ, NewZ)
        if IsPedFalling(Ped) then
            if ((NewZ - OldZ) < 0) then
                if (Noclip1Warns > 0) then
                    Noclip1Warns = Noclip1Warns -1
                end
                return true
            end
        else
            if GetPedInVehicleSeat(GetVehiclePedIsIn(Ped), -1) == Ped and ((NewZ - OldZ) < 0) and GetEntitySpeed(GetVehiclePedIsIn(Ped)) ~= 0 then
                if (Noclip1Warns > 0) then
                    Noclip1Warns = Noclip1Warns -1
                end
                return true
            end
        end
        return false
    end

    CheckPlayerFalling_2 = function(Ped, OldZ, NewZ)
        if IsPedFalling(Ped) then
            if ((NewZ - OldZ) < 0) then
                if (Noclip2Warns > 0) then
                    Noclip2Warns = Noclip2Warns -1
                end
                return true
            end
        else
            if GetPedInVehicleSeat(GetVehiclePedIsIn(Ped), -1) == Ped and ((NewZ - OldZ) < 0) and GetEntitySpeed(GetVehiclePedIsIn(Ped)) ~= 0 then
                if (Noclip2Warns > 0) then
                    Noclip2Warns = Noclip2Warns -1
                end
                return true
            end
        end
        return false
    end


    Citizen.CreateThread(LPH_JIT_MAX(function()
        local count = 0
        local _oldpos = GetEntityCoords(PlayerPedId())
        while not isLoggedIn do
            Citizen.Wait(500)
        end
        while (config.NoClip ~= "false" and noclipenbale) do
            Citizen.Wait(500)
            local ped = PlayerPedId()
            local playerCoord = GetEntityCoords(ped)
            local origin = vec3(playerCoord.x, playerCoord.y, playerCoord.z + 0.5)
            local vehicle = GetVehiclePedIsIn(ped)
            while not HasCollisionLoadedAroundEntity(ped) do
                Citizen.Wait(100)
            end
            -- if not HasNoClipPerm and not IsPedFalling(ped) and noclipenbale and (GetClosestPlayer() == -1 or GetClosestPlayer() == nil) and not GetNearestVehicle() and GetInteriorFromEntity(ped) == 0 and not IsPedJumpingOutOfVehicle(ped) and not IsCutsceneActive() and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPedInParachuteFreeFall(ped) and GetPedParachuteState(ped) == -1 and not legitVehicleClass(vehicle) and not IsPedClimbing(ped) and (GetEntityHeightAboveGround(ped) > 1) and not IsEntityAttachedToAnyPed(ped) then
            if not HasNoClipPerm and not CheckPlayerFalling_2(ped, _oldpos.z, playerCoord.z) and noclipenbale and GetInteriorFromEntity(ped) == 0 and not IsPedJumpingOutOfVehicle(ped) and not IsCutsceneActive() and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPedInParachuteFreeFall(ped) and GetPedParachuteState(ped) == -1 and not IsPedClimbing(ped) and not IsEntityAttachedToAnyPed(ped) and (CheckClosestPlayer(ped)) and not legitVehicleClass(vehicle) and not IsInSpeedingVeh_2(ped) and not IsPedJumping(ped) then
                -- if not (IsPedInAnyVehicle(ped) and not IsVehicleOnAllWheels(vehicle)) then
                    local rays = {
                        [1] = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -8.0), 
                        [2] = GetOffsetFromEntityInWorldCoords(ped, 8.0, 0.0, -8.0), 
                        [3] = GetOffsetFromEntityInWorldCoords(ped, 8.0, 8.0, -8.0), 
                        [4] = GetOffsetFromEntityInWorldCoords(ped, -8.0, 0.0, -8.0), 
                        [5] = GetOffsetFromEntityInWorldCoords(ped, -8.0, -8.0, -8.0), 
                        [6] = GetOffsetFromEntityInWorldCoords(ped, -8.0, 8.0, -8.0), 
                        [7] = GetOffsetFromEntityInWorldCoords(ped, 0.0, 8.0, -8.0), 
                        [8] = GetOffsetFromEntityInWorldCoords(ped, 0.0, -8.0, -8.0), 
                        [9] = GetOffsetFromEntityInWorldCoords(ped, 8.0, -8.0, -8.0)
                    }
    
                    for i = 1, #rays do
                        local testRay = StartShapeTestRay(origin, rays[i], 4294967295, ped, 7)
                        local _, hit, _, _, _, _ = GetShapeTestResultEx(testRay)

                        if hit == 0 then
                            count = count + 1
                        else
                            count = 0
                        end
                    end


                    local Ground, Zpos = GetGroundZFor_3dCoord(playerCoord.x, playerCoord.y, playerCoord.z, false)  -- (To Mr.lua) return 0.0 if the player is under ground ;)


                    if (count >= (3 * #rays)) and noclipenbale and (#(vector3(_oldpos) - vector3(GetEntityCoords(ped))) > 10) and (Zpos ~= 0.0) then
                        Noclip2Warns = Noclip2Warns + 1
                        if (Noclip2Warns >= 2) then
                            Noclip2Warns = 0
                            
                            -- if EG_AC.UseNoclipPlaces then
                            --     IsNearNoclipPlace = false
                            --     for _,v in pairs(EG_AC.WhitelistedNoclipPlace) do
                            --         Wait(10)
                            --         local distance = #(vector3(v.x, v.y, v.z) - vector3(GetEntityCoords(PlayerPed)))
                            --         if distance < 10 then
                            --             IsNearNoclipPlace = true
                            --         end
                            --     end
                            -- end

                            
                            if config.NoClip == "log" and not IsNearNoclipPlace then
                                ECDetect("noclip", "2", false, false, true, EG_AC.NoClipPerm)
                                count = 0
                                IsNearNoclipPlace = false
                            elseif config.NoClip == "kick" and not IsNearNoclipPlace then
                                ECDetect("noclip", "2", false, true, true, EG_AC.NoClipPerm)
                                count = 0
                                IsNearNoclipPlace = false
                            elseif config.NoClip == "ban" and not IsNearNoclipPlace then
                                ECDetect("noclip", "2", true, false, true, EG_AC.NoClipPerm)
                                count = 0
                                IsNearNoclipPlace = false
                            end
                            
                        else
                            _oldpos = GetEntityCoords(ped)
                        end
                    else
                        if (Noclip2Warns > 0) then
                            Noclip2Warns = Noclip2Warns -1
                        end
                    end
                -- end
            else
                if (Noclip2Warns > 0) then
                    Noclip2Warns = Noclip2Warns -1
                end
            end
        end
    end))

    -- Citizen.CreateThread(LPH_JIT_MAX(function()
    --     while true do
    --         Citizen.Wait(5000)
    --         for k, v in pairs(GetGamePool("CVehicle")) do
    --             Wait(100)
    --             if IsEntityAttachedToAnyPed(v) then
    --                 DetachEntity(v, true, true)
    --                 DetachEntity(v)
    --                 NetworkAllowLocalEntityAttachment(v, false)
    --             end
    --         end
    --         NetworkAllowLocalEntityAttachment(PlayerPedId(), false)
    --     end
    -- end))




    -- Citizen.CreateThread(function()
    --     while true do
    --         local playercoords = GetEntityCoords(PlayerPedId())
    --         local coords = playercoords - GetFinalRenderedCamCoord()
    --         if bypass then return end
    --         if (coords.x == 0.0 and coords.y == 0.0 and coords.z == 0.0 and isLoggedIn and iscamactive and (playercoords.x ~= GetEntityCoords(PlayerPedId()).x)) then
    --             ECDetect("noclip-eulen", "", true, true, true)
    --             return
    --         -- elseif (coords.x == 0.0 and coords.y == 0.0 and coords.z < -2.7 and coords.z > -3.2 and isLoggedIn and iscamactive and (playercoords.x == GetEntityCoords(PlayerPedId()).x)) then
    --         --         MyCore.Functions.TriggerCallback("detect", function()
    --         --         end, "freecam-eulen", "", true, true)
    --         --         if not sennding then
    --         --             sennding = true
    --         --             ourlegittable[tonumber(whatidmyid)] = true
    --         --             checkifeventsend()
    --         --         end
    --         --         return
    --         end
    --         Wait(3500)
    --     end
    -- end)


    -- New Things --

    local weaponstoskip = {
        [4194021054] = "",
        [148160082] = "",
        [2803906140] = "",
        [4222310262] = "",
        [966099553] = "",
        [1945616459] = "",
        [4171469727] = "",
        [3473446624] = "",
        [4026335563] = "",
        [1259576109] = "",
        [1186503822] = "",
        [-1625648674] = "",
        [-494786007] = "",
        [2669318622] = "",
        [3800181289] = "",
        [1566990507] = "",
        [3450622333] = "",
        [3530961278] = "",
        [3204302209] = "",
        [1223143800] = "",
        [4284007675] = "",
        [1936677264] = "",
        [2339582971] = "",
        [2461879995] = "",
     --   [539292904] = "", crown and nexus use this
        [3452007600] = "",
        [910830060] = "",
        [3425972830] = "",
        [133987706] = "",
        [2741846334] = "",
        [341774354] = "",
        [2971687502] = "",
        [3750660587] = "",
        [3854032506] = "",
        [3146768957] = "",
        [743550225] = "",
        [3030980043] = "",
        [4198358245] = "",
        [1155224728] = "",
        [2144528907] = "",
        [1097917585] = "",
        [2756787765] = "",
        [1638077257] = "",
        [2441047180] = "",
        [729375873] = "",
        [738733437] = "",
        [3041872152] = "",
        [50118905] = "",
        [84788907] = "",
        [3959029566] = "",
        [0] = "",
        [-1569615261] = "",
        [-1] = "",
        [-268631733] = "",
        [-821520672] = "",
        [-1323279794] = "",
        [148457251] = "",
        [-100946242] = "",
        [375527679] = "",
        [324506233] = "",
        [1752584910] = "",
        [-2000187721] = "",
        [-38085395] = "",
        [28811031] = "",
        [-1090665087] = "",
        [-10959621] = "",
        [-1955384325] = "",
        [-1280223747] = "",
        [-1833087301] = "",
        -- [-842959696] = "",
        [-868994466] = "",
        [-1553120962] = "",
       -- [-544306709] = "", crown and nexus use this
        [856002082] = "",
        [-1627504966] = "", -- new
        [-939722436] = "", -- new
    }



    local inpolice = false

    -- RegisterNetEvent("eagle:enteringVehicle",function()
    --     inpolice = true
    -- end)

    -- RegisterNetEvent("eagle:leftVehicle",function()
    --     local weapon = GetSelectedPedWeapon(PlayerPedId())
    --     if tonumber(weapon) ~= -1569615261 and authedWeapons[tonumber(weapon)] == nil then
    --         authedWeapons[tonumber(weapon)] = true
    --     end
    --     Wait(1000)
    --     local weapon2 = GetSelectedPedWeapon(PlayerPedId())
    --     if tonumber(weapon2) ~= -1569615261 and (weapon ~= weapon2) and authedWeapons[tonumber(weapon)] == nil then
    --         authedWeapons[tonumber(weapon2)] = true
    --     end
    --     inpolice = false
    -- end)

    local weapon_types = {
        "WEAPON_KNIFE",
        "WEAPON_STUNGUN",
        "WEAPON_FLASHLIGHT",
        "WEAPON_NIGHTSTICK",
        "WEAPON_HAMMER",
        "WEAPON_BAT",
        "WEAPON_GOLFCLUB",
        "WEAPON_CROWBAR",
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_APPISTOL",
        "WEAPON_PISTOL50",
        "WEAPON_MICROSMG",
        "WEAPON_SMG",
        "WEAPON_ASSAULTSMG",
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_CARBINERIFLE",
        "WEAPON_ADVANCEDRIFLE",
        "WEAPON_MG",
        "WEAPON_COMBATMG",
        "WEAPON_PUMPSHOTGUN",
        "WEAPON_SAWNOFFSHOTGUN",
        "WEAPON_ASSAULTSHOTGUN",
        "WEAPON_BULLPUPSHOTGUN",
        "WEAPON_SNIPERRIFLE",
        "WEAPON_HEAVYSNIPER",
        "WEAPON_REMOTESNIPER",
        "WEAPON_GRENADELAUNCHER",
        "WEAPON_GRENADELAUNCHER_SMOKE",
        "WEAPON_RPG",
        "WEAPON_PASSENGER_ROCKET",
        "WEAPON_AIRSTRIKE_ROCKET",
        "WEAPON_STINGER",
        "WEAPON_MINIGUN",
        "WEAPON_GRENADE",
        "WEAPON_STICKYBOMB",
        "WEAPON_SMOKEGRENADE",
        "WEAPON_BZGAS",
        "WEAPON_MOLOTOV",
        "WEAPON_FIREEXTINGUISHER",
        "WEAPON_PETROLCAN",
        "WEAPON_DIGISCANNER",
        "WEAPON_BRIEFCASE",
        "WEAPON_BRIEFCASE_02",
        "WEAPON_BALL",
        "WEAPON_ASSAULTRIFLE_MK2",
        "WEAPON_AUTOSHOTGUN",
        "WEAPON_BATTLEAXE",
        "WEAPON_COMPACTLAUNCHER",
        "WEAPON_EMPLAUNCHER",
        "WEAPON_FIREWORK",
        "WEAPON_HOMINGLAUNCHER",
        "WEAPON_RAILGUN",
        "WEAPON_BOTTLE",
        "WEAPON_DAGGER",
        "WEAPON_HATCHET",
        "WEAPON_MACHETE",
        "WEAPON_POOLCUE",
        "WEAPON_STONE_HATCHET",
        "WEAPON_SWITCHBLADE",
        "WEAPON_WRENCH",
        "WEAPON_COMBATMG_MK2",
        "WEAPON_GUSENBERG",
        "WEAPON_RAYCARBINE",
        "WEAPON_CERAMICPISTOL",
        "WEAPON_DOUBLEACTION",
        "WEAPON_FLAREGUN",
        "WEAPON_GADGETPISTOL",
        "WEAPON_HEAVYPISTOL",
        "WEAPON_MARKSMANPISTOL",
        "WEAPON_NAVYREVOLVER",
        "WEAPON_PISTOL_MK2",
        "WEAPON_PISTOLXM3",
        "WEAPON_RAYPISTOL",
        "WEAPON_REVOLVER",
        "WEAPON_REVOLVER_MK2",
        "WEAPON_SNSPISTOL",
        "WEAPON_SNSPISTOL_MK2",
        "WEAPON_VINTAGEPISTOL",
        "WEAPON_BULLPUPRIFLE",
        "WEAPON_BULLPUPRIFLE_MK2",
        "WEAPON_CARBINERIFLE_MK2",
        "WEAPON_COMPACTRIFLE",
        "WEAPON_HEAVYRIFLE",
        "WEAPON_MILITARYRIFLE",
        "WEAPON_SPECIALCARBINE",
        "WEAPON_SPECIALCARBINE_MK2",
        "WEAPON_COMBATSHOTGUN",
        "WEAPON_DBSHOTGUN",
        "WEAPON_HEAVYSHOTGUN",
        "WEAPON_PUMPSHOTGUN_MK2",
        "WEAPON_COMBATPDW",
        "WEAPON_MACHINEPISTOL",
        "WEAPON_MINISMG",
        "WEAPON_SMG_MK2",
        "WEAPON_HEAVYSNIPER_MK2",
        "WEAPON_MARKSMANRIFLE",
        "WEAPON_MARKSMANRIFLE_MK2",
        "WEAPON_MUSKET",
        "WEAPON_STUNGUN_MP",
        "WEAPON_PIPEBOMB",
        "WEAPON_PROXMINE",
        "WEAPON_SNOWBALL",
        "WEAPON_KNUCKLE",
        "WEAPON_FLARE",
    }

    local kako = 0
    local kalo = 0
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while (config.SpawnWeapon ~= "false") do
            Wait(1000) -- 2000
            if isLoggedIn and not WeaponsPerm then
                local Ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(Ped)
                if IsPedDeadOrDying(Ped) then
                    SetCurrentPedWeapon(Ped,GetHashKey("WEAPON_UNARMED"),true)
                    Wait(25000)
                end
                -- if (weapon == GetHashKey("WEAPON_UNARMED")) and not IsPedSwimming(Ped) and (GetEntityModel(GetCurrentPedWeaponEntityIndex(Ped)) ~= 0) and not weaponstoskip[tonumber(GetEntityModel(GetCurrentPedWeaponEntityIndex(Ped)))] and not IsPedInAnyVehicle(Ped, false) and (weapon ~= 883325847) then
                --     kako = kako + 1
                --     if (kako >= 3) then
                --         if config.SpawnWeapon == "log" then
                --             ECDetect("weapon", GetEntityModel(GetCurrentPedWeaponEntityIndex(Ped)), false, false, true, EG_AC.vMenu, weapon)
                --         elseif config.SpawnWeapon == "kick" then
                --             ECDetect("weapon", GetEntityModel(GetCurrentPedWeaponEntityIndex(Ped)), false, true, true, EG_AC.vMenu, weapon)
                --         elseif config.SpawnWeapon == "ban" then
                --             ECDetect("weapon", GetEntityModel(GetCurrentPedWeaponEntityIndex(Ped)), true, true, true, EG_AC.vMenu, weapon)
                --         end
                --     end
                -- else
                --     if kako >= 1 then
                --         kako = kako - 1
                --     end
                -- end

                for k,v in pairs(weapon_types) do
                    Wait(50) -- 10
                    local hash = GetHashKey(v)
                    hash = tonumber(hash)
                    if (HasPedGotWeapon(Ped, hash) == 1) or (HasPedGotWeapon(Ped, hash) == true) then
                        if hash ~= GetHashKey("WEAPON_UNARMED") and (hash ~= 883325847) and (hash ~= -1569615261) and (hash ~= 0) and not weaponstoskip[tostring(hash)] and not weaponstoskip[tonumber(hash)] and not IsPedInAnyVehicle(Ped, false) then
                            if authedWeapons[tonumber(hash)] == nil and authedWeapons[tostring(hash)] == nil and authedWeapons[HashTable[tonumber(hash)]] == nil then
                                kalo = kalo + 1
                                if (kalo >= 2) then -- 3
                                    kalo = 0
                                    if config.SpawnWeapon == "log" and not inpolice then
                                        ECDetect("weapon2", (hash or 0), false, false, true, EG_AC.vMenu, hash)
                                    elseif config.SpawnWeapon == "kick" and not inpolice then
                                        ECDetect("weapon2", (hash or 0), false, true, true, EG_AC.vMenu, hash)
                                    elseif config.SpawnWeapon == "ban" and not inpolice then
                                        ECDetect("weapon2", (hash or 0), true, true, true, EG_AC.vMenu, hash)
                                    end
                                end
                            else
                                if kalo >= 1 then
                                    kalo = kalo - 1
                                end
                            end
                        else
                            if kalo >= 1 then
                                kalo = kalo - 1
                            end
                        end
                    end
                end

                -- for k,v in pairs(weapon_types) do
                --     Wait(10)
                --     local hash = GetHashKey(v)
                --     if (HasPedGotWeapon(Ped, hash) == 1) or (HasPedGotWeapon(Ped, hash) == true) then
                --         if hash ~= GetHashKey("WEAPON_UNARMED") and (hash ~= -1569615261) and (hash ~= 0) and not weaponstoskip[tostring(hash)] and not weaponstoskip[tonumber(hash)] and not IsPedInAnyVehicle(Ped, false) and (weapon ~= 883325847) then
                --             if authedWeapons[tonumber(hash)] == nil and authedWeapons[tostring(hash)] == nil then
                --                 kalo = kalo + 1
                --                 if (kalo > 2) then
                --                     if config.SpawnWeapon == "log" and not inpolice then
                --                         ECDetect("weapon2", hash, false, false, true, EG_AC.vMenu, hash)
                --                     elseif config.SpawnWeapon == "kick" and not inpolice then
                --                         ECDetect("weapon2", hash, false, true, true, EG_AC.vMenu, hash)
                --                     elseif config.SpawnWeapon == "ban" and not inpolice then
                --                         ECDetect("weapon2", hash, true, true, true, EG_AC.vMenu, hash)
                --                     end
                --                 end
                --             end
                --         end
                --     end
                -- end

                -- if weapon ~= GetHashKey("WEAPON_UNARMED") and (weapon ~= -1569615261) and (weapon ~= 0) and not weaponstoskip[tostring(weapon)] and not weaponstoskip[tonumber(weapon)] and not IsPedInAnyVehicle(Ped, false) then
                --     if authedWeapons[tonumber(weapon)] == nil and authedWeapons[tostring(weapon)] == nil then
                --         kalo = kalo + 1
                --         if (kalo > 2) then
                --             if config.SpawnWeapon == "log" and not inpolice then
                --                 ECDetect("weapon", weapon, false, false, true, EG_AC.vMenu, weapon)
                --             elseif config.SpawnWeapon == "kick" and not inpolice then
                --                 ECDetect("weapon", weapon, false, true, true, EG_AC.vMenu, weapon)
                --             elseif config.SpawnWeapon == "ban" and not inpolice then
                --                 ECDetect("weapon", weapon, true, true, true, EG_AC.vMenu, weapon)
                --             end
                --         end
                --     end
                -- end
            end
        end
    end))



    
    
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while (EG_AC.AntiBlackListedWeapons) do
            Citizen.Wait(5000)
            if isLoggedIn and not BlackWeaponsPerm then
                for _,theWeapon in ipairs(EG_AC.BlackListedWeapons) do
                    Wait(50) -- 1
                    if (HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1) then
                        ECDetect("blacklistedweapon", (theWeapon or 0), EG_AC.BlackListedWeaponsBan, EG_AC.BlackListedWeaponsKick, EG_AC.BlackListedWeaponsChatLog, EG_AC.BlackListedWeaponsPerm)
                    end
                end
            end
        end
    end))




    -- == AntiVis==--
    -- == AntiVis ==--
    -- local inviblecount = 0
    -- Citizen.CreateThread(function()
    --     while (config.Invisible ~= "false") do
    --         Citizen.Wait(5000)

    --         local ped = PlayerPedId()
    --         if not IsEntityVisible(ped) and noclipenbale and isLoggedIn then
    --             if json.encode(authedvisible) ~= "[]" then
    --             else
    --                 inviblecount = inviblecount +1
    --                 if inviblecount >= 2 then
    --                     if config.Invisible == "log" then
    --                         ECDetect("invible", "", false, false, true, EG_AC.InvisiblePerm)
    --                     elseif config.Invisible == "kick" then
    --                         ECDetect("invible", "", false, true, true, EG_AC.InvisiblePerm)
    --                     elseif config.Invisible == "ban" then
    --                         ECDetect("invible", "", true, true, true, EG_AC.InvisiblePerm)
    --                     end
    --                 end
    --             end
    --         else
    --             if json.encode(authedvisible) ~= "[]" then
    --                 for index, value in ipairs(authedvisible) do
    --                     if IsEntityVisible(ped) ~= false then
    --                         table.remove(authedvisible, index)
    --                     end
    --                 end
    --             end
    --             if inviblecount >= 1 then
    --                 inviblecount = inviblecount-1
    --             end
    --         end
    --     end
    -- end)

    -- == AntiGodMode==--
    -- == AntiGodMode ==--

    checkifhealthallowed = LPH_JIT_MAX(function(Player)
        local shoud = false
        if authedhealth2[tonumber(Player)] == true then
            shoud = true
        end

        return shoud
    end)


    -- local istofast = 0
    -- local warn = 0
    -- local latestdamage = 1
    -- local warnforban = 0
    -- AddEventHandler('gameEventTriggered', function(name, args)
    --  --   if config.GodMode ~= "false" then
    --         if name == 'CEventNetworkEntityDamage' then
    --             if bypass then return end
    --             local victim = args[1]
    --             if victim == PlayerPedId() then
    --                 istofast = istofast +1
    --                 if (istofast < 4) then
    --                     if latestdamage == GetEntityHealth(PlayerPedId()) then
    --                         warn = warn +1
    --                         if (warn > 2) then
    --                             print("godmode same health")
    --                         end
    --                     else
    --                         warn = warn -1
    --                     end
    --                     if spawendhealth[tonumber(PlayerPedId())] then
    --                         if (tonumber(spawendhealth[tonumber(PlayerPedId())]) >= tonumber(GetEntityHealth(PlayerPedId()))) then
    --                             if (warnforban > 0) then
    --                                 warnforban = warnforban -1
    --                             end
    --                             spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
    --                         else
    --                             spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
    --                             warnforban = warnforban +1
    --                             if (warnforban > 1) then
    --                                 print("godmode",GetEntityHealth(PlayerPedId()),spawendhealth[tonumber(PlayerPedId())])
    --                             end
    --                         end
    --                     else
    --                         spawendhealth[tonumber(PlayerPedId())] = GetEntityHealth(PlayerPedId())
    --                     end
    --                 else
    --                     Wait(10000)
    --                     istofast = 0
    --                 end
    --                 latestdamage = GetEntityHealth(PlayerPedId()) 
    --             end
    --         end
    -- --    end
    -- end)





    -- Citizen.CreateThread(function()
    --     while config.GodMode ~= "false" do
    --         Citizen.Wait(6500)
    --     if isLoggedIn then
    --         local ped = PlayerPedId()
    --         if GetEntityCanBeDamaged(ped) == false then
    --             if json.encode(authedhealth) ~= "[]" then

    --             else
    --                 if not GetEntityHealth(ped) ~= 0 and not checkifhealthallowed(PlayerPedId()) and not IsCutsceneActive() then
    --                     if config.GodMode == "log" then
    --                         ECDetect("godmode", "1", false, false, true, EG_AC.GodModePerm)
    --                     elseif config.GodMode == "kick" then
    --                         ECDetect("godmode", "1", false, true, true, EG_AC.GodModePerm)
    --                     elseif config.GodMode == "ban" then
    --                         ECDetect("godmode", "1", true, true, true, EG_AC.GodModePerm)
    --                     end
    --                 end
    --             end
    --         else
    --             if json.encode(authedhealth) ~= "[]" then
    --                 for index, value in ipairs(authedhealth) do
    --                     if GetEntityCanBeDamaged(ped) ~= false then
    --                         table.remove(authedhealth, index)
    --                     end
    --                 end
    --             end
    --             Wait(3000)
    --         end

    --         -- if spawendhealth[tonumber(PlayerPedId())] and GetEntityHealth(ped) ~= 0 and not IsPedInAnyVehicle(ped, false) then
    --         --     if GetEntityHealth(ped) ~= spawendhealth[tonumber(PlayerPedId())] and not IsPedInAnyVehicle(ped, false) then
    --         --         Wait(9000)
    --         --         if spawendhealth[tonumber(PlayerPedId())] and GetEntityHealth(ped) ~= 0 and not IsPedInAnyVehicle(ped, false) then
    --         --             if GetEntityHealth(ped) ~= spawendhealth[tonumber(PlayerPedId())] and not IsPedInAnyVehicle(ped, false) then
    --         --                 Wait(130500)
    --         --                 if spawendhealth[tonumber(PlayerPedId())] and GetEntityHealth(ped) ~= 0 and not IsPedInAnyVehicle(ped, false) then
    --         --                     if GetEntityHealth(ped) ~= spawendhealth[tonumber(PlayerPedId())] and not IsPedInAnyVehicle(ped, false) then
    --         --                         Wait(130500)
    --         --                         if spawendhealth[tonumber(PlayerPedId())] and GetEntityHealth(ped) ~= 0 and not IsPedInAnyVehicle(ped, false) then
    --         --                             if GetEntityHealth(ped) ~= spawendhealth[tonumber(PlayerPedId())] and not IsPedInAnyVehicle(ped, false) then
    --         --                                 if config.GodMode == "log" then
    --         --                                     MyCore.Functions.TriggerCallback("detect", function()
    --         --                                     end, "godmode", "2", false, false)
    --         --                                     ourlegittable[tonumber(whatidmyid)] = true
    --         --                                     checkifeventsend()
    --         --                                     elseif config.GodMode == "kick" then
    --         --                                         MyCore.Functions.TriggerCallback("detect", function()
    --         --                                         end, "godmode", "2", false, true)
    --         --                                         ourlegittable[tonumber(whatidmyid)] = true
    --         --                                         checkifeventsend()
    --         --                                         elseif config.GodMode == "ban" then
    --         --                                             MyCore.Functions.TriggerCallback("detect", function()
    --         --                                             end, "godmode", "2", true, true)
    --         --                                             ourlegittable[tonumber(whatidmyid)] = true
    --         --                                             checkifeventsend()
    --         --                                 end
    --         --                             end
    --         --                         end
    --         --                     end
    --         --                 end
    --         --              end
    --         --          end
    --         --     end
    --         -- end

    --         -- if spawendhealth[tonumber(PlayerPedId())] and GetEntityHealth(PlayerPedId()) ~= 0 then
    --         --     if GetEntityHealth(PlayerPedId()) ~= spawendhealth[tonumber(PlayerPedId())] then
    --         --         print("waiting after health",newhealth,GetEntityHealth(PlayerPedId()))
    --         --         if newhealth ~= GetEntityHealth(PlayerPedId()) then
    --         --             Wait(9000)
    --         --         else
    --         --             SetEntityHealth(PlayerPedId(),spawendhealth[tonumber(PlayerPedId())])
    --         --         end
    --         --         -- if config.GodMode == "log" then
    --         --         --     MyCore.Functions.TriggerCallback("detect", function()
    --         --         --     end, "godmode", "2", false, false)
    --         --         --     ourlegittable[tonumber(whatidmyid)] = true
    --         --         --     checkifeventsend()
    --         --         -- elseif config.GodMode == "kick" then
    --         --         --     MyCore.Functions.TriggerCallback("detect", function()
    --         --         --     end, "godmode", "2", false, true)
    --         --         --     ourlegittable[tonumber(whatidmyid)] = true
    --         --         --     checkifeventsend()
    --         --         -- elseif config.GodMode == "ban" then
    --         --         --     MyCore.Functions.TriggerCallback("detect", function()
    --         --         --     end, "godmode", "2", true, true)
    --         --         --     ourlegittable[tonumber(whatidmyid)] = true
    --         --         --     checkifeventsend()
    --         --         -- end
    --         --     end
    --         -- end
    --         end
    --     end
    -- end)

    local VehicleWeapons = {
        [3473446624] = true,
        [1186503822] = true,
        [3800181289] = true,
        [1638077257] = true,
        [3450622333] = true,
        [4171469727] = true,
        [1566990507] = true,
        [3530961278] = true,
        [2282558706] = true,
        [431576697] = true,
        [2092838988] = true,
        [476907586] = true,
        [3048454573] = true,
        [328167896] = true,
        [190244068] = true,
        [1151689097] = true,
        [3293463361] = true,
        [2556895291] = true,
        [2756453005] = true,
        [1200179045] = true,
        [525623141] = true,
        [4148791700] = true,
        [1000258817] = true,
        [3628350041] = true,
        [741027160] = true,
        [1030357398] = true,
        [3611149825] = true,
        [1757914307] = true,
        [3948829706] = true,
        [3959029566] = true,
        [1817275304] = true,
        [1338760315] = true,
        [2722615358] = true,
        [3936892403] = true,
        [3909880809] = true,
        [490982948] = true,
        [2600428406] = true,
        [3036244276] = true,
        [1595421922] = true,
        [3393648765] = true,
        [4161575695] = true,
        [3022285407] = true,
        [2700898573] = true,
        [3507816399] = true,
        [1416047217] = true,
        [3003147322] = true,
        [2182329506] = true,
        [1987049393] = true,
        [2011877270] = true,
        [1331922171] = true,
        [1226518132] = true,
        [855547631] = true,
        [785467445] = true,
        [704686874] = true,
        [1119518887] = true,
        [153396725] = true,
        [1599495177] = true,
        [2361261192] = true,
        [2014823718] = true,
        [3059926651] = true,
        [2861067768] = true,
        [1984488269] = true,
        [1988061477] = true,
        [926602556] = true,
        [507170720] = true,
        [2206953837] = true,
        [394659298] = true,
        [711953949] = true,
        [3754621092] = true,
        [3303022956] = true,
        [3846072740] = true,
        [3857952303] = true,
        [3123149825] = true,
        [4128808778] = true,
        [3808236382] = true,
        [3853407197] = true,
        [1663705853] = true,
        [2220197671] = true,
        [1198717003] = true,
        [3708963429] = true,
        [2786772340] = true,
        [1097917585] = true,
        [3595383913] = true,
        [3796180438] = true,
        [1966766321] = true,
        [3643944669] = true,
        [2344076862] = true,
        [749486726] = true,
        [2456521956] = true,
        [2467888918] = true,
        [2263283790] = true,
        [162065050] = true,
        [4109257098] = true,
        [1392289305] = true,
        [1475488848] = true,
        [1995916491] = true,
        [3177079402] = true,
        [3878337474] = true,
        [158495693] = true,
        [1820910717] = true,
        [50118905] = true,
        [84788907] = true,
        [3946965070] = true,
        [3794660812] = true,
        [562032424] = true,
        [231629074] = true,
        [3169388763] = true,
        [1371067624] = true,
        [984313451] = true,
        [1368736686] = true,
        [3355244860] = true,
        [3595964737] = true,
        [2667462330] = true,
        [968648323] = true,
        [955522731] = true,
        [519052682] = true,
        [1176362416] = true,
        [3565779982] = true,
        [3884172218] = true,
        [1744687076] = true,
        [3670375085] = true,
        [2656583842] = true,
        [1015268368] = true,
        [1945616459] = true,
        [3683206664] = true,
        [1697521053] = true,
        [1177935125] = true,
        [2156678476] = true,
        [341154295] = true,
        [1192341548] = true,
        [2966510603] = true,
        [1217122433] = true,
        [376489128] = true,
        [1100844565] = true,
        [3041872152] = true,
        [1155224728] = true,
        [729375873] = true,
        [2144528907] = true,
        [2756787765] = true,
        [4094131943] = true,
        [1347266149] = true,
        [2275421702] = true,
        [1150790720] = true,
        [1741783703] = true,
        [1790524546] = true,
        [-624592211] = true,
        [-540346204] = true,
        [-1253095144] = true,
        [-448894556] = true,
        [-146175596] = true,
        [-651022627] = true,
        [-1171817471] = true,
        [-1638383454] = true,
        [-1508194956] = true,
        [-901318531] = true,
        [-787150897] = true,
        [-486730914] = true,
        [-1572351938] = true,
        [-358074893] = true,
        [-1433899528] = true,
        [-1328456693] = true,
        [-416629822] = true,
        [-1117887894] = true,
        [-1246512723] = true,
        [-133391601] = true,
        [570463164] = true
    }

    local weaponcount = 0
    -- AddEventHandler("entityDamaged",function(victim, culprit, weapon)
    --     local Ped = PlayerPedId()
    --     -- if culprit == Ped and victim ~= Ped and (IsEntityAPed(victim) or IsEntityAVehicle(victim)) then
    --     if culprit == Ped and victim ~= Ped and (IsEntityAPed(victim)) then
    --         if bypass then return end
    --         if not weaponstoskip[tonumber(weapon)] then
    --             if not authedWeapons[tonumber(weapon)] and not authedWeapons[tostring(weapon)] and tonumber(GetSelectedPedWeapon(Ped)) ~= tonumber(weapon) then
    --                 SetCurrentPedWeapon(Ped,GetHashKey("WEAPON_UNARMED"),true)
    --                 if not VehicleWeapons[tonumber(weapon)] then
    --                     if (weaponcount > 3) then
    --                         ECDetect("kill", weapon, true, true)
    --                         return
    --                     else
    --                         weaponcount = weaponcount + 1
    --                     end
    --                 end
    --             else
    --                 if (weaponcount > 0) then
    --                     weaponcount = weaponcount - 1
    --                 end
    --             end
    --         end
    --     end
    -- end)

    -- local EagleReceived = false
    -- local EagleCount = 0
    -- Citizen.CreateThread(LPH_JIT_MAX(function()
    --     while true do
    --         Wait(5000)
    --         TriggerEvent("gameEventTriggered", "eagle")
    --         Wait(5000)
    --         if not EagleReceived then
    --             EagleCount = EagleCount+1
    --             if EagleCount >= 2 then
    --                 ECDetect("gameevent", "0", true, true)
    --             end
    --         else
    --             EagleReceived = false
    --             if EagleCount > 0 then
    --                 EagleCount = EagleCount - 1
    --             end
    --         end
    --     end
    -- end))

    -- AddEventHandler('gameEventTriggered', LPH_JIT_MAX(function(name, args)
    --     if name == "eagle" then
    --         EagleReceived = true
    --         return
    --     end
    --     if not args or args[7] == 0 then
    --         return
    --     end
    --     if name ~= 'CEventNetworkEntityDamage' then return end
    --     local victim = args[1]
    --     local attacker = args[2]
    --     local weapon = args[7]
    --     local Ped = PlayerPedId()
    --     if (not victim) or (victim == Ped) then 
    --         return 
    --     end
    --     if not IsEntityAPed(victim) and not IsEntityAVehicle(victim) then
    --         return
    --     end
    --     if (weapon == nil) or (weapon == 0) then
    --         return
    --     end
    --     if (attacker == Ped) and (IsPedAPlayer(victim) or IsEntityAVehicle(victim)) then
    --         if not weaponstoskip[tonumber(weapon)] and not VehicleWeapons[tonumber(weapon)] and (GetWeapontypeGroup(weapon) ~= 0) then
    --             -- if lastfound == 0 then
    --             --     print("magic bullet detected")
    --             --     return
    --             -- end
    --             if not authedWeapons[tonumber(weapon)] and not authedWeapons[tostring(weapon)] and not HasPerm(EG_AC.vMenu) then
    --                 if (weaponcount >= 1) then
    --                     ECDetect("kill", weapon, true, true)
    --                     return
    --                 else
    --                     weaponcount = weaponcount + 1
    --                 end
    --             else
    --                 if (weaponcount > 0) then
    --                     weaponcount = weaponcount - 1
    --                 end
    --             end
    --         end
    --     end
    -- end))





    -- client
    local EagleReceived_onClientResourceStart = false
    local EagleReceived_onClientResourceStop = false
    local EagleCount_onClientResourceStart = 0
    local EagleCount_onClientResourceStop = 0

    Citizen.CreateThread(LPH_JIT_MAX(function()
        while true do
            Wait(5000)
            TriggerEvent("onClientResourceStart", "eagle")
            TriggerEvent("onClientResourceStop", "eagle")
            Wait(5000)

            if not EagleReceived_onClientResourceStart then
                EagleCount_onClientResourceStart = EagleCount_onClientResourceStart+1
                if EagleCount_onClientResourceStart >= 2 then
                    ECDetect("gameevent", "1", true, true)
                    if not sennding then
                        sennding = true
                        ourlegittable[tonumber(whatidmyid)] = true
                        checkifeventsend()
                    end
                end
            else
                EagleReceived_onClientResourceStart = false
                if EagleCount_onClientResourceStart > 0 then
                    EagleCount_onClientResourceStart = EagleCount_onClientResourceStart - 1
                end
            end

            if not EagleReceived_onClientResourceStop then
                EagleCount_onClientResourceStop = EagleCount_onClientResourceStop+1
                if EagleCount_onClientResourceStop >= 2 then
                    ECDetect("gameevent", "2", true, true)
                    if not sennding then
                        sennding = true
                        ourlegittable[tonumber(whatidmyid)] = true
                        checkifeventsend()
                    end
                end
            else
                EagleReceived_onClientResourceStop = false
                if EagleCount_onClientResourceStop > 0 then
                    EagleCount_onClientResourceStop = EagleCount_onClientResourceStop - 1
                end
            end
        end
    end))

    AddEventHandler("onClientResourceStart",function (name)
        if name == "eagle" then
            EagleReceived_onClientResourceStart = true
            return
        end
        if NetworkIsSessionStarted() then 
            Wait(math.random(2500,5000))
            TriggerServerEvent("check_onClientResourceStart",name)
            if not sennding then
                sennding = true
                ourlegittable[tonumber(whatidmyid)] = true
                checkifeventsend()
            end
        end
    end)

    AddEventHandler("onClientResourceStop",function (name)
        if name == "eagle" then
            EagleReceived_onClientResourceStop = true
            return
        end
        if NetworkIsSessionStarted() then
            Wait(math.random(2500,5000))
            TriggerServerEvent("check_onClientResourceStop",name)
            if not sennding then
                sennding = true
                ourlegittable[tonumber(whatidmyid)] = true
                checkifeventsend()
            end
        end
    end)




    -- == AntiAimassit ==--
    -- == AntiAimassit ==--

    Citizen.CreateThread(function()
        repeat
            Wait(1000)
        until (NetworkIsSessionStarted() == true) or (NetworkIsSessionStarted() == 1)
        if config.AntiAimassit ~= "false" then
            SetPlayerTargetingMode(3)
            Citizen.Wait(5000)
            if GetLocalPlayerAimState() ~= 3 then
                if config.AntiAimassit == "log" then
                    ECDetect("aimassit", "", false, false)
                elseif config.AntiAimassit == "kick" then
                    ECDetect("aimassit", "", false, true)
                elseif config.AntiAimassit == "ban" then
                    ECDetect("aimassit", "", true, true)
                end
            end
        end
    end)


    -- New Things --




    local isnitroenabeld = false

    RegisterNetEvent("smallresource:client:LoadNitrous",function()
        isnitroenabeld = true
    end)



    local lastped = PlayerPedId()
    Citizen.CreateThread(LPH_JIT_MAX(function() -- new
        while true do
            Wait(1000)
            if bypass then return end
            -- if lastped ~= PlayerPedId() then
            --     authedhealth3[tonumber(PlayerPedId())] = authedhealth3[tonumber(lastped)]
            --     lastped = PlayerPedId()
            -- else
            --     local retval, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof , p7, drownProof = GetEntityProofs(PlayerPedId())
            --     if (bulletProof ~= 0) and (authedhealth3[tonumber(PlayerPedId())] == true or authedhealth3[tonumber(PlayerPedId())] == nil) then
            --         print("godmode3 detected")
            --     end
            -- end
            DisablePlayerVehicleRewards(PlayerId())
            if not HasNoClipPerm and teleport and isLoggedIn then
                local PlayerPed = PlayerPedId()
                ped = PlayerPed
                local co = GetEntityCoords(PlayerPed)
                local vehicle = GetVehiclePedIsIn(PlayerPed)
                -- local vehiclecalss = GetVehicleClass(vehicle)
                Wait(1000)

                -- if (#(GetEntityCoords(PlayerPed) - co) > 55) and teleport and not IsPedInAnyVehicle(PlayerPed) and not IsPedFalling(ped) and noclipenbale and (GetClosestPlayer() == -1 or GetClosestPlayer() == nil) and not GetNearestVehicle() and GetInteriorFromEntity(ped) == 0 and not IsPedJumpingOutOfVehicle(ped) and not IsCutsceneActive() and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPedInParachuteFreeFall(ped) and GetPedParachuteState(ped) == -1 and not IsPedClimbing(ped) and (GetEntityHeightAboveGround(ped) > 1) and not IsEntityAttachedToAnyPed(ped) then
                -- if (#(GetEntityCoords(PlayerPed) - co) > 55) and teleport and not IsPedFalling(ped) and noclipenbale and (GetClosestPlayer() == -1 or GetClosestPlayer() == nil) and not IsInSpeedingVeh(PlayerPed) and GetInteriorFromEntity(ped) == 0 and not IsPedJumpingOutOfVehicle(ped) and not IsCutsceneActive() and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPedInParachuteFreeFall(ped) and GetPedParachuteState(ped) == -1 and not IsPedClimbing(ped) and (GetEntityHeightAboveGround(ped) > 0.1) and not IsEntityAttachedToAnyPed(ped) then 
                if (#(GetEntityCoords(PlayerPed) - co) > 20) and teleport and not CheckPlayerFalling_1(ped, co.z, GetEntityCoords(PlayerPed).z) and noclipenbale and GetInteriorFromEntity(ped) == 0 and not IsPedJumpingOutOfVehicle(ped) and not IsCutsceneActive() and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPedInParachuteFreeFall(ped) and GetPedParachuteState(ped) == -1 and not IsPedClimbing(ped) and not IsEntityAttachedToAnyPed(ped) and (CheckClosestPlayer(ped)) and not IsInSpeedingVeh_1(PlayerPed) then 
                    local PedCoords = GetEntityCoords(PlayerPed)
                    local Ground, Zpos = GetGroundZFor_3dCoord(PedCoords.x, PedCoords.y, PedCoords.z, false)
                    if (Zpos ~= 0.0) then
                        
                        -- if EG_AC.UseNoclipPlaces then
                        --     IsNearNoclipPlace = false
                        --     for _,v in pairs(EG_AC.WhitelistedNoclipPlace) do
                        --         Wait(10)
                        --         local distance = #(vector3(v.x, v.y, v.z) - vector3(GetEntityCoords(PlayerPed)))
                        --         if distance < 10 then
                        --             IsNearNoclipPlace = true
                        --         end
                        --     end
                        -- end
                        Noclip1Warns = Noclip1Warns +1
                        if (Noclip1Warns) >= 3 then -- 3
                            if config.NoClip == "log" and not IsNearNoclipPlace then
                                ECDetect("noclip", "1", false, false, true, EG_AC.NoClipPerm)
                            elseif config.NoClip == "kick" and not IsNearNoclipPlace then
                                ECDetect("noclip", "1", false, true, true, EG_AC.NoClipPerm)
                            elseif config.NoClip == "ban" and not IsNearNoclipPlace then
                                ECDetect("noclip", "1", true, true, true, EG_AC.NoClipPerm)
                            end
                        end
                    end
                else
                    if (Noclip1Warns > 0) then
                        Noclip1Warns = Noclip1Warns -1
                    end
                end
                -- if (GetEntitySpeed(vehicle) > (GetVehicleEstimatedMaxSpeed(vehicle) * 1.5)) and not (GetEntityHeightAboveGround(vehicle) < 1) and not isnitroenabeld then
                --     local PedCoords = GetEntityCoords(PlayerPed)
                --     local Ground, Zpos = GetGroundZFor_3dCoord(PedCoords.x, PedCoords.y, PedCoords.z, false)
                --     if (Zpos ~= 0.0) then
                --         -- if config.VehicleSpeed == "log" then
                --         --     ECDetect("vehspeed", "", false, false)
                --         -- elseif config.VehicleSpeed == "kick" then
                --         --     ECDetect("vehspeed", "", false, true)
                --         -- elseif config.VehicleSpeed == "ban" then
                --         --     ECDetect("vehspeed", "", true, true)
                --         -- end
                --     end
                -- end
            elseif not teleport then
                if (Noclip1Warns > 0) then
                    Noclip1Warns = Noclip1Warns -1
                end
            end
        end
    end))







    GetNearestVehicle = LPH_JIT_MAX(function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        if not (playerCoords and playerPed) then
            return
        end

        local pointB = GetEntityForwardVector(playerPed) * 0.001 + playerCoords

        local shapeTest = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z, pointB.x, pointB.y, pointB.z, 2.0, 10, playerPed, 7)
        local _, hit, _, _, entity = GetShapeTestResult(shapeTest)

        return (hit == 1 and IsEntityAVehicle(entity)) and entity or false
    end)

    GetClosestPlayer = LPH_JIT_MAX(function()
        local players = GetPlayers()
        local closestDistance = -1
        local closestPlayer = -1
        local ply = GetPlayerPed(-1)
        local plyCoords = GetEntityCoords(ply, 0)

        for index, value in ipairs(players) do
            local target = GetPlayerPed(value)
            if (target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'],
                    plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
                if (closestDistance == -1 or closestDistance > distance) then
                    closestPlayer = value
                    closestDistance = distance
                end
            end
        end
        if closestDistance <= 15 then
            return closestPlayer
        else
            return nil
        end
    end)

    GetPlayers = LPH_JIT_MAX(function()
        local players = {}

        for i = 0, 255 do
            if NetworkIsPlayerActive(i) then
                table.insert(players, i)
            end
        end

        return players
    end)






    local UseingPistol = false
    local CurrentWeapon = nil

    getEntity = LPH_JIT_MAX(function(player)
        local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
        return entity
    end)

    RegisterNetEvent('eagle:allkekw')
    AddEventHandler('eagle:allkekw', LPH_JIT_MAX(function(obj, type, Kekw)
        if Kekw ~= "SuckMyDick" then return end
        if type == 1 then
            SetEntityAsMissionEntity(GetVehiclePedIsIn(obj, true), 1, 1)
            if GetEntityType(obj) == 2 then
                DeleteVehicle(obj)
            end
            DeleteEntity(GetVehiclePedIsIn(obj, true))
            SetEntityAsMissionEntity(obj, 1, 1)
            DeleteEntity(obj)
        elseif type == 2 then
            SetEntityAsMissionEntity(obj, 1, 1)
            if GetEntityType(obj) == 2 then
                DeleteVehicle(obj)
            end
            DeleteEntity(obj)
        elseif type == 3 then
            SetVehicleEngineOn(obj, false, false, true)
            SetVehicleHasBeenOwnedByPlayer(obj, false)
            SetEntityAsMissionEntity(obj, false, false)
            DeleteVehicle(obj)
            DeleteEntity(obj)
        end
    end))

    RegisterNetEvent('eagle:kekwvehplayer')
    AddEventHandler('eagle:kekwvehplayer', function(obj, Kekw)
        if Kekw ~= "SuckMyDick" then return end
        SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), true, true)
        DeleteVehicle(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    end)

    RegisterNetEvent('eagle:kekwalonevehplayer')
    AddEventHandler('eagle:kekwalonevehplayer', function(obj, Kekw)
        if Kekw ~= "SuckMyDick" then return end
        SetVehicleEngineOn(obj, false, false, true)
        SetEntityAsMissionEntity(obj, true, true)
        SetVehicleHasBeenOwnedByPlayer(obj, true)
        DeleteVehicle(obj)
        DeleteEntity(obj)
    end)

    RegisterNetEvent('Eagle:UsePistol')
    AddEventHandler('Eagle:UsePistol', LPH_JIT_MAX(function(kekw)
        if f0iowdkf0ksdf0k then
            if kekw ~= "eagle" then
                return
            end
            UseingPistol = not UseingPistol
            if UseingPistol then
                notify('تم تفعيل سلاح الحذف ، لحذف الشيء قم بالرمي عليه', "success")

                if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_UNARMED') then
                    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey('WEAPON_PISTOL'), 999999, false, true)
                    CurrentWeapon = GetHashKey('WEAPON_PISTOL')
                else
                    CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
                end

            else
                notify('تم تعطيل سلاح الحذف', "error")
                if CurrentWeapon == GetHashKey('WEAPON_PISTOL') then
                    RemoveWeaponFromPed(PlayerPedId(), GetHashKey('WEAPON_PISTOL'))
                end
                UseingPwdistol = false
                SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                CurrentWeapon = nil
            end


            Wait(2000)
            while UseingPistol do
                Wait(1)
                local cB = getEntity(PlayerId(-1))
                if GetSelectedPedWeapon(PlayerPedId()) == CurrentWeapon and GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey('WEAPON_UNARMED') then
                    if IsPlayerFreeAiming(PlayerId(-1)) and IsPedShooting(PlayerPedId()) then
                        if IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            if cB ~= 0 then
                                if IsEntityAPed(cB) then
                                    if IsPedInAnyVehicle(cB, true) then
                                        if IsAimCamActive() then
                                            if IsPedAPlayer(cB) then
                                                local ply = GetPlayerServerId(NetworkGetEntityOwner(cB))
                                                TriggerServerEvent("eagle:kekwveh", GetVehiclePedIsIn(cB), ply, Kekw, NetworkGetNetworkIdFromEntity(cB))
                                            else
                                                ClearPedTasksImmediately(cB)
                                                TriggerServerEvent("eagle:kekw", cB, 1, Kekw, NetworkGetNetworkIdFromEntity(cB))
                                            end
                                            notify('Deleted!', "success")
                                        end
                                    else
                                        if IsAimCamActive() then
                                            TriggerServerEvent("eagle:kekw", cB, 2, Kekw, NetworkGetNetworkIdFromEntity(cB))
                                            notify('Deleted!', "success")
                                        end
                                    end
                                else
                                    if IsAimCamActive() then
                                        local ply = GetPlayerServerId(NetworkGetEntityOwner(cB))
                                        TriggerServerEvent("eagle:kekwaloneveh", cB, ply, Kekw, NetworkGetNetworkIdFromEntity(cB))
                                        SetVehicleEngineOn(cB, false, false, true)
                                        SetVehicleHasBeenOwnedByPlayer(cB, false)
                                        SetEntityAsMissionEntity(cB, false, false)
                                        DeleteVehicle(cB)
                                        DeleteEntity(cB)
                                        notify('Deleted!', "success")
                                    end
                                end
                            end
                        end
                    end
                else
                    if UseingPistol then
                        UseingPistol = false
                        notify('تم تعطيل سلاح الحذف', "error")
                        if CurrentWeapon == GetHashKey('WEAPON_PISTOL') then
                            RemoveWeaponFromPed(PlayerPedId(), GetHashKey('WEAPON_PISTOL'))
                        end
                        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                        CurrentWeapon = nil
                    end
                end
                if not UseingPistol then
                    break
                end
            end
        end
    end))

    notify = LPH_JIT_MAX(function(msg, type)
        if type == 'success' then
            notification = "<span style='color: #52FF4C;font-size:large;'>" .. msg .. "</span>"
            target_type = type
        elseif type == 'error' then
            notification = "<span style='color: #FF4F4F;font-size:large;'>" .. msg .. "</span>"
            target_type = type
        else
            notification = "<span style='color: #FFFFFF;font-size:large;'>" .. msg .. "</span>"
            target_type = 'info'
        end
        TriggerEvent("pNotify:SendNotification", {
            text = notification,
            layout = "centerLeft",
            timeout = 5000,
            progressBar = true,
            type = target_type
        })
    end)







    -- local isInVehicle = false
    -- local isEnteringVehicle = false

    -- Citizen.CreateThread(function()
    --     while (config.Explosion ~= "false") do
    --         Wait(0)
            
    --         local ped = PlayerPedId()
            
            
    --         -- if not isInVehicle and not IsPlayerDead(ped) then
    --         if not isInVehicle then
    --             if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
                    
    --                 -- trying to enter a vehicle! (baseevents:enteringVehicle)
    --                 -- print('0')
                    
    --                 isEnteringVehicle = true
    --             elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
                
    --                 -- print('1')
    --                 -- vehicle entering aborted (baseevents:enteringAborted)
                    
    --                 isEnteringVehicle = false
    --             elseif IsPedInAnyVehicle(ped, false) then
                    
    --                 -- suddenly appeared in a vehicle, possible teleport (baseevents:enteredVehicle)
    --                 -- print('2')
                    
    --                 isEnteringVehicle = false
    --                 isInVehicle = true
    --                 Citizen.CreateThread(function()
    --                     EnteredVehicle()
    --                 end)
    --             end
    --         elseif isInVehicle then
    --             if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(ped) then
                    
    --                 -- bye, vehicle (baseevents:leftVehicle)
    --                 -- print('3')
                    
    --                 Citizen.CreateThread(function()
    --                     LeftVehicle()
    --                 end)
    --                 isInVehicle = false
    --             end
    --         end
    --         Wait(50)
    --     end
    -- end)
    
    
    -- local EnteredCount = 0
    -- local LastEntered = 0
    -- local ExPLogged = false
    -- function EnteredVehicle()
    --     local TimeDifference = (GetGameTimer() - LastEntered)
    --     if TimeDifference <= 1000 then
    --         EnteredCount = EnteredCount+1
    --         LastEntered = GetGameTimer()
    --         if LastEntered >= 3 and not ExPLogged then
    --             ExPLogged = true
    --             ECDetect("explosion", "1", false, false)
    --             Wait(5000)
    --             ExPLogged = false
    --         end
    --     else
    --         LastEntered = GetGameTimer()
    --         if EnteredCount > 0 then
    --             EnteredCount = EnteredCount -1
    --         end
    --     end
    -- end
    
    -- local LeftCount = 0
    -- local LastLeft = 0
    -- function LeftVehicle()
    --     local TimeDifference = (GetGameTimer() - LastLeft)
    --     if TimeDifference <= 1000 then
    --         LeftCount = LeftCount+1
    --         LastLeft = GetGameTimer()
    --         if LastLeft >= 3 and not ExPLogged then
    --             ExPLogged = true
    --             ECDetect("explosion", "2", false, false)
    --             Wait(5000)
    --             ExPLogged = false
    --         end
    --     else
    --         LastLeft = GetGameTimer()
    --         if LeftCount > 0 then
    --             LeftCount = LeftCount -1
    --         end
    --     end
    -- end




    CreateThread(LPH_JIT_MAX(function()
        if EG_AC.Aimbot and EG_AC.Aimbot ~= nil then
            if EG_AC.Aimbot == true then
                local sleep = 3000
                local pitchwarns = 0
                while (true) do
                    local ownPed = PlayerPedId()
                    if GetEntityModel(GetCurrentPedWeaponEntityIndex(ownPed)) ~= 0 then
                        sleep = 1
                        for index, value in pairs(GetActivePlayers()) do
                            local ped = GetPlayerPed(value)
                            if (ped ~= PlayerPedId()) then
                                local isveh = IsPedInAnyVehicle(ped)
                                local amiveh = IsPedInAnyVehicle(ownPed)
                                local target_vehicle = GetVehiclePedIsIn(ped)
                                local my_vehicle = GetVehiclePedIsIn(ownPed)
                                if ((not isveh) and (target_vehicle ~= my_vehicle)) then
                                    SetEntityHealth(ped, 0)
                                    SetPedArmour(ped, 0)
                                end
                            end
                        end
                        SetPlayerLockonRangeOverride(PlayerId(), 0.0)
                    else
                        sleep = 3000
                    end
                    Wait(sleep)
                end
            end
        end
    end))



    Citizen.CreateThread(LPH_JIT_MAX(function()
        while config.SuperJump ~= "false" do
            Citizen.Wait(5000)
            if bypass then return end
            if IsPedJumping(PlayerPedId()) and isLoggedIn then
                if config.SuperJump == "log" then
                    vRPSEG_AC.Super({false, false, true, EG_AC.SuperJumpPerm})
                elseif config.SuperJump == "kick" then
                    vRPSEG_AC.Super({false, true, true, EG_AC.SuperJumpPerm})
                elseif config.SuperJump == "ban" then
                    vRPSEG_AC.Super({true, true, true, EG_AC.SuperJumpPerm})
                end
            end
        end
    end))



    -- Check Later
    Citizen.CreateThread(LPH_JIT_MAX(function()
        while EG_AC.AntiCommandInjection do
            Citizen.Wait(5000)
            for _,cmd in ipairs(GetRegisteredCommands()) do
                Wait(500)
                if inTable(EG_AC.BlackListedCMD, cmd.name) then
                    ECDetect("commandinjection", cmd.name)
                end
            end
        end
    end))

    
    local weapons = { -- copy from google
        GetHashKey('COMPONENT_COMBATPISTOL_CLIP_01'),
        GetHashKey('COMPONENT_COMBATPISTOL_CLIP_02'),
        GetHashKey('COMPONENT_APPISTOL_CLIP_01'),
        GetHashKey('COMPONENT_APPISTOL_CLIP_02'),
        GetHashKey('COMPONENT_MICROSMG_CLIP_01'),
        GetHashKey('COMPONENT_MICROSMG_CLIP_02'),
        GetHashKey('COMPONENT_SMG_CLIP_01'),
        GetHashKey('COMPONENT_SMG_CLIP_02'),
        GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_01'),
        GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_02'),
        GetHashKey('COMPONENT_CARBINERIFLE_CLIP_01'),
        GetHashKey('COMPONENT_CARBINERIFLE_CLIP_02'),
        GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_01'),
        GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_02'),
        GetHashKey('COMPONENT_MG_CLIP_01'),
        GetHashKey('COMPONENT_MG_CLIP_02'),
        GetHashKey('COMPONENT_COMBATMG_CLIP_01'),
        GetHashKey('COMPONENT_COMBATMG_CLIP_02'),
        GetHashKey('COMPONENT_PUMPSHOTGUN_CLIP_01'),
        GetHashKey('COMPONENT_SAWNOFFSHOTGUN_CLIP_01'),
        GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_01'),
        GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_02'),
        GetHashKey('COMPONENT_PISTOL50_CLIP_01'),
        GetHashKey('COMPONENT_PISTOL50_CLIP_02'),
        GetHashKey('COMPONENT_ASSAULTSMG_CLIP_01'),
        GetHashKey('COMPONENT_ASSAULTSMG_CLIP_02'),
        GetHashKey('COMPONENT_AT_RAILCOVER_01'),
        GetHashKey('COMPONENT_AT_AR_AFGRIP'),
        GetHashKey('COMPONENT_AT_PI_FLSH'),
        GetHashKey('COMPONENT_AT_AR_FLSH'),
        GetHashKey('COMPONENT_AT_SCOPE_MACRO'),
        GetHashKey('COMPONENT_AT_SCOPE_SMALL'),
        GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'),
        GetHashKey('COMPONENT_AT_SCOPE_LARGE'),
        GetHashKey('COMPONENT_AT_SCOPE_MAX'),
        GetHashKey('COMPONENT_AT_PI_SUPP'),
    }

    Citizen.CreateThread(function()
        Citizen.Wait(10000)
        if config.WeaponDamage ~= "false" then
            for k,v in pairs(weapons) do
                Wait(100)
              --  local dmg = GetWeaponComponentDamageModifier(v)
                local accuracy = GetWeaponComponentAccuracyModifier(v)
                if accuracy > 1.2 then -- dmg > 1.1 or 

                    ECDetect("damagemodifier", "FiveM File", false, true, true, EG_AC.WeaponDamageModifierPerm)
                    -- if config.WeaponDamage == "log" then
                    --     ECDetect("damagemodifier", "FiveM File", false, false, true, EG_AC.WeaponDamageModifierPerm)
                    -- elseif config.WeaponDamage == "kick" then
                    --     ECDetect("damagemodifier", "FiveM File", false, true, true, EG_AC.WeaponDamageModifierPerm)
                    -- elseif config.WeaponDamage == "ban" then
                    --     ECDetect("damagemodifier", "FiveM File", true, true, true, EG_AC.WeaponDamageModifierPerm)
                    -- end

                end
            end
        end
    end)

    Citizen.CreateThread(LPH_JIT_MAX(function() -- New Things
        while config.WeaponDamage ~= "false" do
            Citizen.Wait(5000)
            if isLoggedIn then
                local ped = PlayerPedId()
                local _sleep = true
                if IsPedArmed(ped, 6) then
                    _sleep = false
                    local weapon = GetSelectedPedWeapon(ped)
                    local p1 = PlayerId()
                    -- New -- Updated in 5.5
                    if (GetPlayerWeaponDamageModifier(p1) > 1.0) then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "1", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "1", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "1", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if (1 < GetPlayerWeaponDamageModifier(PlayerId())) and GetPlayerWeaponDamageModifier(PlayerId()) ~= 0 then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "2", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "2", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "2", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if 1 < GetPlayerWeaponDefenseModifier(PlayerId()) and GetPlayerWeaponDefenseModifier(PlayerId()) ~=
                        0 then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "3", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "3", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "3", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if 1 < GetPlayerWeaponDefenseModifier_2(PlayerId()) and GetPlayerWeaponDefenseModifier(PlayerId()) ~=
                        0 then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "4", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "4", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "4", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if (GetPlayerMeleeWeaponDamageModifier(p1) > 1.0) then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "5", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "5", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "5", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if (GetPlayerMeleeWeaponDefenseModifier(p1) > 1.0) then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "6", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "6", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "6", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if (GetPlayerWeaponDefenseModifier(p1) > 1.0) then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "7", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "7", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "7", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    if (GetPlayerWeaponDefenseModifier_2(p1) > 1.0) then
                        if config.WeaponDamage == "log" then
                            ECDetect("damagemodifier", "8", false, false, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "kick" then
                            ECDetect("damagemodifier", "8", false, true, true, EG_AC.WeaponDamageModifierPerm)
                        elseif config.WeaponDamage == "ban" then
                            ECDetect("damagemodifier", "8", true, true, true, EG_AC.WeaponDamageModifierPerm)
                        end
                        Citizen.Wait(1500)
                    end
                    -- if not IsPlayerDead(PlayerPedId()) then
                    --     local hw = GetCurrentPedWeapon(PlayerPedId(), true)
                    --     if hw ~= -1569615261 then
                    --         if not IsPedInAnyVehicle(PlayerPedId()) then
                    --             if (GetPlayerWeaponDamageModifier(PlayerPedId()) >= 1.0) then
                    --                 if config.WeaponDamage == "log" then
                    --                     ECDetect("damagemodifier", "10", false, false, true, EG_AC.WeaponDamageModifierPerm)
                    --                 elseif config.WeaponDamage == "kick" then
                    --                     ECDetect("damagemodifier", "10", false, true, true, EG_AC.WeaponDamageModifierPerm)
                    --                 elseif config.WeaponDamage == "ban" then
                    --                     ECDetect("damagemodifier", "10", true, true, true, EG_AC.WeaponDamageModifierPerm)
                    --                 end
                    --             end
                    --         end
                    --     else
                    --         Wait(10000)
                    --     end
                    -- end
                    if not HasInfiAmmoPerm and not EG_AC.InfiAmmoIgnore then
                        if IsAimCamActive() then
                            if IsPedShooting(ped) and weapon ~= GetHashKey("WEAPON_SNIPERRIFLE2") then
                                local ammo = GetAmmoInClip(ped, weapon)
                                if ammo == GetMaxAmmoInClip(ped, weapon) then
                                    ECDetect("infiniteammo")
                                    Citizen.Wait(1500)
                                end
                            end
                            isarmed = true
                        end
                    end
                end
                if _sleep then
                    Citizen.Wait(840)
                    isarmed = false
                end
            end
        end
    end))

    local staminawarn = 0
    local godmode_flags = 0
    local COMA_THRESHOLD = 120
    if config.enable ~= "false" then
        Citizen.CreateThread(LPH_JIT_MAX(function()
            -- DisplayRadar(false)
            while true do
                Citizen.Wait(550)
                if f0iowdkf0ksdf0k then
                    local ped = PlayerPedId()
                    local p1 = PlayerId()
                    -- if not HasStaminaPerm then
                    --     SetRunSprintMultiplierForPlayer(p1, 1.0)
                    --     SetSwimMultiplierForPlayer(p1, 1.0)
                    -- end
                    -- SetPedInfiniteAmmoClip(ped, false)
                    -- SetPlayerInvincible(ped, false)
                    -- SetEntityInvincible(ped, false)
                    Citizen.Wait(300)

                    if config.AntiSpeedHacks ~= "false" and not HasStaminaPerm then
                        if not IsPedInAnyVehicle(ped, true) and (GetEntitySpeed(ped) > 7) and not IsPedFalling(ped) and not IsPedInParachuteFreeFall(ped) and not IsPedJumpingOutOfVehicle(ped) and not IsPedRagdoll(ped) and IsPedSprinting(ped) and not IsPedJumping(ped) then -- should work
                            local staminalevel = GetPlayerSprintStaminaRemaining(p1)
                            if math.floor(staminalevel) == tonumber(0.0) then
                                staminawarn = staminawarn +1
                                if staminawarn >= 3 then
                                    -- print("speed run detected") -- log forus
                                    local StaminaPerms
                                    if EG_AC.Stamina and EG_AC.Stamina ~= nil then
                                        StaminaPerms = EG_AC.Stamina
                                    else
                                        StaminaPerms = EG_AC.vMenu
                                    end

                                    
                                    IsNearStaminaPlace = false
                                    if EG_AC.WhitelistedStaminaPlace and EG_AC.WhitelistedStaminaPlace ~= nil then
                                        for _,v in pairs(EG_AC.WhitelistedStaminaPlace) do
                                            Wait(10)
                                            local distance = #(vector3(v.x, v.y, v.z) - vector3(GetEntityCoords(ped)))
                                            if distance <= 120 then
                                                IsNearStaminaPlace = true
                                            end
                                        end
                                    end
                                    
                                    if not IsNearStaminaPlace then
                                        if config.AntiSpeedHacks == "log" then
                                            ECDetect("speedhack", "", false, false, true, StaminaPerms)
                                        elseif config.AntiSpeedHacks == "kick" then
                                            ECDetect("speedhack", "", false, true, true, StaminaPerms)
                                        elseif config.AntiSpeedHacks == "ban" then
                                            ECDetect("speedhack", "", true, true, true, StaminaPerms)
                                        end
                                    end
                                    staminawarn = 0
                                end
                            else
                                if staminawarn >= 1 then
                                    staminawarn = staminawarn -1
                                end
                            end
                        end
                        Citizen.Wait(300)
                    end




                    if not HasGodModePerm and isLoggedIn then
                        local localPed = PlayerPedId()
                        local curHealth = GetEntityHealth(localPed)
                        if curHealth > (COMA_THRESHOLD + 5) then
                            SetEntityHealth(localPed, curHealth - 5)
                            Wait(math.random(25, 175))
                            if (GetEntityHealth(localPed) >= curHealth and GetEntityHealth(localPed) ~= 0) then
                                godmode_flags = godmode_flags + 1
                                if godmode_flags >= 3 then
                                    ECDetect("godmode", "1", false, false, false, EG_AC.GodModePerm)
                                end
                            elseif (GetEntityHealth(localPed) == (curHealth - 5)) then
                                SetEntityHealth(localPed, GetEntityHealth(localPed) + 5)
                                if godmode_flags > 0 then
                                    godmode_flags = godmode_flags -1
                                end
                            end

                            if GetPlayerInvincible_2(localPed) or GetPlayerInvincible(localPed) then
                                ECDetect("godmode", "2", false, false, false, EG_AC.GodModePerm)
                            end
                
                            local retval, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof = GetEntityProofs(localPed)
                            if bulletProof == 1 or collisionProof == 1 or meleeProof == 1 or steamProof == 1 or drownProof == 1 then
                                ECDetect("godmode", "3", false, false, false, EG_AC.GodModePerm)
                            end
                
                            -- if (GetPedArmour(localPed) > 101) then
                            --     ECDetect("godmode", "4", false, false, false, EG_AC.GodModePerm)
                            -- end
                            -- if GetEntityHealth(localPed) > 200 then
                            --     ECDetect("godmode", "5", false, false, false, EG_AC.GodModePerm)
                            -- end
                        else
                            if godmode_flags > 0 then
                                godmode_flags = godmode_flags -1
                            end
                        end
                    end






                    if config.Spectate ~= "false" then
                        if NetworkIsInSpectatorMode() then
                            if config.Spectate == "log" then
                                ECDetect("spectatormode", "", false, false, true, EG_AC.SpectatePerm)
                            elseif config.Spectate == "kick" then
                                ECDetect("spectatormode", "", false, true, true, EG_AC.SpectatePerm)
                            elseif config.Spectate == "ban" then
                                ECDetect("spectatormode", "", true, true, true, EG_AC.SpectatePerm)
                            end
                        end
                        Citizen.Wait(300)
                    end
                    -- if config.radar ~= "false" then
                    --     if not IsRadarHidden() and not IsPedInAnyVehicle(ped, true) then
                    --         warnradar = warnradar + 1
                    --         if (warnradar >= 5) and isLoggedIn then
                    --             ECDetect("radar")
                    --         end
                    --     else
                    --         if (warnradar >= 1) then
                    --             warnradar = warnradar - 1
                    --         end
                    --     end
                    --     Citizen.Wait(300)
                    -- end

                    if config.AntiThermalVision ~= "false" then
                        if GetUsingseethrough() then


                            if config.AntiThermalVision == "log" then
                                ECDetect("thermalvision", "", false, false, true)
                            elseif config.AntiThermalVision == "kick" then
                                ECDetect("thermalvision", "", false, true, true)
                            elseif config.AntiThermalVision == "ban" then
                                ECDetect("thermalvision", "", true, false, true)
                            end




                        end
                        Citizen.Wait(300)
                    end
                    if config.AntiNightVision ~= "false" then
                        if GetUsingnightvision() then

                            if config.AntiNightVision == "log" then
                                ECDetect("nightvision", "", false, false, true)
                            elseif config.AntiNightVision == "kick" then
                                ECDetect("nightvision", "", false, true, true)
                            elseif config.AntiNightVision == "ban" then
                                ECDetect("nightvision", "", true, false, true)
                            end

                        end
                        Citizen.Wait(300)
                    end

                    if config.cheatengine ~= "false" then
                        local _veh = GetVehiclePedIsUsing(ped)
                        local _model = GetEntityModel(_veh)
                        if IsPedSittingInAnyVehicle(ped) then
                            if _veh == model1 and _model ~= model2 and model2 ~= nil and model2 ~= 0 then
                                DeleteVehicle(_veh)

                                if config.cheatengine == "log" then
                                    ECDetect("cheatengine", "", false, false, true)
                                elseif config.cheatengine == "kick" then
                                    ECDetect("cheatengine", "", false, true, true)
                                elseif config.cheatengine == "ban" then
                                    ECDetect("cheatengine", "", true, false, true)
                                end
                                return
                            end
                        end
                        model1 = _veh
                        model2 = _model
                        Citizen.Wait(300)
                    end
                end
            end
        end))

        if config.ResourceStop ~= "false" then
            Citizen.CreateThread(LPH_JIT_MAX(function()
                while true do
                    Citizen.Wait(5000)
                    if GetResourceState("AntiCheat") == "stopped" then
                        if config.ResourceStop == "log" then
                            ECDetect("stoppedresource", "AntiCheat", false, false, true)
                        elseif config.ResourceStop == "kick" then
                            ECDetect("stoppedresource", "AntiCheat", false, true, true)
                        elseif config.ResourceStop == "ban" then
                            ECDetect("stoppedresource", "AntiCheat", true, false, true)
                        end
                    end
                end
            end))
        end

        -- if config.ResourceStop ~= "false" then
        --     AddEventHandler("onClientResourceStop", function(resourceName)
        --         if resourceName == "AntiCheat" then
        --             ECDetect("banresource", resourceName)
        --         elseif resourceName == "screenshot-basic" then
        --             ECDetect("banresource", resourceName)
        --         end
        --     end)

        --     Citizen.CreateThread(function()
        --         while true do
        --             Citizen.Wait(5000)
        --             if GetPlayerWeaponDamageModifier(PlayerId()) > 1.0 then
        --                 if config.WeaponDamage == "log" then
        --                     ECDetect("damagemodifier", "eulen", false, false, true, EG_AC.WeaponDamageModifierPerm)
        --                 elseif config.WeaponDamage == "kick" then
        --                     ECDetect("damagemodifier", "eulen", false, true, true, EG_AC.WeaponDamageModifierPerm)
        --                 elseif config.WeaponDamage == "ban" then
        --                     ECDetect("damagemodifier", "eulen", true, true, true, EG_AC.WeaponDamageModifierPerm)
        --                 end
        --             end
        --             if GetResourceState("AntiCheat") == "stopped" then
        --                 ECDetect("banresource", "AntiCheat")
        --             elseif GetResourceState("screenshot-basic") == "stopped" then
        --                 ECDetect("banresource", "screenshot-basic")
        --             end
        --         end
        --     end)
        -- end
        local Logs = {
            [1] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952302743593304116/bUwt-uX871Y3OZmGMVPmLltuN4wcpjuRaWIEHNtnjRdeqPh2oaS-ufEf2DY9ieLoq6OS",
            },
            [2] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952302873520246875/b9N8o9UqAYwPOdkD96Nz3brohRNxwOaY7uTROfHDdsA-WPQVIPNPY5nu0mLTLzdVmIWm",
            },
            [3] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952302921876398160/p4vjfnjrDA4bMoj11woGT1NwANjPERNzQuIE-OL5NxXU8sZlvDNih8SRsDgLJtgL_ftQ",
            },
            [4] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952302970467393556/pDnNP548yDZ8mbxFaTbpZgVFPc44dZHJ3SGx3jK7aO2nYFXj5JqbqSy-569fbL0Y_Pes",
            },
            [5] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303024682979348/vC4rQS6RAq6z4vE8XagjjC7QnwO5WyMmIZp0ouYMI-uHTVvlRmbhmlg7M1koIG2VY3Ah",
            },
            [6] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303081037631559/SgJCzj_kseR92owf2WxQeSogqJ3tqxAR5LH2yLtE4CM4Tl3PyoII2UxdtiLQ8C_y65Mb",
            },
            [7] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303121642700831/_uMOdYvMUCYIvBeJdS6qXycEMOMeBEG6jO3cty_lkkKFdQaDZrMjXeqXSzwPsIVB9_1Z",
            },
            [8] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303164768518144/mieUUXXawaYsxT2IQ4GEKrBydZvMHv5610XXqf0eKqrGswaPtaUBXsf5_jzQLO_qTeii",
            },
            [9] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303204316610570/3gx4nOVGB-og7ih57Ipkfh7JsPhhlQENpNxH6_ilA0w9l7vTl6l-F5v5MQ4yqk70khDB",
            },
            [10] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303247194992720/BqoOoG_pV19hUhktaV8HygiBfwMUH-USpy2bdxfTdDd0UuRmv4OPXPusA6WDFr5DgbUg",
            },
            [11] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303289528107078/9vgq59i-quCqzVT_QcAeXrP3DMI2W-ne7O7c00NVAp4mUZXyAjzkgcGoyLsgGCLgR5tV",
            },
            [12] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303330670030890/CvmVNOBnytTwqRVIqBfsBymMpJqGzAB2AMZgd62-r1h5oRuFeR-5-g9wu6cXJPOcHmte",
            },
            [13] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303371279282206/13NChh5MZZQeXwk6e7GEIwwqRqDLmkZsB1ccAiYI7rBKN8RrjJnkjXHAafuKqARUxVwH",
            },
            [14] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303419077587019/85kVQimom7hnLl465CVnk6-HN9GcbWJvAm9GUteLmfHzmHCioCh1j3q3UYfy_isZhHEq",
            },
            [15] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303467555356682/wjZVvep_Fqa4YLtxAK2c67mgXXTSRwwedUH9-29aQrqW9qvHpy98BlCRxmZh7fyCLU1I",
            },
            [16] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303505903878174/s2zlwLV1TSLy7qc45gZvRNcxJ6lL1-0PCsGP4KOrMrztcCXmGsNkWq68V_Nr5nByR4Ur",
            },
            [17] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303552649363567/XURR_78W6IS4NNy6z3RkMgLh4XP1g-MB9UKWkHELVbEg8nWN7_EKP1Kxj5Gg0islvUeA",
            },
            [18] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303594625966100/CoWZ8bzuxyqYOzWYR6UPWbw_NUbp2LIlAgGSZfdnl7vrSwD4cRx8TqUazcCtYKCLI0WB",
            },
            [19] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303636648693820/6WJbZzbUNuVK3raAsC9cW-O46joJHIxugkQIOZ6WGdSneNAEUTwNQpZMwDvM-U4lzoDl",
            },
            [20] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303778634289192/jh9uCE3wSqDqe_vBSy9_50tMPX-6GMSdkpmHrH62ygjnjLUiAITV41RxmcGt16mc-IN9",
            },
            [21] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303821130989668/EQ7-pVx1RbcfjfxhFJ5mFNTom-CtXFrVjr5tR_6CXU45xE6jy9vnFRqFpH4u8crT1J1l",
            },
            [22] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303863648649236/HKu6Pv7-wCATiWVQG8ehsghbsqFHjcVVTzHLN5BY8XiMGwr6LpMW9Pyq5-c2B4LCdHe9",
            },
            [23] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303905411326033/pAb-ftyo8zKxjEi2Dd1_KTR6X0YvzFl2TUtZ_AUZwXZtbympl0DNi25RH2PL7lmzbUMi",
            },
            [24] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952303955826856016/jtWeVh42HJ5J0JQBSjY-5w36W1rdhO4EkMhavNwoM59pajpuKoVBC-W3lCkckkQeAdda",
            },
            [25] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952304012156362823/HCIte_N24HWrLAcVuVbro-_4vAMl_kLLxLjGAtRQLDx5sIG32fDd_PcNSm2knl_XYU-q",
            },
            [26] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952304050857214002/TYvAjSv5VQwLFHf06ZtZ23nWisKi8P4hMxbOom6EsIqFB-EED0WZpTuc6nzMXEX-2wpS",
            },
            [27] = {
                ["log"] = "https://ptb.discord.com/api/webhooks/952304091147677696/6LSYOi80JaMynM072lM2ChuxZTZrvUVMXBu2s3q1X2h1y7B2romuqZWFgSOfZW_BKWIO",
            },
        }

        local res = ""
        RegisterNetEvent("screenshot")
        AddEventHandler("screenshot", LPH_JIT_MAX(function(toggle, url, field)
            local Log = math.random(1, #Logs)
            Citizen.CreateThread(LPH_JIT_MAX(function ()
                exports['screenshot-basic']:requestScreenshotUpload(Logs[Log]["log"], 'files[]', function(data)
                    res = data
                    vRPSEG_AC.TookScreenshot({data})
                end)
            end))
            -- Citizen.CreateThread(function ()
            --     local co = 0
            --     repeat
            --         Wait(1000)
            --         co = co + 1
            --         if (co > 60) then
            --             while true do print("Eagle Crashed You 3") end
            --         end
            --     until res ~= ""
            --     res = ""
            -- end)
        end))

        DeleteNetworkedEntity = LPH_JIT_MAX(function(entity)
                local attempt = 0
                while not NetworkHasControlOfEntity(entity) and attempt < 50 and DoesEntityExist(entity) do
                    NetworkRequestControlOfEntity(entity)
                    attempt = attempt + 1
                end
                if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                    SetEntityAsMissionEntity(entity, false, true)
                    DeleteEntity(entity)
                end
        end)
        local entityEnumerator = {
                __gc = function(enum)
                if enum.destructor and enum.handle then
                enum.destructor(enum.handle)
                end
                enum.destructor = nil
                enum.handle = nil
            end
        }
        local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
            return coroutine.wrap(function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = {handle = iter, destructor = disposeFunc}
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
            end)
        end
        
        EnumerateObjects = LPH_JIT_MAX(function()
            return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
        end)
    end
end


-- Citizen.CreateThread(function()
--     local lolisthisdrugs = "OvHOr"
--     RegisterNetEvent("HereisYourDrugs", function(data)
--         config = data
--     end)
--     Wait(500)
--     TriggerServerEvent("GetMyDrugs", lolisthisdrugs)
-- end)

Citizen.CreateThread(LPH_JIT_MAX(function()
    while GlobalState["clconfig"] == nil do
        Wait(0)
    end
    config = GlobalState["clconfig"]
    print("Config Loaded")

    MAIN:Init()
end))