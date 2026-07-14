{{ config(materialized='table', tags=['performance_smoke']) }}

select
    i as id,
    (i % 1000) + 1 as amount
from generate_series(1, 1000000) as t(i)
