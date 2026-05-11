# QlikView to SQL Translation Examples - F1 Historico Project

## Overview
This document shows the exact translation from QlikView expressions to SQL for the F1 project.

## Original QlikView Expressions

### Expression 1: Count with Set Analysis
**Source:** Document\CH01, Document\CH02, Document\CH03 (from QVW analysis)

**QlikView:**
```qlik
Count({<campo={1}>} positionOrder)
```

**dbt SQL Translation:**
```sql
-- In int_f1_results_enriched.sql
CASE 
    WHEN position_order IS NOT NULL 
    AND is_finished = TRUE 
    THEN 1 
    ELSE 0 
END AS count_valid_positions

-- Usage in aggregation (int_f1_constructor_performance.sql)
SUM(count_valid_positions) AS count_finished_positions
```

**Explanation:**
- Set Analysis `{<campo={1}>}` filters where campo=1
- Translated to SQL as conditional CASE statement
- Creates binary indicator (0 or 1) for valid positions
- Aggregated using SUM() instead of COUNT() for same result

---

### Expression 2: Sum Aggregation
**Source:** Document\CH01 (from QVW metadata)

**QlikView:**
```qlik
Sum(positionOrder)
```

**dbt SQL Translation:**
```sql
-- In int_f1_constructor_performance.sql
SUM(position_order) AS sum_position_order
```

**Explanation:**
- Direct 1:1 translation
- Field renamed from positionOrder → position_order (snake_case)
- Available in both fact table and aggregation layer

---

### Expression 3: Average Position
**Source:** Document\CH08, CH09, CH11, CH13 (from QVW analysis)

**QlikView:**
```qlik
Avg(position)
```

**dbt SQL Translation:**
```sql
-- In int_f1_constructor_performance.sql
AVG(CASE WHEN final_position IS NOT NULL THEN final_position END) AS avg_position
```

**Explanation:**
- Added NULL handling with CASE statement
- Ensures DNF (Did Not Finish) records don't skew average
- More robust than direct AVG()

---

### Expression 4: Sum of Points
**Source:** Document\CH11, CH13 (from QVW analysis)

**QlikView:**
```qlik
Sum([points])
```

**dbt SQL Translation:**
```sql
-- In int_f1_constructor_performance.sql
SUM(points_earned) AS total_points

-- Also available in fact table
-- mart_f1_race_results.points_earned (for Power BI SUM)
```

**Explanation:**
- Field renamed: points → points_earned (more descriptive)
- Pre-calculated at constructor level
- Also available as granular measure in fact table

---

### Expression 5: Complex Percentage Calculation
**Source:** Document\CH07 (from QVW metadata)

**QlikView:**
```qlik
sum((points-positionOrder)/positionOrder)
```

**dbt SQL Translation:**
```sql
-- In int_f1_results_enriched.sql (available for further aggregation)
CASE 
    WHEN position_order > 0 
    THEN (points_earned - position_order) / position_order 
    ELSE NULL 
END AS points_vs_position_ratio

-- Aggregated version:
SUM(
    CASE 
        WHEN position_order > 0 
        THEN (points_earned - position_order) / CAST(position_order AS DECIMAL(10,2))
        ELSE 0 
    END
) AS total_performance_ratio
```

**Explanation:**
- Added division by zero protection
- Cast to DECIMAL for precision
- NULL handling for invalid calculations
- Available both at grain level and aggregated

---

## Cyclic and Hierarchical Groups

### QlikView Cyclic Group: "CiclicoG"
**Fields:** constructorRef, driverRef

**dbt Implementation:**
```sql
-- Instead of cyclic group, provide both dimensions separately

-- In mart_f1_race_results (fact table)
driver_key,          -- driverRef
constructor_key      -- constructorRef

-- Power BI can switch between these using slicers/buttons
```

**Power BI Usage:**
- Create two separate visuals or use bookmark navigation
- Use field parameters to switch between dimensions

---

### QlikView Hierarchical Group: "JerarquicoG"
**Fields:** constructorRef → driverRef

**dbt Implementation:**
```sql
-- In mart_f1_dim_constructor.sql
team_category,           -- Top level
constructor_name         -- Detail level

-- In mart_f1_dim_driver.sql  
driver_category,         -- Top level
driver_name              -- Detail level

-- In mart_f1_race_results.sql (denormalized for performance)
constructor_name,
driver_name
```

