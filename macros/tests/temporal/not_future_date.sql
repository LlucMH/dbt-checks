{% test not_future_date(model, column_name) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value > {{ dbt_checks.current_date_sql() }}

{% endtest %}