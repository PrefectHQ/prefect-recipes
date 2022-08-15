from prefect import task, flow, get_run_logger
from prefect.filesystems import S3
import pandas as pd
import asyncio

# Its interesting that we need to use async for this? 
# I though the way Prefect handled concurrency, we didn't need 
@task
async def get_s3_data(s3_block):

    # if from_path() set to None, the bucket path associated with the S3 block instance is used as the root.
    local_path="./dev/file_deposit/"
    await s3_block.get_directory(from_path=None, local_path=local_path)

    logger = get_run_logger()
    logger.info(f"Loaded s3 files to {local_path} directory.")

@task
def read_data():

    # Is there a way I can read the filename from s3? 
    # I rely on this filename not changing.
    df = pd.read_csv('dev/file_deposit/mock_csv_file.csv')
    df_len = df.shape[0]
    logger = get_run_logger()
    logger.info(f"Row Count from s3 File: {df_len}")

    return df

@task
def write_data():
    pass


@flow
def flow():
    # I was getting errors loading this in a task - is that normal?
    s3_block = S3.load("mock-data")
    get_s3_data.submit(s3_block=s3_block)
    df = read_data()


if __name__ == "__main__":
    flow()

