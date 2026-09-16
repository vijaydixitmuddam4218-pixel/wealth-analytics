{% macro audit_columns() %}

    CURRENT_TIMESTAMP() AS dbt_run_date,
    '{{ invocation_id }}' AS dbt_run_id,
    '{{ this.name }}' AS dbt_model_name

{% endmacro %}