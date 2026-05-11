{{ config(materialized='table') }}

SELECT
    result_id AS result_key,
    race_id AS race_key,
    driver_key,
    constructor_key,
    driver_name,
    constructor_name,
    final_position,
    points_earned,
    is_finished,
    is_podium,
    count_valid_positions AS metric_count_valid_positions,
    _loaded_at
FROM {{ ref('int_f1_results_enriched') }}
