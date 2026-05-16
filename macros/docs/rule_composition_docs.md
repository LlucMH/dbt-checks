-- =========================
-- RULE COMPOSITION DOCS
-- =========================

{% docs test_expression_is_true %}
Ensures that a SQL expression evaluates to true for every row.

### Description

Checks that the provided SQL expression evaluates to true.

This check enables fully custom row-level business validations without writing custom test SQL files.

Useful for enforcing arbitrary business rules and validation logic.

Supports scoped validation through `where`.

### Arguments

- **expression** *(string)*  
SQL boolean expression that must evaluate to true.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failed_check | failure_reason |
| --- | --- |
| expression_is_true | Expression must evaluate to true |

### Example

```yaml
tests:
  - dbt_checks.expression_is_true:
      arguments:
        expression: "discount_amount <= total_amount"
```

{% enddocs %}


{% docs test_all_of %}
Ensures that all provided expressions evaluate to true.

### Description

Checks that every expression in the provided list evaluates to true for each row.

Useful for composing reusable validation rules without creating custom SQL tests.

Supports scoped validation through `where`.

### Arguments

- **expressions** *(list[string])*  
List of SQL boolean expressions that must all evaluate to true.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failed_check | failure_reason |
| --- | --- |
| all_of | All expressions must evaluate to true |

### Example

```yaml
tests:
  - dbt_checks.all_of:
      arguments:
        expressions:
          - "discount_amount >= 0"
          - "discount_amount <= total_amount"
          - "status is not null"
```

{% enddocs %}


{% docs test_any_of %}
Ensures that at least one provided expression evaluates to true.

### Description

Checks that at least one expression in the provided list evaluates to true for each row.

Useful for validating alternative valid states or mutually acceptable conditions.

Supports scoped validation through `where`.

### Arguments

- **expressions** *(list[string])*  
List of SQL boolean expressions where at least one must evaluate to true.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failed_check | failure_reason |
| --- | --- |
| any_of | At least one expression must evaluate to true |

### Example

```yaml
tests:
  - dbt_checks.any_of:
      arguments:
        expressions:
          - "email is not null"
          - "phone_number is not null"
```

{% enddocs %}