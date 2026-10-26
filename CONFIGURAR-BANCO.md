# Configurar o banco compartilhado

O acesso do site é somente por usuário e senha: `bruno` / `bruno`. Não é necessário criar conta no Supabase Auth nem usar Gmail.

## Configuração

1. No projeto Supabase, abra **Editor SQL → Nova consulta**.
2. Cole todo o conteúdo de `supabase-username-login.sql` e clique em **Executar**. Esse script cria a credencial `bruno` / `bruno`, protege as tabelas e cria as funções que o site chama para ler e salvar o inventário.
3. A URL e a chave pública ficam em `supabase.js`, carregado pelo `index.html`. Mantenha os dois arquivos na mesma pasta. Não coloque chave `secret` ou `service_role` no site.
4. Publique `index.html` e `supabase.js` juntos no Netlify. Depois, entre com `bruno` / `bruno`.

O login é conferido no banco e a senha é armazenada como hash. O site consulta o inventário a cada cinco segundos para atualizar os outros aparelhos. A senha padrão é compartilhada e simples; use o painel apenas com a equipe.

Se você já tinha executado `supabase-setup.sql`, execute também `supabase-username-login.sql`. O segundo script configura o acesso por usuário e senha sem e-mail.

No primeiro login em um banco vazio, os dados locais daquele navegador iniciam o inventário compartilhado. Escolha o aparelho que tem o estoque correto antes desse primeiro login; os dados de outros aparelhos não são mesclados automaticamente.

**Limite atual:** se duas pessoas alterarem o inventário ao mesmo tempo, a gravação mais recente pode substituir a anterior.
