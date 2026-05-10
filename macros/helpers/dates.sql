{% macro days_ago(n_days) %}

    {{ dbt_checks.dateadd_days(
        dbt_checks.current_date_sql(),
        -1 * n_days
    ) }}

{% endmacro %}


{% macro days_from_now(n_days) %}

    {{ dbt_checks.dateadd_days(
        dbt_checks.current_date_sql(),
        n_days
    ) }}

{% endmacro %}


{% macro current_date_minus_days(n_days) %}

    {{ dbt_checks.days_ago(n_days) }}

{% endmacro %}


{% macro current_date_plus_days(n_days) %}

    {{ dbt_checks.days_from_now(n_days) }}

{% endmacro %}