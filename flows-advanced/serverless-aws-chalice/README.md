# Serverless AWS Chalice

This recipe demonstrates how to use Prefect in an AWS lambda function managed by [Chalice](https://aws.github.io/chalice/). Prefect flows can be executed directly in the AWS Lambda or on a remote agent via an API call back to Prefect Cloud.

## Getting Started

First install the chalice framework from pip,

```sh
pip install -U chalice
```

Next, fill in `.chalice/config.json` from `.chalice/config.json.tpl` either manually or using the command below assuming you have `PREFECT_API_KEY` and `PREFECT_API_URL` set in your environment,

```sh
cat .chalice/config.json.tpl | envsubst > .chalice/config.json
```

Finally deploy the function,

```sh
chalice deploy
```

## Endpoints

Once deployed, you should have a new API with three endpoints,

* `GET /hello/<name>` which runs a Prefect flow on AWS Lambda
* `GET /deployments/<deployment-id>` which returns the deployment data for the given deployment using Prefect's API
* `POST /deployments/<deployment-id>/run` which creates a new flow run for the given deployment using Prefect's API
