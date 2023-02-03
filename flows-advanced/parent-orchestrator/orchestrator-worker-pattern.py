"""
This recipe demonstrates how to asynchronously distribute work across multiple,
infrastructure-independent workers using `run_deployment` and `asyncio.gather`.

The results of the worker flows are persisted and retrieved within the orchestrator
using `FlowRun.state.result()`.
"""


import asyncio

import httpx
from prefect import flow
from prefect.deployments import run_deployment


async def get_pokemon_names(limit=100):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://pokeapi.co/api/v2/pokemon?limit={limit}")
        return [pokemon["name"] for pokemon in response.json()["results"]]


async def get_pokemon_info(pokemon_name):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://pokeapi.co/api/v2/pokemon/{pokemon_name}")
        pokemon_info = response.json()
        return {
            "name": pokemon_info["name"],
            "height": pokemon_info["height"],
            "weight": pokemon_info["weight"],
        }


# deploy this flow with:
# prefect deployment build orchestrator-worker-pattern.py:get_total_pokemon_weight --name orchestrator -a
@flow(log_prints=True)
async def get_total_pokemon_weight(num_pokemon: int = 100, chunk_size: int = 10):
    print(f"Processing {num_pokemon} pokemon in batches of {chunk_size}...")

    pokemon_names = await get_pokemon_names(limit=num_pokemon)

    pokemon_name_chunks = [
        pokemon_names[i : i + chunk_size]
        for i in range(0, len(pokemon_names), chunk_size)
    ]

    worker_flow_runs = await asyncio.gather(
        *[
            run_deployment(  # returns a FlowRun object
                name="process-pokemon-batch/worker",
                parameters=dict(pokemon_names=pokemon_names),
            )
            for pokemon_names in pokemon_name_chunks
        ]
    )

    resolved_worker_results = [
        worker_flow_run.state.result() for worker_flow_run in worker_flow_runs
    ]

    total_pokemon_weight = sum(
        [await result.get() for result in resolved_worker_results]
    )

    print(f"Total weight of {num_pokemon} pokemon: {total_pokemon_weight} units")


# deploy this flow with:
# prefect deployment build orchestrator-worker-pattern.py:process_pokemon_batch --name worker -a
@flow(persist_result=True)
async def process_pokemon_batch(pokemon_names: list[str]) -> int:
    pokemon_info = [
        await get_pokemon_info(pokemon_name) for pokemon_name in pokemon_names
    ]

    pokemon_batch_weight = sum(pokemon["weight"] for pokemon in pokemon_info)

    return pokemon_batch_weight


if __name__ == "__main__":
    asyncio.run(get_total_pokemon_weight())
