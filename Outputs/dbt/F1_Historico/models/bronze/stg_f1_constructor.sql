{{
    config(
        materialized='view',
        tags=['bronze', 'staging', 'f1']
    )
}}

-- Staging model for Constructor dimension
-- Source: Formula1 - Historico.xlsx (constructor sheet)
-- Description: Cleans and standardizes constructor data

WITH source AS (
    SELECT *
    FROM {{ source('f1_raw', 'constructor') }}
),

renamed AS (
    SELECT
        -- Primary Key
        constructorRef AS constructor_key,
        
        -- Descriptive fields
        TRIM(name) AS constructor_name,
        TRIM(nationality) AS nationality,
        TRIM(url) AS info_url,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY constructor_key 
            ORDER BY _loaded_at DESC
        ) AS _row_num
    FROM renamed
)

SELECT
    constructor_key,
    constructor_name,
    nationality,
    info_url,
    _loaded_at
FROM deduped
WHERE _row_num = 1
