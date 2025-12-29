import fs from 'fs';

const luaFilePath = 'c:\\Users\\PC FORCE\\Desktop\\VSC\\1\\.vscode\\pxui-menu-main\\PixelUI.lua';
const sqlFilePath = 'c:\\Users\\PC FORCE\\Desktop\\VSC\\1\\.vscode\\pxui-menu-main\\setup_database_full.sql';

try {
    const luaCode = fs.readFileSync(luaFilePath, 'utf8');

    // Escape single quotes for SQL
    const escapedLuaCode = luaCode.replace(/'/g, "''");

    const sqlContent = `-- [[ STEP 1: Create the system_assets table ]]
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
VALUES ('main_menu', $BODY$${luaCode}$BODY$)
ON CONFLICT (name) DO UPDATE SET content = EXCLUDED.content;
`;

    fs.writeFileSync(sqlFilePath, sqlContent);
    console.log('SQL file created successfully at: ' + sqlFilePath);
} catch (err) {
    console.error('Error:', err);
}
