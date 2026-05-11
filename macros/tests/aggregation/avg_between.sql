{% test avg_between(
    model,
    column_name,
    min_value,
    max_value,
    group_by=None,
    where=None
) %}

{{ dbt_checks.validate_min_max(min_value, max_value) }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

{{
    dbt_checks.build_grouped_aggregation_cte(
        model=model,
        aggregation='avg',
        column_name=column_name,
        group_by=group_by,
        where=where
    )
}}

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

    metric_value as actual_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'avg_between' as failed_check,
    'Average value must be within range' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from validation

where
    {{ dbt_checks.build_between_predicate(
        'metric_value',
        min_value,
        max_value,
        true
    ) }}

{% endtest %}