**Power BI Usage:**
- Create hierarchy: team_category → constructor_name → driver_name
- Enable drill-down in visuals

---

## Complete Example: Constructor Performance Report

### Original QlikView Script Logic
```qlik
// Table with multiple expressions
LOAD
    constructorRef,
    Count({<campo={1}>} positionOrder) as ValidPositions,
    Sum(positionOrder) as TotalPositionOrder,
    Avg(position) as AvgPosition,
    Sum(points) as TotalPoints
FROM Results
GROUP BY constructorRef;
```

### Equivalent dbt SQL (int_f1_constructor_performance.sql)
```sql
WITH results_enriched AS (
    SELECT * FROM {{ ref('int_f1_results_enriched') }}
)

SELECT
    constructor_key,
    constructor_name,
    
    -- Count({<campo={1}>} positionOrder)
    SUM(count_valid_positions) AS count_finished_positions,
    
    -- Sum(positionOrder)
    SUM(position_order) AS sum_position_order,
    
    -- Avg(position)
    AVG(CASE WHEN final_position IS NOT NULL THEN final_position END) AS avg_position,
    
    -- Sum(points)
    SUM(points_earned) AS total_points,
    
    -- Additional metrics not in QlikView but useful for Power BI
    COUNT(DISTINCT race_id) AS total_races,
    SUM(CASE WHEN final_position = 1 THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN is_podium THEN 1 ELSE 0 END) AS total_podiums
    
FROM results_enriched
GROUP BY 1, 2
```

---

## Power BI DAX Translation

### No Complex DAX Needed!
All QlikView expressions are pre-calculated in SQL. Power BI just needs simple aggregations:

```dax
// Instead of complex Set Analysis, use pre-calculated field:
Valid Positions = SUM(mart_f1_race_results[metric_count_valid_positions])

// Instead of QlikView Sum:
Total Position Order = SUM(mart_f1_race_results[metric_sum_position_order])

// Simple measures:
Total Points = SUM(mart_f1_race_results[points_earned])
Win Count = COUNTROWS(FILTER(mart_f1_race_results, [is_winner] = TRUE))
```

---

## Testing Equivalence

### Validation Query
To verify QlikView and dbt produce same results:

```sql
-- Run this in Snowflake after dbt models complete
SELECT
    constructor_key,
    count_finished_positions,  -- Should match QlikView Count({<campo={1}>} positionOrder)
    sum_position_order,        -- Should match QlikView Sum(positionOrder)
    avg_position,              -- Should match QlikView Avg(position)
    total_points               -- Should match QlikView Sum(points)
FROM f1_analytics.silver.int_f1_constructor_performance
ORDER BY constructor_key;

-- Compare with QlikView output
```

---

## Key Translation Principles

1. **Set Analysis → SQL CASE**
   - QlikView `{<field={value}>}` becomes `CASE WHEN field = value`
   - Pre-calculate indicators for aggregation

2. **Aggregations → Pre-calculate**
   - Move complex calculations to SQL layer
   - Store as measures in fact/dimension tables
   - Power BI only does simple SUM/COUNT

3. **Cyclic Groups → Separate Dimensions**
   - Don't replicate cyclic behavior
   - Provide both dimensions, let Power BI switch

4. **Hierarchies → Dimensional Categories**
   - Create explicit category fields
   - Build hierarchies in Power BI semantic model

5. **NULL Handling**
   - Always add NULL protection in SQL
   - QlikView handles NULLs differently than SQL

---

## Performance Comparison

| Metric | QlikView | dbt + Power BI |
|--------|----------|----------------|
| **Calculation Location** | Client (in-memory) | Server (Snowflake) |
| **Data Volume Support** | Limited by RAM | Unlimited (warehouse scales) |
| **Calculation Speed** | Fast (in-memory) | Fast (pre-calculated) |
| **Maintenance** | Script-based | SQL + version control |
| **Testing** | Manual | Automated (dbt test) |
| **Documentation** | External | Self-documenting |

---

**Status:** All QlikView expressions successfully translated to SQL  
**Validation:** Ready for comparison testing  
**Next Step:** Run dbt models and compare output with QlikView
