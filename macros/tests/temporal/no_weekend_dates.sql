{% test no_weekend_dates(model, column_name) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ dbt_checks.day_of_week_sun0(column_name) }} in (0, 6)

{% endtest %}