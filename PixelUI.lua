local PixelUI = {}
local IsVisible, DUI, HoveredIndex = false, nil, 1
local ActiveMenu, CurrentMenu, MenuStack = {}, {}, {}

-- Configuration
local BASE_URL = "https://dbd3mk.github.io/pxui-menu/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

local MenuKey = 72 -- H Key
local isShiftPressed = false

-- Core Functions
function PixelUI:Send(d) if DUI then MachoSendDuiMessage(DUI, json.encode(d)) end end
function PixelUI:Notify(t, ti, d) PixelUI:Send({ action="showNotification", type=t, title=ti, desc=d }) end

function PixelUI:Build()
    -- Tab: Actions
    local actionsTab = {
        { label = "Teleport to Waypoint", type = "button", onSelect = function() PixelUI:Notify("info", "TELEPORT", "Teleporting to waypoint...") end },
        { label = "Heal & Armor", type = "button", onSelect = function() PixelUI:Notify("success", "SELF", "Stats Restored") end },
        { label = "God Mode [OFF]", type = "toggle", onSelect = function() end },
        { label = "Invisibility [OFF]", type = "toggle", onSelect = function() end },
        { label = "Super Jump [OFF]", type = "toggle", onSelect = function() end },
        { label = "Explode Nearest Vehicle", type = "button", danger = true, onSelect = function() end },
        { label = "Ram Nearest Player", type = "button", danger = true, onSelect = function() end },
    }

    -- Tab: Players
    local playersTab = {
        { label = "Refresh Player List", type = "button", onSelect = function() PixelUI:UpdatePlayerTab() end },
        -- Players will be injected here
    }

    -- Tab: Settings
    local settingsTab = {
        { label = "Menu Accent Color", type = "list", value = "Red", options = {"Red", "Blue", "Green", "Purple"} },
        { label = "Discord Link", type = "button", onSelect = function() PixelUI:Notify("info", "DISCORD", "Link copied to clipboard") end },
        { label = "Unload Menu", type = "button", danger = true, onSelect = function() end },
    }

    ActiveMenu = {
        tabs = {"Actions", "Players", "Settings"},
        activeTabIdx = 0,
        content = {
            [0] = actionsTab,
            [1] = playersTab,
            [2] = settingsTab
        }
    }
end

function PixelUI:UpdatePlayerTab()
    local p = { { label = "Refresh Player List", type = "button", onSelect = function() PixelUI:UpdatePlayerTab() end } }
    for _, player in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(player)
        local trolls = { 
            { label = "Spectate", type = "toggle", value = false },
            { label = "Teleport To", type = "button" },
            { label = "Explode Player", type = "button", danger = true },
            { label = "Freeze Player", type = "toggle", value = false }
        }
        table.insert(p, { label = GetPlayerName(player).." ["..sid.."]", type = "subMenu", subTabs = trolls })
    end
    ActiveMenu.content[1] = p
    if ActiveMenu.activeTabIdx == 1 then
        CurrentMenu = p
        PixelUI:UpdateUI()
    end
end

function PixelUI:UpdateUI()
    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            tabs = ActiveMenu.tabs,
            activeTabIdx = ActiveMenu.activeTabIdx,
            items = CurrentMenu,
            selectedIndex = HoveredIndex - 1
        }
    })
end

-- Input Handling
MachoOnKeyDown(function(key)
    if key == 16 or key == 160 or key == 161 then isShiftPressed = true return end

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
        elseif key == 37 or key == 39 then -- LEFT / RIGHT (Tabs)
            if key == 37 then -- Left
                ActiveMenu.activeTabIdx = ActiveMenu.activeTabIdx > 0 and ActiveMenu.activeTabIdx - 1 or #ActiveMenu.tabs - 1
            else -- Right
                ActiveMenu.activeTabIdx = ActiveMenu.activeTabIdx < #ActiveMenu.tabs - 1 and ActiveMenu.activeTabIdx + 1 or 0
            end
            CurrentMenu = ActiveMenu.content[ActiveMenu.activeTabIdx]
            HoveredIndex = 1
            MenuStack = {} -- Clear stack when changing tabs
            PixelUI:UpdateUI()
        elseif key == 13 then -- ENTER
            local item = CurrentMenu[HoveredIndex]
            if item.type == "subMenu" then
                table.insert(MenuStack, CurrentMenu)
                CurrentMenu = item.subTabs
                HoveredIndex = 1
                PixelUI:UpdateUI()
            elseif item.onSelect then 
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
    CurrentMenu = ActiveMenu.content[0]
    Citizen.Wait(1000)
    PixelUI:Notify("success", "PIXEL UI", "V2.5 Premium Loaded")
end

PixelUI:Init()

return PixelUI
