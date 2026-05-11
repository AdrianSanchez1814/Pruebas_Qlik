# ADR: F1 Histórico Data Model Design

## Metadata
- **Status**: Accepted
- **Date**: 2024
- **Decision Makers**: Data Architecture Team
- **Project**: F1 Histórico - Migration from QlikView to Snowflake/Power BI

## Context

The F1 Histórico project requires migrating data from QlikView (Excel source) to a modern data warehouse architecture in Snowflake, optimized for Power BI consumption. The source data consists of:

- **Constructor table**: 211 records, 4 fields
- **Drivers table**: 857 records, 8 fields  
- **Results table**: 26,080 records, 18 fields

The data originates from "Formula1 - Historico.xlsx" file with sheets: constructor, results, and drivers.

## Decision

We have designed a **three-layer medallion architecture** (Bronze, Silver, Gold) with a **Star Schema** in the Gold layer optimized for Power BI analytics.

### Architecture Layers

#### 1. Bronze Layer (Raw)
**Purpose**: Store unprocessed data exactly as received from source

**Tables**:
- `raw_constructor`
- `raw_drivers`
- `raw_results`

**Design Principles**:
- Mirror source structure without transformations
- Preserve all source data types (initially as strings/variants where needed)
- Include audit columns: `created_at`, `updated_at`, `_source`
- Implement Change Data Capture (CDC) using Snowflake Streams

**Rationale**:
- Maintain data lineage and auditability
- Enable reprocessing without accessing source systems
- Support compliance and data governance requirements

#### 2. Silver Layer (Staging/Conformed)
**Purpose**: Clean, standardize, and conform data

**Tables**:
- `stg_constructor`
- `stg_driver`
- `stg_race_result`

**Transformations Applied**:
- **Data type corrections**: Convert string representations to proper types (numbers, dates)
- **Key cleaning**: Remove duplicates, standardize business keys
- **Name standardization**: Consistent naming conventions (snake_case)
- **Calculated fields**: Add derived fields (e.g., `driver_full_name`, `driver_age`)
- **Flags**: Add boolean indicators (e.g., `is_finished`, `is_classified`)

**Data Quality Views**:
- `vw_stg_constructor_quality`
- `vw_stg_driver_quality`
- `vw_stg_race_result_quality`

**Rationale**:
- Separate data quality concerns from raw data storage
- Create reusable, clean datasets for multiple downstream consumers
- Implement data quality checks at this layer

#### 3. Gold Layer (Business/Marts)
**Purpose**: Business-optimized star schema for analytics

**Star Schema Design**:

**Dimension Tables**:
- `dim_constructor`: Constructor attributes
- `dim_driver`: Driver attributes with demographics
- `dim_race`: Race and circuit information (placeholder for future data)
- `dim_status`: Result status categories (placeholder for future data)

**Fact Table**:
- `fact_race_result`: Grain = one result per driver per race
  - Foreign keys to all dimensions
  - Metrics: points, times, laps
  - Flags: winner, podium, points position
  - Degenerate dimensions: car number, grid position

**Aggregate Tables**:
- `mart_driver_stats`: Pre-aggregated driver statistics
- `mart_constructor_stats`: Pre-aggregated constructor statistics

**Power BI Views**:
- `vw_race_results_detailed`: Denormalized view for detailed analysis
- `vw_driver_performance`: Driver KPIs
- `vw_constructor_performance`: Constructor KPIs

**Rationale**:
- Star schema optimizes Power BI query performance
- Pre-aggregations reduce computational load on Power BI
- Views provide simplified interface for report developers
- Clustering on foreign keys improves join performance

### Key Design Decisions

#### Decision 1: Star Schema Model
**Choice**: Implement star schema instead of snowflake schema or flat tables

**Reasons**:
- Power BI performs best with star schemas
- Simplifies DAX calculations and relationships
- Reduces data duplication
- Improves query performance through clustering

