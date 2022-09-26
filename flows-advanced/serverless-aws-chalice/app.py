from chalice import Chalice
from prefect import flow, get_run_logger

app = Chalice(app_name='serverless-aws-chalice')


@app.route('/hello/{name}')
def index(name: str):
    hello_from_chalice(name)
    return {'message': 'success'}


@flow
def hello_from_chalice(name: str):
    get_run_logger().info(f"Hello from Chalice, {name}!")
