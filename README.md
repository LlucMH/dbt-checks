<p align="center">
  <img src="docs/assets/dbt-checks banner.png" alt="dbt-checks banner" width="600"/>
</p>

---

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/LlucMH/dbt-checks/ci.yml?branch=main" />
  <img src="https://img.shields.io/badge/dbt-1.5%2B-orange" />
  <img src="https://img.shields.io/badge/tested%20on-duckdb%20%7C%20postgres-blue" />
  <img src="https://img.shields.io/badge/cross--db-dbt%20dispatch-lightgrey" />
  <img src="https://img.shields.io/github/license/LlucMH/dbt-checks" />
  <img src="https://img.shields.io/github/v/release/LlucMH/dbt-checks" />
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" />
  <img src="https://img.shields.io/github/issues/LlucMH/dbt-checks" />
  <img src="https://img.shields.io/github/issues-pr/LlucMH/dbt-checks" />
</p>

---

# dbt-checks

**dbt-checks** is a lightweight library of reusable data quality checks for dbt projects.

The package provides business-oriented validation checks that help teams express data quality rules declaratively inside dbt schema files.

Instead of repeatedly writing custom SQL tests, users can apply reusable checks with standardized outputs, validation guards, grouped validation support, and cross-warehouse compatibility.

> ⚠️ Rapidly evolving project — feedback and contributions are welcome.

---

# Installation

Add the package to your `packages.yml`:

```yaml
packages:
  - git: https://github.com/LlucMH/dbt-checks.git
    revision: v0.7.5
```

Install dependencies:

```bash
dbt deps
```

Always pin a release version in production projects.

---

# Features

dbt-checks provides:

* reusable business-oriented validations
* grouped validation with `group_by`
* conditional business rules
* rule composition checks
* multi-column validations
* standardized failure outputs
* validation guards
* CI-friendly debugging
* predictable NULL handling
* cross-warehouse compatibility through dbt dispatch

---

# Quick Example

```yaml
models:
  - name: orders

    columns:
      - name: amount
        data_tests:
          - dbt_checks.non_negative

      - name: email
        data_tests:
          - dbt_checks.null_ratio_below:
              arguments:
                value: 0.02
```

Run validations using:

```bash
dbt test
```

---

# Validation Flow

<p align="center">
  <img src="docs/assets/validation-flow.png" alt="Validation Flow" width="1100"/>
</p>

dbt-checks supports a CI-friendly validation lifecycle with standardized outputs, stored failures support, and progressive rollout strategies.

---

# Validation Categories

The package currently provides:

| Category         | Description                          |
| ---------------- | ------------------------------------ |
| Numeric          | Numeric ranges and thresholds        |
| String           | Text validation and formats          |
| Temporal         | Dates, timestamps, freshness         |
| Aggregation      | Dataset-level metrics                |
| Ratio            | Completeness and distribution checks |
| Multi-column     | Relationships between columns        |
| Conditional      | Dependency-based business rules      |
| Rule Composition | Expression-based business rules      |

See the documentation for detailed examples.

---

# Supported Warehouses

dbt-checks is designed to work across common dbt adapters.

Current compatibility targets include:

* DuckDB
* Postgres
* BigQuery
* Snowflake
* Databricks
* Spark
* Redshift

Adapter-specific behavior is handled through dbt dispatch.

| Warehouse  | Status                                             |
| ---------- | --------------------------------------------------- |
| DuckDB     | Fully tested in CI                                   |
| Postgres   | Fully tested in CI                                   |
| BigQuery   | Dialect-audited; CI wired, pending GCP credentials   |
| Snowflake  | Dialect-audited; CI wired, pending Snowflake credentials |
| Databricks | Dialect-audited; CI wired, pending Databricks credentials |
| Spark      | Dialect-audited; CI wired, pending Spark cluster credentials |
| Redshift   | Dialect-audited; CI wired, pending Redshift credentials |

---

# Documentation

Documentation is organized under the `/docs` directory.

* [Documentation Index](docs/README.md)

## Getting Started

* [Overview](docs/overview.md)
* [Checks](docs/checks.md)

## Validation Features

* [Grouped Checks](docs/grouped-checks.md)
* [Conditional Checks](docs/conditional-checks.md)
* [Rule Composition](docs/rule-composition.md)

