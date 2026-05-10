{% test between_values(model, column_name, min_value, max_value, inclusive=true, where=None) %}

{{ dbt_checks.validate_min_max(min_value, max_value) }}

with base as (
    select
        {{ dbt_checks.as_numeric(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ min_value }} as expected_min_value,
    {{ max_value }} as expected_max_value,
    {{ inclusive }} as inclusive,
    'between_values' as failed_check,
    {% if inclusive %}
        'Value must be between {{ min_value }} and {{ max_value }} inclusive' as failure_reason
    {% else %}
        'Value must be strictly between {{ min_value }} and {{ max_value }}' as failure_reason
    {% endif %},
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_between_predicate(
        'check_value',
        min_value,
        max_value,
        inclusive
    ) }}

{% endtest %}