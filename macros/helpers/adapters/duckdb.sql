{% macro duckdb__current_date_sql() %}
  current_date
{% endmacro %}

{% macro duckdb__current_timestamp_sql() %}
  current_timestamp
{% endmacro %}

{% macro duckdb__dateadd_days(date_expr, n_days) %}
  cast({{ date_expr }} as date) + {{ n_days }}
{% endmacro %}

{% macro duckdb__datediff_days(start_date, end_date) %}
  datediff('day', {{ start_date }}, {{ end_date }})
{% endmacro %}

{% macro duckdb__regex_match(expr, pattern) %}
  {{ expr }} ~ '{{ pattern }}'
{% endmacro %}

{% macro duckdb__day_of_week_sun0(expr) %}
  extract(dow from {{ expr }})
{% endmacro %}

{% macro duckdb__try_cast_to_date(expr) %}
  try_cast({{ expr }} as date)
{% endmacro %}

{% macro duckdb__try_cast_to_timestamp(expr) %}
  try_cast({{ expr }} as timestamp)
{% endmacro %}