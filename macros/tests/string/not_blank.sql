{% test not_blank(model, column_name, where=None) %}

with base as (
    select
        {{ dbt_checks.as_string(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    trim(check_value) as trimmed_value,
    'not_blank' as failed_check,
    'Value must not be blank or whitespace only' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_not_blank_predicate('check_value') }}

{% endtest %}