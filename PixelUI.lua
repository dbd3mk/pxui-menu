local PixelUI = {}
local IsVisible = false
local MenuKey = 72 -- H Key

-- Configuration
local BASE_URL = "https://raw.githubusercontent.com/dbd3mk/pxui-menu/main/"
local MENU_URL = BASE_URL .. "index.html?v=" .. math.random(1, 999999)

-- State
local MenuState = {
    title = "PIXEL UI",
    banner = "https://i.imgur.com/3QZ9j9S.png",
    activeTab = "General",
    tabs = {"General", "Players", "Vehicle", "Weapon", "Troll", "Settings"},
    selectedIndex = 1,
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
        { type = "toggle", label = "God Mode", value = false },
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
        local json_data = json.encode(data)
        -- print("^3[PixelUI] Sending: " .. json_data .. "^7") -- Uncomment for verbose debug
        MachoSendDuiMessage(DUI, json_data) 
    else
        print("^1[PixelUI] Error: Cannot Send - DUI is nil^7")
    end 
end

function PixelUI:UpdateUI()
    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            title = MenuState.title,
            banner = MenuState.banner,
            tabs = MenuState.tabs,
            activeTab = MenuState.activeTab,
            items = MenuState.items,
            footer = "PixelUI v2.0 | " .. #MenuState.items .. " Items"
        }
    })
    PixelUI:Send({ action = "updateSelection", index = MenuState.selectedIndex - 1 })
end

-- Input Handling
MachoOnKeyDown(function(key)
    -- print("Key Pressed: " .. key) -- Debug: Check if keys are registered
    if key == MenuKey then
        print("^2[PixelUI] Key 'H' Pressed. Toggling Menu...^7")
        IsVisible = not IsVisible
        
        PixelUI:Send({ action = "setVisible", visible = IsVisible })
        
        -- Enable focus to ensure the menu is visible and interactive
        SetNuiFocus(IsVisible, IsVisible) 
        
        if IsVisible then 
            PixelUI:UpdateUI() 
            print("^2[PixelUI] Menu Visible: ON^7")
        else
            print("^2[PixelUI] Menu Visible: OFF^7")
        end
    end

    if not IsVisible then return end

    if key == 38 then -- UP
        if MenuState.selectedIndex > 1 then
            MenuState.selectedIndex = MenuState.selectedIndex - 1
            PixelUI:Send({ action = "updateSelection", index = MenuState.selectedIndex - 1 })
        end
    elseif key == 40 then -- DOWN
        if MenuState.selectedIndex < #MenuState.items then
            MenuState.selectedIndex = MenuState.selectedIndex + 1
            PixelUI:Send({ action = "updateSelection", index = MenuState.selectedIndex - 1 })
        end
    elseif key == 37 or key == 39 then -- LEFT / RIGHT (Tab Switch)
        local currentTabIdx = 0
        for i, t in ipairs(MenuState.tabs) do if t == MenuState.activeTab then currentTabIdx = i break end end
        
        if key == 37 then -- Left
            currentTabIdx = currentTabIdx > 1 and currentTabIdx - 1 or #MenuState.tabs
        else -- Right
            currentTabIdx = currentTabIdx < #MenuState.tabs and currentTabIdx + 1 or 1
        end
        
        MenuState.activeTab = MenuState.tabs[currentTabIdx]
        MenuState.selectedIndex = 1
        
        -- Update Items based on Tab
        if MenuState.activeTab == "General" then MenuState.items = PixelUI:GetGeneralItems()
        elseif MenuState.activeTab == "Players" then MenuState.items = PixelUI:GetPlayerItems()
        else MenuState.items = {{type="separator", label="Empty Tab"}} end
        
        PixelUI:UpdateUI()
    end
end)

-- Initialization
Citizen.CreateThread(function()
    print("^2[PixelUI] Initializing DUI...^7")
    
    -- Create DUI
    -- Using MachoCreateDui if available, otherwise fallback to standard CreateDui (if applicable in this env)
    -- Assuming MachoCreateDui(url, width, height) based on MachoSendDuiMessage usage
    
    if MachoCreateDui then
        DUI = MachoCreateDui(MENU_URL, 1920, 1080)
    else
        print("^1[PixelUI] Error: MachoCreateDui not found!^7")
        -- Fallback attempt
        if CreateDui then 
            DUI = CreateDui(MENU_URL, 1920, 1080) 
        end
    end

    if DUI then
        print("^2[PixelUI] DUI Created Successfully! URL: " .. MENU_URL .. "^7")
        -- Wait a bit for page to load then sync
        Citizen.Wait(2000)
        PixelUI:UpdateUI()
    else
        print("^1[PixelUI] Failed to create DUI object.^7")
    end
end)

return PixelUI
