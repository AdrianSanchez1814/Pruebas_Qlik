{{
    config(
        materialized='table',
        tags=['silver', 'intermediate', 'f1']
    )
}}

-- Intermediate model: F1 Results with Constructor and Driver details
-- Grain: One row per result (race + driver + constructor combination)
-- Business Rules:
-- - Join results with constructor and driver dimensions
-- - Calculate race performance metrics
-- - Apply QlikView Set Analysis logic: Count({<campo={1}>} positionOrder) becomes conditional count

WITH results AS (
    SELECT * FROM {{ ref('stg_f1_results') }}
),

constructors AS (
    SELECT * FROM {{ ref('stg_f1_constructor') }}
),

drivers AS (
    SELECT * FROM {{ ref('stg_f1_drivers') }}
),

joined_results AS (
    SELECT
        -- Result identifiers
        r.result_id,
        r.race_id,
        
        -- Driver dimension
        r.driver_id,
        d.driver_key,
        d.driver_code,
        d.full_name AS driver_name,
        d.first_name AS driver_first_name,
        d.last_name AS driver_last_name,
        d.nationality AS driver_nationality,
        d.date_of_birth AS driver_dob,
        
        -- Constructor dimension
        r.constructor_id,
        c.constructor_key,
        c.constructor_name,
        c.nationality AS constructor_nationality,
        
        -- Race position metrics
        r.final_position,
        r.position_order,
        r.position_text,
        r.grid_position,
        
        -- Performance metrics
        r.points_earned,
        r.laps_completed,
        r.race_time_milliseconds,
        r.fastest_lap_number,
        r.fastest_lap_time,
        r.fastest_lap_speed,
        
        -- Status and indicators
        r.status_id,
        r.finish_time,
        r.is_finished,
        r.is_podium,
        r.is_points_finish,
        
        -- Calculated fields - Replicate QlikView logic
        -- Original QlikView: Count({<campo={1}>} positionOrder)
        -- Translates to: Count position_order where a specific condition is met
        CASE 
            WHEN r.position_order IS NOT NULL AND r.is_finished = TRUE 
            THEN 1 
            ELSE 0 
        END AS count_valid_positions,
        
        -- Grid gain/loss
        CASE 
            WHEN r.grid_position IS NOT NULL AND r.final_position IS NOT NULL
            THEN r.grid_position - r.final_position
            ELSE NULL
        END AS positions_gained,
        
        -- Performance categories
        CASE
            WHEN r.final_position = 1 THEN 'Winner'
            WHEN r.final_position IN (2, 3) THEN 'Podium'
            WHEN r.final_position <= 10 AND r.points_earned > 0 THEN 'Points'
            WHEN r.is_finished = TRUE THEN 'Finished'
            ELSE 'DNF'
        END AS result_category,
        
        -- Metadata
        r._loaded_at
        
    FROM results r
    LEFT JOIN constructors c 
        ON r.constructor_id = c.constructor_key OR r.constructor_id::VARCHAR = c.constructor_key
    LEFT JOIN drivers d 
        ON r.driver_id = d.driver_id
)

SELECT * FROM joined_results
