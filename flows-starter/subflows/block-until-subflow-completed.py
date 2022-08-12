"""
Discourse:
https://discourse.prefect.io/t/how-can-i-create-a-subflow-and-block-until-it-s-completed/94
"""

from prefect import flow, task
import time


@flow
def subflow_1():
    print("Subflow 1 started!")
    time.sleep(3)
    return "Hello from subflow!"


@flow
def subflow_2():
    print("Subflow 2 started!")
    time.sleep(3)
    return "Hello from the second subflow!"


@task
def normal_task():
    print("A normal task")


@flow
def main_flow():
    state_subflow_1 = subflow_1()
    state_subflow_2 = subflow_2()
    normal_task(wait_for=[state_subflow_1, state_subflow_2])


main_flow()
