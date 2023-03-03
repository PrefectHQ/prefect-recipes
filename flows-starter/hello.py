from prefect import flow
from prefect.blocks.system import String


@flow(log_prints=True)
def hello(name: str):
    """A simple flow that creates a `String` block with a name
    and greets that `name`.

    Args:
        name: subject of the greeting

    """
    greeting = String(value=name)
    print(f"Hello {greeting.value}!")
    
    greeting.save("demo-string-block", overwrite=True)

if __name__ == "__main__":
    hello(name="Marvin Van Duck")
