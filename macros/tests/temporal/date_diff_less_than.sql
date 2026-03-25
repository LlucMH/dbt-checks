{% test date_diff_less_than(model, start_column, end_column, max_days) %}

select *
from {{ model }}
where
    {{ start_column }} is not null
    and {{ end_column }} is not null
    and {{ dbt_checks.datediff_days(start_column, end_column) }} > {{ max_days }}

{% endtest %}