# Installing and Configuring Prefect Prometheus Exporter

## Summary

This document is intended to be both an overview, and the step-by-step requirements to deploy the Prefect Prometheus Exporter into your environment.

The Prefect Prometheus Exporter is a containerized Python application. It queries for data using GraphQL from the Prefect Server instance (which can be hosted anywhere), converts it, and serves it on the /metrics endpoint that Prometheus can scrape. Prometheus is a simple time-series database that collects this information, and is in turn consumed and rendered in a more visibly friendly way by Grafana.

The implementation looks like this:

![Document systems (2).png](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/Diagram.png)

## Requirements

To successfully implement and configure the Prefect-Prometheus-Exporter, the following are required:

- [Prometheus-Operator](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- Prefect Server / Prefect Cloud endpoint is accessible
- Helm
- Public / Private Container Registry
- Docker

This document will focus on installation and configuration on the Exporter specifically, as this is being introduced to the architecture / system. 

Grafana and Prometheus should already have at least a default installation in operational environment, but do not need to be in-cluster. 

It is also assumed there is a currently accessible Prefect configuration. This document and configuration is written solely around Prefect Apollo (Prefect 1.0) which relies on GraphQL. 
This work will be re-factored to support Prefect Orion (Prefect 2.0) which transitions to a RESTful API.

## Components

1. **Prefect Server**: depicted above, the entry point for requests is the Apollo pod, by default on `:4200`. 
2. **Prefect** **Database:** where all the information is stored - this data is retrieved by requests from Apollo through Hasura/GraphQL. Default implementations are either SQLite or Postgres.
3. **Prefect**-**Prometheus**-**Exporter:** This is the container that will be built and inserted into the cluster. It is functionally a proxy - it retrieves information from the database through queries to Apollo, and exposes those metrics by default on `:8000/metrics`.
4. **Prometheus:** This is the time-series database that aggregates and scrapes metrics in a ‘pull’ model. Each ‘target’ that it scrapes is configured through a ServiceMonitor (detailed below). A ServiceMonitor is a CRD (Custom Resource Definition) - it is not native to Kubernetes, but created as part of the Prometheus-Operator installation. It reaches targets on the port specified in their ServiceMonitor manifest. It is exposed by default on `:9090`.
5. **Grafana:** This is the visualization service and dashboarding. Grafana is configured with Prometheus as a data-source. By default it is accessible on `:3000`.

## Source Repository

The source location for this content is [PrefectHQ/prefect-recipes](https://github.com/prefecthq/prefect-recipes).
This is a base ‘recipe’ - the expectation is that the helm-chart and docker_setup are modified for each environment (detailed below).
The directory contains the following:

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/Tree.png)

- `Dockerfile` is used to build the image.
- `dashboard.json` is the current Prefect Dashboard as Code - this can be imported to Grafana.
- `docker_setup` is a simple shell script - details below.
- `graphql_query.py` is a sample Python GraphQL request. It can be used as a standalone for testing syntax.
- [`monitor.py`](http://monitor.py) is the core application, and entry point for the Docker container.
- `prefect-prometheus` is the Helm Chart to install the container and follows typical Helm structure.
- `requirements.txt` is a list of the required packages to install with the container.

## 1 - Building and Pushing the Image

Steps below are displayed to build the container. In this set of instructions, I am using a development registry.

<aside>
💡 The registry should be replaced with your in-house / organizational container registry.
It is possible that this image will be officially published on the PrefectHQ Docker Hub, but is not at this time. Items that are expected to be customized will be marked **bold**

</aside>

```bash
vim docker_setup

#!/bin/bash

export IMAGE_REGISTRY="**chaboy**" # Your registry should change
export PROJECT_NAME="prefect-prometheus-exporter"
export PROJECT_VERSION="**1.2.3-amd64**" # This was version syntax I used. 

echo "$IMAGE_REGISTRY/$PROJECT_NAME:$PROJECT_VERSION"
docker build --platform=linux/amd64 -t "$IMAGE_REGISTRY/$PROJECT_NAME:$PROJECT_VERSION" -f ./Dockerfile .
docker push "$IMAGE_REGISTRY/$PROJECT_NAME:$PROJECT_VERSION"
```

From the directory where your Dockerfile exists, this script can be executed: `./docker_setup`

This will set your registry, project name, version, build, then push the image.

## 2 - Updating the Helm Chart

The helm chart that is provisioned in the repository is similarly configured to use a development registry and default environment variables.

In `values.yaml`, the variables should be updated to reflect the image pushed in Step 1 - Building and pushing the image.

```yaml
image:
  repository: **chaboy/prefect-prometheus-exporter**
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: **"1.2.3-amd64"**

service:
  enabled: true
  type: ClusterIP
  port: **8000**       # The port the container can be accessed on
  targetPort: **8000** # The port the container will serve on.

# port:targetPort is comparable to port-forwarding.
# The container is exposing the targetPort at the application layer
# The targetPort can be accessed outside via the port:
 
metricsPath: /metrics
scrapeDelay: 300
graphqlEndpoint: **http://localhost:4200** # The Apollo Server
```

Describing items listed above that need changing.

- `Repository` should reflect the registry where the image was pushed in Step 1.
- `Tag` should reflect the tag created for the image in Step 1.
- `port` can be left as default if desired. This is the port Prometheus will scrape against.
- `targetPort` Can be left as default if desired. This is the container port that is exposed. A connection to :port will map to :targetPort.
- `GraphQLEndpoint` is a URL or IP address to access your Prefect instance - this is typically how you access your UI:

```yaml
# To access the pod internal DNS name. 
prefect-server-apollo is the name of the pod
.prefect is the namespace the pod resides in
graphqlEndpoint: http://prefect-server-apollo.prefect:4200/
```

## 3 - Installing the Helm Chart

<aside>
💡 As mentioned in requirements - `ServiceMonitor.yaml` is predicated upon custom resource definitions that are provisioned as part of Prometheus-Operator. If Prometheus-Operator is not already installed, it’s advised to complete that for the environment prior to next steps detailed below.

</aside>

As the Helm chart is shipped with the repository, it is not currently present in a Helm Repository.
It is likely this will change when the Prefect-Prometheus-Exporter is added to the main Prefect Docker image registry.

From the same directory you built the `Dockerfile`, execute the following to install the Helm Chart:

```bash
#To install the prefect-prometheus chart, referencing the ./prefect-prometheus folder.
helm install prefect-prometheus ./prefect-prometheus
```

```bash
#To upgrade the existing chart, deploy a new image, or override values.
helm upgrade prefect-prometheus ./prefect-prometheus
```

Optionally, a `.yaml` can be created to isolate the changes listed in Step 2 and passed as an argument. The arguments passed in this fashion will supersede those defined in `values.yaml`.
This can be useful if you have separate Prefect Servers you’d like to apply (using separate GraphQL endpoints) or different environments entirely.

```yaml
vim custom_values.yaml
image:
  repository: **chaboy/prefect-prometheus-exporter**
  tag: **"1.2.3-amd64"**

service:
  port: **8000**
  targetPort: **8000**

graphqlEndpoint: https://apollo.prefect-installation.com
```

This override of `custom_values.yaml` can then be applied:

```yaml
helm upgrade prefect-prometheus ./prefect-prometheus -f custom_values.yaml
```

## 4 - Validating Prometheus

This step is solely focused on Prometheus configuration to observe the prefect-prometheus-exporter.

Access the Prometheus service by either port-forwarding directly into the cluster if the service is not exposed. This requires your `KUBECONFIG` to be set to the cluster, assuming Prometheus is running inside the cluster.

```bash
#services/prometheus-kube-prometheus - services is the definition you want to forward
#prometheus-kube-prometheus is the specific name of the service you wish to forward
#This service is listening on :9090 - we are forwarding our own 9090 traffic to it
#-n prometheus is for the "prometheus" namespace - this might be different depending on where prometheus is installed
kubectl port-forward services/prometheus-kube-prometheus-prometheus 9090:9090 -n prometheus
```

You can then access the page via [localhost:9090](http://localhost:9090).

Alternatively, if the service has an IP address and is exposed (either internally or externally) you can access that *ip:port* address directly.

Once in the Prometheus configuration, you can validate that the exporter is visible by navigating to “Status → Targets”. We can see in the image under “Targets” that prefect-prometheus is **(1/1 up)**, indicating Prometheus is aware and pulling metrics from this configuration.

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/prometheus.png)

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/prom%20target.png)

## 5 - Accessing the Grafana Dashboard

This is identical to Step 4. Here we are substituting the Prometheus Service and Endpoint for Grafana:

```bash
# Via port-forwarding
kubectl port-forward services/prometheus-grafana 3000:3000 -n prometheus
```

Then we can access Grafana on  [localhost:3000](http://localhost:3000). Alternatively, we can reach the endpoint directly through `ip:port`.

Once logged in, you’ll be presented with a list of recently viewed dashboards. If this is the first time logging in, verify Grafana is pulling in metrics from Prometheus:

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/grafana%20config.png)

## 6 - Installing Grafana Dashboards

There are a wide number of open-source curated dashboards available.
We can install these by selecting the “+” symbol on the page, and selecting ‘Import’.

Imports can be done either by “ID” or by a URL.

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/grafana%20import.png)

