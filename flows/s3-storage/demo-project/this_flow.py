from prefect import Flow, Parameter, task
from prefect import run_configs
from prefect import executors
from prefect.backend import get_key_value
from prefect.engine import signals
from prefect.engine.results import S3Result
from prefect.run_configs import KubernetesRun
from prefect.storage.s3 import S3
from prefect.tasks.secrets import PrefectSecret
import requests
from prefect.executors import LocalDaskExecutor

@task(name="An extract function")
def extract(source_GET_params: dict) -> dict:
    try:
        r = requests.get(**source_GET_params)
        r.raise_for_status()
    except requests.exceptions.HTTPError as err:
        raise signals.FAIL(f"Failed to get source with status: {r.status_code}")

@task(name="A transform function")
def transform(raw_piece_of_data: dict) -> object:
    # do any necessary transformations
    return raw_piece_of_data 

@task(name="A load function")
def load(clean_data: object) -> None:
    s3_result = S3Result(bucket='bucket_of_interesting_results_from_our_flow')
    # load clean_data as needed to your destination
    # use PrefectSecret('DB_cnx_config') as needed
    pass
    
PROJECT = "DEMO"

S3_storage = S3(
    bucket = "s3-flow-storage",
    key = f"{PROJECT}/flow.py",
    stored_as_script = True,
    local_script_path = "flow.py",
)

with Flow(
    name='Move Some Data',
    # run_config=KubernetesRun(image=get_key_value('TPS_BASE_IMAGE_TEST')),
    executor=LocalDaskExecutor(),
    storage=S3_storage,

) as flow:
    # define sources somehow or load source schemas from elsewhere
    sources = Parameter('sources', default=[dict(url='https://github.com/timeline.json')])
    raw_data = extract.map(sources)
    clean_data = transform.map(raw_data)
    result = load(clean_data=clean_data)

flow.run()