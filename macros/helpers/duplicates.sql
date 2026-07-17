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

        {{ dbt_checks.render_column_list(columns) }},

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

),

key_frequency as (

    {#-
        One row per distinct evaluated key (group_by expressions + composite-key
        expressions), reusing the key_occurrences already computed by the single
        window-function pass above instead of recalculating occurrence counts.
    -#}
    select distinct * from keyed

),

key_frequency_summary as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_output(groups) }},
        {%- endif %}

        coalesce(sum(case when key_occurrences > 1 then 1 else 0 end), 0) as duplicate_group_count,
        coalesce(max(case when key_occurrences > 1 then key_occurrences else 0 end), 0) as max_duplicate_group_size

    from key_frequency

    {%- if groups | length > 0 %}
        group by {{ dbt_checks.render_group_by_output(groups) }}
    {%- endif %}

),

severity as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_output(groups) }},
        {%- endif %}

        validation.evaluated_row_count,
        validation.unique_row_count,
        validation.duplicate_row_count,
        key_frequency_summary.duplicate_group_count,
        key_frequency_summary.max_duplicate_group_size

    from validation

    {%- if groups | length > 0 %}
    inner join key_frequency_summary using ({{ dbt_checks.render_group_by_output(groups) }})
    {%- else %}
    cross join key_frequency_summary
    {%- endif %}

)

{% endmacro %}