A few that I have found useful and find relevant and beneficial are (with their import ID):

- Kube State Metrics - 13332
- Ingress Nginx - 9614
- Kubernetes - 15661
- Istio Control Plane - 7645
- Istio Mesh - 7639
- Istio Workload - 7630
- Istio Service - 7636
- External DNS - 15038

## 7 - Installing the Prefect Prometheus Dashboard

The `dashboard.json` included in the Github repository is the json representation of the Dashboard for the Prefect Prometheus Exporter. This file can be opened in your favorite code editor, copied to clipboard, and pasted under the ‘Import’ page to be brought in.

At the time of writing, the dashboard appears as follows. Note that both the metrics and dashboard can be customized to your preference, so this is only a current representation for documentation purposes.

![Untitled](https://github.com/PrefectHQ/prefect-recipes/blob/prom-monitoring/prefect-v1-legacy/devops/monitoring/imgs/grafana_dashboard.png)

## 8 - Interpreting the Prefect Dashboard

This description should be expected to change as the dashboard and metrics are modified.
The description summary below uses the current dashboard represented above:

- `Flow Run Percent Success by Project` is a dynamic panel based on number of projects. The value is `Flow Runs Success / Flow Run Total` per project. The thresholds are 0-60% = RED 61%-95% = YELLOW 96-100% = GREEN
- `Upcoming Flows` is a query that aggregates all flows based on the `Scheduled` state. This metric is returned by default from the exporter every 300 seconds.
- `Active Flow Running` is an aggregate of all flows currently in the `Running` state.
This metric is returned by default from the exporter every 300 seconds.
- `Success Flow Rate` is an aggregate measure of all projects `Successful Runs` / `All Runs`. This is not specific per project or flow, it is just a barometer of overall success rate.
- `Failed Flow Rate` is the total number of failed Flows by project over the selected timespan. Any failed number over 0 is depicted in RED.
- `Flows Per Hour` reports the flow runs that are successful over time. As flows are successful or failed, they are displayed here with the associated time stamp.
- `Flows Run Success` is a line chart depicting success rate by project over time. `Flow Run Percent Success by Project` shows the most up-to-date calculation with a quick glance. This chart shows the trending behavior by project over time.
- `Flow Count` is a simple graph depicting the number of registered flows across time and project. As flows are registered or deprecated in a project, this displays that total. This can help determine larger project counts, and narrow focus.
- `Total Flow Run Count` is intended to be a state per project, by status (Running, Scheduled, Upcoming, etc.). This ended up being a very noisy graph across projects and states, so is currently welcome to suggestion of what additional visibility would be useful.

## 9 - Extending Functionality

Database impact is a massive consideration when choosing to extend the functionality of this. Care should be taken when selecting additional queries to introduce as, depending on the query in particular, the scale could be up to O(N * P), where N is number of flows and P is the number of projects. 

A more concrete example of this might be that you wish to query every flow for its start and stop time to determine run time. 
Such a query would require building a list of all projects (P) to comb through first.
From that number of projects, we would then need to query each flow (N) for its individual Start / Stop time and perform some arithmetic on the container side.
If there are 10 Projects and 100 flows active per project, this would constitute 1000 API requests on the database.

With that in mind, functionality extension is fairly straightforward.

1. Building new queries: An idea of the query or results you wish to view or return from GraphQL. A sample query is included with the repository as `graphql_query.py`. A number of queries are already included as part of `[monitor.py](http://monitor.py)` that can additionally be used for reference. An interactive API is available through the Apollo endpoint to determine a suitable query. [Learn more about the Prefect Interactive API](https://docs-v1.prefect.io/orchestration/ui/interactive-api.html).
2. What the results from your query represent. Prometheus supports four measurement types.
    1. **Counter**: this number only goes up. Generally for things like “totals” - total number of web requests, or total number of queries made. 
    2. **Gauge:** this number can increase and decrease. Almost all queries used in documenting this are gauges. While some *could* conceivably be counters, Projects, and Flows can be deleted, which would decrement the variable.
    3. **Histogram**: used for “buckets”. A good example for histograms would be latencies. 
    90% of requests occur in < 50ms. 
    9% of requests occur in < 500ms. 
    1% of requests are satisfied in < 1m. 
    This would allow you to depict number of occurrences in defined quantiles.
    4. Summaries are near identical to histograms but expose streaming quantile information, as opposed to defined, captured bucket quantiles. [See more definitive breakdowns and usage](https://prometheus.io/docs/concepts/metric_types/).
3. **Creating the prometheus variable**.

```python
# Gauge is the type of variable to create
# 'prefect_flowruns_submitted' is the keyed metric to expose to Prometheus and is selectable in Grafana
# After the key-name is a brief description of the metric
# Lastly are (OPTIONAL) labels -  ['project_id', 'project_name']. 
# These labels are interpreted during the run and applied to each exposed item.
# This is how to determine '80 flows for project a' vs '22 flows for project b'
flowRunSubmitted = Gauge('prefect_flowruns_submitted', 'Number of submitted flow runs by Project', ['project_id', 'project_name'])
```

1. **Adding the export function into** `monitor.py`.
In the example below, we will take in a list of `allProjects` (already an existing query). For each project, we execute the query FlowRunSuccessByProject and pass in the ID of the project. This returns a list of Flows in the given project. From that list of flows, we assign:
   a) Project ID as a label
   b) Project Name as a label
   c) Set the value of the gauge as the length of the list, which is the # of flows that matched the query.

