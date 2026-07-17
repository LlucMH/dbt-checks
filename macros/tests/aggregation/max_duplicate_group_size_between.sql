{% test max_duplicate_group_size_between(model, columns, min_count, max_count, group_by=None, where=None) %}

{{ dbt_checks.validate_expression_list(columns, 'columns') }}
{{ dbt_checks.validate_no_duplicate_columns(columns, 'columns') }}
{{ dbt_checks.validate_non_negative_integer(min_count, 'min_count') }}
{{ dbt_checks.validate_non_negative_integer(max_count, 'max_count') }}
{{ dbt_checks.validate_min_max(min_count, max_count) }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

{{
    dbt_checks.build_composite_key_validation_cte(
        model=model,
        columns=columns,
        group_by=group_by,
        where=where
    )
}}

select

    {%- if groups | length > 0 %}
        {{ dbt_checks.render_group_by_output(groups) }},
    {%- endif %}

    max_duplicate_group_size as actual_max_duplicate_group_size,
    {{ min_count }} as expected_min_count,
    {{ max_count }} as expected_max_count,
    evaluated_row_count,
    unique_row_count,
    duplicate_row_count,
    duplicate_group_count,
    max_duplicate_group_size,
    'max_duplicate_group_size_between' as failed_check,
    'Max duplicate group size for {{ columns | join(", ") }} must be between {{ min_count }} and {{ max_count }}' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from severity

where
    {{ dbt_checks.build_between_predicate('max_duplicate_group_size', min_count, max_count) }}

{% endtest %}
