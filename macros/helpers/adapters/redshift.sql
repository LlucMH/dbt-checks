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
  {#-
    Redshift is Postgres-derived and runs with standard_conforming_strings
    on by default, so backslash is not a special character in a regular
    string literal here (unlike Snowflake/BigQuery/Databricks/Spark, where
    pattern also needs backslash-escaping). An unescaped `'` in `pattern`
    would still terminate the literal early, so it's doubled per
    standard SQL quote-escaping - the only transform this dialect needs.
  -#}
  {{ expr }} ~ '{{ pattern | replace("'", "''") }}'
{% endmacro %}

{% macro redshift__day_of_week_sun0(expr) %}
  date_part(dow, {{ expr }})
{% endmacro %}

{% macro redshift__try_cast_to_date(expr) %}
  try_cast({{ expr }} as date)
{% endmacro %}

{% macro redshift__try_cast_to_timestamp(expr) %}
  try_cast({{ expr }} as timestamp)
{% endmacro %}