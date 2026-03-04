-- sql/05_add_utc_key_constraints.sql
-- George Conde 03-03-2026
-- continued
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'uq_dim_date_hour_ts_utc_key'
  ) THEN
    ALTER TABLE analytics.dim_date_hour
      ADD CONSTRAINT uq_dim_date_hour_ts_utc_key UNIQUE (ts_utc_key);
  END IF;
END $$;

-- Indexes (IF NOT EXISTS works fine here)
CREATE INDEX IF NOT EXISTS idx_fact_demand_ts_utc_key
  ON analytics.fact_demand(ts_utc_key);

CREATE INDEX IF NOT EXISTS idx_fact_pool_price_ts_utc_key
  ON analytics.fact_pool_price(ts_utc_key);