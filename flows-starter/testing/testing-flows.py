"""
Test a flow in Prefect 2.0
Discourse:
https://discourse.prefect.io/t/unit-testing-best-practices-for-prefect-flows-subflows-and-tasks/1070/2
"""


from prefect import flow, task
from prefect.testing.utilities import prefect_test_harness


@task
def my_task():
    return 42


@flow
def my_flow():
    return my_task()


def test_my_flow():
    assert my_flow() == 42


def test_my_flow_with_prefect_test_harness():
    with prefect_test_harness():
        # run the flow against a temporary database
        assert my_flow() == 42


if __name__ == "__main__":
    test_my_flow()
    test_my_flow_with_prefect_test_harness()
