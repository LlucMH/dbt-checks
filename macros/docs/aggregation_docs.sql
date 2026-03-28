-- =========================
-- AGGREGATION DOCS
-- =========================

{% docs row_count_greater_than %}
Ensures that the model contains at least a minimum number of rows.
### Description
Checks that the total row count of the model is greater than the specified minimum.
### Arguments
- **min_value** *(integer)*
Minimum required row count.
### Example
```yaml
tests:
- dbt_checks.row_count_greater_than:
min_value: 100
```
{% enddocs %}


{% docs row_count_less_than %}
Ensures that the model contains fewer than a maximum number of rows.
### Description
Checks that the total row count of the model is less than the specified maximum.
### Arguments
- **max_value** *(integer)*
Maximum allowed row count.
### Example
```yaml
tests:
- dbt_checks.row_count_less_than:
max_value: 1000000
```
{% enddocs %}


{% docs row_count_between %}
Ensures that the model row count falls within a specified range.
### Description
Checks that the total number of rows in the model is between `min_value` and `max_value`.
### Arguments
- **min_value** *(integer)*
Minimum allowed row count.
- **max_value** *(integer)*
Maximum allowed row count.
### Example
```yaml
tests:
- dbt_checks.row_count_between:
min_value: 10
max_value: 1000
```
{% enddocs %}


{% docs sum_between %}
Ensures that the sum of a column falls within a specified range.
### Description
Checks that the sum of non-null values in the column is between `min_value` and `max_value`.
### Arguments
- **column_name** *(string)*
Column to aggregate.
- **min_value** *(number)*
Minimum allowed sum.
- **max_value** *(number)*
Maximum allowed sum.
### Example
```yaml
tests:
- dbt_checks.sum_between:
column_name: revenue
min_value: 1000
max_value: 100000
```
{% enddocs %}


{% docs avg_between %}
Ensures that the average of a column falls within a specified range.
### Description
Checks that the average of non-null values in the column is between `min_value` and `max_value`.
### Arguments
- **column_name** *(string)*
Column to aggregate.
- **min_value** *(number)*
Minimum allowed average.
- **max_value** *(number)*
Maximum allowed average.
### Example
```yaml
tests:
- dbt_checks.avg_between:
column_name: order_value
min_value: 10
max_value: 200
```
{% enddocs %}


{% docs max_between %}
Ensures that the maximum value of a column falls within a specified range.
### Description
Checks that the maximum non-null value in the column is between `min_value` and `max_value`.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_value** *(number)*
Minimum allowed maximum value.
- **max_value** *(number)*
Maximum allowed maximum value.
### Example
```yaml
tests:
- dbt_checks.max_between:
column_name: latency_ms
min_value: 1
max_value: 500
```
{% enddocs %}


{% docs min_between %}
Ensures that the minimum value of a column falls within a specified range.
### Description
Checks that the minimum non-null value in the column is between `min_value` and `max_value`.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_value** *(number)*
Minimum allowed minimum value.
- **max_value** *(number)*
Maximum allowed minimum value.
### Example
```yaml
tests:
- dbt_checks.min_between:
column_name: temperature
min_value: -10
max_value: 50
```
{% enddocs %}