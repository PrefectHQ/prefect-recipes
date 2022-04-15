# Handle dbt model failures

When running a suite of dbt models, sometimes a few models will fail due to exogenous circumstances (e.g. network issues, improper authorization, etc). A robust data pipeline uses retries to mitigate intermittent errors, but retrying all models just to retry a few failed models can be expensive and time intensive. Fortunately, we can create a Prefect flow that can rerun only failed models when a dbt run fails. This make our data pipeline robust as well as efficient.

# Prerequisites

Install the dependencies necessary for the demo:
```bash
poetry install
```

We'll also need a local Postres instance to run dbt against. To use Docker to run a local Postgres instance:
```bash
docker run -d --name local_postgres_db -v dbdata:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:14
```

Use can then seed the local Postgres instance with data from dbt's [Jaffle Shop example](https://github.com/dbt-labs/jaffle_shop):
```bash
dbt seed --profiles-dir .
```

# Running the recipe

To run the recipe, run:
```bash
poetry shell python flow.py
```

The flow should run successfully.

This flow makes use of the DbtShellTask and Prefect triggers. The DbtShellTask makes it easy to run dbt command, including the complex command necessary to run only models that failed on the previous run. Here's the command that we're using to rerun failed models:
```bash
dbt build --select result:error+ --defer --state ./target
```
The value for the `--state` flag can be modified to point to another location where dbt state artifacts are stored. 

The flow uses the `all_failed` trigger for the rerun dbt models task to ensure that task only runs if the initial dbt build task fails. The initial dbt build task is also set as the upstream dependency of the rerun task. The final task uses the `any_successful` trigger to ensure that it runs as long as either the initial build of the rerun is successful. Both the initial build and rerun are set as upstream dependencies for the final task.

## Authors
Alex Streed

[alex.s@prefect.io](mailto:alex.s@prefect.io)