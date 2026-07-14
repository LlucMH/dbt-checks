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
  {#-
    Databricks SQL string literals only interpret a fixed set of
    recognized escapes (\', \", \\, \n, \t, ...); unrecognized backslash
    sequences like `\d` or `\s` pass through verbatim, so regex patterns
    mostly "just work" unescaped. But an unescaped `'` still terminates
    the literal early, and a pattern ending in a bare `\` would consume
    the closing quote as an (incorrectly) recognized `\'` escape.
    Backslash-escaping both `\` and `'` first avoids both cases: `\\`
    round-trips to a literal `\` (so `\d` still compiles to `\d`), and the
    closing quote can never be swallowed.
  -#}
  regexp_like(
    cast({{ expr }} as string),
    '{{ pattern | replace('\\', '\\\\') | replace("'", "\\'") }}'
  )
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