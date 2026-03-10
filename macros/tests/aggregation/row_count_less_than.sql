{% test row_count_less_than(model, max_value) %}

with validation as (
    select count(*) as row_count
    from {{ model }}
)

select *
from validation
where row_count >= {{ max_value }}

{% endtest %}