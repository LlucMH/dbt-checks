{% macro escape_sql_string(value) %}
    {{ return(
        (value | string).replace("'", "''")
    ) }}
{% endmacro %}


{% macro safe_sql_string_literal(value) %}
    {{ return("'" ~ dbt_checks.escape_sql_string(value) ~ "'") }}
{% endmacro %}