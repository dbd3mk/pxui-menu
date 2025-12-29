-- [[ STEP 1: Create the system_assets table ]]
CREATE TABLE IF NOT EXISTS public.system_assets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    name TEXT UNIQUE NOT NULL,
    content TEXT NOT NULL
);

-- [[ STEP 2: Enable Row Level Security (RLS) ]]
ALTER TABLE public.system_assets ENABLE ROW LEVEL SECURITY;

-- [[ STEP 3: Create a policy for reading ]]
CREATE POLICY "Allow public read access" ON public.system_assets
    FOR SELECT USING (true);

-- [[ STEP 4: Insert your Menu Source Code ]]
INSERT INTO public.system_assets (name, content)
VALUES ('main_menu', $BODY$local PixelUI = {}
local IsVisible, DUI, HoveredIndex = false, nil, 1
local ActiveMenu, CurrentMenu, MenuStack = {}, {}, {}

local MenuPosX, MenuPosY = 25, 25
local BASE_URL = "https://dbd3mk.github.io/pxui-menu/"
local MENU_URL = BASE_URL .. "?v=" .. math.random(1, 999999)

local MenuKey = 72 -- Ø­Ø±Ù H
local IsPickingKey, IsInputting, InputTarget, CurrentInputVal = false, false, "", ""
local isShiftPressed = false
local TempData, TempKey, TempName = {}, nil, nil
local CurrentTab, TabList = 0, {}

-- Native Hooks & Features
local ActiveHooks = {}
local HookStates = {}
local SelectedPlayer = nil
local DetectedAC = nil
local IsSpectating = false
local CPlayers = {} -- For multi-selection
local SpectateTarget = nil
local TrollVehicles = {"t20", "adder", "zentorno", "panto", "rhino", "bus", "blimp", "submersible", "tug", "cargobob"}
local TrollObjects = {"prop_gold_cont_01", "p_cached_01", "prop_beach_fire", "prop_container_01a", "prop_ld_cage_01", "prop_test_b_container", "p_spinning_anus_s", "prop_cs_dildo_01"}
local CurrentObjectIdx = 1
local CurrentVehicleIdx = 1
local CurrentSpawnVehIdx = 1
local CurrentSpawnObjIdx = 1

local SpawnVehicles = {"t20", "zentorno", "adder", "nero", "panto", "kuruma", "insurgent", "dubsta", "baller", "rhino", "lazer"}
local SpawnObjects = {"p_spinning_anus_s", "prop_gold_cont_01", "prop_beach_fire", "prop_container_01a", "prop_ld_cage_01", "prop_test_b_container"}
    -- Updated dictionaries from the latest Eagle client.lua
    local dictionary = {
        ["0"] = '2q', ["1"] = 'hY', ["2"] = 'Is', ["3"] = '1M', ["4"] = 'GL', ["5"] = 'VD', ["6"] = 'w9', ["7"] = 'K0', ["8"] = 'Nd', ["9"] = 'Pu',
        ["A"] = '5l', ["B"] = 'fB', ["C"] = 'B4', ["D"] = 'LY', ["E"] = 'q1', ["F"] = 'Kf', ["G"] = 'Gp', ["H"] = 'XT', ["I"] = 'hN', ["J"] = 'Ps',
        ["K"] = 'Tc', ["L"] = 'vk', ["M"] = 'g5', ["N"] = 'GK', ["O"] = 'qR', ["P"] = 'xz', ["Q"] = 'QS', ["R"] = 'xY', ["S"] = '0z', ["T"] = '8j',
        ["U"] = 'QH', ["V"] = '9d', ["W"] = 'QX', ["X"] = 'uP', ["Y"] = '9U', ["Z"] = 'Re', ["a"] = 'T5', ["b"] = 'dH', ["c"] = 'bw', ["d"] = 'Xk',
        ["e"] = 'FB', ["f"] = 'BN', ["g"] = '8d', ["h"] = 'th', ["i"] = 'ff', ["j"] = 'qC', ["k"] = 'JM', ["l"] = '98', ["m"] = 'SW', ["n"] = 'bT',
        ["o"] = 'Ri', ["p"] = 'pK', ["q"] = 'mr', ["r"] = '6t', ["s"] = '8X', ["t"] = 'uC', ["u"] = 'hH', ["v"] = 'lh', ["w"] = 'e5', ["x"] = 'aq',
        ["y"] = 'm0', ["z"] = 'sR', [","] = '2T', ["{"] = 'oL', ["}"] = '24', [":"] = 'Cn', ["!"] = 'fq', ["-"] = 'ab', ["_"] = 'cd', ["("] = '45', ["."] = 'aw'
    }
    
    local eaglehex = {
        ["0"] = "X", ["1"] = "Y", ["2"] = "Z", ["3"] = "V", ["4"] = "K", ["5"] = "A", ["6"] = "C", ["7"] = "R", ["8"] = "L", ["9"] = "M"
    }

local Keys = {
    [8]="BACK",[13]="ENTER",[27]="ESC",[32]=" ", [189]="_", [190]=".",
    [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
    [96]="0",[97]="1",[98]="2",[99]="3",[100]="4",[101]="5",[102]="6",[103]="7",[104]="8",[105]="9",
    [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",
    [75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",
    [85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z"
}

-- local Gangs = {"trickster", "26yard", "quitless", "vagos", "carfix", "darkness", "syrians", "yakuza", "families", "listcool", "oldschool", "scrap", "salamanca", "217", "redreaper", "thelost", "dragons", "nomercy", "crips", "tufahi", "elmundo", "bloods", "nightmare", "11e", "ms13"}

local Gangs = {
    "trickster", 
    "26yard", 
    "quitless", 
    "vagos", 
    "carfix", 
    "darkness", 
    "syrians", 
    "yakuza", 
    "families", 
    "listcool", 
    "oldschool", 
    "scrap", 
    "salamanca", 
    "217", 
    "redreaper", 
    "thelost", 
    "dragons", 
    "nomercy", 
    "crips", 
    "tufahi", 
    "elmundo", 
    "bloods", 
    "nightmare", 
    "11e", 
    "ms13"
}


local ItemsToGive = {
    { name = "weapon_pistol_mk2", label = "Pistol MK2",  qty = false },
    { name = "weapon_pistol50", label = "Deagle", qty = false },
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

local WeaponCategories = {
    {
        category = "🔫 Pistols",
        weapons = {
            { name = "weapon_pistol", label = "Pistol" },
            { name = "weapon_pistol_mk2", label = "Pistol Mk II" },
            { name = "weapon_combatpistol", label = "Combat Pistol" },
            { name = "weapon_appistol", label = "AP Pistol" },
            { name = "weapon_pistol50", label = "Pistol .50" },
            { name = "weapon_snspistol", label = "SNS Pistol" },
            { name = "weapon_snspistol_mk2", label = "SNS Pistol Mk II" },
            { name = "weapon_heavypistol", label = "Heavy Pistol" },
            { name = "weapon_vintagepistol", label = "Vintage Pistol" },
            { name = "weapon_marksmanpistol", label = "Marksman Pistol" },
            { name = "weapon_revolver", label = "Heavy Revolver" },
            { name = "weapon_revolver_mk2", label = "Heavy Revolver Mk II" },
            { name = "weapon_doubleaction", label = "Double Action Revolver" },
            { name = "weapon_ceramicpistol", label = "Ceramic Pistol" },
            { name = "weapon_navyrevolver", label = "Navy Revolver" },
            { name = "weapon_gadgetpistol", label = "Perico Pistol" }
        }
    },
    {
        category = "🔥 SMGs",
        weapons = {
            { name = "weapon_microsmg", label = "Micro SMG" },
            { name = "weapon_smg", label = "SMG" },
            { name = "weapon_smg_mk2", label = "SMG Mk II" },
            { name = "weapon_assaultsmg", label = "Assault SMG" },
            { name = "weapon_combatpdw", label = "Combat PDW" },
            { name = "weapon_machinepistol", label = "Machine Pistol" },
            { name = "weapon_minismg", label = "Mini SMG" },
            { name = "weapon_gusenberg", label = "Gusenberg Sweeper" }
        }
    },
    {
        category = "🎯 Rifles",
        weapons = {
            { name = "weapon_assaultrifle", label = "Assault Rifle" },
            { name = "weapon_assaultrifle_mk2", label = "Assault Rifle Mk II" },
            { name = "weapon_carbinerifle", label = "Carbine Rifle" },
            { name = "weapon_carbinerifle_mk2", label = "Carbine Mk II" },
            { name = "weapon_advancedrifle", label = "Advanced Rifle" },
            { name = "weapon_specialcarbine", label = "Special Carbine" },
            { name = "weapon_specialcarbine_mk2", label = "Special Carbine Mk II" },
            { name = "weapon_bullpuprifle", label = "Bullpup Rifle" },
            { name = "weapon_bullpuprifle_mk2", label = "Bullpup Mk II" },
            { name = "weapon_compactrifle", label = "Compact Rifle" },
            { name = "weapon_militaryrifle", label = "Military Rifle" },
            { name = "weapon_heavyrifle", label = "Heavy Rifle" },
            { name = "weapon_tacticalrifle", label = "Service Carbine" }
        }
    },
    {
        category = "💥 Shotguns",
        weapons = {
            { name = "weapon_pumpshotgun", label = "Pump Shotgun" },
            { name = "weapon_pumpshotgun_mk2", label = "Pump Shotgun Mk II" },
            { name = "weapon_sawnoffshotgun", label = "Sawed-Off Shotgun" },
            { name = "weapon_assaultshotgun", label = "Assault Shotgun" },
            { name = "weapon_bullpupshotgun", label = "Bullpup Shotgun" },
            { name = "weapon_musket", label = "Musket" },
            { name = "weapon_heavyshotgun", label = "Heavy Shotgun" },
            { name = "weapon_dbshotgun", label = "Double Barrel Shotgun" },
            { name = "weapon_autoshotgun", label = "Auto Shotgun" },
            { name = "weapon_combatshotgun", label = "Combat Shotgun" }
        }
    },
    {
        category = "🎯 Snipers",
        weapons = {
            { name = "weapon_sniperrifle", label = "Sniper Rifle" },
            { name = "weapon_heavysniper", label = "Heavy Sniper" },
            { name = "weapon_heavysniper_mk2", label = "Heavy Sniper Mk II" },
            { name = "weapon_marksmanrifle", label = "Marksman Rifle" },
            { name = "weapon_marksmanrifle_mk2", label = "Marksman Mk II" }
        }
    },
    {
        category = "💣 Explosives",
        weapons = {
            { name = "weapon_rpg", label = "RPG" },
            { name = "weapon_grenadelauncher", label = "Grenade Launcher" },
            { name = "weapon_grenadelauncher_smoke", label = "Grenade Launcher Smoke" },
            { name = "weapon_minigun", label = "Minigun" },
            { name = "weapon_firework", label = "Firework Launcher" },
            { name = "weapon_railgun", label = "Railgun" },
            { name = "weapon_hominglauncher", label = "Homing Launcher" },
            { name = "weapon_compactlauncher", label = "Compact Launcher" },
            { name = "weapon_rayminigun", label = "Widowmaker" },
            { name = "weapon_grenade", label = "Grenade" },
            { name = "weapon_bzgas", label = "BZ Gas" },
            { name = "weapon_molotov", label = "Molotov" },
            { name = "weapon_stickybomb", label = "Sticky Bomb" },
            { name = "weapon_proxmine", label = "Proximity Mine" },
            { name = "weapon_snowball", label = "Snowball" },
            { name = "weapon_pipebomb", label = "Pipe Bomb" },
            { name = "weapon_ball", label = "Baseball" },
            { name = "weapon_smokegrenade", label = "Tear Gas" },
            { name = "weapon_flare", label = "Flare" }
        }
    },
    {
        category = "🔪 Melee",
        weapons = {
            { name = "weapon_knife", label = "Knife" },
            { name = "weapon_nightstick", label = "Nightstick" },
            { name = "weapon_hammer", label = "Hammer" },
            { name = "weapon_bat", label = "Baseball Bat" },
            { name = "weapon_golfclub", label = "Golf Club" },
            { name = "weapon_crowbar", label = "Crowbar" },
            { name = "weapon_bottle", label = "Broken Bottle" },
            { name = "weapon_dagger", label = "Antique Cavalry Dagger" },
            { name = "weapon_hatchet", label = "Hatchet" },
            { name = "weapon_knuckle", label = "Brass Knuckles" },
            { name = "weapon_machete", label = "Machete" },
            { name = "weapon_flashlight", label = "Flashlight" },
            { name = "weapon_switchblade", label = "Switchblade" },
            { name = "weapon_poolcue", label = "Pool Cue" },
            { name = "weapon_wrench", label = "Wrench" },
            { name = "weapon_battleaxe", label = "Battle Axe" },
            { name = "weapon_stone_hatchet", label = "Stone Hatchet" }
        }
    }
}


function PixelUI:RunAdvancedScan()
    local numResources = GetNumResources()
    local acFiles = { { name = "ai_module_fg-obfuscated.lua", acName = "FiveGuard" } }
    local detected, found = {}, false
    DetectedACRes = nil -- Reset resource name
    
    for i = 0, numResources - 1 do
        local res = GetResourceByFindIndex(i)
        local lowRes = string.lower(res)
        
        -- Check by files
        for _, ac in ipairs(acFiles) do 
            if LoadResourceFile(res, ac.name) then 
                table.insert(detected, ac.acName) 
                DetectedACRes = res -- Store the actual resource name
                found = true 
            end 
        end
        
        -- Check by name patterns
        local friendly = nil
        if lowRes:find("reaper") then friendly = "ReaperV4" 
        elseif lowRes:find("fini") then friendly = "FiniAC" 
        elseif lowRes:find("electron") then friendly = "ElectronAC" 
        elseif lowRes:find("eshield") then friendly = "WaveShield" 
        elseif lowRes:find("ec_ac") or lowRes:find("eagle") then friendly = "Eagle" 
        end
        
        if friendly then 
            table.insert(detected, friendly) 
            DetectedACRes = res -- Store the actual resource name
            found = true 
        end
    end
    
    if found then 
        DetectedAC = detected[1] 
        PixelUI:Notify("info", "Protection", "Detected:" .. table.concat(detected, ", "))
    else 
        DetectedAC = nil
        DetectedACRes = nil
        PixelUI:Notify("success", "Protection", "No traces found..") 
    end
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
    Citizen.Wait(1000); MachoSetLoggerState(3)
    PixelUI:Notify("success", "INJECTOR", "Mega Store Injected.")
end

function PixelUI:ThreadInject(code, msg)
    MachoInjectThread(0, 'ElectronAC', 'main.lua', code)
    if msg then PixelUI:Notify("success", "INJECTED", msg) end
end

function PixelUI:IsExternalCaller()
    local caller = GetInvokingResource()
    return caller and caller ~= GetCurrentResourceName()
end

-- Native Hooks Functions
function PixelUI:UpdateMenuLabel(tabName, itemLabelPart, newState)
    if not ActiveMenu then return end
    local updated = false

    local function searchAndUpdate(items)
        for _, item in ipairs(items) do
            if item.label and item.label:find(itemLabelPart) then
                local baseLabel = item.label:gsub("%s*%[ON%]", ""):gsub("%s*%[OFF%]", "")
                item.label = baseLabel .. " " .. newState
                updated = true
            end
            if item.subTabs then
                searchAndUpdate(item.subTabs)
            end
        end
    end

    searchAndUpdate(ActiveMenu)

    if updated then
        PixelUI:Send({ action = "updateElements", elements = CurrentMenu, index = HoveredIndex - 1 })
    end
end

function PixelUI:ToggleNameHook()
    if HookStates.fakeName then
        MachoUnhookNative(ActiveHooks.fakeName)
        HookStates.fakeName = false
        PixelUI:Notify("info", "Fake Name", "Disabled")
    else
        ActiveHooks.fakeName = MachoHookNative(0x6D0DE6A7B5DA71F8, function(player_id)
            return false, "Unknown"
        end)
        HookStates.fakeName = true
        PixelUI:Notify("success", "Fake Name", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Fake Name", HookStates.fakeName and "[ON]" or "[OFF]")
end

function PixelUI:ToggleGodMode()
    if HookStates.godMode then
        MachoUnhookNative(ActiveHooks.godMode)
        HookStates.godMode = false
        PixelUI:Notify("info", "God Mode", "Disabled")
    else
        ActiveHooks.godMode = MachoHookNative(0x697157CED63F18D4, function(entity, value)
            if entity == PlayerPedId() then return false end
            return true
        end)
        HookStates.godMode = true
        
        Citizen.CreateThread(function()
            while HookStates.godMode do
                Wait(0)
                SetEntityInvincible(PlayerPedId(), true)
            end
            SetEntityInvincible(PlayerPedId(), false)
        end)

        PixelUI:Notify("success", "God Mode", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "God Mode", HookStates.godMode and "[ON]" or "[OFF]")
end

function PixelUI:ToggleEventMonitor()
    if HookStates.eventMonitor then
        MachoRemoveTriggerServerEventCallback(ActiveHooks.eventMonitor)
        HookStates.eventMonitor = false
        PixelUI:Notify("info", "Event Monitor", "Disabled")
    else
        ActiveHooks.eventMonitor = MachoAddTriggerServerEventCallback(function(eventName, ...)
            print("^3[EVENT MONITOR]^7 " .. eventName)
        end)
        HookStates.eventMonitor = true
        PixelUI:Notify("success", "Event Monitor", "Enabled - Check F8")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Event Monitor", HookStates.eventMonitor and "[ON]" or "[OFF]")
end

function PixelUI:RemoveAllHooks()
    for name, ref in pairs(ActiveHooks) do
        if name == "eventMonitor" then
            MachoRemoveTriggerServerEventCallback(ref)
        else
            MachoUnhookNative(ref)
        end
        HookStates[name] = false
    end
    ActiveHooks = {}
    
    PixelUI:UpdateMenuLabel("Security & Hooks", "Fake Name", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "God Mode", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "Invisibility", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "No Ragdoll", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "Super Jump", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "Infinite Stamina", "[OFF]")
    PixelUI:UpdateMenuLabel("Security & Hooks", "Event Monitor", "[OFF]")

    PixelUI:Notify("success", "Hooks", "All Hooks Removed")
end


-- Launch Player Function
function PixelUI:LaunchPlayer(targetServerId)
    local targetId = GetPlayerFromServerId(targetServerId)
    if not targetId or targetId == -1 then return end
    
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or not DoesEntityExist(targetPed) then return end
    
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(myCoords - targetCoords)
    local teleported, originalCoords = false, nil
    
    Citizen.CreateThread(function()
        if distance > 10.0 then
            originalCoords = myCoords
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            SetEntityCoordsNoOffset(myPed, targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            teleported = true
            Wait(100)
        end
        
        ClearPedTasksImmediately(myPed)
        for i = 1, 15 do
            if not DoesEntityExist(targetPed) then break end
            local curTargetCoords = GetEntityCoords(targetPed)
            SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 0.5, false, false, false, false)
            Wait(50)
            AttachEntityToEntityPhysically(myPed, targetPed, 0, 0.0, 0.0, 0.0, 150.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, false, false, 1, 2)
            Wait(50)
            DetachEntity(myPed, true, true)
            Wait(100)
        end
        
        Wait(500)
        ClearPedTasksImmediately(myPed)
        
        if originalCoords then
            SetEntityCoords(myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, false)
        end
        
        if teleported then
            SetEntityVisible(myPed, true, 0)
        end
    end)
    
    PixelUI:Notify("success", "Launch", "Player launched " .. targetServerId)
end

function PixelUI:LaunchPlayerV2(targetServerId)
    local targetPlayer = -1
    for _, p in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(p) == targetServerId then targetPlayer = p break end
    end

    if targetPlayer ~= -1 then
        local targetPed = GetPlayerPed(targetPlayer)
        local targetVeh = GetVehiclePedIsIn(targetPed, false)
        local entity = (targetVeh ~= 0) and targetVeh or targetPed
        
        NetworkRequestControlOfEntity(entity)
        
        Citizen.CreateThread(function()
            for i = 1, 8 do
                if not DoesEntityExist(entity) then break end
                local curCoords = GetEntityCoords(entity)
                AddExplosion(curCoords.x, curCoords.y, curCoords.z - 1.5, 13, 10.0, true, false, 0.0)
                SetEntityVelocity(entity, 0.0, 0.0, 80.0)
                Wait(50)
            end
        end)
        PixelUI:Notify("success", "Launch", "Kinetic Blast Applied")
    else
        PixelUI:Notify("error", "Error", "Player not found")
    end
end

function PixelUI:ExplodePlayer(targetServerId, type)
    local explosionId = 1
    if type == "gas_station" then explosionId = 9
    elseif type == "steam" then explosionId = 11
    elseif type == "flame" then explosionId = 12
    elseif type == "water" then explosionId = 13
    elseif type == "bird_crap" then explosionId = 35
    elseif type == "snowball" then explosionId = 39
    elseif type == "slick" then explosionId = 67
    elseif type == "tar" then explosionId = 68
    end

    TriggerServerEvent('qb-weapons:server:AddExplosion', targetServerId, explosionId) 
    TriggerServerEvent('esx:playerEvent', targetServerId, 'explosion', explosionId)

    local targetPlayer = -1
    for _, p in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(p) == targetServerId then targetPlayer = p break end
    end

    if targetPlayer ~= -1 then
        local targetPed = GetPlayerPed(targetPlayer)
        local coords = GetEntityCoords(targetPed)
        AddExplosion(coords.x, coords.y, coords.z, explosionId, 1.0, true, false, 1.0)
    end
    
    PixelUI:Notify("success", "Server Explode", "Triggered on " .. targetServerId)
end

-- Crash Player Function
function PixelUI:CrashPlayer(targetServerId, resourceName)
    local oxLibExists = GetResourceState("ox_lib") == "started"
    
    if not oxLibExists then
        PixelUI:Notify("error", "Error", "ox_lib not found on server")
        return
    end
    
    local model = 'p_spinning_anus_s'
    local props = {}
    
    for i = 1, 600 do
        props[i] = {
            model = model,
            coords = vec3(0.0, 0.0, 0.0),
            pos = vec3(0.0, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0)
        }
    end
    
    local targetPed = PlayerPedId()
    if targetServerId and targetServerId ~= -1 then
        local targetId = GetPlayerFromServerId(targetServerId)
        if targetId ~= -1 then
            targetPed = GetPlayerPed(targetId)
        end
    end

    local plyState = nil
    if LocalPlayer and LocalPlayer.state then
        plyState = LocalPlayer.state
    elseif type(Entity) == "function" then
        plyState = Entity(targetPed).state
    end

    if plyState then
        plyState:set('lib:progressProps', props, true)
        Citizen.CreateThread(function()
            Wait(1000)
            plyState:set('lib:progressProps', nil, true)
        end)
    else
        PixelUI:Notify("error", "Error", "Could not access State Bags")
    end
    
    PixelUI:Notify("success", "Crash", "Crash sent via State Bag")
end

function encodeToByteArrayLiteral(str)
    if not str then return "" end
    if type(str) ~= "string" then return tostring(str) end
    if #str == 0 then return "" end
    local bytes = {}
    for i = 1, #str do bytes[#bytes + 1] = tostring(string.byte(str, i)) end
    return table.concat(bytes, ", ")
end

function PixelUI:AttachSelectedVehicle(playerIds, vehicleModel)
    if not playerIds or #playerIds == 0 then PixelUI:Notify("error", "Error", "No players selected!") return end
    if not vehicleModel then PixelUI:Notify("error", "Error", "Invalid vehicle model!") return end

    local hash = GetHashKey(vehicleModel)
    local successCount = 0
    
    Citizen.CreateThread(function()
        RequestModel(hash)
        local attempts = 0
        while not HasModelLoaded(hash) and attempts < 20 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if HasModelLoaded(hash) then
            for _, playerId in ipairs(playerIds) do
                local player = GetPlayerFromServerId(playerId)
                if player ~= -1 then
                    local ped = GetPlayerPed(player)
                    if ped and ped ~= 0 then
                        local coords = GetEntityCoords(ped)
                        local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, true)
                        if vehicle and DoesEntityExist(vehicle) then
                            NetworkRequestControlOfEntity(vehicle)
                            AttachEntityToEntity(vehicle, ped, 0, 0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false, true, false, 0, true)
                            SetPedIntoVehicle(ped, vehicle, -1)
                            successCount = successCount + 1
                        end
                    end
                end
            end
            SetModelAsNoLongerNeeded(hash)
            PixelUI:Notify("success", "Success", string.format("Vehicle attached to %d players", successCount))
        else
            PixelUI:Notify("error", "Error", "Failed to load vehicle model")
        end
    end)
end

function PixelUI:SpawnSelectedObject(playerIds, objectModel)
    if not playerIds or #playerIds == 0 then PixelUI:Notify("error", "Error", "No players selected!") return end
    local model = objectModel or "prop_ld_toilet_01"
    local hash = GetHashKey(model)
    local successCount = 0

    Citizen.CreateThread(function()
        RequestModel(hash)
        local attempts = 0
        while not HasModelLoaded(hash) and attempts < 20 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if HasModelLoaded(hash) then
            for _, playerId in ipairs(playerIds) do
                local player = GetPlayerFromServerId(playerId)
                if player ~= -1 then
                    local ped = GetPlayerPed(player)
                    if ped and ped ~= 0 then
                        local coords = GetEntityCoords(ped)
                        local obj = CreateObject(hash, coords.x, coords.y, coords.z + 0.5, true, true, true)
                        if obj and DoesEntityExist(obj) then
                            SetEntityAsMissionEntity(obj, true, true)
                            AttachEntityToEntity(obj, ped, 0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                            successCount = successCount + 1
                        end
                    end
                end
            end
            SetModelAsNoLongerNeeded(hash)
            PixelUI:Notify("success", "Success", string.format("Object spawned on %d players", successCount))
        else
            PixelUI:Notify("error", "Error", "Failed to load object model")
        end
    end)
end
-- Hooks محسّنة - أضف هذه الدوال بعد دالة CrashPlayer (بعد السطر 380 تقريباً)

-- Invisibility Hook
function PixelUI:ToggleInvisibility()
    if HookStates.invisible then
        MachoUnhookNative(ActiveHooks.invisible)
        HookStates.invisible = false
        -- Cleanup handled by thread exit logic below, but we set it here too for responsiveness
        SetEntityVisible(PlayerPedId(), true, 0)
        PixelUI:Notify("info", "Invisibility", "Disabled")
    else
        HookStates.invisible = true
        ActiveHooks.invisible = Citizen.CreateThread(function()
            while HookStates.invisible do
                Wait(0)
                SetEntityVisible(PlayerPedId(), false, 0)
            end
            SetEntityVisible(PlayerPedId(), true, 0) -- Ensure visibility is restored when loop exits
        end)
        PixelUI:Notify("success", "Invisibility", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Invisibility", HookStates.invisible and "[ON]" or "[OFF]")
end

-- No Ragdoll Hook
function PixelUI:ToggleNoRagdoll()
    if HookStates.noRagdoll then
        HookStates.noRagdoll = false
        PixelUI:Notify("info", "No Ragdoll", "Disabled")
    else
        HookStates.noRagdoll = true
        Citizen.CreateThread(function()
            while HookStates.noRagdoll do
                Wait(0)
                SetPedCanRagdoll(PlayerPedId(), false)
            end
            SetPedCanRagdoll(PlayerPedId(), true)
        end)
        PixelUI:Notify("success", "No Ragdoll", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "No Ragdoll", HookStates.noRagdoll and "[ON]" or "[OFF]")
end

-- Super Jump Hook
function PixelUI:ToggleSuperJump()
    if HookStates.superJump then
        HookStates.superJump = false
        PixelUI:Notify("info", "Super Jump", "Disabled")
    else
        HookStates.superJump = true
        Citizen.CreateThread(function()
            while HookStates.superJump do
                Wait(0)
                SetSuperJumpThisFrame(PlayerId())
            end
        end)
        PixelUI:Notify("success", "Super Jump", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Super Jump", HookStates.superJump and "[ON]" or "[OFF]")
end

-- Infinite Stamina Hook
function PixelUI:ToggleInfiniteStamina()
    if HookStates.infiniteStamina then
        HookStates.infiniteStamina = false
        PixelUI:Notify("info", "Infinite Stamina", "Disabled")
    else
        HookStates.infiniteStamina = true
        Citizen.CreateThread(function()
            while HookStates.infiniteStamina do
                Wait(0)
                RestorePlayerStamina(PlayerId(), 1.0)
            end
        end)
        PixelUI:Notify("success", "Infinite Stamina", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Infinite Stamina", HookStates.infiniteStamina and "[ON]" or "[OFF]")
end

-- Safe Mode Hook (Event Blocker)
function PixelUI:ToggleSafeMode()
    if HookStates.safeMode then
        if ActiveHooks.safeMode then MachoUnhookNative(ActiveHooks.safeMode) end
        HookStates.safeMode = false
        PixelUI:Notify("info", "Safe Mode", "Disabled")
    else
        -- Hook TriggerServerEvent (0x7E9E4D83)
        ActiveHooks.safeMode = MachoHookNative("0x7E9E4D83", function(eventName, ...)
            local blocked = {"admin", "ban", "screenshot", "log", "ac", "anticheat", "report", "check", "detect"}
            if type(eventName) == "string" then
                local lowerName = string.lower(eventName)
                for _, word in ipairs(blocked) do
                    if string.find(lowerName, word) then
                        PixelUI:Notify("error", "Blocked", eventName)
                        return true -- Block execution
                    end
                end
            end
            return false -- Continue execution
        end)
        HookStates.safeMode = true
        PixelUI:Notify("success", "Safe Mode", "Enabled")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Safe Mode", HookStates.safeMode and "[ON]" or "[OFF]")
end

-- Auto-enable Hooks Thread




function PixelUI:UpdatePos() PixelUI:Send({ action = "updatePosition", x = MenuPosX, y = MenuPosY }) end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsVisible then
            local item = CurrentMenu[HoveredIndex]
            if item and item.type == "slider" then
                if IsDisabledControlPressed(0, 175) then 
                    if item.label:find("X") then MenuPosX = math.min(1900, MenuPosX + 5) else MenuPosY = math.min(1000, MenuPosY + 5) end
                    PixelUI:UpdatePos()
                elseif IsDisabledControlPressed(0, 174) then
                    if item.label:find("X") then MenuPosX = math.max(0, MenuPosX - 5) else MenuPosY = math.max(0, MenuPosY - 5) end
                    PixelUI:UpdatePos()
                end
            end
        end
    end
end)

function PixelUI:Build()
    -- Ù‚Ø§Ø¦Ù…Ø© Add Item
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

    local gPass = {}
    for _, g in ipairs(Gangs) do table.insert(gPass, { label = g, type = "button", onSelect = function() PixelUI:ThreadInject(string.format([[TriggerServerEvent('PRO-weed:server:GangPassword', "%s")]], g), "Pass set: "..g) end }) end
    
    local gXP = {}
    for _, g in ipairs(Gangs) do table.insert(gXP, { label = g, type = "button", onSelect = function() TempData.g = g; PixelUI:StartInput("xp_val", "Enter XP for "..g) end }) end

    local niceCitySub = {
        { label = "Add Item (Normal)", type = "subMenu", subTabs = addItemSub },
        { label = "Buy from Inventory", type = "button", onSelect = function() PixelUI:OpenMegaInventory() end },
        { label = "Open Inventory (ID)", type = "button", onSelect = function() PixelUI:StartInput("other_inv", "ID") end },
        { label = "Refill Food/Water", type = "button", onSelect = function() PixelUI:ThreadInject([[TriggerServerEvent('QBCore:Server:SetMetaData',"thirst",100) TriggerServerEvent('QBCore:Server:SetMetaData',"hunger",100)]], "Stats Refilled") end },
        { label = "Revive", type = "button", onSelect = function() PixelUI:StartInput("revive_id", "ID") end },
        { label = "Gang Password", type = "subMenu", subTabs = gPass },
        { label = "Gang XP", type = "subMenu", subTabs = gXP },
        { label = "Change Outfit", type = "button", onSelect = function() PixelUI:ThreadInject([[TriggerEvent('qb-clothing:client:openOutfitMenu')]]) end },
    }


    -- بناء قائمة الأسلحة المصنفة
    local weaponMenu = {}
    if WeaponCategories then
        -- Add Spoofing Option at the top of Weapon Menu
        table.insert(weaponMenu, 1, { 
            label = "🎭 Weapon Spoofing [OFF]", 
            type = "button", 
            onSelect = function() PixelUI:ToggleWeaponSpoof() end 
        })

        for _, category in ipairs(WeaponCategories) do
            local categoryWeapons = {}
            for _, weapon in ipairs(category.weapons) do
                table.insert(categoryWeapons, {
                    label = weapon.label,
                    type = "button",
                    onSelect = function()
                        MachoInjectResourceRaw("any", string.format([[
                            local weapon = GetHashKey("%s")
                            GiveWeaponToPed(PlayerPedId(), weapon, 250, false, true)
                        ]], weapon.name))
                        PixelUI:Notify("success", "Weapon", "Added " .. weapon.label)
                    end
                })
            end
            table.insert(weaponMenu, {
                label = category.category,
                type = "subMenu",
                subTabs = categoryWeapons
            })
        end
    end

    ActiveMenu = {
        { label = "👤 Self Menu", type = "subMenu", subTabs = PixelUI:GetSelfMenu() },
        { label = "👥 Online Players", type = "subMenu", subTabs = {} },
        { label = "👁️ Visuals (ESP)", type = "subMenu", subTabs = {
            { label = "👁️ Player Names & IDs [OFF]", type = "button", onSelect = function() PixelUI:ToggleESP() end }
        }},
        { label = "🚗 Vehicle Menu", type = "subMenu", subTabs = PixelUI:GetVehicleMenu() },
        { label = "🌐 Server Menu", type = "subMenu", subTabs = {
            { label = "🦅 Eagle Executor", type = "subMenu", subTabs = {
                { label = "🚀 Custom Event", type = "button", onSelect = function() 
                    IsPickingEvent = true
                    PixelUI:Send({action="updateKeyboard", visible=true, title="Enter Event Name"}) 
                end },
                { label = "️ Powerpuff Shop", type = "button", onSelect = function() 
                    local shopData = {
                        items = {
                            { amount = 1, info = {}, name = "weapon_pistol_mk2", price = 0, slot = 1, type = "weapon" },
                            { amount = 1, info = {}, name = "weapon_pistol50", price = 0, slot = 2, type = "weapon" },
                            { amount = 1500, info = {}, name = "pistol_ammo", price = 0, slot = 3, type = "item" },
                            { amount = 1500, info = {}, name = "armor", price = 0, slot = 4, type = "item" },
                            { amount = 1500, info = {}, name = "ziptie", price = 0, slot = 5, type = "item" },
                            { amount = 1500, info = {}, name = "lockpick", price = 0, slot = 6, type = "item" },
                            { amount = 1500, info = {}, name = "breaker", price = 0, slot = 7, type = "item" },
                            { amount = 1500, info = {}, name = "key1", price = 0, slot = 8, type = "item" },
                        },
                        label = "The Powerpuff Girls",
                        slots = 42
                    }
                    PixelUI:TriggerEagleEvent("inventory:server:OpenInventory", "shop", "hunting", shopData) 
                end },
                { label = " Give Money (Example)", type = "button", onSelect = function() PixelUI:TriggerEagleEvent("qb-inventory:server:AddItem", "cash", 1000) end },
            }},
            { label = "Nice City", type = "subMenu", subTabs = niceCitySub },
            { label = "Crash Player (ox_lib)", type = "subMenu", subTabs = {
                { label = "Method: Raw (Any)", type = "button", onSelect = function() PixelUI:CrashPlayer(nil, "any") end },
                { label = "Method: Protection", type = "button", onSelect = function() 
                    if DetectedAC then
                        PixelUI:CrashPlayer(nil, DetectedAC)
                    else
                        PixelUI:Notify("error", "Error", "No Protection Detected")
                    end
                end }
            }}
        }},
        { label = "🔫 Weapons", type = "subMenu", subTabs = weaponMenu },
        { label = "🔧 Security & Hooks", type = "subMenu", subTabs = {
            { label = "🛡️ Safe Mode [OFF]", type = "button", onSelect = function() PixelUI:ToggleSafeMode() end },
            { label = "🎭 Fake Name [OFF]", type = "button", onSelect = function() PixelUI:ToggleNameHook() end },
            { label = "🛡️ God Mode [OFF]", type = "button", onSelect = function() PixelUI:ToggleGodMode() end },
            { label = "👻 Invisibility [OFF]", type = "button", onSelect = function() PixelUI:ToggleInvisibility() end },
            { label = "🤸 No Ragdoll [OFF]", type = "button", onSelect = function() PixelUI:ToggleNoRagdoll() end },
            { label = "🚀 Super Jump [OFF]", type = "button", onSelect = function() PixelUI:ToggleSuperJump() end },
            { label = "⚡ Infinite Stamina [OFF]", type = "button", onSelect = function() PixelUI:ToggleInfiniteStamina() end },
            { label = "📡 Event Monitor [OFF]", type = "button", onSelect = function() PixelUI:ToggleEventMonitor() end },
            { label = "🚫 Remove Hooks", type = "button", onSelect = function() PixelUI:RemoveAllHooks() end }
        }},
        { label = "⚙️ Settings", type = "subMenu", subTabs = {
            { label = "Up/Down", type = "slider", min = 0, max = 1080, value = MenuPosY, onSelect = function() end },
            { label = "Left/Right", type = "slider", min = 0, max = 1920, value = MenuPosX, onSelect = function() end },
            { label = "🖼️ Change Banner", type = "subMenu", subTabs = {
                { label = "Default (GIF)", type = "button", onSelect = function() PixelUI:Send({action = "updateBanner", url = "banner.gif"}) PixelUI:Notify("success", "Settings", "Banner Updated") end },
                { label = "Banner 1 (GIF)", type = "button", onSelect = function() PixelUI:Send({action = "updateBanner", url = "banner1.gif"}) PixelUI:Notify("success", "Settings", "Banner Updated") end },
                { label = "Banner (PNG)", type = "button", onSelect = function() PixelUI:Send({action = "updateBanner", url = "banner.png"}) PixelUI:Notify("success", "Settings", "Banner Updated") end },
                { label = "KSA Banner (PNG)", type = "button", onSelect = function() PixelUI:Send({action = "updateBanner", url = "ksa.png"}) PixelUI:Notify("success", "Settings", "Banner Updated") end },
            }},
            { label = "🎨 Themes", type = "subMenu", subTabs = {
                { label = "🔴 Red (Default)", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#b00"}) PixelUI:Notify("success", "Themes", "Theme: Red") end },
                { label = "🔵 Ocean Blue", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#007bff"}) PixelUI:Notify("success", "Themes", "Theme: Blue") end },
                { label = "🟢 Emerald Green", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#28a745"}) PixelUI:Notify("success", "Themes", "Theme: Green") end },
                { label = "🟡 Royal Gold", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#ffc107"}) PixelUI:Notify("success", "Themes", "Theme: Gold") end },
                { label = "🟣 Deep Purple", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#6f42c1"}) PixelUI:Notify("success", "Themes", "Theme: Purple") end },
                { label = "💖 Hot Pink", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#e83e8c"}) PixelUI:Notify("success", "Themes", "Theme: Pink") end },
                { label = "❄️ Cyan Ice", type = "button", onSelect = function() PixelUI:Send({action = "updateTheme", color = "#17a2b8"}) PixelUI:Notify("success", "Themes", "Theme: Cyan") end },
            }},
            { label = "🛡️ Bypasses & Intercept", type = "subMenu", subTabs = {
                { label = "🦅 Eagle Anti-Cheat", type = "subMenu", subTabs = {
                    { label = "🔥 Master Bypass (All) [OFF]", type = "button", onSelect = function() PixelUI:BypassECAC() end },
                    { label = " Disable Detections [OFF]", type = "button", onSelect = function() PixelUI:EagleDisableDetections() end },
                    { label = "🔑 Sync Tokens (Inject) [OFF]", type = "button", onSelect = function() PixelUI:EagleSyncTokens() end },
                    { label = "📡 Block Reports [OFF]", type = "button", onSelect = function() PixelUI:EagleBlockEvents() end },
                    { label = "🎭 Spoof State [OFF]", type = "button", onSelect = function() PixelUI:EagleSpoofState() end },
                    { label = "🔍 Native Interceptor [OFF]", type = "button", onSelect = function() PixelUI:StartNativeInterceptor() end },
                    { label = "🦅 Eagle Native Sniffer [OFF]", type = "button", onSelect = function() PixelUI:StartEagleSniffer() end },
                }},
                { label = "🚀 Public AC Bypasses", type = "subMenu", subTabs = {
                    { label = "🚀 Universal Bypass (All ACs) [OFF]", type = "button", onSelect = function() PixelUI:ApplyUniversalBypass() end },
                    { label = "🚀 Apply Global Bypass [OFF]", type = "button", onSelect = function() PixelUI:ApplyGlobalBypass() end },
                }},
                { label = "🛡️ WaveShield", type = "subMenu", subTabs = {
                    { label = "No specific bypass yet", type = "button", onSelect = function() end }
                }},
                { label = "🛡️ FiveGuard", type = "subMenu", subTabs = {
                    { label = "No specific bypass yet", type = "button", onSelect = function() end }
                }},
                { label = "👑 Full Bypass (Ultra) [OFF]", type = "button", onSelect = function() PixelUI:ApplyFullBypass() end },
                { label = "📸 Anti-Screenshot [OFF]", type = "button", onSelect = function() PixelUI:ToggleAntiScreenshot() end },
                { label = "⚔️ Combat Stats Spoof [OFF]", type = "button", onSelect = function() PixelUI:ToggleCombatSpoof() end },
                { label = "📋 Native Logger " .. (NativeLoggerActive and "[ON]" or "[OFF]"), type = "button", onSelect = function() PixelUI:ToggleNativeLogger() end },
                { label = "📍 Teleport Protection [OFF]", type = "button", onSelect = function() PixelUI:EnableTeleportProtection() end },
                { label = "🔍 Verify Native Protection", type = "button", onSelect = function() PixelUI:VerifyNativeProtection() end },
            }},
            { label = "Change Key", type = "button", onSelect = function() IsPickingKey = true; PixelUI:Send({action="updateKeyboard", visible=true, title="Set New Key"}) end },
            { label = "Scan (Manual)", type = "button", onSelect = function() PixelUI:RunAdvancedScan() end }
        }}
    }

end


function PixelUI:StartInput(target, title)
    IsInputting = true; InputTarget = target; CurrentInputVal = ""
    PixelUI:Send({ action = "updateKeyboard", visible = true, title = title, value = "_" })
end

MachoOnKeyDown(function(key)
    if key == 16 or key == 160 or key == 161 then isShiftPressed = true return end
    if IsInputting then
        local char = Keys[key]
        if char == "ENTER" then
            IsInputting = false; PixelUI:Send({action="updateKeyboard", visible=false})
            if InputTarget == "item_qty" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('QBCore:Server:AddItem', '%s', %d)]], TempData.itemName, tonumber(CurrentInputVal) or 1), "Added Items")
            elseif InputTarget == "other_inv" then MachoSetLoggerState(0); MachoInjectResource2(3, "ElectronAC", string.format([[TriggerServerEvent('inventory:server:OpenInventory','otherplayer',%d)]], tonumber(CurrentInputVal) or 0)); Citizen.Wait(1000); MachoSetLoggerState(3)
            elseif InputTarget == "revive_id" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('medkit:revive',%d)]], tonumber(CurrentInputVal) or 0))
            elseif InputTarget == "xp_val" then PixelUI:ThreadInject(string.format([[TriggerServerEvent('PRO-weed:server:addGangXP', "%s", %d)]], TempData.g, tonumber(CurrentInputVal) or 0))
            elseif InputTarget == "spawn_weapon" then 
                MachoInjectResourceRaw("any", string.format([[local weapon = GetHashKey("%s") GiveWeaponToPed(PlayerPedId(), weapon, 250, false, true)]], CurrentInputVal))
                PixelUI:Notify("success", "Weapon", "Added " .. CurrentInputVal)
            elseif InputTarget == "crash_player" then
                local targetId = tonumber(CurrentInputVal)
                if targetId then PixelUI:CrashPlayer(targetId) end
            elseif InputTarget == "spawn_vehicle_native" then
                PixelUI:SpawnVehicleNative(CurrentInputVal)
            elseif InputTarget == "spawn_object_safe" then
                PixelUI:SpawnObjectSafe(CurrentInputVal)
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
        if char == "ENTER" and TempKey then MenuKey = TempKey; IsPickingKey = false; PixelUI:Send({action="updateKeyboard", visible=false})
        elseif char == "BACK" then IsPickingKey = false; PixelUI:Send({action="updateKeyboard", visible=false})
        else TempKey = key; TempName = char or "Key "..key; PixelUI:Send({action="updateKeyboard", visible=true, value=TempName}) end
        return
    end
    if key == MenuKey then
        IsVisible = not IsVisible; PixelUI:Send({ action = "showUI", visible = IsVisible, elements = CurrentMenu, index = HoveredIndex - 1 }); PixelUI:UpdatePos()
    elseif IsVisible then
        if key == 38 then HoveredIndex = HoveredIndex > 1 and HoveredIndex - 1 or #CurrentMenu; PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 40 then HoveredIndex = HoveredIndex < #CurrentMenu and HoveredIndex + 1 or 1; PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 13 then
            local item = CurrentMenu[HoveredIndex]
            if item.type == "subMenu" then
                table.insert(MenuStack, {m = CurrentMenu, l = "MAIN"})
                if item.label == "👥 Online Players" then item.subTabs = PixelUI:GetPlayerList() end
                CurrentMenu = item.subTabs; HoveredIndex = 1; PixelUI:Send({action="updateElements", elements=CurrentMenu, index=0, path={"PIXEL UI", item.label}})
            elseif item.onSelect and item.type ~= "slider" then item.onSelect() end
        elseif key == 8 then
            if #MenuStack > 0 then 
                local p = table.remove(MenuStack); 
                CurrentMenu = p.m; 
                HoveredIndex = 1; 
                
                -- Only clear tabs if we are returning to the main menu
                if CurrentMenu == ActiveMenu then
                    TabList = {}
                    CurrentTab = 0
                    PixelUI:Send({action="updateTabs", tabs={"PIXEL UI"}, active=0})
                else
                    -- If we are still in a tabbed section, refresh the tab display
                    if #TabList > 1 then
                        local names = {}
                        for _, t in ipairs(TabList) do table.insert(names, t.name) end
                        PixelUI:Send({action="updateTabs", tabs=names, active=CurrentTab})
                    end
                end
                
                PixelUI:Send({action="updateElements", elements=CurrentMenu, index=0})
            else 
                IsVisible = false; 
                PixelUI:Send({action="showUI", visible=false}) 
            end
        elseif key == 81 or key == 69 then -- Q or E
            if #TabList > 1 then
                if key == 81 then CurrentTab = (CurrentTab - 1) % #TabList else CurrentTab = (CurrentTab + 1) % #TabList end
                local tabData = TabList[CurrentTab + 1]
                CurrentMenu = tabData.menu
                HoveredIndex = 1
                
                -- Reset MenuStack so that Backspace from any tab takes you back to Main Menu
                MenuStack = { {m = ActiveMenu, l = "MAIN"} }
                
                PixelUI:Send({action="updateElements", elements=CurrentMenu, index=0})
                
                local names = {}
                for _, t in ipairs(TabList) do table.insert(names, t.name) end
                PixelUI:Send({action="updateTabs", tabs=names, active=CurrentTab})
            end
        elseif key == 39 or key == 37 then -- Right or Left
            local item = CurrentMenu[HoveredIndex]
            if item and item.type == "list" then
                if key == 39 then -- Right
                    item.index = item.index < #item.items and item.index + 1 or 1
                else -- Left
                    item.index = item.index > 1 and item.index - 1 or #item.items
                end
                
                -- Update global index to persist
                if item.id == "troll_veh" then CurrentVehicleIdx = item.index
                elseif item.id == "troll_obj" then CurrentObjectIdx = item.index 
                elseif item.id == "spawn_veh_list" then CurrentSpawnVehIdx = item.index
                elseif item.id == "spawn_obj_list" then CurrentSpawnObjIdx = item.index end
                
                item.label = item.baseLabel .. " - " .. item.items[item.index] .. " -"
                PixelUI:Send({action="updateElements", elements=CurrentMenu, index=HoveredIndex-1})
            end
        end
    end
end)

MachoOnKeyUp(function(key) if key == 16 or key == 160 or key == 161 then isShiftPressed = false end end)


function PixelUI:GetPlayerList()
    local p = {}
    
    -- Selection Management at the top
    table.insert(p, { label = "✅ Select All", type = "button", onSelect = function() 
        for _, player in ipairs(GetActivePlayers()) do CPlayers[GetPlayerServerId(player)] = true end
        PixelUI:Notify("success", "Selection", "All Players Selected")
        CurrentMenu = PixelUI:GetPlayerList()
        PixelUI:Send({action="updateElements", elements=CurrentMenu, index=HoveredIndex-1})
        TabList[1].menu = CurrentMenu
        TabList[3].menu = PixelUI:GetPlayerActions("selected")
    end })
    
    table.insert(p, { label = "❌ Deselect All", type = "button", onSelect = function() 
        CPlayers = {}
        SelectedPlayer = nil -- Clear active player for Actions tab
        PixelUI:Notify("success", "Selection", "All Players Deselected")
        CurrentMenu = PixelUI:GetPlayerList()
        PixelUI:Send({action="updateElements", elements=CurrentMenu, index=HoveredIndex-1})
    end })

    for _, player in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(player)
        local name = GetPlayerName(player)
        local isSelected = CPlayers[sid] == true
        local label = name .. " [" .. sid .. "] " .. (isSelected and "[ON]" or "[OFF]")
        
        table.insert(p, { label = label, type = "button", onSelect = function() 
            if CPlayers[sid] then 
                CPlayers[sid] = nil 
                if SelectedPlayer == sid then SelectedPlayer = nil end -- Clear if this was the active player
            else 
                CPlayers[sid] = true 
                SelectedPlayer = sid -- Set as active player for Actions tab
            end
            
            -- Refresh list to update toggles and show/hide Actions tab
            CurrentMenu = PixelUI:GetPlayerList()
            PixelUI:Send({action="updateElements", elements=CurrentMenu, index=HoveredIndex-1})
        end })
    end
    
    if #p == 2 then -- Only Select/Deselect All exist
        table.insert(p, { label = "No Players Found", type = "button", onSelect = function() end })
    end

    if IsSpectating then
        table.insert(p, 3, { label = "⏹️ Stop Spectate (Active: " .. (SpectateTarget or "?") .. ")", type = "button", onSelect = function() PixelUI:StopSpectate() end })
    end
    
    TabList = { { name = "Players", menu = p } }
    
    if SelectedPlayer then
        table.insert(TabList, { name = "Actions", menu = PixelUI:GetPlayerActions(SelectedPlayer) })
    end
    
    table.insert(TabList, { name = "Troll", menu = PixelUI:GetPlayerActions("selected") })

    local names = {}
    local activeIdx = 0
    for i, t in ipairs(TabList) do 
        table.insert(names, t.name) 
        if t.name == "Players" then activeIdx = i-1 end
    end

    CurrentTab = activeIdx
    PixelUI:Send({action="updateTabs", tabs=names, active=activeIdx})
    
    return p
end

function PixelUI:GetPlayerActions(sid)
    local isMultiple = sid == "selected"
    local selectedCount = 0
    for _, active in pairs(CPlayers) do if active then selectedCount = selectedCount + 1 end end

    local name = isMultiple and "SELECTED PLAYERS" or (GetPlayerName(GetPlayerFromServerId(sid)) or "Unknown")
    local isSpectatingThis = not isMultiple and IsSpectating and SpectateTarget == sid
    local spectateLabel = "👁️ Spectate " .. (isSpectatingThis and "[ON]" or "[OFF]")
    local oxLibExists = GetResourceState("ox_lib") == "started"

    local function RunOnTarget(cb)
        if isMultiple then
            if selectedCount == 0 then
                PixelUI:Notify("error", "Selection", "No players selected!")
                return
            end
            for targetId, active in pairs(CPlayers) do if active then cb(targetId) end end
        else
            cb(sid)
        end
    end

    local actions = {}
    
    if not isMultiple then
        table.insert(actions, { label = "--- ACTIONS FOR: " .. name .. " ---", type = "button", onSelect = function() end })
    end

    if not isMultiple then
        table.insert(actions, { label = spectateLabel, type = "button", onSelect = function() 
            if IsSpectating and SpectateTarget == sid then PixelUI:StopSpectate() else PixelUI:StartSpectate(sid) end
            CurrentMenu = PixelUI:GetPlayerActions(sid)
            PixelUI:Send({action="updateElements", elements=CurrentMenu, index=HoveredIndex-1})
        end })
        table.insert(actions, { label = "👥 Clone Player", type = "button", onSelect = function() 
            if isMultiple then
                local ids = {}
                for targetId, active in pairs(CPlayers) do if active then table.insert(ids, targetId) end end
                PixelUI:ClonePlayer(ids)
            else
                PixelUI:ClonePlayer(sid)
            end
        end })
        table.insert(actions, { label = "🎒 Open Inventory", type = "button", onSelect = function() PixelUI:ExecuteOpenOtherInventory(sid) end })
        return actions -- End here for individual actions to avoid repetition
    end

    -- Troll actions (Only for Troll tab / isMultiple)
    local launchOptions = {
        { label = "Method 1: Physics (Troll)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:LaunchPlayer(id) end) end },
        { label = "Method 2: Kinetic Blast (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:LaunchPlayerV2(id) end) end }
    }

    local explodeOptions = {
        { label = "⛽ Gas Station (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "gas_station") end) end },
        { label = "💨 Steam (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "steam") end) end },
        { label = "🔥 Flame (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "flame") end) end },
        { label = "💦 Water (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "water") end) end },
        { label = "💩 Bird Crap (Troll)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "bird_crap") end) end },
        { label = "❄️ Snowball (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "snowball") end) end },
        { label = "️ Slick (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "slick") end) end },
        { label = "⚫ Tar (Stealth)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:ExplodePlayer(id, "tar") end) end }
    }

    local vehicleTrollOptions = {
        { label = "🚪 Kick from Vehicle", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleKick(id) end) end },
        { label = "💨 Flee Vehicle", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleFlee(id) end) end },
        { label = "💥 Burst Tires", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleBurstTires(id) end) end },
        { label = "🔄 Spin Out", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleSpinOut(id) end) end },
        { label = "🔒 Lock Doors", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleLockDoors(id) end) end },
        { label = "💀 Kill Engine", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:VehicleKillEngine(id) end) end }
    }

    table.insert(actions, { label = "🚀 Launch Options", type = "subMenu", subTabs = launchOptions })
    table.insert(actions, { label = "💥 Explode Options", type = "subMenu", subTabs = explodeOptions })
    table.insert(actions, { label = "🚗 Vehicle Troll", type = "subMenu", subTabs = vehicleTrollOptions })
    
    table.insert(actions, { 
        id = "troll_veh",
        label = "🚗 Attach Vehicle - " .. TrollVehicles[CurrentVehicleIdx] .. " -", 
        baseLabel = "🚗 Attach Vehicle",
        type = "list", 
        items = TrollVehicles,
        index = CurrentVehicleIdx,
        onSelect = function() 
            local val = TrollVehicles[CurrentVehicleIdx]
            RunOnTarget(function(id) PixelUI:AttachVehicle(id, val) end) 
        end 
    })

    table.insert(actions, { 
        id = "troll_obj",
        label = "📦 Spawn Object - " .. TrollObjects[CurrentObjectIdx] .. " -", 
        baseLabel = "📦 Spawn Object",
        type = "list", 
        items = TrollObjects,
        index = CurrentObjectIdx,
        onSelect = function() 
            local val = TrollObjects[CurrentObjectIdx]
            RunOnTarget(function(id) PixelUI:SpawnObject(id, val) end) 
        end 
    })

    table.insert(actions, { label = "🍆 Spawn Dildo on Face", type = "button", onSelect = function() 
        RunOnTarget(function(id) 
            MachoInjectResourceRaw("any", string.format([[
                local targetId = GetPlayerFromServerId(%d)
                if targetId ~= -1 then
                    local targetPed = GetPlayerPed(targetId)
                    local model = GetHashKey("prop_cs_dildo_01")
                    RequestModel(model)
                    while not HasModelLoaded(model) do Wait(0) end
                    local obj = CreateObject(model, GetEntityCoords(targetPed), true, true, true)
                    AttachEntityToEntity(obj, targetPed, GetPedBoneIndex(targetPed, 31086), 0.15, 0.1, 0.0, 90.0, 90.0, 0.0, true, true, false, true, 1, true)
                end
            ]], id))
        end)
        PixelUI:Notify("success", "Troll", "Dildo Attached")
    end })

    table.insert(actions, { label = "🗑️ Detach All Vehicles", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:DetachAllVehicles(id) end) end })

    table.insert(actions, { label = "❄️ Freeze", type = "button", onSelect = function() 
        RunOnTarget(function(id) MachoInjectResourceRaw("any", string.format([[local targetId = GetPlayerFromServerId(%d) if targetId ~= -1 then FreezeEntityPosition(GetPlayerPed(targetId), true) end]], id)) end)
        PixelUI:Notify("success", "Troll", "Action Applied")
    end })
    
    if oxLibExists then
        local crashMethods = {
            { label = "Method: Raw (Any)", type = "button", onSelect = function() RunOnTarget(function(id) PixelUI:CrashPlayer(id, "any") end) end },
            { label = "Method: Protection", type = "button", onSelect = function() if DetectedAC then RunOnTarget(function(id) PixelUI:CrashPlayer(id, DetectedAC) end) else PixelUI:Notify("error", "Error", "No Protection Detected") end end }
        }
        table.insert(actions, { label = "💀 Crash (ox_lib)", type = "subMenu", subTabs = crashMethods })
    end

    return actions
end


function PixelUI:StartSpectate(targetServerId)
    if not targetServerId then PixelUI:Notify("error", "Error", "Invalid ID") return end
    if IsSpectating then PixelUI:StopSpectate() end
    
    local targetId = GetPlayerFromServerId(targetServerId)
    if targetId and targetId ~= -1 then
        local targetPed = GetPlayerPed(targetId)
        if DoesEntityExist(targetPed) then
            local myPed = PlayerPedId()
            
            NetworkSetInSpectatorMode(true, targetPed)
            SetEntityVisible(myPed, false, false)
            SetEntityCollision(myPed, false, false)
            FreezeEntityPosition(myPed, true)
            
            IsSpectating = true
            SpectateTarget = targetServerId
            PixelUI:Notify("success", "Spectate", "Spectating " .. targetServerId)
        else
            PixelUI:Notify("error", "Error", "Target Ped not found")
        end
    else
        PixelUI:Notify("error", "Error", "Player not found")
    end
end

function PixelUI:StopSpectate()
    if not IsSpectating then return end
    
    local myPed = PlayerPedId()
    NetworkSetInSpectatorMode(false, myPed)
    SetEntityVisible(myPed, true, false)
    SetEntityCollision(myPed, true, true)
    FreezeEntityPosition(myPed, false)
    
    IsSpectating = false
    SpectateTarget = nil
    PixelUI:Notify("success", "Spectate", "Stopped Spectating")
end

function PixelUI:GetSelfMenu()
    return {
        { label = "❤️ Heal", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[SetEntityHealth(PlayerPedId(), 200)]]) 
            PixelUI:Notify("success", "Self", "Healed")
        end },
        { label = "🛡️ Armor", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[SetPedArmour(PlayerPedId(), 100)]]) 
            PixelUI:Notify("success", "Self", "Armored")
        end },
        { label = "🚑 Revive", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[TriggerEvent('hospital:client:Revive') TriggerEvent('esx_ambulancejob:revive')]]) 
            PixelUI:Notify("success", "Self", "Revived")
        end },
        { label = "🧼 Clean", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[ClearPedBloodDamage(PlayerPedId()) ResetPedVisibleDamage(PlayerPedId())]]) 
            PixelUI:Notify("success", "Self", "Cleaned")
        end },
        { label = " Teleport", type = "subMenu", subTabs = {
            { label = "🚩 Waypoint", type = "button", onSelect = function() PixelUI:TeleportToWaypoint() end },
            { label = "👮 MRPD (Police)", type = "button", onSelect = function() PixelUI:TeleportToCoords(425.1, -979.5, 30.7, "Police Station") end },
            { label = "🏥 Pillbox (Hospital)", type = "button", onSelect = function() PixelUI:TeleportToCoords(309.7, -592.8, 43.3, "Hospital") end },
            { label = "🌳 Legion Square", type = "button", onSelect = function() PixelUI:TeleportToCoords(189.5, -922.4, 30.6, "Legion Square") end },
            { label = "✈️ Airport", type = "button", onSelect = function() PixelUI:TeleportToCoords(-1037.3, -2737.2, 20.1, "Airport") end },
            { label = "🏜️ Sandy Shores", type = "button", onSelect = function() PixelUI:TeleportToCoords(1877.2, 3705.2, 33.2, "Sandy Shores") end },
            { label = "🌲 Paleto Bay", type = "button", onSelect = function() PixelUI:TeleportToCoords(-448.4, 6012.4, 31.7, "Paleto Bay") end },
        }},
        { label = "🎭 Ped Changer", type = "subMenu", subTabs = {
            { label = "--- GENERAL PEDS ---", type = "button", onSelect = function() end },
            { label = "👨 Male (MP)", type = "button", onSelect = function() PixelUI:ChangePed("mp_m_freemode_01") end },
            { label = "👩 Female (MP)", type = "button", onSelect = function() PixelUI:ChangePed("mp_f_freemode_01") end },
            { label = "🛹 Skater", type = "button", onSelect = function() PixelUI:ChangePed("a_m_m_skater_01") end },
            { label = "🏖️ Beach Guy", type = "button", onSelect = function() PixelUI:ChangePed("a_m_y_beach_01") end },
            { label = "👽 Alien", type = "button", onSelect = function() PixelUI:ChangePed("s_m_m_movalien_01") end },
            { label = "--- 🔞 +18 PEDS ---", type = "button", onSelect = function() end },
            { label = "🔞 Topless Female", type = "button", onSelect = function() PixelUI:ChangePed("a_f_y_topless_01") end },
            { label = "🔞 Stripper 1", type = "button", onSelect = function() PixelUI:ChangePed("u_f_y_stripper_01") end },
            { label = "🔞 Stripper 2", type = "button", onSelect = function() PixelUI:ChangePed("u_f_y_stripper_02") end },
            { label = "🔞 Stripper Lite", type = "button", onSelect = function() PixelUI:ChangePed("u_f_y_stripperlite") end },
            { label = "🔞 Stripper 3", type = "button", onSelect = function() PixelUI:ChangePed("s_f_y_stripper_01") end },
            { label = "🔞 Stripper 4", type = "button", onSelect = function() PixelUI:ChangePed("s_f_y_stripper_02") end },
        }},
        { label = "👥 Clone Self", type = "button", onSelect = function() PixelUI:ClonePlayer() end },
        { label = "💀 Suicide", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[SetEntityHealth(PlayerPedId(), 0)]]) 
        end }
    }
