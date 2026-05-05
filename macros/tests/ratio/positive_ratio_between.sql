{% test positive_ratio_between(model, column_name, min_ratio, max_ratio, where=None) %}

with stats as (
    select
        count(*) as total_rows,
        sum(case when cast({{ column_name }} as numeric) > 0 then 1 else 0 end) as positive_rows
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
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