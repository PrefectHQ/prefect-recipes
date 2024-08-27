# Orchestrator Worker Patterns


## Pokemon Example

![Alt text](https://user-images.githubusercontent.com/31014960/216550466-c1b2cc82-500c-4a59-9b24-b86093e2cccf.png)

Using the free PokeAPI, this recipe demonstrates how to asynchronously distribute work across multiple,
infrastructure-independent workers using `run_deployment` and `asyncio.gather`.

The orchestrator flow is responsible for fetching the list of pokemon and then distributing some number
of pokemon to each worker flow, which then processes the pokemon and returns the total weight of the batch.

The results of the worker flows are persisted and gathered within the
orchestrator flow by awaiting `(FlowRun.state.result()).get()`.

The deployment commands below don't specify an infrastructure (and therefore
default to the `Process` infrastructure), since the code in this recipe is infrastructure
agnostic and wouldn't need to change if the deployments used a different infra block.

### Deployment commands
The only thing required in order to run this example is to have Prefect installed and these deployments created:

```bash
prefect deploy pokemon_weight.py:get_total_pokemon_weight -n orchestrator
```

```bash
prefect deploy pokemon_weight.py:get_total_pokemon_weight -n worker
```
