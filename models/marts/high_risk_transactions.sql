{{
    config(
        materialized='table',
        tags=['marts', 'compliance']
    )
}}

SELECT
    transaction_id,
    customer_id,
    transaction_type,
    amount,
    transaction_date,
    {{ audit_columns() }}
FROM {{ ref('stg_transactions') }}
WHERE amount > CAST({{ get_config_value('HIGH_RISK_THRESHOLD') }} AS FLOAT64)