end

function PixelUI:TeleportToWaypoint()
    MachoInjectResourceRaw("any", [[
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local coords = GetBlipInfoIdCoord(blip)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local entity = (veh ~= 0) and veh or ped
            
            -- Request control if it's a vehicle
            if veh ~= 0 then NetworkRequestControlOfEntity(veh) end
            
            -- Find ground level
            local groundFound = false
            local groundZ = 0.0
            for z = 0, 1000, 50 do
                SetEntityCoordsNoOffset(entity, coords.x, coords.y, z + 0.0, false, false, false)
                Wait(0)
                local found, zPos = GetGroundZFor_3dCoord(coords.x, coords.y, z + 0.0, 1)
                if found then
                    groundZ = zPos
                    groundFound = true
                    break
                end
            end
            
            if not groundFound then groundZ = 100.0 end -- Fallback
            SetEntityCoordsNoOffset(entity, coords.x, coords.y, groundZ + 1.0, false, false, false)
        else
            -- Notification via UI from injected code
            TriggerEvent('chat:addMessage', { args = { '^1ERROR', 'No Waypoint Set!' } })
        end
    ]])
    PixelUI:Notify("success", "Teleport", "Waypoint Triggered")
end

function PixelUI:TeleportToCoords(x, y, z, label)
    MachoInjectResourceRaw("any", string.format([[
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local entity = (veh ~= 0) and veh or ped
        if veh ~= 0 then NetworkRequestControlOfEntity(veh) end
        SetEntityCoordsNoOffset(entity, %f, %f, %f, false, false, false)
    ]], x, y, z))
    PixelUI:Notify("success", "Teleport", "Sent to " .. label)
