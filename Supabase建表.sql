-- ============================================================
-- 室内设计助手 / Supabase 建表脚本   (UTF-8 无 BOM)
-- 用法: Supabase 控制台 -> 左侧 SQL Editor -> New query
--       整段粘贴 -> 不要选中任何内容 -> Run (Ctrl+Enter)
-- 只需跑一次。全部语句都是幂等的，重复跑也安全。
-- ============================================================

create table if not exists public.chat_history (
  id          text primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  space_key   text not null,
  title       text,
  messages    jsonb not null default '[]'::jsonb,
  conditions  jsonb not null default '{}'::jsonb,
  usage       jsonb,
  updated_at  timestamptz not null default now(),
  object_name text,
  topic       text
);

create index if not exists chat_history_user_updated_idx
  on public.chat_history (user_id, updated_at desc);

-- 行级安全: 这一步不能省。publishable / anon key 是公开的,
-- 没有 RLS 的话任何人都能读整张表。
alter table public.chat_history enable row level security;

drop policy if exists chat_history_select_own on public.chat_history;
create policy chat_history_select_own on public.chat_history
  for select using (auth.uid() = user_id);

drop policy if exists chat_history_insert_own on public.chat_history;
create policy chat_history_insert_own on public.chat_history
  for insert with check (auth.uid() = user_id);

drop policy if exists chat_history_update_own on public.chat_history;
create policy chat_history_update_own on public.chat_history
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists chat_history_delete_own on public.chat_history;
create policy chat_history_delete_own on public.chat_history
  for delete using (auth.uid() = user_id);