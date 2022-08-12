"""
Discourse:
https://discourse.prefect.io/t/can-my-subflow-use-a-different-task-runner-than-my-parent-flow/101
"""

from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner


@task
def hello_local():
    print("Hello!")


@task
def hello_dask():
    print("Hello from Dask!")


@flow(task_runner=SequentialTaskRunner())
def my_flow():
    hello_local()
    my_subflow()
    hello_local()


@flow
def my_subflow():
    hello_dask()


my_flow()
