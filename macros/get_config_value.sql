{% macro get_config_value(key) %}

    (SELECT config_value FROM `{{ target.database }}.analytics_zone.config_compliance` WHERE config_key = '{{ key }}')

{% endmacro %}