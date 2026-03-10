{% macro build_between_predicate(column_name, min_value, max_value, inclusive=true) %}
    {% if inclusive %}
        (
            {{ column_name }} < {{ min_value }}
            or {{ column_name }} > {{ max_value }}
        )
    {% else %}
        (
            {{ column_name }} <= {{ min_value }}
            or {{ column_name }} >= {{ max_value }}
        )
    {% endif %}
{% endmacro %}


{% macro build_greater_than_predicate(column_name, min_value, inclusive=false) %}
    {% if inclusive %}
        {{ column_name }} < {{ min_value }}
    {% else %}
        {{ column_name }} <= {{ min_value }}
    {% endif %}
{% endmacro %}


{% macro build_less_than_predicate(column_name, max_value, inclusive=false) %}
    {% if inclusive %}
        {{ column_name }} > {{ max_value }}
    {% else %}
        {{ column_name }} >= {{ max_value }}
    {% endif %}
{% endmacro %}


{% macro build_not_blank_predicate(column_name) %}
    trim({{ column_name }}) = ''
{% endmacro %}