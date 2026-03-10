{% test positive_ratio_between(model, column_name, min_ratio, max_ratio) %}

with stats as (
    select
        count(*) as total_rows,
        sum(case when {{ column_name }} > 0 then 1 else 0 end) as positive_rows
    from {{ model }}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else positive_rows * 1.0 / total_rows
        end as positive_ratio
    from stats
)

select *
from ratio
where positive_ratio < {{ min_ratio }}
   or positive_ratio > {{ max_ratio }}

{% endtest %}