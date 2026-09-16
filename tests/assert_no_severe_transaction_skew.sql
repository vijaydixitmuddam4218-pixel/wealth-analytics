-- This test FAILS if any single customer represents more than 40% of
-- total transaction volume. Singular tests pass when they return ZERO
-- rows — so this query should return nothing under normal conditions,
-- and return the offending customer_id if skew crosses the threshold.

WITH customer_volume AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count
    FROM {{ ref('stg_transactions') }}
    GROUP BY customer_id
),

total_volume AS (
    SELECT SUM(transaction_count) AS grand_total
    FROM customer_volume
)

SELECT
    customer_volume.customer_id,
    customer_volume.transaction_count,
    ROUND(customer_volume.transaction_count * 100.0 / total_volume.grand_total, 1) AS pct_of_total
FROM customer_volume
CROSS JOIN total_volume
WHERE customer_volume.transaction_count * 100.0 / total_volume.grand_total > 40