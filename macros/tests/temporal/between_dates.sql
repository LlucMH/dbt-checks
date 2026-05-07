{% test between_dates(model, column_name, min_date, max_date, where=None) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from base
where
    value is not null
    and (
        value < cast('{{ min_date }}' as date)
        or value > cast('{{ max_date }}' as date)
    )

{% endtest %}