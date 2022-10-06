{
  "version": "2.0",
  "app_name": "serverless-aws-chalice",
  "environment_variables": {
    "PREFECT_API_KEY": "${PREFECT_API_KEY}",
    "PREFECT_API_URL": "${PREFECT_API_URL}",
    "PREFECT_HOME": "/tmp/.prefect"
  },
  "stages": {
    "dev": {
      "api_gateway_stage": "api"
    }
  }
}
