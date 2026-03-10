{% test less_than(model, column_name, max_value) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} >= {{ max_value }}

{% endtest %}