**Alternatives Considered**:
- Snowflake schema: Rejected due to complexity and performance overhead
- Flat denormalized tables: Rejected due to data redundancy and maintenance issues
- Data vault: Rejected as overkill for this dataset size

#### Decision 2: Separate Dimension for Race
**Choice**: Create `dim_race` as separate dimension despite limited current data

**Reasons**:
- **Problematic join identified**: RaceId in results table needs enrichment
- Race information (year, round, circuit, date) is essential for time-based analysis
- Anticipates future data sources with race details
- Maintains referential integrity
- Enables time intelligence in Power BI

**Note**: This dimension requires population from additional data sources not currently available in the QlikView extract

#### Decision 3: Status Dimension
**Choice**: Create `dim_status` as separate dimension

**Reasons**:
- **Simplifies fact table**: Removes status description complexity
- Status has business categorization logic (Finished, Mechanical, Accident)
- Enables filtering by status categories in Power BI
- Reduces redundancy in fact table

#### Decision 4: Pre-Aggregated Tables
**Choice**: Include `mart_driver_stats` and `mart_constructor_stats`

**Reasons**:
- Common KPIs identified from QlikView analysis:
  - Total wins, podiums, points
  - Average position
  - DNF rates
- Pre-aggregation dramatically improves dashboard load times
- Power BI can use aggregations feature pointing to these tables
- Reduces memory footprint in Power BI model

**Alternatives Considered**:
- Calculate everything in Power BI DAX: Rejected due to performance concerns
- Materialized views: Considered but chose tables for explicit refresh control

#### Decision 5: Surrogate Keys
**Choice**: Use autoincrement surrogate keys in dimensions and fact

**Reasons**:
- Protects against source key changes
- Simplifies relationships in Power BI
- Enables future SCD Type 2 implementation if needed
- Standard data warehousing best practice

#### Decision 6: Clustering Strategy
**Choice**: Cluster fact table by (race_key, driver_key, constructor_key)

**Reasons**:
- Most common query patterns in QlikView analysis showed filtering/grouping by:
  - Race (time-based analysis)
  - Driver (driver performance)
  - Constructor (team performance)
- Improves query pruning and performance
- Reduces credit consumption in Snowflake

#### Decision 7: No Data Invention
**Choice**: Only model data present in source metadata

**Reasons**:
- **Explicit requirement**: "Don't create new tables that don't have any reference in metadata"
- Maintain data lineage and trust
- Avoid assumptions about missing data
- Document placeholders for future data (dim_race, dim_status)

**Placeholders Created**:
- `dim_race`: Structure defined, awaits data population
- `dim_status`: Structure defined, awaits data population

#### Decision 8: Audit Columns Standard
**Choice**: Include created_at, updated_at, _source in all tables

**Reasons**:
- Data lineage tracking
- Debugging and troubleshooting support
- Compliance and audit requirements
- Enables incremental loading strategies

#### Decision 9: Data Type Conventions
**Choice**: Use specific Snowflake data types

**Mappings**:
- IDs: `NUMBER(38,0)` (Snowflake integer)
- Decimals: `NUMBER(38,2)` or `NUMBER(38,3)` based on precision needs
- Strings: `VARCHAR` with appropriate sizes
- Dates: `DATE` type
- Timestamps: `TIMESTAMP_NTZ` (no timezone)
- Flags: `BOOLEAN`

**Rationale**:
- Leverage Snowflake's data type optimization
- Ensure compatibility with Power BI
- Balance storage efficiency with query performance

### Metadata Source Analysis

**Source Files Analyzed**:
- `Orden_Script/orden_ejecucion.json`
- QlikView metadata from `Set_Pruebas/F1 codigo y objetos.qvw`

**Fields Identified**:

**Constructor Table** (4 fields):
- constructorId (numeric, key)
- constructorRef (text)
- name (text)
- nationalityCostructor (text) - Note: typo in source

