{% test no_weekend_dates(model, column_name, where=None) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from base
where
    value is not null
    and {{ dbt_checks.day_of_week_sun0("value") }} in (0, 6)

{% endtest %}