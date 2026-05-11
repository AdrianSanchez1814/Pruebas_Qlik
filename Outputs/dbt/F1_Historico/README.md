# F1 Historico - dbt Project

## Project Overview
This dbt project transforms Formula 1 historical data from QlikView to Snowflake, preparing it for consumption in Power BI.

**Source System:** QlikView (F1 codigo y objetos.qvw)  
**Target System:** Snowflake → Power BI  
**Project Name:** F1 Histórico

## Data Source
- **Excel File:** Formula1 - Historico.xlsx
  - Constructor sheet (211 rows, 4 fields)
  - Drivers sheet (857 rows, 8 fields)
  - Results sheet (26,080 rows, 24 fields)

## Architecture

### Bronze Layer (Staging)
Data cleaning, type casting, and deduplication:
- `stg_f1_constructor.sql` - Constructor dimension staging
- `stg_f1_drivers.sql` - Drivers dimension staging
- `stg_f1_results.sql` - Results fact table staging with business indicators

### Silver Layer (Intermediate)
Business logic and conformed dimensions:
- `int_f1_results_enriched.sql` - Results joined with dimensions, calculated metrics
  - **Grain:** One row per race result
  - **QlikView Logic:** Implements `Count({<campo={1}>} positionOrder)` as SQL CASE
- `int_f1_constructor_performance.sql` - Aggregated constructor statistics
  - **Grain:** One row per constructor
  - **Metrics:** Win rates, points aggregations, completion rates

### Gold Layer (Marts)
Star schema models optimized for Power BI:
- `mart_f1_race_results.sql` - **Fact Table**
  - Pre-calculated QlikView Set Analysis metrics
  - Denormalized for performance
  - Boolean flags for easy filtering
  
- `mart_f1_dim_constructor.sql` - **Constructor Dimension**
  - Career statistics
  - Hierarchical categories for drill-down
  
- `mart_f1_dim_driver.sql` - **Driver Dimension**
  - Career statistics
  - Driver classifications

## QlikView to dbt Translation

### Original QlikView Expressions
```qlik
// Set Analysis Count
Count({<campo={1}>} positionOrder)

// Simple Aggregation
Sum(positionOrder)

// Average Position
Avg(position)
```

### dbt SQL Implementation
```sql
-- Replaces: Count({<campo={1}>} positionOrder)
CASE 
    WHEN position_order IS NOT NULL AND is_finished = TRUE 
    THEN 1 
    ELSE 0 
END AS count_valid_positions

-- Replaces: Sum(positionOrder)
SUM(position_order) AS sum_position_order

-- Replaces: Avg(position)
AVG(CASE WHEN final_position IS NOT NULL THEN final_position END) AS avg_position
```

## Data Quality Tests

### Bronze Layer
- `not_null` tests on primary keys
- `unique` tests on dimension keys
- Row count validation

### Silver Layer
- Referential integrity checks
- Row count equality with source
- No duplicate joins

### Gold Layer
- Primary key uniqueness
- Foreign key relationships
- Measure validation

## Running the Project

```bash
# Install dependencies
dbt deps

# Test source connections
dbt run-operation source_freshness

# Run models by layer
dbt run --select tag:bronze
dbt run --select tag:silver
dbt run --select tag:gold

# Run all tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## Power BI Integration

### Recommended Relationships
- `mart_f1_race_results[driver_key]` → `mart_f1_dim_driver[driver_key]`
- `mart_f1_race_results[constructor_key]` → `mart_f1_dim_constructor[constructor_key]`

### Pre-calculated Measures (No DAX Required)
- `metric_count_valid_positions` - From QlikView Set Analysis
- `metric_sum_position_order` - Sum aggregation
- `points_earned` - Ready for SUM aggregation
- `is_winner`, `is_podium`, `is_points_finish` - Boolean filters

### Recommended Power BI Visuals
1. **Constructor Performance Table** - Use `mart_f1_dim_constructor`
2. **Driver Career Stats** - Use `mart_f1_dim_driver`
3. **Race Results Details** - Use `mart_f1_race_results` fact table
4. **Hierarchical Drill-down** - Use `team_category` and `driver_category`

## Maintenance

### Incremental Loads
Currently configured for full refresh. For incremental:
```sql
{{
    config(
        materialized='incremental',
        unique_key='result_id'
    )
}}
```

### Data Refresh Schedule
Recommended: Daily at 2 AM UTC
```bash
dbt run --select tag:gold
```

## Contact & Support
**Project:** Aqualia Migration (QlikView → Snowflake → Power BI)  
**Dataset:** Formula 1 Historical Racing Data
