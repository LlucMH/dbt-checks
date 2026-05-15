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

    {{ dbt_checks.validate_required_number(value, arg_name) }}

    {% if value <= 0 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be greater than 0"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_non_negative_number(value, arg_name='value') %}

    {{ dbt_checks.validate_required_number(value, arg_name) }}

    {% if value < 0 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be greater than or equal to 0"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_required_date(value, arg_name='value') %}

    {% if value is none or value | trim == '' %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be a valid date literal or SQL date expression"
        ) }}
    {% endif %}

{% endmacro %}


{% macro is_iso_date_literal(value) %}

    {{ return(
        value is string
        and modules.re.match('^\\d{4}-\\d{2}-\\d{2}$', value)
    ) }}

{% endmacro %}


{% macro validate_date_range(min_date, max_date) %}

    {{ dbt_checks.validate_required_date(min_date, 'min_date') }}
    {{ dbt_checks.validate_required_date(max_date, 'max_date') }}

    {% if dbt_checks.is_iso_date_literal(min_date)
        and dbt_checks.is_iso_date_literal(max_date) %}

        {% if min_date > max_date %}
            {{ exceptions.raise_compiler_error(
                "Invalid arguments: min_date cannot be greater than max_date"
            ) }}
        {% endif %}

    {% endif %}

{% endmacro %}


{% macro validate_positive_integer(value, arg_name='value') %}

    {{ dbt_checks.validate_positive_number(value, arg_name) }}

    {% if value != value | int %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be an integer"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_non_negative_integer(value, arg_name='value') %}

    {{ dbt_checks.validate_non_negative_number(value, arg_name) }}

    {% if value != value | int %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be an integer"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_boolean(value, arg_name='value') %}

    {% if value is none %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " is required"
        ) }}
    {% endif %}

    {% if value not in [true, false] %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be true or false"
        ) }}
    {% endif %}

{% endmacro %}


{% macro validate_group_by(group_by, arg_name='group_by') %}

    {% if group_by is none %}
        {{ return('') }}
    {% endif %}

    {% if group_by is string %}

        {% if group_by | trim == '' %}
            {{ exceptions.raise_compiler_error(
                "Invalid argument: " ~ arg_name ~ " cannot be empty"
            ) }}
        {% endif %}

        {{ return('') }}

    {% endif %}

    {% if group_by is sequence %}

        {% if group_by | length == 0 %}
            {{ exceptions.raise_compiler_error(
                "Invalid argument: " ~ arg_name ~ " cannot be an empty list"
            ) }}
        {% endif %}

        {% for item in group_by %}
            {% if item is not string or item | trim == '' %}
                {{ exceptions.raise_compiler_error(
                    "Invalid argument: " ~ arg_name ~ " must be a string or a non-empty list of strings"
                ) }}
            {% endif %}
        {% endfor %}

        {{ return('') }}

    {% endif %}

    {{ exceptions.raise_compiler_error(
        "Invalid argument: " ~ arg_name ~ " must be a string or a non-empty list of strings"
    ) }}

{% endmacro %}


{% macro validate_required_column(value, arg_name='column') %}

    {% if value is none or value | string | trim == '' %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " cannot be null or empty"
        ) }}
    {% endif %}

{% endmacro %}