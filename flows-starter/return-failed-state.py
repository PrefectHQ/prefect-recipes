"""
Discourse:
https://discourse.prefect.io/t/how-to-ensure-that-my-tasks-immediately-fail-if-a-specific-upstream-task-failed/111
"""
import random
from prefect import task, flow


@task
def do_something_important():
    bool_ = random.random() > 0.5
    print(f"Is the number > 0.5? {bool_}")
    if bool_:
        raise ValueError("Non-deterministic error has occured.")


@task
def fail():
    raise RuntimeError("Bad task")


@task
def succeed():
    print("Success")


@task
def always_run():
    print("Running regardless of upstream task's state")


@flow
def main_flow():
    a = do_something_important()
    fail(wait_for=[a])
    succeed(wait_for=[a])
    always_run()


if __name__ == "__main__":
    main_flow()
