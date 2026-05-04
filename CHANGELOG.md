# Changelog

All notable changes to this project will be documented in this file.

The format follows semantic versioning.

---

## [0.2.6] - 2026-05-04

### Added
- Comprehensive edge case validation across all test macros
- New integration test suites covering:
  - empty tables (empty_tables)
  - type casting scenarios (type_casting)
  - extreme values (extreme_values)
  - boundary conditions (boundary_values)
- Full coverage across all check families:
  - numeric
  - string
  - temporal
  - aggregation
  - ratio
- Validation of strict vs inclusive behavior for comparison-based tests
- Temporal edge case coverage including:
  - current date boundaries
  - weekday/weekend validation
  - date differences and limits

### Changed
- Improved robustness of test macros under edge conditions
- Standardized behavior when handling:
  - empty datasets
  - mixed-type columns
  - boundary values in comparisons

### Fixed
- Cross-database type issues in string and temporal tests
- Inconsistent behavior when applying functions to non-typed columns
- Errors caused by implicit type inference in edge scenarios
- Issues in no_weekend_dates when handling derived columns

### CI
- Expanded CI to validate all edge case scenarios
- Ensures consistent behavior across adapters and data shapes

### Notes
- Edge case handling is now explicitly validated and stable
- Seeds are not used for edge cases to guarantee type control and reproducibility

---

## [0.2.5] - 2026-05-03

### Added
- Consistent NULL handling strategy across all checks
- Explicit NULL validation via:
  - `null_ratio_below`
  - `null_ratio_between`

### Changed
- Most checks now ignore NULL values by default
- NULL validation is no longer implicit and must be handled explicitly
- Ratio-based checks provide the primary mechanism for controlling NULL behavior

### Fixed
- Inconsistent behavior when columns contained NULL values
- Ambiguous results caused by implicit NULL handling across different tests

### Docs
- Added dedicated section explaining NULL handling strategy
- Clarified how each check behaves in the presence of NULL values

### Notes
- NULL handling is now explicit and predictable
- Users should use ratio-based checks to control NULL-related constraints

### Breaking Changes
- Standarized comparison checks to use `value`argument:
  - greater_than
  - greater_or_equal_than
  - less_than
  - less_or_equal_than
  - row_count_greater_than
  - row_count_less_than

Previous arguments like `min_value` or `threshold`are no longer supported.

---

## [0.2.4] - 2026-04-04

### Fixed
- Stabilize CI behavior for `should_pass` and `should_fail` integration tests
- Ensure documentation compiles correctly with `dbt docs generate`
- Clean repository from local development artifacts

### Changed
- Improve CI pipeline with documentation validation
- Refine `.gitignore` for better repository hygiene
- Improve README structure and usage clarity
- Validate installation from tagged releases


---

## [0.2.3] - Skipped

### Notes
- Version skipped due to CI failure before realise

---

## [0.2.2] - 2026-03-30

### Added
- Full documentation for all tests

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