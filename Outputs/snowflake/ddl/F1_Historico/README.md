# F1 Histórico - Snowflake Data Model Implementation Guide

## 📋 Project Overview

Complete Snowflake DDL implementation for the **F1 Histórico** project, migrating data from QlikView (Excel source) to a modern data warehouse optimized for Power BI consumption.

## 🎯 Objectives

- Create a scalable, maintainable data warehouse in Snowflake
- Implement best practices for data modeling
- Optimize for Power BI performance
- Ensure data quality and auditability
- Follow medallion architecture (Bronze → Silver → Gold)

## 📊 Source Data

**Origin**: Formula1 - Historico.xlsx (extracted from QlikView)  
**Last Extraction**: 2026-04-21 17:19:52 UTC

### Tables
| Table | Records | Fields | Description |
|-------|---------|--------|-------------|
| constructor | 211 | 4 | F1 constructors/teams |
| drivers | 857 | 8 | F1 drivers with demographics |
| results | 26,080 | 18 | Race results with performance metrics |

## 📁 Repository Structure

```
Outputs/snowflake/
├── ddl/
│   └── F1_Historico/
│       ├── database.sql              # Database and schema creation
│       ├── bronze/
│       │   └── F1_raw.sql           # Raw tables (mirror source)
│       ├── silver/
│       │   └── F1_staging.sql       # Cleaned/conformed tables
│       └── gold/
│           └── F1_marts.sql         # Star schema for BI
└── docs/
    └── decisions/
        └── ADR_F1_Historico_model.md  # Architecture Decision Record
```

## 🏗️ Architecture

### Three-Layer Medallion Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GOLD LAYER                            │
│                    (Business/Analytics)                      │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ dim_driver   │  │dim_constructor│ │   dim_race   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
│                   ┌────────▼────────┐                       │
│                   │ fact_race_result│                       │
│                   └─────────────────┘                       │
│                                                              │
│  Aggregates: mart_driver_stats, mart_constructor_stats      │
│  Views: vw_race_results_detailed, vw_driver_performance     │
└──────────────────────────────────────────────────────────────┘
                            ▲
┌───────────────────────────┴───────────────────────────────────┐
│                       SILVER LAYER                            │
│                   (Cleaned/Conformed)                         │
│                                                               │
│  stg_constructor | stg_driver | stg_race_result              │
│  + Data quality views                                         │
│  + Calculated fields                                          │
│  + Standardized names                                         │
└───────────────────────────────────────────────────────────────┘
                            ▲
