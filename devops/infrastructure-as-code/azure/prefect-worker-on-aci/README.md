# Running Local Development Flows in Docker

### Start from a clean directory
```bash
mkdir ~/test_aci_dev && cd ~/test_aci_dev
```

### Create a .pass and .user local file for configuring ACI credentials
```bash
# Create the file
touch .pass
touch .user

#Update the contents
vim .pass
this_is_my_docker_password

vim .user
this_is_my_docker_username
```

### Clone down the repository :
```bash
git clone https://<>@bitbucket.org/sopkin/azure-deployments.git
```

### Change to the right directory:
```bash
cd azure-deployments/prefect-worker-on-aci
```

### Create a Resource group:
```bash
az group create --name "rg_name_here" --location eastus
```

### Edit create_container.sh and update the necessary values to deploy:
```bash
rg=BoydACIPrefectAgent
container_name="prefect-aci-worker"
image='index.docker.io/chaboy/private_test:latest'
registry_server='index.docker.io'
```

### Execute create_container.sh:
```bash
./create_container.sh
```

### Once Provisioned, you can:
    - Create a Deployment
    - Update the Worker Pool

### (Option A: Build an Image Containing Flow Code)
Flow code and a Dockerfile are already included as an example.

```bash
export image_tag="your repo/image:tag"
docker build --platform linux/amd64 -t $image_tag .

#Push to registry:
docker push $image_tag
```

### Update the Pool to reference this Image
    - If it's a Private Image, attach a Docker Registry Credentials Block

### Deploy / Apply a Deployment
A sample deployment is provided for this tutorial.
```bash
python deployment.py
```



