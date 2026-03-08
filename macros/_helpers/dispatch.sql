{% macro current_date_sql() %}
  {{ return(adapter.dispatch('current_date_sql', 'dbt_checks')()) }}
{% endmacro %}

{% macro current_timestamp_sql() %}
  {{ return(adapter.dispatch('current_timestamp_sql', 'dbt_checks')()) }}
{% endmacro %}

{% macro dateadd_days(date_expr, n_days) %}
  {{ return(adapter.dispatch('dateadd_days', 'dbt_checks')(date_expr, n_days)) }}
{% endmacro %}

{% macro datediff_days(start_date, end_date) %}
  {{ return(adapter.dispatch('datediff_days', 'dbt_checks')(start_date, end_date)) }}
{% endmacro %}

{% macro regex_match(expr, pattern) %}
  {{ return(adapter.dispatch('regex_match', 'dbt_checks')(expr, pattern)) }}
{% endmacro %}

{% macro day_of_week_sun0(expr) %}
  {{ return(adapter.dispatch('day_of_week_sun0', 'dbt_checks')(expr)) }}
{% endmacro %}

{% macro try_cast_to_date(expr) %}
  {{ return(adapter.dispatch('try_cast_to_date', 'dbt_checks')(expr)) }}
{% endmacro %}

{% macro try_cast_to_timestamp(expr) %}
  {{ return(adapter.dispatch('try_cast_to_timestamp', 'dbt_checks')(expr)) }}
{% endmacro %}

{# -------------------- default__ fallbacks -------------------- #}

{% macro default__current_date_sql() %}
  current_date
{% endmacro %}

{% macro default__current_timestamp_sql() %}
  current_timestamp
{% endmacro %}

{% macro default__dateadd_days(date_expr, n_days) %}
  dateadd(day, {{ n_days }}, {{ date_expr }})
{% endmacro %}

{% macro default__datediff_days(start_date, end_date) %}
  datediff(day, {{ start_date }}, {{ end_date }})
{% endmacro %}

{% macro default__regex_match(expr, pattern) %}
  regexp_like({{ expr }}, '{{ pattern }}')
{% endmacro %}

{% macro default__day_of_week_sun0(expr) %}
  extract(dow from {{ expr }})
{% endmacro %}

{% macro default__try_cast_to_date(expr) %}
  cast({{ expr }} as date)
{% endmacro %}

{% macro default__try_cast_to_timestamp(expr) %}
  cast({{ expr }} as timestamp)
{% endmacro %}