# F1 Histórico - Snowflake DDL Documentation

## 📋 Project Overview

This project contains the complete DDL (Data Definition Language) scripts for the **F1 Histórico** data warehouse in Snowflake, implementing a medallion architecture (Bronze, Silver, Gold) optimized for Power BI consumption.

---

## 🎯 Objective

Generate complete DDL for bronze, silver, and gold layers in Snowflake based on metadata extracted from QlikView files for the Aqualia project.

---

## 📊 Source Data

- **Project Name**: F1 Histórico
- **Source File**: Formula1 - Historico.xlsx
- **Metadata Source**: `Set_Pruebas/F1 codigo y objetos.qvw`
- **Data Volume**:
  - Constructor: 211 rows, 4 fields
  - Resultados: 26,080 rows, 24 fields
  - Drivers: 857 rows, 8 fields

---

## 🏗️ Architecture

### Database Structure
```
F1_HISTORICO
├── BRONZE (Raw Layer)
│   ├── raw_constructor
│   ├── raw_resultados
│   └── raw_drivers
├── SILVER (Staging Layer)
│   ├── stg_constructor
│   ├── stg_drivers
│   └── stg_race_results
└── GOLD (Mart Layer - Star Schema)
    ├── dim_constructor
    ├── dim_driver
    ├── dim_race
    ├── dim_status
    ├── mart_race_results (Fact Table)
    ├── vw_constructor_performance
    ├── vw_driver_performance
    └── vw_race_results_detail
```

---

## 📁 File Structure

```
Outputs/snowflake/ddl/F1_Historico/
├── README.md                                      # This file
├── database.sql                                   # Database and schemas creation
├── bronze/
│   └── F1_Historico_raw.sql                      # Bronze layer tables
├── silver/
│   └── F1_Historico_staging.sql                  # Silver layer tables
├── gold/
│   └── F1_Historico_marts.sql                    # Gold layer star schema
└── docs/
    └── decisions/
        └── ADR_F1_Historico_model.md             # Architecture Decision Record
```

---

## 🚀 Execution Instructions

### Prerequisites
- Snowflake account with appropriate permissions
- Warehouse created and running
- SYSADMIN role (or equivalent)

### Step 1: Create Database and Schemas
```sql
-- Execute from Snowflake worksheet
@Outputs/snowflake/ddl/F1_Historico/database.sql
```

**Expected Result**: 
- Database `F1_HISTORICO` created
- Schemas: `BRONZE`, `SILVER`, `GOLD` created

### Step 2: Create Bronze Layer
```sql
USE DATABASE F1_HISTORICO;
USE SCHEMA BRONZE;
@Outputs/snowflake/ddl/F1_Historico/bronze/F1_Historico_raw.sql
```

**Expected Result**: 
- 3 raw tables created: `raw_constructor`, `raw_resultados`, `raw_drivers`
- 1 view created: `vw_bronze_summary`

### Step 3: Create Silver Layer
```sql
USE SCHEMA SILVER;
@Outputs/snowflake/ddl/F1_Historico/silver/F1_Historico_staging.sql
```

**Expected Result**: 
- 3 staging tables created: `stg_constructor`, `stg_drivers`, `stg_race_results`
- Indexes created for performance
- 1 view created: `vw_silver_data_quality`

### Step 4: Create Gold Layer
```sql
USE SCHEMA GOLD;
@Outputs/snowflake/ddl/F1_Historico/gold/F1_Historico_marts.sql
```

**Expected Result**: 
- 4 dimension tables created
- 1 fact table created with clustering
- 3 analytical views created
- 1 summary view created
- Indexes and foreign keys created

---

## ✅ Validation Queries

After execution, validate the model with these queries:

### Check All Objects Created
```sql
-- Count objects by schema
SELECT 
    table_schema,
    table_type,
    COUNT(*) AS object_count
FROM F1_HISTORICO.INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER', 'GOLD')
GROUP BY table_schema, table_type
ORDER BY table_schema, table_type;
```

### Check Bronze Layer
```sql
SELECT * FROM F1_HISTORICO.BRONZE.vw_bronze_summary;
```

### Check Silver Layer
```sql
SELECT * FROM F1_HISTORICO.SILVER.vw_silver_data_quality;
```

### Check Gold Layer
```sql
SELECT * FROM F1_HISTORICO.GOLD.vw_gold_summary;
```

### Validate Star Schema Relationships
```sql
-- Check fact table structure
DESCRIBE TABLE F1_HISTORICO.GOLD.mart_race_results;

-- Check foreign keys
SHOW IMPORTED KEYS IN F1_HISTORICO.GOLD.mart_race_results;

-- Check clustering
SHOW TABLES LIKE 'mart_race_results' IN F1_HISTORICO.GOLD;
```

