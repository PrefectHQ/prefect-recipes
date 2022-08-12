from prefect import task


@task
def signal_task(message):
    if message == 'stop_immediately!':
        raise RuntimeError('Got a signal to end the task run!')


signal_task.fn("continue")
signal_task.fn("stop_immediately!")
