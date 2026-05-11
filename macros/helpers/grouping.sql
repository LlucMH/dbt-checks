{% macro normalize_group_by(group_by) %}
    {%- if group_by is none -%}
        {{ return([]) }}
    {%- elif group_by is string -%}
        {{ return([group_by]) }}
    {%- else -%}
        {{ return(group_by) }}
    {%- endif -%}
{% endmacro %}


{% macro render_group_by_select(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}

    {%- for group in groups -%}
        {{ group }} as grouped_by_{{ loop.index }}{% if not loop.last %}, {% endif %}
    {%- endfor -%}
{% endmacro %}


{% macro render_group_by_output(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}

    {%- for group in groups -%}
        grouped_by_{{ loop.index }}{% if not loop.last %}, {% endif %}
    {%- endfor -%}
{% endmacro %}


{% macro render_group_by_clause(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}

    {%- if groups | length > 0 -%}
        {{ return("group by " ~ (groups | join(", "))) }}
    {%- endif -%}
{% endmacro %}