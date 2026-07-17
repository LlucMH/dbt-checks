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
        {{ group }} as {{ dbt_checks.group_by_alias(group, loop.index) }}{% if not loop.last %}, {% endif %}
    {%- endfor -%}
{% endmacro %}


{% macro render_group_by_output(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}

    {%- for group in groups -%}
        {{ dbt_checks.group_by_alias(group, loop.index) }}{% if not loop.last %}, {% endif %}
    {%- endfor -%}
{% endmacro %}


{% macro render_group_by_list(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}
    {{ return(groups | join(', ')) }}
{% endmacro %}


{% macro render_group_by_clause(group_by) %}
    {%- set groups = dbt_checks.normalize_group_by(group_by) -%}

    {%- if groups | length > 0 -%}
        {{ return("group by " ~ dbt_checks.render_group_by_list(groups)) }}
    {%- endif -%}
{% endmacro %}


{% macro group_by_alias(group, index) %}
    {%- set raw = group | string | trim -%}

    {%- set clean = raw
        | replace('"', '')
        | replace('`', '')
        | replace('[', '')
        | replace(']', '')
        | replace('.', '_')
        | replace(' ', '_')
        | replace('-', '_')
    -%}

    {%- if '(' in clean or ')' in clean or "'" in clean or ',' in clean -%}
        {{ return('grouped_by_' ~ index) }}
    {%- endif -%}

    {{ return('grouped_by_' ~ clean) }}
{% endmacro %}