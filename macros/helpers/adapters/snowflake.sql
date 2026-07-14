{% macro snowflake__current_date_sql() %}
  current_date()
{% endmacro %}

{% macro snowflake__current_timestamp_sql() %}
  current_timestamp()
{% endmacro %}

{% macro snowflake__dateadd_days(date_expr, n_days) %}
  dateadd(day, {{ n_days }}, {{ date_expr }})
{% endmacro %}

{% macro snowflake__datediff_days(start_date, end_date) %}
  datediff(day, {{ start_date }}, {{ end_date }})
{% endmacro %}

{% macro snowflake__regex_match(expr, pattern) %}
  {#-
    Snowflake single-quoted string literals interpret backslash escape
    sequences by default, so a pattern containing `\d`, `\s`, etc. would
    have its backslashes consumed by literal parsing before regexp_like
    ever sees them, and a literal `'` would break out of the string
    literal entirely. Backslash-escaping both `\` and `'` first produces
    an equivalent literal that Snowflake parses unambiguously, matching
    the same fix applied to bigquery__regex_match.
  -#}
  regexp_like(
    {{ expr }},
    '{{ pattern | replace('\\', '\\\\') | replace("'", "\\'") }}'
  )
{% endmacro %}

{% macro snowflake__day_of_week_sun0(expr) %}
  case dayname({{ expr }})
    when 'Sun' then 0
    when 'Mon' then 1
    when 'Tue' then 2
    when 'Wed' then 3
    when 'Thu' then 4
    when 'Fri' then 5
    when 'Sat' then 6
  end
{% endmacro %}

{% macro snowflake__try_cast_to_date(expr) %}
  try_to_date({{ expr }})
{% endmacro %}

{% macro snowflake__try_cast_to_timestamp(expr) %}
  try_to_timestamp({{ expr }})
{% endmacro %}