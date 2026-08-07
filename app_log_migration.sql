-- Migration für Tankstellenabrechnung v.132
-- Legt die Tabelle für die persistente Log-Historie
-- (DBF-Import-Protokoll + Email-Versand-Protokoll) an.
--
-- Ausführen im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- Projekt: rrkqdjswofqhzmrgvsnd

create table if not exists app_log (
  id            bigint generated always as identity primary key,
  created_at    timestamptz not null default now(),
  typ           text not null,          -- 'import' | 'email'
  quelle        text,                   -- z.B. 'ORT, KUNDEN, MARB' oder 'Rechnung 4711'
  nachricht     text not null,          -- voller Log-Text bzw. Zeile
  neu           integer,                -- nur bei typ='import': Anzahl neuer Datensätze
  geaendert     integer,                -- nur bei typ='import': Anzahl geänderter Datensätze
  unveraendert  integer,                -- nur bei typ='import': Anzahl unveränderter Datensätze
  status        text,                   -- 'ok' | 'fehler' | 'info'
  details       jsonb                   -- z.B. Beispiel-Änderungen pro Feld, Email-Metadaten
);

create index if not exists idx_app_log_created on app_log (created_at desc);
create index if not exists idx_app_log_typ on app_log (typ);

-- Row Level Security aktivieren, analog zu den anderen Tabellen der App:
alter table app_log enable row level security;

create policy "authenticated full access on app_log"
  on app_log
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Optional: automatische Löschung alter Einträge (>2 Jahre) auch serverseitig
-- absichern, falls die App das mal nicht macht. Braucht pg_cron (wie bei den
-- Supabase-Ping-Workflows schon genutzt). Kann übersprungen werden, da die
-- App das clientseitig beim Öffnen der Log-Historie bereits erledigt.
--
-- select cron.schedule(
--   'app_log_cleanup',
--   '0 3 * * *',
--   $$ delete from app_log where created_at < now() - interval '730 days' $$
-- );
