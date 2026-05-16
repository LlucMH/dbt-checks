{% test require_value_when(model, when, column_name, value, where=None) %}

{{ dbt_checks.validate_required_string(when, 'when') }}
{{ dbt_checks.validate_required_column(column_name, 'column_name') }}
{{ dbt_checks.validate_required_string(value, 'value') }}

select
    *,
    'require_value_when' as failed_check,
    'Column must contain required value when condition is met' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    (
        {{ when }}
    )
    and not (
        {{ dbt_checks.as_string(column_name) }} = '{{ value }}'
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}