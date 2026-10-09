# brisas — como publicar (custo zero)

São três peças: **Supabase** guarda as perguntas, **GitHub** guarda o código e **Vercel** publica o site.
Leva uns 20 minutos na primeira vez.

## O que tem nesta pasta

| Arquivo | Para quê |
|---|---|
| `index.html` | O app inteiro (página, estilo e lógica num arquivo só) |
| `supabase.sql` | Cria as tabelas e as regras de segurança do banco |
| `.github/workflows/manter-acordado.yml` | Visita o banco a cada 3 dias para ele não pausar |

Abrir o `index.html` direto no navegador já funciona em **modo demonstração**
(com perguntas de exemplo, salvas só no seu navegador). Bom para testar o visual.

---

## 1. Criar o banco no Supabase

1. Crie uma conta gratuita em supabase.com e clique em **New project**.
   Dê um nome (ex.: `brisas`), crie uma senha forte para o banco e escolha a região **South America (São Paulo)**.
2. Quando o projeto terminar de subir, abra **SQL Editor** no menu lateral.
3. Cole todo o conteúdo de `supabase.sql` e clique em **Run**. Deve aparecer "Success".
4. Vá em **Project Settings → API** (ou **API Keys**) e copie:
   - a **Project URL** (algo como `https://abcdefgh.supabase.co`)
   - a chave **publishable** (começa com `sb_publishable_`). Em projetos mais antigos ela aparece como **anon public**.

> Essas duas informações são públicas por natureza: qualquer site com Supabase as expõe no navegador.
> A segurança está nas regras do `supabase.sql`, que só permitem ler e depositar.
> **Nunca** use a chave `secret` / `service_role` no site.

## 2. Ligar o app ao banco

Abra o `index.html` num editor de texto e, perto do início do `<script>`, preencha:

```js
const SUPABASE_URL = "https://abcdefgh.supabase.co";
const SUPABASE_KEY = "sb_publishable_xxxxxxxx";
```

Salve. O aviso de "modo demonstração" some e o site passa a ler do banco (começa vazio).

## 3. Subir para o GitHub

1. Crie uma conta em github.com (se ainda não tiver) e um repositório novo, ex.: `brisas`.
2. Na página do repositório, clique em **uploading an existing file** e arraste os arquivos desta pasta.
   A pasta `.github` é oculta em alguns sistemas; se não conseguir arrastá-la, crie o arquivo pelo botão
   **Add file → Create new file** com o nome `.github/workflows/manter-acordado.yml` e cole o conteúdo.
3. Clique em **Commit changes**.

## 4. Publicar na Vercel

1. Entre em vercel.com com a sua conta do GitHub (plano **Hobby**, gratuito).
2. **Add New → Project**, escolha o repositório `brisas` e clique em **Deploy**. Não precisa mudar nenhuma configuração.
3. Em segundos você recebe um endereço tipo `brisas-xxxx.vercel.app`. Dá para trocar o nome em
   **Settings → Domains**.

Toda vez que você editar um arquivo no GitHub, a Vercel republica sozinha.

## 5. Evitar que o banco pause

O Supabase gratuito pausa projetos depois de 7 dias sem uso. O arquivo `manter-acordado.yml` resolve isso:

1. No repositório do GitHub: **Settings → Secrets and variables → Actions → New repository secret**.
2. Crie `SUPABASE_URL` com a Project URL e `SUPABASE_KEY` com a chave publishable.
3. Em **Actions**, abra "Manter as brisas acordadas" e clique em **Run workflow** uma vez para testar.

Se um dia o projeto pausar mesmo assim, os dados ficam guardados: basta entrar no painel do Supabase e clicar em **Restore**.

---

## Moderação

Tudo é feito no painel do Supabase, em **Table Editor**:

- **Esconder** uma pergunta ou desdobramento: desmarque a coluna `visivel`. Some do site na hora, mas fica guardado.
- **Editar**: clique duas vezes no texto e corrija (precisa continuar terminando com `?`).
- **Excluir de vez**: selecione a linha e apague. Ao apagar uma pergunta, os desdobramentos dela vão junto.

O público não consegue editar nem apagar nada, só ler e depositar.

## Para personalizar

- **Temas** (categorias): edite a lista `TEMAS` no `index.html` **e** a lista `check (gaveta in (...))`
  no banco (SQL Editor). As duas precisam bater.
- **Tipos de desdobramento**: lista `TIPOS` no `index.html` e `check (tipo in (...))` no banco.
- **Textos e título**: estão em português claro no HTML, é só trocar.
- **Cores**: no topo do `<style>` (`--rosa`, `--azul`, `--amarelo`…) e, para os rabiscos, na lista `CORES_RABISCO`.
- **Temas e tipos de brisa**: cada um tem um rótulo e uma cor nas listas `TEMAS` e `TIPOS`; troque os rótulos à vontade, mas mantenha as chaves (à esquerda) iguais às do banco.

## Link direto para um espécime

Cada pergunta tem um endereço próprio: `seusite.vercel.app/#42` abre direto a brisa nº 0042.
Bom para compartilhar uma pergunta específica.
