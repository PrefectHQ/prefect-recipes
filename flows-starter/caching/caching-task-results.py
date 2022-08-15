"""
Discourse:
https://discourse.prefect.io/t/how-can-i-cache-a-task-result-for-two-hours-to-prevent-re-computation/67
"""


import datetime
from prefect import task
from prefect.tasks import task_input_hash


@task(cache_key_fn=task_input_hash, cache_expiration=datetime.timedelta(hours=2))
def my_task():
    pass
