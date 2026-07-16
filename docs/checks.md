# Checks

This document provides an overview of the validation checks available in `dbt-checks`.

Detailed syntax, arguments, and examples are available in dbt Docs.

---

# Numeric Checks

Validate numeric values against thresholds and ranges.

Available checks:

* `non_negative`
* `non_positive`
* `greater_than`
* `greater_or_equal_than`
* `less_than`
* `less_or_equal_than`
* `between_values`

Common use cases:

* monetary values
* quantities
* percentages
* scores
* KPI validation

---

# String Checks

Validate text fields, identifiers, and formatted values.

Available checks:

* `not_blank`
* `length_between`
* `matches_regex`
* `starts_with`
* `ends_with`
* `contains`

Common use cases:

* email validation
* identifier formats
* code validation
* naming conventions

---

# Temporal Checks

Validate dates and timestamps.

Available checks:

* `not_future_date`
* `not_before_date`
* `between_dates`
* `recent_date`
* `date_diff_less_than`
* `no_weekend_dates`

Common use cases:

* freshness monitoring
* SLA validation
* event tracking
* operational reporting

---

# Aggregation Checks

Validate model-level metrics.

Available checks:

* `row_count_greater_than`
* `row_count_less_than`
* `row_count_between`
* `sum_between`
* `avg_between`
* `min_between`
* `max_between`

Common use cases:

* volume monitoring
* KPI validation
* anomaly detection
* business controls

---

# Ratio Checks

Validate proportions, completeness metrics, distributions and relative cardinality.

Available checks:

* `null_ratio_below`
* `null_ratio_between`
* `positive_ratio_between`
* `negative_ratio_between`
* `value_ratio_between`
* `distinct_ratio_between`

Common use cases:

* completeness monitoring
* quality thresholds
* event distribution monitoring
* duplicate detection
* key quality monitoring
* ingestion monitoring

---

# Multi-column Checks

Validate relationships between columns in the same row.

Available checks:

* `columns_equal`
* `columns_distinct`
* `column_greater_than_column`
* `column_less_than_column`

Common use cases:

* financial validation
* consistency checks
* business rule enforcement

---

# Related Documentation

Additional documentation is available in:

* `grouped-checks.md`
* `conditional-checks.md`
* `rule-composition.md`
* `architecture.md`
* dbt Docs

---

# dbt Docs

The recommended source of truth for:

* arguments
* examples
* macro metadata
* detailed behavior

is the generated dbt Docs site.

Generate documentation with:

```bash
dbt docs generate
dbt docs serve
```

---

## Related Documentation

* [Overview](overview.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Rule Composition](rule-composition.md)
* [Architecture](architecture.md)
* [Examples](examples.md)
* [CI](ci.md)
