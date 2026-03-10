{% macro calculate_ratio_cte(model, match_condition) %}
stats as (
    select
        count(*) as total_rows,
        sum(case when {{ match_condition }} then 1 else 0 end) as matching_rows
    from {{ model }}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else matching_rows * 1.0 / total_rows
        end as metric_ratio
    from stats
)
{% endmacro %}