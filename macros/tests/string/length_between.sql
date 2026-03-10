{% test length_between(model, column_name, min_length, max_length) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and (
        length({{ column_name }}) < {{ min_length }}
        or length({{ column_name }}) > {{ max_length }}
    )

{% endtest %}