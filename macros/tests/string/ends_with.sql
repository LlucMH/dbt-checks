{% test ends_with(model, column_name, suffix, where=None) %}

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
    '{{ suffix }}' as expected_suffix,
    'ends_with' as failed_check,
    'Value must end with "{{ suffix }}"' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value not like '%{{ suffix }}'

{% endtest %}