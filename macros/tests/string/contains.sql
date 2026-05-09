{% test contains(model, column_name, substring, where=None) %}

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
    '{{ substring }}' as expected_substring,
    'contains' as failed_check,
    'Value must contain substring "{{ substring }}"' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value not like '%{{ substring }}%'

{% endtest %}