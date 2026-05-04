{% test less_or_equal_than(model, column_name, value) %}

with base as (
    select cast({{ column_name }} as numeric) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value > {{ value }}

{% endtest %}