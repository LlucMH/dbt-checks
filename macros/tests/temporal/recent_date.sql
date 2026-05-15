{% test recent_date(model, column_name, max_age_days, group_by=None, where=None) %}

{{ dbt_checks.validate_non_negative_integer(max_age_days, 'max_age_days') }}
{{ dbt_checks.validate_group_by(group_by) }}

{%- set groups = dbt_checks.normalize_group_by(group_by) -%}

{% if groups | length == 0 %}

select
    {{ dbt_checks.as_date(column_name) }} as failing_value,
    {{ dbt_checks.datediff_days(
        dbt_checks.as_date(column_name),
        dbt_checks.current_date_sql()
    ) }} as actual_age_days,
    {{ max_age_days }} as expected_max_age_days,
    'recent_date' as failed_check,
    'Date must be within {{ max_age_days }} days' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from {{ model }}

where
    {{ column_name }} is not null
    {{ dbt_checks.apply_and_where(where) }}
    and {{ dbt_checks.datediff_days(
        dbt_checks.as_date(column_name),
        dbt_checks.current_date_sql()
    ) }} > {{ max_age_days }}

{% else %}

with validation as (

    select
        {{ dbt_checks.render_group_by_select(groups) }},
        max({{ dbt_checks.as_date(column_name) }}) as latest_date

    from {{ model }}

    where {{ column_name }} is not null
    {{ dbt_checks.apply_and_where(where) }}

    {{ dbt_checks.render_group_by_clause(groups) }}

),

checks as (

    select
        {{ dbt_checks.render_group_by_output(groups) }},
        latest_date,
        {{ dbt_checks.datediff_days(
            'latest_date',
            dbt_checks.current_date_sql()
        ) }} as actual_age_days

    from validation

)

select
    {{ dbt_checks.render_group_by_output(groups) }},
    latest_date as failing_value,
    actual_age_days,
    {{ max_age_days }} as expected_max_age_days,
    'recent_date' as failed_check,
    'Latest date must be within {{ max_age_days }} days' as failure_reason,
    {{ dbt_checks.applied_condition(where) }} as applied_condition

from checks

where
    latest_date is not null
    and actual_age_days > {{ max_age_days }}

{% endif %}

{% endtest %}