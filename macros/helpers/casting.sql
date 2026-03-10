{% macro cast_to_date(value) %}
    {{ return(adapter.dispatch('cast_to_date', 'dbt_checks')(value)) }}
{% endmacro %}


{% macro default__cast_to_date(value) %}
    cast('{{ value }}' as date)
{% endmacro %}


{% macro cast_to_timestamp(value) %}
    {{ return(adapter.dispatch('cast_to_timestamp', 'dbt_checks')(value)) }}
{% endmacro %}


{% macro default__cast_to_timestamp(value) %}
    cast('{{ value }}' as timestamp)
{% endmacro %}


{% macro cast_column_to_string(column_name) %}
    {{ return(adapter.dispatch('cast_column_to_string', 'dbt_checks')(column_name)) }}
{% endmacro %}


{% macro default__cast_column_to_string(column_name) %}
    cast({{ column_name }} as {{ dbt.type_string() }})
{% endmacro %}


{% macro cast_column_to_numeric(column_name) %}
    {{ return(adapter.dispatch('cast_column_to_numeric', 'dbt_checks')(column_name)) }}
{% endmacro %}


{% macro default__cast_column_to_numeric(column_name) %}
    cast({{ column_name }} as numeric)
{% endmacro %}