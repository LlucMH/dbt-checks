{% test date_diff_less_than(model, start_column, end_column, max_days, where=None) %}

with base as (
    select
        cast({{ start_column }} as date) as check_start_date,
        cast({{ end_column }} as date) as check_end_date
    from {{ model }}
    {% if where %}
        where {{ where }}
    {% endif %}
),

validation as (
    select
        check_start_date,
        check_end_date,
        {{ dbt_checks.datediff_days('check_start_date', 'check_end_date') }} as diff_days
    from base
)

select
    check_start_date as failing_start_date,
    check_end_date as failing_end_date,
    diff_days as actual_diff_days,
    {{ max_days }} as expected_max_days,
    'date_diff_less_than' as failed_check,
    'Date difference must be less than {{ max_days }} days' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from validation
where
    check_start_date is not null
    and check_end_date is not null
    and diff_days > {{ max_days }}

{% endtest %}