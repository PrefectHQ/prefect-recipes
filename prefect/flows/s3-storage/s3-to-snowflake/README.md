# General ETL Flow using S3 Storage and a Snowflake destination

![](airbyte-prefect.png)

A ETL template utilizing S3 script storage for flow registration and Snowflake for a data warehouse.


### [Dependencies](pyproject.toml)

    - python = "^3.7"
    - snowflake-connector-python = {extras = ["pandas"], version = "^2.7.1"}
    - prefect = "^0.15.10"
    - boto3 = "^1.20.24"


## Authors
Nate Nowack

[nate@prefect.io](mailto:nate@prefect.io)