"""
Purpose: Retrieves data from API from last hour. Appends records to the
Snowflake table, "ABC_RAW"."RAW"."ABC_TABLE". On the first run, this
flow will retrieve all historical data from the ABC API. After the first
successful run, the same flow will retrieve only data since the last successful
load of data into Snowflake.

Requirements:
Assumes you have the following blocks in your workspace:
- a SnowflakeCredentials block named "abc-support-sysadmin"
- a SnowflakeConnector block named "abc-raw"
- a Secret block named "abc-credentials" containing the following:
{
    "endpoint": "my-endpoint",
    "api-user": "my-api-user",
    "api-access-code": "my-api-access-code"
}

If you are unable to create these blocks in the UI because SnowflakeCredentials or
SnowflakeConnector block types do not exist,
run
`pip install prefect-snowflake`
`prefect block register -m prefect_snowflake.credentials`
`prefect block register -m prefect_snowflake.database`
"""


import asyncio
import json
from datetime import date
from datetime import datetime as dt
from datetime import timedelta
from typing import List

import aiohttp
import pytz
from pandas import DataFrame, json_normalize
from prefect import flow, task
from prefect.blocks.system import Secret
from prefect.logging import get_run_logger
from prefect_snowflake.database import SnowflakeConnector
from snowflake.connector.errors import ProgrammingError
from snowflake.connector.pandas_tools import write_pandas

# data to be loaded into Snowflake target table
abc_data = []


@task(name="Step 1 of 3: Retrieve last time that data was loaded into Snowflake table")
def get_start_time(target_table: str) -> dt:

    """
    A pre-check on the target table such that extract_data_from_api() will
    pull only data after the last load time. This ensures no duplicate data
    while fulfilling an APPEND ONLY requirement. If there is no data
    in the target table (or it doesn't exist), we want to load all existing
    data we can from the API. In that case, the start time is 07/01/2022.

    Args:
        - target_table (str): The name of the Snowflake table in which to
        check whether rows exist.

    Returns:
        - start_datetime (dt): The datetime from which to begin loading data.
    """

    logger = get_run_logger()

    # Load a Snowflake block containing account, user, password, warehouse,
    # database, schema, and role
    snowflake_auth = SnowflakeConnector.load("abc-raw")

    with snowflake_auth.get_connection() as conn:
        with conn.cursor() as cur:
            # attempt to retrieve data from the target_table
            try:
                select_from_table_stmt = (
                    f"SELECT MAX(ELT_LOADED_ON) FROM {target_table} LIMIT 1"
                )
                max_elt_loaded_on_tms = cur.execute(select_from_table_stmt).fetchone()[
                    0
                ]
                logger.info(f"Max ELT_LOADED_ON tms: {max_elt_loaded_on_tms}")

            # if we cannot, then do a historical load into the table
            except ProgrammingError as e:
                if f"Object '{target_table}' does not exist or not authorized." in str(
                    e
                ):
                    logger.info(e)
                    max_elt_loaded_on_tms = "2022-07-01T00:00:01.000000Z"
                else:
                    logger.error(f"snowflake.connector error occurred: {str(e)}")
                    raise
            else:
                logger.info(f"Max ELT_LOADED_ON tms: {max_elt_loaded_on_tms}")

    start_datetime = dt.strptime(max_elt_loaded_on_tms, "%Y-%m-%dT%H:%M:%S.%fZ")

    return start_datetime


@flow(name="Retrieve data from all depts since last successful run")
async def _get_data_from_all_depts(
    dept_code_list: List[int], endpoint_, headers_, startDt_list: List
) -> None:

    """
    Retrieves data from all departments at all dates since last successful run.
    As this runs hourly, it is likely to be data only from the last hour
    from each dept.

    Args:
        - dept_code_list: A list of dept IDs each referenced as a
        batchSystemCode.
        - endpoint_: ABC endpoint for requests.
        - headers_: Pass in credentials.
        - startDt_list: startDt params for ABC.
    """

    logger = get_run_logger()

    async with aiohttp.ClientSession() as session:
        tasks = []

        # iterate through all necessary dates and depts
        [
            tasks.append(
                asyncio.ensure_future(
                    session.get(
                        url=endpoint_,
                        headers=headers_,
                        params={
                            "startDate": date,
                            "units": "metric",
                            "batchSystemCode": code,
                        },
                    )
                )
            )
            for code in dept_code_list
            for date in startDt_list
        ]

        # this will be used as the value in ELT_LOADED_ON column for this load
        pst = pytz.timezone("America/Los_Angeles")
        abc_request_time = dt.strftime(dt.now(tz=pst), "%Y-%m-%dT%H:%M:%S.%fZ")

        responses = await asyncio.gather(*tasks, return_exceptions=True)
        for response in responses:
            if response.status == 200:
                abc_data.extend(await response.json())
            else:
                logger.error(
                    f"Response Error: {response.status} for request {response}"
                )

        return abc_request_time


