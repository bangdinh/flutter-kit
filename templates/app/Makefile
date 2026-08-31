# Makefile — dev tooling for __name__ (built on flutter_kit).
# `make` or `make help` lists the commands.

.DEFAULT_GOAL := help
.PHONY: help get gen gen-watch clean analyze format test test-coverage \
        run-dev run-stg run-prod feature ci

DART ?= dart
FLUTTER ?= flutter

help: ## List commands (default)
	@echo "__name__ — commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

get: ## flutter pub get
	$(FLUTTER) pub get

gen: ## build_runner (riverpod, freezed, json, envied)
	$(DART) run build_runner build

gen-watch: ## build_runner in watch mode
	$(DART) run build_runner watch

analyze: ## dart analyze (flutter analyze crashes on some machines)
	$(DART) analyze lib test

format: ## dart format
	$(DART) format lib test --line-length 80

test: ## flutter test
	$(FLUTTER) test

test-coverage: ## flutter test with coverage
	$(FLUTTER) test --coverage

clean: ## flutter clean + pub get
	$(FLUTTER) clean
	rm -rf .dart_tool build
	$(FLUTTER) pub get

run-dev: ## run against dev
	$(FLUTTER) run --dart-define=ENV=dev

run-stg: ## run against staging
	$(FLUTTER) run --dart-define=ENV=staging

run-prod: ## run against prod (release)
	$(FLUTTER) run --dart-define=ENV=prod --release

## Scaffold a feature folder: make feature NAME=profile
# The generator lives in the kit, so every app's structure stays identical.
feature: ## scaffold lib/features/<NAME> (NAME=profile)
	@test -n "$(NAME)" || { echo "Usage: make feature NAME=<feature_name>"; exit 1; }
	$(DART) run flutter_kit:new_feature $(NAME)

ci: get gen analyze test ## everything CI runs, locally
	@echo "✅ analyze and tests passed"

## Bump the kit: edit the `ref:` in pubspec.yaml, then
##   make get && make gen && make ci
## Read the kit's CHANGELOG for the tag you are moving to first.
