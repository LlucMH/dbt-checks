select
    cast(value as numeric) as value,
    cast(status as varchar) as status
from {{ ref('seed_ratio_all_null') }}