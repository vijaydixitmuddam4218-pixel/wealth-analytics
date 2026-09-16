{{
    config(
        materialized='table',
        tags=['marts', 'reconciliation']
    )
}}

WITH trading AS (
    SELECT customer_id, security_id, quantity, price, position_date
    FROM {{ ref('stg_positions') }}
    WHERE source_system = 'TRADING_SYSTEM'
),

custody AS (
    SELECT customer_id, security_id, quantity, price, position_date
    FROM {{ ref('stg_positions') }}
    WHERE source_system = 'CUSTODY_SYSTEM'
)

SELECT
    COALESCE(t.customer_id, c.customer_id) AS customer_id,
    COALESCE(t.security_id, c.security_id) AS security_id,
    COALESCE(t.position_date, c.position_date) AS position_date,
    t.quantity AS qty_trading_system,
    c.quantity AS qty_custody_system,
    t.price AS price_trading_system,
    c.price AS price_custody_system,
    CASE
        WHEN t.quantity IS NULL THEN 'MISSING_IN_TRADING'
        WHEN c.quantity IS NULL THEN 'MISSING_IN_CUSTODY'
        WHEN t.quantity != c.quantity THEN 'QUANTITY_MISMATCH'
        WHEN t.price != c.price THEN 'PRICE_MISMATCH'
        ELSE 'MATCH'
    END AS reconciliation_status,
    {{ audit_columns() }}

FROM trading t
FULL OUTER JOIN custody c
    ON t.customer_id = c.customer_id
    AND t.security_id = c.security_id
    AND t.position_date = c.position_date