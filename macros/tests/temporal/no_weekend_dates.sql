{% test no_weekend_dates(model, column_name, where=None) %}

with base as (
    select
        {{ dbt_checks.as_date(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
),

validation as (
    select
        check_value,
        {{ dbt_checks.day_of_week_sun0("check_value") }} as day_of_week
    from base
)

select
    check_value as failing_value,
    day_of_week as actual_day_of_week,
    'weekday only' as expected_date_type,
    'no_weekend_dates' as failed_check,
    'Date must not fall on a weekend' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    check_value is not null
    and {{ dbt_checks.build_no_weekend_date_predicate('day_of_week') }}

{% endtest %}