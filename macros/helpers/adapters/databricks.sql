{% macro databricks__current_date_sql() %}
  current_date()
{% endmacro %}

{% macro databricks__current_timestamp_sql() %}
  current_timestamp()
{% endmacro %}

{% macro databricks__dateadd_days(date_expr, n_days) %}
  date_add(cast({{ date_expr }} as date), {{ n_days }})
{% endmacro %}

{% macro databricks__datediff_days(start_date, end_date) %}
  date_diff(day, cast({{ start_date }} as timestamp), cast({{ end_date }} as timestamp))
{% endmacro %}

{% macro databricks__regex_match(expr, pattern) %}
  regexp_like(cast({{ expr }} as string), '{{ pattern }}')
{% endmacro %}

{% macro databricks__day_of_week_sun0(expr) %}
  dayofweek(cast({{ expr }} as date)) - 1
{% endmacro %}

{% macro databricks__try_cast_to_date(expr) %}
  try_cast({{ expr }} as date)
{% endmacro %}

{% macro databricks__try_cast_to_timestamp(expr) %}
  try_cast({{ expr }} as timestamp)
{% endmacro %}