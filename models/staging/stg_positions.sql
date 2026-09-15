{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

SELECT
    position_id,
    customer_id,
    UPPER(TRIM(security_id)) AS security_id,
    quantity,
    price,
    market_value,
    position_date,
    UPPER(TRIM(source_system)) AS source_system,
    last_updated_ts
FROM {{ source('raw', 'raw_positions') }}
WHERE position_id IS NOT NULL
  AND quantity > 0
  AND price > 0