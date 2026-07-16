# Changelog

All notable changes to this project will be documented in this file.

The format follows semantic versioning.

---

## [0.8.1] - 2026-07-16

### Added

#### `distinct_count_between`

Added a new aggregation check, `dbt_checks.distinct_count_between`, which
validates that the cardinality of a column (`count(distinct column_name)`)
falls within a `min_value` / `max_value` range (inclusive). It follows the
same shape as the other checks in `macros/tests/aggregation/`: standardized
`actual_distinct_count` / `expected_min_value` / `expected_max_value` failure
output, `group_by` (including multi-column grouping), a `where` argument, and
compile-time validation of `min_value` / `max_value` as non-negative
integers via the existing `validate_non_negative_integer` helper.

NULL values are excluded from the count, matching standard SQL
`count(distinct ...)` semantics. A column with no non-NULL values (including
an empty table, or a group whose values are all NULL) reports a distinct
count of `0` rather than NULL, so — unlike `sum_between`, `avg_between`,
`min_between`, and `max_between` — this check needs no `metric_value is null`
fallback in its failure predicate, and no `where column_name is not null`
pre-filter in its validation CTE (pre-filtering would have dropped
all-NULL groups from the result entirely instead of reporting `0`).

Extended the shared aggregation helper architecture in
`macros/helpers/aggregation.sql` rather than introducing a new one: added a
`count_distinct` aggregation type to `render_aggregation_metric` and
`build_aggregation_validation_cte`, so `distinct_count_between` is a thin
test macro on top of the same `build_aggregation_validation_cte` used by
`avg_between` / `max_between`.

Introduced a single shared helper, `distinct_count_expression`, that renders
the bare `count(distinct column_name)` expression. `render_aggregation_metric`
uses it directly for `distinct_count_between`'s `metric_value`, and
`calculate_distinct_ratio_cte` (in `macros/helpers/ratio.sql`) now calls the
same helper for its numerator instead of duplicating the expression inline.
This keeps `distinct_count_between` and `distinct_ratio_between` computing
cardinality from one source of truth, and gives the rest of the 0.8.x
distinctness/duplicate-check series (`duplicate_count_between`,
`duplicate_ratio_between`, `unique_combination_ratio_between`) a reusable
foundation to build on. Required no adapter-specific dispatch overrides,
since `count(distinct ...)` is standard SQL across all seven target adapters.

Use cases: duplicate detection, key quality monitoring, ingestion
monitoring, and event integrity — complementing `distinct_ratio_between`'s
relative-cardinality measure with an absolute distinct-count check for
cases where the expected cardinality is a known, stable number (for example,
a fixed set of countries or categories) rather than a proportion of table
size.

#### Documentation

Documented the new check in `macros/docs/aggregation_docs.md` and
`macros/tests/aggregation/_schema.yml`, and added it to the aggregation
check listings in `docs/checks.md`, `docs/overview.md`, and the "Grouped
Aggregation Checks" section of `docs/grouped-checks.md`. Updated
`docs/architecture.md`'s "Future Architecture Areas" note to reflect that
`distinct_count_between` now covers absolute distinct-count validation
alongside `distinct_ratio_between`'s relative-cardinality measure; row-level
uniqueness enforcement and duplicate observability tooling remain future
work.

#### Integration tests

Added integration coverage under `integration_tests/`: a standard
valid/invalid pair with a dedicated deterministic seed, single- and
multi-column grouped checks (including a `where`-scoped grouped case and a
grouped case with NULL column values), NULL-column handling (including an
all-NULL column, reusing the existing `distinct_ratio_between` NULL
fixtures), an empty-table case, and a `where`-scoped case. Added
compile-time validation guard fixtures (`min_value > max_value`, a
non-integer `min_value`, and an empty `column_name`) to
`integration_tests_invalid_configs/`.

### Changed

- Bumped package version to `0.8.1` per `VERSIONING.md` (adding a new check
  is a MINOR change).

---

## [0.8.0] - 2026-07-16

### Added

#### `distinct_ratio_between`

Added a new ratio check, `dbt_checks.distinct_ratio_between`, which validates
that the ratio of distinct values in a column
(`count(distinct column_name) / count(column_name)`) falls within a
`min_ratio` / `max_ratio` range. It follows the same shape as the other
checks in `macros/tests/ratio/`: standardized `actual_ratio` /
`expected_min_ratio` / `expected_max_ratio` failure output, `group_by`
(including multi-column grouping), a `where` argument, and
division-by-zero-safe handling of empty/all-NULL inputs via the existing
`safe_ratio` helper.

NULL handling intentionally differs from the rest of the ratio checks.

Unlike the existing ratio checks, which all use `count(*)` as their
denominator, `distinct_ratio_between` uses `count(column_name)`, excluding
NULL values from both the numerator and the denominator. Whether NULL values
contribute to the numerator of the existing ratio checks depends on the
metric itself (for example, `null_ratio_*` intentionally counts NULL values,
while other ratio checks do not).

This behavior is deliberate. Pairing `count(distinct column_name)` with
`count(*)` would allow a column containing many NULL values to report an
artificially low distinct ratio even when every non-NULL value is unique,
which is the opposite of what duplicate-detection and key-quality use cases
need.

A column containing no non-NULL values (including an empty table) safely
reports a ratio of `0` rather than raising a division-by-zero error.

Added a matching helper, `calculate_distinct_ratio_cte`, in
`macros/helpers/ratio.sql`, alongside the existing `calculate_ratio_cte`.
Reuses `validate_required_column`, `validate_ratio_bounds`, and
`validate_group_by` for compile-time argument validation, and required no
adapter-specific dispatch overrides since `count(distinct ...)` is standard
SQL across all seven target adapters.

Use cases: duplicate detection, key quality monitoring, ingestion
monitoring, and event integrity — complementing absolute distinct-count
validation (an `aggregation`-style check) with a relative-cardinality
measure that stays meaningful as table size changes, and that can surface
duplication trends when compared over time or across `group_by` segments.

#### Documentation

Documented the new check in `macros/docs/ratio_docs.md` and
`macros/tests/ratio/_schema.yml`, and added it to the ratio check listings
in `docs/checks.md`, `docs/overview.md`, and the "Grouped Ratio Checks"
section of `docs/grouped-checks.md`. Removed "distinctness metrics" from
`docs/architecture.md`'s "Future Architecture Areas" now that it is
delivered; "uniqueness metrics" (row-level uniqueness enforcement) and
"duplicate observability" tooling remain future work.

#### Integration tests

