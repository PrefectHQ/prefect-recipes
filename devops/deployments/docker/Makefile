# Makefiles provide a handy way to codify commands
# Instead of having to copy paste commands from the
# README, you can just execute them as "make <command",
# for example "make build" or "make all". If your
# system doesn't include make, or if you just want to
# avoid it, you can always just copy paste the commands.

# This forces make to run commands even if files haven't changed
.PHONY: create-image create-blocks deploy run all

# Let's define our commands
create-image:
	docker build -t prefect-docker-example:latest .

create-blocks:
	python blocks/docker_container.py

deploy:
	prefect deployments build \
		flows/hello.py:hello \
		--name prefect-docker-example \
		--infra-block docker-container/prefect-docker-example \
		--work-queue docker \
		--apply

run:
	prefect deployment run hello/prefect-docker-example
	prefect agent start -q docker

all: create-image create-blocks deploy run
