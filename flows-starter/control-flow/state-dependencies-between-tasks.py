"""
Discourse:
https://discourse.prefect.io/t/how-can-i-define-state-dependencies-between-tasks/69/2
"""


from prefect import flow, task


@task
def task_1():
    pass


@task
def task_2():
    pass


@task
def task_3():
    pass


@flow(name="flow_with_dependencies")
def main_flow():
    t1 = task_1()
    t2 = task_2(wait_for=[t1])
    t3 = task_3(wait_for=[t2])
    return t3


if __name__ == "__main__":
    main_flow()
