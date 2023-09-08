### Using State Hooks to trigger Deployments

This recipe demonstrates two different ways to trigger a deployment when a Prefect flow run completes: one using `run_deployment` within a state hook, and the other using `emit_event` within a state hook.

---

#### Method 1: `run_deployment` in a state hook

- Directly calls `run_deployment` to trigger the downstream deployment.
- Passes the result of the upstream flow run as a parameter to the downstream deployment.

#### Method 2: `emit_event` in a state hook

- Emits a custom event using `emit_event` that is meant to trigger the downstream deployment.
- Again, passes the result of the upstream flow run as a parameter to the downstream deployment, but via the event payload.
- Allows for more flexible triggering logic / downstream actions, defined in a trigger attached the deployment in `prefect.yaml`.

---

### Key points

| Feature             | Method 1: `run_deployment` | Method 2: `emit_event`  |
|---------------------|----------------------------|-------------------------|
| Invocation Mechanism| Direct API call       | Emit Event -> Trigger -> Action |
| Requires result persistence | Yes                     | Yes                |
| Requires Prefect Cloud | No                     | Yes                |

NOTE: Both methods require result persistence, because when you call `state.result()` in a state hook (outside the flow run context), the result is retrieved via the Prefect API, not from the flow's local python process.