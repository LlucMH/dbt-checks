{% test length_between(model, column_name, min_length, max_length) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and (
        length(value) < {{ min_length }}
        or length(value) > {{ max_length }}
    )

{% endtest %}