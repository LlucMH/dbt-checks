{% test between_values(model, column_name, min_value, max_value, inclusive=true, where=None) %}

with base as (
    select
        cast({{ column_name }} as numeric) as check_value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select
    check_value as failing_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    {{ inclusive }} as inclusive,
    'between_values' as failed_check,

    {% if inclusive %}
        'Value must be between {{ min_value }} and {{ max_value }} inclusive' as failure_reason
    {% else %}
        'Value must be strictly between {{ min_value }} and {{ max_value }}' as failure_reason
    {% endif %},

    '{{ where if where is not none else "none" }}' as applied_condition

from base
where
    check_value is not null
    and (
        {% if inclusive %}
            check_value < {{ min_value }}
            or check_value > {{ max_value }}
        {% else %}
            check_value <= {{ min_value }}
            or check_value >= {{ max_value }}
        {% endif %}
    )

{% endtest %}