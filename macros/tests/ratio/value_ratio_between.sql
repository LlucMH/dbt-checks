{% test value_ratio_between(model, column_name, value, min_ratio, max_ratio) %}

with stats as (
    select
        count(*) as total_rows,
        sum(case when {{ column_name }} = '{{ value }}' then 1 else 0 end) as value_rows
    from {{ model }}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else value_rows * 1.0 / total_rows
        end as value_ratio
    from stats
)

select *
from ratio
where value_ratio < {{ min_ratio }}
   or value_ratio > {{ max_ratio }}

{% endtest %}