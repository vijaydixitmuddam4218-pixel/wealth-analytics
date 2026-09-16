{{
    config(
        materialized='incremental',
        partition_by={'field': 'position_date', 'data_type': 'date'},
        incremental_strategy='insert_overwrite',
        tags=['marts']
    )
}}

{% if is_incremental() %}
    {% set validation_query %}
        SELECT
            COUNT(*) AS row_count,
            COUNTIF(quantity <= 0) AS bad_quantity_count
        FROM {{ ref('stg_positions') }}
        WHERE position_date > (SELECT MAX(position_date) FROM {{ this }})
    {% endset %}

    {% set validation_results = run_query(validation_query) %}
    {% set row_count = validation_results.columns['row_count'].values()[0] %}
    {% set bad_quantity_count = validation_results.columns['bad_quantity_count'].values()[0] %}
    {% set is_valid = (row_count > 0 and bad_quantity_count == 0) %}

    {% if not is_valid %}
        {{ log_data_quality_rejection(this.name, 'Empty batch or invalid quantities detected', row_count, bad_quantity_count) }}
        {{ log_bad_position_records() }}
    {% endif %}
{% else %}
    {% set is_valid = true %}
{% endif %}

SELECT
    customer_id,
    security_id,
    quantity,
    price,
    position_date,
    source_system,
    {{ audit_columns() }}
FROM {{ ref('stg_positions') }}
WHERE {{ 'TRUE' if is_valid else 'FALSE' }}
{% if is_incremental() %}
    AND position_date > (SELECT MAX(position_date) FROM {{ this }})
{% endif %}