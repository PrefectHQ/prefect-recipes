from prefect import flow, task
from prefect_sqlalchemy import SqlAlchemyConnector

@task
def setup_table(block_name: str) -> None:
    with SqlAlchemyConnector.load(block_name) as connector:
        connector.execute(
            "CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);"
        )
        connector.execute(
            "INSERT INTO customers (name, address) VALUES (:name, :address);",
            parameters={"name": "Marvin", "address": "Highway 42"},
        )
        connector.execute_many(
            "INSERT INTO customers (name, address) VALUES (:name, :address);",
            seq_of_parameters=[
                {"name": "Ford", "address": "Highway 42"},
                {"name": "Unknown", "address": "Highway 42"},
            ],
        )

@task
def fetch_data(block_name: str) -> list:
    all_rows = []
    with SqlAlchemyConnector.load(block_name) as connector:
        while True:
            # Repeated fetch* calls using the same operation will
            # skip re-executing and instead return the next set of results
            new_rows = connector.fetch_many("SELECT * FROM customers", size=2)
            if len(new_rows) == 0:
                break
            all_rows.append(new_rows)
    return all_rows

@flow
def sqlalchemy_flow(block_name: str) -> list:
    setup_table(block_name)
    all_rows = fetch_data(block_name)
    return all_rows

sqlalchemy_flow("BLOCK-NAME-PLACEHOLDER")