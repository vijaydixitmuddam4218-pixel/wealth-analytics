{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

SELECT
    transaction_id,
    customer_id,
    UPPER(TRIM(transaction_type)) AS transaction_type,
    amount,
    UPPER(TRIM(currency)) AS currency,
    transaction_date,
    settlement_date,
    counterparty_id,
    last_updated_ts
FROM {{ source('raw', 'raw_transactions') }}
WHERE transaction_id IS NOT NULL
  AND settlement_date >= transaction_date
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY transaction_id
    ORDER BY last_updated_ts DESC
) = 1