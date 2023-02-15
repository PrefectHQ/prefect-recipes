from prefect import flow
from prefect.blocks.system import String


@flow(log_prints=True)
def hello(block_name: str = "name"):
    """A simple flow that says hello.

    Assumes a `String` block named "name" exists in the active
    Prefect Cloud workspace.

    Args:
        block_name: The name of the block to load. Defaults to "name".

    """
    name = String.load(block_name)
    print(f"Hello {name.value}!")

    if "Expert" not in name.value:
        print("You're about to become a Prefect expert!")
        name.value = name.value + " the Prefect Expert"
        print(f"Your name is now {name.value}!")
        name.save("name", overwrite=True)
    else:
        print("You're already a Prefect expert!")
        print(
            "Check out some Prefect recipes: https://docs.prefect.io/recipes/recipes/"
        )
