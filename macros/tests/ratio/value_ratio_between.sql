{% test value_ratio_between(model, column_name, value, min_ratio, max_ratio, where=None) %}

with
{{ dbt_checks.calculate_ratio_cte(
    model,
    dbt_checks.as_string(column_name) ~ " = '" ~ value ~ "'",
    where
) }}

select
    metric_ratio as actual_ratio,
    {{ min_ratio }} as expected_min_ratio,
    {{ max_ratio }} as expected_max_ratio,
    '{{ value }}' as expected_value,
    'value_ratio_between' as failed_check,
    'Value ratio for {{ value }} must be between {{ min_ratio }} and {{ max_ratio }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from ratio
where
    {{ dbt_checks.build_between_predicate(
        'metric_ratio',
        min_ratio,
        max_ratio
    ) }}

{% endtest %}