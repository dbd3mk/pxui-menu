import { createClient } from '@supabase/supabase-js'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url';

const supabaseUrl = 'https://qxkwtfjauhdyyvuuwfey.supabase.co'
const supabaseKey = 'sb_publishable_HwkO4jlKV_zxTqKrsSbigA_bqLY6n_4'
const supabase = createClient(supabaseUrl, supabaseKey)

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function upload() {
    console.log("🚀 Starting upload process (RPC Mode)...")

    try {
        const filePath = path.join(__dirname, '..', 'PixelUI.lua')
        if (!fs.existsSync(filePath)) {
            console.error("❌ Error: PixelUI.lua not found!")
            return
        }

        const content = fs.readFileSync(filePath, 'utf8')
        console.log(`📂 File read successfully (${content.length} bytes)`)

        // Upload using the secure RPC function (Bypasses RLS)
        const { data, error } = await supabase.rpc('upload_menu_asset', { p_content: content })

        if (error) {
            console.error("❌ RPC Upload Failed:", error.message)
            console.log("💡 Hint: Did you run the SQL to create the 'upload_menu_asset' function?")
        } else {
            console.log("✅✅ Menu uploaded successfully via Secure RPC!")
        }
    } catch (err) {
        console.error("❌ Unexpected Error:", err)
    }
}

upload()
