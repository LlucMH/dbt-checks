{% test between_dates(model, column_name, min_date, max_date, where=None) %}

{{ dbt_checks.validate_date_range(min_date, max_date) }}

with base as (
    select
        {{ dbt_checks.as_date(column_name) }} as check_value
    from {{ model }}
    {{ dbt_checks.apply_where(where) }}
)

select
    check_value as failing_value,
    {{ dbt_checks.cast_to_date(min_date) }} as expected_min_date,
    {{ dbt_checks.cast_to_date(max_date) }} as expected_max_date,
    'between_dates' as failed_check,
    {{ dbt_checks.safe_sql_string_literal(
        "Date must be between " ~ min_date ~ " and " ~ max_date
    ) }} as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition
from base
where
    check_value is not null
    and {{ dbt_checks.build_date_between_predicate(
        'check_value',
        min_date,
        max_date
    ) }}

{% endtest %}