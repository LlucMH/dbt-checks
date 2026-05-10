{% test min_between(model, column_name, min_value, max_value, where=None) %}

{{ dbt_checks.validate_min_max(min_value, max_value) }}

with validation as (
    select
        min({{ dbt_checks.as_numeric(column_name) }}) as metric_value
    from {{ model }}
    where {{ column_name }} is not null
    {{ dbt_checks.apply_and_where(where) }}
)

select
    metric_value as actual_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'min_between' as failed_check,
    'Minimum value must be between {{ min_value }} and {{ max_value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from validation
where
    metric_value is null
    or {{ dbt_checks.build_between_predicate('metric_value', min_value, max_value) }}

{% endtest %}