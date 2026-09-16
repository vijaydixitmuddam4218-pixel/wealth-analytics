{% materialization insert_by_period, adapter='bigquery' %}

    {#
        A custom materialization: instead of rebuilding the whole table
        every run, this only deletes and re-inserts rows matching the
        CURRENT run's partition value (e.g., today's date) — leaving
        every other day's data completely untouched.
    #}

    {%- set target_relation = this -%}
        {%- set partition_column = config.get('meta').get('partition_column') -%}

    {% if not adapter.get_relation(this.database, this.schema, this.identifier) %}
        {#  Table doesn't exist yet — first run, just build it fully  #}
        {% call statement('main') %}
            CREATE TABLE {{ target_relation }} AS
            {{ sql }}
        {% endcall %}
    {% else %}
        {#  Table already exists — delete today's slice, then insert it fresh  #}
        {% call statement('main') %}
            DELETE FROM {{ target_relation }}
            WHERE {{ partition_column }} = (
                SELECT MAX({{ partition_column }}) FROM ({{ sql }})
            );

            INSERT INTO {{ target_relation }}
            {{ sql }}
        {% endcall %}
    {% endif %}

    {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}