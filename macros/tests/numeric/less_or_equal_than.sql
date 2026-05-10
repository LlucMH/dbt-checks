{% test less_or_equal_than(model, column_name, value, where=None) %}

{{ dbt_checks.validate_required_number(value, 'value') }}

with base as (
    select
        {{ dbt_checks.as_numeric(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ value }} as expected_max_value,
    'less_or_equal_than' as failed_check,
    'Value must be less than or equal to {{ value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_less_than_predicate(
        'check_value',
        value,
        true
    ) }}

{% endtest %}