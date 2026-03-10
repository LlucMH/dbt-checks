{% test ends_with(model, column_name, suffix) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} not like '%{{ suffix }}'

{% endtest %}