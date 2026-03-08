{% test between_dates(model, column_name, min_date, max_date) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and (
        {{ column_name }} < cast('{{ min_date }}' as date)
        or {{ column_name }} > cast('{{ max_date }}' as date)
    )

{% endtest %}