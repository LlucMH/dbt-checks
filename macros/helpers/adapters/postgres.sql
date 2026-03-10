{% macro postgres__current_date_sql() %}
  current_date
{% endmacro %}

{% macro postgres__current_timestamp_sql() %}
  current_timestamp
{% endmacro %}

{% macro postgres__dateadd_days(date_expr, n_days) %}
  ({{ date_expr }} + interval '{{ n_days }} day')
{% endmacro %}

{% macro postgres__datediff_days(start_date, end_date) %}
  (cast({{ end_date }} as date) - cast({{ start_date }} as date))
{% endmacro %}

{% macro postgres__regex_match(expr, pattern) %}
  {{ expr }} ~ '{{ pattern }}'
{% endmacro %}

{% macro postgres__day_of_week_sun0(expr) %}
  date_part('dow', {{ expr }})
{% endmacro %}

{% macro postgres__try_cast_to_date(expr) %}
  cast({{ expr }} as date)
{% endmacro %}

{% macro postgres__try_cast_to_timestamp(expr) %}
  cast({{ expr }} as timestamp)
{% endmacro %}