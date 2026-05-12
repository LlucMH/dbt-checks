{% test value_ratio_between(model, column_name, value, min_ratio, max_ratio, group_by=None, where=None) %}

{{ dbt_checks.validate_ratio_bounds(min_ratio, max_ratio) }}
{{ dbt_checks.validate_required_string(value, 'value') }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with
{{ dbt_checks.calculate_ratio_cte(
    model,
    dbt_checks.as_string(column_name) ~ " = '" ~ value ~ "'",
    where,
    group_by
) }}

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

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