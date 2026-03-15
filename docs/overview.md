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
      - name: value
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


## Categories of Checks

`dbt-checks` organizes validations into several groups, each targeting a common type of data quality rule.

---

### Numeric checks

Numeric checks validate numeric ranges and thresholds.

Typical use cases include ensuring metrics are positive, values remain within expected ranges, or numeric anomalies are detected.

Available checks:

- `non_negative`
- `non_positive`
- `greater_than`
- `greater_or_equal_than`
- `less_than`
- `less_or_equal_than`
- `between_values`

Example:

```yaml
columns:
  - name: value
    data_tests:
      - dbt_checks.between_values:
          arguments:
            min_value: 0
            max_value: 100
```
---

### String checks

String checks validate textual fields such as identifiers, codes, or free-text columns.

These checks ensure values follow expected formats or patterns.

Available checks:

- `not_blank`
- `length_between`
- `matches_regex`
- `starts_with`
- `ends_with`
- `contains`

Example:

```yaml
columns:
  - name: email
    data_tests:
      - dbt_checks.matches_regex:
          arguments:
            pattern: "^[^@]+@[^@]+\\.[^@]+$"
```
---

### Temporal checks

Temporal checks validate date and timestamp fields.

They help ensure events occur within valid time ranges and prevent issues such as future timestamps or inconsistent date intervals.

Available checks:

- `not_future_date`
- `not_before_date`
- `between_dates`
- `recent_date`
- `date_diff_less_than`
- `no_weekend_dates`

Example:

```yaml
columns:
  - name: event_date
    data_tests:
      - dbt_checks.not_future_date
```
---

### Aggregation checks

Aggregation checks validate aggregated values across datasets.

They help ensure datasets contain a reasonable number of rows or that aggregated metrics remain within expected limits.

Available checks:

- `row_count_greater_than`
- `row_count_less_than`
- `row_count_between`
- `sum_between`
- `avg_between`
- `max_between`
- `min_between`

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_between:
          arguments:
            min_rows: 100
            max_rows: 1000000
```
---

### Ratio checks

Ratio checks validate proportions of rows matching a condition.

They are useful for monitoring data completeness, detecting anomalies, or validating business rules that apply to a percentage of records.

Available checks:

- `negative_ratio_between`
- `null_ratio_below`
- `null_ratio_between`
- `positive_ratio_between`
- `value_ratio_between`

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

Adapter-specific behavior is handled through dbt's `dispatch` mechanism.

---

## Project goals

`dbt-checks` aims to provide:

- reusable validation patterns
- clear and expressive tests
- easy integration into existing dbt projects

The package is intentionally lightweight and focused on common validation scenarios.
