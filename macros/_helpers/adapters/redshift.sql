{% macro redshift__current_date_sql() %}
  current_date
{% endmacro %}

{% macro redshift__current_timestamp_sql() %}
  current_timestamp
{% endmacro %}

{% macro redshift__dateadd_days(date_expr, n_days) %}
  dateadd(day, {{ n_days }}, {{ date_expr }})
{% endmacro %}

{% macro redshift__datediff_days(start_date, end_date) %}
  datediff(day, {{ start_date }}, {{ end_date }})
{% endmacro %}

{% macro redshift__regex_match(expr, pattern) %}
  {{ expr }} ~ '{{ pattern }}'
{% endmacro %}

{% macro redshift__day_of_week_sun0(expr) %}
  date_part(dow, {{ expr }})
{% endmacro %}

{% macro redshift__try_cast_to_date(expr) %}
  cast({{ expr }} as date)
{% endmacro %}

{% macro redshift__try_cast_to_timestamp(expr) %}
  cast({{ expr }} as timestamp)
{% endmacro %}