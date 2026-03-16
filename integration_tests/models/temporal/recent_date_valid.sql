select current_date as date
union all
select current_date - interval '1 day'
union all
select current_date - interval '5 day'