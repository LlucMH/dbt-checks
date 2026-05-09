{% test negative_ratio_between(model, column_name, min_ratio, max_ratio, where=None) %}

with stats as (
    select
        count(*) as total_rows,
        sum(
            case
                when cast({{ column_name }} as numeric) < 0 then 1
                else 0
            end
        ) as negative_rows
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else negative_rows * 1.0 / total_rows
        end as metric_ratio
    from stats
)

select
    metric_ratio as actual_ratio,
    {{ min_ratio }} as expected_min_ratio,
    {{ max_ratio }} as expected_max_ratio,
    'negative_ratio_between' as failed_check,
    'Negative ratio must be between {{ min_ratio }} and {{ max_ratio }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from ratio
where
    metric_ratio < {{ min_ratio }}
    or metric_ratio > {{ max_ratio }}

{% endtest %}