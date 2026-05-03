select
    cast(value as int) as value
from {{ ref('seed_numeric_all_null') }}
