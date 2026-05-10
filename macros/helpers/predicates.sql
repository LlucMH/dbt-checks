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


{% macro build_contains_predicate(column_name, substring) %}

    {{ column_name }} not like '%{{ substring }}%'

{% endmacro %}


{% macro build_starts_with_predicate(column_name, prefix) %}

    {{ column_name }} not like '{{ prefix }}%'

{% endmacro %}


{% macro build_ends_with_predicate(column_name, suffix) %}

    {{ column_name }} not like '%{{ suffix }}'

{% endmacro %}


{% macro build_regex_not_match_predicate(column_name, pattern) %}

    not {{ dbt_checks.regex_match(column_name, pattern) }}

{% endmacro %}


{% macro build_date_between_predicate(column_name, min_date, max_date) %}

    (
        {{ column_name }} < {{ dbt_checks.cast_to_date(min_date) }}
        or {{ column_name }} > {{ dbt_checks.cast_to_date(max_date) }}
    )

{% endmacro %}


{% macro build_not_before_date_predicate(column_name, min_date) %}

    {{ column_name }} < {{ dbt_checks.cast_to_date(min_date) }}

{% endmacro %}


{% macro build_not_future_date_predicate(column_name) %}

    {{ column_name }} > {{ dbt_checks.current_date_sql() }}

{% endmacro %}


{% macro build_recent_date_predicate(column_name, max_age_days) %}

    {{ column_name }} < {{ dbt_checks.days_ago(max_age_days) }}

{% endmacro %}


{% macro build_no_weekend_date_predicate(day_of_week_column) %}

    {{ day_of_week_column }} in (0, 6)

{% endmacro %}