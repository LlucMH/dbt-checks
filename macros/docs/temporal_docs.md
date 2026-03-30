-- =========================
-- TEMPORAL DOCS
-- =========================

{% docs test_not_future_date %}
Ensures that dates are not in the future.
### Description
Checks that each non-null date value is less than or equal to the current date.
### Arguments
- **column_name** *(string)*
Date column to evaluate.
### Example
    tests:
        - dbt_checks.not_future_date:
            column_name: order_date
{% enddocs %}


{% docs test_not_before_date %}
Ensures that dates are not before a specified minimum date.
### Description
Checks that each non-null date value is on or after the specified minimum date.
### Arguments
- **column_name** *(string)*
Date column to evaluate.
- **min_date** *(date or string)*
Minimum allowed date.
### Example
    tests:
        - dbt_checks.not_before_date:
            column_name: signup_date
            min_date: "2024-01-01"
{% enddocs %}


{% docs test_between_dates %}
Ensures that dates fall within a given range.
### Description
Checks that each non-null date value is between `min_date` and `max_date`.
### Arguments
- **column_name** *(string)*
Date column to evaluate.
- **min_date** *(date or string)*
Minimum allowed date.
- **max_date** *(date or string)*
Maximum allowed date.
### Example
    tests:
        - dbt_checks.between_dates:
            column_name: event_date
            min_date: "2024-01-01"
            max_date: "2024-12-31"
{% enddocs %}


{% docs test_recent_date %}
Ensures that dates are within a specified number of days from today.
### Description
Checks that each non-null date value is not older than `max_age_days` compared with the current date.
### Arguments
- **column_name** *(string)*
Date column to evaluate.
- **max_age_days** *(integer)*
Maximum allowed age in days.
### Example
    tests:
        - dbt_checks.recent_date:
            column_name: updated_at
            max_age_days: 7
{% enddocs %}


{% docs test_date_diff_less_than %}
Ensures that the difference between two date columns is below a threshold.
### Description
Checks that the number of days between `start_column` and `end_column` is less than or equal to the defined.
### Arguments
- **start_column** *(string)*
Start date column.
- **end_column** *(string)*
End date column.
- **max_days** *(integer)*
Maximum allowed difference in days.
### Example
    tests:
        - dbt_checks.date_diff_less_than:
            start_column: created_date
            end_column: fulfilled_date
            max_days: 10
{% enddocs %}


{% docs test_no_weekend_dates %}
Ensures that dates do not fall on weekends.
### Description
Checks that each non-null date value falls on a weekday.
### Arguments
- **column_name** *(string)*
Date column to evaluate.
### Example
    tests:
        - dbt_checks.no_weekend_dates:
            column_name: settlement_date
{% enddocs %}