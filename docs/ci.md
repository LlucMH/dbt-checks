# CI

This document describes the CI strategy used by `dbt-checks`.

The goal of the CI pipeline is to validate:

- package installation
- dbt parsing
- integration test execution
- expected pass/fail behavior
- documentation generation
- repository governance
- OSS community health files

---

# CI Goals

The CI pipeline is designed to ensure that `dbt-checks` remains:

- reliable
- reproducible
- contributor-friendly
- release-ready
- safe to evolve

CI should catch both functional regressions and repository governance regressions.

---

# Main CI Workflow

The main workflow runs on:

- pull requests
- pushes to `main`

The workflow validates the package using the integration test project under:

```text
integration_tests/
```

---

# Validation Steps

The CI pipeline typically performs the following steps:

```text
Checkout repository
      ↓
Set up Python
      ↓
Install dbt dependencies
      ↓
Run dbt deps
      ↓
Run dbt parse
      ↓
Run invalid configuration checks
      ↓
Run seeds
      ↓
Run models
      ↓
Run passing tests
      ↓
Run expected failing tests
      ↓
Validate stored failure outputs
      ↓
Run dbt compile
      ↓
Run dbt docs generate
      ↓
Upload artifacts
```

---

# Integration Tests

Integration tests validate package behavior against a real dbt project.

They cover:

- passing checks
- failing checks
- edge cases
- null handling
- grouped validations
- conditional checks
- rule composition checks
- multi-column checks
- `where` filters
- validation guards

---

# Expected Pass / Fail Strategy

`dbt-checks` uses tagged tests to validate both success and failure behavior.

Typical tags include:

```text
should_pass
should_fail
```

## Passing tests

Tests tagged `should_pass` must pass.

## Failing tests

Tests tagged `should_fail` are expected to fail.

This validates that checks correctly detect invalid data.

---

# Invalid Configuration Tests

The CI pipeline validates compile-time argument guards through a dedicated invalid configuration project.

These tests ensure invalid configurations fail during compilation.

Examples:

- invalid numeric ranges
- invalid ratio ranges
- invalid date ranges
- invalid expression lists
- invalid grouped configurations

This helps catch configuration errors before SQL execution.

---

# Stored Failure Outputs

CI stores failure outputs for failing tests.

This validates that checks expose useful debugging information such as:

- `failing_value`
- `actual_value`
- `actual_ratio`
- `failed_check`
- `failure_reason`
- `applied_condition`
- `grouped_by_*`

These outputs are designed to improve CI debugging and stored failure inspection.

---

# Documentation Validation

CI runs:

```bash
dbt docs generate
```

This validates that:

- docs blocks compile
- macro metadata is valid
- schema documentation is usable
- dbt Docs can be generated successfully

---

# Governance Validation

The CI pipeline also validates repository governance files.

Examples:

- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `SUPPORT.md`
- issue templates
- pull request template

This helps keep the repository contributor-ready.

---

# Community Health Validation

GitHub community health files are validated to ensure the repository keeps a consistent OSS collaboration structure.

Expected files include:

```text
.github/ISSUE_TEMPLATE/bug_report.yml
.github/ISSUE_TEMPLATE/feature_request.yml
.github/ISSUE_TEMPLATE/config.yml
.github/PULL_REQUEST_TEMPLATE.md
```

---

# Artifacts

When CI runs, dbt artifacts may be uploaded for debugging.

Common artifacts include:

```text
target/
logs/
run_results.json
manifest.json
```

These artifacts help inspect failures after CI runs.

---

# Future CI Improvements

Planned future improvements include:

- multi-adapter CI
- Postgres validation
- BigQuery validation
- Snowflake validation
- Databricks validation
- Spark validation
- Redshift validation
- dbt version matrix
- package installation validation
- release workflow validation
- compatibility matrix generation

---

## Related Documentation

* [Overview](overview.md)
* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Rule Composition](rule-composition.md)
* [Architecture](architecture.md)
* [Examples](examples.md)
