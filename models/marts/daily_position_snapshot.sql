{{
    config(
        materialized='insert_by_period',
        tags=['marts'],
        meta={'partition_column': 'position_date'}
    )
}}

SELECT
    customer_id,
    security_id,
    quantity,
    price,
    position_date,
    source_system
FROM {{ ref('stg_positions') }}