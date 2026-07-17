-- =========================
-- AGGREGATION DOCS
-- =========================

{% docs test_row_count_greater_than %}
Ensures that the model contains at least a minimum number of rows.

### Description

Checks that the total row count of the model is greater than the specified minimum.

This check is not affected by NULL values since it operates on total row count.

Supports grouped validation through `group_by`.

### Arguments

- **value** *(integer)*  
Minimum required row count.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.row_count_greater_than:
      arguments:
        value: 100
```

### Grouped example

```yaml
tests:
  - dbt_checks.row_count_greater_than:
      arguments:
        value: 100
        group_by: country
```

{% enddocs %}


{% docs test_row_count_less_than %}
Ensures that the model contains fewer than a maximum number of rows.

### Description

Checks that the total row count of the model is less than the specified maximum.

This check is not affected by NULL values since it operates on total row count.

Supports grouped validation through `group_by`.

### Arguments

- **value** *(integer)*  
Maximum allowed row count.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.row_count_less_than:
      arguments:
        value: 1000000
```

### Grouped example

```yaml
tests:
  - dbt_checks.row_count_less_than:
      arguments:
        value: 1000
        group_by: status
```

{% enddocs %}


{% docs test_row_count_between %}
Ensures that the model row count falls within a specified range.

### Description

Checks that the total number of rows in the model is between `min_value` and `max_value`.

This check is not affected by NULL values since it operates on total row count.

Supports grouped validation through `group_by`.

### Arguments

- **min_value** *(integer)*  
Minimum allowed row count.

- **max_value** *(integer)*  
Maximum allowed row count.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.row_count_between:
      arguments:
        min_value: 10
        max_value: 1000
```

### Grouped example

```yaml
tests:
  - dbt_checks.row_count_between:
      arguments:
        min_value: 10
        max_value: 1000
        group_by:
          - country
          - sales_channel
```

{% enddocs %}


{% docs test_distinct_count_between %}
Ensures that the number of distinct values in a column falls within a specified range.

### Description

Calculates the cardinality of the column:

```
count(distinct column_name)
```

and verifies that it lies between `min_value` and `max_value` (inclusive).

NULL values are excluded from the count, matching standard SQL
`count(distinct ...)` semantics. If the column has no non-NULL values
(including an empty table), the distinct count is `0`.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_value** *(non-negative integer)*  
Minimum allowed distinct count.

- **max_value** *(non-negative integer)*  
Maximum allowed distinct count.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_distinct_count | expected_min_value | expected_max_value | failed_check |
| --- | --- | --- | --- |
| 3 | 5 | 10 | distinct_count_between |

### Grouped failure output

| grouped_by_country | actual_distinct_count | expected_min_value |
| --- | --- | --- |
| ES | 3 | 5 |

### Example

```yaml
tests:
  - dbt_checks.distinct_count_between:
      arguments:
        column_name: user_id
        min_value: 100
        max_value: 10000
```

### Grouped example

```yaml
tests:
  - dbt_checks.distinct_count_between:
      arguments:
        column_name: session_id
        min_value: 1
        max_value: 500
        group_by:
          - country
          - channel
```

{% enddocs %}


{% docs test_duplicate_count_between %}
Ensures that the number of rows belonging to a duplicated composite key falls within a specified range.

### Description

Evaluates the composite key formed by `columns` and calculates:

```
duplicate_row_count =
    evaluated_row_count - unique_row_count
```

and verifies that it lies between `min_count` and `max_count` (inclusive).

`duplicate_row_count` counts **every row that belongs to a duplicate group**,
not the number of excess copies beyond the first occurrence. A row is part
of a duplicate group when its full `columns` combination appears more than
once among the evaluated rows. For example:

```
A
A
A
B
C
```

produces `evaluated_row_count = 5`, `unique_row_count = 2` (only `B` and
`C`), and `duplicate_row_count = 3` — all three `A` rows count as
duplicates, because none of them can be individually distinguished from the
others in that group. This is not the same as
`excess_duplicate_count = sum(group_size - 1)` (which would report `2` for
this example); that alternative metric is not implemented by this check.

Rows where **any** column in `columns` is NULL are excluded from
`evaluated_row_count` entirely, matching the NULL-handling philosophy
introduced by `distinct_ratio_between` and `unique_combination_ratio_between`:
a composite key that is partially unknown cannot be judged unique or
duplicate, so it is dropped rather than being treated as a guaranteed match
or guaranteed miss. Use NULL or completeness checks separately when missing
key values must be detected.

For an ungrouped check, if every row is excluded this way — including an
empty table — the check produces `evaluated_row_count = 0`,
`unique_row_count = 0`, and `duplicate_row_count = 0`.

When `group_by` is used, groups with no evaluable composite keys are omitted
from the result entirely rather than appearing with a duplicate count of
`0`.

Supports grouped validation through `group_by`. When `group_by` is set,
duplicate frequencies are evaluated independently within each group — the
same key appearing once in Spain and once in France remains unique inside
each country rather than being considered globally duplicated.

Useful for validating:

- duplicate IDs on a primary-key-like column
- composite order-line keys, for example `(order_id, line_number)`
- slowly changing dimensions, for example `(customer_id, effective_date)`
- event deduplication, for example `(source_system, event_id)`
- merged source streams where the same business key may arrive more than
  once

### Arguments

- **columns** *(list[string])*  
Column names or SQL expressions defining the composite key. Must be a
non-empty list of distinct expressions.

- **min_count** *(non-negative integer)*  
Minimum allowed duplicate row count.

- **max_count** *(non-negative integer)*  
Maximum allowed duplicate row count.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_duplicate_count | expected_min_count | expected_max_count | evaluated_row_count | unique_row_count | duplicate_row_count | failed_check |
| --- | --- | --- | --- | --- | --- | --- |
| 3 | 0 | 0 | 5 | 2 | 3 | duplicate_count_between |

### Grouped failure output

| grouped_by_country | actual_duplicate_count | expected_min_count | evaluated_row_count | unique_row_count | duplicate_row_count |
| --- | --- | --- | --- | --- | --- |
| ES | 3 | 0 | 5 | 2 | 3 |

### Example

```yaml
tests:
  - dbt_checks.duplicate_count_between:
      arguments:
        columns:
          - order_id
        min_count: 0
        max_count: 10
