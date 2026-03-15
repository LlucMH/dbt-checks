# dbt-checks

**dbt-checks** is a lightweight library of reusable data quality checks
for dbt projects.

It provides simple, expressive tests that help validate business rules
and data integrity directly in your dbt models.

The goal is to make common checks easy to apply without writing custom
SQL every time.

> ⚠️ Early stage project --- feedback and contributions are welcome.

------------------------------------------------------------------------

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

------------------------------------------------------------------------

# Usage

Checks can be added directly to models or columns in your schema files.

Example:

``` yaml
models:
  - name: orders
    columns:
      - name: amount
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

------------------------------------------------------------------------

# Available Checks

## Numeric

  Check              Description
  ------------------ ---------------------------------------------
  `non_negative`     Ensures values are ≥ 0
  `non_positive`     Ensures values are ≤ 0
  `greater_than`     Ensures values are greater than a threshold
  `less_than`        Ensures values are less than a threshold
  `between_values`   Ensures values fall within a numeric range

Example:

``` yaml
- dbt_checks.between_values:
    arguments:
      min_value: 0
      max_value: 100
```

------------------------------------------------------------------------

## String

  Check              Description
  ------------------ ---------------------------------------------
  `not_blank`        Ensures strings are not empty or whitespace
  `length_between`   Validates string length range
  `matches_regex`    Validates a regex pattern
  `starts_with`      Ensures string starts with prefix
  `ends_with`        Ensures string ends with suffix

------------------------------------------------------------------------

## Temporal

  Check               Description
  ------------------- --------------------------------------
  `not_future_date`   Ensures date is not in the future
  `not_before_date`   Ensures date is after a minimum date
  `between_dates`     Ensures date is within a range
  `recent_date`       Ensures date is within N days

Example:

``` yaml
- dbt_checks.recent_date:
    arguments:
      max_age_days: 7
```

------------------------------------------------------------------------

## Aggregation

  Check                      Description
  -------------------------- ------------------------------------------------
  `row_count_between`        Ensures model row count is within range
  `row_count_greater_than`   Ensures model has at least N rows
  `sum_between`              Ensures sum of a column falls within range
  `avg_between`              Ensures average of a column falls within range

Example:

``` yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            min_value: 100
```

------------------------------------------------------------------------

## Ratio

  Check                      Description
  -------------------------- -------------------------------------------
  `null_ratio_below`         Ensures null ratio is below threshold
  `positive_ratio_between`   Ensures positive value ratio within range
  `value_ratio_between`      Ensures specific value ratio within range

Example:

``` yaml
- dbt_checks.null_ratio_below:
    arguments:
      threshold: 0.05
```

------------------------------------------------------------------------

# Supported Warehouses

`dbt-checks` supports common dbt adapters:

-   Snowflake
-   BigQuery
-   Databricks
-   Spark
-   Redshift
-   Postgres

Adapter-specific behavior is handled through dbt's `dispatch` mechanism.

------------------------------------------------------------------------

# Why dbt-checks?

Many dbt projects repeatedly implement the same validation logic.

`dbt-checks` provides:

-   reusable checks
-   simple configuration
-   consistent validation patterns
-   cross-warehouse compatibility

------------------------------------------------------------------------

# Contributing

Contributions are welcome.

If you'd like to add a new check:

1.  Implement it in `macros/tests`
2.  Reuse helper macros when possible
3.  Add documentation
4.  Add integration tests

------------------------------------------------------------------------

# License

MIT
