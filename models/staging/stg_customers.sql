{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

SELECT
    customer_id,
    TRIM(name) AS name,
    LOWER(TRIM(email)) AS email,
    COALESCE(NULLIF(TRIM(phone), ''), 'UNKNOWN') AS phone,
    TRIM(address) AS address,
    UPPER(TRIM(risk_rating)) AS risk_rating,
    UPPER(TRIM(kyc_status)) AS kyc_status,
    COALESCE(compliance_flags, 'NONE') AS compliance_flags,
    last_updated_ts
FROM {{ source('raw', 'raw_customers') }}
WHERE customer_id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id, last_updated_ts
    ORDER BY last_updated_ts
) = 1