{% test starts_with(model, column_name, prefix, where=None) %}

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
    '{{ prefix }}' as expected_prefix,
    'starts_with' as failed_check,
    'Value must start with "{{ prefix }}"' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value not like '{{ prefix }}%'

{% endtest %}