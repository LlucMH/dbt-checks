{% test max_between(model, column_name, min_value, max_value) %}

with validation as (
    select max({{ column_name }}) as metric_value
    from {{ model }}
    where {{ column_name }} is not null
)

select *
from validation
where metric_value < {{ min_value }}
   or metric_value > {{ max_value }}

{% endtest %}