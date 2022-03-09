# Prefect-oriented recipes


## Flows

- [Airbyte Orchestration](airbyte-orchestration/): kicking off Airbyte syncs with a Prefect flow
- [Using S3 Storage](s3-storage): using S3 to register flows as scripts 
    - [demo project](s3-storage/demo-project/):  how to structure a repo where you need custom Python libraries
    - [s3 to snowflake](s3-storage/s3-to-snowflake/): basic ETL template using an S3 source and snowflake destination

## Tools

- [Secret Import](tools/import-secrets-to-cloud/): Import your secrets from your local `~/.prefect/config.toml` into your active Prefect Cloud tenant.