```

### Grouped example

```yaml
tests:
  - dbt_checks.duplicate_count_between:
      arguments:
        columns:
          - customer_id
          - effective_date
        min_count: 0
        max_count: 5
        group_by:
          - source_system
          - region
```

### Composite key expressions

The `columns` argument accepts a non-empty list of column names or SQL
expressions, each evaluated as one component of the composite key.

```yaml
tests:
  - dbt_checks.duplicate_count_between:
      arguments:
        columns:
          - lower(email)
          - cast(created_at as date)
        min_count: 0
        max_count: 0
```

Expressions are rendered directly into the generated SQL and must be valid
for the target adapter.

{% enddocs %}


{% docs test_sum_between %}
Ensures that the sum of a column falls within a specified range.

### Description

Checks that the sum of non-null values in the column is between `min_value` and `max_value`.

NULL values are ignored.  
If all values are NULL, the result is considered invalid.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to aggregate.

- **min_value** *(number)*  
Minimum allowed sum.

- **max_value** *(number)*  
Maximum allowed sum.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.sum_between:
      arguments:
        column_name: revenue
        min_value: 1000
        max_value: 100000
```

### Grouped example

```yaml
tests:
  - dbt_checks.sum_between:
      arguments:
        column_name: revenue
        min_value: 1000
        max_value: 100000
        group_by: country
```

{% enddocs %}


{% docs test_avg_between %}
Ensures that the average of a column falls within a specified range.

### Description

Checks that the average of non-null values in the column is between `min_value` and `max_value`.

NULL values are ignored.  
If all values are NULL, the result is considered invalid.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to aggregate.

- **min_value** *(number)*  
Minimum allowed average.

- **max_value** *(number)*  
Maximum allowed average.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.avg_between:
      arguments:
        column_name: order_value
        min_value: 10
        max_value: 200
```

### Grouped example

```yaml
tests:
  - dbt_checks.avg_between:
      arguments:
        column_name: order_value
        min_value: 10
        max_value: 200
        group_by: country
```

{% enddocs %}


{% docs test_max_between %}
Ensures that the maximum value of a column falls within a specified range.

### Description

Checks that the maximum non-null value in the column is between `min_value` and `max_value`.

NULL values are ignored.  
If all values are NULL, the result is considered invalid.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_value** *(number)*  
Minimum allowed maximum value.

- **max_value** *(number)*  
Maximum allowed maximum value.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.max_between:
      arguments:
        column_name: latency_ms
        min_value: 1
        max_value: 500
```

### Grouped example

```yaml
tests:
  - dbt_checks.max_between:
      arguments:
        column_name: latency_ms
        min_value: 1
        max_value: 500
        group_by: service
```

{% enddocs %}


{% docs test_min_between %}
Ensures that the minimum value of a column falls within a specified range.

### Description

Checks that the minimum non-null value in the column is between `min_value` and `max_value`.

NULL values are ignored.  
If all values are NULL, the result is considered invalid.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_value** *(number)*  
Minimum allowed minimum value.

- **max_value** *(number)*  
Maximum allowed minimum value.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Example

```yaml
tests:
  - dbt_checks.min_between:
      arguments:
        column_name: temperature
        min_value: -10
        max_value: 50
```

### Grouped example

```yaml
tests:
  - dbt_checks.min_between:
      arguments:
        column_name: temperature
        min_value: -10
        max_value: 50
        group_by:
          - country
          - sensor_type
```

{% enddocs %}