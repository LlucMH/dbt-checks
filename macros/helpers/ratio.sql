{% macro calculate_ratio_cte(model, condition, where=None, group_by=None) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

ratio as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        {{ dbt_checks.safe_ratio(
            "sum(case when " ~ condition ~ " then 1 else 0 end)",
            "count(*)"
        ) }} as metric_ratio

    from {{ model }}

    {{ dbt_checks.apply_where(where) }}

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_clause(groups) }}
    {%- endif %}

)

{% endmacro %}


ratio as (
    select
        total_rows,
        matching_rows,
        {{ dbt_checks.safe_ratio('matching_rows', 'total_rows') }} as metric_ratio
    from stats
)

{% endmacro %}


{% macro build_ratio_validation_cte(
    model,
    numerator_expression,
    denominator_expression='count(*)',
    group_by=None,
    where=None
) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with validation as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        {{ dbt_checks.safe_ratio(
            numerator_expression,
            denominator_expression
        ) }} as actual_ratio

    from {{ model }}

    {{ dbt_checks.apply_where(where) }}

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_clause(groups) }}
    {%- endif %}

)

{% endmacro %}