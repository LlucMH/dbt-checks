{% test not_future_date(model, column_name, where=None) %}

with base as (
    select
        {{ dbt_checks.as_date(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ dbt_checks.current_date_sql() }} as expected_max_date,
    'not_future_date' as failed_check,
    'Date must not be in the future' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_not_future_date_predicate('check_value') }}

{% endtest %}