-- Migration: Häkchen-Feld für manuell bearbeitete Tankungen
-- (z.B. wenn einzelne Tankungen eines Ausweises separat/selbst abgerechnet werden)
--
-- Ausführen im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- Projekt: rrkqdjswofqhzmrgvsnd

alter table tankungen
  add column if not exists manuell_erledigt boolean not null default false;

create index if not exists idx_tankungen_manuell_erledigt
  on tankungen (manuell_erledigt) where manuell_erledigt = true;
