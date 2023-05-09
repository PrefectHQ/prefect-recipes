# Running Local Development Flows in Docker

### Start from a clean directory
```bash
mkdir ~/test_docker_dev && cd ~/test_docker_dev
```

### Create a .envfile for docker environment variablesand update with your values here:
```bash
# Create the file
touch .envFile

#Copy in the contents:
PREFECT_API_KEY=<>
PREFECT_API_URL=<>
AZURE_STORAGE_CONNECTION_STRING=<Optional ; required if not using a block>
```

### Clone down code:
```bash
git clone https://<>@bitbucket.org/sopkin/azure-deployments.git
```

### Change to the right directory:
```bash
cd azure-deployments/local-docker-dev
```

### Start Docker Desktop if it's not running already

### Pull a docker image :
```bash
docker pull prefecthq/prefect:2-python3.9
```

### Run the docker image, mounting in the cloned repository, and private .envfile :
```bash
docker run -v ~/test_docker_dev/azure-deployments/local-docker-dev/:/opt/prefect/flows --env-file ~/test_docker_dev/.envfile -it prefecthq/prefect:2-python3.9 /bin/sh
```

### Change to the flows directory :
```bash
cd /opt/prefect/flows
pip install -r requirements.txt
```

### Run the flow :
```bash
python transform_flow.py
```

### (Optional) Create a work pool in the docker container :
```bash
prefect work-pool create 'docker-dev'
```

### (Optional) Build and Register the flow as a deployment :
```bash
prefect deployment build ./transform_flow.py:transform_flow -n transform-flow-deploy -p docker-dev --apply
```

### (Optional) Start a work pool in the docker container :
```bash
prefect agent start -p 'docker_pool'
```

### (Optional) Run the flow from the UI and monitor :
