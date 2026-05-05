{% test non_negative(model, column_name, where=None) %}

with base as (
    select cast({{ column_name }} as numeric) as value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from base
where
    value is not null
    and value < 0

{% endtest %}