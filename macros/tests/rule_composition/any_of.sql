{% test any_of(model, expressions, where=None) %}

{{ dbt_checks.validate_expression_list(expressions) }}

select
    *,
    {{ dbt.string_literal(expressions | join(' or ')) }} as failed_expression,
    'any_of' as failed_rule_type,
    'any_of' as failed_check,
    'At least one expression must evaluate to true' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    not (
        {{ expressions | join(' or ') }}
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}