## Technical Documentation

* [Architecture](docs/architecture.md)
* [CI](docs/ci.md)

## Usage Examples

* [Examples](docs/examples.md)

For detailed arguments, examples, and metadata, use dbt Docs:

```bash
dbt docs generate
dbt docs serve
```

---

# Examples

The project includes practical usage examples for common analytics engineering and data quality scenarios.

## Included Scenarios

* ecommerce validations
* finance validations
* customer data quality
* SaaS multi-tenant validation
* medallion architecture strategies
* grouped validation
* conditional business rules
* CI rollout strategies

---

## Grouped Validation Example

<p align="center">
  <img src="docs/assets/grouped-checks-example.png" alt="Grouped Checks Example" width="1100"/>
</p>

Grouped validation allows checks to run independently for each segment of a dataset.

This is especially useful for:

* multi-tenant SaaS platforms
* country-level KPIs
* regional analytics
* source-system monitoring
* partition validation

---

## Medallion Quality Strategy

<p align="center">
  <img src="docs/assets/medallion-quality-strategy.png" alt="Medallion Quality Strategy" width="1100"/>
</p>

dbt-checks supports different validation strategies across:

* bronze ingestion layers
* silver transformation layers
* gold KPI layers

This helps teams apply data quality intentionally across the analytics lifecycle.

---

## Stored Failures Workflows

<p align="center">
  <img src="docs/assets/stored-failures-example.png" alt="Stored Failures Example" width="1100"/>
</p>

Stored failures allow teams to:

* debug failing rows
* monitor quality trends
* build alerts
* improve operational observability

---

## CI Rollout Strategies

<p align="center">
  <img src="docs/assets/ci-rollout-strategy.png" alt="CI Rollout Strategy" width="1100"/>
</p>

dbt-checks supports progressive rollout strategies using:

* `severity: warn`
* `severity: error`
* `warn_if`
* `error_if`
* `--warn-error`

This enables safer adoption in existing projects.

---

## dbt Docs Integration

<p align="center">
  <img src="docs/assets/dbt-docs-example.png" alt="dbt Docs Example" width="1100"/>
</p>

dbt-checks integrates naturally with dbt documentation workflows and exposes metadata directly through dbt docs.

---

## CI Integration

<p align="center">
  <img src="docs/assets/ci-failure-example.png" alt="CI Failure Example" width="1100"/>
</p>

CI integration helps teams detect issues early before invalid data reaches downstream consumers.

---

# Why dbt-checks?

Many dbt projects repeatedly implement the same validation logic.

dbt-checks provides:

* reusable validation patterns
* expressive business-rule enforcement
* grouped validation support
* standardized failure semantics
* observability-friendly outputs
* CI-friendly debugging
* cross-warehouse compatibility
* maintainable validation architecture

The goal is to make data quality checks easier to write, easier to understand, and easier to maintain.

---

# Community & Support

dbt-checks is an open-source project and contributions are welcome.

## Resources

* [Contributing Guide](CONTRIBUTING.md)
* [Versioning Policy](VERSIONING.md)
* [Code of Conduct](CODE_OF_CONDUCT.md)
* [Security Policy](SECURITY.md)
* [Support Guidelines](SUPPORT.md)
* [License](LICENSE)

## Repository Resources

The repository includes:

* [Issue Templates](.github/ISSUE_TEMPLATE/)
* [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md)
* [Documentation](docs/README.md)
* [CI Workflow](.github/workflows/ci.yml)

## Community Goals

The project aims to provide:

* clear contribution guidelines
* transparent governance
* reproducible validation workflows
* maintainable documentation
* contributor-friendly collaboration

Feedback, bug reports, feature requests, and pull requests are always appreciated.

---

# OSS Maturity

dbt-checks is evolving toward a production-grade OSS package with:

* multi-adapter CI
* adapter compatibility validation
* Fusion compatibility
* release validation workflows
* repository governance
* contributor tooling
* dbt Hub readiness

---

# Contributing

Contributions are welcome.

When adding a new check:

1. Implement the macro
2. Reuse existing helper macros
3. Add integration tests
4. Add documentation
5. Validate NULL behavior
6. Consider grouped validation support

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

# License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for details.