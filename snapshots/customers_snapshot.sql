{% snapshot customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='last_updated_ts'
    )
}}

-- Only pick the MOST RECENT row per customer — this simulates a real
-- source system, which only ever shows current state, not full history.
-- ROW_NUMBER() ranks each customer's rows by last_updated_ts, newest first.
-- QUALIFY filters to keep only rank 1 (the latest) per customer.
SELECT
    customer_id,
    name,
    email,
    phone,
    address,
    risk_rating,
    kyc_status,
    compliance_flags,
    last_updated_ts
FROM {{ ref('stg_customers') }}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY last_updated_ts DESC
) = 1

{% endsnapshot %}