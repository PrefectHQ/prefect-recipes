import os
import pandas as pd
from prefect import flow, task
from prefect.tasks import task_input_hash
from datetime import timedelta
from prefect_sqlalchemy import SqlAlchemyConnector

CSV_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

@task(log_prints=True, tags=["extract"], cache_key_fn=task_input_hash, cache_expiration=timedelta(days=1))
def extract_data(url: str):
    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    df = pd.read_csv(url, compression="gzip")


    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    return df

@task(log_prints=True)
def transform_data(df):
    print(f"pre: missing passenger count: {df['passenger_count'].isin([0]).sum()}")
    df = df[df['passenger_count'] != 0]
    print(f"post: missing passenger count: {df['passenger_count'].isin([0]).sum()}")
    return df

@task(log_prints=True, retries=3)
def load_data(table_name, df):
    
    connection_block = SqlAlchemyConnector.load("postgres-connector") # Loading Our SQL-Alchemy Connector Block
    with connection_block.get_connection(begin=False) as engine:
        df.to_sql(name=table_name, con=engine, if_exists='replace')


@flow(name="Ingest Data", log_prints=True)
def main_flow(table_name: str = "yellow_taxi_trips"):

    
    # Extracting CSV Data from above URL
    raw_data = extract_data(CSV_URL)
    # Transforming the Data
    data = transform_data(raw_data)
    # Loading data using SQL alchemy
    load_data(table_name, data)

if __name__ == '__main__':
    main_flow(table_name = "yellow_trips")