# Conditional Checks

Conditional checks validate dependency-based business rules.

They are useful when a rule should only apply if another condition is true.

Examples:

- require a cancellation date when an order is cancelled
- require a VAT number for specific countries
- require a status when a workflow reaches a specific stage
- enforce conditional completeness rules

---

# Available Checks

| Check | Description |
| --- | --- |
| `require_when` | Ensures a requirement expression is true when a trigger condition is met |
| `require_not_null_when` | Ensures a column is not null when a condition is met |
| `require_value_when` | Ensures a column contains a specific value when a condition is met |

---

# `require_when`

Ensures that a requirement expression is true when a trigger condition is met.

## Example

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.require_when:
          arguments:
            when: "status = 'cancelled'"
            require: "cancelled_at is not null"
```

This validates:

> If `status = 'cancelled'`, then `cancelled_at` must not be null.

---

# `require_not_null_when`

Ensures that a column is not null when a condition is met.

## Example

```yaml
models:
  - name: customers
    data_tests:
      - dbt_checks.require_not_null_when:
          arguments:
            when: "country = 'ES'"
            column_name: vat_number
```

This validates:

> If `country = 'ES'`, then `vat_number` must not be null.

---

# `require_value_when`

Ensures that a column contains a specific value when a condition is met.

## Example

```yaml
models:
  - name: subscriptions
    data_tests:
      - dbt_checks.require_value_when:
          arguments:
            when: "cancelled_at is not null"
            column_name: status
            value: "cancelled"
```

This validates:

> If `cancelled_at` is not null, then `status` must be `cancelled`.

---

# Failure Outputs

Conditional checks expose debugging context to make failures easier to inspect.

Common output fields include:

- `trigger_condition`
- `required_condition`
- `required_column`
- `required_value`
- `failed_check`
- `failure_reason`
- `applied_condition`

Example output:

| trigger_condition | required_condition | failed_check |
| --- | --- | --- |
| status = 'cancelled' | cancelled_at is not null | require_when |

---

# Scoped Conditional Checks

Conditional checks support native dbt `where` configuration.

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.require_not_null_when:
          arguments:
            when: "status = 'cancelled'"
            column_name: cancelled_at
          config:
            where: "created_at >= current_date - interval '30 days'"
```

This applies the conditional rule only to recent records.

---

# NULL Handling

Conditional checks evaluate NULL behavior based on the provided SQL expressions.

For example:

```sql
status = 'cancelled'
```

will only trigger when the expression evaluates to true.

If the condition is false or unknown, the requirement is not evaluated as a failure.

---

# Common Use Cases

## Cancelled orders

```yaml
- dbt_checks.require_not_null_when:
    arguments:
      when: "status = 'cancelled'"
      column_name: cancelled_at
```

## Country-specific tax fields

```yaml
- dbt_checks.require_not_null_when:
    arguments:
      when: "country = 'ES'"
      column_name: vat_number
```

## Workflow state consistency

```yaml
- dbt_checks.require_when:
    arguments:
      when: "payment_status = 'paid'"
      require: "paid_at is not null"
```

## Required value after event

```yaml
- dbt_checks.require_value_when:
    arguments:
      when: "cancelled_at is not null"
      column_name: status
      value: "cancelled"
```

---

## Related Documentation

* [Overview](overview.md)
* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Rule Composition](rule-composition.md)
* [Architecture](architecture.md)
* [Examples](examples.md)
* [CI](ci.md)
