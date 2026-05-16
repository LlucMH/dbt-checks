{% test require_not_null_when(model, when, column_name, where=None) %}

{{ dbt_checks.validate_required_string(when, 'when') }}
{{ dbt_checks.validate_required_column(column_name, 'column_name') }}

select
    *,
    {{ dbt.string_literal(when) }} as trigger_condition,
    {{ dbt.string_literal(column_name) }} as required_column,
    'require_not_null_when' as failed_check,
    'Column must not be null when condition is met' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    (
        {{ when }}
    )
    and {{ column_name }} is null
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}