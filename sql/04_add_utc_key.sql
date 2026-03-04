-- sql/04_add_utc_key.sql
-- George Conde 03-03-2026
-- A fix issues arising from DST
BEGIN;

ALTER TABLE analytics.dim_date_hour
  ADD COLUMN IF NOT EXISTS ts_utc_key BIGINT;

ALTER TABLE analytics.fact_demand
  ADD COLUMN IF NOT EXISTS ts_utc_key BIGINT;

ALTER TABLE analytics.fact_pool_price
  ADD COLUMN IF NOT EXISTS ts_utc_key BIGINT;

UPDATE analytics.dim_date_hour
SET ts_utc_key = EXTRACT(EPOCH FROM ts_utc)::bigint
WHERE ts_utc_key IS NULL;

UPDATE analytics.fact_demand
SET ts_utc_key = EXTRACT(EPOCH FROM ts_utc)::bigint
WHERE ts_utc_key IS NULL;

UPDATE analytics.fact_pool_price
SET ts_utc_key = EXTRACT(EPOCH FROM ts_utc)::bigint
WHERE ts_utc_key IS NULL;

COMMIT;