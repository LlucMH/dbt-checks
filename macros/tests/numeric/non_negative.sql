{% test non_negative(model, column_name) %}

with base as (
    select cast({{ column_name }} as numeric) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value < 0

{% endtest %}