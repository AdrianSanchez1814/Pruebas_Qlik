{{
    config(
        materialized='table',
        tags=['silver', 'intermediate', 'f1', 'aggregation']
    )
}}

-- Intermediate model: Constructor Performance Aggregations
-- Grain: One row per constructor
-- Business Logic: Aggregations similar to QlikView expressions

WITH results_enriched AS (
    SELECT * FROM {{ ref('int_f1_results_enriched') }}
),

constructor_stats AS (
    SELECT
        constructor_key,
        constructor_name,
        constructor_nationality,
        
        -- Count metrics - Replicates QlikView: Sum(positionOrder), Count({<campo={1}>} positionOrder)
        COUNT(DISTINCT race_id) AS total_races,
        COUNT(DISTINCT driver_key) AS total_drivers,
        SUM(count_valid_positions) AS count_finished_positions,
        SUM(position_order) AS sum_position_order,
        
        -- Performance aggregations
        AVG(CASE WHEN final_position IS NOT NULL THEN final_position END) AS avg_position,
        SUM(points_earned) AS total_points,
        SUM(laps_completed) AS total_laps,
        
        -- Win/Podium/Points counts
        SUM(CASE WHEN final_position = 1 THEN 1 ELSE 0 END) AS total_wins,
        SUM(CASE WHEN is_podium THEN 1 ELSE 0 END) AS total_podiums,
        SUM(CASE WHEN is_points_finish THEN 1 ELSE 0 END) AS total_points_finishes,
        
        -- DNF statistics
        SUM(CASE WHEN is_finished = FALSE THEN 1 ELSE 0 END) AS total_dnf,
        
        -- Best results
        MIN(CASE WHEN final_position IS NOT NULL THEN final_position END) AS best_finish,
        MAX(points_earned) AS max_points_single_race,
        
        -- Metadata
        MAX(_loaded_at) AS _last_updated
        
    FROM results_enriched
    GROUP BY 1, 2, 3
),

with_calculated_metrics AS (
    SELECT
        *,
        
        -- Win rate
        CASE 
            WHEN total_races > 0 
            THEN ROUND(100.0 * total_wins / total_races, 2)
            ELSE 0
        END AS win_rate_pct,
        
        -- Podium rate
        CASE 
            WHEN total_races > 0 
            THEN ROUND(100.0 * total_podiums / total_races, 2)
            ELSE 0
        END AS podium_rate_pct,
        
        -- Points per race
        CASE 
            WHEN total_races > 0 
            THEN ROUND(total_points / total_races, 2)
            ELSE 0
        END AS points_per_race,
        
        -- Completion rate
        CASE 
            WHEN total_races > 0 
            THEN ROUND(100.0 * (total_races - total_dnf) / total_races, 2)
            ELSE 0
        END AS completion_rate_pct
        
    FROM constructor_stats
)

SELECT * FROM with_calculated_metrics
