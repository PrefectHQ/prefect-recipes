from prefect import task, flow, get_run_logger
from prefect.filesystems import S3
import pandas as pd
import asyncio

@task
async def get_s3_data(s3_block):

    # if from_path() set to None, the bucket path associated with the S3 block instance is used.
    local_path="./dev/file_deposit/"
    await s3_block.get_directory(from_path=None, local_path=local_path)

    logger = get_run_logger()
    logger.info(f"Loaded s3 files to {local_path} directory.")

@task
def read_data():

    df = pd.read_csv('dev/file_deposit/mock_csv_file.csv')
    df_len = df.shape[0]
    logger = get_run_logger()
    logger.info(f"Row Count from s3 File: {df_len}")

    return df


@flow
def flow():
    s3_block = S3.load("mock-data")
    get_s3_data.submit(s3_block=s3_block)
    df = read_data()


if __name__ == "__main__":
    flow()