Added integration coverage under `integration_tests/`: a standard
valid/invalid pair, single- and multi-column grouped checks, NULL-column
handling (including an all-NULL column), an empty-table case, and a
`where`-scoped case. Added compile-time validation guard fixtures
(`min_ratio > max_ratio`, an out-of-range ratio, and an empty
`column_name`) to `integration_tests_invalid_configs/`.

### Changed

- Bumped package version to `0.8.0` per `VERSIONING.md` (adding a new check
  is a MINOR change).

### Breaking Changes

- None.

---

## [0.7.7] - 2026-07-15

This is the closing release of the 0.7.x compatibility/audit series. It does
not add another cross-adapter dialect audit — all seven adapters were
already audited between 0.7.0 and 0.7.5 — and instead consolidates the CI
architecture built up across that series and closes the remaining gaps in
what it actually validates.

### Added

#### dbt Core Version Matrix

Added `integration_tests_dbt_version_matrix/`, a minimal fixture project
(one model, two column-level `non_negative` checks) separate from the main
`integration_tests/` project. It exists specifically because the main
project's schema.yml files use the `data_tests:` key (dbt Core 1.8+), which
would fail to parse under dbt Core 1.5.0 for reasons unrelated to whether
dbt-checks' own macros work under that version. This fixture uses the
older `tests:` key instead, which is valid dbt Core syntax across the whole
1.5.0–1.11.x range.

Added `.github/workflows/dbt-version-matrix.yml`, a reusable workflow that
runs `dbt deps`, `dbt parse`, `dbt run`, `dbt test` (both `should_pass` and
`should_fail`), `dbt compile`, and `dbt docs generate` against that fixture
on DuckDB. Wired into `.github/workflows/ci.yml` as a new
`dbt-core-version-matrix` job, matrixed over two legs:

- `minimum-supported` — dbt-core 1.5.0, dbt-duckdb 1.5.2 (matching
  `require-dbt-version` in `dbt_project.yml`)
