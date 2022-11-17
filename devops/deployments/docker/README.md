# Prefect Flows in Docker Containers

This recipe demonstrates how to run Prefect flows in Docker containers. Although this example uses your local Docker engine, the concepts extend to any infrastructure block that uses images, such as `KubernetesJob`s and `ECSTask`s.

In order for a Prefect agent to run your flow, it needs a copy of your flow code. Prefect doesn't ever store your code, so there has to be some intermediary storage location. This intermediary is called the storage block, and there are a few options available,

1. Local file system (i.e. files on your computer or another "local" location)
2. Remote file system (i.e. S3 or similar)
3. Git (i.e. a GitHub or BitBucket repo)

The key thing to keep in mind with image-based infrastructure blocks is that the image can serve as a fourth storage option. It certainly isn't required, but if you choose to, you can "store" your flow code in your image. In practice, when creating a deployment with an image-based infrastructure block, you can omit the storage block and Prefect will assume your flow code is available in the image at runtime. Further, if you base your image on Prefect's official images (as shown in the [Dockerfile](./Dockerfile)), your flow code will be assumed to exist in the `/opt/prefect/` directory.

## Getting Started

Assuming you have `make` installed - most systems do - then simply run the following command,

```sh
make all
```

This will,
1. Build an image with our code and dependencies.
2. Create the infrastructure block that our deployment will use.
3. Create a deployment of our hello flow.
4. Create a flow run and then start an agent to process it.

Notably, we don't specify a storage block anywhere since our code is built into our image.

## Extending to Other Infrastructures

This example works well locally, but if we want to extend the concepts to other infrastructures, there are a few considerations:

First, we need to hand off our image to a registry. There are many options here (DockerHub, AWS ECR, and GitHub Container Registry to name a few), but they all do more or less the same thing. After we build our image, we'll want to login to our registry and push our image there. Note that the name of our image will change to include some information about our registry. As an example, here's what this might look like with AWS ECR,

```sh
export REGION=us-east-1
export ACCOUNT_ID=123456789

aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

docker tag prefect-docker-example:latest $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/prefect-docker-example:latest

docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/prefect-docker-example:latest
```

Second, we'll want to make sure that our image is accessible at runtime. This means we need to update the `image` attribute in our infrastructure block to the one we pushed. More importantly, we need our actual infrastructure to have permission to pull the image from the registry. There are many ways to accomplish this. Sticking with our AWS examples, the most common way would be to pass an IAM role to your resource.

Finally, we'll want to configure the other options on our infrastructure block. This step is highly dependent on the specific block, and such is best covered elsewhere.