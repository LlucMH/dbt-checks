<p align="center">
  <img src="assets/dbt-checks banner.png" alt="dbt-checks banner" width="600"/>
</p>

---

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/LlucMH/dbt-checks/ci.yml?branch=main" />
  <img src="https://img.shields.io/badge/dbt-1.5%2B-orange" />
  <img src="https://img.shields.io/badge/tested%20on-duckdb-blue" />
  <img src="https://img.shields.io/badge/cross--db-dbt%20dispatch-lightgrey" />
  <img src="https://img.shields.io/github/license/LlucMH/dbt-checks" />
  <img src="https://img.shields.io/github/v/release/LlucMH/dbt-checks" />
</p>

---

**`dbt-checks`** is a lightweight library of reusable data quality checks for dbt projects.

It provides simple, expressive tests to validate business rules and data integrity directly in your models — without writing custom SQL every time.

> ⚠️ Early-stage project — feedback and contributions are welcome.

---

# Installation

Add the package to your `packages.yml`:

```yaml
packages:
  - git: https://github.com/LlucMH/dbt-checks.git
    revision: v0.3.3-
```

Then install dependencies:

``` bash
dbt deps
```

💡 Always pin a version in production projects.

# Usage

Checks can be added directly to models or columns in your schema files.

Example:

``` yaml
models:
  - name: orders
    columns:
      - name: value
        data_tests:
          - dbt_checks.non_negative
          - dbt_checks.between_values:
              arguments:
                min_value: 0
                max_value: 10000
```

Run tests as usual:

``` bash
dbt test
```

# Scoped Checks with `where`

All checks support an optional `where` argument to apply validations only to a subset of rows.

This is useful when you want to validate specific business segments, statuses, partitions, or recent data.

Example:

```yaml
models:
  - name: orders
    columns:
      - name: value
        data_tests:
          - dbt_checks.greater_than:
              arguments:
                value: 0
                where: "status = 'active'"
```

The `where` expression is applied before the check runs.

# Standardized Failure Output

dbt-checks provides standardized and human-readable failure outputs designed for easier debugging and CI visibility.

Instead of generic outputs like:

```text
Got 1 result, configured to fail if != 0
```

checks now expose contextual failure information.

## Row-level checks

Example output:

| failing_value | expected_min_value | failed_check | failure_reason |
| --- | --- | --- | --- |
| -5 | 0 | non_negative | Value must be greater than or equal to 0 |

Used by:
- numeric checks
- string checks
- most temporal checks

---

## Aggregation checks

Example output:

| actual_value | expected_min_value | expected_max_value |
| --- | --- | --- |
| 1500 | 0 | 1000 |

Used by:
- avg_between
- sum_between
- min_between
- max_between
- row_count_between

---

## Ratio checks

Example output:

| actual_ratio | expected_min_ratio | expected_max_ratio |
| --- | --- | --- |
| 0.92 | 0.0 | 0.80 |

Used by:
- null_ratio_between
- positive_ratio_between
- negative_ratio_between
- value_ratio_between

---

## Additional Context

Checks may also expose:

- `failed_check`
- `failure_reason`
- `applied_condition`
- `actual_length`
- `actual_diff_days`
- `actual_day_of_week`

This makes dbt-checks outputs easier to:
- debug in CI
- inspect in stored failures
- integrate with observability tooling
- consume programmatically

# NULL Handling

dbt-checks follows a consistent and explicit null-handling strategy.

Most checks ignore null values by default.
Use dedicated checks to validate null presence.

## Summary:

- Numeric        → ignored  
- String         → ignored  
- Temporal       → ignored  
- Aggregation    → ignored (SQL behavior)  
- Row count      → includes nulls  
- Ratio checks   → explicit handling  

Use:
- null_ratio_below
- null_ratio_between

# Severity Configuration

`dbt-checks` uses native dbt severity configuration.

You can decide whether a failing check should raise a warning or fail the pipeline.

## Warning severity

Use `severity: warn` for checks that should be monitored but should not block execution.

```yaml
models:
  - name: orders
    columns:
      - name: email
        data_tests:
          - dbt_checks.null_ratio_below:
              arguments:
                threshold: 0.05
              config:
                severity: warn
```

Useful for:

- exploratory checks
- soft data quality monitoring
- checks being progressively rolled out
- non-critical business rules

## Error severity

Use `severity: error` for checks that should fail the pipeline when violated.

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            value: 100
          config:
            severity: error
```

Useful for:

- production-critical validations
- data contract checks
- downstream-breaking issues
- SLA violations

## warn_if and error_if

You can also use dbt's native `warn_if` and `error_if` configuration.

```yaml
models:
  - name: orders
    columns:
      - name: email
        data_tests:
          - dbt_checks.null_ratio_below:
              arguments:
                threshold: 0.05
              config:
                severity: warn
                warn_if: "> 0"
