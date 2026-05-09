{% test no_weekend_dates(model, column_name, where=None) %}

with base as (
    select
        cast({{ column_name }} as date) as check_value
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
),

validation as (
    select
        check_value,
        {{ dbt_checks.day_of_week_sun0("check_value") }} as day_of_week
    from base
)

select
    check_value as failing_value,
    day_of_week as actual_day_of_week,
    'weekday only' as expected_date_type,
    'no_weekend_dates' as failed_check,
    'Date must not fall on a weekend' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    check_value is not null
    and day_of_week in (0, 6)

{% endtest %}