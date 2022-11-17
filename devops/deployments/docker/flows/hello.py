from prefect import flow, get_run_logger

from utilities.tasks import cowsay_hello, log_current_path


@flow
def hello(name: str = "Marvin"):
    get_run_logger().info(f"Hello {name}!")
    cowsay_hello(name)
    log_current_path()


# This is here so that we can invoke the script directly for testing
if __name__ == "__main__":
    hello()
