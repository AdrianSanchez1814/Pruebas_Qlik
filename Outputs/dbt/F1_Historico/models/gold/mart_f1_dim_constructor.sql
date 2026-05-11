{{
    config(
        materialized='table',
        tags=['gold', 'mart', 'f1', 'powerbi', 'dimension']
    )
}}

-- Gold Layer: Constructor Dimension for Power BI
-- Conformed dimension with aggregated performance metrics

WITH constructor_base AS (
    SELECT * FROM {{ ref('stg_f1_constructor') }}
),

constructor_perf AS (
    SELECT * FROM {{ ref('int_f1_constructor_performance') }}
),

dim_constructor AS (
    SELECT
        -- Dimension Key
        cb.constructor_key,
        
        -- Attributes
        cb.constructor_name,
        cb.nationality AS constructor_nationality,
        cb.info_url,
        
        -- Performance Metrics (for enhanced filtering and analysis)
        COALESCE(cp.total_races, 0) AS total_races,
        COALESCE(cp.total_drivers, 0) AS total_drivers,
        COALESCE(cp.total_points, 0) AS total_points,
        COALESCE(cp.total_wins, 0) AS total_wins,
        COALESCE(cp.total_podiums, 0) AS total_podiums,
        COALESCE(cp.total_points_finishes, 0) AS total_points_finishes,
        COALESCE(cp.total_dnf, 0) AS total_dnf,
        COALESCE(cp.avg_position, 0) AS avg_finish_position,
        COALESCE(cp.best_finish, 999) AS best_finish_position,
        COALESCE(cp.win_rate_pct, 0) AS win_rate_percentage,
        COALESCE(cp.podium_rate_pct, 0) AS podium_rate_percentage,
        COALESCE(cp.points_per_race, 0) AS avg_points_per_race,
        COALESCE(cp.completion_rate_pct, 0) AS race_completion_percentage,
        
        -- Hierarchical Classification (for drill-down in Power BI)
        CASE 
            WHEN COALESCE(cp.total_wins, 0) > 0 THEN 'Championship Winning Team'
            WHEN COALESCE(cp.total_podiums, 0) > 5 THEN 'Podium Competitor'
            WHEN COALESCE(cp.total_points_finishes, 0) > 10 THEN 'Points Scorer'
            ELSE 'Emerging Team'
        END AS team_category,
        
        -- Metadata
        cb._loaded_at AS dimension_created_at,
        COALESCE(cp._last_updated, cb._loaded_at) AS last_updated_at
        
    FROM constructor_base cb
    LEFT JOIN constructor_perf cp 
        ON cb.constructor_key = cp.constructor_key
)

SELECT * FROM dim_constructor