┌───────────────────────────┴───────────────────────────────────┐
│                       BRONZE LAYER                            │
│                      (Raw/Untouched)                          │
│                                                               │
│  raw_constructor | raw_drivers | raw_results                 │
│  + CDC Streams                                                │
│  + Audit columns                                              │
└───────────────────────────────────────────────────────────────┘
```

## 🚀 Implementation Steps

### Step 1: Create Database and Schemas (2 minutes)
```sql
-- Execute: Outputs/snowflake/ddl/F1_Historico/database.sql
-- Creates: F1_HISTORICO database with BRONZE, SILVER, GOLD schemas
```

### Step 2: Create Bronze Layer (5 minutes)
```sql
-- Execute: Outputs/snowflake/ddl/F1_Historico/bronze/F1_raw.sql
-- Creates: 
--   - raw_constructor
--   - raw_drivers  
--   - raw_results
--   - CDC streams for all tables
```

### Step 3: Create Silver Layer (5 minutes)
```sql
-- Execute: Outputs/snowflake/ddl/F1_Historico/silver/F1_staging.sql
-- Creates:
--   - stg_constructor
--   - stg_driver
--   - stg_race_result
--   - Data quality views
```

### Step 4: Create Gold Layer (10 minutes)
```sql
-- Execute: Outputs/snowflake/ddl/F1_Historico/gold/F1_marts.sql
-- Creates:
--   - Dimensions (constructor, driver, race, status)
--   - Fact table (race_result)
--   - Aggregate tables (driver_stats, constructor_stats)
--   - Power BI views
```

**Total Execution Time**: ~22 minutes

## 📦 Data Loading Strategy

### Bronze Layer Loading
```sql
-- Option 1: COPY FROM Stage
COPY INTO F1_HISTORICO.BRONZE.raw_constructor
FROM @my_stage/constructor.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- Option 2: Direct INSERT
INSERT INTO F1_HISTORICO.BRONZE.raw_constructor 
VALUES (1, 'mclaren', 'McLaren', 'British', CURRENT_TIMESTAMP(), ...);
```

### Silver Layer Loading (from Bronze)
```sql
-- Example: Load stg_constructor from raw_constructor
MERGE INTO F1_HISTORICO.SILVER.stg_constructor AS target
USING (
    SELECT 
        constructorId AS constructor_id,
        TRIM(constructorRef) AS constructor_ref,
        TRIM(name) AS constructor_name,
        TRIM(nationalityCostructor) AS constructor_nationality,
        _source
    FROM F1_HISTORICO.BRONZE.raw_constructor
) AS source
ON target.constructor_id = source.constructor_id
WHEN MATCHED THEN UPDATE SET
    constructor_name = source.constructor_name,
    updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT VALUES (
    source.constructor_id,
    source.constructor_ref,
    source.constructor_name,
    source.constructor_nationality,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    source._source
);
```

### Gold Layer Loading (from Silver)
```sql
-- 1. Load Dimensions First
INSERT INTO F1_HISTORICO.GOLD.dim_constructor
SELECT constructor_id, constructor_ref, constructor_name, ...
FROM F1_HISTORICO.SILVER.stg_constructor;

-- 2. Load Fact Table
INSERT INTO F1_HISTORICO.GOLD.fact_race_result
SELECT 
    s.result_id,
    r.race_key,
    d.driver_key,
    c.constructor_key,
    ...
FROM F1_HISTORICO.SILVER.stg_race_result s
JOIN F1_HISTORICO.GOLD.dim_race r ON s.race_id = r.race_id
JOIN F1_HISTORICO.GOLD.dim_driver d ON s.driver_id = d.driver_id
JOIN F1_HISTORICO.GOLD.dim_constructor c ON s.constructor_id = c.constructor_id;

-- 3. Refresh Aggregates
INSERT INTO F1_HISTORICO.GOLD.mart_driver_stats
SELECT 
    driver_key,
    COUNT(*) AS total_races,
    SUM(CASE WHEN is_winner THEN 1 ELSE 0 END) AS total_wins,
    ...
