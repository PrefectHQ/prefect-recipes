"""
Purpose: Generates data for the TPC-H benchmark.
The data is generated using the dbgen utility provided by the TPC-H benchmark.
The data is then exported to JSON files and converted to Parquet files.
The Parquet files are then used to generate a report of the top 50 orders
by revenue for a given customer segment.

Requirements:

- a DuckDBConnector block named "tpch-benchmark"
- a AWScredentials block for interacting with S3

"""
import datetime
import os
import uuid

import fsspec
import numpy as np
import pandas as pd
import psutil
from prefect import flow, task
from prefect_aws import AwsCredentials
from upath import UPath as Path

from prefect_duckdb import DuckDBConnector

LOCAL = os.environ.get("EXECUTION_ENVIRONMENT", "local") == "local"
BUCKET = os.environ.get("BUCKET")

ROOT = Path("./data-lake").resolve() if LOCAL else Path(f"s3://{BUCKET}/data-lake")
RAW_DIR = Path("./data-lake").resolve() / "raw"  # Input JSON files
PROCESSED_DIR = ROOT / "processed"  # Processed Parquet files
RESULTS_DIR = ROOT / "results"  # Reduced/aggrgated results

fs = fsspec.filesystem(ROOT.protocol, use_listings_cache=False)


def new_time(
    t: pd.Timestamp, t_start: pd.Timestamp = None, t_end: pd.Timestamp = None
) -> pd.Timestamp:
    """Create a new timestamp between t_start and t_end based on
    the time difference between 1992-01-01 and 1998-12-31."""
    d = pd.Timestamp("1998-12-31") - pd.Timestamp("1992-01-01")
    return t_start + (t - pd.Timestamp("1992-01-01")) * ((t_end - t_start) / d)


schema = {
    "part": {
        "p_partkey": "BIGINT",
        "p_name": "VARCHAR",
        "p_mfgr": "VARCHAR",
        "p_brand": "VARCHAR",
        "p_type": "VARCHAR",
        "p_size": "BIGINT",
        "p_container": "VARCHAR",
        "p_retailprice": "DOUBLE",
        "p_comment": "VARCHAR",
    },
    "supplier": {
        "s_suppkey": "BIGINT",
        "s_name": "VARCHAR",
        "s_address": "VARCHAR",
        "s_nationkey": "BIGINT",
        "s_phone": "VARCHAR",
        "s_acctbal": "DOUBLE",
        "s_comment": "VARCHAR",
    },
    "partsupp": {
        "ps_partkey": "BIGINT",
        "ps_suppkey": "BIGINT",
        "ps_availqty": "BIGINT",
        "ps_supplycost": "DOUBLE",
        "ps_comment": "VARCHAR",
    },
    "customer": {
        "c_custkey": "BIGINT",
        "c_name": "VARCHAR",
        "c_address": "VARCHAR",
        "c_nationkey": "BIGINT",
        "c_phone": "VARCHAR",
        "c_acctbal": "DOUBLE",
        "c_mktsegment": "VARCHAR",
        "c_comment": "VARCHAR",
    },
    "orders": {
        "o_orderkey": "UUID",
        "o_custkey": "BIGINT",
        "o_orderstatus": "VARCHAR",
        "o_totalprice": "DOUBLE",
        "o_orderdate": "TIMESTAMP",
        "o_orderpriority": "VARCHAR",
        "o_clerk": "VARCHAR",
        "o_shippriority": "BIGINT",
        "o_comment": "VARCHAR",
        "o_null": "VARCHAR",
    },
    "lineitem": {
        "l_orderkey": "UUID",
        "l_partkey": "BIGINT",
        "l_suppkey": "BIGINT",
        "l_linenumber": "BIGINT",
        "l_quantity": "DOUBLE",
        "l_extendedprice": "DOUBLE",
        "l_discount": "DOUBLE",
        "l_tax": "DOUBLE",
        "l_returnflag": "VARCHAR",
        "l_linestatus": "VARCHAR",
        "l_shipdate": "TIMESTAMP",
        "l_commitdate": "TIMESTAMP",
        "l_receiptdate": "TIMESTAMP",
        "l_shipinstruct": "VARCHAR",
        "l_shipmode": "VARCHAR",
        "l_comment": "VARCHAR",
    },
    "nation": {
        "n_nationkey": "BIGINT",
        "n_name": "VARCHAR",
        "n_regionkey": "BIGINT",
        "n_comment": "VARCHAR",
    },
    "region": {
        "r_regionkey": "BIGINT",
        "r_name": "VARCHAR",
        "r_comment": "VARCHAR",
        "r_null": "VARCHAR",
    },
}


