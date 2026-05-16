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