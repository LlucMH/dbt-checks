{% test max_between(model, column_name, min_value, max_value, where=None) %}

with validation as (
    select max(cast({{ column_name }} as numeric)) as metric_value
    from {{ model }}
    where {{ column_name }} is not null
    {% if where is not none %}
        and {{ where }}
    {% endif %}
)

select *
from validation
where metric_value is null
   or metric_value < {{ min_value }}
   or metric_value > {{ max_value }}

{% endtest %}