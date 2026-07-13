select
    1 as id,
    cast('hello' as {{ dbt.type_string() }}) as value
union all
select
    2 as id,
    cast('   ' as {{ dbt.type_string() }}) as value
union all
select
    3 as id,
    cast('world' as {{ dbt.type_string() }}) as value
union all
select
    4 as id,
    cast(' ' as {{ dbt.type_string() }}) as value