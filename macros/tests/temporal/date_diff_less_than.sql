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

select *
from validation
where
    check_start_date is not null
    and check_end_date is not null
    and diff_days > {{ max_days }}

{% endtest %}