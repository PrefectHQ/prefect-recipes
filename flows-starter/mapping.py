"""This example demonstrates how to map a task over a list of inputs to run
them concurrently.

It also shows how to use the `return_state` task option to retrieve
results conditionally based on the state of the task for each input.
"""

from prefect import flow, task


@task
def add_42(x) -> int:
    print(result := x + 42)
    return result


@flow(log_prints=True)
def my_flow() -> tuple[list[int], list[int]]:
    # `map` calls `Task.submit` for each list item and returns a `list[PrefectFuture]`
    some_futures = add_42.map([1, 2, 3])
    some_states = add_42.map([4, None, 6], return_state=True)

    some_results = [future.result() for future in some_futures]
    some_more_results = [
        state.result() for state in some_states if state.is_completed()
    ]

    return some_results, some_more_results


if __name__ == "__main__":
    assert my_flow() == ([43, 44, 45], [46, 48])
