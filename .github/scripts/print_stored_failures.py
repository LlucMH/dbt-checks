#!/usr/bin/env python3
"""Print stored dbt_test__audit failure tables to stdout and GITHUB_STEP_SUMMARY.

Centralizes the per-adapter connection and information_schema query logic
that adapter-integration-tests.yml previously duplicated as a separate
inline Python heredoc per adapter. Each `list_*` function below is called
only for its own adapter, so adapter-specific driver imports stay local to
that function — a CI leg only has its own adapter's driver installed, not
every driver for every adapter.
"""

import argparse
import glob
import os
import sys


def to_markdown(headers, rows):
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join(["---"] * len(headers)) + " |",
    ]

    for row in rows:
        safe_values = [
            "" if v is None else str(v).replace("|", "\\|").replace("\n", " ")
            for v in row
        ]
        lines.append("| " + " | ".join(safe_values) + " |")

    return "\n".join(lines)


def emit(output_lines):
    final_output = "\n".join(output_lines)
    print(final_output)

    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as f:
            f.write(final_output)
            f.write("\n")


def list_duckdb():
    import duckdb

    db_files = glob.glob("**/*.duckdb", recursive=True)
    if not db_files:
        return []

    db_path = max(db_files, key=os.path.getmtime)
    print(f"Using DuckDB database: {db_path}")

    con = duckdb.connect(db_path, read_only=True)
    tables = con.execute("""
        select table_schema, table_name
        from information_schema.tables
        where table_schema ilike '%dbt_test__audit%'
        order by table_name
    """).fetchall()

    results = []
    for schema, table in tables:
        result = con.execute(f'select * from "{schema}"."{table}" limit 20')
        headers = [col[0] for col in result.description]
        rows = result.fetchall()
        results.append((table, headers, rows))
    return results


def _list_psycopg2(host, port, user, password, dbname):
    import psycopg2

    con = psycopg2.connect(
        host=host, port=port, user=user, password=password, dbname=dbname
    )
    con.autocommit = True
    cur = con.cursor()

    cur.execute("""
        select table_schema, table_name
        from information_schema.tables
        where table_schema ilike '%dbt_test__audit%'
        order by table_name
    """)
    tables = cur.fetchall()

    results = []
    for schema, table in tables:
        cur.execute(f'select * from "{schema}"."{table}" limit 20')
        headers = [col.name for col in cur.description]
        rows = cur.fetchall()
        results.append((table, headers, rows))
    return results


def list_postgres():
    return _list_psycopg2(
        host=os.environ["POSTGRES_HOST"],
        port=os.environ["POSTGRES_PORT"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=os.environ["POSTGRES_DB"],
    )


def list_redshift():
    # Redshift is Postgres-wire-compatible, so it reuses the same
    # psycopg2-based query as the Postgres leg.
    return _list_psycopg2(
        host=os.environ["REDSHIFT_HOST"],
        port=os.environ["REDSHIFT_PORT"],
        user=os.environ["REDSHIFT_USER"],
        password=os.environ["REDSHIFT_PASSWORD"],
        dbname=os.environ["REDSHIFT_DB"],
    )


def list_bigquery():
    from google.cloud import bigquery

    project = os.environ["BIGQUERY_PROJECT"]
    dataset = os.environ["BIGQUERY_DATASET"]

    client = bigquery.Client.from_service_account_json(
        os.environ["BIGQUERY_KEYFILE"],
        project=project,
    )

    tables = list(client.query(f"""
        select table_name
        from `{project}.{dataset}`.INFORMATION_SCHEMA.TABLES
        where table_name like '%dbt_test__audit%'
        order by table_name
    """).result())

    results = []
    for row in tables:
        table = row["table_name"]
        result = client.query(
            f"select * from `{project}.{dataset}.{table}` limit 20"
        ).result()
        headers = [field.name for field in result.schema]
        rows = [[value for value in record.values()] for record in result]
        results.append((table, headers, rows))
    return results


def list_snowflake():
    import snowflake.connector

    database = os.environ["SNOWFLAKE_DATABASE"]

    con = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.environ.get("SNOWFLAKE_ROLE") or None,
        database=database,
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE") or None,
        schema=os.environ["SNOWFLAKE_SCHEMA"],
    )
    cur = con.cursor()

    cur.execute(f"""
        select table_schema, table_name
        from {database}.information_schema.tables
        where table_schema ilike '%dbt_test__audit%'
        order by table_name
    """)
    tables = cur.fetchall()

    results = []
    for schema, table in tables:
        cur.execute(f'select * from "{schema}"."{table}" limit 20')
        headers = [col[0] for col in cur.description]
        rows = cur.fetchall()
        results.append((table, headers, rows))
    return results


def list_databricks():
    from databricks import sql

    con = sql.connect(
        server_hostname=os.environ["DATABRICKS_HOST"],
        http_path=os.environ["DATABRICKS_HTTP_PATH"],
        access_token=os.environ["DATABRICKS_TOKEN"],
        catalog=os.environ.get("DATABRICKS_CATALOG") or None,
        schema=os.environ["DATABRICKS_SCHEMA"],
    )
    cur = con.cursor()

    cur.execute("""
        select table_schema, table_name
        from information_schema.tables
        where table_schema ilike '%dbt_test__audit%'
        order by table_name
    """)
    tables = cur.fetchall()

    results = []
    for schema, table in tables:
        cur.execute(f"select * from `{schema}`.`{table}` limit 20")
        headers = [col[0] for col in cur.description]
        rows = cur.fetchall()
        results.append((table, headers, rows))
    return results


def list_spark():
    from pyhive import hive

    schema = os.environ["SPARK_SCHEMA"]

    con = hive.Connection(
        host=os.environ["SPARK_HOST"],
        port=int(os.environ["SPARK_PORT"]),
        username=os.environ["SPARK_USER"],
        password=os.environ["SPARK_PASSWORD"],
        auth="LDAP",
    )
    cur = con.cursor()

    cur.execute(f"show tables in {schema} like '*dbt_test__audit*'")
    tables = [row[1] for row in cur.fetchall()]

    results = []
    for table in sorted(tables):
        cur.execute(f"select * from {schema}.{table} limit 20")
        headers = [col[0] for col in cur.description]
        rows = cur.fetchall()
        results.append((table, headers, rows))
    return results


LISTERS = {
    "duckdb": list_duckdb,
    "postgres": list_postgres,
    "redshift": list_redshift,
    "bigquery": list_bigquery,
    "snowflake": list_snowflake,
    "databricks": list_databricks,
    "spark": list_spark,
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--adapter", required=True, choices=sorted(LISTERS))
    args = parser.parse_args()

    tables = LISTERS[args.adapter]()

    if not tables:
        print("No stored failure tables found.")
        return

    output = ["# dbt-checks failure output", ""]

    for table, headers, rows in tables:
        if not rows:
            continue

        output.append(f"## `{table}`")
        output.append("")
        output.append(to_markdown(headers, rows))
        output.append("")

    emit(output)


if __name__ == "__main__":
    main()
