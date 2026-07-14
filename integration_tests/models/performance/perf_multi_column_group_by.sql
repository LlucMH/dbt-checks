{{ config(materialized='table', tags=['performance_smoke']) }}

select
    'region_' || r.region_id as region,
    'category_' || c.category_id as category,
    k.seq as amount,
    current_date - cast(k.seq % 30 as integer) as event_date
from generate_series(0, 19) as r(region_id)
cross join generate_series(0, 9) as c(category_id)
cross join generate_series(1, 500) as k(seq)
