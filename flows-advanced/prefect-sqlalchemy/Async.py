from prefect import flow, task
from prefect_sqlalchemy import SqlAlchemyConnector
import asyncio

@task
async def setup_table(block_name: str) -> None:
    async with await SqlAlchemyConnector.load(block_name) as connector:
        await connector.execute(
            "CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);"
        )
        await connector.execute(
            "INSERT INTO customers (name, address) VALUES (:name, :address);",
            parameters={"name": "Marvin", "address": "Highway 42"},
        )
        await connector.execute_many(
            "INSERT INTO customers (name, address) VALUES (:name, :address);",
            seq_of_parameters=[
                {"name": "Ford", "address": "Highway 42"},
                {"name": "Unknown", "address": "Highway 42"},
            ],
        )

@task
async def fetch_data(block_name: str) -> list:
    all_rows = []
    async with SqlAlchemyConnector.load(block_name) as connector:
        while True:
            # Repeated fetch* calls using the same operation will
            # skip re-executing and instead return the next set of results
            new_rows = await connector.fetch_many("SELECT * FROM customers", size=2)
            if len(new_rows) == 0:
                break
            all_rows.append(new_rows)
    return all_rows

@flow
async def sqlalchemy_flow(block_name: str) -> list:
    await setup_table(block_name)
    all_rows = await fetch_data(block_name)
    return all_rows

asyncio.run(sqlalchemy_flow("BLOCK-NAME-PLACEHOLDER")) 