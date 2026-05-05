-- =========================
-- RATIO DOCS
-- =========================

{% docs test_null_ratio_below %}
Ensures that the ratio of null values in a column is below a specified threshold.
### Description
Calculates the proportion of rows where the column value is NULL and verifies that it does not exceed the defined threshold.

All rows are considered in the denominator.  
If the table is empty, the ratio defaults to 0.

### Arguments
- **column_name** *(string)*
Column to evaluate.
- **threshold** *(float)*
Maximum allowed null ratio (between 0 and 1).
- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Example
    tests:
        - dbt_checks.null_ratio_below:
            column_name: user_id
            threshold: 0.05
{% enddocs %}


{% docs test_null_ratio_between %}
Ensures that the ratio of null values falls within a specified range.
### Description
Computes the proportion of NULL values and checks that it lies between `min_ratio` and `max_ratio`.

All rows are considered in the denominator.  
If the table is empty, the ratio defaults to 0.

### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_ratio** *(float)*
Minimum allowed ratio (inclusive).
- **max_ratio** *(float)*
Maximum allowed ratio (inclusive).
- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Example
    tests:
        - dbt_checks.null_ratio_between:
            column_name: user_id
            min_ratio: 0.0
            max_ratio: 0.1
{% enddocs %}


{% docs test_positive_ratio_between %}
Ensures that the ratio of positive values falls within a specified range.
### Description
Calculates the proportion of rows where the value is greater than 0 and validates it against the defined range.

All rows are considered in the denominator.  
NULL values are ignored in the numerator but included in the denominator.  
If the table is empty, the ratio defaults to 0.

### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_ratio** *(float)*
Minimum allowed ratio.
- **max_ratio** *(float)*
Maximum allowed ratio.
- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Example
    tests:
        - dbt_checks.positive_ratio_between:
            column_name: revenue
            min_ratio: 0.8
            max_ratio: 1.0
{% enddocs %}


{% docs test_negative_ratio_between %}
Ensures that the ratio of negative values falls within a specified range.
### Description
Calculates the proportion of rows where the value is less than 0 and checks it against the specified range.

All rows are considered in the denominator.  
NULL values are ignored in the numerator but included in the denominator.  
If the table is empty, the ratio defaults to 0.

### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_ratio** *(float)*
Minimum allowed ratio.
- **max_ratio** *(float)*
Maximum allowed ratio.
- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Example
    tests:
        - dbt_checks.negative_ratio_between:
            column_name: balance
            min_ratio: 0.0
            max_ratio: 0.1
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

### Arguments
- **column_name** *(string)*
Column to evaluate.
- **value** *(any)*
Target value to match.
- **min_ratio** *(float)*
Minimum allowed ratio.
- **max_ratio** *(float)*
Maximum allowed ratio.
- **where** *(string, optional)*
Optional SQL expression used to filter rows before applying the check.

### Example
    tests:
        - dbt_checks.value_ratio_between:
            column_name: status
            value: 'active'
            min_ratio: 0.7
            max_ratio: 0.95
{% enddocs %}