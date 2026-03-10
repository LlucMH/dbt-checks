{% macro days_ago(n_days) %}
  {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), -1 * n_days) }}
{% endmacro %}

{% macro days_from_now(n_days) %}
  {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), n_days) }}
{% endmacro %}

{% macro days_ago(n_days) %}
  {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), -1 * n_days) }}
{% endmacro %}

{% macro days_from_now(n_days) %}
  {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), n_days) }}
{% endmacro %}