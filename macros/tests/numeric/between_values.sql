{% test between_values(model, column_name, min_value, max_value, inclusive=true, where=None) %}

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
    and (
        {% if inclusive %}
            value < {{ min_value }}
            or value > {{ max_value }}
        {% else %}
            value <= {{ min_value }}
            or value >= {{ max_value }}
        {% endif %}
    )

{% endtest %}