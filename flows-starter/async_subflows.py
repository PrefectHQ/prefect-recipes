"""This example demonstrates how to run asynchronous subflows concurrently
    using `asyncio.gather`.
"""

import asyncio
from prefect import flow


@flow
async def subflow(x):
    print(f"Running subflow with {x=}")
    return x


@flow
async def parent_flow():
    return await asyncio.gather(*[subflow(x) for x in range(3)])


if __name__ == "__main__":
    assert asyncio.run(parent_flow()) == [0, 1, 2]
