{% test row_count_between(model, min_value, max_value, where=None) %}

with validation as (
    select count(*) as row_count
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from validation
where row_count < {{ min_value }}
   or row_count > {{ max_value }}

{% endtest %}