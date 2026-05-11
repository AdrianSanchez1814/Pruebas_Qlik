{{ config(materialized='view') }}

SELECT
    driverRef AS driver_key,
    CAST(driverId AS INTEGER) AS driver_id,
    TRIM(code) AS driver_code,
    TRIM(forename) AS first_name,
    TRIM(surname) AS last_name,
    TRIM(nationality) AS nationality,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM {{ source('f1_raw', 'drivers') }}
