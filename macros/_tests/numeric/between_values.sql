{% test between_values(model, column_name, min_value, max_value, inclusive=true) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and (
        {% if inclusive %}
            {{ column_name }} < {{ min_value }}
            or {{ column_name }} > {{ max_value }}
        {% else %}
            {{ column_name }} <= {{ min_value }}
            or {{ column_name }} >= {{ max_value }}
        {% endif %}
    )

{% endtest %}