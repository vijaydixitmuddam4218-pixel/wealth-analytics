{% snapshot customers_snapshot_check %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['kyc_status']
    )
}}

SELECT
    customer_id,
    kyc_status
FROM {{ source('raw', 'raw_customers') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) = 1

{% endsnapshot %}