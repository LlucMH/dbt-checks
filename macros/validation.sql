{% macro validate_required_number(value, arg_name='value') %}

    {% if value is none %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " is required"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_min_max(min_value, max_value) %}

    {{ dbt_checks.validate_required_number(min_value, 'min_value') }}
    {{ dbt_checks.validate_required_number(max_value, 'max_value') }}

    {% if min_value > max_value %}
        {{ exceptions.raise_compiler_error(
            "Invalid arguments: min_value cannot be greater than max_value"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_ratio(value, arg_name='value') %}

    {% if value is none %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " is required"
        ) }}
    {% endif %}

    {% if value < 0 or value > 1 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be between 0 and 1"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_ratio_bounds(min_ratio, max_ratio) %}

    {{ dbt_checks.validate_ratio(min_ratio, 'min_ratio') }}
    {{ dbt_checks.validate_ratio(max_ratio, 'max_ratio') }}

    {% if min_ratio > max_ratio %}
        {{ exceptions.raise_compiler_error(
            "Invalid arguments: min_ratio cannot be greater than max_ratio"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_required_string(value, arg_name='value') %}

    {% if value is none or value | trim == '' %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " cannot be null or empty"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_positive_number(value, arg_name='value') %}

    {% if value is none %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " is required"
        ) }}
    {% endif %}

    {% if value <= 0 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be greater than 0"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_non_negative_number(value, arg_name='value') %}

    {% if value is none %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " is required"
        ) }}
    {% endif %}

    {% if value < 0 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be greater than or equal to 0"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_required_date(value, arg_name='value') %}

    {% if value is none or value | trim == '' %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be a valid date string"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_date_range(min_date, max_date) %}

    {{ dbt_checks.validate_required_date(min_date, 'min_date') }}
    {{ dbt_checks.validate_required_date(max_date, 'max_date') }}

{% endmacro %}