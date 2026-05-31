# dbt-checks Overview

**dbt-checks** is a lightweight library of reusable data quality checks for dbt projects.

The package provides business-oriented validation checks that help teams express data quality rules declaratively inside dbt schema files.

Instead of writing custom SQL tests repeatedly, users can apply reusable checks with standardized outputs, validation guards, and cross-warehouse compatibility.

---

# Philosophy

`dbt-checks` is built around a few core principles:

* Declarative validation
* Reusable business rules
* Standardized failure outputs
* CI-friendly debugging
* Cross-warehouse compatibility
* Minimal configuration
* Maintainable data quality enforcement

The package complements built-in dbt tests such as:

* `not_null`
* `unique`
* `relationships`
* `accepted_values`

by providing additional reusable validation patterns.

---

# Example

```yaml
models:
  - name: orders

    columns:
      - name: amount
        data_tests:
          - dbt_checks.non_negative

      - name: email
        data_tests:
          - dbt_checks.null_ratio_below:
              arguments:
                value: 0.02
```

This allows business rules to be expressed directly in schema files without writing custom SQL.

---

# Validation Categories

The package currently provides several categories of validation checks.

## Numeric Checks

Validate numeric ranges and thresholds.

Examples:

* non-negative values
* bounded metrics
* threshold validation

---

## String Checks

Validate textual fields and formats.

Examples:

* blank values
* regex validation
* prefixes and suffixes
* string length validation

---

## Temporal Checks

Validate dates and timestamps.

Examples:

* freshness validation
* future date detection
* date interval validation

---

## Aggregation Checks

Validate dataset-level metrics.

Examples:

* row counts
* sums
* averages
* minimum and maximum values

---

## Ratio Checks

Validate proportions of rows matching a condition.

Examples:

* null ratios
* positive value ratios
* business-event ratios

---

## Multi-column Checks

Validate relationships between columns.

Examples:

* equality validation
* comparison validation
* consistency validation

---

## Conditional Checks

Validate dependency-based business rules.

Examples:

* required fields when a condition is met
* workflow consistency checks
* conditional completeness validation

---

## Rule Composition Checks

Compose custom business rules using SQL expressions.

Examples:

* financial consistency rules
* contactability rules
* workflow validation

---

# Key Features

## Grouped Validation

Several checks support segmented validation through `group_by`.

Examples:

```yaml
group_by: country
```

```yaml
group_by:
  - country
  - sales_channel
```

This allows validations to run independently for each segment.

---

## Standardized Failure Outputs

Checks expose contextual debugging information.

Examples include:

* failing values
* actual vs expected metrics
* grouped context
* trigger conditions
* failed expressions

The goal is to make failures easier to debug in CI and stored failure tables.

---

## Validation Guards

Argument validation is performed during compilation whenever possible.

Examples:

* invalid ranges
* invalid ratios
* invalid dates
* invalid grouped configurations
* invalid expression lists

This helps catch configuration errors before SQL execution.

---

## Adapter Compatibility

Warehouse-specific behavior is isolated through reusable helper macros and dbt dispatch.

Current compatibility targets include:

* DuckDB
* Postgres
* BigQuery
* Snowflake
* Databricks
* Spark
* Redshift

---

# Documentation

Detailed documentation is available in:

* `checks.md`
* `grouped-checks.md`
* `conditional-checks.md`
* `rule-composition.md`
* `architecture.md`
* `ci.md`
* `examples.md`

---

# Project Goals

The long-term goals of `dbt-checks` are:

* reusable validation patterns
* expressive business-rule validation
* warehouse portability
* maintainable data quality enforcement
* CI-friendly observability
* contributor-friendly OSS development
* dbt ecosystem compatibility

The package aims to remain lightweight while supporting practical real-world data quality use cases.

---

## Related Documentation

* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Rule Composition](rule-composition.md)
* [Architecture](architecture.md)
* [Examples](examples.md)
* [CI](ci.md)
