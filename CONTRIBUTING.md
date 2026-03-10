# Contributing to dbt-checks

Thank you for considering contributing to **dbt-checks**.

This project aims to provide reusable data quality checks for dbt projects.

---

## Development setup

Clone the repository:

```bash
git clone https://github.com/<your-org>/dbt-checks
cd dbt-checks
```

Install dbt and dependencies:

```bash
pip install dbt-core dbt-duckdb
```

## Running integration tests

The repository includes a small dbt project under integration_tests used to validate the package.

Run the tests with:

```bash
cd integration_tests
dbt deps
dbt seed
dbt run
dbt test
```

## Adding a new check

When adding a new check:

    1 - Implement the macro under macros/tests/ 
    2 - Reuse helper macros where possible  
    3 - Add integration tests in integration_tests  
    4 - Update the documentation if needed  

## Code style

- Keep macros simple and readable
- Prefer reusable helpers
- Ensure compatibility across adapters when possible

## Reporting issues

If you find a bug or want to propose a feature, please open an issue on GitHub.
