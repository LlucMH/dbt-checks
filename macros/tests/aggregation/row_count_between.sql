{% test row_count_between(model, min_value, max_value, where=None) %}

{{ dbt_checks.validate_non_negative_integer(min_value, 'min_value') }}
{{ dbt_checks.validate_non_negative_integer(max_value, 'max_value') }}
{{ dbt_checks.validate_min_max(min_value, max_value) }}

with validation as (
    select
        count(*) as metric_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    metric_value as actual_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'row_count_between' as failed_check,
    'Row count must be between {{ min_value }} and {{ max_value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    {{ dbt_checks.build_between_predicate('metric_value', min_value, max_value) }}

{% endtest %}