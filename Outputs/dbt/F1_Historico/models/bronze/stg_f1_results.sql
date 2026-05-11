{{
    config(
        materialized='view',
        tags=['bronze', 'staging', 'f1']
    )
}}

-- Staging model for Results fact table
-- Source: Formula1 - Historico.xlsx (results sheet)
-- Description: Cleans and standardizes race results data

WITH source AS (
    SELECT *
    FROM {{ source('f1_raw', 'results') }}
),

renamed AS (
    SELECT
        -- Primary Key (composite)
        CAST(resultId AS INTEGER) AS result_id,
        
        -- Foreign Keys
        CAST(raceId AS INTEGER) AS race_id,
        CAST(driverId AS INTEGER) AS driver_id,
        CAST(constructorId AS INTEGER) AS constructor_id,
        
        -- Race position metrics
        CAST(position AS INTEGER) AS final_position,
        CAST(positionOrder AS INTEGER) AS position_order,
        CAST(positionText AS VARCHAR) AS position_text,
        
        -- Performance metrics
        CAST(points AS DECIMAL(10,2)) AS points_earned,
        CAST(laps AS INTEGER) AS laps_completed,
        CAST(milliseconds AS BIGINT) AS race_time_milliseconds,
        CAST(fastestLap AS INTEGER) AS fastest_lap_number,
        CAST(fastestLapTime AS VARCHAR) AS fastest_lap_time,
        CAST(fastestLapSpeed AS DECIMAL(10,3)) AS fastest_lap_speed,
        
        -- Grid and status
        CAST(grid AS INTEGER) AS grid_position,
        CAST(statusId AS INTEGER) AS status_id,
        TRIM(CAST(time AS VARCHAR)) AS finish_time,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
),

cleaned AS (
    SELECT
        *,
        -- Create indicator for whether driver finished race
        CASE 
            WHEN final_position IS NOT NULL AND final_position > 0 THEN TRUE
            ELSE FALSE
        END AS is_finished,
        
        -- Create indicator for podium finish
        CASE 
            WHEN final_position IN (1, 2, 3) THEN TRUE
            ELSE FALSE
        END AS is_podium,
        
        -- Create indicator for points scoring finish
        CASE 
            WHEN points_earned > 0 THEN TRUE
            ELSE FALSE
        END AS is_points_finish
        
    FROM renamed
)

SELECT * FROM cleaned
