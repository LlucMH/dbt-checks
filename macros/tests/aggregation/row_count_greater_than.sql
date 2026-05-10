{% test row_count_greater_than(model, value, where=None) %}

{{ dbt_checks.validate_non_negative_integer(value, 'value') }}

with validation as (
    select
        count(*) as metric_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    metric_value as actual_value,
    {{ value }} as expected_min_value,
    'row_count_greater_than' as failed_check,
    'Row count must be greater than {{ value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    {{ dbt_checks.build_greater_than_predicate('metric_value', value) }}

{% endtest %}