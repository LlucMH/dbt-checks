# Known Limitations

This document lists limitations of `dbt-checks` that are explicit design
trade-offs or platform constraints, not bugs. It exists so compatibility
claims elsewhere in the repository (README, CI status, CHANGELOG) stay
precise instead of overstating what has actually been verified.

---

# Postgres strict ISO date parsing

`postgres__try_cast_to_date` and `postgres__try_cast_to_timestamp`
(`macros/helpers/adapters/postgres.sql`) only accept strict ISO 8601 input:

- date: `YYYY-MM-DD`
- timestamp: `YYYY-MM-DD` optionally followed by a space- or `T`-separated
  `HH:MI:SS`

Anything else returns `NULL` rather than raising. This is narrower than
DuckDB's `try_cast` or Snowflake's `try_to_date`/`try_to_timestamp`, both of
which parse a wider range of date formats natively.

This exists because Postgres has no native `TRY_CAST` — `cast(x as date)`
raises an error on invalid input instead of returning `NULL`. The workaround
regex-guards the input before casting, which necessarily narrows what counts
as "parseable" on this adapter compared to adapters with a native try-cast.

**Impact:** a value like `01/15/2024` or `Jan 15 2024` returns `NULL` on
Postgres/Redshift but may parse successfully on DuckDB, Snowflake, BigQuery,
Databricks, or Spark. Checks relying on `try_cast_to_date`/
`try_cast_to_timestamp` (e.g. temporal checks over loosely-typed source
columns) can behave differently across adapters for the same input.

---

# Cloud adapter CI requires credentials

BigQuery, Snowflake, Databricks, Spark, and Redshift each have a dedicated
matrix leg in `.github/workflows/ci.yml`, but every one of them is gated on
repository variables/secrets (see `docs/ci.md` for the exact configuration
per adapter). Without that configuration, the leg is **skipped**, not
failed — CI stays green, but the leg contributes no signal.

**Impact:** merges to `main` do not, by themselves, guarantee those five
adapters were exercised. See "Dialect audited does not mean live-tested"
below.

---

# Spark minimum version required for `try_cast`

`spark__try_cast_to_date`/`spark__try_cast_to_timestamp`
(`macros/helpers/adapters/spark.sql`) use `try_cast(expr as type)`, which
was added in **Spark 3.2**. `try_to_date()`/`try_to_timestamp()` were
deliberately avoided because they are Databricks-SQL-only functions, absent
on plain Spark clusters reached over the Thrift/ODBC/Livy connection methods
`dbt-spark` also supports.

**Impact:** on a Spark cluster older than 3.2, `try_cast_to_date`/
`try_cast_to_timestamp` will fail to compile or execute rather than
returning `NULL` on invalid input. The Spark CI leg (see above) does not
currently pin or verify a minimum cluster version, since it depends on
whatever cluster is configured via `SPARK_HOST`.

---

# Dialect audited does not mean live-tested

"Dialect audited" (see the adapter capability table in `README.md`) means an
adapter's helper macros were manually reviewed against the warehouse's
documented SQL dialect — checked for correct function names, casting
behavior, escaping rules, and date/time semantics by reading vendor
documentation and the generated SQL.

It does **not** mean the macros were ever executed against a real instance
of that warehouse. Only DuckDB and Postgres are currently both dialect
audited and live-tested in CI; BigQuery, Snowflake, Databricks, Spark, and
Redshift are dialect audited and CI-wired, but live-tested only once their
respective credentials are configured (see "Cloud adapter CI requires
credentials" above).

A dialect audit catches documented behavior mismatches. It cannot catch
warehouse-specific runtime surprises (permission errors, quota/timeout
behavior, version-specific SQL parser quirks) that only surface by actually
running the query.

---

# Differences in regex behavior across adapters

`regex_match(expr, pattern)` dispatches to adapter-specific implementations
that differ in both the underlying regex engine and string-literal escaping
rules:

| Adapter    | Implementation                          | Pattern escaping needed |
| ---------- | ---------------------------------------- | ------------------------ |
| DuckDB     | `expr ~ 'pattern'` (POSIX)               | None                      |
| Postgres   | `expr ~ 'pattern'` (POSIX)               | None                      |
| Redshift   | `expr ~ 'pattern'` (POSIX)               | Quote-doubling only (`standard_conforming_strings` is on by default, so backslash is not special) |
| Snowflake  | `regexp_like(expr, 'pattern')`           | Backslash + quote escaping (literal backslash escapes are interpreted by the string literal) |
| BigQuery   | `regexp_contains(expr, 'pattern')`       | Backslash + quote escaping (non-raw string literal) |
| Databricks | `regexp_like(expr, 'pattern')`           | Backslash + quote escaping (fixed set of recognized escapes; unescaped `\` before the closing quote would be consumed) |
| Spark      | `regexp_like(expr, 'pattern')`           | Backslash + quote escaping (same rules as Databricks SQL) |

`dbt-checks` handles the escaping differences internally, so a `pattern`
argument written once in a schema.yml behaves consistently across adapters.
But the underlying regex **engines** are not identical (POSIX regex on
DuckDB/Postgres/Redshift vs. each warehouse's own regex dialect on the
others) — features like lookahead/lookbehind, possessive quantifiers, or
Unicode character classes may be supported on some adapters and not others.
Patterns that rely only on common, portable regex syntax (character
classes, anchors, basic quantifiers, alternation) behave consistently;
advanced or engine-specific syntax does not.

---

# Limitations of performance smoke tests

`performance-smoke-tests` (`.github/workflows/performance-smoke-tests.yml`,
see `docs/ci.md`) runs against a local DuckDB file and a disposable Postgres
service container in CI — not a production-sized cloud warehouse.

- Results say nothing about behavior on BigQuery, Snowflake, Databricks,
  Spark, or Redshift, or at data volumes beyond the 1M-row / 1,000-group
  scenarios exercised.
- Timings are **not comparable across releases or adapters** — CI runner
  hardware and load are not controlled for benchmarking purposes. The goal
  is narrower: catch pathological SQL generation (redundant CTEs, repeated
  source scans) and confirm the grouped validation architecture holds up at
  larger row volumes and higher `group_by` cardinality before release.
- The scenarios are exact, deterministic grids (`generate_series` cross
  joins), not representative of real-world data skew or cardinality
  distributions.

---

## Related Documentation

* [Overview](overview.md)
* [CI](ci.md)
* [Architecture](architecture.md)