- `latest-stable` — dbt-core 1.11.7, dbt-duckdb 1.10.1 (matching every
  other adapter leg's existing pin)

Deliberately does not test intermediate dbt Core releases — only the two
ends of the supported range. Both legs were run locally against a real
`dbt-core==1.5.0`/`dbt-duckdb==1.5.2` install (Python 3.11, matching CI's
pinned Python version — dbt-core 1.5.0 requires `distutils`, removed in
Python 3.12) before being wired into CI, to confirm the package's macros
actually work under the version floor the package claims to support, not
just that the pin resolves.

#### Clean Installation Validation

Added a `clean-installation-validation` job to `.github/workflows/ci.yml`
that scaffolds a temporary consumer project (not checked into the repo) and
runs `dbt deps`, `dbt parse`, and `dbt docs generate` against it, installing
`dbt-checks` via `packages.yml`'s `git:` + `revision:` syntax — the same
installation path documented in `README.md` and used by real consumers.
Every other CI job installs the package via `packages: - local: ..`, which
never exercised the git-clone install path at all.

The revision pinned is the PR head commit
(`github.event.pull_request.head.sha`) on `pull_request` events, falling
back to `github.sha` on pushes to `main` — `github.sha` alone resolves to
GitHub's synthetic PR merge commit on `pull_request` events, which is not
reliably fetchable by a plain `git clone` of the canonical repository.
Verified locally against the current `main` HEAD commit before being wired
into CI.

#### Known Limitations Documentation

Added `docs/known-limitations.md`, documenting explicitly:

- Postgres/Redshift's strict ISO 8601-only `try_cast_to_date`/
  `try_cast_to_timestamp` (narrower than DuckDB/Snowflake's native
  try-cast)
- cloud adapter CI legs (BigQuery, Snowflake, Databricks, Spark, Redshift)
  require credentials and are skipped, not failed, without them
- Spark's `try_cast` requires Spark 3.2+
- "dialect audited" is not "live tested" — an audit is a manual review
  against vendor documentation, not an execution against a real warehouse
- regex engine and escaping differences across all seven adapters (POSIX
  `~` on DuckDB/Postgres/Redshift vs. `regexp_like`/`regexp_contains` with
  backslash-escaping on Snowflake/BigQuery/Databricks/Spark)
- performance smoke tests run on CI-scale DuckDB/Postgres only, and are not
  comparable across releases or adapters

Linked from `README.md` and `docs/README.md`.

### Changed

#### Adapter Capability Table

Replaced the single-column adapter status table in `README.md` ("Fully
tested in CI" / "Dialect-audited; CI wired, pending X credentials") with an
explicit three-column table — Dialect audited / CI wired / Live tested —
so each of the three claims can be verified independently instead of being
folded into one prose string per adapter.

#### CI Workflow Consolidation

Reviewed `.github/workflows/ci.yml` and
`.github/workflows/adapter-integration-tests.yml` for duplication called
out across the 0.7.x series and centralized what was safely centralizable:

- **Credential-gating jobs**: the five `check-{bigquery,snowflake,
  databricks,spark,redshift}-configuration` jobs each re-implemented the
  same "is this variable and this secret both set?" bash logic. Extracted
  into a shared composite action,
  `.github/actions/check-credentials/action.yml`, taking `var-value`,
  `secret-value`, and `adapter-name` as inputs. Each of the five jobs is now
  a two-line call into it instead of an inline script. (GitHub Actions job
  `outputs` don't merge cleanly across matrix legs of a single job, which is
  why this is five jobs calling one action rather than one matrixed job —
  the five separate `needs:`/`if:` gates on the five `*-integration-tests`
  jobs depend on five distinct outputs.)
- **Adapter package installation mapping**: the seven `Install dbt (X)`
  steps in `adapter-integration-tests.yml`, each a near-identical `if:
  inputs.adapter == 'X'` guard around one `pip install` line, were
  collapsed into a single `Install dbt` step with a bash `case` statement
  keyed on `inputs.adapter`.
- **Stored-failure reporting scripts**: the seven per-adapter inline Python
  heredocs (~500 lines total) that queried `information_schema` and
  rendered stored failure rows to the job summary were extracted into
  `.github/scripts/print_stored_failures.py`, a single script dispatching
  on `--adapter`. The Postgres and Redshift heredocs were byte-for-byte
  identical logic under different env var names (Redshift is
  Postgres-wire-compatible) and now share one `_list_psycopg2` helper.
  Adapter-specific driver imports (`duckdb`, `psycopg2`,
  `google-cloud-bigquery`, `snowflake-connector-python`,
  `databricks-sql-connector`, `pyhive`) stay local to each adapter's own
  function, since a given CI leg only has its own driver installed.
  Verified against a real DuckDB stored-failures database (generated by
  running the actual integration suite locally) before being wired into
  CI; the Postgres/Redshift path was verified by code inspection only (no
  local Postgres instance available) since the extracted logic is an exact
  transcription of the original, parameterized.

Reviewed but left unchanged: the per-adapter `env:` block in
`adapter-integration-tests.yml` is already the single centralized home for
every adapter's connection variables (that's what the reusable workflow is
for) — there was nothing further to consolidate there. The credential
repository-variable/secret *names* themselves (`BIGQUERY_PROJECT`,
`GCP_SA_KEY`, etc.) still live in `ci.yml`, `adapter-integration-tests.yml`,
and `docs/ci.md` — collapsing that mapping further would mean generating
one of those from the other, which is out of scope for this release.

#### Repo Governance Checks

Added checks to `repo-governance` in `.github/workflows/ci.yml`:
`docs/known-limitations.md` existence and its README link, the three
adapter capability table headers ("Dialect audited" / "CI wired" / "Live
tested"), and the existence of the new CI consolidation files
(`dbt-version-matrix.yml`, `check-credentials/action.yml`,
`print_stored_failures.py`, `integration_tests_dbt_version_matrix/`) — so
this release's own claims stay enforced going forward, the same way every
other documentation/architecture claim in this repository already is.

### Notes

- No SQL generation changes.
- No macro behavior changes.
- No API changes.
- No existing test behavior changes — the stored-failure reporting output
  format is unchanged (same markdown tables, same job summary target); only
  where the code that produces it lives has changed. One cosmetic wording
  change: the DuckDB leg now prints "No stored failure tables found."
  instead of "No DuckDB database found." when no failures were stored, for
  consistency with the other six adapters.
- See [Known Limitations](docs/known-limitations.md) for what this release
  documents as explicit trade-offs rather than open work.

### Breaking Changes

- None.

---

## [0.7.6] - 2026-07-15

### Added

#### Performance Smoke Tests

Added `integration_tests/models/performance/`: five synthetic data models
generated with `generate_series` (no seed files, so this doesn't bloat the
repo), each an exact deterministic grid rather than a randomized or
modular-arithmetic dataset:

- `perf_volume_100k` / `perf_volume_1m` — 100k and 1M ungrouped rows
- `perf_cardinality_100_groups` / `perf_cardinality_1k_groups` — 100k rows
  across 100 groups and 200k rows across 1,000 groups
- `perf_multi_column_group_by` — 100k rows grouped by a two-column
  `[region, category]` `group_by` (200 combinations)

`integration_tests/models/performance/_schema.yml` applies the check
families most exercised by grouped and aggregate validation against these
scenarios: `row_count_between`, `sum_between`, `avg_between`,
`null_ratio_between`, `value_ratio_between`, and `recent_date` with
`group_by` (single- and multi-column). All 21 checks pass against exact,
hand-derived bounds rather than loose tolerances.

Every model and check is tagged `performance_smoke` only (deliberately not
`should_pass`), so it never runs as part of the existing adapter matrix.

#### Performance Smoke CI Job

Added `.github/workflows/performance-smoke-tests.yml`, a new reusable
workflow following the same matrix + `workflow_call` pattern as
`adapter-integration-tests.yml`, wired into `.github/workflows/ci.yml` as a
new `performance-smoke-tests` job running unconditionally over `duckdb` and
`postgres` (no credential gating needed — both targets are always available
in CI).

The job runs `dbt compile`, `dbt run`, and `dbt test` against
`tag:performance_smoke`, each timed, then reports to the job summary:

- per-node execution time (from `run_results.json`)
- generated SQL size (lines/bytes), CTE count, and a repeated-scan count per
  compiled node (identified via `manifest.json`, not filename matching —
  dbt truncates and hashes long compiled test filenames, which would
  otherwise silently miss nodes)
- an `EXPLAIN` plan, where available, for one representative ungrouped
  aggregation test and one representative grouped aggregation test

### Changed

#### Adapter Matrix Exclusion

Changed the "Run test models" step in
`.github/workflows/adapter-integration-tests.yml` from `dbt run` to `dbt run
--exclude tag:performance_smoke`, so the cloud adapter legs (BigQuery,
Snowflake, Databricks, Spark, Redshift) never build the 1M-row table. Every
`dbt test` invocation in that workflow was already tag-selected, so no
further change was needed to keep performance tests off those legs.

### Notes

- **These are performance smoke tests, not a warehouse benchmark.** CI only
  has a local DuckDB file and a disposable Postgres service container
  available, so results say nothing about behavior on a production-sized
  cloud warehouse. The goal is to catch pathological SQL generation and
  confirm the grouped validation architecture holds up at larger row volumes
  and higher `group_by` cardinality before release — not to produce
  comparable timing numbers across releases or adapters.
- As part of adding this tooling, `macros/helpers/aggregation.sql`,
  `macros/helpers/ratio.sql`, and the generated SQL for `row_count_between`,
  `avg_between`, `value_ratio_between`, and `recent_date` were reviewed
  directly: every check already compiles to a single scan of the source
  model through one CTE chain, with no redundant CTEs or repeated scans. No
  macro changes were needed.
- No SQL generation changes.
- No macro behavior changes.
- No API changes.
- No existing test behavior changes — `dbt_checks_row_count_between_perf_*`
  and friends are new tests in `integration_tests` only, not part of the
  package's public macro surface.

### Breaking Changes

- None.

---

## [0.7.5] - 2026-07-14

### Changed

#### Redshift Adapter Audit

Reviewed `macros/helpers/adapters/redshift.sql` and the shared grouping,
dispatch, casting, and predicate helpers for Redshift SQL dialect
correctness:

- `redshift__try_cast_to_date`/`_timestamp` already used Redshift's native
  `try_cast`, so unparseable input already returned `NULL` rather than
  raising — this was already fixed in 0.7.0 alongside the Postgres
  `try_cast` gap, no further changes needed here.
- `redshift__current_date_sql`/`current_timestamp_sql`/`dateadd_days`/
  `datediff_days` already used correct native syntax in the shared
  `(start, end) -> end - start` convention — no changes needed.
- `redshift__day_of_week_sun0` already correctly used Redshift's
  `date_part(dow, expr)` with an unquoted `dow` keyword — Redshift's
  `DATE_PART` diverges from Postgres's (which requires the datepart as a
  quoted string literal, e.g. `date_part('dow', ...)`) but returns the
  same 0-indexed Sunday convention; no changes needed.
- `group_by_alias` already strips double quotes, so Redshift-quoted
  `group_by` columns (`"col"`) alias correctly.
- Grouped checks (aggregation, ratio, freshness) rely only on `GROUP BY`
  over `SELECT`-list expressions/aliases, which Redshift supports
  natively — no changes needed to `macros/helpers/grouping.sql`,
  `aggregation.sql`, or `ratio.sql` for Redshift compatibility.

#### Gated Redshift CI Leg

Added a `redshift` entry to the `integration-tests` matrix in
`.github/workflows/ci.yml`, reusing the same
`adapter-integration-tests.yml` workflow as the other adapters. Like the
other cloud warehouses, Redshift has no free local equivalent, so the leg
requires a real Redshift cluster or Redshift Serverless workgroup.

The matrix job is gated on the `REDSHIFT_HOST` repository variable and
`REDSHIFT_PASSWORD` repository secret both being set; until they're
configured, the leg is **skipped** (not failed), so CI stays green. Once
configured, the reusable workflow installs `dbt-redshift`, runs the
identical integration + invalid-config suite, and prints stored failure
rows via `psycopg2` against `information_schema` — reusing the same
script as the Postgres leg, since Redshift is Postgres-wire-compatible.

`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `redshift`
target alongside the existing DuckDB, Postgres, BigQuery, Snowflake,
Databricks, and Spark targets.

### Fixed

#### Redshift regex_match Escaping

Fixed `redshift__regex_match` in `macros/helpers/adapters/redshift.sql`.
The macro previously interpolated `pattern` directly into a single-quoted
string literal; an unescaped `'` in `pattern` would terminate the literal
early. Unlike Snowflake/BigQuery/Databricks/Spark, Redshift is
Postgres-derived and runs with `standard_conforming_strings` on by
default, so backslash is not a special character in a regular string
literal — doubling any existing backslashes (as those other adapters
require) would have corrupted patterns like `\d`. The macro now only
doubles embedded `'` characters (standard SQL quote-escaping), leaving
backslashes untouched.

### Notes

- Macro behavior change: `redshift__regex_match` now escapes embedded `'`
  characters in `pattern` before interpolation; previously-compiling
  patterns containing `'` will now compile to different (correct) SQL.
  Patterns without a `'` are unaffected.
- No other macro API or SQL generation changes.
- `README.md`'s Redshift compatibility status is "Dialect-audited; CI
  wired, pending Redshift credentials", not "Fully tested in CI" — the CI
  leg is not yet exercised against a real Redshift cluster in this
  repository.
- All seven adapters listed in `README.md`'s compatibility matrix
  (DuckDB, Postgres, BigQuery, Snowflake, Databricks, Spark, Redshift)
  have now been dialect-audited; DuckDB and Postgres are fully tested in
  CI, and the remaining five are wired but gated pending real warehouse
  credentials.

### Breaking Changes

- None.

---

## [0.7.4] - 2026-07-14

### Changed

#### Spark Adapter Audit

Reviewed `macros/helpers/adapters/spark.sql` and the shared grouping,
dispatch, casting, and predicate helpers for Apache Spark SQL dialect
correctness. Unlike `dbt-databricks`, which always talks to Databricks
Runtime, `dbt-spark` can also reach plain Apache Spark clusters over the
Thrift, HTTP, ODBC, or (local) session connection methods, so functions
outside core Spark SQL cannot be assumed available:

- `spark__day_of_week_sun0` already correctly shifted Spark's
  1 (Sunday) - 7 (Saturday) `dayofweek()` result to the shared 0-indexed
  Sunday convention — no fix needed.
- `spark__dateadd_days`/`datediff_days` already used core Spark SQL's
  `date_add`/`datediff` functions in the same `(start, end) -> end - start`
  convention as the other adapters — no changes needed.
- `group_by_alias` already strips backticks alongside double quotes, so
  Spark-quoted `group_by` columns (`` `col` ``) alias correctly.
- Grouped checks (aggregation, ratio, freshness) rely only on `GROUP BY`
  over `SELECT`-list expressions/aliases, which Spark SQL supports
  natively — no changes needed to `macros/helpers/grouping.sql`,
  `aggregation.sql`, or `ratio.sql` for Spark compatibility.

#### Gated Spark CI Leg

Added a `spark` entry to the `integration-tests` matrix in
`.github/workflows/ci.yml`, reusing the same
`adapter-integration-tests.yml` workflow as the other adapters. The leg
targets a standalone Spark cluster over its Thrift server — the common
non-Databricks production deployment — rather than a disposable service
container, since there is no lightweight way to stand up a full Spark
Thrift server in CI.

The matrix job is gated on the `SPARK_HOST` repository variable and
`SPARK_PASSWORD` repository secret both being set; until they're
configured, the leg is **skipped** (not failed), so CI stays green. Once
configured, the reusable workflow installs `dbt-spark[PyHive]`, connects
over Thrift with LDAP auth, runs the identical integration + invalid-config
suite, and prints stored failure rows via `PyHive`'s `SHOW TABLES ... LIKE`
against the configured schema.

`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `spark`
target alongside the existing DuckDB, Postgres, BigQuery, Snowflake, and
Databricks targets.

### Fixed

#### Spark regex_match Escaping

Fixed `spark__regex_match` in `macros/helpers/adapters/spark.sql`. Spark
SQL string literals share Databricks SQL's escaping rules (a fixed set of
recognized escapes; unrecognized sequences like `\d` pass through
verbatim), so the same bug applied here as `databricks__regex_match`
before 0.7.3: an unescaped `'` in `pattern` terminated the literal early,
and a pattern ending in a bare `\` would consume the closing quote. The
macro now backslash-escapes `\` and `'` before interpolation, the same
transform applied to `bigquery__regex_match` (0.7.1), `snowflake__regex_match`
(0.7.2), and `databricks__regex_match` (0.7.3).

#### Spark try_cast Portability

Fixed `spark__try_cast_to_date` and `spark__try_cast_to_timestamp` in
`macros/helpers/adapters/spark.sql`. Both previously called
`try_to_date()`/`try_to_timestamp()`, which are Databricks Runtime SQL
functions, not core Apache Spark SQL — they're unavailable on a plain
Spark cluster reached via the Thrift/ODBC/Livy connection methods
`dbt-spark` also supports. Both macros now use `try_cast(expr as date)`/
`try_cast(expr as timestamp)` instead, added in Spark 3.2 and portable
across `dbt-spark`'s supported connection methods, preserving the same
NULL-on-unparseable-input contract as before.

### Notes

- Macro behavior changes: `spark__regex_match` now escapes `pattern`
  before interpolation (previously-compiling patterns containing an
  unescaped `'` or a trailing bare `\` will now compile to different,
  correct SQL); `spark__try_cast_to_date`/`_timestamp` now use `try_cast`
  instead of `try_to_date`/`try_to_timestamp` (behaviorally equivalent —
  both return `NULL` on unparseable input — but `try_cast` is portable to
  non-Databricks Spark clusters that lack the Databricks-specific
  functions).
- No other macro API or SQL generation changes.
- `README.md`'s Spark compatibility status is "Dialect-audited; CI wired,
  pending Spark cluster credentials", not "Fully tested in CI" — the CI
  leg is not yet exercised against a real Spark cluster in this
  repository.

### Breaking Changes

- None.

---

## [0.7.3] - 2026-07-14

### Changed

#### Databricks Adapter Audit

Reviewed `macros/helpers/adapters/databricks.sql` and the shared grouping,
dispatch, casting, and predicate helpers for Databricks SQL dialect
correctness:

- `databricks__try_cast_to_date`/`_timestamp` already used native
  `try_cast`, so unparseable input already returned `NULL` rather than
  raising — no fix needed here.
- `databricks__day_of_week_sun0` already correctly shifted Databricks'
  1 (Sunday) - 7 (Saturday) `dayofweek()` result to the shared 0-indexed
  Sunday convention.
- `databricks__dateadd_days`/`datediff_days` already used Databricks'
  native `date_add`/`date_diff` functions with day-granularity arguments
  in the same `(start, end) -> end - start` convention as the other
  adapters — no changes needed.
- `group_by_alias` already strips backticks alongside double quotes, so
  Databricks-quoted `group_by` columns (`` `col` ``) alias correctly.
- Grouped checks (aggregation, ratio, freshness) rely only on `GROUP BY`
  over `SELECT`-list expressions/aliases, which Databricks SQL supports
  natively — no changes needed to `macros/helpers/grouping.sql`,
  `aggregation.sql`, or `ratio.sql` for Databricks compatibility.

#### Gated Databricks CI Leg

Added a `databricks` entry to the `integration-tests` matrix in
`.github/workflows/ci.yml`, reusing the same
`adapter-integration-tests.yml` workflow as the other adapters. Like
BigQuery and Snowflake, Databricks has no free local equivalent, so the
leg requires a real Databricks workspace with a SQL warehouse or cluster.

The matrix job is gated on the `DATABRICKS_HOST` repository variable and
`DATABRICKS_TOKEN` repository secret both being set; until they're
configured, the leg is **skipped** (not failed), so CI stays green. Once
configured, the reusable workflow installs `dbt-databricks`, runs the
identical integration + invalid-config suite, and prints stored failure
rows via the `databricks-sql-connector` client against
`information_schema.tables`.

`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `databricks`
target alongside the existing DuckDB, Postgres, BigQuery, and Snowflake
targets.

### Fixed

#### Databricks regex_match Escaping

Fixed `databricks__regex_match` in `macros/helpers/adapters/databricks.sql`.
The macro previously interpolated `pattern` directly into a single-quoted
string literal. Databricks SQL string literals only interpret a fixed set
of recognized escapes (leaving sequences like `\d` or `\s` verbatim), but
an unescaped `'` in `pattern` still terminated the literal early, and a
pattern ending in a bare `\` would consume the closing quote as an
(incorrectly) recognized `\'` escape. The macro now backslash-escapes `\`
and `'` before interpolation — the same transform applied to
`bigquery__regex_match` (0.7.1) and `snowflake__regex_match` (0.7.2) —
which round-trips ordinary regex escapes like `\d` correctly while closing
both holes.

### Notes

- Macro behavior change: `databricks__regex_match` now escapes `pattern`
  before interpolation; previously-compiling patterns containing an
  unescaped `'` or a trailing bare `\` will now compile to different
  (correct) SQL. Patterns without those characters are unaffected.
- No other macro API or SQL generation changes.
- `README.md`'s Databricks compatibility status is "Dialect-audited; CI
  wired, pending Databricks credentials", not "Fully tested in CI" — the CI
  leg is not yet exercised against a real Databricks workspace in this
  repository.
- Spark (`macros/helpers/adapters/spark.sql`) has the same unaudited
  `regex_match` escaping gap as Databricks did before this release, but is
  out of scope for this release; it remains "Planned validation".

### Breaking Changes

- None.

---

## [0.7.2] - 2026-07-14

### Changed

#### Snowflake Adapter Audit

Reviewed `macros/helpers/adapters/snowflake.sql` and the shared grouping,
dispatch, casting, and predicate helpers for Snowflake SQL dialect
correctness:

- `snowflake__try_cast_to_date`/`_timestamp` already used
  `try_to_date`/`try_to_timestamp`, so unparseable input already returned
  `NULL` rather than raising — no fix needed here (unlike the Postgres
  `try_cast` gap fixed in 0.7.0).
- `snowflake__day_of_week_sun0` already correctly mapped `dayname()`'s
  three-letter output to the shared 0-indexed Sunday convention via a
  `case` expression.
- `snowflake__dateadd_days`/`datediff_days` already used Snowflake's native
  `dateadd`/`datediff` functions with a `day` part — no changes needed.
- `group_by_alias` already strips double quotes alongside backticks, so
  Snowflake-quoted `group_by` columns (`"col"`) alias correctly.
- Grouped checks (aggregation, ratio, freshness) rely only on `GROUP BY`
  over `SELECT`-list expressions/aliases, which Snowflake supports
  natively — no changes needed to `macros/helpers/grouping.sql`,
  `aggregation.sql`, or `ratio.sql` for Snowflake compatibility.

#### Gated Snowflake CI Leg

Added a `snowflake` entry to the `integration-tests` matrix in
`.github/workflows/ci.yml`, reusing the same
`adapter-integration-tests.yml` workflow as the other adapters. Like
BigQuery, Snowflake has no free local equivalent, so the leg requires a
real Snowflake account.

The matrix job is gated on the `SNOWFLAKE_ACCOUNT` repository variable and
`SNOWFLAKE_PASSWORD` repository secret both being set; until they're
configured, the leg is **skipped** (not failed), so CI stays green. Once
configured, the reusable workflow installs `dbt-snowflake`, runs the
identical integration + invalid-config suite, and prints stored failure
rows via the `snowflake-connector-python` client against
`information_schema.tables`.

`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `snowflake`
target alongside the existing DuckDB, Postgres, and BigQuery targets.

### Fixed

#### Snowflake regex_match Escaping

Fixed `snowflake__regex_match` in `macros/helpers/adapters/snowflake.sql`.
The macro previously interpolated `pattern` directly into a single-quoted
string literal; Snowflake string literals interpret backslash escape
sequences by default, so a pattern containing `\d`, `\s`, or a literal `'`
would either compile to the wrong regex or break compilation entirely. The
macro now backslash-escapes `\` and `'` before interpolation, matching the
same fix applied to `bigquery__regex_match` in 0.7.1.

### Notes

- Macro behavior change: `snowflake__regex_match` now escapes `pattern`
  before interpolation; previously-compiling patterns containing `\` or `'`
  will now compile to different (correct) SQL. Patterns without those
  characters are unaffected.
- No other macro API or SQL generation changes.
- `README.md`'s Snowflake compatibility status is "Dialect-audited; CI
  wired, pending Snowflake credentials", not "Fully tested in CI" — the CI
  leg is not yet exercised against real Snowflake in this repository.

### Breaking Changes

- None.

---

## [0.7.1] - 2026-07-13

### Changed

#### BigQuery Adapter Audit

Reviewed `macros/helpers/adapters/bigquery.sql` and the shared grouping,
dispatch, casting, and predicate helpers for BigQuery Standard SQL dialect
correctness:

- `bigquery__try_cast_to_date`/`_timestamp` already used `safe_cast`, so
  unparseable input already returned `NULL` rather than raising — no fix
  needed here (unlike the Postgres `try_cast` gap fixed in 0.7.0).
- `bigquery__day_of_week_sun0` already correctly shifted BigQuery's
  1 (Sunday) - 7 (Saturday) `EXTRACT(DAYOFWEEK ...)` result to the shared
  0-indexed Sunday convention; documented this with an inline comment.
- `group_by_alias` already strips backticks alongside double quotes, so
  BigQuery-quoted `group_by` columns (`` `col` ``) alias correctly.
- Grouped checks (aggregation, ratio, freshness) rely only on `GROUP BY`
  over `SELECT`-list expressions/aliases, which BigQuery Standard SQL
  supports natively — no changes needed to `macros/helpers/grouping.sql`,
  `aggregation.sql`, or `ratio.sql` for BigQuery compatibility.

#### Gated BigQuery CI Leg

Added a `bigquery` entry to the `integration-tests` matrix in
`.github/workflows/ci.yml`, reusing the same
`adapter-integration-tests.yml` workflow as DuckDB and Postgres. Unlike
Postgres's disposable `postgres:16` service container, BigQuery has no free
local equivalent, so the leg requires a real GCP project and service
account.

The matrix job is gated on the `BIGQUERY_PROJECT` repository variable and
`GCP_SA_KEY` repository secret both being set; until they're configured,
the leg is **skipped** (not failed), so CI stays green. Once configured,
the reusable workflow installs `dbt-bigquery`, writes the service account
key to a keyfile, runs the identical integration + invalid-config suite,
and prints stored failure rows via the `google-cloud-bigquery` client
against `INFORMATION_SCHEMA.TABLES`.

`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `bigquery`
target alongside the existing DuckDB and Postgres targets.

### Fixed

#### BigQuery regex_match Escaping

Fixed `bigquery__regex_match` in `macros/helpers/adapters/bigquery.sql`.
The macro previously interpolated `pattern` directly into a raw string
literal (`r'{{ pattern }}'`); BigQuery raw strings still require the
delimiting quote character to be escaped and don't interpret backslashes,
so a pattern containing a literal `'` would break compilation or let
pattern content escape the string literal. The macro now backslash-escapes
`\` and `'` and emits a regular (non-raw) string literal instead, which
BigQuery parses unambiguously.

### Notes

- Macro behavior change: `bigquery__regex_match` now escapes `pattern`
  before interpolation; previously-compiling patterns containing `\` or `'`
  will now compile to different (correct) SQL. Patterns without those
  characters are unaffected.
- No other macro API or SQL generation changes.
- `README.md`'s BigQuery compatibility status is "Dialect-audited; CI
  wired, pending GCP credentials", not "Fully tested in CI" — the CI leg
  is not yet exercised against real BigQuery in this repository.

### Breaking Changes

- None.

---

## [0.7.0] - 2026-07-13
 
### Added
 
#### Multi-Adapter CI
 
Added a DuckDB/Postgres adapter matrix to the `integration-tests` job in
`.github/workflows/ci.yml`, with the adapter-dependent steps extracted into a
new reusable workflow at `.github/workflows/adapter-integration-tests.yml`
(`workflow_call`, parameterized by `adapter`).
 
Each matrix leg installs `dbt-core` plus the matching adapter package
(`dbt-duckdb` or `dbt-postgres`), runs the full integration and
invalid-config suite against either the existing DuckDB file target or a
`postgres:16` service container, and prints stored failure rows to the job
summary via an adapter-specific script (a direct DuckDB query, or
`psycopg2` against `information_schema` for Postgres).
 
`integration_tests/profiles.yml` and
`integration_tests_invalid_configs/profiles.yml` now define a `postgres`
target alongside the existing DuckDB `dev` target, selected at runtime via
the `DBT_TARGET` env var.
 
The former single `integration-tests` job is now split into
`repo-governance` (adapter-independent documentation, macro, and community
health checks, run once) and `integration-tests` (the adapter matrix), so
governance checks aren't duplicated per adapter.
 
### Changed
 
#### Postgres try_cast Fixes
 
Fixed `postgres__try_cast_to_date` and `postgres__try_cast_to_timestamp` in
`macros/helpers/adapters/postgres.sql`. Postgres has no native `TRY_CAST`:
`cast(x as date)` raises on invalid input instead of returning `NULL`, unlike
DuckDB's `try_cast`. Both macros now guard with a regex before casting, so
unparseable input returns `NULL` rather than raising — required for
`should_fail`-tagged tests to behave the same way on Postgres as on DuckDB.
This is narrower than DuckDB's try-cast, which accepts a wider range of date
formats; only strict ISO 8601 (`YYYY-MM-DD`, optionally with a time
component) is accepted.
 
Also switched `redshift__try_cast_to_date`/`_timestamp` in
`macros/helpers/adapters/redshift.sql` to use Redshift's native `try_cast`
instead of a raising `cast`.
 
#### Documentation
 
Updated `docs/ci.md` to describe the adapter matrix and reusable workflow
split, and moved Postgres validation out of "Future CI Improvements".
Updated `README.md`'s adapter compatibility table to mark Postgres "Fully
tested in CI".
 
### Notes
 
- No macro API changes. `postgres__try_cast_to_date`/`_timestamp` now return
  `NULL` on unparseable input instead of raising, matching DuckDB's
  try-cast semantics.
- No test behavior changes beyond the Postgres/Redshift try_cast fixes
  above.
 
### Breaking Changes
 
- None.
 
---
 
 
## [0.6.5] - 2026-07-12
 
### Changed
 
#### Release Automation
 
Changed `.github/workflows/release.yml` trigger from `push` (on
`dbt_project.yml` changes) to `workflow_run`, gated on the `CI` workflow
completing with `conclusion == 'success'` on `main`.
 
This ensures a release is never tagged or published unless the full CI
suite — integration tests, invalid-config guard rails, governance and
documentation checks — has passed on that exact commit.
 
Both jobs now check out `github.event.workflow_run.head_sha` explicitly,
so the release always corresponds to the commit CI actually validated,
not whatever `main` happens to point to when the workflow runs.
 
### Notes
 
- No SQL generation changes
- No macro behavior changes
- No API changes
- No test behavior changes
### Breaking Changes
 
- None.

---

## [0.6.4] - 2026-07-12
 
### Added
 
#### Versioning Policy
 
Added `VERSIONING.md` defining:
 
- what qualifies as a MAJOR, MINOR, or PATCH change
- how compile-time validation guards are treated under semver
- the deprecation process for breaking changes
- the release process
#### Release Automation
 
Added `.github/workflows/release.yml`:
 
- detects version changes in `dbt_project.yml` on push to `main`
- creates the matching `vX.Y.Z` tag
- publishes a GitHub Release generated from the corresponding `CHANGELOG.md` section
#### CI Governance
 
Added CI validation ensuring the version in `dbt_project.yml` has a matching
`CHANGELOG.md` entry before merging to `main`.
 
### Changed
 
- Linked `VERSIONING.md` from `README.md` (Community & Support) and
  `CONTRIBUTING.md` (Pull requests)
### Notes
 
- No SQL generation changes
- No macro behavior changes
- No API changes
- No test behavior changes
### Breaking Changes
 
- None.

---

## [0.6.3] - 2026-06-11

### Added

#### Visual Documentation

Added visual documentation assets under `docs/assets`:

- validation flow diagrams
- medallion quality strategy diagrams
- CI rollout strategy diagrams
- stored failures examples
- grouped validation examples
- dbt docs screenshots
- CI failure screenshots

These additions improve:

- onboarding
- discoverability
- OSS maturity
- contributor understanding
- recruiter readability

---

## [0.6.2] - 2026-06-01

### Added

#### Documentation Structure

Added a dedicated documentation directory:

- `docs/README.md`
- `docs/overview.md`
- `docs/checks.md`
- `docs/grouped-checks.md`
- `docs/conditional-checks.md`
- `docs/rule-composition.md`
- `docs/architecture.md`
- `docs/ci.md`
- `docs/examples.md`

#### Documentation Navigation

Added cross-links between documentation pages to improve navigation and discoverability.

Documentation pages now include related documentation sections.

#### Technical Documentation

Added dedicated documentation covering:

- package architecture
- grouped validation
- conditional validation
- rule composition
- CI workflows
- practical usage examples

#### Documentation Index

Added a centralized documentation index under:

```text
docs/README.md
```

to improve documentation discoverability.

### Changed

#### README Simplification

Refactored README to act as a project landing page.

Moved detailed documentation into the dedicated `/docs` directory.

README now focuses on:

- installation
- package overview
- validation categories
- supported warehouses
- community resources
- documentation navigation

#### Documentation Organization

Reorganized package documentation into topic-specific documents.

This improves:

- scalability
- maintainability
- contributor onboarding
- long-term project growth

### Notes

- No SQL generation changes
- No macro behavior changes
- No API changes
- No test behavior changes

### Breaking Changes

- None.

---

## [0.6.1] - 2026-05-28

### Added

#### GitHub Community Health

Added structured GitHub collaboration templates:

- issue templates
- bug report template
- feature request template
- pull request template

These additions improve:

- contributor onboarding
- issue standardization
- PR consistency
- maintainer workflows
- OSS collaboration experience

#### Repository Governance

Added GitHub community health repository structure:

- `.github/ISSUE_TEMPLATE`
- `PULL_REQUEST_TEMPLATE.md`

Added repository collaboration workflows for:

- bug reporting
- feature proposals
- pull request guidance
- contributor validation workflows

#### CI Governance Validation

Added CI validation for repository governance and collaboration templates.

CI now validates:

- issue templates
- pull request templates
- GitHub community health structure

This improves:

- repository consistency
- governance reliability
- OSS maintainability

#### README Improvements

Expanded README with:

- OSS collaboration guidance
- Community & Support section
- GitHub workflow guidance
- OSS maturity positioning
- contributor resources
- repository governance references

Added new badges:

- PRs welcome
- issues
- pull requests

### Changed

- Improved OSS contributor experience
- Improved repository governance workflows
- Improved collaboration tooling
- Improved maintainer ergonomics
- Improved issue triage consistency
- Improved pull request onboarding workflows
- Improved long-term OSS maintainability

### Notes

- No SQL generation changes
- No macro behavior changes
- No API changes
- Fully compatible with previous `0.6.0` release

### Breaking Changes

- None.

---

## [0.6.0] - 2026-05-27

### Added

#### OSS Repository Standards

Added foundational OSS repository governance files:

- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `SUPPORT.md`

These additions improve:

- contributor onboarding
- repository professionalism
- OSS maintainability
- security reporting workflows
- community expectations

#### Community & Governance

Added:

- contribution guidelines
- security disclosure guidance
- support expectations
- contributor behavior standards

#### README Improvements

Expanded README with:

- Features section
- OSS maturity section
- Community & Support section
- improved repository navigation
- improved package positioning

### Changed

- Improved repository structure for long-term OSS scalability
- Improved contributor readiness
- Improved project discoverability and professionalism
- Improved onboarding experience for external contributors

### Notes

- No SQL generation changes
- No macro behavior changes
- No API changes
- Fully compatible with previous `0.5.x` releases

### Breaking Changes

- None.

---

## [0.5.4] - 2026-05-17

### Changed

- Standardized macro argument documentation across all check categories
- Improved dbt Docs compatibility and macro discoverability

### Updated

- Updated temporal macro argument names to match current APIs
- Updated ratio macro argument names to match current APIs
- Updated string macro argument names to match current APIs

### Added

- Added documentation coverage for:
  - conditional checks
  - multi-column checks
  - rule composition checks
- Added missing `where` arguments to documented macro APIs
- Added grouped validation arguments (`group_by`) to supported checks

### Fixed

- Fixed inconsistencies between README examples and macro schema definitions

### Breaking Changes
- None.

---

## [0.5.3] - 2026-05-17

### Added

#### Rule Composition Checks
Added reusable expression-based validation checks:
- `expression_is_true`
- `all_of`
- `any_of`
These checks allow composing multiple business rules declaratively without writing custom SQL tests.

#### Conditional Checks
Added conditional dependency-based validation checks:
- `require_when`
- `require_not_null_when`
- `require_value_when`
These checks enable validations such as:
- requiring fields when conditions are met
- enforcing conditional business rules
- validating dependent columns
- conditional completeness enforcement

#### Multi-column Validation Improvements
Added:
- `columns_distinct`
This complements existing multi-column checks:
- `columns_equal`
- `column_greater_than_column`
- `column_less_than_column`

#### Advanced Failure Outputs
Advanced checks now expose contextual debugging information such as:
- failed expressions
- trigger conditions
- required conditions
- compared column values
- applied scoped conditions

#### Documentation Improvements
Updated README and dbt docs documentation for:
- rule composition checks
- conditional checks
- multi-column checks
- grouped validations
- advanced failure outputs
- validation semantics
- null-handling behavior

#### Integration Coverage
Added integration tests for:
- passing and failing conditional checks
- rule composition checks
- scoped validations with `where`
- multi-column validations
- null handling behavior
- advanced debugging outputs

#### Internal Improvements
Extended reusable internal helper architecture with:
- rule composition helpers
- conditional validation helpers
- advanced output helpers
- reusable expression validation guards
- Standardized safe SQL literal rendering for advanced failure outputs and expression-based checks

### Breaking Changes
- None.

---

## [0.5.2] - 2026-05-16

### Added
- Added conditional validation checks.
- Added `require_when`.
- Added `require_not_null_when`.
- Added `require_value_when`.
- Added integration coverage for dependency-based business rules.

### Changed
- Introduced reusable conditional validation architecture.

### Breaking Changes
- None.

---

## [0.5.1] - 2026-05-16

### Added
- Added rule composition checks.
- Added `expression_is_true`.
- Added `all_of`.
- Added `any_of`.
- Added reusable expression list validation helpers.
- Added integration coverage for composed rule validation.

### Changed
- Introduced reusable rule composition architecture for complex business validations.

### Breaking Changes
- None.

---

## [0.5.0] - 2026-05-16

### Added
- Added first multi-column validation checks.
- Added `columns_equal`.
- Added `column_greater_than_column`.
- Added `column_less_than_column`.
- Added integration coverage for multi-column checks, including `where` filters and null handling.

### Changed
- Introduced a dedicated multi-column validation category.

### Breaking Changes
- None.

---

## [0.4.5] - 2026-05-16

### Added
- Added grouped freshness validation support for `recent_date`.
- Added `group_by` support to `recent_date`.
- Added integration coverage for grouped freshness checks, including `where` filters and multi-column grouping.

### Changed
- Extended grouped validation patterns to temporal freshness use cases.

### Breaking Changes
- None.

---

## [0.4.4] - 2026-05-15

### Added
- Added official support for multi-column `group_by`.
- Added multi-column grouped validation integration coverage.
- Added multi-column grouped failure output documentation.

### Changed
- Stabilized grouped validation behavior for multiple grouping columns.
- Improved grouped output readability for multi-column validation.

### Fixed
- Improved consistency of grouped SQL generation across aggregation and ratio checks.

### Breaking Changes
- None.

---

## [0.4.3] - 2026-05-15

### Added
- Added readable grouped failure output aliases for simple `group_by` columns.
- Added fallback indexed grouped aliases for complex SQL expressions.

### Changed
- Improved grouped failure outputs from generic aliases such as `grouped_by_1` to more descriptive aliases such as `grouped_by_status`.
- Updated README failure output documentation to include grouped aggregation and grouped ratio examples.

### Fixed
- Improved grouped validation debugging experience in CI and stored failure tables.

### Breaking Changes
- None.

---

## [0.4.2] - 2026-05-12

### Added
- Added grouped ratio validation support through `group_by`.
- Added `group_by` support for ratio checks including `null_ratio_below`, `null_ratio_between`, `positive_ratio_between`, `negative_ratio_between`, and `value_ratio_between`.
- Added grouped ratio integration coverage.

### Changed
- Reused existing ratio check names and APIs for grouped behavior.
- Introduced reusable ratio validation CTE helpers.

### Notes
Existing ratio checks now support grouped validation through `group_by`.
No new check names were introduced.

### Breaking Changes
- None.

---

## [0.4.1] - 2026-05-12

### Added
- Added grouped aggregation support to existing aggregation checks.
- Added `group_by` support for `avg_between`, `sum_between`, `min_between`, `max_between`, `row_count_between`, and `row_count_less_than`.
- Added integration coverage for grouped aggregation checks, including `where` support, null values, null groups, and failing grouped thresholds.

### Changed
- Reused existing check names and APIs for grouped aggregation behavior instead of introducing grouped-specific check names.
- Introduced reusable internal aggregation helpers for consistent grouped and non-grouped aggregation SQL generation.
- Expanded README documentation for grouped aggregation checks and `group_by` usage.

### Fixed
- Improved grouped aggregation output alias handling through centralized grouping helpers.

### Breaking Changes
- None.

----

## [0.4.0] - 2026-05-12

### Added
- Added basic grouped validation support through `group_by`.
- Added `group_by` support to the existing `row_count_greater_than` check.
- Added grouped row count integration tests, including `where` support and null group values.

### Changed
- Introduced reusable internal grouping helpers for grouped validation patterns.
- Existing checks can now be extended with grouped behavior without introducing separate check names.

### Notes
- No new grouped check name was introduced for `row_count_greater_than`; grouped validation is enabled through the existing check API using `group_by`.
- Multi-column `group_by` is not documented as public API yet and is planned for a later `0.4.x` release.

### Breaking Changes
- None.

---

## [0.3.7] - 2026-05-11

### Added
- Added support for SQL date expressions in temporal boundaries such as `min_date` and `max_date`.
- Added integration coverage for dynamic SQL date expressions across temporal checks.

### Changed
- Expanded the temporal helper architecture to consistently support both ISO date literals and SQL date expressions.
- Improved documentation around temporal helper design and dynamic date boundary behavior.

### Fixed
- Fixed temporal boundary rendering for SQL date expressions containing quotes.
- Improved consistency of temporal helper usage across checks.
- Improved SQL escaping behavior in temporal failure outputs.

---

## [0.3.6] - 2026-05-10

### Added
- CI validation for internal helper macros:
  - `as_numeric`
  - `as_string`
  - `as_date`
  - `safe_ratio`
  - `apply_where`
  - `apply_and_where`
  - `applied_condition`
- CI validation for README core UX sections
- CI validation for current installation version in README
- Additional CI safeguards for documentation consistency

### Changed
- Improved CI coverage for internal package architecture
- Improved CI coverage for documentation quality
- Improved release consistency validation

### Notes
- No macro behavior changes
- No SQL generation changes
- No breaking changes
- Fully compatible with previous `0.3.x` releases

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