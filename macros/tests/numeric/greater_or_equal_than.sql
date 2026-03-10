{% test greater_or_equal_than(model, column_name, min_value) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} < {{ min_value }}

{% endtest %}