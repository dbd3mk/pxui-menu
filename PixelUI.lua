local PixelUI = {}
local IsVisible, DUI, HoveredIndex = false, nil, 1
local ActiveMenu, CurrentMenu, MenuStack = {}, {}, {}

-- Configuration
local BASE_URL = "https://dbd3mk.github.io/pxui-menu/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

local MenuKey = 72 -- H Key
local MenuPosX, MenuPosY = 30, 30
local IsPickingKey, TempKey, TempName = false, nil, nil
local isShiftPressed = false

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
function PixelUI:UpdatePos() PixelUI:Send({ action = "updatePosition", x = MenuPosX, y = MenuPosY }) end

-- Advanced Protection Scan Logic
function PixelUI:ScanAC()
    local function ResourceFileExists(res, file)
        local content = LoadResourceFile(res, file)
        return content ~= nil
    end

    local numResources = GetNumResources()
    local acFiles = {
        { name = "ai_module_fg-obfuscated.lua", acName = "FiveGuard" },
    }
    
    local detected = {}
    PixelUI:Notify("info", "SCANNER", "Starting Advanced Scan...")
    
    for i = 0, numResources - 1 do
        local res = GetResourceByFindIndex(i)
        if res then
            local resLower = res:lower()

            -- Check for specific files
            for _, acFile in ipairs(acFiles) do
                if ResourceFileExists(res, acFile.name) then
                    table.insert(detected, {name = acFile.acName, res = res})
                end
            end

            -- Check for resource name patterns
            local friendly = nil
            if resLower:sub(1, 7) == "reaperv" then friendly = "ReaperV4"
            elseif resLower:sub(1, 4) == "fini" then friendly = "FiniAC"
            elseif resLower:sub(1, 7) == "chubsac" then friendly = "ChubsAC"
            elseif resLower:sub(1, 6) == "fireac" then friendly = "FireAC"
            elseif resLower:sub(1, 7) == "drillac" then friendly = "DrillAC"
            elseif resLower:sub(-7) == "eshield" then friendly = "WaveShield"
            elseif resLower:sub(-10) == "likizao_ac" then friendly = "Likizao-AC"
            elseif resLower:sub(1, 5) == "greek" then friendly = "GreekAC"
            elseif resLower == "pac" then friendly = "PhoenixAC"
            elseif resLower == "electronac" then friendly = "ElectronAC"
            end

            if friendly then
                table.insert(detected, {name = friendly, res = res})
            end
        end
    end

    if #detected > 0 then
        for _, ac in ipairs(detected) do
            PixelUI:Notify("warning", "AC DETECTED", ac.name .. " found in: " .. ac.res)
        end
    else
        PixelUI:Notify("success", "SCAN COMPLETE", "No known anti-cheat footprints found.")
    end
end

function PixelUI:Build()
    local settingsMenu = {
        { label = "Menu X Position", type = "list", value = MenuPosX },
        { label = "Menu Y Position", type = "list", value = MenuPosY },
        { label = "Change Toggle Key", type = "button", onSelect = function() 
            IsPickingKey = true
            PixelUI:Send({action="updateKeyboard", visible=true, title="Press New Key", value="???"})
        end },
        { label = "Run Protection Scan", type = "button", onSelect = function() 
            PixelUI:ScanAC()
        end },
    }

    ActiveMenu = {
        { label = "SELF", type = "subMenu", subTabs = {} },
        { label = "PLAYER", type = "subMenu", subTabs = {} },
        { label = "SERVER", type = "subMenu", subTabs = {} },
        { label = "SETTING", type = "subMenu", subTabs = settingsMenu }
    }
end

function PixelUI:UpdateUI()
    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            tabs = {"MAIN MENU"},
            activeTabIdx = 0,
            items = CurrentMenu,
            selectedIndex = HoveredIndex - 1
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
            if item and item.label then
                if item.label:find("Position") then
                    if IsDisabledControlPressed(0, 175) then -- Right
                        if item.label:find("X") then MenuPosX = MenuPosX + 2 else MenuPosY = MenuPosY + 2 end
                        item.value = item.label:find("X") and MenuPosX or MenuPosY
                        PixelUI:UpdateUI()
                    elseif IsDisabledControlPressed(0, 174) then -- Left
                        if item.label:find("X") then MenuPosX = math.max(0, MenuPosX - 2) else MenuPosY = math.max(0, MenuPosY - 2) end
                        item.value = item.label:find("X") and MenuPosX or MenuPosY
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
        PixelUI:Send({ action = "showUI", visible = IsVisible, elements = CurrentMenu, index = HoveredIndex - 1 })
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
        elseif key == 13 then -- ENTER
            local item = CurrentMenu[HoveredIndex]
            if item and item.type == "subMenu" then
                table.insert(MenuStack, CurrentMenu)
                CurrentMenu = item.subTabs
                HoveredIndex = 1
                PixelUI:UpdateUI()
            elseif item and item.onSelect then 
                item.onSelect() 
            end
        elseif key == 8 then -- BACKSPACE
            if #MenuStack > 0 then 
                CurrentMenu = table.remove(MenuStack)
                HoveredIndex = 1
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
    Citizen.Wait(1000)
    PixelUI:Notify("success", "PIXEL UI", "Advanced Scanner Ready")
end

PixelUI:Init()

return PixelUI
