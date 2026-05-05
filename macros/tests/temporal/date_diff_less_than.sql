{% test date_diff_less_than(model, start_column, end_column, max_days, where=None) %}

with base as (
    select
        cast({{ start_column }} as date) as start_date,
        cast({{ end_column }} as date) as end_date
    from {{ model }}
    {% if where %}
    where {{ where }}
    {% endif %}
),

validation as (
    select
        start_date,
        end_date,
        {{ dbt_checks.datediff_days('start_date', 'end_date') }} as diff_days
    from base
)

select *
from validation
where
    start_date is not null
    and end_date is not null
    and diff_days > {{ max_days }}

{% endtest %}