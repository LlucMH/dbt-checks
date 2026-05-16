{% test require_when(model, when, require, where=None) %}

{{ dbt_checks.validate_required_string(when, 'when') }}
{{ dbt_checks.validate_required_string(require, 'require') }}

select
    *,
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