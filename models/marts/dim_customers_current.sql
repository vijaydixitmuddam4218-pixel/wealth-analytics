{{
    config(
        materialized='table',
        tags=['marts']
    )
}}

SELECT
    {{ generate_surrogate_key(['customer_id']) }} AS customer_sk,
    customer_id,
    name,
    risk_rating,
    kyc_status
FROM {{ ref('customers_snapshot') }}
WHERE dbt_valid_to IS NULL