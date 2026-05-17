{% test require_value_when(model, when, column_name, value, where=None) %}

{{ dbt_checks.validate_required_string(when, 'when') }}
{{ dbt_checks.validate_required_column(column_name, 'column_name') }}
{{ dbt_checks.validate_required_string(value, 'value') }}

select
    *,
    {{ dbt_checks.safe_sql_string_literal(when) }} as trigger_condition,
    {{ dbt_checks.safe_sql_string_literal(column_name) }} as required_column,
    {{ dbt_checks.safe_sql_string_literal(value) }} as required_value,
    'require_value_when' as failed_check,
    'Column must contain required value when condition is met' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    (
        {{ when }}
    )
    and not (
        {{ dbt_checks.as_string(column_name) }} = {{ dbt_checks.safe_sql_string_literal(value) }}
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}