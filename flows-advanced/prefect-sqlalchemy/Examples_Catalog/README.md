# Examples Catalog

Below is a list of examples for  `prefect-sqlalchemy`.

## [Credentials Module](https://prefecthq.github.io/prefect-sqlalchemy/credentials/#prefect_sqlalchemy.credentials)

Create an asynchronous engine to PostgreSQL using URL params.

```python
from prefect import flow
from prefect_sqlalchemy import DatabaseCredentials, AsyncDriver

@flow
def sqlalchemy_credentials_flow():
    sqlalchemy_credentials = DatabaseCredentials(
        driver=AsyncDriver.POSTGRESQL_ASYNCPG,
        username="prefect",
        password="prefect_password",
        database="postgres"
    )
    print(sqlalchemy_credentials.get_engine())

sqlalchemy_credentials_flow()
```

Create a synchronous engine to Snowflake using the  `url`  kwarg.

```python
from prefect import flow
from prefect_sqlalchemy import DatabaseCredentials, AsyncDriver

@flow
def sqlalchemy_credentials_flow():
    url = (
        "snowflake://<user_login_name>:<password>"
        "@<account_identifier>/<database_name>"
        "?warehouse=<warehouse_name>"
    )
    sqlalchemy_credentials = DatabaseCredentials(url=url)
    print(sqlalchemy_credentials.get_engine())

sqlalchemy_credentials_flow()
```
## [Database Module](https://prefecthq.github.io/prefect-sqlalchemy/database/#prefect_sqlalchemy.database)

Create a table, insert three rows into it, and fetch two rows repeatedly.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    database.execute("CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);")
    database.execute_many(
        "INSERT INTO customers (name, address) VALUES (:name, :address);",
        seq_of_parameters=[
            {"name": "Ford", "address": "Highway 42"},
            {"name": "Unknown", "address": "Space"},
            {"name": "Me", "address": "Myway 88"},
        ],
    )
    results = database.fetch_many("SELECT * FROM customers", size=2)
    print(results)
    results = database.fetch_many("SELECT * FROM customers", size=2)
    print(results)
```
Resets connections so `fetch_*` methods return new results.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    results = database.fetch_one("SELECT * FROM customers")
    database.reset_connections()
    results = database.fetch_one("SELECT * FROM customers")
```
Create a table and insert two rows into it.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    database.execute("CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);")
    database.execute_many(
        "INSERT INTO customers (name, address) VALUES (:name, :address);",
        seq_of_parameters=[
            {"name": "Ford", "address": "Highway 42"},
            {"name": "Unknown", "address": "Space"},
            {"name": "Me", "address": "Myway 88"},
        ],
    )
```

Resets connections so `fetch_*` methods return new results.

```python
import asyncio
from prefect_sqlalchemy import SqlAlchemyConnector

async def example_run():
    async with SqlAlchemyConnector.load("MY_BLOCK") as database:
        results = await database.fetch_one("SELECT * FROM customers")
        await database.reset_async_connections()
        results = await database.fetch_one("SELECT * FROM customers")

asyncio.run(example_run())

Load stored database credentials and use in context manager:

from prefect_sqlalchemy import SqlAlchemyConnector

database_block = SqlAlchemyConnector.load("BLOCK_NAME")
with database_block:
    ...
```
Create table named customers and insert values; then fetch the first 10 rows.
```python
from prefect_sqlalchemy import (
    SqlAlchemyConnector, SyncDriver, ConnectionComponents
)

with SqlAlchemyConnector(
    connection_info=ConnectionComponents(
        driver=SyncDriver.SQLITE_PYSQLITE,
        database="prefect.db"
    )
) as database:
    database.execute(
        "CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);",
    )
    for i in range(1, 42):
        database.execute(
            "INSERT INTO customers (name, address) VALUES (:name, :address);",
            parameters={"name": "Marvin", "address": f"Highway {i}"},
        )
    results = database.fetch_many(
        "SELECT * FROM customers WHERE name = :name;",
        parameters={"name": "Marvin"},
        size=10
    )
