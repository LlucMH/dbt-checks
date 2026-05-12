{% test row_count_between(model, min_value, max_value, group_by=None, where=None) %}

{{ dbt_checks.validate_non_negative_integer(min_value, 'min_value') }}
{{ dbt_checks.validate_non_negative_integer(max_value, 'max_value') }}
{{ dbt_checks.validate_min_max(min_value, max_value) }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with validation as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        count(*) as metric_value

    from {{ model }}

    {{ dbt_checks.apply_where(where) }}

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_clause(groups) }}
    {%- endif %}

)

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

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