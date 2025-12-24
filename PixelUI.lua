local PixelUI = {}
local IsVisible = false
local MenuKey = 72 -- H Key

-- Configuration
local BASE_URL = "https://raw.githubusercontent.com/dbd3mk/pxui-menu/main/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

-- State
local MenuState = {
    title = "PIXEL UI",
    banner = "banner.png",
    activeTabIdx = 0,
    tabs = {"General", "Players", "Vehicle", "Weapon", "Troll", "Settings"},
    selectedIndex = 0, -- 0-based for JS
    items = {}
}

-- Mock Data Generators
function PixelUI:GetGeneralItems()
    return {
        { type = "button", label = "Self Heal" },
        { type = "button", label = "Armor Up" },
        { type = "separator", label = "Teleport" },
        { type = "button", label = "Waypoint" },
        { type = "button", label = "Revive Self" },
        { type = "toggle", label = "God Mode", value = true },
        { type = "toggle", label = "Invisibility", value = false },
    }
end

function PixelUI:GetPlayerItems()
    local items = {
        { type = "separator", label = "Online Players" }
    }
    for _, p in ipairs(GetActivePlayers()) do
        table.insert(items, { type = "button", label = GetPlayerName(p) .. " [" .. GetPlayerServerId(p) .. "]" })
    end
    return items
end

-- Init Items
MenuState.items = PixelUI:GetGeneralItems()

-- Core Functions
function PixelUI:Send(data)
    if DUI then 
        MachoSendDuiMessage(DUI, json.encode(data)) 
    end 
end

function PixelUI:UpdateUI()
    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            title = MenuState.title,
            banner = MenuState.banner,
            tabs = MenuState.tabs,
            activeTabIdx = MenuState.activeTabIdx,
            items = MenuState.items,
            selectedIndex = MenuState.selectedIndex
        }
    })
end

-- Input Handling
MachoOnKeyDown(function(key)
    if key == MenuKey then
        IsVisible = not IsVisible
        PixelUI:Send({ action = "setVisible", visible = IsVisible })
        
        -- Keyboard only focus
        SetNuiFocus(IsVisible, false)
        SetNuiFocusKeepInput(IsVisible)
        
        if IsVisible then 
            Citizen.Wait(100)
            PixelUI:UpdateUI() 
        end
    end

    if not IsVisible then return end

    if key == 38 then -- UP
        if MenuState.selectedIndex > 0 then
            MenuState.selectedIndex = MenuState.selectedIndex - 1
            PixelUI:Send({ action = "updateSelection", index = MenuState.selectedIndex })
        end
    elseif key == 40 then -- DOWN
        if MenuState.selectedIndex < #MenuState.items - 1 then
            MenuState.selectedIndex = MenuState.selectedIndex + 1
            PixelUI:Send({ action = "updateSelection", index = MenuState.selectedIndex })
        end
    elseif key == 37 or key == 39 then -- LEFT / RIGHT (Tab Switch)
        if key == 37 then -- Left
            MenuState.activeTabIdx = MenuState.activeTabIdx > 0 and MenuState.activeTabIdx - 1 or #MenuState.tabs - 1
        else -- Right
            MenuState.activeTabIdx = MenuState.activeTabIdx < #MenuState.tabs - 1 and MenuState.activeTabIdx + 1 or 0
        end
        
        MenuState.selectedIndex = 0
        
        -- Update Items based on Tab
        local tabName = MenuState.tabs[MenuState.activeTabIdx + 1]
        if tabName == "General" then MenuState.items = PixelUI:GetGeneralItems()
        elseif tabName == "Players" then MenuState.items = PixelUI:GetPlayerItems()
        else MenuState.items = {{type="separator", label="Empty Section"}} end
        
        PixelUI:UpdateUI()
    end
end)

-- Initialization
Citizen.CreateThread(function()
    if MachoCreateDui then
        DUI = MachoCreateDui(MENU_URL, 1920, 1080)
        Citizen.Wait(2000)
        PixelUI:UpdateUI()
    end
end)

return PixelUI
