{% test between_dates(model, column_name, min_date, max_date, where=None) %}

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
    cast('{{ max_date }}' as date) as expected_max_date,
    'between_dates' as failed_check,
    'Date must be between {{ min_date }} and {{ max_date }}' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and (
        check_value < cast('{{ min_date }}' as date)
        or check_value > cast('{{ max_date }}' as date)
    )

{% endtest %}