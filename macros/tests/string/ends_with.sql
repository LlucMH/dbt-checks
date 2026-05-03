{% test ends_with(model, column_name, suffix) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value not like '%{{ suffix }}'

{% endtest %}