{% test column_greater_than_column(model, left_column, right_column, where=None) %}

{{ dbt_checks.validate_required_column(left_column, 'left_column') }}
{{ dbt_checks.validate_required_column(right_column, 'right_column') }}

select
    {{ left_column }} as left_value,
    {{ right_column }} as right_value,
    {{ dbt_checks.safe_sql_string_literal(left_column) }} as left_column,
    {{ dbt_checks.safe_sql_string_literal(right_column) }} as right_column,
    'column_greater_than_column' as failed_check,
    'Left column must be greater than right column' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    {{ left_column }} is not null
    and {{ right_column }} is not null
    {{ dbt_checks.apply_and_where(where) }}
    and not (
        {{ dbt_checks.as_numeric(left_column) }} > {{ dbt_checks.as_numeric(right_column) }}
    )

{% endtest %}