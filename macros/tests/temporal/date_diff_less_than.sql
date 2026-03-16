{% test date_diff_less_than(model, start_column, end_column, max_days) %}

select *
from {{ model }}
where
    {{ start_column }} is not null
    and {{ end_column }} is not null
    and datediff('day', {{ start_column }}, {{ end_column }}) > {{ max_days }}

{% endtest %}