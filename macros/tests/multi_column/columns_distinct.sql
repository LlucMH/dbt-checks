{% test columns_distinct(model, left_column, right_column, where=None) %}

{{ dbt_checks.validate_required_column(left_column, 'left_column') }}
{{ dbt_checks.validate_required_column(right_column, 'right_column') }}

select
    {{ left_column }} as left_value,
    {{ right_column }} as right_value,
    {{ dbt_checks.safe_sql_string_literal(left_column) }} as left_column,
    {{ dbt_checks.safe_sql_string_literal(right_column) }} as right_column,
    'columns_distinct' as failed_check,
    'Columns must be different' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    {{ left_column }} is not null
    and {{ right_column }} is not null
    {{ dbt_checks.apply_and_where(where) }}
    and {{ left_column }} = {{ right_column }}

{% endtest %}