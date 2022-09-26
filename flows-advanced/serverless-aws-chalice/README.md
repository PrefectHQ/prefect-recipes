# Serverless AWS Chalice

This recipe demonstrates how to use Prefect in an AWS lambda function managed by [Chalice](https://aws.github.io/chalice/).

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