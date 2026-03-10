# Changelog

All notable changes to this project will be documented in this file.

The format follows semantic versioning.

---

## [0.1.0] - 2026-03-10

### Added

- Initial release of **dbt-checks**
- Numeric checks:
  - `non_negative`
  - `non_positive`
  - `greater_than`
  - `less_than`
  - `between_values`
- String checks:
  - `not_blank`
  - `length_between`
  - `matches_regex`
- Temporal checks:
  - `not_future_date`
  - `recent_date`
- Aggregation checks:
  - `row_count_greater_than`
  - `row_count_between`
- Ratio checks:
  - `null_ratio_below`
- Integration test project
- CI pipeline using GitHub Actions