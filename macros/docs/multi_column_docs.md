-- =========================
-- MULTI COLUMN DOCS
-- =========================

{% docs test_columns_equal %}
Ensures that two columns contain the same value.

### Description

Checks that both columns are equal for each row.

Rows where either column is NULL are ignored by default.

Useful for validating mirrored fields, replicated identifiers, or synchronized metrics.

Supports scoped validation through `where`.

### Arguments

- **left_column** *(string)*  
Left column to compare.

- **right_column** *(string)*  
Right column to compare.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| left_value | right_value | failed_check |
| --- | --- | --- |
| 100 | 200 | columns_equal |

### Example

```yaml
tests:
  - dbt_checks.columns_equal:
      arguments:
        left_column: expected_total
        right_column: actual_total
```

{% enddocs %}


{% docs test_columns_distinct %}
Ensures that two columns contain different values.

### Description

Checks that both columns are different for each row.

Rows where either column is NULL are ignored by default.

Useful for validating distinct identifiers, preventing duplicated states, or enforcing field separation.

Supports scoped validation through `where`.

### Arguments

- **left_column** *(string)*  
Left column to compare.

- **right_column** *(string)*  
Right column to compare.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| left_value | right_value | failed_check |
| --- | --- | --- |
| active | active | columns_distinct |

### Example

```yaml
tests:
  - dbt_checks.columns_distinct:
      arguments:
        left_column: current_status
        right_column: previous_status
```

{% enddocs %}


{% docs test_column_greater_than_column %}
Ensures that one column is greater than another column.

### Description

Checks that the left column is strictly greater than the right column for each row.

Rows where either column is NULL are ignored by default.

Useful for validating thresholds, totals, balances, and temporal ordering logic.

Supports scoped validation through `where`.

### Arguments

- **left_column** *(string)*  
Left column to compare.

- **right_column** *(string)*  
Right column to compare.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| left_value | right_value | failed_check |
| --- | --- | --- |
| 50 | 100 | column_greater_than_column |

### Example

```yaml
tests:
  - dbt_checks.column_greater_than_column:
      arguments:
        left_column: total_amount
        right_column: discount_amount
```

{% enddocs %}


{% docs test_column_less_than_column %}
Ensures that one column is less than another column.

### Description

Checks that the left column is strictly less than the right column for each row.

Rows where either column is NULL are ignored by default.

Useful for validating discounts, percentages, thresholds, and upper-bound constraints.

Supports scoped validation through `where`.

### Arguments

- **left_column** *(string)*  
Left column to compare.

- **right_column** *(string)*  
Right column to compare.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| left_value | right_value | failed_check |
| --- | --- | --- |
| 150 | 100 | column_less_than_column |

### Example

```yaml
tests:
  - dbt_checks.column_less_than_column:
      arguments:
        left_column: discount_amount
        right_column: total_amount
```

{% enddocs %}