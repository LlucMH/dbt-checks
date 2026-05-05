{% test contains(model, column_name, substring, where=None) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from base
where
    value is not null
    and value not like '%{{ substring }}%'

{% endtest %}