{% macro current_date_sql() %}
    current_date
{% endmacro %}


{% macro cast_to_date(value) %}
    cast('{{ value }}' as date)
{% endmacro %}