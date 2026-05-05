{% test date_diff_less_than(model, start_column, end_column, max_days, where=None) %}

with base as (
    select
        cast({{ start_column }} as date) as start_date,
        cast({{ end_column }} as date) as end_date
    from {{ model }}
    {% if where is not none %}
        where {{ where }}
    {% endif %}
)

select *
from base
where
    start_date is not null
    and end_date is not null
    and {{ dbt_checks.datediff_days('start_date', 'end_date') }} > {{ max_days }}

{% endtest %}