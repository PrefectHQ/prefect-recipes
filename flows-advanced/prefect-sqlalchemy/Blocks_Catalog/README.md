# Blocks Catalog

Below is a list of Blocks available for registration in  `prefect-sqlalchemy`.

To register blocks in this module to  [view and edit them](https://orion-docs.prefect.io/ui/blocks/)  on Prefect Cloud, first  [install the required packages](https://prefecthq.github.io/prefect-sqlalchemy/#installation), then

`prefect  block  register  -m  prefect_sqlalchemy` 

Note, to use the `load` method on Blocks, you must already have a block document [saved through code](https://orion-docs.prefect.io/concepts/blocks/#saving-blocks) or [saved through the UI](https://orion-docs.prefect.io/ui/blocks/).

## [Credentials Module](https://prefecthq.github.io/prefect-sqlalchemy/credentials/#prefect_sqlalchemy.credentials)

[DatabaseCredentials](https://prefecthq.github.io/prefect-sqlalchemy/credentials/#prefect_sqlalchemy.credentials.DatabaseCredentials)

Block used to manage authentication with a database.

To load the DatabaseCredentials:

```python
from prefect import flow
from prefect_sqlalchemy.credentials import DatabaseCredentials

@flow
def my_flow():
    my_block = DatabaseCredentials.load("MY_BLOCK_NAME")

my_flow() 
```
For additional examples, check out the [Credentials Module](https://prefecthq.github.io/prefect-sqlalchemy/examples_catalog/#credentials-module) under Examples Catalog.

## [Database Module](https://prefecthq.github.io/prefect-sqlalchemy/database/#prefect_sqlalchemy.database)

[SqlAlchemyConnector](https://prefecthq.github.io/prefect-sqlalchemy/database/#prefect_sqlalchemy.database.SqlAlchemyConnector)

Block used to manage authentication with a database.

Upon instantiating, an engine is created and maintained for the life of the object until the close method is called.

It is recommended to use this block as a context manager, which will automatically close the engine and its connections when the context is exited.

It is also recommended that this block is loaded and consumed within a single task or flow because if the block is passed across separate tasks and flows, the state of the block's connection and cursor could be lost.

To load the SqlAlchemyConnector:

```python
from prefect import flow
from prefect_sqlalchemy.database import SqlAlchemyConnector

@flow
def my_flow():
    my_block = SqlAlchemyConnector.load("MY_BLOCK_NAME")

my_flow() 
```

For additional examples, check out the [Database Module](https://prefecthq.github.io/prefect-sqlalchemy/examples_catalog/#database-module) under Examples Catalog.