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
  {#-
    Postgres has no native TRY_CAST: cast(x as date) raises an error on
    invalid input instead of returning NULL, unlike DuckDB's try_cast or
    Snowflake's try_to_date. This guards with a regex before casting, so
    only strict ISO 8601 (YYYY-MM-DD) strings are accepted — anything else
    returns NULL rather than raising. This is narrower than DuckDB/
    Snowflake's try-cast, which parse a wider range of date formats.
  -#}
  case
    when cast({{ expr }} as text) ~ '^\d{4}-\d{2}-\d{2}$'
      then cast({{ expr }} as date)
    else null
  end
{% endmacro %}

{% macro postgres__try_cast_to_timestamp(expr) %}
  {#-
    Same TRY_CAST limitation as postgres__try_cast_to_date. Accepts
    'YYYY-MM-DD' optionally followed by a 'HH:MI:SS' time component
    (space- or 'T'-separated); anything else returns NULL instead of
    raising.
  -#}
  case
    when cast({{ expr }} as text) ~ '^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}:\d{2})?$'
      then cast({{ expr }} as timestamp)
    else null
  end
{% endmacro %}