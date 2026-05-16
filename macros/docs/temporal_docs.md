-- =========================
-- TEMPORAL DOCS
-- =========================

{% docs test_not_future_date %}
Ensures that dates are not in the future.

### Description

Checks that each non-null date value is less than or equal to the current date.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

Supports scoped validation through `where`.

### Arguments

- **column_name** *(string)*  
Date column to evaluate.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | failed_check | failure_reason |
| --- | --- | --- |
| 2099-01-01 | not_future_date | Date must not be in the future |

### Example

```yaml
tests:
  - dbt_checks.not_future_date:
      arguments:
        column_name: order_date
```

{% enddocs %}


{% docs test_not_before_date %}
Ensures that dates are not before a specified minimum date.

### Description

Checks that each non-null date value is on or after the specified minimum date.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

Supports scoped validation through `where`.

### Arguments

- **column_name** *(string)*  
Date column to evaluate.

- **min_date** *(date or string)*  
Minimum allowed date.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_min_date | failed_check |
| --- | --- | --- |
| 2023-01-01 | 2024-01-01 | not_before_date |

### Example

```yaml
tests:
  - dbt_checks.not_before_date:
      arguments:
        column_name: signup_date
        min_date: "2024-01-01"
```

{% enddocs %}


{% docs test_between_dates %}
Ensures that dates fall within a given range.

### Description

Checks that each non-null date value is between `min_date` and `max_date`.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

Supports scoped validation through `where`.

### Arguments

- **column_name** *(string)*  
Date column to evaluate.

- **min_date** *(date or string)*  
Minimum allowed date.

- **max_date** *(date or string)*  
Maximum allowed date.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_min_date | expected_max_date |
| --- | --- | --- |
| 2025-01-01 | 2024-01-01 | 2024-12-31 |

### Example

```yaml
tests:
  - dbt_checks.between_dates:
      arguments:
        column_name: event_date
        min_date: "2024-01-01"
        max_date: "2024-12-31"
```

{% enddocs %}


{% docs test_recent_date %}
Ensures that dates are within a specified number of days from today.

### Description

Checks that the latest non-null date value is not older than `max_age_days` compared with the current date.

NULL values are ignored.  
If all values are NULL, the check passes by default.

Supports grouped validation through `group_by`.

Supports scoped validation through `where`.

### Arguments

- **column_name** *(string)*  
Date column to evaluate.

- **max_age_days** *(integer)*  
Maximum allowed age in days.

- **group_by** *(string or list[string], optional)*  
Column or columns used for grouped validation.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | actual_age_days | expected_max_age_days |
| --- | --- | --- |
| 2024-01-01 | 30 | 7 |

### Grouped failure output

| grouped_by_country | failing_value | actual_age_days |
| --- | --- | --- |
| FR | 2024-01-01 | 30 |

### Example

```yaml
tests:
  - dbt_checks.recent_date:
      arguments:
        column_name: updated_at
        max_age_days: 7
```

### Grouped example

```yaml
tests:
  - dbt_checks.recent_date:
      arguments:
        column_name: updated_at
        max_age_days: 7
        group_by:
          - country
          - sales_channel
```

{% enddocs %}


{% docs test_date_diff_less_than %}
Ensures that the difference between two date columns is below a threshold.

### Description

Checks that the number of days between `start_column` and `end_column` is less than or equal to the defined threshold.

Rows where either date is NULL are ignored.  
Use ratio-based checks if you need to validate NULL presence.

Supports scoped validation through `where`.

### Arguments

- **start_column** *(string)*  
Start date column.

- **end_column** *(string)*  
End date column.

- **max_days** *(integer)*  
Maximum allowed difference in days.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| start_value | end_value | actual_diff_days | expected_max_days |
| --- | --- | --- | --- |
| 2024-01-01 | 2024-02-01 | 31 | 10 |

### Example

```yaml
tests:
  - dbt_checks.date_diff_less_than:
      arguments:
        start_column: created_date
        end_column: fulfilled_date
        max_days: 10
```

{% enddocs %}


{% docs test_no_weekend_dates %}
Ensures that dates do not fall on weekends.

### Description

Checks that each non-null date value falls on a weekday.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

Supports scoped validation through `where`.

### Arguments

- **column_name** *(string)*  
Date column to evaluate.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | actual_day_of_week | failed_check |
| --- | --- | --- |
| 2024-06-15 | Saturday | no_weekend_dates |

### Example

```yaml
tests:
  - dbt_checks.no_weekend_dates:
      arguments:
        column_name: settlement_date
```

{% enddocs %}