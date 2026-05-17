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

# Table of Contents

- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
- [Scoped Checks with `where`](#scoped-checks-with-where)
- [Standardized Failure Output](#standardized-failure-output)
- [NULL Handling](#null-handling)
- [Severity Configuration](#severity-configuration)
- [Real-world Usage Patterns](#real-world-usage-patterns)
- [Available Checks](#available-checks)
  - [Numeric](#numeric)
  - [String](#string)
  - [Temporal](#temporal)
  - [Aggregation](#aggregation)
  - [Ratio](#ratio)
  - [Multi-column](#multi-column)
- [Grouped Checks](#grouped-checks)
- [Rule Composition](#rule-composition)
- [Conditional Checks](#conditional-checks)
- [Validation Guards](#validation-guards)
- [Supported Warehouses](#supported-warehouses)
- [Why dbt-checks?](#why-dbt-checks)
- [Internal Architecture](#internal-architecture)
- [Production Adoption Recommendations](#production-adoption-recommendations)
- [Contributing](#contributing)
- [License](#license)

---

**`dbt-checks`** is a lightweight library of reusable data quality checks for dbt projects.

It provides simple, expressive tests to validate business rules and data integrity directly in your models — without writing custom SQL every time.

> ⚠️ Rapidly evolving project — feedback and contributions are welcome.

---

# Installation

Add the package to your `packages.yml`:

```yaml
packages:
  - git: https://github.com/LlucMH/dbt-checks.git
    revision: v0.5.4
```

Then install dependencies:

```bash
dbt deps
```

💡 Always pin a version in production projects.

# Features

`dbt-checks` provides:

- reusable business-friendly dbt tests
- scoped validations with native `where` support
- grouped validations with `group_by`
- multi-column validations
- conditional business rules
- rule composition checks
- standardized failure outputs
- CI-friendly debugging context
- predictable null handling
- cross-warehouse compatibility through dbt dispatch

# Usage

Checks can be applied at both model-level and column-level in your schema files.

Example:

```yaml
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

```bash
dbt test
```

# Scoped Checks with `where`

All checks support dbt's native `where` configuration to apply validations only to a subset of rows.

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
              config:
                where: "status = 'active'"
```

The `where` expression is applied before the check runs.

# Standardized Failure Output

dbt-checks provides standardized and human-readable failure outputs designed for easier debugging and CI visibility.

Instead of generic outputs like:

```text
Got 1 result, configured to fail if != 0
```

checks expose contextual failure information.

## Row-level checks

Example output:

| failing_value | expected_min_value | failed_check | failure_reason |
| --- | --- | --- | --- |
| -5 | 0 | non_negative | Value must be greater than or equal to 0 |

Used by:

- numeric checks
- string checks
- temporal checks
- multi-column checks
- rule composition checks
- conditional checks

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

## Grouped aggregation checks

Grouped aggregation checks expose grouped context directly in the failure output.

Example output:

| grouped_by_status | actual_value | expected_min_value |
| --- | --- | --- |
| active | 900 | 1000 |

Used by grouped validations such as:

- grouped row count checks
- grouped aggregation checks
- segmented business rule validation

This makes grouped failures easier to:

- debug in CI
- identify problematic segments
- inspect stored failures
- consume programmatically

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

## Advanced rule outputs

Advanced checks expose rule-specific debugging context.

Example output:

| trigger_condition | required_condition | failed_check |
| --- | --- | --- |
| status = 'cancelled' | cancelled_at is not null | require_when |

Used by:

- rule composition checks
- conditional checks
- expression-based checks

---

## Additional Context

Checks may also expose:

- `failed_check`
- `failure_reason`
- `applied_condition`
- `actual_length`
- `actual_diff_days`
- `actual_day_of_week`
- `grouped_by_*`
- `left_column`
- `right_column`
- `failed_expression`
- `trigger_condition`
- `required_condition`
- `required_column`
- `required_value`

### Example with scoped validation

| failing_value | failed_check | applied_condition |
| --- | --- | --- |
| -5 | non_negative | status = 'active' |

This makes dbt-checks outputs easier to:

- debug in CI
- inspect in stored failures
- integrate with observability tooling
- consume programmatically

# NULL Handling

dbt-checks follows a consistent and explicit null-handling strategy.

Most checks ignore null values by default. Use dedicated checks to validate null presence.

## Summary

- Numeric → ignored
- String → ignored
- Temporal → ignored
- Aggregation → ignored by SQL aggregation behavior
- Row count → includes nulls
- Ratio checks → explicit handling
- Multi-column checks → ignored when either compared value is null
- Conditional checks → depend on the condition being evaluated

Use:

- null_ratio_below
- null_ratio_between

## Edge cases

### Empty tables

Aggregation checks support empty tables safely.

### Division by zero

Ratio checks use safe division helpers internally.

### Invalid configurations

Invalid arguments fail compilation early through validation guards.

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

## `warn_if` and `error_if`

dbt also allows severity thresholds based on the number of failing rows.

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

This is useful when you want small issues to raise warnings but larger issues to fail the pipeline.

```yaml
models:
  - name: orders
    columns:
      - name: value
        data_tests:
          - dbt_checks.non_negative:
              config:
                warn_if: "> 0"
                error_if: "> 10"
```

In this example:

- 1 to 10 failing rows produce a warning
- more than 10 failing rows produce an error

This is useful for progressive adoption:

1. Start with `warn_if`
2. Monitor failures
3. Fix upstream issues
4. Tighten thresholds over time
5. Promote checks to hard errors

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

# Real-world Usage Patterns

## Validate only active records

```yaml
- dbt_checks.not_blank:
    config:
      where: "is_active = true"
```

## Validate only recent partitions

```yaml
- dbt_checks.non_negative:
    config:
      where: "created_at >= current_date - interval '30 day'"
```

## Soft monitoring

```yaml
- dbt_checks.null_ratio_below:
    arguments:
      threshold: 0.05
    config:
      severity: warn
```

## Progressive severity rollout

```yaml
- dbt_checks.non_negative:
    config:
      warn_if: "> 0"
      error_if: "> 100"
```

## Strict CI enforcement

```bash
dbt test --warn-error
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

Example:

```yaml
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

Example:

```yaml
columns:
  - name: date
    data_tests:
      - dbt_checks.recent_date:
          arguments:
            max_age_days: 7
```

## Aggregation

Aggregation checks validate dataset-level metrics.

Nulls follow SQL behavior and are ignored in aggregation functions.

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

Example:

```yaml
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

Example:

```yaml
columns:
  - name: email
    data_tests:
      - dbt_checks.null_ratio_below:
          arguments:
            threshold: 0.05
```

## Multi-column

Multi-column checks validate relationships between columns in the same row.

Check | Description
----- | ----------
`columns_equal` | Ensures two columns have equal values
`columns_distinct` | Ensures two columns have distinct values
`column_greater_than_column` | Ensures one numeric column is greater than another
`column_less_than_column` | Ensures one numeric column is less than another

Example:

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.column_less_than_column:
          arguments:
            left_column: discount_amount
            right_column: order_amount
```

# Grouped Checks

Aggregation, ratio, and freshness checks support grouped validation using `group_by`.

Grouped checks validate conditions independently for each segment while reusing the same check names and APIs.

Grouped behavior is enabled through the optional `group_by` argument.

## Basic grouped validation

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            value: 100
            group_by: status
```

This validates that each `status` group has more than 100 rows.

## Grouped validation with `where`

```yaml
models:
  - name: orders
    data_tests:
      - dbt_checks.row_count_greater_than:
          arguments:
            value: 100
            group_by: status
          config:
            where: "created_at >= current_date - interval '30 days'"
```

This validates each `status` group only for rows matching the `where` condition.

For simple column-based grouping, dbt-checks exposes readable grouped context fields such as `grouped_by_status`.

For complex SQL expressions, dbt-checks falls back to stable indexed aliases such as `grouped_by_1`.

## Grouped Aggregation Checks

Grouped aggregation checks allow aggregate validations to run independently per segment.

Supported grouped aggregation checks include:

- `row_count_greater_than`
- `row_count_less_than`
- `row_count_between`
- `avg_between`
- `sum_between`
- `min_between`
- `max_between`

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

This validates that the average `order_value` is between 10 and 500 for each `country`.

## Grouped Ratio Checks

Ratio checks also support grouped validation through `group_by`.

Supported grouped ratio checks include:

- `null_ratio_below`
- `null_ratio_between`
- `positive_ratio_between`
- `negative_ratio_between`
- `value_ratio_between`

Example:

```yaml
models:
  - name: orders
    columns:
      - name: email
        data_tests:
          - dbt_checks.null_ratio_below:
              arguments:
                threshold: 0.05
                group_by: country
```

This validates that each `country` has a null ratio below `5%`.

## Grouped Freshness Checks

`recent_date` supports grouped freshness validation using `group_by`.

This is useful when each segment is expected to receive recent data independently.

Example:

```yaml
models:
  - name: events
    columns:
      - name: event_date
        data_tests:
          - dbt_checks.recent_date:
              arguments:
                max_age_days: 7
                group_by: country
```

This validates that each `country` has at least one date within the last 7 days.

## Multi-column grouping

Grouped checks support multiple grouping columns.

Example:

```yaml
group_by:
  - country
  - sales_channel
```

Failure outputs expose one grouped context field per grouping column:

| grouped_by_country | grouped_by_sales_channel | actual_ratio |
| --- | --- | --- |
| ES | online | 0.80 |

Example with a ratio check:

```yaml
models:
  - name: orders
    columns:
      - name: status
        data_tests:
          - dbt_checks.value_ratio_between:
              arguments:
                value: "completed"
                min_ratio: 0.7
                max_ratio: 1.0
                group_by:
                  - country
                  - sales_channel
```

This validates the ratio independently for each `(country, sales_channel)` combination.

## Grouped ratio failure output

Grouped ratio checks expose grouped context directly in failure outputs.

Example output:

| grouped_by_country | actual_ratio | expected_max_ratio |
| --- | --- | --- |
| ES | 0.92 | 0.80 |

# Rule Composition

Rule composition checks allow combining multiple validation expressions into reusable business rules.

Rule composition checks reduce the need for custom SQL tests by enabling reusable declarative business logic directly in schema files.

Check | Description
----- | ----------
`expression_is_true` | Validates a SQL expression row by row
`all_of` | Ensures all expressions evaluate to true
`any_of` | Ensures at least one expression evaluates to true

Example:

```yaml
- dbt_checks.all_of:
    arguments:
      expressions:
        - "discount_amount >= 0"
        - "discount_amount <= total_amount"
        - "status is not null"
```

# Conditional Checks

Conditional checks validate dependency-based business rules.

Check | Description
----- | ----------
`require_when` | Ensures a requirement expression is true when another condition is met
`require_not_null_when` | Ensures a column is not null when a condition is met
`require_value_when` | Ensures a column contains a specific value when a condition is met

Example:

```yaml
- dbt_checks.require_not_null_when:
    arguments:
      when: "country = 'ES'"
      column_name: vat_number
```

# Validation Guards

`dbt-checks` validates test arguments during compilation to detect invalid configurations early.

Example:

```yaml
- dbt_checks.between_values:
    arguments:
      min_value: 100
      max_value: 0
```

Examples of invalid configurations detected automatically:

- `min_value > max_value`
- ratios outside `0..1`
- empty required strings
- empty required columns
- invalid expression lists
- invalid `group_by` definitions
- invalid integer arguments
- invalid boolean values
- invalid date ranges for ISO date literals

# Supported Warehouses

`dbt-checks` is designed to work across common dbt adapters:

- Snowflake
- BigQuery
- Databricks
- Spark
- Redshift
- Postgres

Adapter-specific behavior is handled through dbt's `dispatch` mechanism.

**Tested on DuckDB in CI.**

**Additional adapters are supported through dbt dispatch (best-effort compatibility).**

| Warehouse | Status |
|---|---|
| DuckDB | Fully tested in CI |
| Snowflake | Supported via dispatch |
| BigQuery | Supported via dispatch |
| Databricks | Supported via dispatch |
| Spark | Supported via dispatch |
| Postgres | Supported via dispatch |
| Redshift | Supported via dispatch |

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
- production-ready usage examples
- progressive data quality adoption patterns
- grouped validation support
- segmented business rule validation
- reusable grouped aggregation architecture
- multi-column grouped validation
- multi-column validation support
- row-level validation across related fields
- rule composition checks
- conditional business-rule validation

# Internal Architecture

`dbt-checks` uses reusable internal helper macros to standardize SQL generation across all checks.

Internal helpers include:

- casting helpers
- reusable predicates
- ratio utilities
- filter application helpers
- date utilities
- validation helpers
- grouped aggregation helpers
- grouped ratio helpers
- grouped output helpers
- multi-column validation helpers
- rule composition helpers
- conditional validation helpers

### Date helper design

Temporal helpers intentionally support both:

- static ISO date literals
- SQL date expressions

Examples:

```sql
created_at
current_date
current_date - interval '7 days'
```

This allows temporal checks to work with:

- static date boundaries
- dynamic temporal windows
- adapter-specific SQL date expressions

Examples:

```sql
min_date: "2024-01-01"
max_date: current_date
```

Temporal checks consistently rely on centralized helper macros instead of implementing manual date casts individually.

This includes:

- `as_date()`
- `cast_to_date()`
- reusable temporal predicates

SQL expressions are safely rendered and escaped internally to preserve cross-warehouse compatibility and predictable SQL generation.

This improves:

- maintainability
- adapter compatibility
- consistency
- future extensibility

# Production Adoption Recommendations

Recommended rollout strategy:

1. Start new checks as `severity: warn`
2. Monitor failures in CI
3. Fix upstream quality issues
4. Tighten thresholds progressively
5. Promote stable checks to `severity: error`

This approach allows safer incremental adoption in mature data platforms.

# Contributing

Contributions are welcome.

To add a new check:

1. Implement it in `macros/tests`
2. Reuse helper macros when possible
3. Add documentation
4. Add integration tests including null behavior

# License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.