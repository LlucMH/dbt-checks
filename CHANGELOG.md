# Changelog

All notable changes to this project will be documented in this file.

The format follows semantic versioning.

---

## [0.2.2] - 2026-03-30

### Fixed
- Fix `test_date_diff_less_than` doc

---

## [0.2.1] - 2026-03-30

### Fixed
- Improve formatting of YAML examples in documentation
- Use proper Markdown code blocks for better readability in dbt docs

### Changed
- Standardize example rendering across all test documentation

---

## [0.2.0] - 2026-03-30

### Added

- Documentation blocks (`{% docs %}`) for all generic tests
- Macro-level documentation via `schema.yml`
- Argument documentation for all tests
- Domain-based organization:
  - aggregation
  - numeric
  - string
  - temporal
  - ratio

### Changed

- Improved project structure for scalability and maintainability
- Enhanced developer experience when browsing dbt docs

### CI

- Stabilized integration testing workflow
- Clear separation between `should_pass` and `should_fail` tests

---

## [0.1.0] - 2026-03-10

### Added

Initial release of **dbt-checks**.

#### Numeric checks

- non_negative
- non_positive
- greater_than
- greater_or_equal_than
- less_than
- less_or_equal_than
- between_values

#### String checks

- not_blank
- length_between
- matches_regex
- starts_with
- ends_with
- contains

#### Temporal checks

- not_future_date
- not_before_date
- between_dates
- recent_date
- date_diff_less_than
- no_weekend_dates

#### Aggregation checks

- row_count_greater_than
- row_count_less_than
- row_count_between
- sum_between
- avg_between
- max_between
- min_between

#### Ratio checks

- null_ratio_below
- null_ratio_between
- positive_ratio_between
- negative_ratio_between
- value_ratio_between

#### Infrastructure

- Integration test project
- CI pipeline using GitHub Actions
- Cross-warehouse support using dbt dispatch