@task
def generate_data(scale: int = 1, path: Path = RAW_DIR):
    """
    Generate data for the TPC-H benchmark using the dbgen utility provided by duckDB
    The data is then exported to JSON files.

    Args:
        scale (int): Scale factor for the data generation
        path (Path): Path to store the generated data
    """

    duck_connector = DuckDBConnector()
    with duck_connector.get_connection() as conn:
        static_tables = [
            "customer",
            "lineitem",
            "nation",
            "orders",
            "part",
            "partsupp",
            "region",
            "supplier",
        ]
        conn.sql(
            f"""
            SET memory_limit='{psutil.virtual_memory().available // 2**30 }G';
            SET preserve_insertion_order=false;
            SET threads TO 1;
            SET enable_progress_bar=false;
            """
        )
        conn.sql(f"call dbgen(sf={scale})")
        tables = (
            conn.sql("SELECT * FROM information_schema.tables")
            .arrow()
            .column("table_name")
        )

        now = pd.Timestamp.now()
        for table in reversed(sorted(map(str, tables))):
            if table in static_tables and list((RAW_DIR / table).rglob("*.json")):
                print(f"Static table {table} already exists")
                continue
            print(f"Exporting table: {table}")

            df = conn.sql(f"""SELECT * FROM {table}""").df()

            # Make order IDs unique across multiple data generation cycles
            if table == "orders":
                # Generate new, random uuid order IDs
                df["o_orderkey_new"] = pd.Series(
                    (uuid.uuid4().hex for _ in range(df.shape[0])),
                    dtype="string[pyarrow]",
                )
                orderkey_new = df[["o_orderkey", "o_orderkey_new"]].set_index(
                    "o_orderkey"
                )
                df = df.drop(columns="o_orderkey").rename(
                    columns={"o_orderkey_new": "o_orderkey"}
                )
            elif table == "lineitem":
                df = (
                    df.set_index("l_orderkey")
                    .join(orderkey_new)
                    .reset_index(drop=True)
                    .rename(columns={"o_orderkey_new": "l_orderkey"})
                )
            # Shift times to be more recent and lineitem prices to be non-uniform
            if table == "lineitem":

                df["l_shipdate"] = new_time(
                    df["l_shipdate"], t_start=now, t_end=now + pd.Timedelta("3 days")
                )

                df["l_extendedprice"] = (
                    np.random.rand(df.shape[0]) * df["l_extendedprice"]
                )
            cols = [c for c in df.columns if "date" in c and table != "lineitem"]
            df[cols] = new_time(
                df[cols], t_start=now - pd.Timedelta("15 minutes"), t_end=now
            )
            conn.register(table, df)
            outfile = (
                path
                / table
                / f"{table}_{datetime.datetime.now().isoformat().split('.')[0]}.json"
            )
            fs.makedirs(outfile.parent, exist_ok=True)
            conn.sql(
                f"""
                    COPY (SELECT * FROM {table})
                    TO '{outfile}'
                """
            )

            print(f"Exported table {table} to {outfile}")
        print("Finished exporting all data")


@task()
def copy_to_parquet(file: Path, datadir: Path = PROCESSED_DIR):
    """Convert raw JSON data file to Parquet.
    Args:
        file (Path): Path to the JSON file to convert to Parquet
    """
    duck_connector = DuckDBConnector()
    if not LOCAL:
        aws_credentials = AwsCredentials().load("s3-service")
        duck_connector.create_secret(
            "secret1",
            "S3",
            aws_credentials.aws_access_key_id,
            aws_credentials.aws_secret_access_key,
            aws_credentials.region_name,
        )
    with duck_connector.get_connection() as conn:
        partition = f"{datetime.datetime.now().isoformat().split('.')[0]}"
        outfile = datadir / file.parent.name / partition
        fs.makedirs(outfile, exist_ok=True)
        query = f"""
        COPY
        (SELECT * FROM read_json_auto(
            '{file}',
            columns = {schema[file.parent.name]}
            )
        )
        TO '{outfile}/{file.parent.name}.parquet'
        (FORMAT PARQUET);
        """
        conn.execute(query)
        print(f"Exported table {file.parent.name} to {outfile}")
        if LOCAL:
            fs.rm(str(file))

        return file


