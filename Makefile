# Set the port to expose on the host
HOST_PORT ?= 8080

# Makefile targets

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: dev
dev: ## Run the development server
	pipenv run mkdocs serve --dev-addr localhost:$(HOST_PORT)

.PHONY: build
build: ## Build the documentation
	pipenv run mkdocs build && cp docs/skill.md site

.PHONY: clean
clean: ## Remove build artifacts
	rm -rf site

.PHONY: all
all: build ## Default target – builds the documentation

.PHONY: test
test: ## Placeholder to satisfy linters
	@echo "No tests defined yet"
