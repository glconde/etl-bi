-- sql/03_transform_demand_price.sql
-- George Conde 03-03-2026
-- Build analytics dimensions + facts from raw tables

BEGIN;

-- 1) dim_date_hour: derive local time attributes for Alberta (America/Edmonton)
-- note: store ts_utc as the primary key and compute ts_local for reporting.
INSERT INTO analytics.dim_date_hour (
  ts_utc,
  ts_local,
  date_local,
  year,
  month,
  month_name,
  day,
  hour,
  day_of_week,
  is_weekend
)
SELECT
  r.ts_utc,
  (r.ts_utc AT TIME ZONE 'America/Edmonton') AS ts_local,
  ((r.ts_utc AT TIME ZONE 'America/Edmonton')::date) AS date_local,
  EXTRACT(YEAR  FROM (r.ts_utc AT TIME ZONE 'America/Edmonton'))::int AS year,
  EXTRACT(MONTH FROM (r.ts_utc AT TIME ZONE 'America/Edmonton'))::int AS month,
  TO_CHAR((r.ts_utc AT TIME ZONE 'America/Edmonton'), 'Mon') AS month_name,
  EXTRACT(DAY   FROM (r.ts_utc AT TIME ZONE 'America/Edmonton'))::int AS day,
  EXTRACT(HOUR  FROM (r.ts_utc AT TIME ZONE 'America/Edmonton'))::int AS hour,
  EXTRACT(DOW   FROM (r.ts_utc AT TIME ZONE 'America/Edmonton'))::int AS day_of_week,
  (EXTRACT(DOW  FROM (r.ts_utc AT TIME ZONE 'America/Edmonton')) IN (0,6)) AS is_weekend
FROM raw.demand_hourly r
ON CONFLICT (ts_utc) DO NOTHING;

-- 2) fact_demand
INSERT INTO analytics.fact_demand (ts_utc, demand_mw)
SELECT ts_utc, demand_mw
FROM raw.demand_hourly
ON CONFLICT (ts_utc)
DO UPDATE SET demand_mw = EXCLUDED.demand_mw;

-- 3) fact_pool_price
INSERT INTO analytics.fact_pool_price (ts_utc, pool_price)
SELECT ts_utc, pool_price
FROM raw.pool_price_hourly
ON CONFLICT (ts_utc)
DO UPDATE SET pool_price = EXCLUDED.pool_price;

COMMIT;