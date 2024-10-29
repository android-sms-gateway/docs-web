# Set the image name
IMAGE_NAME ?= capcom6/android-sms-gateway-docs

# Set the container name
CONTAINER_NAME ?= android-sms-gateway-docs

# Set the port to expose on the host
HOST_PORT ?= 8080

# Makefile targets
.PHONY: build run stop clean

# Serve the documentation
dev:
	mkdocs serve

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run: build
	docker run --rm --name $(CONTAINER_NAME) -p $(HOST_PORT):80 $(IMAGE_NAME)

# Stop and remove the Docker container
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

# Remove the Docker image
clean: stop
	docker rmi $(IMAGE_NAME)

# Rebuild the Docker image
rebuild: clean build

# Helper to shell into the running container
shell:
	docker exec -it $(CONTAINER_NAME) /bin/sh
