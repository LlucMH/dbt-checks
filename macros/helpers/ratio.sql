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