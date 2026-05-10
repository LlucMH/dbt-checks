{% test null_ratio_below(model, column_name, threshold, where=None) %}

with
{{ dbt_checks.calculate_ratio_cte(
    model,
    column_name ~ " is null",
    where
) }}

select
    metric_ratio as actual_ratio,
    {{ threshold }} as expected_max_ratio,
    'null_ratio_below' as failed_check,
    'Null ratio must be below {{ threshold }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from ratio
where
    {{ dbt_checks.build_less_than_predicate(
        'metric_ratio',
        threshold,
        true
    ) }}

{% endtest %}