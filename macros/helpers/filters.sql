{% macro apply_where(where) %}
    {{ return(adapter.dispatch('apply_where', 'dbt_checks')(where)) }}
{% endmacro %}


{% macro default__apply_where(where) %}

    {% if where is not none %}
        where {{ where }}
    {% endif %}

{% endmacro %}


{% macro applied_condition(where) %}

    '{{ where if where is not none else "none" }}'

{% endmacro %}

{% macro apply_and_where(where) %}

    {% if where is not none %}
        and {{ where }}
    {% endif %}

{% endmacro %}