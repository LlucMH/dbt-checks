{% test contains(model, column_name, substring) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} not like '%{{ substring }}%'

{% endtest %}