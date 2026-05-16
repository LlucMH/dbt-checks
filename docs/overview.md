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
- Standardized failure outputs
- CI-friendly debugging
- Cross-warehouse compatibility
- Reusable validation patterns
- Declarative business-rule enforcement

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
          - dbt_checks.null_ratio_below:
              arguments:
                threshold: 0.02
```

This allows expressing business rules such as:

- values should never be negative
- at most 2% of rows may have missing emails

---

# Categories of Checks

`dbt-checks` organizes validations into several groups, each targeting a common type of data quality rule.

---

## Numeric checks

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

## String checks

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

## Temporal checks

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
  - name: created_at
    data_tests:
      - dbt_checks.recent_date:
          arguments:
            max_age_days: 7
```

Grouped freshness validation is also supported:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.recent_date:
          arguments:
            max_age_days: 7
            group_by: country
```

This validates freshness independently for each segment.

---

## Aggregation checks

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
            min_value: 100
            max_value: 1000000
```

Grouped aggregation validation is supported through `group_by`.

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.avg_between:
          arguments:
            column_name: order_value
            min_value: 10
            max_value: 500
            group_by: country
```

This validates aggregated metrics independently for each segment.

---

## Ratio checks

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
columns:
  - name: status
    data_tests:
      - dbt_checks.value_ratio_between:
          arguments:
            value: "completed"
            min_ratio: 0.8
            max_ratio: 1.0
```

Grouped ratio validation is also supported:

```yaml
group_by:
  - country
  - sales_channel
```

This validates ratios independently for each segment combination.

---

## Multi-column checks

Multi-column checks validate relationships between columns within the same row.

These checks are useful for enforcing row-level business consistency and validating relationships between related fields.

Available checks:

- `columns_equal`
- `columns_distinct`
- `column_greater_than_column`
- `column_less_than_column`

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.column_less_than_column:
          arguments:
            left_column: discount_amount
            right_column: total_amount
```

Typical use cases include:

- validating discounts do not exceed totals
- ensuring two related fields are different
- validating start/end relationships
- validating expected vs actual values

---

## Rule composition checks

Rule composition checks allow reusable SQL expressions to be combined into business-rule validations.

Available checks:

- `expression_is_true`
- `all_of`
- `any_of`

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
              - "status is not null"
```

These checks make it possible to express custom business rules directly in schema files without writing bespoke SQL tests.

---

## Conditional checks

Conditional checks validate dependency-based business rules.

They allow validations of the form:

> if condition A is true, then condition B must also be true

Available checks:

- `require_when`
- `require_not_null_when`
- `require_value_when`

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.require_not_null_when:
          arguments:
            when: "status = 'cancelled'"
            column_name: cancelled_at
```

Typical use cases include:

- cancelled orders requiring cancellation timestamps
- VAT requirements for specific countries
- workflow/state consistency validation
- conditional completeness validation

---

# Grouped Validation

Several checks support grouped validation through `group_by`.

Grouped validation allows rules to be evaluated independently for each segment.

Examples:

```yaml
group_by: country
```

```yaml
group_by:
  - country
  - sales_channel
```

Supported grouped validation areas include:

- aggregation checks
- ratio checks
- freshness checks

Grouped failure outputs expose contextual fields such as:

- `grouped_by_country`
- `grouped_by_status`

This makes failures easier to debug in CI and stored failure tables.

---

# Standardized Failure Outputs

`dbt-checks` provides standardized and contextual failure outputs.

Instead of generic outputs such as:

```text
Got 1 result, configured to fail if != 0
```

checks expose business-oriented debugging information.

Examples include:

| left_value | right_value | failed_check |
| --- | --- | --- |
| 150 | 100 | column_less_than_column |

| trigger_condition | required_condition | failed_check |
| --- | --- | --- |
| status = 'cancelled' | cancelled_at is not null | require_when |

| grouped_by_country | actual_ratio | expected_max_ratio |
| --- | --- | --- |
| ES | 0.92 | 0.80 |

These outputs are designed to improve:

- CI debugging
- stored failure inspection
- observability integrations
- developer experience

---

# Validation Guards

`dbt-checks` validates arguments during compilation to detect invalid configurations early.

Examples of invalid configurations detected automatically include:

- invalid ranges
- invalid ratios
- empty required strings
- invalid grouping definitions
- invalid expression lists
- invalid conditional rules

This prevents invalid checks from silently generating incorrect SQL.

---

# Supported warehouses

The package is designed to work across common dbt adapters, including:

- Snowflake
- BigQuery
- Databricks
- Spark
- Redshift
- Postgres

Adapter-specific behavior is handled through dbt's `dispatch` mechanism.

DuckDB is used as the primary CI validation adapter.

---

# Project goals

`dbt-checks` aims to provide:

- reusable validation patterns
- expressive business-rule validations
- CI-friendly debugging outputs
- declarative schema-driven validation
- cross-warehouse compatibility
- reusable validation architecture
- grouped validation support
- standardized failure semantics
- maintainable data quality enforcement

The package is intentionally lightweight and focused on practical real-world validation scenarios.