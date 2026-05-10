{% test starts_with(model, column_name, prefix, where=None) %}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    '{{ prefix }}' as expected_prefix,
    'starts_with' as failed_check,
    'Value must start with "{{ prefix }}"' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_starts_with_predicate(
        'check_value',
        prefix
    ) }}

{% endtest %}