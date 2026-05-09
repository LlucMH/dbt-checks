{% test not_blank(model, column_name, where=None) %}

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
    trim(check_value) as trimmed_value,
    'not_blank' as failed_check,
    'Value must not be blank or whitespace only' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and trim(check_value) = ''

{% endtest %}