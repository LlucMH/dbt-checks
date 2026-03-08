{% macro validate_min_max(min_value, max_value) %}
    {% if min_value > max_value %}
        {{ exceptions.raise_compiler_error(
            "Invalid arguments: min_value cannot be greater than max_value"
        ) }}
    {% endif %}
{% endmacro %}


{% macro validate_ratio(value, arg_name='value') %}
    {% if value < 0 or value > 1 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be between 0 and 1"
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
    {% if value <= 0 %}
        {{ exceptions.raise_compiler_error(
            "Invalid argument: " ~ arg_name ~ " must be greater than 0"
        ) }}
    {% endif %}
{% endmacro %}