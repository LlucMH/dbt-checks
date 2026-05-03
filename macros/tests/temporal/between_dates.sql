{% test between_dates(model, column_name, min_date, max_date) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and (
        value < cast('{{ min_date }}' as date)
        or value > cast('{{ max_date }}' as date)
    )

{% endtest %}