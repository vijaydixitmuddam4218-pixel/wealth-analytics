{{
    config(
        materialized='table',
        tags=['marts', 'regulatory']
    )
}}

SELECT
    p.position_date AS report_date,
    p.customer_id,
    c.name AS customer_name,
    c.kyc_status,
    c.risk_rating,
    p.security_id,
    SUM(p.quantity * p.price) AS total_market_value,
    COUNT(*) AS position_count,
    {{ audit_columns() }}
FROM {{ ref('fct_positions_incremental') }} p
LEFT JOIN {{ ref('customers_snapshot') }} c
    ON p.customer_id = c.customer_id
    AND p.position_date >= DATE(c.dbt_valid_from)
    AND (p.position_date < DATE(c.dbt_valid_to) OR c.dbt_valid_to IS NULL)
WHERE c.kyc_status = 'APPROVED'
GROUP BY p.position_date, p.customer_id, c.name, c.kyc_status, c.risk_rating, p.security_id