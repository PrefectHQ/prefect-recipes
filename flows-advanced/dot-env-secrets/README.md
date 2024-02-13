# Dot-env Secrets

Recipe to quickly load your `.env` secrets into
Prefect's [Secret block](https://docs.prefect.io/latest/api-ref/prefect/blocks/system/#prefect.blocks.system.Secret).

## Reasoning

Often times, I would find myself adapting existing Python script into Prefect.
Storing secret environment variables in a `.env` file is a common solution and
the [dotenv](https://pypi.org/project/python-dotenv/) package can seamlessly load those
variables into the runtime environment.

I needed a tool to load all the variables present in this file into my Prefect workplace
so that my flows no longer need to rely on this file and can just fetch the variable
from Prefect.

## Dependencies

In order to run this script you would
need [python-dot-env](https://pypi.org/project/python-dotenv/).
A *prefect-only* solution is also possible but not (yet) presented in this recipe.
Make sure to be authenticated before running the script.

## Solution

Running this script will:

- Load the variables present in the .env file (specified in the `fp` parameter)
- Convert the variable names to `kebab-case`
- Upload Secret block to your Prefect workspace

## Example

In this example `sample-dot-env` contains a variable `LOAD_DOT_ENV` which is a string.
In the `load_secrets` function we specify the path to the `sample-dot-env` file:

```shell
LOAD_DOT_ENV=it_works
```

```python
if __name__ == "__main__":
    env_file = "flows-advanced/dot-env-secrets/sample-dot-env"
    load_secrets(env_file)
```

Executing it will print each variable name and its block ID

```shell
load-dot-env ffb9096a-efd3-4fcf-a37e-f79b8549f27f
```

You can now use this Secret block in your Prefect code!

![screenshot](static/block-loaded-example.png)

## More

More could be done to this recipe! For example:

- Provide a solution to 'load' all Prefect's secrets onto a file
- Remove the `dotenv` dependency
- Load all variables concurrently