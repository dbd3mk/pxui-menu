-- [[ STEP 1: Create the system_assets table ]]
CREATE TABLE IF NOT EXISTS public.system_assets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    name TEXT UNIQUE NOT NULL,
    content TEXT NOT NULL
);

-- [[ STEP 2: Secure the table ]]
-- Disable public read access to the table directly
ALTER TABLE public.system_assets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.system_assets;

-- [[ STEP 3: Create the Secure RPC Function ]]
-- This function acts as a gateway. It only returns the code if the Macho Key is valid and not banned.
CREATE OR REPLACE FUNCTION get_secure_menu(p_macho_key TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with admin privileges to bypass RLS internally
AS $$
DECLARE
    v_username TEXT;
    v_is_banned BOOLEAN;
    v_content TEXT;
BEGIN
    -- 1. Check if the key exists and get user status
    SELECT username, is_banned INTO v_username, v_is_banned
    FROM public.profiles
    WHERE macho_key = p_macho_key;

    -- 2. Validate Key
    IF v_username IS NULL THEN
        RETURN 'ERROR: INVALID_KEY';
    END IF;

    -- 3. Check Ban Status
    IF v_is_banned = TRUE THEN
        RETURN 'ERROR: BANNED';
    END IF;

    -- 4. Fetch the Menu Source Code
    SELECT content INTO v_content
    FROM public.system_assets
    WHERE name = 'main_menu';

    RETURN v_content;
END;
$$;

-- [[ STEP 4: Grant Access ]]
-- Allow the public (anon) to call this specific function
GRANT EXECUTE ON FUNCTION get_secure_menu(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION get_secure_menu(TEXT) TO authenticated;
