{% test row_count_less_than(model, value, where=None) %}

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
    {{ value }} as expected_max_value,
    'row_count_less_than' as failed_check,
    'Row count must be less than {{ value }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    metric_value >= {{ value }}

{% endtest %}