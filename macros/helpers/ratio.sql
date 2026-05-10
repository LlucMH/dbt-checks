{% macro calculate_ratio_cte(model, match_condition, where=None) %}

stats as (
    select
        count(*) as total_rows,
        sum(
            case
                when {{ match_condition }} then 1
                else 0
            end
        ) as matching_rows
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
),

ratio as (
    select
        total_rows,
        matching_rows,
        {{ dbt_checks.safe_ratio('matching_rows', 'total_rows') }} as metric_ratio
    from stats
)

{% endmacro %}