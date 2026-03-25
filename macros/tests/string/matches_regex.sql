{% test matches_regex(model, column_name, pattern) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and not {{ dbt_checks.regex_match(column_name, pattern) }}

{% endtest %}