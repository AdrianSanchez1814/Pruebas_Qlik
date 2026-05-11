{{
    config(
        materialized='table',
        tags=['gold', 'mart', 'f1', 'powerbi', 'dimension']
    )
}}

WITH driver_base AS (
    SELECT * FROM {{ ref('stg_f1_drivers') }}
),

driver_stats AS (
    SELECT
        driver_key,
        COUNT(DISTINCT race_id) AS career_races,
        SUM(points_earned) AS career_points,
        SUM(CASE WHEN final_position = 1 THEN 1 ELSE 0 END) AS career_wins,
        SUM(CASE WHEN is_podium THEN 1 ELSE 0 END) AS career_podiums,
        AVG(CASE WHEN final_position IS NOT NULL THEN final_position END) AS avg_finish_position,
        MIN(CASE WHEN final_position IS NOT NULL THEN final_position END) AS best_finish
    FROM {{ ref('int_f1_results_enriched') }}
    GROUP BY 1
)

SELECT
    db.driver_key,
    db.driver_id,
    db.driver_code,
    db.first_name,
    db.last_name,
    db.full_name,
    db.date_of_birth,
    db.nationality AS driver_nationality,
    COALESCE(ds.career_races, 0) AS total_career_races,
    COALESCE(ds.career_points, 0) AS total_career_points,
    COALESCE(ds.career_wins, 0) AS total_career_wins,
    COALESCE(ds.career_podiums, 0) AS total_career_podiums,
    COALESCE(ds.avg_finish_position, 0) AS avg_career_finish,
    COALESCE(ds.best_finish, 999) AS best_career_finish,
    CASE 
        WHEN COALESCE(ds.career_wins, 0) >= 10 THEN 'Legend'
        WHEN COALESCE(ds.career_wins, 0) >= 1 THEN 'Race Winner'
        WHEN COALESCE(ds.career_podiums, 0) >= 5 THEN 'Podium Finisher'
        WHEN COALESCE(ds.career_points, 0) > 0 THEN 'Points Scorer'
        ELSE 'Rookie'
    END AS driver_category,
    db._loaded_at
FROM driver_base db
LEFT JOIN driver_stats ds ON db.driver_key = ds.driver_key
