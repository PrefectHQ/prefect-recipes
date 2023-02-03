"""
This recipe demonstrates how to asynchronously distribute work across multiple,
infrastructure-independent workers using `run_deployment` and `asyncio.gather`.

The results of the worker flows are persisted and then gathered within the
orchestrator flow by awaiting `(FlowRun.state.result()).get()`.

The deployment commands below don't specify an infrastructure (and therefore
default to the `Process` infrastructure), since the code in this recipe is infrastructure
agnostic and wouldn't need to change if the deployments used a different infra block.
"""

import asyncio, httpx
from typing import Any, Dict, List

from prefect import flow
from prefect.deployments import run_deployment


async def get_pokemon_names(limit: int = 100) -> List[str]:
    """Get a list of pokemon names from the pokeapi"""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://pokeapi.co/api/v2/pokemon?limit={limit}")
        return [pokemon["name"] for pokemon in response.json()["results"]]


async def get_pokemon_info(pokemon_name: str) -> Dict[str, Any]:
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

    # split pokemon name list into a list of lists, each containing `chunk_size` pokemon
    pokemon_name_chunks = [
        pokemon_names[i : i + chunk_size]
        for i in range(0, len(pokemon_names), chunk_size)
    ]

    # since 100 pokemon / 10 workers, my agent will spawn 10 worker sub-flows
    worker_flow_runs = await asyncio.gather(
        *[
            run_deployment(  # returns a FlowRun object
                name="process-pokemon-batch/worker",
                parameters=dict(pokemon_names=pokemon_names),
            )
            for pokemon_names in pokemon_name_chunks
        ]
    )

    # get the results of each worker flow run
    total_pokemon_weight = sum(
        [await run.state.result().get() for run in worker_flow_runs]
    )

    print(f"Total weight of {num_pokemon} pokemon: {total_pokemon_weight} units")


# deploy this flow with:
# prefect deployment build orchestrator-worker-pattern.py:process_pokemon_batch --name worker -a
@flow(persist_result=True)
async def process_pokemon_batch(pokemon_names: List[str]) -> int:
    pokemon_info = [
        await get_pokemon_info(pokemon_name) for pokemon_name in pokemon_names
    ]

    pokemon_batch_weight = sum(pokemon["weight"] for pokemon in pokemon_info)

    return pokemon_batch_weight


if __name__ == "__main__":
    asyncio.run(get_total_pokemon_weight())
