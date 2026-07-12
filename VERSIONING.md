# Versioning Policy

`dbt-checks` follows [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`).

This document defines what qualifies as a breaking change, a minor change, or a
patch, and how deprecations are communicated before removal.

---

# Version segments

## MAJOR

A major bump indicates a breaking change to the public API.

Examples:
- Renaming or removing a check
- Renaming or removing a check argument
- Changing the meaning of an existing argument
- Changing default NULL-handling behavior for an existing check
- Changing standardized failure output columns (removing or renaming a column)
- Raising the minimum supported dbt version (`require-dbt-version`)

## MINOR

A minor bump indicates new functionality that does not break existing usage.

Examples:
- Adding a new check
- Adding `group_by` support to an existing check
- Adding a new optional argument with a backward-compatible default
- Adding a new validation guard that only rejects configurations that were
  already invalid (see "Validation guards" below)

## PATCH

A patch bump indicates changes with no impact on generated SQL or macro
behavior.

Examples:
- Documentation updates
- CI changes
- Repository governance files
- Visual assets
- Release process and tooling changes

Every patch release must confirm in its CHANGELOG entry:
- No SQL generation changes
- No macro behavior changes

---

# Validation guards and semver

Compile-time validation guards (`validate_*` helpers) reject configurations
that were already invalid — for example `min_value > max_value`. Adding a new
guard for a case that previously compiled to incorrect or undefined behavior
is treated as a **minor** change, not a major one, because no configuration
that produced a documented, correct result is affected.

If a guard would reject a configuration that previously produced a
documented, correct result, that is a **major** change and must go through
the deprecation process below.

---

# Deprecation process

When an existing check or argument needs to change in a breaking way:

1. **Announce.** Open a GitHub issue describing the change and the reasoning.
2. **Support both behaviors for at least one minor release**, when technically
   feasible. The deprecated path continues to work but is documented as
   deprecated in the relevant `{% docs %}` block and in `docs/checks.md`.
3. **Warn at compile time.** Where possible, use `exceptions.warn(...)` to
   surface a deprecation message during `dbt compile` / `dbt test` for the
   deprecated path.
4. **Remove in the next MAJOR release**, with the removal documented in
   `CHANGELOG.md` under `### Breaking Changes`.

Deprecations that cannot reasonably support both behaviors in parallel (for
example, a NULL-handling change affecting query results) must still follow
steps 1 and 4, skipping step 2, and must be called out prominently in the
CHANGELOG and release notes.

---

# Release process

Releases are cut from `main` and are fully automated once a version bump is
merged:

1. Update `version` in `dbt_project.yml`.
2. Add the corresponding entry to `CHANGELOG.md` (this is validated in CI —
   see `docs/ci.md`).
3. Merge to `main`.
4. The release workflow detects the version change, creates the `vX.Y.Z` tag,
   and publishes a GitHub Release generated from the matching `CHANGELOG.md`
   section.

Tags follow strict `vX.Y.Z` semver so they remain indexable by dbt Hub's
`hubcap` tooling.

---

# Compatibility notes

- `dbt-checks` currently requires `dbt >= 1.5.0` (see `require-dbt-version` in
  `dbt_project.yml`). Raising this floor is a MAJOR change.
- Cross-warehouse compatibility claims in `README.md` are scoped to what is
  verified in CI. Extending "Planned validation" to "Fully tested in CI" for a
  new warehouse is documented as a MINOR change once that warehouse's CI job
  is in place.

---

See [CONTRIBUTING.md](CONTRIBUTING.md) for the general contribution workflow.
