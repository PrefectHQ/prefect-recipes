from prefect import flow
from prefect.deployments import run_deployment
from prefect.filesystems import GCS

def trigger_on_complete(flow, flow_run, state):
    print(
        f"hello from {flow_run.name}'s completion hook |"
        f" the return value was {(r := state.result())!r}"
    )
    run_deployment(
        name="triggered-flow/triggered",
        parameters=dict(prev_result=r)
    )

@flow(
    persist_result=True,
    result_storage=GCS.load("my-result-storage"),
    on_completion=[trigger_on_complete]
)
def foobar() -> str:
    return "foobar"


@flow(log_prints=True)
def triggered_flow(prev_result: str) -> str:
    print(f"got {prev_result=!r}")
