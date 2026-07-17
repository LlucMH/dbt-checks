{% macro render_column_list(columns) %}
    {{ return(columns | join(', ')) }}
{% endmacro %}


{% macro build_composite_key_not_null_filter(columns) %}

    {%- for column in columns -%}
        {{ column }} is not null
        {%- if not loop.last %} and {% endif -%}
    {%- endfor -%}

{% endmacro %}


{% macro build_composite_key_validation_cte(model, columns, group_by=None, where=None) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with keyed as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        count(*) over (
            partition by
            {%- if groups | length > 0 %}
                {{ dbt_checks.render_group_by_list(groups) }},
            {%- endif %}
            {{ dbt_checks.render_column_list(columns) }}
        ) as key_occurrences

    from {{ model }}

    where {{ dbt_checks.build_composite_key_not_null_filter(columns) }}
    {{ dbt_checks.apply_and_where(where) }}

),

validation as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_output(groups) }},
        {%- endif %}

        count(*) as evaluated_row_count,
        coalesce(sum(case when key_occurrences = 1 then 1 else 0 end), 0) as unique_row_count,
        count(*) - coalesce(sum(case when key_occurrences = 1 then 1 else 0 end), 0) as duplicate_row_count

    from keyed

    {%- if groups | length > 0 %}
        group by {{ dbt_checks.render_group_by_output(groups) }}
    {%- endif %}

)

{% endmacro %}