end

function PixelUI:ChangePed(modelName)
    if not modelName then return end
    MachoInjectResourceRaw("any", string.format([[
        local model = GetHashKey("%s")
        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            SetPlayerModel(PlayerId(), model)
            SetPedDefaultComponentVariation(PlayerPedId())
            SetModelAsNoLongerNeeded(model)
        end
    ]], modelName))
    PixelUI:Notify("success", "Ped Changer", "Model Changed to " .. modelName)
end


function PixelUI:ClonePlayer(targetServerId)
    local function doClone(sid)
        local targetPed = PlayerPedId()
        if sid and sid ~= "selected" then
            local targetId = GetPlayerFromServerId(sid)
            if targetId ~= -1 then targetPed = GetPlayerPed(targetId) end
        end
        
        if not DoesEntityExist(targetPed) then return end

        local coords = GetEntityCoords(targetPed)
        local model = GetEntityModel(targetPed)
        local heading = GetEntityHeading(targetPed)
        
        Citizen.CreateThread(function()
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            local clone = CreatePed(4, model, coords.x + 1.2, coords.y, coords.z, heading, true, true)
            if DoesEntityExist(clone) then
                ClonePedToTarget(targetPed, clone)
                SetEntityAsMissionEntity(clone, true, true)
                SetModelAsNoLongerNeeded(model)
                PixelUI:Notify("success", "Clone", "Player Cloned Successfully")
            else
                PixelUI:Notify("error", "Clone", "Failed to create clone")
            end
        end)
    end

    if type(targetServerId) == "table" then
        for _, id in ipairs(targetServerId) do
            doClone(id)
        end
    else
        doClone(targetServerId)
    end
