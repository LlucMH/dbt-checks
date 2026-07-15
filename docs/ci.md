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

It is split into the following jobs:

- `repo-governance` — adapter-independent checks (documentation, macro
  structure, community health files). Runs once.
- `clean-installation-validation` — installs the package via `git:` into a
  temporary consumer project, the same way real consumers do (see "Clean
  Installation Validation" below).
- `integration-tests` — a matrix over supported adapters, each leg calling
  the `adapter-integration-tests.yml` reusable workflow.
- `performance-smoke-tests` — a DuckDB/Postgres-only matrix calling the
  `performance-smoke-tests.yml` reusable workflow (see "Performance Smoke
  Tests" below).
- `dbt-core-version-matrix` — a DuckDB-only matrix over the minimum
  supported and latest stable dbt Core versions, calling the
  `dbt-version-matrix.yml` reusable workflow (see "dbt Core Version Matrix"
  below).

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
spark
redshift
```

Each matrix leg calls the reusable workflow
`.github/workflows/adapter-integration-tests.yml` with the adapter name as
input. The reusable workflow:

- installs `dbt-core` plus the adapter-specific package (`dbt-duckdb`,
  `dbt-postgres`, `dbt-bigquery`, `dbt-snowflake`, `dbt-databricks`,
  `dbt-spark[PyHive]`, or `dbt-redshift`) via a single "Install dbt" step
  that switches on `inputs.adapter` — one centralized mapping instead of a
  separate step per adapter
- selects the matching dbt target via the `DBT_TARGET` env var, resolved
  against `integration_tests/profiles.yml` and
  `integration_tests_invalid_configs/profiles.yml` (which define a `dev`
  DuckDB target, a `postgres` target, a `bigquery` target, a `snowflake`
  target, a `databricks` target, a `spark` target, and a `redshift`
  target)
- for the Postgres leg, starts a `postgres:16` service container for the
  job to connect to
- runs the full integration + invalid-config suite identically against
  whichever adapter it was called with
- prints stored failure rows to the job summary via
  [`.github/scripts/print_stored_failures.py`](../.github/scripts/print_stored_failures.py),
  a single script (not a per-adapter inline heredoc) that dispatches on
  `--adapter` to the matching connection logic: a direct DuckDB file query,
  `psycopg2` against `information_schema` for Postgres and Redshift
  (Redshift is Postgres-wire-compatible, so both share one helper), the
  `google-cloud-bigquery` client against `INFORMATION_SCHEMA.TABLES` for
  BigQuery, `snowflake-connector-python` against `information_schema.tables`
  for Snowflake, `databricks-sql-connector` against
  `information_schema.tables` for Databricks, or `PyHive` against a Thrift
  server's `SHOW TABLES` for Spark. Each adapter's driver import stays local
  to its own function, since a given CI leg only has that one driver
  installed.

This keeps the adapter-dependent steps in one place, so adding another
adapter to the matrix means adding a matrix entry, an install mapping entry,
and a `list_*` function in `print_stored_failures.py` — not duplicating the
whole pipeline.

The five cloud adapter legs (BigQuery, Snowflake, Databricks, Spark,
Redshift) are each gated behind a `check-*-configuration` job in
`.github/workflows/ci.yml` that checks whether the adapter's repository
variable and secret are both set. All five call the same shared composite
action, [`.github/actions/check-credentials`](../.github/actions/check-credentials/action.yml),
with the adapter's variable/secret names as inputs — the gating logic itself
is defined once, not five times.

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

## Spark CI

Unlike the DuckDB and Postgres legs, the Spark leg targets a standalone
Spark cluster over its Thrift server (the common non-Databricks production
deployment for `dbt-spark`), so it requires a reachable cluster rather than
a disposable service container.

The Spark CI leg is gated and only runs when the required repository
configuration is available.

Required configuration:

- Repository variable: `SPARK_HOST`
- Repository secret: `SPARK_PASSWORD`

Optional configuration (repository variables): `SPARK_PORT` (defaults to
`10000`), `SPARK_USER` (defaults to `dbt_checks`), `SPARK_SCHEMA` (defaults
to `default`).

When these values are not configured, the Spark CI leg is skipped rather
than failed, the same way the BigQuery, Snowflake, and Databricks legs are
gated above.

## Redshift CI

Like the other cloud warehouses, Redshift has no free local equivalent, so
the leg requires a real Redshift cluster or Redshift Serverless workgroup.
`dbt-redshift` connects over the Postgres wire protocol, so this leg reuses
the same `psycopg2`-based failure-output script as the Postgres leg.

The Redshift CI leg is gated and only runs when the required repository
configuration is available.

Required configuration:

- Repository variable: `REDSHIFT_HOST`
- Repository secret: `REDSHIFT_PASSWORD`

Optional configuration (repository variables): `REDSHIFT_PORT` (defaults
to `5439`), `REDSHIFT_USER` (defaults to `dbt_checks`), `REDSHIFT_DB`
(defaults to `dbt_checks`), `REDSHIFT_SCHEMA` (defaults to `public`).

When these values are not configured, the Redshift CI leg is skipped
rather than failed, the same way the other cloud warehouse legs are gated
above.

---

# Performance Smoke Tests

`performance-smoke-tests` runs as a matrix (`.github/workflows/ci.yml`) over:

```text
duckdb
postgres
```

calling the reusable workflow `.github/workflows/performance-smoke-tests.yml`.
It is unconditional (no credential gating) since both targets are always
available in CI.

**These are smoke tests, not a warehouse benchmark.** CI only has a local
DuckDB file and a disposable Postgres service container available, so results
say nothing about behavior on a production-sized cloud warehouse. The goal is
narrower: catch pathological SQL generation and confirm the grouped
validation architecture still behaves at larger row volumes and higher
`group_by` cardinality before it ships, not to produce comparable timing
numbers across releases or adapters.

## Scenarios

Synthetic data is generated with `generate_series` (no seed files, so this
doesn't bloat the repo) under `integration_tests/models/performance/`, tagged
`performance_smoke`:

- 100k rows, ungrouped (`perf_volume_100k`)
- 1M rows, ungrouped (`perf_volume_1m`)
- 100 groups (`perf_cardinality_100_groups`)
- 1,000 groups (`perf_cardinality_1k_groups`)
- a two-column `group_by` across 200 combinations
  (`perf_multi_column_group_by`)

Each scenario is an exact, deterministic grid (a `generate_series` cross
join, not modular-arithmetic tricks), so the checks below use tight bounds
instead of loose tolerances.

## Checks

The scenarios prioritize the check families most exercised by grouped and
aggregate validation: `row_count_between`, `sum_between`, `avg_between`,
`null_ratio_between`, `value_ratio_between`, and `recent_date` with
`group_by` (including multi-column `group_by`).

All performance tests are tagged `performance_smoke` only — deliberately
**not** `should_pass` — so they never run as part of the adapter matrix.
`adapter-integration-tests.yml`'s "Run test models" step explicitly excludes
`tag:performance_smoke`, so the cloud adapter legs (BigQuery, Snowflake,
Databricks, Spark, Redshift) never build these tables.

## What the job reports

For each of `dbt compile`, `dbt run`, and `dbt test` (all `--select
tag:performance_smoke`):

- wall-clock time and per-node `execution_time` from `run_results.json`

Then, for the compiled SQL of the performance models and their tests:

- **generated SQL size** — line and byte counts per compiled file
- **repeated scan detection** — how many times the source model name appears
  in its own compiled test SQL (the helper macros in `macros/helpers/` build
  a single `with validation as (...)` CTE per check, so this is expected to
  be exactly 1)
- **CTE count** — how many CTEs each compiled test defines

And, where available, an `EXPLAIN` plan for one representative ungrouped
aggregation test and one representative grouped aggregation test.

All of this is written to the GitHub Actions job summary, the same way
enriched failure outputs are for the adapter matrix.

## Review finding

As part of adding this tooling, `macros/helpers/aggregation.sql`,
`macros/helpers/ratio.sql`, and the generated SQL for `row_count_between`,
`avg_between`, `value_ratio_between`, and `recent_date` were reviewed
directly: every check already compiles to a single scan of the source model
through one CTE chain, with no redundant CTEs or repeated scans. No macro
changes were needed — this release adds the CI tooling to keep it that way
going forward.

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
- performance smoke scenarios (see "Performance Smoke Tests" below)

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

# dbt Core Version Matrix

`dbt-core-version-matrix` runs as a matrix (`.github/workflows/ci.yml`) over:

```text
minimum-supported  (dbt-core 1.5.0, matching require-dbt-version in dbt_project.yml)
latest-stable       (dbt-core 1.11.7, the version used by every adapter leg above)
```

calling the reusable workflow `.github/workflows/dbt-version-matrix.yml`,
unconditionally, against DuckDB only — DuckDB is free and local, so this
adds no credential dependency, and the point of this matrix is to validate
compatibility with dbt Core itself, not with a specific warehouse (that's
what the Adapter Matrix above is for).

By design, this does **not** test every intermediate dbt Core release
between 1.5.0 and 1.11.7 — only the two ends of the supported range, unless
a specific regression gives reason to pin an intermediate version.

## Why a separate fixture project

This matrix runs against
[`integration_tests_dbt_version_matrix/`](../integration_tests_dbt_version_matrix/),
not the main `integration_tests/` project. The main project's schema.yml
files use the `data_tests:` key, introduced in dbt Core 1.8 — a
project-author schema.yml syntax choice unrelated to whether dbt-checks'
own macros run correctly under a given dbt Core version. Using it here would
make the minimum-supported leg fail on a dbt Core parser limitation that has
nothing to do with the package. `integration_tests_dbt_version_matrix/`
instead uses the older `tests:` key, which has been valid dbt Core syntax
since long before 1.5.0 and remains valid (deprecated) through 1.11.x, so
the same fixture parses under both ends of the matrix.

The fixture is intentionally minimal: one model, two column-level
`non_negative` checks (one tagged `should_pass`, one tagged `should_fail`),
enough to exercise package install, macro dispatch, a validation guard, real
query execution, and both pass/fail detection — not a re-run of the full
integration suite.

---

# Clean Installation Validation

`clean-installation-validation` (`.github/workflows/ci.yml`) validates the
installation path real consumers use — installing via `git:` in
`packages.yml` — rather than the `local: ..` path every other CI job uses.

From a temporary consumer project scaffolded during the job (not checked
into the repo), it runs:

```text
dbt deps    (installs dbt-checks from git, pinned to the commit under test)
dbt parse
dbt docs generate
```

The `packages.yml` revision is the PR head commit
(`github.event.pull_request.head.sha`) on `pull_request` events, falling
back to `github.sha` on pushes to `main` — `github.sha` alone would resolve
to GitHub's synthetic PR merge commit on `pull_request` events, which is not
reliably fetchable by a plain `git clone` of the canonical repository.

**Known limitation:** this clones `https://github.com/LlucMH/dbt-checks.git`
directly, so it only validates commits already reachable on that
repository's branches. A pull request opened from a fork would need to be
merged (or its branch pushed to the canonical repository) before this job
can resolve its commit.

---

# Future CI Improvements

Planned future improvements include:

- BigQuery CI leg fully exercised once GCP credentials are configured
  (currently wired but gated — see "BigQuery CI" above)
- Snowflake CI leg fully exercised once Snowflake credentials are configured
  (currently wired but gated — see "Snowflake CI" above)
- Databricks CI leg fully exercised once Databricks credentials are
  configured (currently wired but gated — see "Databricks CI" above)
- Spark CI leg fully exercised once a reachable Spark cluster is configured
  (currently wired but gated — see "Spark CI" above)
- Redshift CI leg fully exercised once Redshift credentials are configured
  (currently wired but gated — see "Redshift CI" above)
- release workflow validation

See [Known Limitations](known-limitations.md) for limitations that are
explicit trade-offs rather than open work.

---

## Related Documentation

* [Overview](overview.md)
* [Checks](checks.md)
* [Grouped Checks](grouped-checks.md)
* [Conditional Checks](conditional-checks.md)
* [Rule Composition](rule-composition.md)
* [Architecture](architecture.md)
* [Known Limitations](known-limitations.md)
* [Examples](examples.md)
