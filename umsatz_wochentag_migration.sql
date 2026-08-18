-- Migration: RPC-Funktion für "Umsatz nach Wochentag" auf dem Dashboard
-- Serverseitige Aggregation (schnell, auch bei 150k+ Tankungen), statt
-- alle Rohdaten ans Frontend zu laden.
--
-- Ausführen im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- Projekt: rrkqdjswofqhzmrgvsnd

create or replace function umsatz_nach_wochentag(von date default null, bis date default null)
returns table(wochentag int, summe_euro numeric, summe_liter numeric, anzahl bigint)
language sql
stable
as $$
  select
    extract(dow from hidatum)::int as wochentag,  -- 0=Sonntag .. 6=Samstag (Postgres-Standard)
    sum(hipreis)  as summe_euro,
    sum(himenge)  as summe_liter,
    count(*)      as anzahl
  from tankungen
  where (von is null or hidatum >= von)
    and (bis is null or hidatum <= bis)
  group by 1
  order by 1;
$$;
