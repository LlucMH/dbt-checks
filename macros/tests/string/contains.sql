{% test contains(model, column_name, substring, where=None) %}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    '{{ substring }}' as expected_substring,
    'contains' as failed_check,
    'Value must contain substring "{{ substring }}"' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_contains_predicate(
        'check_value',
        substring
    ) }}

{% endtest %}