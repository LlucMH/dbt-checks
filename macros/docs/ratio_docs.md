-- =========================
-- RATIO DOCS
-- =========================

{% docs test_null_ratio_below %}
Ensures that the ratio of null values in a column is below a specified threshold.

### Description

Calculates the proportion of rows where the column value is NULL and verifies that it does not exceed the defined threshold.

All rows are considered in the denominator.  
If the table is empty, the ratio defaults to 0.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **threshold** *(float)*  
Maximum allowed null ratio (between 0 and 1).

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_max_ratio | failed_check |
| --- | --- | --- |
| 0.25 | 0.05 | null_ratio_below |

### Grouped failure output

| grouped_by_country | actual_ratio | expected_max_ratio |
| --- | --- | --- |
| ES | 0.25 | 0.05 |

### Example

```yaml
tests:
  - dbt_checks.null_ratio_below:
      arguments:
        column_name: user_id
        threshold: 0.05
```

### Grouped example

```yaml
tests:
  - dbt_checks.null_ratio_below:
      arguments:
        column_name: user_id
        threshold: 0.05
        group_by: country
```

{% enddocs %}


{% docs test_null_ratio_between %}
Ensures that the ratio of null values falls within a specified range.

### Description

Computes the proportion of NULL values and checks that it lies between `min_ratio` and `max_ratio`.

All rows are considered in the denominator.  
If the table is empty, the ratio defaults to 0.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_ratio** *(float)*  
Minimum allowed ratio (inclusive).

- **max_ratio** *(float)*  
Maximum allowed ratio (inclusive).

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_min_ratio | expected_max_ratio |
| --- | --- | --- |
| 0.25 | 0.0 | 0.10 |

### Grouped failure output

| grouped_by_status | actual_ratio | expected_max_ratio |
| --- | --- | --- |
| inactive | 0.25 | 0.10 |

### Example

```yaml
tests:
  - dbt_checks.null_ratio_between:
      arguments:
        column_name: user_id
        min_ratio: 0.0
        max_ratio: 0.1
```

### Grouped example

```yaml
tests:
  - dbt_checks.null_ratio_between:
      arguments:
        column_name: user_id
        min_ratio: 0.0
        max_ratio: 0.1
        group_by:
          - country
          - sales_channel
```

{% enddocs %}


{% docs test_positive_ratio_between %}
Ensures that the ratio of positive values falls within a specified range.

### Description

Calculates the proportion of rows where the value is greater than 0 and validates it against the defined range.

All rows are considered in the denominator.  
NULL values are ignored in the numerator but included in the denominator.  
If the table is empty, the ratio defaults to 0.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_ratio** *(float)*  
Minimum allowed ratio.

- **max_ratio** *(float)*  
Maximum allowed ratio.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_min_ratio | expected_max_ratio |
| --- | --- | --- |
| 0.40 | 0.80 | 1.0 |

### Grouped failure output

| grouped_by_country | actual_ratio | expected_min_ratio |
| --- | --- | --- |
| FR | 0.40 | 0.80 |

### Example

```yaml
tests:
  - dbt_checks.positive_ratio_between:
      arguments:
        column_name: revenue
        min_ratio: 0.8
        max_ratio: 1.0
```

### Grouped example

```yaml
tests:
  - dbt_checks.positive_ratio_between:
      arguments:
        column_name: revenue
        min_ratio: 0.8
        max_ratio: 1.0
        group_by: country
```

{% enddocs %}


{% docs test_negative_ratio_between %}
Ensures that the ratio of negative values falls within a specified range.

### Description

Calculates the proportion of rows where the value is less than 0 and checks it against the specified range.

All rows are considered in the denominator.  
NULL values are ignored in the numerator but included in the denominator.  
If the table is empty, the ratio defaults to 0.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_ratio** *(float)*  
Minimum allowed ratio.

- **max_ratio** *(float)*  
Maximum allowed ratio.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_min_ratio | expected_max_ratio |
| --- | --- | --- |
| 0.30 | 0.0 | 0.10 |

