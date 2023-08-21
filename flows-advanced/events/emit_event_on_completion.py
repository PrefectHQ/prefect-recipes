"""This example uses `emit_event` to trigger a deployment when a flow run completes.

See the `prefect.yaml` for the corresponding trigger definition.
"""

from prefect import flow
from prefect.client.schemas.objects import Flow, FlowRun
from prefect.events import emit_event
from prefect.filesystems import GCS
from prefect.states import State


def emit_on_complete(flow: Flow, flow_run: FlowRun, state: State):
    print(
        f"hello from {flow_run.name}'s completion hook |"
        f" the return value was {(r := state.result())!r}"
    )
    emit_event(
        event="prefect.result.produced",  # this is an arbitrary event name
        resource={
            "prefect.resource.id": (
                f"prefect.result.{flow_run.deployment_id}.{flow_run.id}"
            )
        },
        payload={"result": r},
    )


# prefect deploy emit_event_on_completion.py:foobar_event
@flow(
    persist_result=True,
    result_storage=GCS.load("my-result-storage"),
    on_completion=[emit_on_complete],
)
def foobar_event() -> str:
    return "foobar"


# prefect deploy emit_event_on_completion.py:event_triggered_flow
@flow(log_prints=True)
def event_triggered_flow(prev_result: str) -> str:
    print(f"got {prev_result=!r}")
