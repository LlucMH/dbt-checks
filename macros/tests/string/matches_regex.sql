{% test matches_regex(model, column_name, pattern, where=None) %}

with base as (
    select
        cast({{ column_name }} as varchar) as check_value
    from {{ model }}
    {% if where %}
        where {{ where }}
    {% endif %}
)

select
    check_value as failing_value,
    '{{ pattern }}' as expected_pattern,
    'matches_regex' as failed_check,
    'Value must match regex pattern "{{ pattern }}"' as failure_reason,
    '{{ where if where is not none else "none" }}' as applied_condition
from base
where
    check_value is not null
    and not {{ dbt_checks.regex_match('check_value', pattern) }}

{% endtest %}