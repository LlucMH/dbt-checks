{% test date_diff_less_than(model, start_column, end_column, max_days, where=None) %}

{{ dbt_checks.validate_positive_integer(max_days, 'max_days') }}

with base as (
    select
        {{ dbt_checks.as_date(start_column) }} as check_start_date,
        {{ dbt_checks.as_date(end_column) }} as check_end_date
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
),

validation as (
    select
        check_start_date,
        check_end_date,
        {{ dbt_checks.datediff_days(
            'check_start_date',
            'check_end_date'
        ) }} as diff_days
    from base
)

select
    check_start_date as failing_start_date,
    check_end_date as failing_end_date,
    diff_days as actual_diff_days,
    {{ max_days }} as expected_max_days,
    'date_diff_less_than' as failed_check,
    'Date difference must be less than {{ max_days }} days' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    check_start_date is not null
    and check_end_date is not null
    and {{ dbt_checks.build_less_than_predicate(
        'diff_days',
        max_days,
        true
    ) }}

{% endtest %}