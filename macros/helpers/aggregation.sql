{% macro distinct_count_expression(column_name) %}
count(distinct {{ column_name }})
{% endmacro %}


{% macro render_aggregation_metric(aggregation, column_name=None) %}

    {% set supported = ['count', 'count_distinct', 'sum', 'avg', 'min', 'max'] %}

    {% if aggregation not in supported %}
        {{ exceptions.raise_compiler_error(
            "Unsupported aggregation: " ~ aggregation
        ) }}
    {% endif %}

    {% if aggregation == 'count' %}
        count(*) as metric_value

    {% elif aggregation == 'count_distinct' %}
        {{ dbt_checks.distinct_count_expression(column_name) }} as metric_value

    {% elif aggregation == 'sum' %}
        sum({{ dbt_checks.as_numeric(column_name) }}) as metric_value

    {% elif aggregation == 'avg' %}
        avg({{ dbt_checks.as_numeric(column_name) }}) as metric_value

    {% elif aggregation == 'min' %}
        min({{ dbt_checks.as_numeric(column_name) }}) as metric_value

    {% elif aggregation == 'max' %}
        max({{ dbt_checks.as_numeric(column_name) }}) as metric_value

    {% endif %}

{% endmacro %}


{% macro build_aggregation_validation_cte(
    model,
    aggregation,
    column_name=None,
    group_by=None,
    where=None
) %}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

with validation as (

    select

        {%- if groups | length > 0 %}
            {{ dbt_checks.render_group_by_select(groups) }},
        {%- endif %}

        {{
            dbt_checks.render_aggregation_metric(
                aggregation,
                column_name
            )
        }}

    from {{ model }}

    {% if aggregation in ['count', 'count_distinct'] %}
        {{ dbt_checks.apply_where(where) }}
    {% else %}
        where {{ column_name }} is not null
        {{ dbt_checks.apply_and_where(where) }}
    {% endif %}

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_clause(groups) }}
    {%- endif %}

)

{% endmacro %}