{% test length_between(model, column_name, min_length, max_length, where=None) %}

with base as (
    select
        cast({{ column_name }} as varchar) as check_value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select
    check_value as failing_value,
    length(check_value) as actual_length,
    {{ min_length }} as expected_min_length,
    {{ max_length }} as expected_max_length,
    'length_between' as failed_check,
    'Value length must be between {{ min_length }} and {{ max_length }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and (
        length(check_value) < {{ min_length }}
        or length(check_value) > {{ max_length }}
    )

{% endtest %}