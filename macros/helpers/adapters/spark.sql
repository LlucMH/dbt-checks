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
  {#-
    Spark SQL string literals share Databricks SQL's escaping rules
    (a fixed set of recognized escapes; unrecognized backslash sequences
    like `\d` or `\s` pass through verbatim), so an unescaped `'` in
    `pattern` still terminates the literal early, and a pattern ending in
    a bare `\` would consume the closing quote as an (incorrectly)
    recognized `\'` escape. Backslash-escaping both `\` and `'` first
    avoids both cases, matching the same fix applied to
    databricks__regex_match.
  -#}
  regexp_like(
    cast({{ expr }} as string),
    '{{ pattern | replace('\\', '\\\\') | replace("'", "\\'") }}'
  )
{% endmacro %}

{% macro spark__day_of_week_sun0(expr) %}
  dayofweek(cast({{ expr }} as date)) - 1
{% endmacro %}

{% macro spark__try_cast_to_date(expr) %}
  {#-
    try_to_date()/try_to_timestamp() are not core Apache Spark SQL
    functions - they're absent on plain Spark clusters reached over the
    Thrift/ODBC/Livy connection methods dbt-spark also supports (unlike
    the dbt-databricks adapter, which always talks to Databricks Runtime
    and does provide them). try_cast(expr as type), added in Spark 3.2,
    is the portable equivalent available across dbt-spark's supported
    versions and connection methods, and already returns NULL on
    unparseable input rather than raising - matching try_cast_to_date's
    contract on every other adapter.
  -#}
  try_cast({{ expr }} as date)
{% endmacro %}

{% macro spark__try_cast_to_timestamp(expr) %}
  try_cast({{ expr }} as timestamp)
{% endmacro %}