print(results) 
```
Create a table, insert three rows into it, and fetch a row repeatedly.
```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    database.execute("CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);")
    database.execute_many(
        "INSERT INTO customers (name, address) VALUES (:name, :address);",
        seq_of_parameters=[
            {"name": "Ford", "address": "Highway 42"},
            {"name": "Unknown", "address": "Space"},
            {"name": "Me", "address": "Myway 88"},
        ],
    )
    results = True
    while results:
        results = database.fetch_one("SELECT * FROM customers")
        print(results) 
```

Create a table and insert one row into it.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    database.execute("CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);")
    database.execute(
        "INSERT INTO customers (name, address) VALUES (:name, :address);",
        parameters={"name": "Marvin", "address": "Highway 42"},
    ) 
```

Create a table, insert three rows into it, and fetch all where name is 'Me'.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

with SqlAlchemyConnector.load("MY_BLOCK") as database:
    database.execute("CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);")
    database.execute_many(
        "INSERT INTO customers (name, address) VALUES (:name, :address);",
        seq_of_parameters=[
            {"name": "Ford", "address": "Highway 42"},
            {"name": "Unknown", "address": "Space"},
            {"name": "Me", "address": "Myway 88"},
        ],
    )
    results = database.fetch_all("SELECT * FROM customers WHERE name = :name", parameters={"name": "Me"})
```

Create an asynchronous engine to PostgreSQL using URL params.

```python
from prefect import flow
from prefect_sqlalchemy import (
    SqlAlchemyConnector, ConnectionComponents, AsyncDriver
)

@flow
def sqlalchemy_credentials_flow():
    sqlalchemy_credentials = SqlAlchemyConnector(
    connection_info=ConnectionComponents(
            driver=AsyncDriver.POSTGRESQL_ASYNCPG,
            username="prefect",
            password="prefect_password",
            database="postgres"
        )
    )
    print(sqlalchemy_credentials.get_engine())

sqlalchemy_credentials_flow() 
```
Create a synchronous engine to Snowflake using the  `url`  kwarg.

```python
from prefect import flow
from prefect_sqlalchemy import SqlAlchemyConnector, AsyncDriver

@flow
def sqlalchemy_credentials_flow():
    url = (
        "snowflake://<user_login_name>:<password>"
        "@<account_identifier>/<database_name>"
        "?warehouse=<warehouse_name>"
    )
    sqlalchemy_credentials = SqlAlchemyConnector(url=url)
    print(sqlalchemy_credentials.get_engine())

sqlalchemy_credentials_flow()
```

Create an engine.

```python
from prefect_sqlalchemy import SqlalchemyConnector

sqlalchemy_connector = SqlAlchemyConnector.load("BLOCK_NAME")
engine = sqlalchemy_connector.get_client(client_type="engine")
```
Create a context managed connection.

```python
from prefect_sqlalchemy import SqlalchemyConnector

sqlalchemy_connector = SqlAlchemyConnector.load("BLOCK_NAME")
with sqlalchemy_connector.get_client(client_type="connection") as conn:
    ...
```
Create an synchronous connection as a context-managed transaction.

```python
from prefect_sqlalchemy import SqlAlchemyConnector

sqlalchemy_connector = SqlAlchemyConnector.load("BLOCK_NAME")
with sqlalchemy_connector.get_connection(begin=False) as connection:
    connection.execute("SELECT * FROM table LIMIT 1;")
```

Create an asynchronous connection as a context-managed transacation.

```python
import asyncio
from prefect_sqlalchemy import SqlAlchemyConnector

sqlalchemy_connector = SqlAlchemyConnector.load("BLOCK_NAME")
async with sqlalchemy_connector.get_connection(begin=False) as connection:
    asyncio.run(connection.execute("SELECT * FROM table LIMIT 1;"))
    ```