import prefect

query = """query {
  task_run(where: { flow_run: { flow_id: { _eq: $flowId } } } ) {
    id
    start_time
    end_time
  }
}"""
client = prefect.client()
runs = client.graphql(query, variables=dict(flowId="<<flow_id>>"))
task_runs = []
for run in runs["data"]:
    task_runs.append({"id": run["id"], "duration": run["end_time"] - run["start_time"]})

# now you can do stuff with those durations
avg_duration = sum(tr["duration"] for tr in task_runs) / len(task_runs)
