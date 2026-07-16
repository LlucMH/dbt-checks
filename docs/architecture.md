# Architecture

This document describes the internal architecture of `dbt-checks`.

The package is designed around a small set of reusable abstractions that provide:

* consistent SQL generation
* predictable failure outputs
* adapter compatibility
* maintainability
* extensibility

---

# Design Principles

The architecture follows several core principles:

## Reuse over duplication

Checks should reuse internal helper macros whenever possible.

Instead of implementing warehouse-specific SQL repeatedly, checks delegate behavior to reusable helper layers.

---

## Standardized outputs

Checks expose consistent failure outputs to improve:

* debugging
* CI visibility
* observability
* stored failure inspection

A user should not need to learn a different failure structure for every check.

---

## Adapter compatibility

Warehouse-specific behavior is isolated through helper macros and dbt dispatch.

This minimizes adapter-specific logic inside individual checks.

---

## Compile-time validation

Invalid configurations should fail during compilation whenever possible.

Examples:

* invalid ranges
* invalid ratios
* empty required arguments
* invalid group definitions

This reduces runtime surprises.

---

# High-Level Architecture

```text
Check Macro
     │
     ▼
Validation Guards
     │
     ▼
Helper Macros
     │
     ▼
Adapter Dispatch
     │
     ▼
Warehouse SQL
```

Each layer has a specific responsibility.

---

# Check Layer

Checks define the business validation itself.

Examples:

* between_values
* recent_date
* null_ratio_between
* require_when

Checks should remain thin and delegate implementation details to helper macros.

Example responsibilities:

* select inputs
* call validation guards
* call reusable predicates
* expose standardized outputs

---

# Validation Layer

Validation guards perform compile-time argument validation.

Examples include:

* required argument validation
* ratio validation
* numeric range validation
* date range validation
* group_by validation

Examples:

```text
min_value > max_value
min_ratio > max_ratio
invalid group_by definitions
```

These validations fail before SQL execution.

---

# Helper Layer

The helper layer contains reusable SQL generation logic.

Examples:

## Casting Helpers

Used to standardize type handling.

Examples:

* as_numeric()
* as_string()
* as_date()

---

## Predicate Builders

Used to generate reusable validation predicates.

Examples:

* numeric comparisons
* temporal comparisons
* ratio predicates

---

## Grouping Helpers

Used by grouped checks.

Examples:

* grouped aggregation logic
* grouped output generation
* grouped aliases

---

## Output Helpers

Used to standardize failure outputs.

Examples:

* failed_check
* failure_reason
* applied_condition
* grouped_by_*

---

# Temporal Architecture

Temporal checks use centralized date helpers.

Examples:

* cast_to_date()
* as_date()
* build_date_between_predicate()
* build_not_before_date_predicate()

These helpers support:

* static ISO dates
* dynamic SQL expressions
* adapter-specific rendering

Examples:

```text
2024-01-01
current_date
current_date - interval '7 days'
```

This avoids duplicating temporal logic across checks.

---

# Grouped Validation Architecture

Grouped checks reuse the same core implementations as non-grouped checks.

The architecture extends validations by introducing a grouping layer.

```text
Base Validation
      │
      ▼
Grouping Helpers
      │
      ▼
Segmented Validation
      │
      ▼
Grouped Outputs
```

Supported categories:

* aggregation checks
* ratio checks
* freshness checks

Grouped outputs expose context through:

```text
grouped_by_country
grouped_by_status
grouped_by_sales_channel
```

For complex expressions, stable aliases are generated automatically.

---

# Standardized Failure Outputs

All checks attempt to expose contextual debugging information.

Examples:

## Row-Level Checks

```text
failing_value
expected_min_value
failed_check
failure_reason
```

## Aggregation Checks

```text
actual_value
expected_min_value
expected_max_value
```

## Ratio Checks

```text
actual_ratio
expected_min_ratio
expected_max_ratio
```

## Conditional Checks

```text
trigger_condition
required_condition
```

This architecture improves:

* CI debugging
* observability
* stored failures
* operational support

---

# Adapter Compatibility

dbt-checks relies on dbt dispatch to support multiple warehouses.

Current target adapters include:

* DuckDB
* Postgres
* BigQuery
* Snowflake
* Databricks
* Spark
* Redshift

The architecture attempts to isolate adapter-specific behavior behind helper macros instead of individual checks.

---

# Extending the Package

When implementing a new check:

1. Add compile-time validation if needed
2. Reuse helper macros whenever possible
3. Reuse existing output patterns
4. Add integration tests
5. Document behavior
6. Consider grouped support when applicable

A new check should generally fit into the existing architecture rather than introducing new patterns.

---

# Future Architecture Areas

Planned future areas include:

* uniqueness metrics
* duplicate observability
* advanced grouped validation abstractions
* expanded adapter compatibility
* dbt Fusion compatibility

`distinct_ratio_between` (added in 0.8.0) covers relative-cardinality
monitoring, and `distinct_count_between` (added in 0.8.1) covers absolute
distinct-count validation, reusing the same `distinct_count_expression`
helper for the shared `count(distinct column_name)` metric; row-level
uniqueness enforcement and duplicate observability tooling remain future
work.

The goal is to keep the public API simple while allowing internal architecture to evolve as the package grows.

---

## Related Documentation

* [Overview](overview.md)
* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Rule Composition](rule-composition.md)
* [Examples](examples.md)
* [CI](ci.md)
