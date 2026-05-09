{% test non_negative(model, column_name, where=None) %}

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
    0 as expected_min_value,
    'non_negative' as failed_check,
    'Value must be greater than or equal to 0' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value < 0

{% endtest %}