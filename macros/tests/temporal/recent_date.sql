{% test recent_date(model, column_name, max_age_days) %}

with base as (
    select cast({{ column_name }} as date) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and value < {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), -1 * max_age_days) }}

{% endtest %}