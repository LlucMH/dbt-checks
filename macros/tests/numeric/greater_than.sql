{% test greater_than(model, column_name, value, where=None) %}

with base as (
    select
        {{ dbt_checks.as_numeric(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ value }} as expected_min_value,
    'greater_than' as failed_check,
    'Value must be greater than {{ value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_greater_than_predicate(
        'check_value',
        value
    ) }}

{% endtest %}