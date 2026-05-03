{% test greater_or_equal_than(model, column_name, value) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} < {{ value }}

{% endtest %}