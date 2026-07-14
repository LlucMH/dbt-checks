{{ config(materialized='table', tags=['performance_smoke']) }}

select
    'group_' || g.group_id as group_key,
    k.seq as amount,
    case when k.seq % 20 = 0 then null else 'active' end as status,
    case when k.seq % 5 = 0 then 'gold' else 'standard' end as tier
from generate_series(0, 999) as g(group_id)
cross join generate_series(1, 200) as k(seq)
