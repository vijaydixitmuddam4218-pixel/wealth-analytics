{{
    config(
        materialized='table',
        tags=['marts', 'compliance']
    )
}}

WITH transactions_with_risk_code AS (
    SELECT
        t.transaction_id,
        t.customer_id,
        t.transaction_type,
        t.amount,
        t.transaction_date,
        CASE
            WHEN t.amount < CAST({{ get_config_value('RISK_LOW_MAX') }} AS FLOAT64) THEN 1
            WHEN t.amount < CAST({{ get_config_value('RISK_MEDIUM_MAX') }} AS FLOAT64) THEN 2
            ELSE 3
        END AS risk_code
    FROM {{ ref('stg_transactions') }} t
    WHERE t.amount > CAST({{ get_config_value('HIGH_RISK_THRESHOLD') }} AS FLOAT64)
)

SELECT
    tr.transaction_id,
    tr.customer_id,
    tr.transaction_type,
    tr.amount,
    tr.transaction_date,
    tr.risk_code,
    r.risk_label,
    r.description AS risk_description,
    {{ audit_columns() }}
FROM transactions_with_risk_code tr
LEFT JOIN {{ ref('risk_category_lookup') }} r
    ON tr.risk_code = r.risk_code