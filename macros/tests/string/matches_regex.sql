{% test matches_regex(model, column_name, pattern, where=None) %}

with base as (
    select cast({{ column_name }} as varchar) as value
    from {{ model }}
    {% if where %}
    where {{ where }}
    {% endif %}
)

select *
from base
where
    value is not null
    and not {{ dbt_checks.regex_match('value', pattern) }}

{% endtest %}