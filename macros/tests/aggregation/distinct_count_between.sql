{% test distinct_count_between(model, column_name, min_value, max_value, group_by=None, where=None) %}

{{ dbt_checks.validate_required_column(column_name, 'column_name') }}
{{ dbt_checks.validate_non_negative_integer(min_value, 'min_value') }}
{{ dbt_checks.validate_non_negative_integer(max_value, 'max_value') }}
{{ dbt_checks.validate_min_max(min_value, max_value) }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

{{
    dbt_checks.build_aggregation_validation_cte(
        model=model,
        aggregation='count_distinct',
        column_name=column_name,
        group_by=group_by,
        where=where
    )
}}

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

    metric_value as actual_distinct_count,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'distinct_count_between' as failed_check,
    'Distinct count for {{ column_name }} must be between {{ min_value }} and {{ max_value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from validation

where
    {{ dbt_checks.build_between_predicate('metric_value', min_value, max_value) }}

{% endtest %}
