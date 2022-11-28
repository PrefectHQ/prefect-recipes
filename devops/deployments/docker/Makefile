# Makefiles provide a handy way to codify commands. Instead of having to copy
# paste commands from a README, you can  execute them as "make <command>": for
# example "make all" or "make run". If your system doesn't include make, or if
# you just want to avoid it, you can always run the commands directly.

# .PHONY forces make to run commands even if files haven't changed.
.PHONY: build-image create-blocks deploy run all

# First, we build an image with our code and dependencies.
build-image:
	docker build -t prefect-docker-example:latest .

# Second, we create the infrastructure block that our deployment will use.
create-blocks:
	python blocks/docker_container.py

# Third, we create a deployment of our hello flow.
deploy:
	prefect deployments build \
		flows/hello.py:hello \
		--name prefect-docker-example \
		--infra-block docker-container/prefect-docker-example \
		--work-queue docker \
		--apply

# Finally, we create a flow run and then start an agent to process it.
run:
	prefect deployment run hello/prefect-docker-example
	prefect agent start -q docker

# Run "make all" to see the end to end process.
all: build-image create-blocks deploy run
