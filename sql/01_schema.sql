-- sql/01_schema.sql
-- George Conde 03-02-2026
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- raw tables
CREATE TABLE IF NOT EXISTS raw.demand_hourly (
  ts_utc        TIMESTAMPTZ NOT NULL,
  demand_mw     NUMERIC,
  source_file   TEXT,
  loaded_at     TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (ts_utc)
);

CREATE TABLE IF NOT EXISTS raw.generation_hourly (
  ts_utc        TIMESTAMPTZ NOT NULL,
  fuel_type     TEXT NOT NULL,
  generation_mw NUMERIC,
  source_file   TEXT,
  loaded_at     TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (ts_utc, fuel_type)
);

-- star schema for power bi
CREATE TABLE IF NOT EXISTS analytics.dim_date_hour (
  ts_utc        TIMESTAMPTZ PRIMARY KEY,
  ts_local      TIMESTAMPTZ NOT NULL,
  date_local    DATE NOT NULL,
  year          INT NOT NULL,
  month         INT NOT NULL,
  month_name    TEXT NOT NULL,
  day           INT NOT NULL,
  hour          INT NOT NULL,
  day_of_week   INT NOT NULL,
  is_weekend    BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_fuel_type (
  fuel_type_id   SERIAL PRIMARY KEY,
  fuel_type_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.fact_demand (
  ts_utc     TIMESTAMPTZ PRIMARY KEY,
  demand_mw  NUMERIC,
  FOREIGN KEY (ts_utc) REFERENCES analytics.dim_date_hour(ts_utc)
);

CREATE TABLE IF NOT EXISTS analytics.fact_generation (
  ts_utc        TIMESTAMPTZ NOT NULL,
  fuel_type_id  INT NOT NULL,
  generation_mw NUMERIC,
  PRIMARY KEY (ts_utc, fuel_type_id),
  FOREIGN KEY (ts_utc) REFERENCES analytics.dim_date_hour(ts_utc),
  FOREIGN KEY (fuel_type_id) REFERENCES analytics.dim_fuel_type(fuel_type_id)
);

-- indexes
CREATE INDEX IF NOT EXISTS idx_fact_generation_ts ON analytics.fact_generation (ts_utc);
CREATE INDEX IF NOT EXISTS idx_fact_generation_fuel ON analytics.fact_generation (fuel_type_id, ts_utc);