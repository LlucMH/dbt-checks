{% test starts_with(model, column_name, prefix) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} not like '{{ prefix }}%'

{% endtest %}