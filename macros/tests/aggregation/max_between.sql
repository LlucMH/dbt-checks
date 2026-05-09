{% test max_between(model, column_name, min_value, max_value, where=None) %}

with validation as (
    select
        max(cast({{ column_name }} as numeric)) as metric_value
    from {{ model }}
    where {{ column_name }} is not null
    {% if where is not none %}
        and {{ where }}
    {% endif %}
)

select
    metric_value as actual_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'max_between' as failed_check,
    'Maximum value must be between {{ min_value }} and {{ max_value }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    metric_value is null
    or metric_value < {{ min_value }}
    or metric_value > {{ max_value }}

{% endtest %}