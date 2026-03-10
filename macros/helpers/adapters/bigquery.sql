{% macro bigquery__current_date_sql() %}
  current_date()
{% endmacro %}

{% macro bigquery__current_timestamp_sql() %}
  current_timestamp()
{% endmacro %}

{% macro bigquery__dateadd_days(date_expr, n_days) %}
  date_add(cast({{ date_expr }} as date), interval {{ n_days }} day)
{% endmacro %}

{% macro bigquery__datediff_days(start_date, end_date) %}
  date_diff(cast({{ end_date }} as date), cast({{ start_date }} as date), day)
{% endmacro %}

{% macro bigquery__regex_match(expr, pattern) %}
  regexp_contains(cast({{ expr }} as string), r'{{ pattern }}')
{% endmacro %}

{% macro bigquery__day_of_week_sun0(expr) %}
  extract(dayofweek from cast({{ expr }} as date)) - 1
{% endmacro %}

{% macro bigquery__try_cast_to_date(expr) %}
  safe_cast({{ expr }} as date)
{% endmacro %}

{% macro bigquery__try_cast_to_timestamp(expr) %}
  safe_cast({{ expr }} as timestamp)
{% endmacro %}