// ============================================================
// Fill in your own Supabase project details below.
// Find them in: Supabase Dashboard -> Project Settings -> API
// ============================================================
const SUPABASE_URL = "https://wjlppviebumivtcydruf.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqbHBwdmllYnVtaXZ0Y3lkcnVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3ODI0NTAsImV4cCI6MjEwMDM1ODQ1MH0.91VGaSnaoP4D5_MUkLNFiS6YIFqh4vW_RruNKB4VMz0";

const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
