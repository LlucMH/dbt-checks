{% test row_count_less_than(model, value) %}

with validation as (
    select count(*) as row_count
    from {{ model }}
)

select *
from validation
where row_count >= {{ value }}

{% endtest %}