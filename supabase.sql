-- ============================================================
-- BRISAS — estrutura do banco (Supabase)
-- Cole tudo isto no SQL Editor do Supabase e clique em "Run".
-- ============================================================

-- 1. ESPÉCIMES: as perguntas existenciais
create table if not exists public.perguntas (
  id         bigint generated always as identity primary key,
  texto      text not null
             check (char_length(texto) between 5 and 280)
             check (texto ~ '\?\s*$'),               -- só entram perguntas
  apelido    text check (apelido is null or char_length(apelido) <= 40),
  gaveta     text not null default 'avulsas'
             check (gaveta in ('sentido','tempo','morte','amor','eu',
                               'outros','liberdade','mundo','avulsas')),
  visivel    boolean not null default true,          -- moderação: desmarque para esconder
  criada_em  timestamptz not null default now()
);

-- 2. DESDOBRAMENTOS: perguntas que aprofundam outras perguntas
create table if not exists public.desdobramentos (
  id           bigint generated always as identity primary key,
  pergunta_id  bigint not null references public.perguntas(id) on delete cascade,
  tipo         text not null
               check (tipo in ('e_se','mais_fundo','ao_contrario','por_que_importa')),
  texto        text not null
               check (char_length(texto) between 5 and 280)
               check (texto ~ '\?\s*$'),
  apelido      text check (apelido is null or char_length(apelido) <= 40),
  visivel      boolean not null default true,
  criada_em    timestamptz not null default now()
);

create index if not exists desdobramentos_pergunta_idx
  on public.desdobramentos (pergunta_id);

-- 3. REGRAS DE ACESSO (Row Level Security)
-- O público pode LER o que está visível e DEPOSITAR coisas novas.
-- Ninguém do público pode editar ou apagar. Você modera pelo painel
-- do Supabase (Table Editor), que ignora essas regras.
alter table public.perguntas      enable row level security;
alter table public.desdobramentos enable row level security;

drop policy if exists "ler perguntas visiveis"   on public.perguntas;
drop policy if exists "depositar perguntas"      on public.perguntas;
drop policy if exists "ler desdobramentos visiveis" on public.desdobramentos;
drop policy if exists "depositar desdobramentos"    on public.desdobramentos;

create policy "ler perguntas visiveis"
  on public.perguntas for select to anon, authenticated
  using (visivel = true);

create policy "depositar perguntas"
  on public.perguntas for insert to anon, authenticated
  with check (visivel = true);

create policy "ler desdobramentos visiveis"
  on public.desdobramentos for select to anon, authenticated
  using (visivel = true);

create policy "depositar desdobramentos"
  on public.desdobramentos for insert to anon, authenticated
  with check (
    visivel = true
    and exists (select 1 from public.perguntas p
                where p.id = pergunta_id and p.visivel = true)
  );

-- 4. PERMISSÕES explícitas (alguns projetos novos não as concedem por padrão)
grant usage on schema public to anon, authenticated;
grant select, insert on public.perguntas, public.desdobramentos to anon, authenticated;
