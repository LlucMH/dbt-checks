{% test row_count_between(model, min_value, max_value) %}

with validation as (
    select count(*) as row_count
    from {{ model }}
)

select *
from validation
where row_count < {{ min_value }}
   or row_count > {{ max_value }}

{% endtest %}