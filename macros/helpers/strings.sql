{% macro escape_sql_string(value) %}
    {{ return(
        (value | string).replace("'", "''")
    ) }}
{% endmacro %}