{% test expression_is_true(model, expression, where=None) %}

{{ dbt_checks.validate_required_string(expression, 'expression') }}

select
    *,
    'expression_is_true' as failed_check,
    'Expression must evaluate to true' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    not (
        {{ expression }}
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}