@task
def shipping_priority_query(segment, datadir=PROCESSED_DIR):
    """
    TPCH-Q3: Shipping Priority Query
    Retrieves the shipping priority and potential revenue of the orders
    having the largest revenue among those that had not been shipped
    as of a given date. The results are then stored in a Parquet file.

    Args:
        segment (str): Customer segment to filter by
    """
    duck_connector = DuckDBConnector()
    if not LOCAL:
        aws_credentials = AwsCredentials().load("s3-service")
        duck_connector.create_secret(
            "secret1",
            "S3",
            aws_credentials.aws_access_key_id,
            aws_credentials.aws_secret_access_key,
            aws_credentials.region_name,
        )
    with duck_connector.get_connection():
        lineitem_path = str(datadir / "lineitem/*/*.parquet")
        orders_path = str(datadir / "orders/*/*.parquet")
        customer_path = str(datadir / "customer/*/*.parquet")
        duck_connector.execute(
            f"CREATE TABLE lineitem AS SELECT * FROM read_parquet('{lineitem_path}')"
        )
        duck_connector.execute(
            f"CREATE TABLE orders AS SELECT * FROM read_parquet('{orders_path}')"
        )
        duck_connector.execute(
            f"CREATE TABLE customer AS SELECT * FROM read_parquet('{customer_path}')"
        )

        date = pd.Timestamp.now()

        query = f"""
            SELECT
                l_orderkey AS order_key,
                sum(l_extendedprice * (1 - l_discount)) AS revenue,
                o_orderdate AS order_date,
                o_shippriority AS ship_priority
            FROM
                customer,
                orders,
                lineitem
            WHERE
                c_mktsegment = '{segment.upper()}'
                AND c_custkey = o_custkey
                AND l_orderkey = o_orderkey
                AND o_orderdate <  '{date}'
                AND l_shipdate > '{date}'
            GROUP BY
                l_orderkey,
                o_orderdate,
                o_shippriority
            ORDER BY
                revenue desc,
                o_orderdate
            LIMIT 50;
            """
        result = duck_connector.sql(query, debug=True)
        print(result.show())
        result.create(segment)
        outfile = RESULTS_DIR / f"{segment}.snappy.parquet"
        if LOCAL:
            fs.makedirs(RESULTS_DIR, exist_ok=True)
        duck_connector.execute(
            f"""
        COPY
        (SELECT * FROM {segment})
        TO '{outfile}'
        (FORMAT PARQUET);
        """
        )


@task
def transform_df(segment: str):
    """
    TPCH-Q3: Shipping Priority Query
    Retrieves the shipping priority and potential revenue of the orders
    having the largest revenue among those that had not been shipped
    as of a given date. The results are then stored in a Parquet file.

    Args:
        segment (str): Customer segment to filter by
    """
    duck_connector = DuckDBConnector()
    with duck_connector.get_connection() as conn:
        lineitem_df = conn.read_parquet(
            str(PROCESSED_DIR / "lineitem/*/*.parquet")
        ).df()
        orders_df = conn.read_parquet(str(PROCESSED_DIR / "orders/*/*.parquet")).df()
        customers_df = conn.read_parquet(
            str(PROCESSED_DIR / "customer/*/*.parquet")
        ).df()

        # Filter conditions
        date = pd.Timestamp.now()
        osel = pd.to_datetime(orders_df["o_orderdate"]) < date
        lsel = pd.to_datetime(lineitem_df["l_shipdate"]) > date
        csel = customers_df["c_mktsegment"].str.upper() == segment.upper()

        # Apply filters
        flineitem = lineitem_df[lsel]
        forders = orders_df[osel]
        fcustomer = customers_df[csel]

        # Merge dataframes
        jn1 = pd.merge(fcustomer, forders, left_on="c_custkey", right_on="o_custkey")
        jn2 = pd.merge(jn1, flineitem, left_on="o_orderkey", right_on="l_orderkey")

        jn2["revenue"] = jn2["l_extendedprice"] * (1 - jn2["l_discount"])
        # Group by and sum revenue
        total = (
            jn2.groupby(["l_orderkey", "o_orderdate", "o_shippriority"])["revenue"]
            .sum()
            .reset_index()
        )
        result = total.sort_values(["revenue"], ascending=False).head(50)
        outfile = RESULTS_DIR / f"{segment}.snappy.parquet"
        result.to_parquet(outfile, compression="snappy")


@flow
def data_lake():
    """
    Purpose: Generates data for the TPC-H benchmark.
    The data is generated using the dbgen utility provided by the DuckDB.
    Data is then exported to parquet files.
    """
    segments = ["automobile", "building", "furniture", "machinery", "household"]
    generate_data(1)
    load = copy_to_parquet.map(list(RAW_DIR.rglob("*.json")))
    shipping_priority_query.map(segment=segments, wait_for=[load])


if __name__ == "__main__":
    data_lake()

    # This deployment will run using s3
    # data_lake.deploy(
    #     name="duckdb-tpch-cloud",
    #     job_variables={"EXECUTION_ENVIRONMENT": "cloud",
    #                    "BUCKET": "tpch-benchmark"},
    # )
