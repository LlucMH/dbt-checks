# Rule Composition

Rule composition checks allow multiple SQL expressions to be combined into reusable business rules.

They are useful when a validation is easier to express as one or more SQL predicates rather than a dedicated check.

---

# Available Checks

| Check | Description |
| --- | --- |
| `expression_is_true` | Validates a single SQL expression row by row |
| `all_of` | Ensures all expressions evaluate to true |
| `any_of` | Ensures at least one expression evaluates to true |

---

# `expression_is_true`

Validates that a SQL expression evaluates to true for every row.

## Example

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.expression_is_true:
          arguments:
            expression: "discount_amount <= total_amount"
```

This validates that discounts never exceed order totals.

---

# `all_of`

Validates that all expressions evaluate to true.

## Example

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.all_of:
          arguments:
            expressions:
              - "discount_amount >= 0"
              - "discount_amount <= total_amount"
              - "status is not null"
```

This validates multiple related business rules together.

---

# `any_of`

Validates that at least one expression evaluates to true.

## Example

```yaml
models:
  - name: contacts
    data_tests:
      - dbt_checks.any_of:
          arguments:
            expressions:
              - "email is not null"
              - "phone is not null"
```

This validates that each contact has at least one contact method.

---

# Failure Outputs

Rule composition checks expose the failing expression context.

Common output fields include:

- `failed_expression`
- `failed_rule_type`
- `failed_check`
- `failure_reason`
- `applied_condition`

Example output:

| failed_expression | failed_rule_type | failed_check |
| --- | --- | --- |
| discount_amount >= 0 and discount_amount <= total_amount | all_of | all_of |

---

# Scoped Rule Composition

Rule composition checks support native dbt `where` configuration.

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.all_of:
          arguments:
            expressions:
              - "discount_amount >= 0"
              - "discount_amount <= total_amount"
          config:
            where: "status = 'completed'"
```

This applies the composed rule only to completed orders.

---

# When to Use Rule Composition

Use rule composition checks when:

- a rule is specific to your business
- a dedicated check would be too narrow
- multiple expressions belong together
- the rule should be readable in schema YAML
- custom SQL tests would be overkill

---

# Rule Composition vs Conditional Checks

Use rule composition when the rule always applies.

Example:

```yaml
- dbt_checks.expression_is_true:
    arguments:
      expression: "discount_amount <= total_amount"
```

Use conditional checks when the rule only applies under a trigger condition.

Example:

```yaml
- dbt_checks.require_when:
    arguments:
      when: "status = 'cancelled'"
      require: "cancelled_at is not null"
```

---

# Common Use Cases

## Financial consistency

```yaml
- dbt_checks.all_of:
    arguments:
      expressions:
        - "total_amount >= 0"
        - "discount_amount >= 0"
        - "discount_amount <= total_amount"
```

## Contactability

```yaml
- dbt_checks.any_of:
    arguments:
      expressions:
        - "email is not null"
        - "phone is not null"
```

## Event consistency

```yaml
- dbt_checks.expression_is_true:
    arguments:
      expression: "event_timestamp >= created_at"
```

---

## Related Documentation

* [Overview](overview.md)
* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Architecture](architecture.md)
* [Examples](examples.md)
* [CI](ci.md)
