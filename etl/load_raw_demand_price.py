import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text

CSV_PATH = Path("data_raw/Hourly_Metered_Volumes_and_Pool_Price_and_AIL_2020-Jul2025.csv")

DB_URL = os.getenv(
    "DB_URL",
    "postgresql+psycopg2://etl_bi_user:etl_bi_password@localhost:5432/etl_bi"
)

def main() -> None:
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV not found: {CSV_PATH.resolve()}")

    # Read only what we need (fast + memory friendly)
    usecols = ["Date_Begin_GMT", "ACTUAL_AIL", "ACTUAL_POOL_PRICE"]
    df = pd.read_csv(CSV_PATH, usecols=usecols)

    # Parse timestamps
    # Date_Begin_GMT looks like "2020-01-01 7:00" (no TZ), treat as UTC
    df["ts_utc"] = pd.to_datetime(df["Date_Begin_GMT"], errors="coerce", utc=True)

    # Coerce numerics
    df["demand_mw"] = pd.to_numeric(df["ACTUAL_AIL"], errors="coerce")
    df["pool_price"] = pd.to_numeric(df["ACTUAL_POOL_PRICE"], errors="coerce")

    # Drop bad rows
    df = df.dropna(subset=["ts_utc"]).copy()

    source_file = CSV_PATH.name

    engine = create_engine(DB_URL, future=True)

    # Insert via executemany UPSERT
    df_demand = df[["ts_utc", "demand_mw"]].copy()
    df_demand["source_file"] = source_file
    demand_rows = df_demand.to_dict("records")

    df_price = df[["ts_utc", "pool_price"]].copy()
    df_price["source_file"] = source_file
    price_rows = df_price.to_dict("records")

    upsert_demand_sql = """
    INSERT INTO raw.demand_hourly (ts_utc, demand_mw, source_file)
    VALUES (%(ts_utc)s, %(demand_mw)s, %(source_file)s)
    ON CONFLICT (ts_utc)
    DO UPDATE SET
        demand_mw = EXCLUDED.demand_mw,
        source_file = EXCLUDED.source_file,
        loaded_at = now();
    """

    upsert_price_sql = """
    INSERT INTO raw.pool_price_hourly (ts_utc, pool_price, source_file)
    VALUES (%(ts_utc)s, %(pool_price)s, %(source_file)s)
    ON CONFLICT (ts_utc)
    DO UPDATE SET
        pool_price = EXCLUDED.pool_price,
        source_file = EXCLUDED.source_file,
        loaded_at = now();
    """

    with engine.begin() as conn:
        conn.exec_driver_sql(upsert_demand_sql, demand_rows)
        conn.exec_driver_sql(upsert_price_sql, price_rows)

    print(f"Loaded raw.demand_hourly: {len(demand_rows):,} rows")
    print(f"Loaded raw.pool_price_hourly: {len(price_rows):,} rows")

if __name__ == "__main__":
    main()