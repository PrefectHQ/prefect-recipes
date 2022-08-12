# Related Discourse: 
# https://discourse.prefect.io/t/migrating-to-prefect-2-0-from-flow-of-flows-to-subflows/1318

from prefect import flow, task

@task()
def my_a_task():
    print('Hello from Subflow A')

@task()
def my_b_task():
    print('Hello from Subflow B')

@flow(name="Subflow A")
def subflow_a():
    my_a_task()

@flow(name="Subflow B")
def subflow_b():
    my_b_task()

@flow(name="Main Flow")
def parent_flow():
    subflow_a()
    subflow_b()

if __name__ == "__main__":
    parent_flow()