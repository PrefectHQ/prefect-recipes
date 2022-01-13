import boto3
import pandas as pd
import prefect
from prefect import Flow, mapped, task
from prefect.tasks.secrets import PrefectSecret
from prefect.engine import signals
from snowflake.connector import SnowflakeConnection
from typing import List, Tuple

logger = prefect.context.get("logger")
logger.setLevel("INFO")

@task(name='Get S3 objects')
def get(bucket: str, key: str) -> pd.DataFrame:
    s3 = boto3.client("s3")
    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
    except Exception:
        raise signals.FAIL('Failed to GET S3 Object')

    return pd.read_csv(obj["body"])

@task(name='Transform S3 data')
def transform(s3_df: pd.DataFrame, output_file: str) -> str:

    # transform as needed

    s3_df.to_csv(f"{output_file}.csv", index=False)

    return output_file

SQL = {
    "COPY_INTO_TEMP": lambda i: f"""COPY INTO TEMP_{i}
            FROM @%TEMP_{i}
            FILE_FORMAT = (
                error_on_column_count_mismatch=false
                TYPE = 'CSV'
                FIELD_OPTIONALLY_ENCLOSED_BY='\042'
                SKIP_HEADER = 1
            )
            TRUNCATECOLUMNS = TRUE PURGE = TRUE """,
    "CREATE_TEMP": lambda i: f"""CREATE OR REPLACE TEMPORARY TABLE TEMP_{i} LIKE {i}""",
    "TRUNCATE": lambda t: f"TRUNCATE TABLE {t}",
    "DROP_TEMP": lambda i: f"DROP TABLE TEMP_{i}",
    "INSERT": lambda i: f"""INSERT INTO {i}
            SELECT * FROM TEMP_{i}""",
    "PKs": lambda keys: "where " + " and ".join("te.%s = t.%s" % (i, i) for i in keys),
    "PUT": lambda i: f"PUT file://{i}.csv @%TEMP_{i}",
}

CADENCES = {
    "LOAD": ("TRUNCATE", "INSERT", "DROP_TEMP"),
    "STAGING": ("CREATE_TEMP", "PUT", "COPY_INTO_TEMP"),
}
METHOD = ["STAGING", "LOAD"]
STEPS = tuple(q for c in (CADENCES[m] for m in METHOD) for q in c)

def generateSQL(steps: Tuple[str], table: str) -> List[str]:
    try:
        sql = lambda s, *i: SQL[s](*i)
    except Exception as e:
        raise signals.FAIL(e)

    lazy = lambda s:  sql(s, table)
    return list(map(lazy, steps))

@task(name="Load tables to Snowflake")
def upload(table_name: str, db_config: dict) -> None:
    with SnowflakeConnection(**db_config) as conn:
        try:
            summary = ""
            cursor = conn.cursor()
            queries = generateSQL(STEPS, table_name)
            for sql in queries:
                try:
                    result = cursor.execute(sql)
                    if "INSERT" in sql:
                        summary += f"\t{table_name}\n\t- {result.rowcount} rows loaded\n"
                except Exception as e:
                    raise signals.FAIL(e)
            if summary != "":
                logger.info(
                    "\n--> TABLE(s) LOAD SUMMARY:\n\t---\n"
                    + "\n ".join(map(str, summary.split("\n")))
                )
        except Exception as e:
            raise signals.FAIL(e)


with Flow('S3 to Snowflake ETL') as flow:

    db_config = {
        "account": PrefectSecret("SNOWFLAKE_ACCOUNT"),
        "user": PrefectSecret("SNOWFLAKE_USER"),
        "password": PrefectSecret("SNOWFLAKE_PASSWORD"),
        "warehouse": "SNOWFLAKE_WAREHOUSE",
        "database": "SNOWFLAKE_DB",
        "schema": "SNOWFLAKE_SCHEMA",
        "role": "SNOWFLAKE_ROLE",
    }

    buckets_and_keys = tuple(
        dict(Bucket='sample_bucket', Key='sample_key')
    )
    # Extract
    s3_data = get.map(buckets_and_keys)
    # Transform
    table_names = transform.map(s3_data)
    # Load
    result = upload(
        mapped(table_names),
        db_config
    )
    
if __name__ == "__main__":
    flow.run(run_on_schedule=False)