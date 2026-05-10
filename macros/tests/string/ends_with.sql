{% test ends_with(model, column_name, suffix, where=None) %}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    '{{ suffix }}' as expected_suffix,
    'ends_with' as failed_check,
    'Value must end with "{{ suffix }}"' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_ends_with_predicate(
        'check_value',
        suffix
    ) }}

{% endtest %}