# Contributing to dbt-checks

Thank you for considering contributing to **dbt-checks**.

`dbt-checks` is an open-source package focused on reusable and business-oriented data quality validations for dbt projects.

The goal of the project is to provide:
- simple and expressive checks
- standardized failure outputs
- reusable validation patterns
- cross-warehouse compatibility
- production-friendly debugging

Contributions, feedback, bug reports, and ideas are welcome.

---

# Development setup

Clone the repository:

```bash
git clone https://github.com/LlucMH/dbt-checks.git
cd dbt-checks
```

Install dbt and adapter dependencies:

```bash
pip install dbt-core dbt-duckdb
```

---

# Running integration tests

The repository includes an integration dbt project under:

```text
integration_tests/
```

This project validates:
- check behavior
- grouped validations
- edge cases
- NULL handling
- CI compatibility

Run integration tests with:

```bash
cd integration_tests

dbt deps
dbt seed
dbt run
dbt test
```

---

# Project structure

```text
macros/
  tests/
  helpers/

integration_tests/
  models/
  seeds/

docs/
```

Main areas:

| Directory | Purpose |
| --- | --- |
| `macros/tests` | Validation checks |
| `macros/helpers` | Reusable internal helpers |
| `integration_tests` | Integration test project |
| `docs` | Package documentation |

---

# Adding a new check

When adding a new check:

1. Implement the macro under `macros/tests`
2. Reuse helper macros whenever possible
3. Add integration tests under `integration_tests`
4. Add or update documentation
5. Ensure outputs follow package conventions

---

# Validation philosophy

`dbt-checks` focuses on:

- reusable business validations
- readable APIs
- standardized outputs
- predictable NULL handling
- grouped validation support
- CI-friendly debugging

Please try to keep new contributions aligned with these principles.

---

# Code style guidelines

## General

- Keep macros simple and readable
- Prefer reusable helpers over duplicated logic
- Avoid adapter-specific SQL unless necessary
- Prefer composable helper macros

---

## Validation outputs

Checks should expose consistent failure outputs whenever possible.

Common output fields include:

- `failing_value`
- `actual_value`
- `expected_min_value`
- `expected_max_value`
- `failed_check`
- `failure_reason`
- `applied_condition`
- `grouped_by_*`

---

## NULL handling

Most checks ignore NULL values by default.

If a check behaves differently:
- document it clearly
- add integration coverage

---

# Documentation requirements

New checks should include:

- `{% docs %}` documentation blocks
- README updates when relevant
- examples
- argument descriptions
- NULL-handling behavior
- failure output examples

---

# Testing expectations

New checks should include integration coverage for:

- passing cases
- failing cases
- NULL handling
- `where` support
- grouped validation support (if applicable)
- edge cases
- empty table behavior (if applicable)

---

# Compatibility expectations

`dbt-checks` aims to support multiple dbt adapters through dbt dispatch.

When possible:
- avoid warehouse-specific SQL
- reuse centralized helpers
- preserve adapter compatibility

Current CI coverage primarily uses DuckDB.

---

# Reporting bugs

If you find a bug, please open a GitHub issue including:

- dbt version
- adapter version
- package version
- reproduction steps
- expected behavior
- actual behavior

---

# Feature requests

Feature requests are welcome.

Please include:
- use case
- expected behavior
- example configuration
- reasoning/business context

---

# Pull requests

When opening a PR:

- keep changes focused
- include tests
- Update documentation if needed:
  - docs/
  - docs blocks
  - schema.yml metadata
- ensure CI passes

Small, incremental improvements are preferred over very large PRs.

---

# Questions & support

For:
- questions
- ideas
- discussions
- bug reports
- feature proposals

please use GitHub Issues or Discussions.

---

Thank you for contributing to `dbt-checks`.