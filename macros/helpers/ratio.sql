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


{% macro calculate_unique_combination_ratio_cte(model, columns, where=None, group_by=None) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

{{
    dbt_checks.build_composite_key_validation_cte(
        model=model,
        columns=columns,
        group_by=group_by,
        where=where
    )
}},

ratio as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_output(groups) }},
        {%- endif %}

        evaluated_row_count,
        unique_row_count,
        {{ dbt_checks.safe_ratio('unique_row_count', 'evaluated_row_count') }} as metric_ratio

    from validation

)

{% endmacro %}


{% macro calculate_distinct_ratio_cte(model, column_name, where=None, group_by=None) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

ratio as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        {{ dbt_checks.safe_ratio(
            dbt_checks.distinct_count_expression(column_name),
            "count(" ~ column_name ~ ")"
        ) }} as metric_ratio

    from {{ model }}

    {{ dbt_checks.apply_where(where) }}

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_clause(groups) }}
    {%- endif %}

)

{% endmacro %}