{% test not_before_date(model, column_name, min_date, where=None) %}

{{ dbt_checks.validate_required_date(min_date, 'min_date') }}

with base as (
    select
        {{ dbt_checks.as_date(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ dbt_checks.cast_to_date(min_date) }} as expected_min_date,
    'not_before_date' as failed_check,
    {{ dbt.string_literal(
        "Date must not be before "
        ~ dbt_checks.escape_sql_string(min_date)
    ) }} as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_not_before_date_predicate(
        'check_value',
        min_date
    ) }}

{% endtest %}