{% test row_count_between(model, min_value, max_value, where=None) %}

with validation as (
    select
        count(*) as metric_value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select
    metric_value as actual_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    'row_count_between' as failed_check,
    'Row count must be between {{ min_value }} and {{ max_value }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    metric_value < {{ min_value }}
    or metric_value > {{ max_value }}

{% endtest %}