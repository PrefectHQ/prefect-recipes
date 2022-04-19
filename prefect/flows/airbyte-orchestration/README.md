# Airbyte Orchestration

![](airbyte-prefect.png)

<hr>

## `trigger-sync.py`

A pared-down recipe to schedule and trigger existing Airbyte sync jobs with the Prefect Airbyte Task.

## `sync-airbyte-config.py`

A simple flow for writing airbyte configuration to disk somewhere.

### [Dependencies](pyproject.toml)

    - python = "^3.7"
    - prefect = "^0.15.11"


## Authors
Nate Nowack

[nate@prefect.io](mailto:nate@prefect.io)