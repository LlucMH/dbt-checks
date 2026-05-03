{% test matches_regex(model, column_name, pattern) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
)

select *
from base
where
    value is not null
    and not {{ dbt_checks.regex_match(column_name, pattern) }}

{% endtest %}