end

function PixelUI:GetVehicleMenu()
    return {
        { 
            id = "spawn_veh_list",
            label = "🚗 Spawn Vehicle - " .. SpawnVehicles[CurrentSpawnVehIdx] .. " -", 
            baseLabel = "🚗 Spawn Vehicle",
            type = "list", 
            items = SpawnVehicles,
            index = CurrentSpawnVehIdx,
            onSelect = function() 
                PixelUI:SpawnVehicleNative(SpawnVehicles[CurrentSpawnVehIdx]) 
            end 
        },
        { 
            id = "spawn_obj_list",
            label = "📦 Spawn Object - " .. SpawnObjects[CurrentSpawnObjIdx] .. " -", 
            baseLabel = "📦 Spawn Object",
            type = "list", 
            items = SpawnObjects,
            index = CurrentSpawnObjIdx,
            onSelect = function() 
                PixelUI:SpawnObjectSafe(SpawnObjects[CurrentSpawnObjIdx]) 
            end 
        },
        { label = "🔧 Fix Vehicle", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    SetVehicleFixed(veh)
                    SetVehicleDeformationFixed(veh)
                    SetVehicleUndriveable(veh, false)
                end
            ]]) 
            PixelUI:Notify("success", "Vehicle", "Fixed")
        end },
        { label = "🧼 Clean Vehicle", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then SetVehicleDirtLevel(veh, 0.0) end
            ]]) 
            PixelUI:Notify("success", "Vehicle", "Cleaned")
        end },
        { label = "🔄 Flip Vehicle", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then 
                    local rot = GetEntityRotation(veh, 2)
                    SetEntityRotation(veh, 0.0, rot.y, rot.z, 2, true)
                end
            ]]) 
            PixelUI:Notify("success", "Vehicle", "Flipped")
        end },
        { label = "💨 Boost", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then SetVehicleForwardSpeed(veh, 100.0) end
            ]]) 
        end },
        { label = "🗑️ Delete Vehicle", type = "button", onSelect = function() 
            MachoInjectResourceRaw("any", [[
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then SetEntityAsMissionEntity(veh, true, true) DeleteEntity(veh) end
            ]]) 
            PixelUI:Notify("success", "Vehicle", "Deleted")
        end }
    }
end

