{% test contains(model, column_name, substring) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value not like '%{{ substring }}%'

{% endtest %}