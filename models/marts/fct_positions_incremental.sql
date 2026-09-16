{{
    config(
        materialized='incremental',
        partition_by={'field': 'position_date', 'data_type': 'date'},
        incremental_strategy='insert_overwrite',
        tags=['marts']
    )
}}

SELECT
    customer_id,
    security_id,
    quantity,
    price,
    position_date,
    source_system,
    {{ audit_columns() }}
FROM {{ ref('stg_positions') }}

{% if is_incremental() %}
WHERE position_date > (SELECT MAX(position_date) FROM {{ this }})
{% endif %}