{% test not_blank(model, column_name) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and trim({{ column_name }}) = ''

{% endtest %}