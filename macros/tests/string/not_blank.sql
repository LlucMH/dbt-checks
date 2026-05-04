{% test not_blank(model, column_name) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and trim(value) = ''

{% endtest %}