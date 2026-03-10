{% test no_weekend_dates(model, column_name) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and extract(dow from {{ column_name }}) in (0, 6)

{% endtest %}