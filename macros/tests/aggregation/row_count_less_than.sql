{% test row_count_less_than(model, value, where=None) %}

with validation as (
    select count(*) as row_count
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from validation
where row_count >= {{ value }}

{% endtest %}