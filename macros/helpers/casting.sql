{% macro as_date(expression) %}
    {{ return(adapter.dispatch('as_date', 'dbt_checks')(expression)) }}
{% endmacro %}


{% macro default__as_date(expression) %}
    cast({{ expression }} as date)
{% endmacro %}


{% macro as_string(expression) %}
    {{ return(adapter.dispatch('as_string', 'dbt_checks')(expression)) }}
{% endmacro %}


{% macro default__as_string(expression) %}
    cast({{ expression }} as {{ dbt.type_string() }})
{% endmacro %}


{% macro as_numeric(expression) %}
    {{ return(adapter.dispatch('as_numeric', 'dbt_checks')(expression)) }}
{% endmacro %}


{% macro default__as_numeric(expression) %}
    cast({{ expression }} as numeric)
{% endmacro %}


{% macro cast_to_date(value) %}
    {{ return(adapter.dispatch('cast_to_date', 'dbt_checks')(value)) }}
{% endmacro %}


{% macro default__cast_to_date(value) %}
    {%- set value_str = value | string | trim -%}

    {%- if dbt_checks.is_iso_date_literal(value_str) -%}
        cast('{{ value_str }}' as date)
    {%- else -%}
        cast({{ value_str }} as date)
    {%- endif -%}
{% endmacro %}


{% macro cast_to_timestamp(value) %}
    {{ return(adapter.dispatch('cast_to_timestamp', 'dbt_checks')(value)) }}
{% endmacro %}


{% macro default__cast_to_timestamp(value) %}
    cast('{{ value }}' as timestamp)
{% endmacro %}


{% macro cast_column_to_string(column_name) %}
    {{ dbt_checks.as_string(column_name) }}
{% endmacro %}


{% macro cast_column_to_numeric(column_name) %}
    {{ dbt_checks.as_numeric(column_name) }}
{% endmacro %}