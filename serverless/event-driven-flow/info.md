# Lambda for event-driven Prefect flows


## Setup 
Check your `serverless` framework installation:
```console
sls --version
```

See [installation](https://www.serverless.com/framework/docs/providers/aws/guide/installation) and [provider authentication](https://www.serverless.com/framework/docs/providers/aws/guide/credentials) instructions.



## Development
- Setup Serverless framework specification like [`serverless.yml`](https://github.com/PrefectHQ/cs-templates/serverless/serverless.yml)
    - provider (e.g. `aws` in this template)
        - name
        - stage
        - region
        - runtime
        - Lambda hashing version
        - IAM resource policies
    - functions
        - handler (i.e. what code should our Lambda consist of?)
            - `module.function` (e.g. `handler.run`)
        - layers
            - `{ Ref: PythonRequirementsLambdaLayer }`
        - events (i.e. what should trigger our Lambda?)
            - service (e.g. S3)
                - key: value (e.g. `bucket: my-random-s3-bucket`)
    - plugins
      - `serverless-python-requirements` (for `python` runtimes)

<br>

- Write the `handler.py` to handle the `event` given its `JSON` structure.

## Deployment
To deploy a new version of this Lambda, run the following with the relevant `aws` authentication:

```console
sls deploy
```

