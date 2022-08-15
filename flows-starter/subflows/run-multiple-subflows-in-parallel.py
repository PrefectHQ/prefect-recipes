"""
Discourse:
https://discourse.prefect.io/t/how-can-i-run-multiple-subflows-or-child-flows-in-parallel/96
"""
import asyncio
from prefect import flow


@flow
async def subflow_1():
    print("Subflow 1 started!")
    await asyncio.sleep(1)


@flow
async def subflow_2():
    print("Subflow 2 started!")
    await asyncio.sleep(1)


@flow
async def subflow_3():
    print("Subflow 3 started!")
    await asyncio.sleep(1)


@flow
async def subflow_4():
    print("Subflow 4 started!")
    await asyncio.sleep(1)


@flow
async def main_flow():
    parallel_subflows = [subflow_1(), subflow_2(), subflow_3(), subflow_4()]
    await asyncio.gather(*parallel_subflows)


if __name__ == "__main__":
    asyncio.run(main_flow())
