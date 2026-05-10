{% macro current_date_sql() %}
    {{ return(adapter.dispatch('current_date_sql', 'dbt_checks')()) }}
{% endmacro %}


{% macro current_timestamp_sql() %}
    {{ return(adapter.dispatch('current_timestamp_sql', 'dbt_checks')()) }}
{% endmacro %}


{% macro dateadd_days(date_expr, n_days) %}
    {{ return(adapter.dispatch('dateadd_days', 'dbt_checks')(date_expr, n_days)) }}
{% endmacro %}


{% macro datediff_days(start_date_expr, end_date_expr) %}
    {{ return(adapter.dispatch('datediff_days', 'dbt_checks')(start_date_expr, end_date_expr)) }}
{% endmacro %}


{% macro regex_match(expr, pattern) %}
    {{ return(adapter.dispatch('regex_match', 'dbt_checks')(expr, pattern)) }}
{% endmacro %}


{% macro day_of_week_sun0(expr) %}
    {{ return(adapter.dispatch('day_of_week_sun0', 'dbt_checks')(expr)) }}
{% endmacro %}


{% macro try_cast_to_date(expr) %}
    {{ return(adapter.dispatch('try_cast_to_date', 'dbt_checks')(expr)) }}
{% endmacro %}


{% macro try_cast_to_timestamp(expr) %}
    {{ return(adapter.dispatch('try_cast_to_timestamp', 'dbt_checks')(expr)) }}
{% endmacro %}


{% macro safe_ratio(numerator, denominator) %}
    {{ return(adapter.dispatch('safe_ratio', 'dbt_checks')(numerator, denominator)) }}
{% endmacro %}


{% macro apply_where(where) %}
    {{ return(adapter.dispatch('apply_where', 'dbt_checks')(where)) }}
{% endmacro %}


# -------------------- default__ fallbacks -------------------- #


{% macro default__current_date_sql() %}
    current_date
{% endmacro %}


{% macro default__current_timestamp_sql() %}
    current_timestamp
{% endmacro %}


{% macro default__dateadd_days(date_expr, n_days) %}
    dateadd(day, {{ n_days }}, {{ date_expr }})
{% endmacro %}


{% macro default__datediff_days(start_date_expr, end_date_expr) %}
    datediff('day', {{ start_date_expr }}, {{ end_date_expr }})
{% endmacro %}


{% macro default__regex_match(expr, pattern) %}
    regexp_like({{ expr }}, '{{ pattern }}')
{% endmacro %}


{% macro default__day_of_week_sun0(expr) %}
    extract(dow from {{ expr }})
{% endmacro %}


{% macro default__try_cast_to_date(expr) %}
    cast({{ expr }} as date)
{% endmacro %}


{% macro default__try_cast_to_timestamp(expr) %}
    cast({{ expr }} as timestamp)
{% endmacro %}


{% macro default__safe_ratio(numerator, denominator) %}

    case
        when {{ denominator }} = 0 then 0
        else {{ numerator }} * 1.0 / {{ denominator }}
    end

{% endmacro %}


{% macro default__apply_where(where) %}

    {% if where is not none %}
        where {{ where }}
    {% endif %}

{% endmacro %}