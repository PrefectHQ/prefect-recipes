from prefect.infrastructure.docker import DockerContainer, ImagePullPolicy


def create_docker_container():
    block = DockerContainer(
        name="prefect-docker-example",
        image="prefect-docker-example:latest",
        # We want to always use our local image, so we NEVER pull it
        image_pull_policy=ImagePullPolicy.NEVER,
    )
    block.save("prefect-docker-example", overwrite=True)


if __name__ == "__main__":
    create_docker_container()
