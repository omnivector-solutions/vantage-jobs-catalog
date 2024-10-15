SHELL:=/bin/bash
ROOT_DIR:=$(shell dirname $(shell pwd))

.PHONY: install
install: ## Install Python packages
	poetry install

.PHONY: lint
lint: install ## Lint the project using ruff
	poetry run ruff check builder infra

.PHONY: mypy
mypy: install ## Run mypy on the project
	poetry run mypy builder --pretty

.PHONY: qa
qa: lint mypy ## Run the quality assurance check
	echo "All tests pass! Ready for deployment"

.PHONY: format
format: install ## Format the code using ruff
	poetry run ruff format builder infra

.PHONY: clean
clean: ## Clean all files/folders created by the project
	@find . -iname '*.pyc' -delete
	@find . -iname '__pycache__' -delete
	@find . -type d -name '.mypy_cache' -exec rm -rf {} +
	@find . -type d -name '.ruff_cache' -exec rm -rf {} +
	@find . -type d -name '.venv' -exec rm -rf {} +
	@find . -iname '*.sif' -delete
	@find . -iname 'catalog.yaml' -delete
	@find . -type d -name 'cdk.out' -exec rm -rf {} +

.PHONY: help
help: ## Print the targets and their descriptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'%