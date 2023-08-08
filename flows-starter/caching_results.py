"""This example demonstrates how to use the `cache_key_fn` and `cache_expiration`
    to cache the result of a task for a given input for a certain amount of time.
"""

from datetime import timedelta
from prefect import flow, task
from prefect.tasks import task_input_hash


@task(cache_key_fn=task_input_hash, cache_expiration=timedelta(minutes=1))
def large_expensive_task(x):
    print(f"Running large_expensive_task({x})")
    return x**100


@flow(log_prints=True)
def caching_flow():
    for _ in range(3):
        # The first time this task is called, it will run and cache the result.
        # Subsequent calls will return the cached result, until the cache expires.
        print(f"Result: {large_expensive_task(2):.2e}")


if __name__ == "__main__":
    caching_flow()
