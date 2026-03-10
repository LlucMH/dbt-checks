# dbt-checks Overview

**dbt-checks** is a lightweight library of reusable data quality checks for dbt projects.

The goal of this package is to make common data validation rules easy to express and reuse across models without writing custom SQL.

Instead of writing ad-hoc queries, users can define checks declaratively in their model schema files.

---

## Philosophy

`dbt-checks` focuses on:

- Simple and readable checks
- Business-friendly validation rules
- Minimal configuration
- Cross-warehouse compatibility

The package complements built-in dbt tests such as `not_null` and `unique` by providing additional reusable checks.

---

## Example

A simple validation using `dbt-checks`:

```yaml
models:
  - name: orders

    columns:
      - name: amount
        data_tests:
          - dbt_checks.non_negative

      - name: email
        data_tests:
          - dbt_checks.ratio_between:
              arguments:
                condition: "email is not null"
                min_ratio: 0.98
```

This allows expressing business rules such as:

- values should never be negative
- at least 98% of rows must have an email

---

## Categories of Checks

`dbt-checks` organizes validations into several groups.

### Numeric checks

Examples:

- `non_negative`
- `non_positive`
- `greater_than`
- `less_than`
- `between_values`

---

### String checks

Examples:

- `not_blank`
- `length_between`
- `matches_regex`
- `starts_with`
- `ends_with`

---

### Temporal checks

Examples:

- `not_future_date`
- `not_before_date`
- `between_dates`
- `recent_date`

---

### Aggregation checks

Examples:

- `row_count_greater_than`
- `row_count_between`
- `sum_between`
- `avg_between`

---

### Ratio checks

Ratio checks validate proportions of rows matching a condition.

Example:

```yaml
- dbt_checks.ratio_between:
    arguments:
      condition: "status = 'completed'"
      min_ratio: 0.8
```

This ensures that at least 80% of rows meet a given condition.

---

## Supported warehouses

The package is designed to work across common dbt adapters, including:

- Snowflake
- BigQuery
- Databricks
- Spark
- Redshift
- Postgres

Adapter-specific behavior is handled through dbt's dispatch mechanism.

---

## Project goals

dbt-checks aims to provide:

- reusable validation patterns
- clear and expressive tests
- easy integration into existing dbt projects

The package is intentionally lightweight and focused on common validation scenarios.
