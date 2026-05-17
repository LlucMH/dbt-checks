-- =========================
-- CONDITIONAL DOCS
-- =========================

{% docs test_require_when %}
Ensures that a required condition is true whenever a trigger condition is met.

### Description

Checks that whenever the `when` condition evaluates to true, the `require` condition must also evaluate to true.

This check is useful for expressing dependency-based business rules.

Supports scoped validation through `where`.

### Arguments

- **when** *(string)*  
Trigger SQL condition.

- **require** *(string)*  
Required SQL condition that must evaluate to true whenever the trigger condition is met.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| trigger_condition | required_condition | failed_check |
| --- | --- | --- |
| status = 'cancelled' | cancelled_at is not null | require_when |

### Example

```yaml
tests:
  - dbt_checks.require_when:
      arguments:
        when: "status = 'cancelled'"
        require: "cancelled_at is not null"
```

{% enddocs %}


{% docs test_require_not_null_when %}
Ensures that a column is not null whenever a trigger condition is met.

### Description

Checks that whenever the `when` condition evaluates to true, the specified column must contain a non-null value.

Useful for validating conditional completeness rules.

Supports scoped validation through `where`.

### Arguments

- **when** *(string)*  
Trigger SQL condition.

- **column_name** *(string)*  
Column that must not be null whenever the trigger condition is met.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| trigger_condition | required_column | failed_check |
| --- | --- | --- |
| status = 'cancelled' | cancelled_at | require_not_null_when |

### Example

```yaml
tests:
  - dbt_checks.require_not_null_when:
      arguments:
        when: "status = 'cancelled'"
        column_name: cancelled_at
```

{% enddocs %}


{% docs test_require_value_when %}
Ensures that a column contains a required value whenever a trigger condition is met.

### Description

Checks that whenever the `when` condition evaluates to true, the specified column must match the required value.

Useful for validating workflow consistency and conditional state rules.

Supports scoped validation through `where`.

### Arguments

- **when** *(string)*  
Trigger SQL condition.

- **column_name** *(string)*  
Column that must contain the required value.

- **value** *(string)*  
Required value for the column whenever the trigger condition is met.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| trigger_condition | required_column | required_value |
| --- | --- | --- |
| status = 'cancelled' | refund_status | processed |

### Example

```yaml
tests:
  - dbt_checks.require_value_when:
      arguments:
        when: "status = 'cancelled'"
        column_name: refund_status
        value: "processed"
```

{% enddocs %}