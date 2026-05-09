{% test not_before_date(model, column_name, min_date, where=None) %}

with base as (
    select
        cast({{ column_name }} as date) as check_value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select
    check_value as failing_value,
    cast('{{ min_date }}' as date) as expected_min_date,
    'not_before_date' as failed_check,
    'Date must not be before {{ min_date }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value < cast('{{ min_date }}' as date)

{% endtest %}