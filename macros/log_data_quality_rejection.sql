{% macro log_data_quality_rejection(model_name, reason, row_count, bad_quantity_count) %}

    {% set insert_sql %}
        INSERT INTO `{{ target.database }}.audit_zone.audit_data_quality_rejections`
        (model_name, rejected_at, reason, row_count, bad_quantity_count, invocation_id)
        VALUES (
            '{{ model_name }}', CURRENT_TIMESTAMP(), '{{ reason }}',
            {{ row_count }}, {{ bad_quantity_count }}, '{{ invocation_id }}'
        )
    {% endset %}
    {% do run_query(insert_sql) %}

{% endmacro %}


{% macro log_bad_position_records() %}

    {% set insert_sql %}
        INSERT INTO `{{ target.database }}.audit_zone.audit_bad_position_records`
        (customer_id, security_id, quantity, price, position_date, source_system, rejected_at, invocation_id)
        SELECT
            customer_id, security_id, quantity, price, position_date, source_system,
            CURRENT_TIMESTAMP(), '{{ invocation_id }}'
        FROM {{ ref('stg_positions') }}
        WHERE position_date > (SELECT MAX(position_date) FROM {{ this }})
          AND quantity <= 0
    {% endset %}
    {% do run_query(insert_sql) %}

{% endmacro %}