{% test not_before_date(model, column_name, min_date) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} < cast('{{ min_date }}' as date)

{% endtest %}