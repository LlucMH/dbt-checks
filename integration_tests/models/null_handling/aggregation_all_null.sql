select
    cast(value as int) as value
from {{ ref('seed_aggregation_all_null') }}
