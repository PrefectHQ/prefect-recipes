"""
Test a subflow in Prefect 2.0
Discourse:
https://discourse.prefect.io/t/unit-testing-best-practices-for-prefect-flows-subflows-and-tasks/1070/2
"""
from prefect import flow, task


@task
def subflow_task(nbr):
    return nbr * 2


@flow
def subflow(nbr):
    subflow_task(nbr)


@flow
def outer_flow():
    subflow()


# test a subflow
def test_subflow(nbr):
    subflow(nbr)


# test a subflow task
def test_subflow_task():
    assert subflow_task.fn(25) == 50


if __name__ == "__main__":
    test_subflow(2)
    test_subflow_task()