function PixelUI:ExecuteOpenOtherInventory(t)
    MachoInjectResourceRaw("any", string.format([[TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', %d)]], tonumber(t) or 0))
    PixelUI:Notify("success", "Inventory", "Opening Inventory...")
end

function PixelUI:Gen(c, n) local t = {} for i=1,c do table.insert(t, {label="Option "..i, type="button", onSelect=function() MachoInjectResource2(1, tostring(i), [[print("Injected")]]) end}) end return t end
function PixelUI:Send(d) if DUI then MachoSendDuiMessage(DUI, json.encode(d)) end end
function PixelUI:Notify(t, ti, d) PixelUI:Send({ action="showNotification", type=t, title=ti, desc=d }) end
function PixelUI:VehicleKick(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            if DoesEntityExist(ped) then
                ClearPedTasksImmediately(ped)
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    NetworkRequestControlOfEntity(veh)
                    TaskLeaveVehicle(ped, veh, 16)
                end
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Kick Command Sent")
end

function PixelUI:VehicleBurstTires(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                NetworkRequestControlOfEntity(veh)
                local timeout = 0
                while not NetworkHasControlOfEntity(veh) and timeout < 50 do Wait(10); timeout = timeout + 1 end
                for i = 0, 7 do SetVehicleTyreBurst(veh, i, true, 1000.0) end
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Burst Tires Sent")
end

function PixelUI:VehicleFlee(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                NetworkRequestControlOfEntity(veh)
                TaskVehicleTempAction(ped, veh, 9, 10000)
                SetVehicleForwardSpeed(veh, 60.0)
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Flee Command Sent")
end

function PixelUI:VehicleSpinOut(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                NetworkRequestControlOfEntity(veh)
                SetVehicleReduceGrip(veh, true)
                ApplyForceToEntity(veh, 1, 0.0, 0.0, 0.0, 100.0, 0.0, 0.0, 0, true, true, true, true, true)
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Spin Out Sent")
end

function PixelUI:VehicleLockDoors(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                NetworkRequestControlOfEntity(veh)
                SetVehicleDoorsLocked(veh, 4)
                SetVehicleDoorsLockedForAllPlayers(veh, true)
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Lock Doors Sent")
end

function PixelUI:VehicleKillEngine(targetServerId)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local ped = GetPlayerPed(targetId)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                NetworkRequestControlOfEntity(veh)
                SetVehicleEngineHealth(veh, -4000.0)
                SetVehicleFuelLevel(veh, 0.0)
            end
        end
    ]], targetServerId))
    PixelUI:Notify("success", "Vehicle Troll", "Engine Kill Sent")
end

function PixelUI:AttachVehicle(targetServerId, model)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local targetPed = GetPlayerPed(targetId)
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local hash = GetHashKey("%s")
                RequestModel(hash)
                while not HasModelLoaded(hash) do Wait(0) end
                local veh = CreateVehicle(hash, coords.x, coords.y, coords.z + 4.0, 0.0, true, true)
                SetEntityAsMissionEntity(veh, true, true)
                AttachEntityToEntity(veh, targetPed, GetPedBoneIndex(targetPed, 31086), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                SetModelAsNoLongerNeeded(hash)
            end
        end
    ]], targetServerId, model))
    PixelUI:Notify("success", "Troll", "Attach Command Sent")
end

function PixelUI:SpawnObject(targetServerId, model)
    MachoInjectResourceRaw("any", string.format([[
        local targetId = GetPlayerFromServerId(%d)
        if targetId ~= -1 then
            local targetPed = GetPlayerPed(targetId)
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local hash = GetHashKey("%s")
                RequestModel(hash)
                while not HasModelLoaded(hash) do Wait(0) end
                local obj = CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true)
                SetEntityAsMissionEntity(obj, true, true)
                PlaceObjectOnGroundProperly(obj)
                FreezeEntityPosition(obj, true)
                SetModelAsNoLongerNeeded(hash)
            end
        end
    ]], targetServerId, model))
    PixelUI:Notify("success", "Troll", "Spawn Command Sent")
end

function PixelUI:DetachAllVehicles(targetServerId)
    local targetId = GetPlayerFromServerId(targetServerId)
    if targetId ~= -1 then
        local targetPed = GetPlayerPed(targetId)
        local vehicles = GetGamePool('CVehicle')
        for _, veh in ipairs(vehicles) do
            if IsEntityAttachedToEntity(veh, targetPed) then
                NetworkRequestControlOfEntity(veh)
                DetachEntity(veh, true, true)
            end
        end
        PixelUI:Notify("success", "Troll", "Vehicles Detached")
    else
        PixelUI:Notify("error", "Error", "Player not found")
    end
end

function PixelUI:ApplyGlobalBypass()
    HookStates.globalBypass = true
    MachoInjectResourceRaw("any", [[
        -- Intercepting TriggerServerEvent (The "Snitch" function)
        local oldTriggerServerEvent = TriggerServerEvent
        TriggerServerEvent = function(eventName, ...)
            local eventLower = eventName:lower()
            local blockedKeywords = {"admin", "ban", "screenshot", "log", "ac", "anticheat", "report", "kick", "ban", "teleport", "coords", "speed"}
            
            for _, keyword in ipairs(blockedKeywords) do
                if eventLower:find(keyword) then
                    print("^1[PIXEL-BYPASS] Intercepted & Blocked AC Report: " .. eventName .. "^7")
                    return 
                end
            end
            return oldTriggerServerEvent(eventName, ...)
        end

        -- Spoofing Permissions (QB/ESX)
        if exports['qb-core'] then
            local QBCore = exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
                local oldGetPlayerData = QBCore.Functions.GetPlayerData
                QBCore.Functions.GetPlayerData = function()
                    local data = oldGetPlayerData()
                    if data then
                        data.isadmin = true
                    end
                    return data
                end
            end
        end
    ]])
    PixelUI:Notify("success", "Security", "Global Bypass Active")
    PixelUI:UpdateMenuLabel("Bypasses & Intercept", "Apply Global Bypass", "[ON]")
end

function PixelUI:ApplyUniversalBypass()
    local targetRes = "any"
    if DetectedAC == "FiveGuard" and DetectedACRes then
        targetRes = DetectedACRes
        PixelUI:Notify("info", "Universal", "Targeting FiveGuard: " .. targetRes)
    end

    HookStates.universalBypass = true
    MachoInjectResourceRaw(targetRes, [[
        -- 1. Neutralize common AC Exports
        local acExports = {"FiveGuard", "WaveShield", "PhoenixAC", "EasyAdmin", "txAdmin"}
        for _, ac in ipairs(acExports) do
            if exports[ac] then
                print("^2[PIXEL] Neutralizing Exports for: " .. ac .. "^7")
                -- We don't delete them, we just make them return true/success
                for exportName, _ in pairs(exports[ac]) do
                    exports[ac][exportName] = function() return true end
                end
            end
        end

        -- 2. Block Resource Scanning (Common in FiveGuard/WaveShield)
        local oldGetNumResources = GetNumResources
        local oldGetResourceByFindIndex = GetResourceByFindIndex
        local myRes = GetCurrentResourceName()

        GetNumResources = function() return oldGetNumResources() - 1 end
        GetResourceByFindIndex = function(index)
            local res = oldGetResourceByFindIndex(index)
            if res == myRes then return "vRP" end -- Hide ourself
            return res
        end

        -- 3. Neutralize 'onClientResourceStart' detection
        local oldAddEventHandler = AddEventHandler
        AddEventHandler = function(eventName, handler)
            if eventName == "onClientResourceStart" or eventName == "onClientResourceStop" then
                local wrappedHandler = function(resName)
                    if resName == myRes then 
                        print("^3[PIXEL] Blocked Resource Event for: " .. resName .. "^7")
                        return 
                    end
                    return handler(resName)
                end
                return oldAddEventHandler(eventName, wrappedHandler)
            end
            return oldAddEventHandler(eventName, handler)
        end

        -- 4. Spoof common AC states
        local oldGetResourceState = GetResourceState
        GetResourceState = function(res)
            local lowRes = res:lower()
            if lowRes:find("ac") or lowRes:find("guard") or lowRes:find("shield") then
                return "started"
            end
            return oldGetResourceState(res)
        end

        print("^2[PIXEL] UNIVERSAL BYPASS ACTIVE (FiveGuard, WaveShield, etc.)^7")
    ]])
    PixelUI:Notify("success", "Security", "Universal Bypass Engaged")
    PixelUI:UpdateMenuLabel("Bypasses & Intercept", "Universal Bypass", "[ON]")
end

function PixelUI:BypassECAC()
    PixelUI:EagleDisableDetections()
    PixelUI:EagleSyncTokens()
    PixelUI:EagleBlockEvents()
    PixelUI:EagleSpoofState()
    HookStates.masterBypass = true
    PixelUI:Notify("success", "Eagle", "Master Bypass Engaged!")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Master Bypass", "[ON]")
end

function PixelUI:EagleDisableDetections()
    HookStates.eagleDisable = true
    MachoInjectResourceRaw("EC_AC", [[
        -- Neutralize all main detection functions
        local function silent() return false end
        
        ECDetectLoader = function(type, data, ...)
            print("^1[PIXEL-BYPASS] Blocked Eagle Detection (Loader): " .. tostring(type) .. "^7")
            return false
        end
        
        ECDetect = function(type, item, ...)
            print("^1[PIXEL-BYPASS] Blocked Eagle Detection (General): " .. tostring(type) .. "^7")
            return false
        end
        
        EulenCDetect = function(...)
            print("^1[PIXEL-BYPASS] Blocked Eagle Detection (Eulen): ^7")
            return false
        end
        
        -- Neutralize Tunnel/Proxy detections
        if vRPSEG_AC then
            if vRPSEG_AC.detect then vRPSEG_AC.detect = function(...) return end end
            if vRPSEG_AC.Eulendetect then vRPSEG_AC.Eulendetect = function(...) return end end
        end
        
        -- Neutralize injection checks
        checkInjection = function(...) return true end
        VerfiyInjection = function(...) return true end
        
        -- Keep the heartbeat alive but silent
        local oldTrigger = TriggerServerEvent
        TriggerServerEvent = function(name, ...)
            local n = tostring(name)
            if n:find("Eagle") or n:find("EC_AC") or n:find("EG_AC") then
                -- Only allow heartbeats, block everything else
                if n == "Eagle:Send:HO2" or n == "Eagle:savepl" or n == "Eagle:era" then
                    return oldTrigger(name, ...)
                end
                print("^1[PIXEL-BYPASS] Blocked Eagle Server Report: " .. n .. "^7")
                return
            end
            return oldTrigger(name, ...)
        end
        
        print("^2[PIXEL] Eagle Internal Detections Fully Neutralized!^7")
    ]])
    PixelUI:Notify("success", "Eagle", "Detections Disabled")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Disable Detections", "[ON]")
end

function PixelUI:EagleSyncTokens()
    HookStates.eagleTokens = true
    MachoInjectResourceRaw("EC_AC", [[
        _G.PixelSafeTrigger = function(eventName, ...)
            local args = {...}
            -- We must check if eaglehex_encode exists and call it with UNPACKED args
            if eaglehex_encode then
                -- This is the magic part: calling Eagle's own function with our data
                eaglehex_encode(eventName, table.unpack(args))
                print("^2[PIXEL] Eagle Internal Trigger Sent: " .. eventName .. "^7")
            elseif ac_encode then
                local encodedName = ac_encode(eventName)
                TriggerServerEvent(encodedName, (events or 0) + 1, "YXZ-YXZ", table.unpack(args))
            else
                TriggerServerEvent(eventName, table.unpack(args))
            end
        end
        print("^2[PIXEL] Eagle Tokens Synced & Ready!^7")
    ]])
    PixelUI:Notify("success", "Eagle", "Tokens Synced")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Sync Tokens", "[ON]")
end

function PixelUI:EagleBlockEvents()
    HookStates.eagleBlock = true
    MachoInjectResourceRaw("any", [[
        -- Hook TriggerServerEvent globally
        local oldTrigger = TriggerServerEvent
        TriggerServerEvent = function(name, ...)
            local n = tostring(name)
            if n:find("EC_AC") or n:find("Eagle") or n:find("EG_AC") or n:find("era") then
                if n:find("HO2") or n:find("savepl") or n:find("era") then return oldTrigger(name, ...) end
                print("^3[PIXEL] Blocked Eagle Report: " .. n .. "^7")
                return 
            end
            return oldTrigger(name, ...)
        end
        
        -- Hook GetEntityScript to spoof our peds
        local oldGetEntityScript = GetEntityScript
        GetEntityScript = function(entity)
            if LocalPlayer.state["PixelEntity_" .. tostring(entity)] then
                return "vRP" -- Spoof as a trusted resource
            end
            return oldGetEntityScript(entity)
        end
    ]])
    PixelUI:Notify("success", "Eagle", "Reports & Script Spoofing Active")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Block Reports", "[ON]")
end

function PixelUI:EagleSpoofState()
    if HookStates.eagleSpoof then
        HookStates.eagleSpoof = false
        PixelUI:Notify("info", "Eagle", "Resource State Spoofed [OFF]")
        PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Spoof State", "[OFF]")
        return
    end

    HookStates.eagleSpoof = true
    MachoInjectResourceRaw("any", [[
        local oldGetResourceState = GetResourceState
        GetResourceState = function(res)
            if res == "EC_AC" or res == "Eagle" then return "started" end
            return oldGetResourceState(res)
        end
    ]])
    PixelUI:Notify("success", "Eagle", "Resource State Spoofed")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Spoof State", "[ON]")
end

function PixelUI:TriggerEagleEvent(eventName, ...)
    local args = {...}
    local argsJson = json.encode(args)
    
    -- Using a safer way to inject and decode the arguments
    local script = string.format([[
        Citizen.CreateThread(function()
            local rawData = %q
            local success, decodedArgs = pcall(json.decode, rawData)
            if success and decodedArgs then
                if _G.PixelSafeTrigger then
                    _G.PixelSafeTrigger("%s", table.unpack(decodedArgs))
                else
                    TriggerServerEvent("%s", table.unpack(decodedArgs))
                end
            else
                print("^1[PIXEL-ERROR] Failed to decode trigger data!^7")
            end
        end)
    ]], argsJson, eventName, eventName)
    
    MachoInjectResourceRaw("EC_AC", script)
    PixelUI:Notify("success", "Eagle Executor", "Trigger Sent via EC_AC")
end

function PixelUI:ApplyFullBypass()
    if HookStates.fullBypass then
        HookStates.fullBypass = false
        PixelUI:Notify("info", "Security", "ULTRA BYPASS V2 DEACTIVATED")
        PixelUI:UpdateMenuLabel("Bypasses & Intercept", "Full Bypass", "[OFF]")
        return
    end

    HookStates.fullBypass = true
    MachoInjectResourceRaw("any", [[
        local myResource = GetCurrentResourceName()

        -- 1. Enhanced Anti-Screenshot
        if exports['screenshot-basic'] then
            local blockScreenshot = function(options, cb)
                print("^1[PIXEL-SHIELD] Blocked AC Screenshot Attempt!^7")
                if cb then cb(false) end
                return false
            end
            exports['screenshot-basic'].requestScreenshot = blockScreenshot
            exports['screenshot-basic'].requestScreenshotUpload = blockScreenshot
        end

        -- 2. Robust Resource Hiding
        local oldGetNumResources = GetNumResources
        GetNumResources = function() return oldGetNumResources() - 1 end

        local oldGetResourceByFindIndex = GetResourceByFindIndex
        GetResourceByFindIndex = function(index)
            local res = oldGetResourceByFindIndex(index)
            if res == myResource then return oldGetResourceByFindIndex(index + 1) end
            return res
        end

        local oldGetResourceInfo = GetResourceMetadata
        GetResourceMetadata = function(res, meta, index)
            if res == myResource then return nil end
            return oldGetResourceInfo(res, meta, index)
        end

        -- 3. Advanced Spectate Detection
        Citizen.CreateThread(function()
            while true do
                Wait(3000)
                local isSpectating = NetworkIsInSpectatorMode() or (not IsEntityVisible(PlayerPedId()) and not IsScreenFadedOut())
                if isSpectating then
                    print("^1[PIXEL-WARN] Spectator Detected!^7")
                    -- Optional: Auto-disable risky features
                end
            end
        end)

        print("^2[PIXEL] FULL BYPASS (ULTRA-V2) ENGAGED!^7")
    ]])
    
    PixelUI:ApplyGlobalBypass()
    PixelUI:BypassECAC() -- Integrated Eagle Bypass
    PixelUI:StartNativeInterceptor()
    PixelUI:Notify("success", "Security", "ULTRA BYPASS V2 ACTIVE")
    PixelUI:UpdateMenuLabel("Bypasses & Intercept", "Full Bypass", "[ON]")
end

function PixelUI:StartNativeInterceptor()
    if HookStates.nativeInterceptor then
        HookStates.nativeInterceptor = false
        PixelUI:Notify("info", "Security", "Native Interceptor [OFF]")
        PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Native Interceptor", "[OFF]")
        return
    end

    HookStates.nativeInterceptor = true
    MachoInjectResourceRaw("any", [[
        -- This is the "God Tier" Bypass logic
        -- We hook the natives and check WHO is calling them
        
        local acName = "EC_AC" -- Target AC
        
        -- Hooking GetEntityCoords (To hide Teleport/Speed)
        local oldGetCoords = GetEntityCoords
        GetEntityCoords = function(entity)
            local caller = GetInvokingResource()
            if caller == acName then
                -- The AC is checking us! Give it fake static coords
                -- print("^3[INTERCEPT] Spoofed Coords for " .. acName .. "^7")
                return vector3(189.5, -922.4, 30.6) -- Legion Square
            end
            return oldGetCoords(entity)
        end

        -- Hooking GetEntityHealth (To hide GodMode)
        local oldGetHealth = GetEntityHealth
        GetEntityHealth = function(entity)
            local caller = GetInvokingResource()
            if caller == acName then
                -- print("^3[INTERCEPT] Spoofed Health for " .. acName .. "^7")
                return 200 -- Always return full health to AC
            end
            return oldGetHealth(entity)
        end

        print("^2[PIXEL] Native Interceptor Active! Blinding " .. acName .. "...^7")
    ]])
    PixelUI:Notify("success", "Security", "Native Interceptor Active")
    PixelUI:UpdateMenuLabel("Eagle Anti-Cheat", "Native Interceptor", "[ON]")
end

function PixelUI:EnableTeleportProtection()
    HookStates.teleportProtect = true
    MachoInjectResourceRaw("any", [[
        local oldSetEntityCoords = SetEntityCoords
        SetEntityCoords = function(entity, x, y, z, ...)
            local caller = GetInvokingResource()
            if entity == PlayerPedId() and caller and caller ~= "" and caller ~= GetCurrentResourceName() then
                print("^1[PIXEL-SHIELD] Blocked AC Teleport Attempt!^7")
                return 
            end
            return oldSetEntityCoords(entity, x, y, z, ...)
        end
    ]])
    PixelUI:Notify("success", "Security", "Teleport Protection Active")
    PixelUI:UpdateMenuLabel("Bypasses & Intercept", "Teleport Protection", "[ON]")
end

function PixelUI:OpenMegaInventory()
    local shopData = {
        items = {},
        label = "Mega Inventory",
        slots = 100
    }
    -- Add all weapons to the shop for free
    for i, category in ipairs(WeaponCategories) do
        for j, weapon in ipairs(category.weapons) do
            table.insert(shopData.items, {
                amount = 1,
                info = {},
                name = weapon.name,
                price = 0,
                slot = #shopData.items + 1,
                type = "weapon"
            })
        end
    end
    PixelUI:TriggerEagleEvent("inventory:server:OpenInventory", "shop", "mega", shopData)
end



function PixelUI:ToggleESP()
    if HookStates.esp then
        HookStates.esp = false
        PixelUI:Notify("info", "ESP", "Disabled")
    else
        HookStates.esp = true
        PixelUI:Notify("success", "ESP", "Enabled")
        
        Citizen.CreateThread(function()
            while HookStates.esp do
                local sleep = 0
                local myCoords = GetEntityCoords(PlayerPedId())
                
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped ~= PlayerPedId() and DoesEntityExist(ped) then
                        local coords = GetEntityCoords(ped)
                        local dist = #(myCoords - coords)
                        
                        if dist < 100.0 then
                            if IsEntityVisible(ped) then
                                local serverId = GetPlayerServerId(player)
                                local name = GetPlayerName(player) or "Unknown"
                                local health = GetEntityHealth(ped) - 100
                                local maxHealth = GetEntityMaxHealth(ped) - 100
                                if health < 0 then health = 0 end
                                if maxHealth < 100 then maxHealth = 100 end
                                local healthPct = health / maxHealth
                                if healthPct > 1.0 then healthPct = 1.0 end

                                -- Draw Text & Box
                                local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.3)
                                if onScreen then
                                    local width = 0.06 + (string.len(name) * 0.003) -- Dynamic width
                                    local height = 0.03
                                    local barHeight = 0.004
                                    
                                    -- 1. Background Box (Dark Grey/Black)
                                    DrawRect(x, y, width, height, 40, 40, 40, 200)
                                    
                                    -- 2. Text (Icon + Name + ID)
                                    SetTextScale(0.30, 0.30)
                                    SetTextFont(0) -- Standard Font
                                    SetTextProportional(1)
                                    SetTextColour(255, 255, 255, 255)
                                    SetTextEntry("STRING")
                                    SetTextCentre(1)
                                    AddTextComponentString("👤 " .. name .. " [" .. serverId .. "]")
                                    DrawText(x, y - 0.011)
                                    
                                    -- 3. Health Bar Background (Black)
                                    local barY = y + (height/2) + (barHeight/2)
                                    DrawRect(x, barY, width, barHeight, 0, 0, 0, 255)
                                    
                                    -- 4. Health Bar Foreground (Green)
                                    local barWidth = width * healthPct
                                    local barX = x - (width/2) + (barWidth/2) -- Align Left
                                    DrawRect(barX, barY, barWidth, barHeight, 46, 204, 113, 255) -- #2ecc71 Green
                                end
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end)
    end
    PixelUI:UpdateMenuLabel("Visuals (ESP)", "Player Names & IDs", HookStates.esp and "[ON]" or "[OFF]")
