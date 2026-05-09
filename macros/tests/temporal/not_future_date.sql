{% test not_future_date(model, column_name, where=None) %}

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
    {{ dbt_checks.current_date_sql() }} as expected_max_date,
    'not_future_date' as failed_check,
    'Date must not be in the future' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and check_value > {{ dbt_checks.current_date_sql() }}

{% endtest %}