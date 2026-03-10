{% test recent_date(model, column_name, max_age_days) %}

select *
from {{ model }}
where
    {{ column_name }} is not null
    and {{ column_name }} < current_date - {{ max_age_days }}

{% endtest %}