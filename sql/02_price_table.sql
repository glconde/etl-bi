-- sql/02_price_table.sql
-- George Conde 03-02-2026
CREATE TABLE IF NOT EXISTS raw.pool_price_hourly (
  ts_utc        TIMESTAMPTZ NOT NULL,
  pool_price    NUMERIC,
  source_file   TEXT,
  loaded_at     TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (ts_utc)
);

CREATE TABLE IF NOT EXISTS analytics.fact_pool_price (
  ts_utc      TIMESTAMPTZ PRIMARY KEY,
  pool_price  NUMERIC,
  FOREIGN KEY (ts_utc) REFERENCES analytics.dim_date_hour(ts_utc)
);