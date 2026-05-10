{% test recent_date(model, column_name, max_age_days, where=None) %}

{{ dbt_checks.validate_positive_integer(max_age_days, 'max_age_days') }}

with base as (
    select
        {{ dbt_checks.as_date(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
),

validation as (
    select
        check_value,
        {{ dbt_checks.days_ago(max_age_days) }} as expected_min_date
    from base
)

select
    check_value as failing_value,
    expected_min_date,
    {{ max_age_days }} as expected_max_age_days,
    'recent_date' as failed_check,
    'Date must be within the last {{ max_age_days }} days' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    check_value is not null
    and {{ dbt_checks.build_recent_date_predicate(
        'check_value',
        max_age_days
    ) }}

{% endtest %}