### Grouped failure output

| grouped_by_country | actual_ratio | expected_max_ratio |
| --- | --- | --- |
| US | 0.30 | 0.10 |

### Example

```yaml
tests:
  - dbt_checks.negative_ratio_between:
      arguments:
        column_name: balance
        min_ratio: 0.0
        max_ratio: 0.1
```

### Grouped example

```yaml
tests:
  - dbt_checks.negative_ratio_between:
      arguments:
        column_name: balance
        min_ratio: 0.0
        max_ratio: 0.1
        group_by: country
```

{% enddocs %}


{% docs test_value_ratio_between %}
Ensures that the ratio of rows matching a specific value falls within a given range.

### Description

Calculates the proportion of rows where `column_name = value` and verifies that it lies between `min_ratio` and `max_ratio`.

All rows are considered in the denominator.  
NULL values are ignored in the numerator but included in the denominator.  
If the table is empty, the ratio defaults to 0.

Useful for validating:

- category distributions
- status proportions
- boolean flags

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **value** *(any)*  
Target value to match.

- **min_ratio** *(float)*  
Minimum allowed ratio.

- **max_ratio** *(float)*  
Maximum allowed ratio.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_value | expected_min_ratio |
| --- | --- | --- |
| 0.50 | active | 0.70 |

### Grouped failure output

| grouped_by_country | actual_ratio | expected_value |
| --- | --- | --- |
| ES | 0.50 | active |

### Example

```yaml
tests:
  - dbt_checks.value_ratio_between:
      arguments:
        column_name: status
        value: 'active'
        min_ratio: 0.7
        max_ratio: 0.95
```

### Grouped example

```yaml
tests:
  - dbt_checks.value_ratio_between:
      arguments:
        column_name: status
        value: 'active'
        min_ratio: 0.7
        max_ratio: 0.95
        group_by:
          - country
          - sales_channel
```

{% enddocs %}


{% docs test_distinct_ratio_between %}
Ensures that the ratio of distinct values in a column falls within a specified range.

### Description

Calculates the proportion of distinct values relative to the number of
non-NULL values in the column:

```
count(distinct column_name)
/
count(column_name)
```

and verifies that it lies between `min_ratio` and `max_ratio`.

NULL values are excluded from both the numerator and the denominator — unlike
the other ratio checks in this package, which count NULL rows in the
denominator. This asymmetry is intentional: `count(distinct column_name)`
never counts NULL as a distinct value in any target adapter, and pairing it
with `count(*)` would let a column with many NULLs report a misleadingly low
ratio even when every non-NULL value is unique. Dividing by `count(column_name)`
instead measures cardinality purely among the values that are actually
present, which is what "duplicate detection" and "key quality" use cases
need.

If the column has no non-NULL values (including an empty table), the ratio
defaults to 0.

Useful for validating:

- duplicate detection
- key quality
- ingestion monitoring
- event integrity

Complements aggregation-level distinct-count validation by monitoring relative
cardinality instead of an absolute count, which makes it stable across
datasets of varying size.

Supports grouped validation through `group_by`.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_ratio** *(float)*  
Minimum allowed ratio (inclusive).

- **max_ratio** *(float)*  
Maximum allowed ratio (inclusive).

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_ratio | expected_min_ratio | expected_max_ratio |
| --- | --- | --- |
| 0.40 | 0.90 | 1.0 |

### Grouped failure output

| grouped_by_source_system | actual_ratio | expected_min_ratio |
| --- | --- | --- |
| crm | 0.40 | 0.90 |

### Example

```yaml
tests:
  - dbt_checks.distinct_ratio_between:
      arguments:
        column_name: user_id
        min_ratio: 0.9
        max_ratio: 1.0
```

### Grouped example

```yaml
tests:
  - dbt_checks.distinct_ratio_between:
      arguments:
        column_name: event_id
        min_ratio: 0.95
        max_ratio: 1.0
        group_by:
          - source_system
          - event_date
```