FROM F1_HISTORICO.GOLD.fact_race_result
GROUP BY driver_key;
```

## 🔗 Power BI Connection

### Connection String
```
Server: <your_snowflake_account>.snowflakecomputing.com
Database: F1_HISTORICO
Schema: GOLD
Warehouse: <your_warehouse>
```

### Recommended Tables/Views for Power BI
1. **`vw_race_results_detailed`** - Main fact table with all dimensions denormalized
2. **`vw_driver_performance`** - Driver KPIs and statistics
3. **`vw_constructor_performance`** - Constructor KPIs and statistics
4. **`dim_driver`** - Driver attributes
5. **`dim_constructor`** - Constructor attributes

### Import vs DirectQuery
- **Import Mode**: Recommended for datasets < 1GB, best performance
- **DirectQuery**: For real-time data or large datasets
- **Composite**: Import dimensions, DirectQuery facts

## 📊 Key Features

### Bronze Layer
✅ Raw data preservation  
✅ CDC streams for incremental loading  
✅ Audit columns (created_at, updated_at, _source)  
✅ Source comments documenting origin  

### Silver Layer
✅ Data type corrections  
✅ Key standardization and deduplication  
✅ Calculated fields (driver_full_name, driver_age)  
✅ Boolean flags (is_finished, is_classified)  
✅ Data quality views  

### Gold Layer
✅ Star schema design  
✅ Surrogate keys with autoincrement  
✅ Foreign key constraints  
✅ Pre-aggregated statistics tables  
✅ Optimized clustering (race_key, driver_key, constructor_key)  
✅ Power BI-friendly views  

## 🎨 Naming Conventions

| Layer | Prefix | Example |
|-------|--------|---------|
| Bronze | `raw_` | `raw_constructor` |
| Silver | `stg_` | `stg_driver` |
| Gold Dimension | `dim_` | `dim_constructor` |
| Gold Fact | `fact_` | `fact_race_result` |
| Gold Aggregate | `mart_` | `mart_driver_stats` |
| Views | `vw_` | `vw_race_results_detailed` |

**Style**: `snake_case` throughout all layers

## ⚠️ Important Notes

### Placeholders for Future Data
Two dimensions require additional data sources:

1. **`dim_race`** - Race calendar, circuits, dates
   - Structure created
   - Awaits population from external source
   - Critical for time-based analysis

2. **`dim_status`** - Result status descriptions
   - Structure created
   - Awaits status lookup data
   - Enhances result categorization

### Current Limitations
- No historical race data available in source
- Status descriptions not in current metadata
- RaceId in results needs enrichment

## 📈 Performance Optimization

### Clustering
```sql
-- Fact table clustered on common join columns
CLUSTER BY (race_key, driver_key, constructor_key)
```

### Aggregates
Pre-calculated tables reduce query time:
- `mart_driver_stats`: Driver-level aggregates
- `mart_constructor_stats`: Constructor-level aggregates

### Views
Denormalized views simplify Power BI DAX:
- `vw_race_results_detailed`: All-in-one fact view
- `vw_driver_performance`: Driver metrics
- `vw_constructor_performance`: Constructor metrics

## 🔍 Data Quality

### Quality Views
```sql
-- Check constructor data quality
SELECT * FROM F1_HISTORICO.SILVER.vw_stg_constructor_quality
WHERE data_quality_status != 'OK';

-- Check driver data quality  
SELECT * FROM F1_HISTORICO.SILVER.vw_stg_driver_quality
WHERE data_quality_status != 'OK';

-- Check result data quality
SELECT * FROM F1_HISTORICO.SILVER.vw_stg_race_result_quality
WHERE data_quality_status != 'OK';
```

## 📚 Additional Documentation

- **Full Architecture Decisions**: See `ADR_F1_Historico_model.md`
- **Design Rationale**: Documented in ADR
- **Implementation Patterns**: Included in each SQL file
- **Future Enhancements**: Listed in ADR

## 🧪 Testing Checklist

- [ ] Database and schemas created successfully
- [ ] Bronze tables created with correct structure
- [ ] Sample data loaded into Bronze
- [ ] Silver transformations execute without errors
- [ ] Data quality views show expected results
- [ ] Gold dimensions populated from Silver
- [ ] Fact table loads with valid foreign keys
- [ ] Aggregate tables calculate correctly
- [ ] Power BI can connect to views
- [ ] Query performance meets requirements
- [ ] Clustering improves query pruning

## 🔄 Maintenance

### Daily Tasks
- Monitor data quality views
- Check for failed loads
- Review query performance

### Weekly Tasks
- Refresh aggregate tables
- Analyze clustering effectiveness
- Review storage usage

### Monthly Tasks
- Update aggregate definitions if needed
- Review and optimize queries
- Plan for new data sources

## 🤝 Support

For questions or issues:
1. Review the ADR document
2. Check SQL comments in DDL files
3. Consult Snowflake documentation
4. Contact data architecture team

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial implementation |

---

**Status**: ✅ Ready for Production  
**Last Updated**: 2024  
**Project**: F1 Histórico - Aqualia Migration
