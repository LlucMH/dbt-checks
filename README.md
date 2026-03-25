# dbt-checks

![CI](https://img.shields.io/github/actions/workflow/status/LlucMH/dbt-checks/ci.yml?branch=main)
![dbt](https://img.shields.io/badge/dbt-1.5%2B-orange)
![duckdb](https://img.shields.io/badge/tested%20on-duckdb-blue)
![dispatch](https://img.shields.io/badge/cross--db-dbt%20dispatch-lightgrey)
![license](https://img.shields.io/github/license/LlucMH/dbt-checks)


**`dbt-checks`** is a lightweight library of reusable data quality checks
for dbt projects.

It provides simple, expressive tests that help validate business rules
and data integrity directly in your dbt models.

The goal is to make common checks easy to apply without writing custom
SQL every time.

> ⚠️ Early stage project --- feedback and contributions are welcome.

# Installation

Add the package to your `packages.yml`:

``` yaml
packages:
  - git: https://github.com/LlucMH/dbt-checks.git
    revision: main
```

Then install dependencies:

``` bash
dbt deps
```

For production projects it is recommended to pin a version once releases are available:

```yaml
packages:
  - git: https://github.com/LlucMH/dbt-checks.git
    revision: 0.1.0
```

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

Check | Description
----- | ----------
`row_count_greater_than` | Ensures model has at least N rows
`row_count_less_than` | Ensures model has at most N rows
`row_count_between` | Ensures row count falls within range
`sum_between` | Ensures column sum falls within range
`avg_between` | Ensures column average falls within range
`max_between` | Ensures column maximum falls within range
`min_between` | Ensures column minimum falls within range

Example

``` yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            min_value: 100
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

Example

``` yaml
columns:
  - name: email
    data_tests:
      - dbt_checks.null_ratio_below:
          arguments:
            threshold: 0.05
```
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

-   reusable checks
-   simple configuration
-   consistent validation patterns
-   cross-warehouse compatibility

# Contributing

Contributions are welcome.

If you'd like to add a new check:

1.  Implement it in `macros/tests`
2.  Reuse helper macros when possible
3.  Add documentation
4.  Add integration tests

# License

MIT
