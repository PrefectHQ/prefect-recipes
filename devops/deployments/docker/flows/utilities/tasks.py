from pathlib import Path

from prefect import get_run_logger, task


@task
def cowsay_hello(name: str):
    # This import happens inside the function so that it's not needed at deploy time
    import cowsay

    cowsay.tux(f"Hello {name}!")


@task
def log_current_path():
    path = Path().absolute()
    get_run_logger().info(f"\n\nThis file was run from {path}\n")