{% enddocs %}


{% docs test_unique_combination_ratio_between %}
Ensures that the proportion of unique composite-key combinations falls within a specified range.

### Description

Evaluates the composite key formed by `columns` and calculates:

```
unique_row_count
/
evaluated_row_count
```

and verifies that it lies between `min_ratio` and `max_ratio`.

A row is counted as unique when its full `columns` combination appears
exactly once among the evaluated rows. Rows whose combination appears more
than once (a duplicate group) contribute zero to `unique_row_count` — every
row in that group is still duplicated, not just the extras — so a table of
```
A
A
B
C
```
reports `unique_row_count = 2` (only `B` and `C`) and
`evaluated_row_count = 4`, an actual ratio of `0.50`.

Rows where **any** column in `columns` is NULL are excluded from
`evaluated_row_count` entirely, the same distinctness philosophy introduced
by `distinct_ratio_between`: a composite key that is partially unknown
cannot be judged unique or duplicate, so it is dropped from both the
numerator and the denominator rather than being treated as a guaranteed
match or guaranteed miss.

For an ungrouped check, if every row is excluded this way — including an
empty table — the check produces `evaluated_row_count = 0`,
`unique_row_count = 0`, and a ratio of `0` through the existing
`safe_ratio` helper.

When `group_by` is used, groups with no evaluable composite keys are omitted
from the result entirely rather than appearing with a ratio of `0`. Use NULL
or completeness checks separately when those groups must be detected.

Supports grouped validation through `group_by`. When `group_by` is set,
uniqueness is evaluated independently within each group — a combination
that repeats in one group does not affect the ratio computed for another.

Useful for validating composite business keys, for example:

- `(order_id, line_number)` on an order lines table
- `(customer_id, effective_date)` on a slowly changing dimension
- `(source_system, event_id)` on a merged event stream

### Arguments

- **columns** *(list[string])*
Column names defining the composite key. Must be a non-empty list of
distinct column names.

- **min_ratio** *(float)*
Minimum allowed ratio (inclusive).

- **max_ratio** *(float)*
Maximum allowed ratio (inclusive).

- **group_by** *(string or list[string], optional)*
Column or columns used for grouped validation.

- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Failure output

| actual_unique_ratio | expected_min_ratio | expected_max_ratio | evaluated_row_count | unique_row_count | failed_check |
| --- | --- | --- | --- | --- | --- |
| 0.50 | 0.95 | 1.0 | 4 | 2 | unique_combination_ratio_between |

### Grouped failure output

| grouped_by_country | actual_unique_ratio | expected_min_ratio | evaluated_row_count | unique_row_count |
| --- | --- | --- | --- | --- |
| ES | 0.50 | 0.95 | 4 | 2 |

### Example

```yaml
tests:
  - dbt_checks.unique_combination_ratio_between:
      arguments:
        columns:
          - order_id
          - line_number
        min_ratio: 0.99
        max_ratio: 1.0
```

### Grouped example

```yaml
tests:
  - dbt_checks.unique_combination_ratio_between:
      arguments:
        columns:
          - customer_id
          - effective_date
        min_ratio: 0.99
        max_ratio: 1.0
        group_by:
          - source_system
          - region
```

### Composite key expressions

The `columns` argument accepts a non-empty list of column names or SQL
expressions.

Each item is evaluated as one component of the composite key. This allows
the check to validate normalized or derived keys without requiring an
intermediate model.

For example:

```yaml
tests:
  - dbt_checks.unique_combination_ratio_between:
      arguments:
        columns:
          - lower(email)
          - cast(created_at as date)
        min_ratio: 1
        max_ratio: 1
```

Expressions must be valid for the target warehouse. Because expressions are
rendered directly into the generated SQL, adapter-specific functions may
reduce portability across warehouses.

Rows where any composite-key expression evaluates to NULL are excluded from
both `evaluated_row_count` and `unique_row_count`.

{% enddocs %}