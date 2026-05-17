{% test require_when(model, when, require, where=None) %}

{{ dbt_checks.validate_required_string(when, 'when') }}
{{ dbt_checks.validate_required_string(require, 'require') }}

select
    *,
    {{ dbt_checks.safe_sql_string_literal(when) }} as trigger_condition,
    {{ dbt_checks.safe_sql_string_literal(require) }} as required_condition,
    'require_when' as failed_check,
    'Requirement condition must be true when trigger condition is met' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    (
        {{ when }}
    )
    and not (
        {{ require }}
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}