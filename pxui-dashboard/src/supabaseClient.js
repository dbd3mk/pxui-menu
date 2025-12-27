import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://qxkwtfjauhdyyvuuwfey.supabase.co'
const supabaseAnonKey = 'sb_publishable_HwkO4jlKV_zxTqKrsSbigA_bqLY6n_4'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
