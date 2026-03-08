{% test sum_between(model, column_name, min_value, max_value) %}

with validation as (
    select coalesce(sum({{ column_name }}), 0) as metric_value
    from {{ model }}
)

select *
from validation
where metric_value < {{ min_value }}
   or metric_value > {{ max_value }}

{% endtest %}