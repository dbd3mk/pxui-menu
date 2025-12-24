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
    -- القائمة الرئيسية البسيطة كما طلب المستخدم
    ActiveMenu = {
        { label = "SELF", type = "subMenu", subTabs = {} },
        { label = "PLAYER", type = "subMenu", subTabs = {} },
        { label = "SERVER", type = "subMenu", subTabs = {} },
        { label = "SETTING", type = "subMenu", subTabs = {} }
    }
end

function PixelUI:UpdateUI()
    PixelUI:Send({
        action = "updateMenu",
        menuData = {
            tabs = {"MAIN MENU"}, -- تبويب واحد فقط كعنوان
            activeTabIdx = 0,
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
    PixelUI:Notify("success", "PIXEL UI", "Menu Simplified")
end

PixelUI:Init()

return PixelUI