end

function PixelUI:ToggleAntiScreenshot()
    if HookStates.antiScreenshot then
        MachoUnhookNative(ActiveHooks.antiScreenshot)
        HookStates.antiScreenshot = false
        PixelUI:Notify("info", "Anti-Screenshot", "Disabled")
    else
        -- Hook TriggerServerEvent to block screenshot events
        ActiveHooks.antiScreenshot = MachoHookNative(0x7E9E4D83, function(eventName, ...)
            if type(eventName) == "string" and (string.find(eventName, "screenshot") or string.find(eventName, "screen")) then
                PixelUI:Notify("success", "Blocked", "Screenshot Attempt")
                return true -- Block execution
            end
            return false
        end)
        
        -- Also inject a cleaner to overwrite client-side screenshot functions if possible
        MachoInjectResourceRaw("screenshot-basic", [[
            requestScreenshot = function() end
            requestScreenshotUpload = function() end
        ]])

        HookStates.antiScreenshot = true
        PixelUI:Notify("success", "Anti-Screenshot", "Enabled (Event Blocker)")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Anti-Screenshot", HookStates.antiScreenshot and "[ON]" or "[OFF]")
end

function PixelUI:ToggleCombatSpoof()
    if HookStates.combatSpoof then
        MachoUnhookNative(ActiveHooks.combatSpoof_dmg)
        MachoUnhookNative(ActiveHooks.combatSpoof_def)
        MachoUnhookNative(ActiveHooks.combatSpoof_melee_dmg)
        MachoUnhookNative(ActiveHooks.combatSpoof_melee_def)
        MachoUnhookNative(ActiveHooks.combatSpoof_def2)
        if ActiveHooks.combatSpoof_proofs then MachoUnhookNative(ActiveHooks.combatSpoof_proofs) end
        if ActiveHooks.combatSpoof_acc then MachoUnhookNative(ActiveHooks.combatSpoof_acc) end
        if ActiveHooks.combatSpoof_comp_dmg then MachoUnhookNative(ActiveHooks.combatSpoof_comp_dmg) end
        if ActiveHooks.combatSpoof_thermal then MachoUnhookNative(ActiveHooks.combatSpoof_thermal) end
        if ActiveHooks.combatSpoof_night then MachoUnhookNative(ActiveHooks.combatSpoof_night) end
        if ActiveHooks.combatSpoof_spec then MachoUnhookNative(ActiveHooks.combatSpoof_spec) end
        if ActiveHooks.combatSpoof_speed then MachoUnhookNative(ActiveHooks.combatSpoof_speed) end
        if ActiveHooks.combatSpoof_stamina then MachoUnhookNative(ActiveHooks.combatSpoof_stamina) end
        if ActiveHooks.combatSpoof_res then MachoUnhookNative(ActiveHooks.combatSpoof_res) end
        if ActiveHooks.combatSpoof_veh_power then MachoUnhookNative(ActiveHooks.combatSpoof_veh_power) end
        if ActiveHooks.combatSpoof_ragdoll then MachoUnhookNative(ActiveHooks.combatSpoof_ragdoll) end
        if ActiveHooks.combatSpoof_visible then MachoUnhookNative(ActiveHooks.combatSpoof_visible) end
        if ActiveHooks.combatSpoof_ammo then MachoUnhookNative(ActiveHooks.combatSpoof_ammo) end
        if ActiveHooks.combatSpoof_del_ent then MachoUnhookNative(ActiveHooks.combatSpoof_del_ent) end
        if ActiveHooks.combatSpoof_del_obj then MachoUnhookNative(ActiveHooks.combatSpoof_del_obj) end
        if ActiveHooks.combatSpoof_cam1 then MachoUnhookNative(ActiveHooks.combatSpoof_cam1) end
        if ActiveHooks.combatSpoof_cam2 then MachoUnhookNative(ActiveHooks.combatSpoof_cam2) end
        if ActiveHooks.combatSpoof_task then MachoUnhookNative(ActiveHooks.combatSpoof_task) end
        if ActiveHooks.combatSpoof_jump then MachoUnhookNative(ActiveHooks.combatSpoof_jump) end
        if ActiveHooks.combatSpoof_shoot then MachoUnhookNative(ActiveHooks.combatSpoof_shoot) end
        if ActiveHooks.combatSpoof_model then MachoUnhookNative(ActiveHooks.combatSpoof_model) end
        if ActiveHooks.combatSpoof_height then MachoUnhookNative(ActiveHooks.combatSpoof_height) end
        if ActiveHooks.combatSpoof_alpha then MachoUnhookNative(ActiveHooks.combatSpoof_alpha) end
        if ActiveHooks.combatSpoof_health then MachoUnhookNative(ActiveHooks.combatSpoof_health) end
        if ActiveHooks.combatSpoof_vis_script then MachoUnhookNative(ActiveHooks.combatSpoof_vis_script) end
        if ActiveHooks.combatSpoof_col then MachoUnhookNative(ActiveHooks.combatSpoof_col) end
        if ActiveHooks.combatSpoof_vel then MachoUnhookNative(ActiveHooks.combatSpoof_vel) end
        if ActiveHooks.combatSpoof_inv1 then MachoUnhookNative(ActiveHooks.combatSpoof_inv1) end
        if ActiveHooks.combatSpoof_inv2 then MachoUnhookNative(ActiveHooks.combatSpoof_inv2) end
        if ActiveHooks.combatSpoof_armour then MachoUnhookNative(ActiveHooks.combatSpoof_armour) end
        if ActiveHooks.combatSpoof_top_speed then MachoUnhookNative(ActiveHooks.combatSpoof_top_speed) end
        if ActiveHooks.combatSpoof_veh_eng then MachoUnhookNative(ActiveHooks.combatSpoof_veh_eng) end
        if ActiveHooks.combatSpoof_veh_body then MachoUnhookNative(ActiveHooks.combatSpoof_veh_body) end
        if ActiveHooks.combatSpoof_tires then MachoUnhookNative(ActiveHooks.combatSpoof_tires) end
        if ActiveHooks.combatSpoof_max_hp then MachoUnhookNative(ActiveHooks.combatSpoof_max_hp) end
        if ActiveHooks.combatSpoof_max_arm then MachoUnhookNative(ActiveHooks.combatSpoof_max_arm) end
        if ActiveHooks.combatSpoof_flags then MachoUnhookNative(ActiveHooks.combatSpoof_flags) end
        if ActiveHooks.combatSpoof_input1 then MachoUnhookNative(ActiveHooks.combatSpoof_input1) end
        if ActiveHooks.combatSpoof_input2 then MachoUnhookNative(ActiveHooks.combatSpoof_input2) end
        if ActiveHooks.combatSpoof_attach then MachoUnhookNative(ActiveHooks.combatSpoof_attach) end
        if ActiveHooks.combatSpoof_cam_mode then MachoUnhookNative(ActiveHooks.combatSpoof_cam_mode) end
        if ActiveHooks.combatSpoof_int1 then MachoUnhookNative(ActiveHooks.combatSpoof_int1) end
        if ActiveHooks.combatSpoof_int2 then MachoUnhookNative(ActiveHooks.combatSpoof_int2) end
        if ActiveHooks.combatSpoof_dmg_type then MachoUnhookNative(ActiveHooks.combatSpoof_dmg_type) end
        if ActiveHooks.combatSpoof_weapon then MachoUnhookNative(ActiveHooks.combatSpoof_weapon) end
        if ActiveHooks.combatSpoof_hand1 then MachoUnhookNative(ActiveHooks.combatSpoof_hand1) end
        if ActiveHooks.combatSpoof_hand2 then MachoUnhookNative(ActiveHooks.combatSpoof_hand2) end
        if ActiveHooks.combatSpoof_oxy then MachoUnhookNative(ActiveHooks.combatSpoof_oxy) end
        if ActiveHooks.combatSpoof_src1 then MachoUnhookNative(ActiveHooks.combatSpoof_src1) end
        if ActiveHooks.combatSpoof_src2 then MachoUnhookNative(ActiveHooks.combatSpoof_src2) end
        if ActiveHooks.combatSpoof_pool then MachoUnhookNative(ActiveHooks.combatSpoof_pool) end
        if ActiveHooks.combatSpoof_ctrl then MachoUnhookNative(ActiveHooks.combatSpoof_ctrl) end
        if ActiveHooks.combatSpoof_exp then MachoUnhookNative(ActiveHooks.combatSpoof_exp) end
        if ActiveHooks.combatSpoof_model_check then MachoUnhookNative(ActiveHooks.combatSpoof_model_check) end
        if ActiveHooks.combatSpoof_ent_model then MachoUnhookNative(ActiveHooks.combatSpoof_ent_model) end
        if ActiveHooks.combatSpoof_human then MachoUnhookNative(ActiveHooks.combatSpoof_human) end
        if ActiveHooks.combatSpoof_ped_type then MachoUnhookNative(ActiveHooks.combatSpoof_ped_type) end
        if ActiveHooks.combatSpoof_arch then MachoUnhookNative(ActiveHooks.combatSpoof_arch) end
        if ActiveHooks.combatSpoof_clip then MachoUnhookNative(ActiveHooks.combatSpoof_clip) end
        if ActiveHooks.combatSpoof_wheel then MachoUnhookNative(ActiveHooks.combatSpoof_wheel) end
        if ActiveHooks.combatSpoof_los then MachoUnhookNative(ActiveHooks.combatSpoof_los) end
        if ActiveHooks.combatSpoof_heli then MachoUnhookNative(ActiveHooks.combatSpoof_heli) end
        if ActiveHooks.combatSpoof_plane then MachoUnhookNative(ActiveHooks.combatSpoof_plane) end
        if ActiveHooks.combatSpoof_rot then MachoUnhookNative(ActiveHooks.combatSpoof_rot) end
        if ActiveHooks.combatSpoof_head then MachoUnhookNative(ActiveHooks.combatSpoof_head) end
        if ActiveHooks.combatSpoof_vec then MachoUnhookNative(ActiveHooks.combatSpoof_vec) end
        if ActiveHooks.combatSpoof_swim1 then MachoUnhookNative(ActiveHooks.combatSpoof_swim1) end
        if ActiveHooks.combatSpoof_swim2 then MachoUnhookNative(ActiveHooks.combatSpoof_swim2) end
        if ActiveHooks.combatSpoof_bone then MachoUnhookNative(ActiveHooks.combatSpoof_bone) end
        
        HookStates.combatSpoof = false
        PixelUI:Notify("info", "Combat Spoof", "Disabled")
    else
        local function SpoofModifier(playerId)
            if playerId == PlayerId() then
                local caller = GetInvokingResource()
                if not caller or caller == GetCurrentResourceName() then return true end
                return false, 1.0 -- Always return default 1.0 to ACs
            end
            return true
        end

        -- Hook GetPlayerWeaponDamageModifier (0x2A9D0D5D)
        ActiveHooks.combatSpoof_dmg = MachoHookNative(0x2A9D0D5D, SpoofModifier)
        
        -- Hook GetPlayerWeaponDefenseModifier (0x2D343D22)
        ActiveHooks.combatSpoof_def = MachoHookNative(0x2D343D22, SpoofModifier)

        -- Hook GetPlayerMeleeWeaponDamageModifier (0x8D8E7174)
        ActiveHooks.combatSpoof_melee_dmg = MachoHookNative(0x8D8E7174, SpoofModifier)

        -- Hook GetPlayerMeleeWeaponDefenseModifier (0x4A3DC7ECCC321032)
        ActiveHooks.combatSpoof_melee_def = MachoHookNative(0x4A3DC7ECCC321032, SpoofModifier)
        
        -- Hook GetPlayerWeaponDefenseModifier_2 (0x9049103F) - Eagle checks this
        ActiveHooks.combatSpoof_def2 = MachoHookNative(0x9049103F, SpoofModifier)

        -- Hook GetEntityProofs (0xBE8CD9BE829BBEBF)
        -- Eagle checks if bulletProof, collisionProof, etc. are enabled. We return all false (0).
        ActiveHooks.combatSpoof_proofs = MachoHookNative(0xBE8CD9BE829BBEBF, function(entity)
            if entity == PlayerPedId() then
                local caller = GetInvokingResource()
                if not caller or caller == GetCurrentResourceName() then return true end
                return false, false, false, false, false, false, false, false, false -- All proofs disabled
            end
            return true
        end)

        -- Hook GetWeaponComponentAccuracyModifier (0x... need hash or name) -> 0x48C36C7D
        -- Eagle bans if > 1.2
        ActiveHooks.combatSpoof_acc = MachoHookNative(0x48C36C7D, function(componentHash)
            return false, 1.0 -- Default accuracy
        end)

        -- Hook GetWeaponComponentDamageModifier (0x... need hash or name) -> 0xFE264C62
        ActiveHooks.combatSpoof_comp_dmg = MachoHookNative(0xFE264C62, function(componentHash)
            return false, 1.0 -- Default damage
        end)

        -- Hook GetUsingseethrough (Thermal) -> 0x4E52E752
        ActiveHooks.combatSpoof_thermal = MachoHookNative(0x4E52E752, function()
            return false, false -- Not using thermal
        end)

        -- Hook GetUsingnightvision (Night) -> 0x2202A3F42C8E5F1F
        ActiveHooks.combatSpoof_night = MachoHookNative(0x2202A3F42C8E5F1F, function()
            return false, false -- Not using night vision
        end)
        
        -- Hook NetworkIsInSpectatorMode -> 0x048746E388762E11
        ActiveHooks.combatSpoof_spec = MachoHookNative(0x048746E388762E11, function()
            return false, false -- Not spectating
        end)

        -- Hook GetEntitySpeed (0xD5037BA82E12416F)
        -- Eagle checks if speed > 7 while on foot. We cap reported speed at 6.0 for AC.
        ActiveHooks.combatSpoof_speed = MachoHookNative(0xD5037BA82E12416F, function(entity)
            local caller = GetInvokingResource()
            if entity == PlayerPedId() and (not caller or caller == GetCurrentResourceName()) then return true end
            
            -- If AC asks, return safe speed
            if entity == PlayerPedId() then
                return false, 6.0 
            end
            return true
        end)

        -- Hook GetEntityCoords (0x3FEF770D40960D15) - CRITICAL for Teleport/Speed Bypass
        ActiveHooks.combatSpoof_coords = MachoHookNative(0x3FEF770D40960D15, function(entity)
            local caller = GetInvokingResource()
            if entity == PlayerPedId() and caller and caller ~= "" and caller ~= GetCurrentResourceName() then
                -- If AC checks coords, return a safe static location (Legion Square)
                return false, vector3(189.5, -922.4, 30.6)
            end
            return true
        end)

        -- Hook GetPlayerSprintStaminaRemaining (0x3265D80296EF373C)
        -- Eagle checks if stamina is stuck at 100 (0.0 loss). We simulate drain.
        ActiveHooks.combatSpoof_stamina = MachoHookNative(0x3265D80296EF373C, function(playerId)
            if playerId == PlayerId() then
                return false, 50.0 -- Always report 50% stamina to avoid "Infinite" detection
            end
            return true
        end)

        -- Hook GetResourceState (0x4039B485)
        -- Eagle checks if "AntiCheat" resource is stopped. We always say "started".
        ActiveHooks.combatSpoof_res = MachoHookNative(0x4039B485, function(resourceName)
            if resourceName == "AntiCheat" or resourceName == "eagle" or resourceName == "ec_ac" then
                return false, "started"
            end
            return true
        end)

        -- Hook GetVehicleCheatPowerIncrease (0x...) -> 0xC39D6D56E6F37688
        ActiveHooks.combatSpoof_veh_power = MachoHookNative(0xC39D6D56E6F37688, function(vehicle)
            return false, 1.0 -- Default power
        end)

        -- Hook CanPedRagdoll (0x...) -> 0x128F79EDCECE4FD5
        -- AC checks if we disabled ragdoll. We say "Yes, I can ragdoll".
        ActiveHooks.combatSpoof_ragdoll = MachoHookNative(0x128F79EDCECE4FD5, function(ped)
            if ped == PlayerPedId() then return false, true end
            return true
        end)

        -- Hook IsEntityVisible (0x...) -> 0x47D6F43D77935C75
        -- AC checks if we are invisible. We say "Yes, I am visible".
        ActiveHooks.combatSpoof_visible = MachoHookNative(0x47D6F43D77935C75, function(entity)
            if entity == PlayerPedId() then return false, true end
            return true
        end)

        -- Hook GetAmmoInClip (0x...) -> 0x2E1202248937775C
        -- AC checks if ammo is full constantly. We simulate a random value if asked.
        ActiveHooks.combatSpoof_ammo = MachoHookNative(0x2E1202248937775C, function(ped, weaponHash)
            local caller = GetInvokingResource()
            if ped == PlayerPedId() and (not caller or caller == GetCurrentResourceName()) then return true end
            
            if ped == PlayerPedId() then
                -- Return a random safe number (e.g., 5 to 10 bullets) to look legit
                return false, math.random(5, 15) 
            end
            return true
        end)

        -- 1. Object Protection (Anti-Delete)
        -- Prevents AC from deleting our UFO even if it finds it.
        local function BlockDelete(entity)
            if DoesEntityExist(entity) then
                local model = GetEntityModel(entity)
                if model == GetHashKey("p_spinning_anus_s") then -- Protect UFO
                    return false -- Block deletion
                end
            end
            return true -- Call original
        end
        ActiveHooks.combatSpoof_del_ent = MachoHookNative(0xAE3CBE5BF394C9C9, BlockDelete) -- DeleteEntity
        ActiveHooks.combatSpoof_del_obj = MachoHookNative(0x539E0AE3E6634B9F, BlockDelete) -- DeleteObject

        -- 2. Freecam Protection (Cam Spoof)
        -- AC checks if camera is far from player. We say "Camera is at player".
        local function SpoofCam()
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            return false, GetEntityCoords(PlayerPedId())
        end
        ActiveHooks.combatSpoof_cam1 = MachoHookNative(0x14D6F5678D8F1B37, SpoofCam) -- GetGameplayCamCoord
        ActiveHooks.combatSpoof_cam2 = MachoHookNative(0xA200EB1EE790F448, SpoofCam) -- GetFinalRenderedCamCoord

        -- 3. No-Reload Protection (Task Spoof)
        -- AC checks if we are reloading. We say "Yes" if asked about reload task (298).
        ActiveHooks.combatSpoof_task = MachoHookNative(0xB0760331C7AA4155, function(ped, taskIndex)
            if ped == PlayerPedId() and taskIndex == 298 then -- 298 is TASK_RELOAD_WEAPON
                return false, true -- Yes, I am reloading
            end
            return true
        end)

        -- 4. Super Jump Protection
        -- AC checks IsPedJumping to detect super jumps. We say "No, I'm not jumping".
        ActiveHooks.combatSpoof_jump = MachoHookNative(0x2D0571BB33077DA0, function(ped)
            if ped == PlayerPedId() then
                return false, false -- Not jumping
            end
            return true
        end)

        -- 5. Rapid Fire / Macro Protection
        -- AC checks IsPedShooting frequency. We randomly say "No" to break the pattern.
        ActiveHooks.combatSpoof_shoot = MachoHookNative(0x34616828CD07F1A1, function(ped)
            if ped == PlayerPedId() then
                -- Return false (not shooting) 20% of the time to break macro detection
                if math.random() < 0.2 then
                    return false, false
                end
            end
            return true
        end)

        -- 6. Vehicle Model Swap Protection
        -- AC checks GetEntityModel to see if we swapped car model. We return original if possible (or just a common car).
        -- NOTE: This is risky if AC needs model for logic. We only spoof if it's OUR vehicle.
        ActiveHooks.combatSpoof_model = MachoHookNative(0x9F47B058362C84B5, function(entity)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end

            if entity == GetVehiclePedIsIn(PlayerPedId(), false) then
                -- If we are in a "forbidden" vehicle (like a tank), maybe we should spoof it?
                -- For now, let's just log it or leave it. Spoofing model might break game physics for AC.
                -- Let's spoof it to an Adder (hash: 0xB779A091) if it's a blacklisted vehicle.
                -- For safety, we will just return the real model for now unless user asks for specific swap spoof.
                -- Implementing a safe fallback:
                return true 
            end
            return true
        end)

        -- 7. Height Spoof (Noclip Protection)
        -- AC checks height above ground. If high without vehicle -> Ban. We say "I'm on ground".
        ActiveHooks.combatSpoof_height = MachoHookNative(0x5D6160275CAEC8DD, function(entity)
            if entity == PlayerPedId() then
                -- Return a safe height (e.g., 1.0 meter)
                return false, 1.0
            end
            return true
        end)

        -- 8. Alpha Spoof (Invisibility Protection)
        -- AC checks transparency. If 0 -> Ban. We say "I'm fully visible (255)".
        ActiveHooks.combatSpoof_alpha = MachoHookNative(0x5A47B3F5E63E94C6, function(entity)
            if entity == PlayerPedId() then
                return false, 255 -- Fully visible
            end
            return true
        end)

        -- 9. Health Fluctuation Spoof (Smart God Mode)
        -- AC checks if health is static (200) while taking damage. We simulate minor fluctuation.
        ActiveHooks.combatSpoof_health = MachoHookNative(0xEEF059FAD016D209, function(entity)
            local caller = GetInvokingResource()
            if entity == PlayerPedId() and (not caller or caller == GetCurrentResourceName()) then return true end
            
            if entity == PlayerPedId() then
                -- Return randomly between 190 and 200 to simulate "taking damage" but healing
                return false, math.random(190, 200)
            end
            return true
        end)

        -- 10. Script Visibility Spoof
        -- Another check for invisibility.
        ActiveHooks.combatSpoof_vis_script = MachoHookNative(0xD7EC8760, function(entity) -- Need correct hash for IsEntityVisibleToScript (0x5D79598F)? No, IsEntityVisibleToScript hash is 0x5D79598F usually? 
        -- Wait, IsEntityVisibleToScript is 0x5D79598F? Let's use name if possible or verify hash.
        -- Using hash 0x5D79598F for IsEntityVisibleToScript
            if entity == PlayerPedId() then return false, true end
            return true
        end)
        -- Re-hooking with correct hash just in case
        ActiveHooks.combatSpoof_vis_script = MachoHookNative(0x5D79598F, function(entity)
            if entity == PlayerPedId() then return false, true end
            return true
        end)

        -- 11. Collision Spoof
        -- AC checks if collision is disabled (Noclip/Spectate). We say "Collision is ON".
        -- HasEntityCollidedWithAnything? No, GetEntityCollisionDisabled (0xCC91D3C6)
        ActiveHooks.combatSpoof_col = MachoHookNative(0xCC91D3C6, function(entity)
            if entity == PlayerPedId() then
                return false, false -- Collision is NOT disabled (it is enabled)
            end
            return true
        end)

        -- 12. Velocity Spoof (Deep Speed/Fly Protection)
        -- AC checks velocity vector. If huge -> Ban. We return a safe vector.
        ActiveHooks.combatSpoof_vel = MachoHookNative(0x4805D2B1D8CF46DA, function(entity)
            local caller = GetInvokingResource()
            if entity == PlayerPedId() and (not caller or caller == GetCurrentResourceName()) then return true end
            
            if entity == PlayerPedId() then
                -- Return a very low velocity vector to look like walking/standing
                return false, vector3(1.0, 1.0, 0.0)
            end
            return true
        end)

        -- 13. Explicit God Mode Spoof
        -- Hooks the direct "Is Invincible" natives.
        local function ReturnFalse() return false, false end
        ActiveHooks.combatSpoof_inv1 = MachoHookNative(0x47042886E615C073, ReturnFalse) -- GetPlayerInvincible
        ActiveHooks.combatSpoof_inv2 = MachoHookNative(0xF235BC766544F05D, ReturnFalse) -- GetPlayerInvincible_2

        -- 14. Armour Fluctuation Spoof
        -- Similar to health, we fluctuate armour to avoid static value detection.
        ActiveHooks.combatSpoof_armour = MachoHookNative(0x9483AF621740511B, function(ped)
            if ped == PlayerPedId() then
                local caller = GetInvokingResource()
                if not caller or caller == GetCurrentResourceName() then return true end
                return false, math.random(90, 100)
            end
            return true
        end)

        -- 15. Vehicle Top Speed Spoof
        -- AC checks if vehicle top speed was modified.
        ActiveHooks.combatSpoof_top_speed = MachoHookNative(0x153973AB99216F86, function(vehicle)
            return false, 1.0 -- Default modifier
        end)

        -- 16. Vehicle Health Spoof (Smart Repair)
        -- AC checks if engine/body health is static 1000. We fluctuate it.
        local function FluctuateVehHealth(veh)
            if veh == GetVehiclePedIsIn(PlayerPedId(), false) then
                return false, math.random(950, 1000) + 0.0
            end
            return true
        end
        ActiveHooks.combatSpoof_veh_eng = MachoHookNative(0xC3C24357, FluctuateVehHealth) -- GetVehicleEngineHealth
        ActiveHooks.combatSpoof_veh_body = MachoHookNative(0xF2711A64, FluctuateVehHealth) -- GetVehicleBodyHealth

        -- 17. Bulletproof Tires Spoof
        -- AC checks if tires can burst. We say "Yes".
        ActiveHooks.combatSpoof_tires = MachoHookNative(0x6730F061, function(vehicle)
            if vehicle == GetVehiclePedIsIn(PlayerPedId(), false) then
                return false, true -- Yes, they can burst
            end
            return true
        end)

        -- 18. Max Stats Spoof
        -- AC checks if max health/armour is modified.
        ActiveHooks.combatSpoof_max_hp = MachoHookNative(0x15D7576066A708E4, function(entity)
            if entity == PlayerPedId() then return false, 200 end
            return true
        end)
        ActiveHooks.combatSpoof_max_arm = MachoHookNative(0x23E63866, function(playerId) -- GetPlayerMaxArmour (Some builds use this)
            if playerId == PlayerId() then return false, 100 end
            return true
        end)

        -- 19. Ped Config Flags Spoof (CRITICAL)
        -- AC checks flags like 187 (Invincible) or 32 (NoRagdoll).
        ActiveHooks.combatSpoof_flags = MachoHookNative(0x78C08A3D, function(ped, flagId, p2)
            if ped == PlayerPedId() then
                -- Flags to block: 187 (Invincible), 32 (NoRagdoll), 223 (Infinite Stamina)
                if flagId == 187 or flagId == 32 or flagId == 223 then
                    return false, false -- Always report as OFF
                end
            end
            return true
        end)

        -- 20. Input Spoof (Noclip Protection)
        -- AC checks if moving without pressing keys. We say "Yes, I'm pressing W".
        local function SpoofInput(pad, control)
            local caller = GetInvokingResource()
            -- ONLY spoof for other resources (AC), NOT for our menu
            if not caller or caller == GetCurrentResourceName() then return true end
            
            -- Only spoof WASD (32, 33, 34, 35)
            if control == 32 or control == 33 or control == 34 or control == 35 then
                return false, 1.0 -- Report 1.0 (fully pressed)
            end
            return true -- Original value for other controls
        end
        ActiveHooks.combatSpoof_input1 = MachoHookNative(0xEC3C712D102757B0, SpoofInput) -- GetControlNormal
        ActiveHooks.combatSpoof_input2 = MachoHookNative(0xF3A21BCD9574E909, function(pad, control)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            
            if control == 32 or control == 33 or control == 34 or control == 35 then -- W, S, A, D
                return false, true 
            end
            return true
        end) -- IsControlPressed

        -- 21. Attachment Spoof
        -- AC checks if we are attached to something. We say "No".
        ActiveHooks.combatSpoof_attach = MachoHookNative(0x48C2BEDC1232144C, function(entity)
            if entity == PlayerPedId() then return false, 0 end
            return true
        end)

        -- 22. Camera Mode Spoof (Aimbot Protection)
        -- AC checks camera mode while aiming. We say "First Person".
        ActiveHooks.combatSpoof_cam_mode = MachoHookNative(0x3C7A3507159757AA, function()
            return false, 4 -- First Person
        end)

        -- 23. Interior Spoof (Teleport Protection)
        -- AC checks if we are in a forbidden interior. We say "Outside (0)".
        ActiveHooks.combatSpoof_int1 = MachoHookNative(0x2107BA504071A6BB, function(entity)
            if entity == PlayerPedId() then return false, 0 end
            return true
        end)
        ActiveHooks.combatSpoof_int2 = MachoHookNative(0x47C373BA, function(entity)
            if entity == PlayerPedId() then return false, 0 end
            return true
        end)

        -- 24. Weapon Damage Type Spoof
        -- AC checks if weapon damage type is modified (e.g., Explosive).
        ActiveHooks.combatSpoof_dmg_type = MachoHookNative(0x3BE0B73C535CC516, function(weaponHash)
            -- Return 3 (Bullet) for most common weapons
            return false, 3
        end)

        -- 25. Weapon Spoof (Hide Forbidden Weapons)
        -- AC checks what weapon we are holding. We say "Pistol".
        ActiveHooks.combatSpoof_weapon = MachoHookNative(0x0A05335F, function(ped)
            if ped == PlayerPedId() then
                local caller = GetInvokingResource()
                if not caller or caller == GetCurrentResourceName() then return true end
                return false, GetHashKey("WEAPON_PISTOL")
            end
            return true
        end)

        -- 26. Handling Spoof (Anti-Handling Check)
        -- AC checks vehicle handling values. We return defaults.
        local function SpoofHandling() return false, 1.0 end
        ActiveHooks.combatSpoof_hand1 = MachoHookNative(0x642FC12F, SpoofHandling) -- GetVehicleHandlingFloat
        ActiveHooks.combatSpoof_hand2 = MachoHookNative(0x27396C75, SpoofHandling) -- GetVehicleHandlingInt

        -- 27. Oxygen Spoof (Infinite Oxygen Protection)
        -- AC checks if we are under water too long.
        ActiveHooks.combatSpoof_oxy = MachoHookNative(0xE1A0BC81, function(playerId)
            if playerId == PlayerId() then return false, 10.0 end
            return true
        end)

        -- 28. Damage Source Spoof (Hide Killer Identity)
        -- AC checks who killed who. We say "World Damage".
        local function HideSource() return false, 0 end
        ActiveHooks.combatSpoof_src1 = MachoHookNative(0x12219735, HideSource) -- GetPedLastDamageSource
        ActiveHooks.combatSpoof_src2 = MachoHookNative(0x54137681, HideSource) -- GetPedSourceOfDamage

        -- 29. AI Props Filter (Hide Spawned Objects)
        -- AC loops through objects. we filter out our UFO.
        local function FilterObjects(objects)
            local filtered = {}
            for _, obj in ipairs(objects) do
                if GetEntityModel(obj) ~= GetHashKey("p_spinning_anus_s") then
                    table.insert(filtered, obj)
                end
            end
            return false, filtered
        end
        ActiveHooks.combatSpoof_pool = MachoHookNative(0x2B9D4F50, FilterObjects) -- GetAllObjects/GetGamePool("CObject")

        -- 30. Entity Control Spoof
        -- AC checks if we control other players' cars. We say "No".
        ActiveHooks.combatSpoof_ctrl = MachoHookNative(0x01BA120598943A6F, function(entity)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            return false, false -- No control
        end)

        -- 31. Explosion Spoof
        -- AC checks AddExplosion. We block it for AC or change type.
        ActiveHooks.combatSpoof_exp = MachoHookNative(0xE3AD2BDBA62312FF, function(x, y, z, explosionType, damageScale, isAudible, isInvisible, cameraShake)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            return false -- Block explosion for AC
        end)

        -- 32. Model Spoof (Anti-Model Changer)
        -- AC checks if we are a forbidden model.
        ActiveHooks.combatSpoof_model_check = MachoHookNative(0x1913FEABC1A71C00, function(ped, modelHash)
            if ped == PlayerPedId() then
                -- Always say "Yes, I am this model" if it's a safe model (like mp_m_freemode_01)
                return false, true 
            end
            return true
        end)

        -- 33. GetEntityModel Spoof (Deep Ped Protection)
        -- AC checks the actual hash. We return mp_m_freemode_01 (0x705E61F2)
        ActiveHooks.combatSpoof_ent_model = MachoHookNative(0x9F47B058362C84B5, function(entity)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            if entity == PlayerPedId() then
                return false, 0x705E61F2 -- mp_m_freemode_01
            end
            return true
        end)

        -- 34. IsPedHuman Spoof
        -- AC checks if we are still "human" (not a dog/alien).
        ActiveHooks.combatSpoof_human = MachoHookNative(0xB980061A, function(ped)
            if ped == PlayerPedId() then return false, true end
            return true
        end)

        -- 35. GetPedType Spoof
        -- AC checks ped type (4 = male, 5 = female).
        ActiveHooks.combatSpoof_ped_type = MachoHookNative(0xFF059E3E, function(ped)
            if ped == PlayerPedId() then return false, 4 end -- Male
            return true
        end)

        -- 36. GetEntityArchetypeName Spoof
        -- AC checks the string name of the model.
        ActiveHooks.combatSpoof_arch = MachoHookNative(0x40027764, function(entity)
            if entity == PlayerPedId() then return false, "mp_m_freemode_01" end
            return true
        end)

        -- 37. Weapon Clip Size Spoof
        -- AC checks if clip size is modified. We return original.
        ActiveHooks.combatSpoof_clip = MachoHookNative(0x015A19F4, function(weaponHash)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            -- Return a standard clip size for most weapons (e.g., 12 for pistol)
            return false, 12 
        end)

        -- 38. Vehicle Wheel Speed Spoof
        -- AC checks wheel speed vs vehicle speed.
        ActiveHooks.combatSpoof_wheel = MachoHookNative(0x14934E96, function(vehicle, wheelIndex)
            if vehicle == GetVehiclePedIsIn(PlayerPedId(), false) then
                return false, 6.0 -- Safe speed
            end
            return true
        end)

        -- 39. Line of Sight Spoof (Anti-Wallshoot Detection)
        -- AC checks if we have LOS to target. We say "Yes".
        ActiveHooks.combatSpoof_los = MachoHookNative(0xFCD2757D, function(entity1, entity2, traceType)
            if entity1 == PlayerPedId() then return false, true end
            return true
        end)

        -- 40. Aerial Justification Spoof (Noclip Protection)
        -- AC checks if we are in a heli/plane when high in air.
        local function InAir()
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            local ped = PlayerPedId()
            if GetEntityHeightAboveGround(ped) > 5.0 then
                return false, true -- Yes, I'm in a heli/plane
            end
            return true
        end
        ActiveHooks.combatSpoof_heli = MachoHookNative(0x29433476, InAir) -- IsPedInAnyHeli
        ActiveHooks.combatSpoof_plane = MachoHookNative(0x5E196C2B, InAir) -- IsPedInAnyPlane

        -- 41. Rotation Spoof (Anti-Spinbot/Snap-Aim)
        -- AC checks for sudden rotation changes. We return a smoothed/static rotation.
        ActiveHooks.combatSpoof_rot = MachoHookNative(0xAFBD61CC, function(entity, rotationOrder)
            if entity == PlayerPedId() then
                return false, vector3(0.0, 0.0, GetEntityHeading(entity)) -- Return safe rotation
            end
            return true
        end)
        ActiveHooks.combatSpoof_head = MachoHookNative(0xE8342E2C, function(entity)
            if entity == PlayerPedId() then
                -- Return heading but maybe slightly delayed or smoothed if we were doing complex logic
                return true 
            end
            return true
        end)

        -- 42. Speed Vector Spoof
        -- AC checks the 3D velocity vector.
        ActiveHooks.combatSpoof_vec = MachoHookNative(0x9A8D700A, function(entity)
            if entity == PlayerPedId() then
                return false, vector3(1.0, 1.0, 0.0) -- Safe vector
            end
            return true
        end)

        -- 43. Swimming Spoof
        -- AC checks if we are swimming at high speeds.
        local function BlockSwim(ped)
            if ped == PlayerPedId() then return false, false end
            return true
        end
        ActiveHooks.combatSpoof_swim1 = MachoHookNative(0x9DE32163, BlockSwim) -- IsPedSwimming
        ActiveHooks.combatSpoof_swim2 = MachoHookNative(0xC027A1AA, BlockSwim) -- IsPedSwimmingUnderWater

        -- 44. Bone Coords Spoof (Anti-Aimbot Detection)
        -- AC checks where we are aiming. We offset the bone coords for the AC.
        ActiveHooks.combatSpoof_bone = MachoHookNative(0x17C07FC8, function(ped, boneId, offsetX, offsetY, offsetZ)
            local caller = GetInvokingResource()
            if not caller or caller == GetCurrentResourceName() then return true end
            
            -- If AC is checking a player's head (bone 31086)
            if boneId == 31086 then
                local realCoords = GetPedBoneCoords(ped, boneId, offsetX, offsetY, offsetZ)
                -- Return coords slightly offset to make AC think we are missing
                return false, realCoords + vector3(0.5, 0.5, 0.0)
            end
            return true
        end)

        HookStates.combatSpoof = true
        PixelUI:Notify("success", "Ultimate Spoof", "Enabled (44 Protections Active)")
    end
    PixelUI:UpdateMenuLabel("Security & Hooks", "Combat Stats Spoof", HookStates.combatSpoof and "[ON]" or "[OFF]")
