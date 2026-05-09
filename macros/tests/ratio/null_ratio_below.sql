{% test null_ratio_below(model, column_name, threshold, where=None) %}

with stats as (
    select
        count(*) as total_rows,
        sum(
            case
                when {{ column_name }} is null then 1
                else 0
            end
        ) as null_rows
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else null_rows * 1.0 / total_rows
        end as metric_ratio
    from stats
)

select
    metric_ratio as actual_ratio,
    {{ threshold }} as expected_max_ratio,
    'null_ratio_below' as failed_check,
    'Null ratio must be below {{ threshold }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from ratio
where
    metric_ratio > {{ threshold }}

{% endtest %}