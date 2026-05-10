# Changelog

All notable changes to this project will be documented in this file.

The format follows semantic versioning.

---

## [0.3.5] - 2026-05-10

### Added
- Table of Contents for improved navigation
- Real-world usage pattern examples
- Scoped validation examples using `where`
- Production adoption recommendations
- Warehouse compatibility matrix
- Documentation for:
  - NULL handling behavior
  - empty table behavior
  - ratio division safety
  - validation guard behavior
- Additional standardized failure output examples

### Changed
- Expanded README with production-oriented guidance
- Improved failure output documentation
- Improved severity rollout guidance
- Improved installation and usage documentation
- Clarified edge case behavior across check categories
- Improved readability and structure of documentation

### Notes
- No macro behavior changes
- No SQL generation changes
- No breaking changes
- Fully compatible with previous `0.3.x` releases

---

## [0.3.4] - 2026-05-10

### Added
- Documentation for native dbt severity configuration
- Examples for:
  - `severity: warn`
  - `severity: error`
  - `warn_if`
  - `error_if`
  - CI usage with `--warn-error`
- Integration tests covering:
  - warning severity behavior
  - error severity behavior
  - `warn_if` behavior
  - `error_if` behavior

### Changed
- Improved README guidance for production adoption
- Added recommended rollout strategy for new checks

### Notes
- This release does not change test macro behavior
- dbt-checks relies on native dbt severity handling
- No breaking changes

---

## [0.3.3] - 2026-05-10

### Added
- Compile-time validation guards for invalid test configurations
- Validation helpers for:
  - numeric bounds
  - ratio bounds
  - integer arguments
  - boolean arguments
  - required strings
  - date expressions
  - ISO date range validation

### Changed
- All configurable tests now validate arguments before SQL generation
- Invalid configurations now fail during dbt compilation with explicit error messages

### Examples of detected invalid configurations
- `min_value > max_value`
- ratios outside `0..1`
- invalid integer arguments
- invalid boolean values
- empty required strings
- invalid date ranges for ISO date literals

### Notes
- SQL date expressions such as `current_date` remain supported
- ISO date literals are validated more strictly when possible

---

## [0.3.2] - 2026-05-10

### Added
- Internal helper macros for reusable casting, filtering, predicates, dates, and ratios
- Shared helpers:
  - `as_numeric`
  - `as_string`
  - `as_date`
  - `safe_ratio`
  - `apply_where`
  - `applied_condition`
  - reusable predicate builders

### Changed
- Refactored numeric, string, temporal, aggregation, and ratio checks to use shared helper macros
- Reduced duplicated SQL across test macros
- Improved maintainability and consistency of generated SQL

### Notes
- This release is internal and does not change the public test API
- No breaking changes

---

## [0.3.1] - 2026-05-10

### Added
- Standardized failure outputs across all checks
- Human-readable failure context for CI and debugging
- Consistent output schema for:
  - row-level checks
  - aggregation checks
  - ratio checks
  - temporal checks
- Explicit failure metadata:
  - `failed_check`
  - `failure_reason`
  - `applied_condition`
- Contextual expected values in failure outputs:
  - `expected_min_value`
  - `expected_max_value`
  - `expected_min_ratio`
  - `expected_max_ratio`
  - `expected_min_date`
  - `expected_max_date`
  - `expected_pattern`
  - `expected_prefix`
  - `expected_suffix`
  - `expected_substring`
- Additional debugging context:
  - `actual_value`
  - `actual_ratio`
  - `actual_length`
  - `actual_diff_days`
  - `actual_day_of_week`

### Changed
- Standardized internal naming conventions:
  - `check_value`
  - `metric_value`
  - `metric_ratio`
- Removed remaining `select *` usage from test macros
- Improved consistency across all check families:
  - numeric
  - string
  - temporal
  - aggregation
  - ratio
- CI now stores and exposes enriched failure outputs
- GitHub Actions summary now displays formatted failing rows

### CI
- Added validation to ensure:
  - all `should_pass` tests pass
  - all `should_fail` tests fail
- Added regression checks preventing:
  - `select *` usage
  - missing standardized failure columns
- Added `dbt parse` validation
- Added enriched failure output reporting via `--store-failures`
- Upload dbt artifacts for debugging:
  - `target/`
  - `logs/`

### Docs
- Added standardized failure output documentation
- Added examples for:
  - row-level failure outputs
  - aggregation failure outputs
  - ratio failure outputs
  - filtered checks using `where`

### Notes
- This release focuses on developer experience, CI readability, and debugging clarity
- Failure outputs are now designed to be machine-readable and CI-friendly
- This release establishes the failure output contract used by future grouped and advanced checks

---

## [0.3.0] - 2026-05-07

### Added
- Add optional `where` argument to all checks
- Allow checks to be applied to filtered subsets of data
- Add integration tests for filtered validation scenarios

### Changed
- Test macros now apply validation after an optional row filter

### Notes
- This enables scoped data quality rules such as validating only active records, recent partitions, or specific categories.

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