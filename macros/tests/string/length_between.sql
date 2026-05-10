{% test length_between(model, column_name, min_length, max_length, where=None) %}

{{ dbt_checks.validate_min_max(min_length, max_length) }}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    length(check_value) as actual_length,
    {{ min_length }} as expected_min_length,
    {{ max_length }} as expected_max_length,
    'length_between' as failed_check,
    'Value length must be between {{ min_length }} and {{ max_length }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_between_predicate(
        'length(check_value)',
        min_length,
        max_length
    ) }}

{% endtest %}