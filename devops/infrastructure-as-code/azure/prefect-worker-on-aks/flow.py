from prefect import task, flow
from prefect import get_run_logger
import pandas as pd
import os
from io import BytesIO

from prefect_azure import AzureBlobStorageCredentials
from prefect_azure.blob_storage import blob_storage_download

# @task(log_prints=True)
def load_from_azure():
    connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
    print(connection_string)
    blob_storage_credentials = AzureBlobStorageCredentials(
        connection_string=connection_string
    )

    data = blob_storage_download(
        blob="file.csv",
        container="prefect-logs",
        blob_storage_credentials=blob_storage_credentials,
    )
    return data


@task
def read_file(data):
    return pd.read_csv(BytesIO(data))


@task(log_prints=True)
def transform_pd(df):
    results = [row["col1"] * row["col2"] for index, row in df.iterrows()]
    print(results)


@flow(log_prints=True)
def transform_flow():
    logger = get_run_logger()

    file = load_from_azure()
    print(type(file))
    df = read_file(file)

    transform_pd(df)


if __name__ == "__main__":
    transform_flow()
