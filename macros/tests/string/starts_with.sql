{% test starts_with(model, column_name, prefix, where=None) %}

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
    and value not like '{{ prefix }}%'

{% endtest %}