{% test matches_regex(model, column_name, pattern) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and not ({{ column_name }} ~ '{{ pattern }}')

{% endtest %}