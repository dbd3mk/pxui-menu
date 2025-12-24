local PixelUI = {}
local IsVisible, DUI, HoveredIndex = false, nil, 1
local ActiveMenu, CurrentMenu, MenuStack = {}, {}, {}

-- Configuration
local BASE_URL = "https://raw.githubusercontent.com/dbd3mk/pxui-menu/main/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

local MenuKey = 72 -- H Key
local IsPickingKey, IsInputting, InputTarget, CurrentInputVal = false, false, "", ""
local isShiftPressed = false
local TempData, TempKey, TempName = {}, nil, nil

local Keys = {
    [8]="BACK",[13]="ENTER",[27]="ESC",[32]=" ", [189]="_", [190]=".",
    [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
    [96]="0",[97]="1",[98]="2",[99]="3",[100]="4",[101]="5",[102]="6",[103]="7",[104]="8",[105]="9",
    [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",
    [75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",
    [85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z"
}

-- Core Functions
function PixelUI:Send(d) if DUI then MachoSendDuiMessage(DUI, json.encode(d)) end end
function PixelUI:Notify(t, ti, d) PixelUI:Send({ action="showNotification", type=t, title=ti, desc=d }) end

function PixelUI:Build()
    local selfMenu = {
        { label = "❤️ Heal", type = "button", onSelect = function() MachoInjectResourceRaw("any", [[SetEntityHealth(PlayerPedId(), 200)]]); PixelUI:Notify("success", "SELF", "Healed") end },
        { label = "🛡️ Armor", type = "button", onSelect = function() MachoInjectResourceRaw("any", [[SetPedArmour(PlayerPedId(), 100)]]); PixelUI:Notify("success", "SELF", "Armored") end },
        { label = "🚑 Revive", type = "button", onSelect = function() MachoInjectResourceRaw("any", [[TriggerEvent('hospital:client:Revive') TriggerEvent('esx_ambulancejob:revive')]]); PixelUI:Notify("success", "SELF", "Revived") end },
        { label = "👻 Invisibility [OFF]", type = "button", onSelect = function() end }, -- Placeholder for toggle logic
    }

    ActiveMenu = {
        { label = "👤 SELF MENU", type = "subMenu", subTabs = selfMenu },
        { label = "👥 ONLINE PLAYERS", type = "subMenu", subTabs = {} },
        { label = "⚙️ SETTINGS", type = "subMenu", subTabs = {
            { label = "Change Key", type = "button", onSelect = function() IsPickingKey = true; PixelUI:Send({action="updateKeyboard", visible=true, title="Press New Key"}) end },
        }}
    }
end

function PixelUI:GetPlayerList()
    local p = {}
    for _, player in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(player)
        local trolls = { 
            { label = "💥 Explode", type = "button", onSelect = function() MachoInjectResourceRaw("any", string.format([[local c=GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(%d))) AddExplosion(c.x,c.y,c.z,1,10.0,true,false,1.0)]], sid)) end },
            { label = "🎒 Open Inventory", type = "button", onSelect = function() MachoInjectResourceRaw("any", string.format([[TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', %d)]], sid)) end } 
        }
        table.insert(p, { label = GetPlayerName(player).." ["..sid.."]", type = "subMenu", subTabs = trolls })
    end
    return p
end

-- Input Handling
MachoOnKeyDown(function(key)
    if key == 16 or key == 160 or key == 161 then isShiftPressed = true return end
    
    if IsInputting then
        -- (Input logic same as reference)
        return
    end

    if IsPickingKey then
        -- (Key picking logic same as reference)
        return
    end

    if key == MenuKey then
        IsVisible = not IsVisible
        PixelUI:Send({ action = "showUI", visible = IsVisible, elements = CurrentMenu, index = HoveredIndex - 1 })
        SetNuiFocus(IsVisible, false)
        SetNuiFocusKeepInput(IsVisible)
    elseif IsVisible then
        if key == 38 then -- UP
            HoveredIndex = HoveredIndex > 1 and HoveredIndex - 1 or #CurrentMenu
            PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 40 then -- DOWN
            HoveredIndex = HoveredIndex < #CurrentMenu and HoveredIndex + 1 or 1
            PixelUI:Send({action="keydown", index=HoveredIndex-1})
        elseif key == 13 then -- ENTER
            local item = CurrentMenu[HoveredIndex]
            if item.type == "subMenu" then
                table.insert(MenuStack, {m = CurrentMenu, l = "MAIN"})
                if item.label == "👥 ONLINE PLAYERS" then item.subTabs = PixelUI:GetPlayerList() end
                CurrentMenu = item.subTabs
                HoveredIndex = 1
                PixelUI:Send({action="updateElements", elements=CurrentMenu, index=0})
            elseif item.onSelect then 
                item.onSelect() 
            end
        elseif key == 8 then -- BACKSPACE
            if #MenuStack > 0 then 
                local p = table.remove(MenuStack)
                CurrentMenu = p.m
                HoveredIndex = 1
                PixelUI:Send({action="updateElements", elements=CurrentMenu, index=0})
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
    Citizen.Wait(1000)
    PixelUI:Notify("success", "PIXEL UI", "V2.0 Loaded Successfully.")
end

PixelUI:Init()

return PixelUI
