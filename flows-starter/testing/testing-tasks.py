"""
Test individual tasks with Prefect 2.0. Can also use task.fn()
Discourse:
https://discourse.prefect.io/t/unit-testing-best-practices-for-prefect-flows-subflows-and-tasks/1070/2
"""
from prefect import task
from pytest import raises


@task
def my_task():
    return 42


def test_my_task():
    assert my_task.fn() == 42


def test_my_task_fails():
    with raises(AssertionError):
        assert my_task.fn() == 45


if __name__ == "__main__":
    test_my_task()
    test_my_task_fails()
