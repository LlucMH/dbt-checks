{% test recent_date(model, column_name, max_age_days, where=None) %}

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
        {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), -1 * max_age_days) }} as expected_min_date
    from base
)

select
    check_value as failing_value,
    expected_min_date,
    {{ max_age_days }} as expected_max_age_days,
    'recent_date' as failed_check,
    'Date must be within the last {{ max_age_days }} days' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    check_value is not null
    and check_value < expected_min_date

{% endtest %}