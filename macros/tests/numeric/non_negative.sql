{% test non_negative(model, column_name, where=None) %}

with base as (
    select
        {{ dbt_checks.as_numeric(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    0 as expected_min_value,
    'non_negative' as failed_check,
    'Value must be greater than or equal to 0' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_greater_than_predicate(
        'check_value',
        0,
        true
    ) }}

{% endtest %}