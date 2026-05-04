{% test null_ratio_between(model, column_name, min_ratio, max_ratio) %}

with stats as (
    select
        count(*) as total_rows,
        sum(case when {{ column_name }} is null then 1 else 0 end) as null_rows
    from {{ model }}
),

ratio as (
    select
        case
            when total_rows = 0 then 0
            else null_rows * 1.0 / total_rows
        end as null_ratio
    from stats
)

select *
from ratio
where null_ratio < {{ min_ratio }}
   or null_ratio > {{ max_ratio }}

{% endtest %}