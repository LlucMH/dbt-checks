{% test recent_date(model, column_name, max_age_days) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} < {{ dbt_checks.dateadd_days(dbt_checks.current_date_sql(), -1 * max_age_days) }}

{% endtest %}