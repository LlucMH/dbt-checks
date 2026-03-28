-- =========================
-- NUMERIC DOCS
-- =========================

{% docs non_negative %}
Ensures that values are greater than or equal to 0.
### Description
Validates that all non-null values in the column are zero or positive.
### Arguments
- **column_name** *(string)*
Column to evaluate.
### Example
```yaml
tests:
- dbt_checks.non_negative:
column_name: amount
```
{% enddocs %}


{% docs non_positive %}
Ensures that values are less than or equal to 0.
### Description
Validates that all non-null values in the column are zero or negative.
### Arguments
- **column_name** *(string)*
Column to evaluate.
### Example
```yaml
tests:
- dbt_checks.non_positive:
column_name: balance_delta
```
{% enddocs %}


{% docs greater_than %}
Ensures that values are strictly greater than a threshold.
### Description
Checks that every non-null value in the column is greater than the specified threshold.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **value** *(number)*
Minimum exclusive threshold.
### Example
```yaml
tests:
- dbt_checks.greater_than:
column_name: quantity
value: 0
```
{% enddocs %}


{% docs greater_or_equal_than %}
Ensures that values are greater than or equal to a threshold.
### Description
Checks that every non-null value in the column is greater than or equal to the specified threshold.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **value** *(number)*
Minimum inclusive threshold.
### Example
```yaml
tests:
- dbt_checks.greater_or_equal_than:
column_name: quantity
value: 0
```
{% enddocs %}


{% docs less_than %}
Ensures that values are strictly less than a threshold.
### Description
Checks that every non-null value in the column is below the specified threshold.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **value** *(number)*
Maximum exclusive threshold.
### Example
```yaml
tests:
- dbt_checks.less_than:
column_name: discount_rate
value: 1
```
{% enddocs %}


{% docs less_or_equal_than %}
Ensures that values are less than or equal to a threshold.
### Description
Checks that every non-null value in the column is less than or equal to the specified threshold.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **value** *(number)*
Maximum inclusive threshold.
### Example
```yaml
tests:
- dbt_checks.less_or_equal_than:
column_name: discount_rate
value: 1
```
{% enddocs %}


{% docs between_values %}
Ensures that values fall within a numeric range.
### Description
Checks that every non-null value in the column is between `min_value` and `max_value`.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_value** *(number)*
Minimum allowed value (inclusive).
- **max_value** *(number)*
Maximum allowed value (inclusive).
### Example
```yaml
tests:
- dbt_checks.between_values:
column_name: score
min_value: 0
max_value: 100
```
{% enddocs %}