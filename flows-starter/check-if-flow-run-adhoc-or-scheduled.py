"""
Discourse:
https://discourse.prefect.io/t/how-can-i-determine-whether-a-flow-run-has-been-executed-ad-hoc-or-was-running-on-schedule/120
"""

import prefect
from prefect import task, flow


@task
def print_task_context():
    pass


@flow(name="autoscheduled_test")
def main_flow():
    print_task_context()
    print("Flow run scheduled through a deployment?")
    print(prefect.context.get_run_context().flow_run.auto_scheduled)


if __name__ == "__main__":
    main_flow()
