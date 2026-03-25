{% test not_future_date(model, column_name) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} > {{ dbt_checks.current_date_sql() }}

{% endtest %}