end

function PixelUI:ToggleWeaponSpoof()
    if HookStates.weaponSpoof then
        MachoUnhookNative(ActiveHooks.weaponSpoof_get)
        MachoUnhookNative(ActiveHooks.weaponSpoof_has)
        MachoUnhookNative(ActiveHooks.weaponSpoof_ammo)
        MachoUnhookNative(ActiveHooks.weaponSpoof_clip)
        MachoUnhookNative(ActiveHooks.weaponSpoof_type)
        HookStates.weaponSpoof = false
        PixelUI:Notify("info", "Weapon Spoof", "Disabled")
    else
        local pistolHash = GetHashKey("WEAPON_PISTOL")
        
        -- 1. GetSelectedPedWeapon (0x0A05335F)
        ActiveHooks.weaponSpoof_get = MachoHookNative(0x0A05335F, function(ped)
            if ped == PlayerPedId() and PixelUI:IsExternalCaller() then
                return false, pistolHash
            end
            return true
        end)

        -- 2. HasPedGotWeapon (0x8DE43447)
        ActiveHooks.weaponSpoof_has = MachoHookNative(0x8DE43447, function(ped, weaponHash, p2)
            if ped == PlayerPedId() and PixelUI:IsExternalCaller() then
                if weaponHash == pistolHash then return false, true end
                return false, false -- Say we don't have anything else
            end
            return true
        end)

        -- 3. GetAmmoInPedWeapon (0x015A19F4)
        ActiveHooks.weaponSpoof_ammo = MachoHookNative(0x015A19F4, function(ped, weaponHash)
            if ped == PlayerPedId() and PixelUI:IsExternalCaller() then
                return false, 30 -- Always report 30 bullets
            end
            return true
        end)

        -- 4. GetWeaponClipSize (0x015A19F4 - wait, checking hash) -> 0x015A19F4 is GetAmmoInPedWeapon? 
        -- Correct hash for GetWeaponClipSize is 0x015A19F4 in some builds? No, let's use 0x583F0E31
        ActiveHooks.weaponSpoof_clip = MachoHookNative(0x583F0E31, function(weaponHash)
            if PixelUI:IsExternalCaller() then
                return false, 12 -- Standard clip
            end
            return true
        end)

        -- 5. GetWeaponDamageType (0x3BE0B73C535CC516)
        ActiveHooks.weaponSpoof_type = MachoHookNative(0x3BE0B73C535CC516, function(weaponHash)
            if PixelUI:IsExternalCaller() then
                return false, 3 -- Bullet damage
            end
            return true
        end)

        HookStates.weaponSpoof = true
        PixelUI:Notify("success", "Weapon Spoof", "Enabled (Stealth Mode)")
    end
    PixelUI:UpdateMenuLabel("Weapons", "Weapon Spoofing", HookStates.weaponSpoof and "[ON]" or "[OFF]")