```python
1: def exportFlowRunSuccess(allProjects):
2:    for project in allProjects:
3:        project_Flows = queryFlowRunSuccessByProject(project['id'])
4:        flowRunTotalSuccess.labels(project['id'], project['name']).set(len(project_Flows))
```

1. **Adding the query function.**
This takes in the project ID, which is passed in the third line of the preceding function `exportFlowRunSuccess`.
As GraphQL requires this variable to query, we assign it to `variables`.
The query itself is a multi-line string and can be crafted in the Interactive API, and copied in exactly.
The `queryName` is the name of the function - this is just for additional telemetry to determine how long each query call is taking by queryName → ID.
We then call `callQuery(query, queryName, variables)`, a wrapper that handles timing, the request, and retries. 
The results are then returned; as the response is typically a nested json response, we need to extract the actual list of Flows which is in the `[’data’][’flow_run’]` key.

```python
def queryFlowRunTotalByProject(project_id: str) -> list: 
    variables = {
        "project_id": project_id
    }

    query = """
    query TotalFlowRuns($project_id: uuid) {
        flow_run(where: {flow: {project_id: {_eq: $project_id}}}) {
            id,
            name,
            state
        }
    }
    """

    queryName = "queryFlowRunTotalByProject"
    flowRuns = callQuery(query, queryName, variables)
    return flowRuns['data']['flow_run']
```

1. **Updating the core metric loop.**

This is just simply adding the `exportFlowRunSuccess`  function to the core loop.

```python
def getAllMetrics():
    allProjects = queryAllProjects()
    exportAllProjects(allProjects)
    exportAllFlows()
    exportFlowsByProject(allProjects)
    exportFlowRunTotal(allProjects)
    exportFlowRunSuccess(allProjects)
    exportFlowStatus(allProjects)
    exportflowRunUpcoming(allProjects)
```

1. Once these changes are made to `monitor.py`, the image would need to be rebuilt and pushed (Steps 1-3 to build, push the image, and update the tag for Helm).
2. Lastly, with the new image pushed the metrics should be exposed and visible on the container endpoint at /metrics. As the datasource is in turn being pulled into Grafana already, the new metric ‘key’ created in the prometheus variable can be graphed / charted as needed.
