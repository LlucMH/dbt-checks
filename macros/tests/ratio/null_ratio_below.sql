{% test null_ratio_below(model, column_name, threshold, group_by=None, where=None) %}

{{ dbt_checks.validate_ratio(threshold, 'threshold') }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with
{{ dbt_checks.calculate_ratio_cte(
    model,
    column_name ~ " is null",
    where,
    group_by
) }}

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

    metric_ratio as actual_ratio,
    {{ threshold }} as expected_max_ratio,
    'null_ratio_below' as failed_check,
    'Null ratio must be below threshold' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from ratio

where metric_ratio > {{ threshold }}

{% endtest %}