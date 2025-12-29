-- [[ PixelUI Premium Cloud Loader ]] --
local PROJECT_URL = "https://qxkwtfjauhdyyvuuwfey.supabase.co"
local API_KEY = "sb_publishable_HwkO4jlKV_zxTqKrsSbigA_bqLY6n_4"

if MachoSetLoggerState then MachoSetLoggerState(0) end

local function SecureLoad()
    local userKey = MachoAuthenticationKey()
    
    if not userKey or userKey == "" then
        print("^1[PixelUI] Error: Macho Key not found!^7")
        return
    end
    
    print("^1[PixelUI]^7 Authenticating with Cloud...")

    -- Call the secure RPC function directly
    local finalUrl = string.format("%s/rest/v1/rpc/get_secure_menu?p_macho_key=%s&apikey=%s", PROJECT_URL, userKey, API_KEY)
    local response = MachoGetRequest(finalUrl)
    
    if response and response ~= "" then
        -- Clean the JSON string response from RPC and handle Windows line endings (\r\n)
        local cleanResponse = response:gsub('^"', ''):gsub('"$', '')
        cleanResponse = cleanResponse:gsub('\\r', ''):gsub('\\n', '\n'):gsub('\\"', '"'):gsub('\\\\', '\\')

        if cleanResponse == "ERROR: INVALID_KEY" then
            print("^1[PixelUI] Access Denied: Key not synced in Dashboard.^7")
        elseif cleanResponse == "ERROR: BANNED" then
            print("^1[PixelUI] Access Denied: You are banned.^7")
        elseif cleanResponse:find("local") or cleanResponse:find("PixelUI") or cleanResponse:find("function") then
            print("^2[PixelUI] Cloud Success! Loading...^7")
            local func, err = load(cleanResponse)
            if func then func() else print("^1[PixelUI] Load Error: " .. tostring(err) .. "^7") end
        else
            print("^1[PixelUI] Server Error: " .. tostring(cleanResponse) .. "^7")
        end
    else
        print("^1[PixelUI] Connection Failed!^7")
    end
    
    if MachoSetLoggerState then MachoSetLoggerState(3) end
end

SecureLoad()
