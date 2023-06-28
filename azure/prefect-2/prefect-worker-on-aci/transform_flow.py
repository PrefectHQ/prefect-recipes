from prefect import task, flow
from prefect import get_run_logger
import pandas as pd
import os
from io import BytesIO

from prefect_azure import AzureBlobStorageCredentials
from prefect_azure.blob_storage import blob_storage_download, blob_storage_upload


# Load the Azure Blob Storage credentials
def azure_creds():
    try:
        azure_credentials_block = AzureBlobStorageCredentials.load("boydoblobbo")
        return azure_credentials_block
    except ValueError as e:
        get_run_logger().info(f"No azure_credentials_block found :{e}")
        try:
            connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
            return AzureBlobStorageCredentials(connection_string=connection_string)
        except Exception as f:
            get_run_logger().info("No connection string found")
            connection_string = None
            raise


# Load the data from Azure Blob Storage
def load_from_azure():
    blob_storage_credentials = azure_creds()
    data = blob_storage_download(
        blob="file.csv",
        container="prefect-logs",
        blob_storage_credentials=blob_storage_credentials,
    )
    return data


# Read the data from Azure Blob Storage
@task
def read_file(data):
    return pd.read_csv(BytesIO(data))


# Write the data to Azure Blob Storage
def write_df(data):
    df = pd.DataFrame(data, columns=["output"])
    csv_data = df.to_csv()
    blob = blob_storage_upload(
        data=csv_data,
        container="prefect-logs",
        blob="csv_data",
        blob_storage_credentials=azure_creds(),
        overwrite=True,
    )
    return blob

# Transform the data - just multiplies two columns together
@task
def transform_pd(df):
    results = [row["col1"] * row["col2"] for index, row in df.iterrows()]
    get_run_logger().info(f"{results=}")
    return results


# Reads a file from Azure Blob Storage, transforms it, and writes it back to Azure Blob Storage
@flow(log_prints=True)
def transform_flow():

    file = load_from_azure()
    df = read_file(file)
    transformed_output = transform_pd(df)
    write_df(transformed_output)


if __name__ == "__main__":
    transform_flow()