@flow(
    name="Step 2 of 3: Extract load summary data from ABC API",
    retries=2,
    retry_delay_seconds=300,
)
def extract_data_from_api(start_time: dt, batchSystemCode_list: List[int]) -> DataFrame:

    """
    Given a list of depts and a start time, will retrieve needed data from API.

    Examples:
    - If there is no data in the table, and the time is
    2022-08-25T10:30:01.000000Z, the list of startDts will look like so:
    ["2022-07-01T00:00:01.000000Z", "2022-07-02T00:00:01.000000Z",
     "2022-07-03T00:00:01.000000Z", ..., "2022-09-12T00:00:01.000000Z"]
     That means we will load data from these dates, UP TO the current time.
     We can only request one date and one dept at a time from ABC.

    - If there is data in the table, and the time is
    2022-08-25T10:30:01.000000Z, we would look at the latest ETL_LOADED_ON
    value in the Snowflake table to see the last time data was loaded. Let's
    say MAX(ETL_LOADED_ON) = 2022-08-23T10:30:01.000000Z, we'll add one
    second to that, and the list of startDts will look like so:
    ["2022-08-23T10:30:02.000000Z", "2022-08-24T00:00:01.000000Z",
    "2022-08-25T00:00:01.000000Z"]

    This enables us to load the remaining data from 2022-08-23 (but no
    overlap), all data from 2022-08-24, and data up until now on 2022-08-25.

    Args:
        - start_time (dt): The time at which to start loading data
        - batchSystemCode_list (list): Dept IDs, each referenced as a
        batchSystemCode.

    Returns:
        - df (DataFrame): retrieved ABC API data.
    """

    logger = get_run_logger()

    ABC_CREDENTIALS = json.loads(Secret.load("abc-credentials").get())

    endpoint = ABC_CREDENTIALS["endpoint"]
    headers = {
        "api-user": ABC_CREDENTIALS["api-user"],
        "api-access-code": ABC_CREDENTIALS["api-access-code"],
    }

    todays_date = date.today()
    start_time_list_formatted = []
    next_day = (start_time + timedelta(days=1)).date()

    while next_day <= todays_date:

        # append it to list
        start_time_list_formatted.append(next_day)
        # increment day
        next_day = next_day + timedelta(days=1)

    # format list of startDt requests for ABC - must be in this format
    start_time_list_formatted = [
        date.strftime("%Y-%m-%d") + "T00:00:01.000000Z"
        for date in start_time_list_formatted
    ]

    # increment startDt by 1 second to get data since last load
    new_start_time = dt.strftime(
        start_time + timedelta(seconds=1), "%Y-%m-%dT%H:%M:%S.%fZ"
    )
    start_time_list_formatted.append(new_start_time)

    logger.info(f"start_time list: {start_time_list_formatted}")

    time_of_abc_request = asyncio.run(
        _get_data_from_all_depts(
            batchSystemCode_list, endpoint, headers, start_time_list_formatted
        )
    )

    if abc_data:
        df = json_normalize(abc_data)
        # add tms when loaded into Snowflake
        df["ELT_LOADED_ON"] = time_of_abc_request
        logger.info(f"Nbr of records from all depts: {len(df)}")
        assert len(abc_data) == len(df)
        return df

    else:
        logger.info("No new records from any depts.")
    return None


@task(name="Step 3 of 3: Load data into Snowflake")
def load_data_into_snowflake(
    df: DataFrame, target_table: str, ddl: str
) -> tuple[bool, int]:

    """
    Given ABC data, a Snowflake table name, and a DDL, will load the data
    into the designated Snowflake table. If this run is a historical load,
    likely we will need to create the table as it won't exist.

    Args:
        - df (DataFrame): ABC data to be loaded into the Snowflake table
        - target_table (str): the table into which to load the data
        - ddl (str): Snowflake DDL for designated table

    Returns:
        - tuple[bool, int]: True if successfully wrote df to Snowflake else
        False; number of rows written as int.
    """

    logger = get_run_logger()

    # use Snowflake block
    snowflake_auth = SnowflakeConnector.load("abc-raw")
    database = snowflake_auth.database
    schema = snowflake_auth.schema_

    create_table_stmt = f"CREATE TABLE IF NOT EXISTS {target_table} ({ddl})"

    with snowflake_auth.get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(create_table_stmt)
            logger.info("Executed SQL statement:" f"{create_table_stmt}")

        # load the data into Snowflake
        success, _, num_rows, _ = write_pandas(
            conn=conn, df=df, table_name=target_table, database=database, schema=schema
        )

        logger.info(f"Success: {success}. Nbr of rows inserted: {num_rows}")

    return success, num_rows


@flow(name="Update ADB Snowflake Table", retries=2, retry_delay_seconds=900)
def abc_elt_flow(batchSystemCode_list: List[int]) -> None:

    """Flow which
    1. Calculates the last successful load of data into Snowflake in order
    to set the correct start_time.
    2. Extracts the data since the start_time from ABC API into a df.
    3. If new data from ABC API, loads df into Snowflake table.

    Args:
        - batchSystemCode_list: A list of dept IDs each referenced as a
        batchSystemCode.
    """

    target_table = "ABC_TABLE"

    start_tms = get_start_time(target_table)

    df = extract_data_from_api(start_tms, batchSystemCode_list)

    if isinstance(df, DataFrame):

        # clean column names for Snowflake
        df.columns = [col.replace(".", "_").upper() for col in df.columns]

        # create ddl
        ddl = "".join([col + " STRING, " for col in df.columns])[:-2]

        load_data_into_snowflake(df, target_table, ddl)


if __name__ == "__main__":
    abc_elt_flow(batchSystemCode_list=[1, 3, 4, 8, 12, 13, 15])