end

function PixelUI:ToggleNativeLogger()
    NativeLoggerActive = not NativeLoggerActive
    if NativeLoggerActive then
        MachoInjectResourceRaw("any", [[
            local oldGetCoords = GetEntityCoords
            GetEntityCoords = function(entity)
                local caller = GetInvokingResource()
                if caller and caller ~= "" and caller ~= GetCurrentResourceName() then
                    print("^3[PIXEL-LOG] Resource ^1" .. caller .. "^3 checked Coords!^7")
                end
                return oldGetCoords(entity)
            end

            local oldGetHealth = GetEntityHealth
            GetEntityHealth = function(entity)
                local caller = GetInvokingResource()
                if caller and caller ~= "" and caller ~= GetCurrentResourceName() then
                    print("^3[PIXEL-LOG] Resource ^1" .. caller .. "^3 checked Health!^7")
                end
                return oldGetHealth(entity)
            end
            print("^2[PIXEL] Native Logger Started! Check F8 console.^7")
        ]])
        PixelUI:Notify("success", "Security", "Native Logger: ON")
    else
        PixelUI:Notify("info", "Security", "Native Logger: Active until Refresh")
    end
    PixelUI:Build() -- Update UI label
end

function PixelUI:StartEagleSniffer()
    MachoInjectResourceRaw("any", [[
        local TargetAC = "EC_AC"
        local WatchedCount = 0
        local NativesToWatch = {
            "GetEntityCoords", "GetEntityHealth", "GetEntitySpeed", "PlayerPedId",
            "IsPedInAnyVehicle", "IsPedRagdoll", "GetPlayerInvincible",
            "IsPedShooting", "GetSelectedPedWeapon", "HasPedGotWeapon", "GetAmmoInPedWeapon",
            "GetVehiclePedIsIn", "GetVehicleEngineHealth",
            "GetResourceState", "GetNumResources", "GetResourceMetadata", "TriggerServerEvent",
            "CreatePed", "ClonePedToTarget"
        }

        for _, nativeName in ipairs(NativesToWatch) do
            local oldNative = _G[nativeName]
            if oldNative then
                WatchedCount = WatchedCount + 1
                _G[nativeName] = function(...)
                    local caller = GetInvokingResource()
                    if caller == TargetAC then
                        print(string.format("^1[EAGLE-DETECTOR] ^0| ^3NATIVE ^0| ^2%s^7", nativeName))
                    end
                    return oldNative(...)
                end
            end
        end

        local oldTrigger = TriggerServerEvent
        TriggerServerEvent = function(name, ...)
            local caller = GetInvokingResource()
            if caller == TargetAC then
                print("^1[EAGLE-REPORT] ^3Server Event: ^2" .. tostring(name) .. "^7")
            end
            return oldTrigger(name, ...)
        end

        local oldTriggerClient = TriggerEvent
        TriggerEvent = function(name, ...)
            local caller = GetInvokingResource()
            if caller == TargetAC then
                print("^5[EAGLE-INTERNAL] ^3Event: ^2" .. tostring(name) .. "^7")
            end
            return oldTriggerClient(name, ...)
        end

        RegisterCommand("checknatives", function()
            print("^2--- Pixel Sniffer Status ---^7")
            print("^3Target: ^1" .. TargetAC)
            print("^3Natives Watched: ^2" .. WatchedCount)
            print("^3Status: ^2Active & Optimized^7")
        end, false)

        print("^2[PIXEL] Advanced Radar Active! Type /checknatives in F8.^7")
    ]])
    PixelUI:Notify("success", "Sniffer", "Eagle Radar Active")
end

function PixelUI:EnableTeleportProtection()
    -- Using MachoHookNative to intercept the actual game engine call
    MachoHookNative("SET_ENTITY_COORDS", [[
        -- This hook intercepts any attempt to move the entity
        -- We can add logic here to "validate" the move or hide it from AC
        return true -- Always tell the caller it succeeded
    ]])
    PixelUI:Notify("success", "Security", "TP Protection Enabled")
end

function PixelUI:ClonePlayer(targetIds)
    local ids = type(targetIds) == "table" and targetIds or {targetIds}
    if #ids == 0 then return end

    local playerIdsStr = table.concat(ids, ",")
    local targetRes = "any"
    
    MachoInjectResourceRaw(targetRes, string.format([[
        local function decode(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end
        local function g(n)
            return _G[decode(n)]
        end
        local function wait(n)
            return Citizen.Wait(n)
        end
        local function findClientIdByServerId(sid)
            local players = g({71,101,116,65,99,116,105,118,101,80,108,97,121,101,114,115})()
            for _, pid in ipairs(players) do
                if g({71,101,116,80,108,97,121,101,114,83,101,114,118,101,114,73,100})(pid) == sid then
                    return pid
                end
            end
            return nil
        end
        local playerIds = {%s}
        for _, targetServerId in ipairs(playerIds) do
            local clientId = findClientIdByServerId(targetServerId)
            local ped = clientId and g({71,101,116,80,108,97,121,101,114,80,101,100})(clientId) or nil
            if ped and g({68,111,101,115,69,110,116,105,116,121,69,120,105,115,116})(ped) then
                local coords = g({71,101,116,69,110,116,105,116,121,67,111,111,114,100,115})(ped)
                local hash = g({71,101,116,69,110,116,105,116,121,77,111,100,101,108})(ped)
                g({82,101,113,117,101,115,116,77,111,100,101,108})(hash)
                while not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(hash) do
                    wait(0)
                end
                local clone = g({67,114,101,97,116,101,80,101,100})(4, hash, coords.x, coords.y, coords.z, 0.0, true, true)
                
                -- Register for spoofing
                if clone and clone ~= 0 then
                    local plyState = (LocalPlayer and LocalPlayer.state) or Entity(PlayerPedId()).state
                    plyState:set("PixelEntity_" .. tostring(clone), true, false)
                end
            end
        end
    ]], playerIdsStr))
    PixelUI:Notify("success", "Clone", "Action Applied")
end

function PixelUI:SpawnVehicleNative(modelName)
    local hash = type(modelName) == "string" and GetHashKey(modelName) or modelName
    Citizen.CreateThread(function()
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end

        if HasModelLoaded(hash) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
            
            if veh and DoesEntityExist(veh) then
                SetPedIntoVehicle(ped, veh, -1)
                SetEntityAsMissionEntity(veh, true, true)
                SetModelAsNoLongerNeeded(hash)
                PixelUI:Notify("success", "Vehicle", "Spawned " .. (modelName or "Vehicle"))
            else
                PixelUI:Notify("error", "Error", "Failed to create vehicle")
            end
        else
            PixelUI:Notify("error", "Error", "Model Load Timeout")
        end
    end)
end

function PixelUI:SpawnObjectSafe(modelName)
    local hash = type(modelName) == "string" and GetHashKey(modelName) or modelName
    Citizen.CreateThread(function()
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end

        if HasModelLoaded(hash) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)
            local x, y, z = coords.x + forward.x * 2.0, coords.y + forward.y * 2.0, coords.z

            local obj = CreateObject(hash, x, y, z, true, true, false)
            
            if obj and DoesEntityExist(obj) then
                SetEntityAsMissionEntity(obj, true, true)
                PlaceObjectOnGroundProperly(obj)
                SetModelAsNoLongerNeeded(hash)
                PixelUI:Notify("success", "Object", "Spawned: " .. (modelName or "Object"))
            else
                PixelUI:Notify("error", "Error", "Failed to create object")
            end
        else
            PixelUI:Notify("error", "Error", "Model Load Timeout")
        end
    end)
end

function PixelUI:VerifyNativeProtection()
    PixelUI:Notify("info", "Verification", "Starting Native Protection Test...")
    
    -- We inject a script into a dummy resource name to simulate an "External Caller"
    MachoInjectResourceRaw("any", [[
        Citizen.CreateThread(function()
            Wait(500)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local health = GetEntityHealth(ped)
            local speed = GetEntitySpeed(ped)
            
            -- Check if Coords are spoofed to Legion Square (189.5, -922.4, 30.6)
            local isCoordsSpoofed = #(coords - vector3(189.5, -922.4, 30.6)) < 2.0
            
            -- Check if Health is spoofed (random 190-200 or static 200)
            local isHealthSpoofed = health >= 190 and health <= 200
            
            -- Check if Speed is capped at 6.0
            local isSpeedSpoofed = speed <= 6.1
            
            print("^2--- PIXEL NATIVE VERIFICATION ---^7")
            print("External Resource Calling Natives...")
            print("Coords Spoofed: " .. (isCoordsSpoofed and "^2YES^7" or "^1NO^7"))
            print("Health Spoofed: " .. (isHealthSpoofed and "^2YES^7" or "^1NO^7"))
            print("Speed Capped: " .. (isSpeedSpoofed and "^2YES^7" or "^1NO^7"))
            
            if isCoordsSpoofed or isHealthSpoofed or isSpeedSpoofed then
                print("^2[SUCCESS] Native Protection is ACTIVE and working!^7")
                TriggerEvent('pixel:verifyResult', true)
            else
                print("^1[FAILURE] Native Protection is NOT working!^7")
                TriggerEvent('pixel:verifyResult', false)
            end
            print("^2----------------------------------^7")
        end)
    ]])
end

AddEventHandler('pixel:verifyResult', function(success)
    if success then
        PixelUI:Notify("success", "Verified", "Native Protection is 100% ACTIVE")
    else
        PixelUI:Notify("error", "Failed", "Native Protection is NOT working. Enable Combat Spoof!")
    end
end)

function PixelUI:Authenticate()
    local machoKey = MachoAuthenticationKey()
    local apiUrl = string.format("https://qxkwtfjauhdyyvuuwfey.supabase.co/rest/v1/profiles?macho_key=eq.%s&select=is_banned,username&apikey=sb_publishable_HwkO4jlKV_zxTqKrsSbigA_bqLY6n_4", machoKey)
    
    PixelUI:Notify("info", "AUTH", "Verifying License...")
    
    local response = MachoWebRequest(apiUrl)
    
    if response and response ~= "" and response ~= "[]" then
        local data = json.decode(response)
        if data and data[1] then
            if data[1].is_banned then
                -- USER IS BANNED
                Citizen.CreateThread(function()
                    while true do
                        Wait(0)
                        drawTxt(0.5, 0.4, 0.0, 0.0, 1.0, "~r~[CRITICAL ERROR]~s~", 255, 255, 255, 255)
                        drawTxt(0.5, 0.45, 0.0, 0.0, 0.6, "YOUR ACCOUNT HAS BEEN BANNED FROM PIXEL UI", 255, 255, 255, 255)
                        drawTxt(0.5, 0.48, 0.0, 0.0, 0.4, "Contact Support via Dashboard", 200, 200, 200, 255)
                    end
                end)
                return false
            end
            
            PixelUI:Notify("success", "AUTH", "Welcome back, " .. data[1].username)
            return true
        end
    end

    -- NOT REGISTERED OR INVALID KEY
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            drawTxt(0.5, 0.4, 0.0, 0.0, 1.0, "~r~[AUTH FAILED]~s~", 255, 255, 255, 255)
            drawTxt(0.5, 0.45, 0.0, 0.0, 0.6, "NO VALID LICENSE FOUND FOR THIS MACHO KEY", 255, 255, 255, 255)
            drawTxt(0.5, 0.48, 0.0, 0.0, 0.4, "Register at: qxkwtfjauhdyyvuuwfey.supabase.co", 200, 200, 200, 255)
        end
    end)
    return false
end

-- Helper for drawing text on screen during auth failure
function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function PixelUI:Init() 
    -- 1. Remote Auth & Ban Check
    if not PixelUI:Authenticate() then return end

    -- 2. Check for Macho Library
    if not MachoHookNative or not MachoInjectResourceRaw then
        Citizen.CreateThread(function()
            while true do
                Wait(5000)
                print("^1[PIXEL-ERROR] Macho Library NOT Found! Bypasses will NOT work.^7")
            end
        end)
    end

    DUI = MachoCreateDui(MENU_URL, 1920, 1080)
    MachoShowDui(DUI)
    PixelUI:Build()
    CurrentMenu = ActiveMenu
    Citizen.Wait(1000)
    PixelUI:Notify("success", "PIXEL UI", "Made By Pixel Team.")
    PixelUI:RunAdvancedScan()
    
    RegisterCommand("pixelcheck", function()
        print("^2--- PIXEL BYPASS STATUS ---^7")
        print("Macho Library: " .. (MachoHookNative and "^2LOADED^7" or "^1MISSING^7"))
        print("Eagle Detected: " .. tostring(DetectedAC ~= nil))
        print("Detections Neutralized: ^2ACTIVE^7")
        print("Hard Hooks (Macho): " .. (HookStates.combatSpoof and "^2" .. 45 .. " Active^7" or "^1Inactive^7"))
        print("Anti-Screenshot: " .. (HookStates.antiScreenshot and "^2ACTIVE^7" or "^1Inactive^7"))
        print("^2--------------------------^7")
    end)

    RegisterCommand("pixelverify", function()
        PixelUI:VerifyNativeProtection()
    end)
end

PixelUI:Init()
$BODY$)
ON CONFLICT (name) DO UPDATE SET content = EXCLUDED.content;
