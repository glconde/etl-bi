# Alberta Electricity Demand & Pool Price Analytics

### ETL + Dimensional Modeling + Power BI

------------------------------------------------------------------------

## Overview

This project explores Alberta’s hourly electricity demand and pool price
behavior (2020–2025) through an end-to-end data pipeline and analytical
dashboard.

It was built to:

- Practice ETL pipeline development
- Apply dimensional modeling concepts
- Learn and implement Power BI for analytical storytelling
- Explore market volatility through structured KPIs

The result is a balanced data engineering + BI project built on publicly
available Alberta market data.

------------------------------------------------------------------------

## Architecture

Public CSV Data  
↓  
Python ETL (Pandas)  
↓  
PostgreSQL (Docker)  
↓  
Star Schema (dim + fact)  
↓  
Power BI Dashboard

### Components

- **Docker Compose** — PostgreSQL + Adminer  
- **Python ETL** — Loads and transforms raw hourly CSV data  
- **PostgreSQL** — Stores raw and analytics schemas  
- **Power BI Desktop** — Interactive reporting layer

------------------------------------------------------------------------

## Data Model

A star schema was implemented to support clean analytical queries.

### Dimension

`analytics.dim_date_hour`

- ts_utc_key (surrogate key derived from UTC timestamp)
- date_local
- year, month, day
- hour
- is_weekend

### Facts

`analytics.fact_demand` - ts_utc_key - demand_mw

`analytics.fact_pool_price` - ts_utc_key - pool_price

Relationships:

dim_date_hour (1) ──── (∞) fact_demand  
dim_date_hour (1) ──── (∞) fact_pool_price

------------------------------------------------------------------------

## Daylight Saving Time (DST) Handling

Alberta observes Daylight Saving Time, which introduces:

- A missing hour in spring
- A duplicated local hour in fall (e.g., 1:00 AM occurs twice)

Using `date_local` directly as a key would create:

- Duplicate dimension values
- Broken one-to-many relationships
- Incorrect aggregations in Power BI

### Solution

The model uses a UTC-derived surrogate key:

`ts_utc_key = YYYYMMDDHH (from Date_Begin_GMT)`

This guarantees:

- Unique hourly identifiers
- Stable star schema joins
- Correct aggregation across DST boundaries

Local time is preserved for reporting, while UTC ensures relational
integrity.

------------------------------------------------------------------------

## Key Metrics

The dashboard computes:

- Peak Demand (MW)
- Average Demand (MW)
- Average Pool Price (CAD/MWh)
- 95th Percentile Pool Price
- High-Price Hours (\> \$200)

These measures highlight structural volatility changes across years.

------------------------------------------------------------------------

## Dashboard Structure

### Page 1 — Market Overview

- Year / Month / Weekend slicers
- KPI summary cards
- Demand trend (time series)
- Pool price trend (time series)

### Page 2 — Load Profile Heatmap

- Month × Hour matrix
- Conditional formatting heatmap
- Visualization of daily and seasonal demand patterns

------------------------------------------------------------------------

## Power BI Requirements

- **Power BI Desktop (latest version recommended)**
- Tested on recent 2024+ versions of Power BI Desktop
- Requires PostgreSQL connector (included in modern versions)

### Download

Power BI Desktop can be downloaded from the Microsoft Store:

Search for:  
**“Power BI Desktop”**

Or download directly from Microsoft’s official site:  
https://www.microsoft.com/power-bi/desktop

The Microsoft Store version is recommended as it updates automatically.

------------------------------------------------------------------------

## Setup Instructions

### 1. Start Database

``` bash
docker-compose up -d
```

### 2. Load Raw Data

Place CSV inside:

`data_raw/`

Run:

``` bash
python etl/load_raw_demand_price.py
```

### 3. Transform to Analytics Schema

``` bash
docker exec -i etl_bi_db psql -U etl_bi_user -d etl_bi < sql/03_transform_demand_price.sql
```

### 4. Open Power BI

Open:

`reports/alberta-electricity-dashboard.pbix`

Ensure the connection points to the local PostgreSQL container.

------------------------------------------------------------------------

## Technologies Used

- Python
- Pandas
- PostgreSQL 16
- Docker
- Power BI Desktop
- DAX

------------------------------------------------------------------------

## Skills Demonstrated

- ETL pipeline design
- Dockerized database environment
- Dimensional modeling (star schema)
- Time-series data handling
- DST-safe key design
- KPI development in DAX
- Interactive dashboard layout

## 👤 Author

George Louie Conde  
Software Developer  
Calgary, AB  
[LinkedIn](https://linkedin.com/in/glconde)  
[GitHub](https://github.com/glconde)

