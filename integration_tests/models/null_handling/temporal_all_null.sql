select
    cast(date as date) as date,
    cast(start_date as date) as start_date,
    cast(end_date as date) as end_date
from {{ ref('seed_temporal_all_null') }}