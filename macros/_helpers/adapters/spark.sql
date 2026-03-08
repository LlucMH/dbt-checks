{% macro spark__current_date_sql() %}
  current_date()
{% endmacro %}

{% macro spark__current_timestamp_sql() %}
  current_timestamp()
{% endmacro %}

{% macro spark__dateadd_days(date_expr, n_days) %}
  date_add(cast({{ date_expr }} as date), {{ n_days }})
{% endmacro %}

{% macro spark__datediff_days(start_date, end_date) %}
  datediff(cast({{ end_date }} as date), cast({{ start_date }} as date))
{% endmacro %}

{% macro spark__regex_match(expr, pattern) %}
  regexp_like(cast({{ expr }} as string), '{{ pattern }}')
{% endmacro %}

{% macro spark__day_of_week_sun0(expr) %}
  dayofweek(cast({{ expr }} as date)) - 1
{% endmacro %}

{% macro spark__try_cast_to_date(expr) %}
  try_to_date({{ expr }})
{% endmacro %}

{% macro spark__try_cast_to_timestamp(expr) %}
  try_to_timestamp({{ expr }})
{% endmacro %}