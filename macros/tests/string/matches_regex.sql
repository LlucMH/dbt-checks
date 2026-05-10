{% test matches_regex(model, column_name, pattern, where=None) %}

{{ dbt_checks.validate_required_string(pattern, 'pattern') }}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    '{{ pattern }}' as expected_pattern,
    'matches_regex' as failed_check,
    'Value must match regex pattern "{{ pattern }}"' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_regex_not_match_predicate(
        'check_value',
        pattern
    ) }}

{% endtest %}