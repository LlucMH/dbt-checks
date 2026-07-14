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

It is split into two jobs:

- `repo-governance` — adapter-independent checks (documentation, macro
  structure, community health files). Runs once.
- `integration-tests` — a matrix over supported adapters, each leg calling
  the `adapter-integration-tests.yml` reusable workflow.

The workflow validates the package using the integration test project under:

```text
integration_tests/
```

---

# Adapter Matrix

`integration-tests` runs as a matrix (`.github/workflows/ci.yml`) over:

```text
duckdb
postgres
bigquery
snowflake
databricks
```

Each matrix leg calls the reusable workflow
`.github/workflows/adapter-integration-tests.yml` with the adapter name as
input. The reusable workflow:

- installs `dbt-core` plus the adapter-specific package (`dbt-duckdb`,
  `dbt-postgres`, `dbt-bigquery`, `dbt-snowflake`, or `dbt-databricks`)
- selects the matching dbt target via the `DBT_TARGET` env var, resolved
  against `integration_tests/profiles.yml` and
  `integration_tests_invalid_configs/profiles.yml` (which define a `dev`
  DuckDB target, a `postgres` target, a `bigquery` target, a `snowflake`
  target, and a `databricks` target)
- for the Postgres leg, starts a `postgres:16` service container for the
  job to connect to
- runs the full integration + invalid-config suite identically against
  whichever adapter it was called with
- prints stored failure rows to the job summary using an adapter-specific
  script (direct DuckDB file query, `psycopg2` against
  `information_schema` for Postgres, the `google-cloud-bigquery` client
  against `INFORMATION_SCHEMA.TABLES` for BigQuery,
  `snowflake-connector-python` against `information_schema.tables` for
  Snowflake, or `databricks-sql-connector` against `information_schema.tables`
  for Databricks)

This keeps the adapter-dependent steps in one place, so adding another
adapter to the matrix means adding a matrix entry plus install/target
wiring, not duplicating the whole pipeline.

## BigQuery CI

Unlike DuckDB (local) and Postgres (service container), BigQuery requires a
real Google Cloud project and a service account with BigQuery permissions.

The BigQuery CI leg is gated and only runs when the required repository
configuration is available.

Required configuration:

- Repository variable: `BIGQUERY_PROJECT`
- Repository secret: `GCP_SA_KEY`

The service account JSON key is written to a temporary key file during the
workflow and used to authenticate the BigQuery adapter.

When these values are not configured, the BigQuery CI leg is skipped rather
than failed. This allows the remaining CI suite to succeed while keeping the
workflow ready for future BigQuery validation.

## Snowflake CI

Like BigQuery, Snowflake has no free local equivalent, so the leg requires a
real Snowflake account.

The Snowflake CI leg is gated and only runs when the required repository
configuration is available.

Required configuration:

- Repository variable: `SNOWFLAKE_ACCOUNT`
- Repository secret: `SNOWFLAKE_PASSWORD`

Optional configuration (repository variables): `SNOWFLAKE_USER`,
`SNOWFLAKE_ROLE`, `SNOWFLAKE_DATABASE` (defaults to `dbt_checks`),
`SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_SCHEMA` (defaults to `public`).

When these values are not configured, the Snowflake CI leg is skipped rather
than failed, the same way the BigQuery leg is gated above.

## Databricks CI

Like BigQuery and Snowflake, Databricks has no free local equivalent, so the
leg requires a real Databricks workspace with a SQL warehouse or
all-purpose cluster.

The Databricks CI leg is gated and only runs when the required repository
configuration is available.

Required configuration:

- Repository variable: `DATABRICKS_HOST`
- Repository secret: `DATABRICKS_TOKEN`

Optional configuration (repository variables): `DATABRICKS_HTTP_PATH`,
`DATABRICKS_CATALOG`, `DATABRICKS_SCHEMA` (defaults to `default`).

When these values are not configured, the Databricks CI leg is skipped
rather than failed, the same way the BigQuery and Snowflake legs are gated
above.

---

# Validation Steps

Each adapter leg of the integration-tests job performs the following steps:

```text
Checkout repository
      ↓
Set up Python
      ↓
Install dbt + adapter package
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

The `repo-governance` job runs its documentation, macro, and community
health checks independently of the adapter matrix.

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

- BigQuery CI leg fully exercised once GCP credentials are configured
  (currently wired but gated — see "BigQuery CI" above)
- Snowflake CI leg fully exercised once Snowflake credentials are configured
  (currently wired but gated — see "Snowflake CI" above)
- Databricks CI leg fully exercised once Databricks credentials are
  configured (currently wired but gated — see "Databricks CI" above)
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
