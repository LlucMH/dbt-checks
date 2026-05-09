{% test greater_or_equal_than(model, column_name, value, where=None) %}

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
    {{ value }} as expected_min_value,
    'greater_or_equal_than' as failed_check,
    'Value must be greater than or equal to {{ value }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value < {{ value }}

{% endtest %}