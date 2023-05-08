from prefect import flow, get_run_logger, task


@task
def hello_world():
    logger = get_run_logger()
    logger.info("Hello world!")


@flow(log_prints=True)
def myflow():
    hello_world()


if __name__ == "__main__":
    myflow()
