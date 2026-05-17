{% test all_of(model, expressions, where=None) %}

{{ dbt_checks.validate_expression_list(expressions) }}

select
    *,
    {{ dbt_checks.safe_sql_string_literal(expressions | join(' and ')) }} as failed_expression,
    'all_of' as failed_rule_type,
    'all_of' as failed_check,
    'All expressions must evaluate to true' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    not (
        {{ expressions | join(' and ') }}
    )
    {{ dbt_checks.apply_and_where(where) }}

{% endtest %}