SHELL := /bin/bash

help:	## displays help for Makefile
	@printf "\n\n################################\n\n"
	@printf "Lookup API Makefile Targets"
	@printf "\n\n################################\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## install dependencies
	@printf "\n\n++++++++++++++ STARTING install ++++++++++++++++++\n";
	pipenv install
	@printf "++++++++++++++ DONE WITH install ++++++++++++++++++\n";

install-dev: ## install dev dependencies
	@printf "\n\n++++++++++++++ STARTING install dev ++++++++++++++++++\n";
	pipenv install --dev
	@printf "++++++++++++++ DONE WITH install dev ++++++++++++++++++\n";

pipenv: ## starts pipenv
	@printf "\n\n++++++++++++++ STARTING pyenv ++++++++++++++++++\n";
	pipenv install --deploy
	@printf "\n\n++++++++++++++ DONE WITH pyenv ++++++++++++++++++\n";

pipenv-dev: ## starts dev pipenv
	@printf "\n\n++++++++++++++ STARTING pyenv ++++++++++++++++++\n";
	pipenv install --dev --deploy
	@printf "++++++++++++++ DONE WITH pyenv ++++++++++++++++++\n";

lint: pipenv-dev ## runs a lint
	@printf "\n\n++++++++++++++ STARTING flake8 linter ++++++++++++++++++\n";
	pipenv run flake8 app
	@printf "\n\n++++++++++++++ DONE WITH flake8 linter ++++++++++++++++++\n";

migration: pipenv ## performs a database migration
	@printf "\n\n++++++++++++++ STARTING flake8 linter ++++++++++++++++++\n";
	alembic upgrade head
	@printf "\n\n++++++++++++++ DONE WITH flake8 linter ++++++++++++++++++\n";

test: pipenv-dev  ## runs unit tests
	@printf "\n\n++++++++++++++ STARTING test ++++++++++++++++++\n";
	pipenv run pytest
	@printf "\n\n++++++++++++++ DONE WITH test ++++++++++++++++++\n";

security: pipenv-dev ## check for security issues on code
	@printf "\n\n++++++++++++++ STARTING security check ++++++++++++++++++\n";
	pipenv run bandit -r app
	@printf "\n\n++++++++++++++ DONE WITH security check ++++++++++++++++++\n";

docker-lint: ## runs docker lint for Dockerfile
	@printf "\n\n++++++++++++++ STARTING docker lint ++++++++++++++++++\n";
	docker run --rm --interactive hadolint/hadolint < Dockerfile
	@printf "\n\n++++++++++++++ DONE WITH docker lint ++++++++++++++++++\n";

run: migration ## starts the application
	@printf "\n\n++++++++++++++ STARTING run ++++++++++++++++++\n";
	pipenv run python3 main.py
	@printf "\n\n++++++++++++++ DONE WITH run ++++++++++++++++++\n";

pre-commit: lint test security docker-lint ## pre-check before commit and push