```

## CI behavior

In CI, you can decide whether warnings should fail the pipeline.

This command treats warnings as failures:

```bash
dbt test --warn-error
```

Recommended rollout strategy:

1. Add new checks as `severity: warn`
2. Monitor failures in CI or dbt artifacts
3. Fix upstream data quality issues
4. Promote stable checks to `severity: error`

# Available Checks

dbt-checks provides reusable data validation tests grouped by category.

## Numeric

Numeric checks validate numeric ranges and thresholds.

Check | Description
----- | ----------
`non_negative` | Ensures values are ≥ 0
`non_positive` | Ensures values are ≤ 0
`greater_than` | Ensures values are greater than a threshold
`greater_or_equal_than` | Ensures values are ≥ a threshold
`less_than` | Ensures values are less than a threshold
`less_or_equal_than` | Ensures values are ≤ a threshold
`between_values` | Ensures values fall within a numeric range

Example

``` yaml
columns:
  - name: value
    data_tests:
      - dbt_checks.between_values:
          arguments:
            min_value: 0
            max_value: 100
```
## String

String checks validate textual fields such as identifiers or formatted values.

Check | Description
----- | ----------
`not_blank` | Ensures strings are not empty or whitespace
`length_between` | Validates string length range
`matches_regex` | Validates a regex pattern
`starts_with` | Ensures string starts with prefix
`ends_with` | Ensures string ends with suffix
`contains` | Ensures string contains substring

Example

``` yaml
columns:
  - name: email
    data_tests:
      - dbt_checks.matches_regex:
          arguments:
            pattern: "^[^@]+@[^@]+\\.[^@]+$"
```
## Temporal

Temporal checks validate date and timestamp fields.

Check | Description
----- | ----------
`not_future_date` | Ensures date is not in the future
`not_before_date` | Ensures date is after a minimum date
`between_dates` | Ensures date is within a range
`recent_date` | Ensures date is within N days
`date_diff_less_than` | Ensures difference between two dates is within threshold
`no_weekend_dates` | Ensures dates do not fall on weekends

Example

``` yaml
columns:
  - name: date
    data_tests:
      - dbt_checks.recent_date:
          arguments:
            max_age_days: 7
```
## Aggregation

Aggregation checks validate dataset-level metrics.
Nulls follow SQL behavior (ignored in aggregation).

Check | Description
----- | ----------
`row_count_greater_than` | Ensures model has at least N rows
`row_count_less_than` | Ensures model has at most N rows
`row_count_between` | Ensures row count falls within range
`sum_between` | Ensures column sum falls within range
`avg_between` | Ensures column average falls within range
`max_between` | Ensures column maximum falls within range
`min_between` | Ensures column minimum falls within range

**If all values are null → test fails**

Example

``` yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            value: 100
```
## Ratio

Ratio checks validate proportions of rows matching a condition.

Check | Description
----- | ----------
`null_ratio_below` | Ensures null ratio is below threshold
`null_ratio_between` | Ensures null ratio is within range
`positive_ratio_between` | Ensures positive value ratio within range
`negative_ratio_between` | Ensures negative value ratio within range
`value_ratio_between` | Ensures specific value ratio within range

**Null handling:**
- null_ratio_* explicitly evaluates nulls
- others use total row count as denominator

Example

``` yaml
columns:
  - name: email
    data_tests:
      - dbt_checks.null_ratio_below:
          arguments:
            threshold: 0.05
```

# Validation Guards

`dbt-checks` validates test arguments during compilation to detect invalid configurations early.

Examples of invalid configurations detected automatically:

- `min_value > max_value`
- ratios outside `0..1`
- empty required strings
- invalid integer arguments
- invalid boolean values
- invalid date ranges for ISO date literals

# Supported Warehouses

`dbt-checks` is designed to work across common dbt adapters:

-   Snowflake
-   BigQuery
-   Databricks
-   Spark
-   Redshift
-   Postgres

Adapter-specific behavior is handled through dbt's `dispatch` mechanism.

**Tested on DuckDB in CI.**

**Aditional adapters are supported through dbt dispatch (best-efort compatibility).**

# Why dbt-checks?

Many dbt projects repeatedly implement the same validation logic.

`dbt-checks` provides:

- reusable checks
- simple configuration
- scoped checks with optional `where` filters
- standardized failure outputs
- CI-friendly debugging context
- predictable null handling
- consistent validation patterns
- cross-warehouse compatibility
- reusable internal helper architecture
- consistent SQL generation across checks
- centralized casting, predicates, ratios, and filtering logic
- native dbt severity support
- clear warn/error usage guidance

# Internal Architecture

`dbt-checks` uses reusable internal helper macros to standardize SQL generation across all checks.

Internal helpers include:

- casting helpers
- reusable predicates
- ratio utilities
- filter application helpers
- date utilities
- validation helpers

This improves:
- maintainability
- adapter compatibility
- consistency
- future extensibility

# Contributing

Contributions are welcome.

To add a new check:

1.  Implement it in `macros/tests`
2.  Reuse helper macros when possible
3.  Add documentation
4.  Add integration tests (including null behavior)

# License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.