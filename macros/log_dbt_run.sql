{% macro log_dbt_run(run_status) %}

    {% set insert_sql %}
        INSERT INTO `{{ target.database }}.audit_zone.audit_dbt_runs`
        (run_id, run_started_at, run_completed_at, run_status, invocation_id)
        VALUES (
            '{{ invocation_id }}',
            TIMESTAMP('{{ run_started_at }}'),
            CURRENT_TIMESTAMP(),
            '{{ run_status }}',
            '{{ invocation_id }}'
        )
    {% endset %}

    {% do run_query(insert_sql) %}

{% endmacro %}