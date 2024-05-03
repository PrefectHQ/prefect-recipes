"""
Purpose: Generates data for the TPC-H benchmark. The data is generated using the dbgen utility provided by the TPC-H benchmark. The data is then exported to JSON files and converted to Parquet files. The Parquet files are then used to generate a report of the top 50 orders by revenue for a given customer segment which is then stored in a Parquet file.

Requirements:

- a DuckDBConnector block named "tpch-support-sysadmin"
- a AWScredentials block for interacting with S3

"""

import datetime
from prefect import flow, task
from prefect.logging import get_run_logger
from prefect_duckdb import DuckDBConnector
import psutil
from upath import UPath as Path
import numpy as np
import pandas as pd
import pyarrow as pa
import uuid
import fsspec
from prefect_aws import AwsCredentials

ROOT = Path("./data-lake").resolve()
RAW_DIR = ROOT / "raw"  # Input JSON files
PROCESSED_DIR = ROOT / "processed"  # Processed Parquet files
RESULTS_DIR = ROOT / "results"  # Reduced/aggrgated results
fs = fsspec.filesystem(ROOT.protocol, use_listings_cache=False)

def new_time(t:pd.Timestamp, t_start:pd.Timestamp=None, t_end:pd.Timestamp=None) -> pd.Timestamp:
    d = pd.Timestamp("1998-12-31") - pd.Timestamp("1992-01-01")
    return t_start + (t - pd.Timestamp("1992-01-01")) * ((t_end - t_start) / d)
    
@task
def generate_data(scale: int = 1, path: Path = RAW_DIR):
    """"
    Generate data for the TPC-H benchmark using the dbgen utility provided by duckDB The data is then exported to JSON files.
    
    Args:
        scale (int): Scale factor for the data generation
        path (Path): Path to store the generated data
    """
    logger = get_run_logger()
    duck_connector = DuckDBConnector()
    with duck_connector.get_connection() as conn:
        static_tables = ["customer", "lineitem", "nation", "orders", "part", "partsupp", "region", "supplier"]
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
            if table in static_tables and (
                list((RAW_DIR / table).rglob("*.json"))
                or list((PROCESSED_DIR / table).rglob("*.parquet"))
            ):
                logger.info(f"Static table {table} already exists")
                continue
            logger.info(f"Exporting table: {table}")
   
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
                # Join with `orderkey_new` mapping to convert old order IDs to new order IDs
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

            outfile = (
                path
                / table
                / f"{table}_{datetime.datetime.now().isoformat().split('.')[0]}.json"
            )

            fs.makedirs(outfile.parent, exist_ok=True)
            
            df.to_json(
                outfile,
                date_format="iso",
                orient="records",
                lines=True,
            )
            logger.info(f"Exported table {table} to {outfile}")
        logger.info("Finished exporting all data")

@task()
def copy_to_parquet(file: Path):
    """Convert raw JSON data file to Parquet.
    Args:
        file (Path): Path to the JSON file to convert to Parquet
    """
    logger = get_run_logger()
    logger(f"Processing {file}")
    duck_connector = DuckDBConnector()
    with duck_connector.get_connection() as conn:
        partition = f"{datetime.datetime.now().isoformat().split('.')[0]}"
        outfile = PROCESSED_DIR / file.parent.name / partition
        fs.makedirs(outfile , exist_ok=True)
        query = f"""
        COPY 
        (SELECT * FROM read_json_auto('{file}')) 
        TO '{outfile}/{file.parent.name}.parquet'
        (FORMAT PARQUET);
        """
        conn.execute(query)
        fs.rm(str(file))
        return file


@task
def transform_df(segment:str):
    """
    TPCH-Q3: Shipping Priority Query 
    As described in the TPC Benchmark™ H (TPC-H) specification: "The Shipping Priority Query retrieves the shipping priority and potential revenue, defined as the sum of l_extendedprice * (1-l_discount), of the orders having the largest revenue among those that had not been shipped as of a given date. Orders are listed in decreasing order of revenue." The results are then stored in a Parquet file.

    Args:
        segment (str): Customer segment to filter by
    """
    logger = get_run_logger()
    duck_connector = DuckDBConnector()
    with duck_connector.get_connection() as conn:
            lineitem_df = conn.read_parquet(str(PROCESSED_DIR / "lineitem/*/*.parquet")).df()
            orders_df = conn.read_parquet(str(PROCESSED_DIR / "orders/*/*.parquet")).df()
            customers_df =conn.read_parquet(str(PROCESSED_DIR / "customer/*/*.parquet")).df()

            # Filter conditions
            date = pd.Timestamp.now()
            osel = pd.to_datetime(orders_df['o_orderdate']) < date
            lsel = pd.to_datetime(lineitem_df['l_shipdate']) > date
            csel = customers_df['c_mktsegment'].str.upper() == segment.upper()

            # Apply filters
            flineitem = lineitem_df[lsel]
            forders = orders_df[osel]
            fcustomer = customers_df[csel]

            # Merge dataframes
            jn1 = pd.merge(fcustomer, forders, left_on='c_custkey', right_on='o_custkey')
            jn2 = pd.merge(jn1, flineitem, left_on='o_orderkey', right_on='l_orderkey')

            jn2['revenue'] = jn2['l_extendedprice'] * (1 - jn2['l_discount'])
            # Group by and sum revenue
            total = jn2.groupby(["l_orderkey", "o_orderdate", "o_shippriority"])["revenue"].sum().reset_index()
            result = total.sort_values(["revenue"], ascending=False).head(50)
            outfile = RESULTS_DIR / f"{segment}.snappy.parquet"
            result.to_parquet(outfile, compression="snappy")
            
               
@flow
def data_lake(local: bool = True):
    segments = ["automobile", "building", "furniture", "machinery", "household"]
    duckdb_connector = DuckDBConnector() 
    with duckdb_connector.get_connection() as conn:
        if not local:
            aws_credentials = AwsCredentials().load("aws-credentials")
            conn.sql(f"""
            SET s3_access_key_id = 'f{aws_credentials.access_key_id}';
            SET s3_secret_access_key = 'f{aws_credentials.secret_access_key}';
            SET s3_region = 'f{aws_credentials.region}';    
            """)
    generate_df = generate_data(1)
    load = copy_to_parquet.map(list(RAW_DIR.rglob("*.json")))
    reduce_df = transform_df.map(segment=segments)
    
    
if __name__ == "__main__":
    data_lake.serve(
        name="duckdb-tpch-local",
        labels=["local"],
        parameters=dict(
            scale=1,
            local=True,
        )
    )
    data_lake.serve(
        name="duckdb-tpch-cloud",
        labels=["cloud"],
        parameters=dict(
            scale=1,
            local=False,
        )       
    )


