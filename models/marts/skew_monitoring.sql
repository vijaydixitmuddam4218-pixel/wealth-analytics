{{
    config(
        materialized='table',
        tags=['marts', 'monitoring']
    )
}}

WITH customer_volume AS (
    SELECT customer_id, COUNT(*) AS transaction_count
    FROM {{ ref('stg_transactions') }}
    GROUP BY customer_id
),

total_volume AS (
    SELECT SUM(transaction_count) AS grand_total FROM customer_volume
)

SELECT
    customer_volume.customer_id,
    customer_volume.transaction_count,
    ROUND(customer_volume.transaction_count * 100.0 / total_volume.grand_total, 1) AS pct_of_total,
    CASE
        WHEN customer_volume.transaction_count * 100.0 / total_volume.grand_total > 40 THEN 'HIGH_CONCENTRATION'
        ELSE 'NORMAL'
    END AS finding,
    {{ audit_columns() }}
FROM customer_volume
CROSS JOIN total_volume