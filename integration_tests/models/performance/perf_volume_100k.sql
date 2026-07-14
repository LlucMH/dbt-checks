{{ config(materialized='table', tags=['performance_smoke']) }}

select
    i as id,
    (i % 1000) + 1 as amount,
    case when i % 20 = 0 then null else 'active' end as status,
    case when i % 5 = 0 then 'gold' else 'standard' end as tier
from generate_series(1, 100000) as t(i)