---

## 🎨 Design Highlights

### Bronze Layer
- **Purpose**: Raw data storage (untransformed)
- **Features**:
  - Mirror source structure
  - All original data types
  - Audit columns: `created_at`, `updated_at`, `_source`
  - Comments in Spanish

### Silver Layer
- **Purpose**: Cleaned and conformed data
- **Transformations**:
  - ✅ Corrected data types
  - ✅ Cleaned keys with constraints
  - ✅ Standardized names (snake_case)
  - ✅ Calculated fields: `grid_gain`, `is_finished`, `is_podium`, `age_years`
  - ✅ Performance indexes

### Gold Layer (Star Schema)
- **Purpose**: BI-ready dimensional model
- **Design**:
  - 4 Dimensions with surrogate keys
  - 1 Fact table with clustering
  - 3 Pre-built analytical views
  - Optimized for Power BI consumption
- **Grain**: One row per race result (driver x race x constructor)

---

## 📖 Naming Conventions

### Table Prefixes
- `raw_` = Bronze layer tables
- `stg_` = Silver layer tables
- `dim_` = Gold layer dimensions
- `mart_` = Gold layer facts
- `vw_` = Views

### Column Naming
- **Snake_case** for all columns
- Surrogate keys: `[table]_key`
- Natural keys: `[table]_id`
- Descriptive names in English

### Mandatory Audit Columns
All tables include:
- `created_at TIMESTAMP_NTZ`
- `updated_at TIMESTAMP_NTZ`
- `_source STRING`

---

## 🔑 Key Design Decisions

1. **Star Schema Model** - Optimized for Power BI
2. **Surrogate Keys** - AUTOINCREMENT in dimensions
3. **Separated Race Dimension** - Avoids complex joins
4. **No Aggregated Tables** - Done dynamically in Power BI
5. **Spanish Comments** - Client requirement (Aqualia)
6. **Clustering by race_key** - Optimizes temporal queries
7. **Boolean Flags** - Simplifies Power BI filters

Full rationale documented in: `docs/decisions/ADR_F1_Historico_model.md`

---

## 📊 Expected Data Volumes

After loading data:
- **Bronze**: ~27,148 rows total
- **Silver**: ~27,148 rows total (cleaned)
- **Gold**: ~27,148 rows in fact + ~1,000+ dimension rows

---

## 🎯 Next Steps

### 1. ETL Implementation
- [ ] Create ETL pipelines for Bronze layer ingestion
- [ ] Implement Silver transformations
- [ ] Build Gold aggregations
- [ ] Schedule incremental loads

### 2. Power BI Integration
- [ ] Connect Power BI to Gold schema
- [ ] Validate star schema relationships
- [ ] Create semantic model
- [ ] Build dashboards

### 3. Data Quality
- [ ] Implement data quality checks
- [ ] Set up monitoring alerts
- [ ] Configure data profiling
- [ ] Document data lineage

### 4. Performance Optimization
- [ ] Monitor query performance
- [ ] Optimize clustering keys
- [ ] Review index usage
- [ ] Configure automatic clustering

### 5. Documentation
- [ ] Document ETL processes
- [ ] Create user guides
- [ ] Build data dictionary
- [ ] Maintain change log

---

## 🛠️ Maintenance

### Regular Tasks
- **Daily**: Check ETL job status
- **Weekly**: Review query performance
- **Monthly**: Analyze storage costs
- **Quarterly**: Review and optimize indexes

### Clustering Maintenance
```sql
-- Check clustering status
SELECT SYSTEM$CLUSTERING_INFORMATION('F1_HISTORICO.GOLD.mart_race_results');

-- Manual reclustering (if needed)
ALTER TABLE F1_HISTORICO.GOLD.mart_race_results RECLUSTER;
```

### Index Maintenance
```sql
-- Rebuild indexes
ALTER TABLE F1_HISTORICO.SILVER.stg_race_results DROP ALL INDEXES;
-- Then recreate from SQL scripts
```

---

## 📞 Support

For questions or issues:
1. Review ADR documentation
2. Check Snowflake documentation
3. Contact data engineering team

---

## 📝 Version History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2025-01-XX | DDL Generation Agent | Initial DDL creation |

---

## 📚 References

- [Snowflake Documentation](https://docs.snowflake.com)
- [Power BI Star Schema Guide](https://docs.microsoft.com/power-bi/guidance/star-schema)
- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- Architecture Decision Record: `docs/decisions/ADR_F1_Historico_model.md`

---

**Status**: ✅ Ready for Deployment

**Last Updated**: 2025-01-XX
