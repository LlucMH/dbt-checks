{% macro datediff_days(start_date, end_date) %}
    {{ return(adapter.dispatch('datediff_days', 'dbt_checks')(start_date, end_date)) }}
{% endmacro %}


{% macro default__datediff_days(start_date, end_date) %}
    datediff(day, {{ start_date }}, {{ end_date }})
{% endmacro %}


{% macro regex_match(column_name, pattern) %}
    {{ return(adapter.dispatch('regex_match', 'dbt_checks')(column_name, pattern)) }}
{% endmacro %}


{% macro default__regex_match(column_name, pattern) %}
    regexp_like({{ column_name }}, '{{ pattern }}')
{% endmacro %}


{% macro day_of_week(column_name) %}
    {{ return(adapter.dispatch('day_of_week', 'dbt_checks')(column_name)) }}
{% endmacro %}


{% macro default__day_of_week(column_name) %}
    extract(dow from {{ column_name }})
{% endmacro %}