select
    cast(value as varchar) as value
from {{ ref('seed_string_all_null') }}