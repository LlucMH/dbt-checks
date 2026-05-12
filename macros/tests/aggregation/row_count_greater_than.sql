{% test row_count_greater_than(model, value, group_by=None, where=None) %}

{{ dbt_checks.validate_non_negative_integer(value, 'value') }}
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
    {{ value }} as expected_min_value,
    'row_count_greater_than' as failed_check,
    'Row count must be greater than {{ value }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from validation

where
    {{ dbt_checks.build_greater_than_predicate('metric_value', value) }}

{% endtest %}