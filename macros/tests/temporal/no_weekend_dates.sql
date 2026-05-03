{% test no_weekend_dates(model, column_name) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and {{ dbt_checks.day_of_week_sun0(column_name) }} in (0, 6)

{% endtest %}