**Drivers Table** (8 fields):
- driverId (numeric, key)
- driverRef (text)
- number_driver (numeric)
- code (text, 3-letter)
- forename (text)
- surname (text)
- dob (date)
- nationalityDriver (text)

**Results Table** (18 fields):
- resultId, raceId, driverId, constructorId (keys)
- number, grid, position, positionText, positionOrder
- points, laps, time, milliseconds
- fastestLap, rank, fastestLapTime, fastestLapSpeed
- statusId

### Naming Conventions

**Standard Applied**: `snake_case` throughout

**Transformations**:
- `constructorId` → `constructor_id`
- `nationalityCostructor` → `constructor_nationality` (typo corrected)
- `driverRef` → `driver_ref`
- `positionOrder` → `position_order`

**Prefixes**:
- Bronze: `raw_`
- Silver: `stg_`
- Gold dimensions: `dim_`
- Gold facts: `fact_`
- Gold aggregates: `mart_`
- Views: `vw_`

## Consequences

### Positive

1. **Performance**: Star schema and clustering optimize Power BI queries
2. **Maintainability**: Clear separation of concerns across layers
3. **Scalability**: Architecture supports future data sources
4. **Data Quality**: Quality checks at Silver layer before business consumption
5. **Auditability**: Complete data lineage from source to consumption
6. **Flexibility**: Pre-aggregates and views provide multiple consumption patterns
7. **Best Practices**: Follows Snowflake and Kimball methodology standards

### Negative

1. **Complexity**: Three-layer architecture requires more maintenance than single-layer
2. **Storage**: Some data duplication across layers increases storage costs
3. **Incomplete**: Race and Status dimensions are placeholders requiring additional data
4. **Processing**: Requires ETL/ELT processes to transform data through layers

### Risks

1. **Missing Data**: Race and Status dimensions cannot be fully populated without additional sources
2. **Performance**: Actual query performance depends on data volumes and usage patterns
3. **Refresh**: Aggregate tables require scheduled refresh processes

### Mitigation Strategies

1. **Missing Data**: Document clearly in schema comments; create issues to source data
2. **Performance**: Monitor query patterns; adjust clustering as needed
3. **Refresh**: Implement Snowflake tasks for automated aggregate refreshes

## Implementation Notes

### Execution Order

1. Execute `database.sql` to create database and schemas
2. Execute `bronze/F1_raw.sql` to create raw tables
3. Execute `silver/F1_staging.sql` to create staging tables
4. Execute `gold/F1_marts.sql` to create star schema

### Data Loading

**Bronze Layer**:
- Use Snowflake COPY INTO or external stages
- Implement Snowpipe for continuous loading if needed

**Silver Layer**:
- Use MERGE statements with streams from Bronze
- Implement data quality checks before loading

**Gold Layer**:
- Populate dimensions first (constructor, driver)
- Load fact table with lookups to dimension keys
- Refresh aggregates after fact loads

### Power BI Connection

- Connect Power BI to Gold layer views
- Use DirectQuery for real-time or Import for performance
- Leverage pre-aggregates for large datasets
- Implement row-level security in Snowflake if needed

## Future Considerations

1. **SCD Type 2**: If historical tracking of dimension changes is needed
2. **Additional Sources**: Race calendar, circuits, seasons data
3. **Real-time Loading**: Implement Snowpipe for continuous ingestion
4. **Data Governance**: Implement Snowflake tags for PII/sensitive data
5. **Cost Optimization**: Review and optimize clustering as data grows
6. **Incremental Loading**: Implement change detection strategies

## References

- Kimball Dimensional Modeling
- Snowflake Best Practices Documentation
- Power BI Star Schema Design Guide
- Project Source: Formula1 - Historico.xlsx via QlikView

## Approval

- **Architect**: [Pending]
- **Data Engineering Lead**: [Pending]
- **BI Lead**: [Pending]
- **Date**: 2024

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Status**: Ready for Review
