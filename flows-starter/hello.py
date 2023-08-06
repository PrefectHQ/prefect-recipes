"""This example shows how to use the String block and the `log_prints` setting
to send the value of the block to the Prefect logger."""

from prefect import flow
from prefect.blocks.system import String


@flow(log_prints=True)
def hello(name: str):
    greeting = String(value=name)
    print(f"Hello {greeting.value}!")

    greeting.save("demo-string-block", overwrite=True)


if __name__ == "__main__":
    hello(name="Marvin Van Duck")
