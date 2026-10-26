// Configuração do Supabase usada pelo index.html.
// A chave publishable pode ficar no navegador; nunca coloque aqui uma chave secret/service_role.
window.SUPABASE_URL = 'https://otobtxvicfolxgttcpld.supabase.co';
window.SUPABASE_ANON_KEY = 'sb_publishable_J3PJBMFecFlWq7I7TqOFcg_ZukkgVV3';
window.backendReady = Boolean(window.SUPABASE_URL && window.SUPABASE_ANON_KEY);
window.supabaseReady = new Promise(resolve => {
  if (!window.backendReady) return resolve(null);
  const script = document.createElement('script');
  script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
  script.onload = () => resolve(window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY));
  script.onerror = () => resolve(null);
  document.head.appendChild(script);
});
