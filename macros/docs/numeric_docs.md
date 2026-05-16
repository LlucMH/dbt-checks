-- =========================
-- NUMERIC DOCS
-- =========================

{% docs test_non_negative %}
Ensures that values are greater than or equal to 0.

### Description

Validates that all non-null values in the column are zero or positive.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | failed_check | failure_reason |
| --- | --- | --- |
| -5 | non_negative | Value must be greater than or equal to 0 |

### Example

```yaml
tests:
  - dbt_checks.non_negative:
      arguments:
        column_name: amount
```

{% enddocs %}


{% docs test_non_positive %}
Ensures that values are less than or equal to 0.

### Description

Validates that all non-null values in the column are zero or negative.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | failed_check | failure_reason |
| --- | --- | --- |
| 5 | non_positive | Value must be less than or equal to 0 |

### Example

```yaml
tests:
  - dbt_checks.non_positive:
      arguments:
        column_name: balance_delta
```

{% enddocs %}


{% docs test_greater_than %}
Ensures that values are strictly greater than a threshold.

### Description

Checks that every non-null value in the column is greater than the specified threshold.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **value** *(number)*  
Minimum exclusive threshold.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_min_value | failed_check |
| --- | --- | --- |
| 0 | 1 | greater_than |

### Example

```yaml
tests:
  - dbt_checks.greater_than:
      arguments:
        column_name: quantity
        value: 0
```

{% enddocs %}


{% docs test_greater_or_equal_than %}
Ensures that values are greater than or equal to a threshold.

### Description

Checks that every non-null value in the column is greater than or equal to the specified threshold.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **value** *(number)*  
Minimum inclusive threshold.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_min_value | failed_check |
| --- | --- | --- |
| -1 | 0 | greater_or_equal_than |

### Example

```yaml
tests:
  - dbt_checks.greater_or_equal_than:
      arguments:
        column_name: quantity
        value: 0
```

{% enddocs %}


{% docs test_less_than %}
Ensures that values are strictly less than a threshold.

### Description

Checks that every non-null value in the column is below the specified threshold.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **value** *(number)*  
Maximum exclusive threshold.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_max_value | failed_check |
| --- | --- | --- |
| 1.2 | 1 | less_than |

### Example

```yaml
tests:
  - dbt_checks.less_than:
      arguments:
        column_name: discount_rate
        value: 1
```

{% enddocs %}


{% docs test_less_or_equal_than %}
Ensures that values are less than or equal to a threshold.

### Description

Checks that every non-null value in the column is less than or equal to the specified threshold.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **value** *(number)*  
Maximum inclusive threshold.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_max_value | failed_check |
| --- | --- | --- |
| 2 | 1 | less_or_equal_than |

### Example

```yaml
tests:
  - dbt_checks.less_or_equal_than:
      arguments:
        column_name: discount_rate
        value: 1
```

{% enddocs %}


{% docs test_between_values %}
Ensures that values fall within a numeric range.

### Description

Checks that every non-null value in the column is between `min_value` and `max_value`.

NULL values are ignored.  
If all values are NULL, the check passes by default.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_value** *(number)*  
Minimum allowed value (inclusive).

- **max_value** *(number)*  
Maximum allowed value (inclusive).

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_min_value | expected_max_value |
| --- | --- | --- |
| 150 | 0 | 100 |

### Example

```yaml
tests:
  - dbt_checks.between_values:
      arguments:
        column_name: score
        min_value: 0
        max_value: 100
```

{% enddocs %}