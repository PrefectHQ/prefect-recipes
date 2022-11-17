from prefect import flow, get_run_logger, task


@task
def cowsay_hello(name: str):
    # The import happens inside the function so that it's not needed at deploy time
    import cowsay

    cowsay.tux(f"Hello {name}!")


@flow
def hello(name: str = "Marvin"):
    get_run_logger().info(f"Hello {name}!")
    cowsay_hello(name)


# This is here so that we can invoke the script directly for testing
if __name__ == "__main__":
    hello()
