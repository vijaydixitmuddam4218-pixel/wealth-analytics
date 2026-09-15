{{
    config(
        materialized='table',
        tags=['marts']
    )
}}

-- Joins every transaction to the customer's state AS IT WAS on the
-- transaction date, using the SCD Type 2 snapshot's valid date ranges —
-- not the customer's current state.

SELECT
    t.transaction_id,
    t.customer_id,
    t.transaction_type,
    t.amount,
    t.currency,
    t.transaction_date,
    t.settlement_date,
    c.name AS customer_name,
    c.risk_rating AS risk_rating_at_transaction_time,
    c.kyc_status AS kyc_status_at_transaction_time,
    c.compliance_flags AS compliance_flags_at_transaction_time

FROM {{ ref('stg_transactions') }} t

LEFT JOIN {{ ref('customers_snapshot') }} c
    ON t.customer_id = c.customer_id
    -- Match the transaction date to whichever snapshot row was "active"
    -- on that date: valid_from <= transaction_date < valid_to
    -- (or valid_to IS NULL, meaning that version is still current).
    AND t.transaction_date >= DATE(c.dbt_valid_from)
    AND (
        t.transaction_date < DATE(c.dbt_valid_to)
        OR c.dbt_valid_to IS NULL
    )